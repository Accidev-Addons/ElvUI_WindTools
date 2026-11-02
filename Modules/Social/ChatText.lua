---@diagnostic disable: need-check-nil, cast-local-type
local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local CT = W:NewModule("ChatText", "AceEvent-3.0", "AceHook-3.0") ---@class ChatTextModule : AceModule, AceEvent-3.0, AceHook-3.0
local CH = E:GetModule("Chat")
local C = W.Utilities.Color

local _G = _G
local format = format
local gsub = gsub
local ipairs = ipairs
local pairs = pairs
local select = select
local strjoin = strjoin
local strlen = strlen
local strmatch = strmatch
local strsplit = strsplit
local strsub = strsub
local strupper = strupper
local tinsert = tinsert
local unpack = unpack
local utf8sub = string.utf8sub
local wipe = wipe

local GetAchievementLink = GetAchievementLink
local GetChannelName = GetChannelName

local function Ambiguate(name)
	return (strsplit("-", name))
end

CT.cache = { RoleIcons = CH.RoleIcons }
local initRecord = {}

local offlineMessageTemplate = "%s" .. _G.ERR_FRIEND_OFFLINE_S
local offlineMessagePattern = gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "(.+)")
offlineMessagePattern = format("^%s$", offlineMessagePattern)

local onlineMessageTemplate = gsub(_G.ERR_FRIEND_ONLINE_SS, "%[%%s%]", "%%s%%s")
local onlineMessagePattern = gsub(_G.ERR_FRIEND_ONLINE_SS, "|Hplayer:%%s|h%[%%s%]|h", "|Hplayer:(.+)|h%%[(.+)%%]|h")
onlineMessagePattern = format("^%s$", onlineMessagePattern)

local achievementMessageTemplate = L["%player% has earned the achievement %achievement%!"]
local achievementMessageTemplateMultiplePlayers = L["%players% have earned the achievement %achievement%!"]

local guildPlayerCache = {}
local achievementMessageCache = {
	byAchievement = {},
	byPlayer = {},
}

local elvuiAbbrStrings = {
	GUILD = L["G"],
	PARTY = L["P"],
	RAID = L["R"],
	OFFICER = L["O"],
	PARTY_LEADER = L["PL"],
	RAID_LEADER = L["RL"],
}

local abbrStrings = {
	GUILD = L["[ABBR] Guild"],
	PARTY = L["[ABBR] Party"],
	RAID = L["[ABBR] Raid"],
	OFFICER = L["[ABBR] Officer"],
	PARTY_LEADER = L["[ABBR] Party Leader"],
	RAID_LEADER = L["[ABBR] Raid Leader"],
	RAID_WARNING = L["[ABBR] Raid Warning"],
}

local roleIcons

CT.cache.elvuiRoleIconsPath = {
	Tank = E.Media.Textures.Tank,
	Healer = E.Media.Textures.Healer,
	DPS = E.Media.Textures.DPS,
}

CT.cache.blizzardRoleIcons = {
	Tank = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:0:19:22:41|t",
	Healer = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:1:20|t",
	DPS = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:22:41|t",
}

function CT:UpdateRoleIcons()
	if not self.db then
		return
	end

	local pack = self.db.enable and self.db.roleIconStyle or "DEFAULT"
	local sizeString = self.db.enable and format(":%d:%d", self.db.roleIconSize, self.db.roleIconSize) or ":16:16"

	if pack ~= "DEFAULT" and pack ~= "BLIZZARD" then
		sizeString = sizeString and (sizeString .. ":0:0:64:64:2:62:0:58")
	end

	if pack == "DEFAULT" then
		roleIcons = {
			TANK = E:TextureString(CT.cache.elvuiRoleIconsPath.Tank, sizeString .. ":0:0:64:64:2:56:2:56"),
			HEALER = E:TextureString(CT.cache.elvuiRoleIconsPath.Healer, sizeString .. ":0:0:64:64:2:56:2:56"),
			DAMAGER = E:TextureString(CT.cache.elvuiRoleIconsPath.DPS, sizeString),
		}
	elseif pack == "BLIZZARD" then
		roleIcons = {
			TANK = gsub(CT.cache.blizzardRoleIcons.Tank, ":16:16", sizeString),
			HEALER = gsub(CT.cache.blizzardRoleIcons.Healer, ":16:16", sizeString),
			DAMAGER = gsub(CT.cache.blizzardRoleIcons.DPS, ":16:16", sizeString),
		}
	else
		roleIcons = {
			TANK = E:TextureString(W.Media.RoleIcons[pack].TANK, sizeString),
			HEALER = E:TextureString(W.Media.RoleIcons[pack].HEALER, sizeString),
			DAMAGER = E:TextureString(W.Media.RoleIcons[pack].DAMAGER, sizeString),
		}
	end

	CH.RoleIcons = self.db.enable and roleIcons or CT.cache.RoleIcons
