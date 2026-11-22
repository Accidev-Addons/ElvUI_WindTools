local W ---@class WindTools
local F, E, L ---@type Functions, ElvUI, LocaleTable
W, F, E, L = unpack((select(2, ...)))
local C = W.Utilities.Color
local UF = E:GetModule("UnitFrames")

local floor = floor
local format = format
local gsub = gsub
local ipairs = ipairs
local max = max
local min = min
local select = select
local strjoin = strjoin
local strsplit = strsplit
local tconcat = table.concat
local tonumber = tonumber
local tostring = tostring
local tremove = tremove
local wipe = wipe

local CreateFrame = CreateFrame
local GetAverageItemLevel = GetAverageItemLevel
local GetClassInfo = GetClassInfo
local GetItemLevelColor = GetItemLevelColor
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetTime = GetTime
local IsIgnored = IsIgnored

local C_CategorySpell_GetCategoryInfo = C_CategorySpell.GetCategoryInfo
local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local C_ChallengeMode_GetMapTable = C_ChallengeMode.GetMapTable
local C_MythicPlus_GetPlayerStatsForMap = C_MythicPlus.GetPlayerStatsForMap
local C_MythicPlus_IsMythicPlusActive = C_MythicPlus.IsMythicPlusActive
local C_MythicPlus_RequestPlayerStat = C_MythicPlus.RequestPlayerStat
local C_LFGList_GetActivityInfoTable = C_LFGList.GetActivityInfoTable
local C_LFGList_GetSearchResultEncounterInfo = C_LFGList.GetSearchResultEncounterInfo
local C_LFGList_GetSearchResultFriends = C_LFGList.GetSearchResultFriends
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_LFGList_GetSearchResultPlayerInfo = C_LFGList.GetSearchResultPlayerInfo
local C_LFGList_IsSavedInstance = C_LFGList.IsSavedInstance

local GROUP_FINDER_CATEGORY_ID_DUNGEONS = GROUP_FINDER_CATEGORY_ID_DUNGEONS
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE

---@cast F Functions

---@class LFGPlayerInfo
local LFGPI = {
	name = "Utilities:LFGPlayerInfo",
}
W.Utilities.LFGPlayerInfo = LFGPI

---@return string name
function LFGPI:GetName()
	return self.name
end

F.Developer.InjectLogger(LFGPI)

local classIconStyle = "flat" ---@type ClassIconStyle

---@param style ClassIconStyle
function LFGPI:SetClassIconStyle(style)
	if style then
		classIconStyle = style
	end
end

---@type ("TANK" | "HEALER" | "DAMAGER")[]
local roleOrder = { "TANK", "HEALER", "DAMAGER" }
local roleIndex = { TANK = 1, HEALER = 2, DAMAGER = 3 }

---@return ("TANK" | "HEALER" | "DAMAGER")[] roleOrder
function LFGPI.GetRoleOrder()
	return roleOrder
end

local roleColors = { TANK = "00a8ff", HEALER = "2ecc71", DAMAGER = "e74c3c" }
local roleNames = { TANK = L["Tank"], HEALER = L["Healer"], DAMAGER = L["DPS"] }

---@param role string
---@return string coloredName
function LFGPI.GetColoredRoleName(role)
	return roleColors[role] and format("|cff%s%s|r", roleColors[role], roleNames[role]) or ""
end

local classList = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }

---@type table<ClassFile, integer>
local classFileToID = {}

---@type table<ClassFile, table<string, integer>>
local localizedSpecNameToID = {}

---@type table<ClassFile, table<string, string>>
local localizedSpecNameToIcon = {}