end

function CT.ShortChannel(channelLink)
	local noBracketsString
	local abbr

	if CT.db then
		if CT.db.removeBrackets then
			noBracketsString = "|Hchannel:%s|h%s|h"
		end

		if CT.db.abbreviation == "SHORT" then
			abbr = abbrStrings[strupper(channelLink)]
		elseif CT.db.abbreviation == "NONE" then
			return ""
		else
			abbr = elvuiAbbrStrings[strupper(channelLink)]
		end
	end

	if not abbr and CT.db.abbreviation == "SHORT" then
		local name = select(2, GetChannelName(gsub(channelLink, "channel:", "")))

		if name then
			if CT.db and CT.db.customAbbreviation then
				abbr = CT.db.customAbbreviation[name]
			end
			abbr = abbr or utf8sub(name, 1, 1)
		end
	end

	abbr = abbr or gsub(channelLink, "channel:", "")

	return format(noBracketsString or "|Hchannel:%s|h[%s]|h", channelLink, abbr)
end

function CT:HandleShortChannels(msg, hide)
	msg = gsub(msg, "|Hchannel:(.-)|h%[(.-)%]|h", hide and "" or CT.ShortChannel)
	msg = gsub(msg, "CHANNEL:", "")
	msg = gsub(msg, "^(.-|h) " .. L["whispers"], "%1")
	msg = gsub(msg, "^(.-|h) " .. L["says"], "%1")
	msg = gsub(msg, "^(.-|h) " .. L["yells"], "%1")
	msg = gsub(msg, "<" .. _G.AFK .. ">", format("[%s]", C.StringByTemplate(L["AFK"], "rose-500")))
	msg = gsub(msg, "<" .. _G.DND .. ">", format("[%s]", C.StringByTemplate(L["DND"], "yellow-400")))

	local raidWarningString = ""
	if CT.db and CT.db.removeBrackets then
		if CT.db.abbreviation == "SHORT" then
			raidWarningString = abbrStrings["RAID_WARNING"]
		end
	else
		if CT.db.abbreviation == "SHORT" then
			raidWarningString = "[" .. abbrStrings["RAID_WARNING"] .. "]"
		end
	end
	msg = gsub(msg, "^%[" .. _G.RAID_WARNING .. "%]", raidWarningString)
	return msg
end

function CT:CheckLFGRoles()
	CH:CheckLFGRoles()
end

function CT:HandleName(nameString)
	if not nameString or nameString == "" then
		return nameString
	end

	if not self.db or not self.db.enable or not self.db.removeRealm then
		return nameString
	end

	if strsub(nameString, strlen(nameString) - 1) == "|r" then -- color
		nameString = F.Strings.Split(nameString, "-")
		nameString = nameString .. "|r"
	else
		nameString = F.Strings.Split(nameString, "-")
	end

	return nameString
end

function CT:MayHaveBrackets(...)
	local names = { ... }
	for i = 1, select("#", ...) do
		names[i] = not CT.db.removeBrackets and "[" .. names[i] .. "]" or names[i]
	end
	return unpack(names)
end

function CT:MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, ...)
	local body = CT.cache.MessageFormatter(CH, frame, info, chatType, chatGroup, chatTarget, channelLength, CT:HandleName(coloredName), historySavedName, ...)
	local sender = select(2, ...)
	if not body or not sender or sender == "" or not CT.db.removeBrackets or strsub(chatType, 1, 9) == "RAID_BOSS" or strsub(chatType, 1, 7) == "MONSTER" then
		return body
	end

	body = gsub(body, "(|Hplayer:[^|]+|h)(.-)(|h)", function(link, label, close)
		if strmatch(link, "^|Hplayer:([^:|]+)") ~= sender then return link .. label .. close end
		if strsub(label, 1, 1) == "[" and strsub(label, -1) == "]" then
			label = strsub(label, 2, -2)
		end
		return link .. label .. close
	end, 1)
	return body