for classID = 1, 13 do
	local classFile = select(2, GetClassInfo(classID)) ---@type ClassFile|nil

	if classFile then
		classFileToID[classFile] = classID
		localizedSpecNameToID[classFile] = localizedSpecNameToID[classFile] or {}
		localizedSpecNameToIcon[classFile] = localizedSpecNameToIcon[classFile] or {}

		for specIndex = 1, 4 do
			local id, name, _, icon = GetSpecializationInfoForClassID(classID, specIndex)
			if id and name and icon then
				localizedSpecNameToID[classFile][name] = id
				localizedSpecNameToIcon[classFile][name] = icon
			end
		end
	end
end

---@param class string
---@param spec string
---@return string|nil iconPath
function LFGPI.GetIconTextureWithClassAndSpecName(class, spec)
	return localizedSpecNameToIcon[class] and localizedSpecNameToIcon[class][spec]
end

---@return number itemLevel
function LFGPI.GetPlayerItemLevel()
	return floor(GetAverageItemLevel() or 0)
end

local KEY_QUEUE_LIMIT = 40
local KEY_REQUEST_TIMEOUT = 5

local keyRatings = {}
local keyQueue = {}
local keyPending, keyPendingTime

local function requestNextKeyRating()
	if keyPending then
		if GetTime() - keyPendingTime < KEY_REQUEST_TIMEOUT then
			return
		end
		keyRatings[keyPending] = nil
	end

	keyPending = tremove(keyQueue)
	if keyPending then
		keyPendingTime = GetTime()
		if C_MythicPlus_RequestPlayerStat(keyPending) == false then
			keyRatings[keyPending] = nil
			keyPending = nil
		end
	end
end

local keyFrame = CreateFrame("Frame")
keyFrame:RegisterCustomEvent("MYTHIC_PLUS_PLAYER_STAT_UPDATE")
keyFrame:SetScript("OnEvent", function(_, _, loaded)
	local name = keyPending
	if not name then
		return
	end
	keyPending = nil

	local rating = 0
	if loaded then
		for _, mapID in ipairs(C_ChallengeMode_GetMapTable()) do
			local stats = C_MythicPlus_GetPlayerStatsForMap(name, mapID)
			rating = rating + (stats and stats.dungeonScore or 0)
		end
	end
	keyRatings[name] = floor(rating)

	requestNextKeyRating()
	if LFGPI.OnKeyRating then
		LFGPI.OnKeyRating()
	end
end)

---@param name string
---@return number? rating
function LFGPI:GetKeyRating(name)
	local rating = keyRatings[name]
	if rating == nil and name ~= "" and C_MythicPlus_IsMythicPlusActive() then
		if #keyQueue >= KEY_QUEUE_LIMIT then
			keyRatings[tremove(keyQueue, 1)] = nil
		end
		keyRatings[name] = false
		keyQueue[#keyQueue + 1] = name
	end

	requestNextKeyRating()
	return rating or nil
end

local groupCache = {}
local groupCacheTime = 0

---@param resultID number
---@return table? group
function LFGPI:GetGroup(resultID)
	local now = GetTime()
	if groupCacheTime ~= now then
		wipe(groupCache)
		groupCacheTime = now
	end

	local group = groupCache[resultID]
	if group then
		return group
	end

	local info = resultID and C_LFGList_GetSearchResultInfo(resultID)
	if not info then
		return
	end

	local activity = C_LFGList_GetActivityInfoTable(info.activityID) or {}
	local leaderScore = activity.isMythicPlusActivity and info.leaderOverallDungeonScore
	local friends, guildMates = C_LFGList_GetSearchResultFriends(resultID)
	local relations = {}
	for _, name in ipairs(friends) do
		relations[name] = "friend"
	end
	for _, name in ipairs(guildMates) do
		relations[name] = "guild"
	end

	group = {
		id = resultID,
		info = info,
		activity = activity,
		members = {},
		classes = {},
		ignored = {},
		tanks = 0,
		healers = 0,
		dps = 0,
		num = 0,
		max = activity.maxNumPlayers or 0,
		reqIlvl = info.requiredItemLevel or 0,
		friends = #friends + #guildMates,
		bosses = C_LFGList_GetSearchResultEncounterInfo(resultID) or {},
		saved = C_LFGList_IsSavedInstance(resultID),
		leaderName = info.leaderName ~= "" and info.leaderName or nil,
		leaderClass = info.leaderClassID and select(2, GetClassInfo(info.leaderClassID)),
		leaderScore = leaderScore and leaderScore > 0 and leaderScore or nil,
	}

	local sum, lowest, highest = 0, nil, 0
	for i = 1, info.numMembers or 0 do
		local player = C_LFGList_GetSearchResultPlayerInfo(resultID, i)
		if player and player.classFilename then
			local name = player.name or ""
			local member = {
				name = name,
				ilvl = player.level or 0,
				class = player.classFilename,
				spec = player.specName,
				role = player.assignedRole or "DAMAGER",
				category = player.categorySpell or 0,
				isLeader = player.isLeader,
				relation = relations[name],
				group = group,
			}

			if IsIgnored(name) then
				member.relation = "ignored"
				group.ignored[#group.ignored + 1] = name
				if member.isLeader then
					group.leaderIgnored = true
				end
			end

			group.members[#group.members + 1] = member
			group.classes[member.class] = (group.classes[member.class] or 0) + 1
			if member.role == "TANK" then
				group.tanks = group.tanks + 1
			elseif member.role == "HEALER" then
				group.healers = group.healers + 1
			else
				group.dps = group.dps + 1
			end

			sum = sum + member.ilvl
			lowest = min(lowest or member.ilvl, member.ilvl)
			highest = max(highest, member.ilvl)
		end
	end

	group.num = #group.members
	group.free = max(group.max - group.num, 0)
	group.avgIlvl = group.num > 0 and floor(sum / group.num + 0.5) or 0
	group.minIlvl = lowest or 0
	group.maxIlvl = highest
	group.qualified = group.reqIlvl <= LFGPI.GetPlayerItemLevel()

	groupCache[resultID] = group
	return group
end

---@param resultID number
---@return boolean isDungeon
function LFGPI:IsIDDungeons(resultID)
	local result = C_LFGList_GetSearchResultInfo(resultID)
	local activity = result and C_LFGList_GetActivityInfoTable(result.activityID)
	return activity and activity.categoryID == GROUP_FINDER_CATEGORY_ID_DUNGEONS
end

---@param members table[]
---@param mode "ROLE"|"ILVL"|"CLASS"|"NAME"|"NONE"
---@return table[] sorted
function LFGPI:SortMembers(members, mode)
	local sorted = {}
	for i, member in ipairs(members) do
		sorted[i] = member
	end

	if mode == "NONE" then
		return sorted
	end

	table.sort(sorted, function(a, b)
		if mode == "ROLE" and a.role ~= b.role then
			return roleIndex[a.role] < roleIndex[b.role]
		end
		if mode == "CLASS" and a.class ~= b.class then
			return a.class < b.class
		end
		if mode ~= "NAME" and a.ilvl ~= b.ilvl then
			return a.ilvl > b.ilvl
		end
		return a.name < b.name
	end)

	return sorted
end

local namedColors = {
	red = "ff5555",
	green = "55ff55",
	yellow = "ffd200",
	orange = "ff8000",
	blue = "66bbff",
	gray = "999999",
	white = "ffffff",
}

local relationTexts = {
	friend = "|cff66bbff" .. L["Friend"] .. "|r",
	guild = "|cff55ff55" .. L["Guild"] .. "|r",
	ignored = "|cffff5555" .. L["Ignored"] .. "|r",
}

local function parseSize(args, default)
	local height, width = strsplit(",", args or "")
	height = tonumber(height) or default
	return height, tonumber(width) or height
end

local function roleIcon(role, args)
	local texture = role and UF.RoleIconTextures[role]
	if not texture then
		return ""
	end
	local height, width = parseSize(args, 14)
	return format("|T%s:%d:%d:0:0:64:64:8:56:8:56|t", texture, height, width)
end

local function plainIcon(texture, args, default)
	local height, width = parseSize(args, default)
	return format("|T%s:%d:%d|t", texture, height, width)
end

local function positive(value)
	return value and value > 0 and value or ""
end

local function wrapItemLevel(itemLevel, text)
	local color = itemLevel and itemLevel > 0 and GetItemLevelColor(itemLevel)
	return color and color:WrapTextInColorCode(text) or text
end

local function wrapKeyRating(rating, text)
	local color = rating and rating > 0 and C_ChallengeMode_GetDungeonScoreRarityColor(rating)
	return color and color:WrapTextInColorCode(text) or text
end

local function shortAge(seconds)
	local minutes = max(1, floor((seconds or 0) / 60))
	if minutes < 60 then
		return format(L["%d min"], minutes)
	end
	return format(L["%d h"], floor(minutes / 60))
end

local playerTags = {
	value = {
		name = function(m)
			return m.name
		end,
		ilvl = function(m)
			return positive(m.ilvl)
		end,
		className = function(m)
			return LOCALIZED_CLASS_NAMES_MALE[m.class]
		end,
		classId = function(m)
			return classFileToID[m.class]
		end,
		classIcon = function(m, args)
			local height, width = parseSize(args, 14)
			return m.class and F.GetClassIconStringWithStyle(m.class, classIconStyle, width, height)
		end,
		specName = function(m)
			return m.spec
		end,
		specId = function(m)
			return localizedSpecNameToID[m.class] and localizedSpecNameToID[m.class][m.spec]
		end,
		specIcon = function(m, args)
			local icon = LFGPI.GetIconTextureWithClassAndSpecName(m.class, m.spec)
			local height, width = parseSize(args, 14)
			return icon and F.GetIconString(icon, height, width, true)
		end,
		roleIcon = function(m, args)
			return roleIcon(m.role, args)
		end,
		roleName = function(m)
			return roleNames[m.role]
		end,
		categoryName = function(m)
			return m.category and m.category ~= 0 and (C_CategorySpell_GetCategoryInfo(m.category))
		end,
		categoryIcon = function(m, args)
			local _, icon = C_CategorySpell_GetCategoryInfo(m.category or 0)
			local height, width = parseSize(args, 14)
			return icon and F.GetIconString(icon, height, width)
		end,
		leaderIcon = function(m, args)
			return m.isLeader and plainIcon(W.Media.Icons.leader, args, 12)
		end,
		leader = function(m)
			return m.isLeader and L["Leader"]
		end,
		relation = function(m)
			return relationTexts[m.relation]
		end,
		keyRating = function(m)
			return m.keyRating or LFGPI:GetKeyRating(m.name)
		end,
		amount = function(m)
			return m.amount
		end,
	},
	cond = {
		amount = function(m)
			return m.amount and m.amount > 1
		end,
		category = function(m)
			return m.category and m.category ~= 0
		end,
		friend = function(m)
			return m.relation == "friend"
		end,
		guild = function(m)
			return m.relation == "guild"
		end,
		ignored = function(m)
			return m.relation == "ignored"
		end,
	},
	wrap = {
		classColor = function(m, text)
			return C.StringWithClassColor(text, m.class) or text
		end,
		ilvlColor = function(m, text)
			return wrapItemLevel(m.ilvl, text)
		end,
		roleColor = function(m, text)
			return roleColors[m.role] and format("|cff%s%s|r", roleColors[m.role], text) or text
		end,
		keyColor = function(m, text)
			return wrapKeyRating(m.keyRating or keyRatings[m.name], text)
		end,
	},
}

local groupTags = {
	value = {
		groupName = function(g)
			return g.info.name
		end,
		activity = function(g)
			return g.activity.fullName
		end,
		activityShort = function(g)
			return g.activity.shortName
		end,
		leaderName = function(g)
			return g.leaderName and (C.StringWithClassColor(g.leaderName, g.leaderClass) or g.leaderName)
		end,
		leaderScore = function(g)
			return g.leaderScore
		end,
		members = function(g)
			return g.num
		end,
		max = function(g)
			return positive(g.max)
		end,
		free = function(g)
			return positive(g.free)
		end,
		tanks = function(g)
			return g.tanks
		end,
		healers = function(g)
			return g.healers
		end,
		dps = function(g)
			return g.dps
		end,
		tankIcon = function(_, args)
			return roleIcon("TANK", args)
		end,
		healerIcon = function(_, args)
			return roleIcon("HEALER", args)
		end,
		dpsIcon = function(_, args)
			return roleIcon("DAMAGER", args)
		end,
		avgIlvl = function(g)
			return positive(g.avgIlvl)
		end,
		minIlvl = function(g)
			return positive(g.minIlvl)
		end,
		maxIlvl = function(g)
			return positive(g.maxIlvl)
		end,
		reqIlvl = function(g)
			return positive(g.reqIlvl)
		end,
		myIlvl = function()
			return LFGPI.GetPlayerItemLevel()
		end,
		age = function(g)
			return shortAge(g.info.age)
		end,
		bosses = function(g)
			return positive(#g.bosses)
		end,
		voice = function(g)
			return g.info.voiceChat
		end,
		friends = function(g)
			return positive(g.friends)
		end,
		difficulty = function(g)
			return g.activity.isHeroicActivity and L["Heroic"] or g.activity.isNormalActivity and L["Normal"]
		end,
		saved = function(g)
			return g.saved and L["Saved"]
		end,
		ignored = function(g)
			return #g.ignored > 0 and tconcat(g.ignored, ", ")
		end,
		categoryName = function(g)
			local spell = g.info.categorySpell
			return spell and spell > 0 and (C_CategorySpell_GetCategoryInfo(spell))
		end,
		categoryIcon = function(g, args)
			local _, icon = C_CategorySpell_GetCategoryInfo(g.info.categorySpell or 0)
			local height, width = parseSize(args, 14)
			return icon and F.GetIconString(icon, height, width)
		end,
		skull = function(_, args)
			return plainIcon([[Interface\TargetingFrame\UI-TargetingFrame-Skull]], args, 12)
		end,
		classes = function(g, args)
			local height, width = parseSize(args, 14)
			local parts = {}
			for _, class in ipairs(classList) do
				local count = g.classes[class]
				if count then
					local icon = F.GetClassIconStringWithStyle(class, classIconStyle, width, height)
					parts[#parts + 1] = count > 1 and icon .. count or icon
				end
			end
			return tconcat(parts, " ")
		end,
		missing = function(g, args)
			local height, width = parseSize(args, 14)
			local parts = {}
			for _, class in ipairs(classList) do
				if not g.classes[class] then
					parts[#parts + 1] = F.GetClassIconStringWithStyle(class, classIconStyle, width, height)
				end
			end
			return tconcat(parts, " ")
		end,
	},
	cond = {
		qualified = function(g)
			return g.qualified
		end,
		unqualified = function(g)
			return not g.qualified
		end,
		heroic = function(g)
			return g.activity.isHeroicActivity
		end,
	},
	wrap = {
		ilvlColor = function(g, text)
			return wrapItemLevel(g.avgIlvl, text)
		end,
		leaderScoreColor = function(g, text)
			return wrapKeyRating(g.leaderScore, text)
		end,
		classColor = function(g, text)
			return g.leaderClass and C.StringWithClassColor(text, g.leaderClass) or text
		end,
		reqColor = function(g, text)
			return format("|cff%s%s|r", g.qualified and namedColors.green or namedColors.red, text)
		end,
	},
}

local function shown(value)
	return value ~= nil and value ~= false and value ~= "" and value ~= 0
end

local function render(template, tags, context)
	local text = gsub(template, "{{(%a+)Start}}(.-){{%1End}}", function(name, body)
		local wrap = tags.wrap[name]
		local hex = namedColors[name]
		local test = tags.cond[name] or tags.value[name]
		if not wrap and not hex and not test then
			return
		end

		body = render(body, tags, context)
		if wrap then
			return wrap(context, body)
		elseif hex then
			return format("|cff%s%s|r", hex, body)
		end
		return shown(test(context)) and body or ""
	end)

	return (gsub(text, "{{(%a+):?([%d,]*)}}", function(name, args)
		local value = tags.value[name]
		if not value then
			return
		end

		local result = value(context, args)
		return shown(result) and tostring(result) or ""
	end))
end

---@param template string
---@param member table
---@return string text
function LFGPI:RenderPlayer(template, member)
	return render(template or "", playerTags, member)
end

---@param template string
---@param group table
---@return string text
function LFGPI:RenderGroup(template, group)
	return render(template or "", groupTags, group)
end

---@param group table
---@return table<string, table[]> composition
function LFGPI:GetComposition(group)
	local composition = { TANK = {}, HEALER = {}, DAMAGER = {} }
	local index = {}

	for _, member in ipairs(self:SortMembers(group.members, "CLASS")) do
		local key = strjoin(":", member.role, member.class, member.spec or "")
		local entry = index[key]
		if not entry then
			entry = { role = member.role, class = member.class, spec = member.spec, amount = 0, name = "", ilvl = 0 }
			index[key] = entry
			composition[member.role][#composition[member.role] + 1] = entry
		end
		entry.amount = entry.amount + 1
	end

	return composition
end

local previewGroup

---@return table group
function LFGPI:GetPreviewGroup()
	if previewGroup then
		return previewGroup
	end

	local function specName(classID, specIndex)
		return (select(2, GetSpecializationInfoForClassID(classID, specIndex)))
	end

	local group = {
		id = 0,
		info = {
			name = L["Sample group"],
			comment = "",
			voiceChat = "Discord",
			age = 754,
			categorySpell = 90010,
			requiredItemLevel = 250,
		},
		activity = {
			fullName = L["Sample Mythic+ dungeon"],
			shortName = L["Sample dungeon"],
			isMythicPlusActivity = true,
			maxNumPlayers = 5,
		},
		members = {},
		classes = { PALADIN = 2, PRIEST = 1, MAGE = 1 },
		ignored = {},
		bosses = { "1", "2", "3" },
		tanks = 1,
		healers = 1,
		dps = 2,
		num = 4,
		max = 5,
		free = 1,
		reqIlvl = 250,
		friends = 1,
		avgIlvl = 256,
		minIlvl = 249,
		maxIlvl = 263,
		saved = true,
		qualified = true,
		leaderName = "Uther",
		leaderClass = "PALADIN",
		leaderScore = 1820,
	}

	local function add(name, class, classID, specIndex, role, ilvl, category, isLeader, relation, keyRating)
		group.members[#group.members + 1] = {
			keyRating = keyRating,
			name = name,
			ilvl = ilvl,
			class = class,
			spec = specName(classID, specIndex),
			role = role,
			category = category,
			isLeader = isLeader,
			relation = relation,
			amount = 2,
			group = group,
		}
	end

	add("Uther", "PALADIN", 2, 2, "TANK", 263, 90015, true, nil, 1820)
	add("Anduin", "PRIEST", 5, 2, "HEALER", 258, 90010, false, "friend", 2310)
	add("Jaina", "MAGE", 8, 3, "DAMAGER", 254, 90010, false, "guild", 940)
	add("Tirion", "PALADIN", 2, 3, "DAMAGER", 249, 90006, false, nil, 0)

	previewGroup = group
	return group
end

local function helpLine(tag, description)
	return C.StringByTemplate(tag, "blue-400") .. " = " .. description
end

local sizeHint = L["Icon size: {{tag:16}} or {{tag:height,width}}."]

---@param kind "player"|"group"
---@return string help
function LFGPI:GetTagHelp(kind)
	local lines = { F.GetWindStyleText(L["Template Elements"]) }
	local function add(tag, description)
		lines[#lines + 1] = helpLine(tag, description)
	end

	if kind == "player" then
		add("{{name}}", L["Character name"])
		add("{{ilvl}}", L["Item level"])
		add("{{className}}", L["Class name"])
		add("{{specName}}", L["Specialization name"])
		add("{{roleName}}", L["Role name"])
		add("{{categoryName}}", L["Sirus category name"])
		add("{{leader}}", L["The word \"Leader\" for the group leader"])
		add("{{relation}}", L["Friend, guild member or ignored player mark"])
		add("{{keyRating}}", L["Mythic+ rating, requested from the server for each player when the tooltip opens"])
		add("{{amount}}", L["Number of players (composition template only)"])
		add("{{classIcon}} {{specIcon}} {{roleIcon}} {{categoryIcon}} {{leaderIcon}}", L["Icons"])
		lines[#lines + 1] = sizeHint
		lines[#lines + 1] = ""
		lines[#lines + 1] = F.GetWindStyleText(L["Blocks"])
		add("{{classColorStart}}...{{classColorEnd}}", L["Class color"])
		add("{{ilvlColorStart}}...{{ilvlColorEnd}}", L["Item level color"])
		add("{{roleColorStart}}...{{roleColorEnd}}", L["Role color"])
		add("{{keyColorStart}}...{{keyColorEnd}}", L["Mythic+ rating color"])
	else
		add("{{groupName}}", L["Group name"])
		add("{{activity}}", L["Full activity name"])
		add("{{activityShort}}", L["Short activity name"])
		add("{{difficulty}}", L["Difficulty"])
		add("{{leaderName}}", L["Leader name in class color"])
		add("{{leaderScore}}", L["Leader's Mythic+ rating"])
		add("{{members}} {{max}} {{free}}", L["Members, group size, free slots"])
		add("{{tanks}} {{healers}} {{dps}}", L["Number of players by role"])
		add("{{avgIlvl}} {{minIlvl}} {{maxIlvl}}", L["Average, lowest and highest item level"])
		add("{{reqIlvl}} {{myIlvl}}", L["Required item level and yours"])
		add("{{age}}", L["Time since the group was listed"])
		add("{{bosses}}", L["Number of defeated bosses"])
		add("{{friends}}", L["Number of friends and guild members"])
		add("{{ignored}}", L["Names of ignored players in the group"])
		add("{{saved}}", L["The word \"Saved\" when you are saved to this instance"])
		add("{{voice}}", L["Voice chat"])
		add("{{categoryName}}", L["Required Sirus category"])
		add("{{classes}} {{missing}}", L["Icons of present and missing classes"])
		add("{{tankIcon}} {{healerIcon}} {{dpsIcon}} {{categoryIcon}} {{skull}}", L["Icons"])
		lines[#lines + 1] = sizeHint
		lines[#lines + 1] = ""
		lines[#lines + 1] = F.GetWindStyleText(L["Blocks"])
		add("{{ilvlColorStart}}...{{ilvlColorEnd}}", L["Color of the average item level"])
		add("{{leaderScoreColorStart}}...{{leaderScoreColorEnd}}", L["Leader's Mythic+ rating color"])
		add("{{classColorStart}}...{{classColorEnd}}", L["Leader class color"])
		add("{{reqColorStart}}...{{reqColorEnd}}", L["Green if you meet the item level requirement, red otherwise"])
	end

	add("{{redStart}}...{{redEnd}}", L["Fixed color: red, green, yellow, orange, blue, gray, white"])
	add(
		"{{tagStart}}...{{tagEnd}}",
		L["Shows the content only when the tag has a value, for example {{bossesStart}}bosses: {{bosses}}{{bossesEnd}}"]
	)

	return tconcat(lines, "\n")
end