end

function CT:ToggleReplacement()
	if not self.db then
		return
	end

	-- HandleShortChannels
	if self.db.enable and (self.db.abbreviation ~= "DEFAULT" or self.db.removeBrackets) then
		if not initRecord.HandleShortChannels then
			CT.cache.HandleShortChannels = CH.HandleShortChannels -- backup
			CH.HandleShortChannels = CT.HandleShortChannels -- replace
			initRecord.HandleShortChannels = true
		end
	else
		if initRecord.HandleShortChannels then
			if CT.cache.HandleShortChannels then
				CH.HandleShortChannels = CT.cache.HandleShortChannels -- restore
			end
			initRecord.HandleShortChannels = false
		end
	end

	if self.db.enable then
		if not initRecord.MessageFormatter then
			CT.cache.MessageFormatter = CH.MessageFormatter
			CH.MessageFormatter = CT.MessageFormatter
			initRecord.MessageFormatter = true
		end
	elseif initRecord.MessageFormatter then
		CH.MessageFormatter = CT.cache.MessageFormatter
		initRecord.MessageFormatter = false
	end
end

function CT:SendAchievementMessage()
	if not self.db or not self.db.enable or not self.db.mergeAchievement then
		return
	end

	local channelData = {
		{ event = "CHAT_MSG_GUILD_ACHIEVEMENT", color = _G.ChatTypeInfo.GUILD },
		{ event = "CHAT_MSG_ACHIEVEMENT", color = _G.ChatTypeInfo.SYSTEM },
	}

	for _, data in ipairs(channelData) do
		local event, color = data.event, data.color
		for frame, cache in pairs(achievementMessageCache.byPlayer) do
			if cache and cache[event] then
				for playerString, achievementTable in pairs(cache[event]) do
					local players = { strsplit("=", playerString) }

					local achievementLinks = {}
					for achievementID in pairs(achievementTable) do
						tinsert(achievementLinks, GetAchievementLink(achievementID))
					end

					local message = nil

					if #players == 1 then
						message = gsub(achievementMessageTemplate, "%%player%%", self:MayHaveBrackets(players[1]))
					elseif #players > 1 then
						message = gsub(
							achievementMessageTemplateMultiplePlayers,
							"%%players%%",
							strjoin(", ", self:MayHaveBrackets(unpack(players)))
						)
					end

					if message then
						message = gsub(message, "%%achievement%%", strjoin(", ", unpack(achievementLinks)))

						message = select(2, W:GetModule("ChatLink"):Filter("", message))
						frame:AddMessage(message, color.r, color.g, color.b)
					end
				end
			end
			wipe(cache)
		end
	end
end

function CT:ElvUIChat_AchievementMessageHandler(event, frame, achievementMessage, playerGUID)
	if not frame or not event or not achievementMessage or not playerGUID then
		return
	end

	if not self.db or not self.db.enable or not self.db.mergeAchievement then
		return
	end

	if not achievementMessageCache.byAchievement[frame] then
		achievementMessageCache.byAchievement[frame] = {}
	end

	if not achievementMessageCache.byAchievement[frame][event] then
		achievementMessageCache.byAchievement[frame][event] = {}
	end

	if not achievementMessageCache.byPlayer[frame] then
		achievementMessageCache.byPlayer[frame] = {}
	end

	if not achievementMessageCache.byPlayer[frame][event] then
		achievementMessageCache.byPlayer[frame][event] = {}
	end

	local cache = achievementMessageCache.byAchievement[frame][event]
	local cacheByPlayer = achievementMessageCache.byPlayer[frame][event]

	local achievementID = strmatch(achievementMessage, "|Hachievement:(%d+):")
	if not achievementID then
		return
	end

	if not cache[achievementID] then
		cache[achievementID] = {}
		E:Delay(0.1, function()
			local players = {}
			for k in pairs(cache[achievementID]) do
				tinsert(players, k)
			end

			if #players >= 1 then
				local playerString = strjoin("=", unpack(players))

				if not cacheByPlayer[playerString] then
					cacheByPlayer[playerString] = {}
				end

				cacheByPlayer[playerString][achievementID] = true

				if not self.waitForAchievementMessage then
					self.waitForAchievementMessage = true
					E:Delay(0.2, function()
						self:SendAchievementMessage()
						self.waitForAchievementMessage = false
					end)
				end
			end

			cache[achievementID] = nil
		end)
	end

	local playerInfo = CH:GetPlayerInfoByGUID(playerGUID)
	if not playerInfo or not playerInfo.englishClass or not playerInfo.name or not playerInfo.nameWithRealm then
		return
	end

	local displayName = self.db.removeRealm and playerInfo.name or playerInfo.nameWithRealm
	local coloredName = C.StringWithClassColor(displayName, playerInfo.englishClass)
	local classIcon = self.db.classIcon
		and F.GetClassIconStringWithStyle(playerInfo.englishClass, self.db.classIconStyle, 16, 16)

	if classIcon then
		coloredName = classIcon .. " " .. coloredName
	end

	if coloredName and cache[achievementID] then
		local playerName = format("|Hplayer:%s|h%s|h", playerInfo.nameWithRealm, coloredName)
		cache[achievementID][playerName] = true
		return true
	end
end

function CT:ElvUIChat_GuildMemberStatusMessageHandler(frame, msg)
	if not frame or not msg then
		return
	end

	if not CT.db or not CT.db.enable or not CT.db.guildMemberStatus then
		return
	end

	local name, class, link, resultText

	name = strmatch(msg, offlineMessagePattern)
	if not name then
		link, name = strmatch(msg, onlineMessagePattern)
	end

	class = name and guildPlayerCache[name]

	if class then
		local displayName = CT.db.removeRealm and Ambiguate(name, "short") or name
		local coloredName =
			C.StringWithClassColor(displayName, link and guildPlayerCache[link] or guildPlayerCache[name])

		coloredName = self:MayHaveBrackets(coloredName)
		local classIcon = self.db.classIcon and F.GetClassIconStringWithStyle(class, CT.db.classIconStyle, 16, 16)
		classIcon = classIcon and classIcon .. " " or ""

		if coloredName and classIcon then
			if link then
				resultText = format(onlineMessageTemplate, link, classIcon, coloredName)
				if CT.db.guildMemberStatusInviteLink then
					local windInviteLink = format(
						"|Hwtlink:invite:%s|h%s|h",
						link,
						C.StringByTemplate(format("[%s]", L["Invite"]), "sky-500")
					)
					resultText = resultText .. " " .. windInviteLink
				end
				frame:AddMessage(resultText, C.ExtractRGBFromTemplate("green-400"))
			else
				resultText = format(offlineMessageTemplate, classIcon, coloredName)
				frame:AddMessage(resultText, C.ExtractRGBFromTemplate("rose-500"))
			end

			return true
		end
	end
end

function CT:GUILD_ROSTER_UPDATE()
	wipe(guildPlayerCache)
	for index = 1, GetNumGuildMembers() do
		local name, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(index)
		if name and class then
			guildPlayerCache[Ambiguate(name, "none")] = class
		end
	end
end

function CT:PLAYER_ENTERING_WORLD(event)
	self:GUILD_ROSTER_UPDATE()
	self:UnregisterEvent(event)
end

local function NativeStatusFilter(frame, event, message, ...)
	if event == "CHAT_MSG_SYSTEM" then
		return CT:ElvUIChat_GuildMemberStatusMessageHandler(frame, message) or false
	end
	return CT:ElvUIChat_AchievementMessageHandler(event, frame, message, select(11, ...)) or false
end

function CT:Initialize()
	self.db = E.db.WT.social.chatText
	if not self.db or not self.db.enable or not E.private.chat.enable then
		return
	end

	self:UpdateRoleIcons()
	self:ToggleReplacement()
	self:CheckLFGRoles()

	if not self.messageFiltersRegistered then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", NativeStatusFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", NativeStatusFilter)
		self.messageFiltersRegistered = true
	end
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self.initialized = true
end

function CT:ProfileUpdate()
	self.db = E.db.WT.social.chatText
	if not self.db then
		return
	end
	if self.db.enable and not self.initialized then
		return self:Initialize()
	end

	self:UpdateRoleIcons()
	self:ToggleReplacement()
	self:CheckLFGRoles()
end

W:RegisterModule(CT:GetName())
