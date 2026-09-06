---@diagnostic disable: need-check-nil, cast-local-type
local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local CT = W:NewModule("ChatText", "AceEvent-3.0", "AceHook-3.0") ---@class ChatTextModule : AceModule, AceEvent-3.0, AceHook-3.0
local CH = E:GetModule("Chat")
local C = W.Utilities.Color

local _G = _G
local format = format
local gsub = gsub
local ipairs = ipairs
local next = next
local pairs = pairs
local select = select
local strjoin = strjoin
local strlen = strlen
local strmatch = strmatch
local strsplit = strsplit
local strsub = strsub
local strtrim = strtrim
local strupper = strupper
local time = time
local tinsert = tinsert
local type = type
local unpack = unpack
local utf8sub = string.utf8sub
local wipe = wipe

local Ambiguate = Ambiguate
local BNGetNumFriends = BNGetNumFriends
local GetAchievementLink = GetAchievementLink
local GetBNPlayerLink = GetBNPlayerLink
local GetChannelName = GetChannelName
local GetClientTexture = BNet_GetClientEmbeddedTexture
local GetTitleIconTexture = C_Texture.GetTitleIconTexture


local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_Club_GetClubInfo = C_Club.GetClubInfo

local Constants_ChatFrameConstants_MaxChatWindows = Constants.ChatFrameConstants.MaxChatWindows
local TitleIconVersion_Small = Enum.TitleIconVersion.Small
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE

CT.cache = { RoleIcons = CH.RoleIcons }
local initRecord = {}

local factionTextures = {
	["Neutral"] = [[Interface\Addons\ElvUI_WindTools\Media\FriendList\GameIcons\Classic]],
	["Alliance"] = [[Interface\Addons\ElvUI_WindTools\Media\FriendList\GameIcons\Alliance]],
	["Horde"] = [[Interface\Addons\ElvUI_WindTools\Media\FriendList\GameIcons\Horde]],
}

local offlineMessageTemplate = "%s" .. _G.ERR_FRIEND_OFFLINE_S
local offlineMessagePattern = gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "(.+)")
offlineMessagePattern = format("^%s$", offlineMessagePattern)

local onlineMessageTemplate = gsub(_G.ERR_FRIEND_ONLINE_SS, "%[%%s%]", "%%s%%s")
local onlineMessagePattern = gsub(_G.ERR_FRIEND_ONLINE_SS, "|Hplayer:%%s|h%[%%s%]|h", "|Hplayer:(.+)|h%%[(.+)%%]|h")
onlineMessagePattern = format("^%s$", onlineMessagePattern)

local achievementMessageTemplate = L["%player% has earned the achievement %achievement%!"]
local achievementMessageTemplateMultiplePlayers = L["%players% have earned the achievement %achievement%!"]

local bnetFriendOnlineMessageTemplate = L["%players% (%bnet%) has come online."]
local bnetFriendOfflineMessageTemplate = L["%players% (%bnet%) has gone offline."]

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
	INSTANCE_CHAT = L["I"],
	INSTANCE_CHAT_LEADER = L["IL"],
	PET_BATTLE_COMBAT_LOG = _G.PET_BATTLE_COMBAT_LOG,
}

local abbrStrings = {
	GUILD = L["[ABBR] Guild"],
	PARTY = L["[ABBR] Party"],
	RAID = L["[ABBR] Raid"],
	OFFICER = L["[ABBR] Officer"],
	PARTY_LEADER = L["[ABBR] Party Leader"],
	RAID_LEADER = L["[ABBR] Raid Leader"],
	RAID_WARNING = L["[ABBR] Raid Warning"],
	INSTANCE_CHAT = L["[ABBR] Instance"],
	INSTANCE_CHAT_LEADER = L["[ABBR] Instance Leader"],
	PET_BATTLE_COMBAT_LOG = _G.PET_BATTLE_COMBAT_LOG,
}


local roleIcons

CT.cache.elvuiRoleIconsPath = {
	Tank = E.Media.Textures.Tank,
	Healer = E.Media.Textures.Healer,
	DPS = E.Media.Textures.DPS,
}

-- [SIRUS] Inline role globals are absent; use the native LFGFrame texture regions.
CT.cache.blizzardRoleIcons = {
	Tank = _G.INLINE_TANK_ICON or "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:0:19:22:41|t",
	Healer = _G.INLINE_HEALER_ICON or "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:1:20|t",
	DPS = _G.INLINE_DAMAGER_ICON or "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:0:64:64:20:39:22:41|t",
}

local windIcon = F.GetIconString(W.Media.Textures.smallLogo, 14)
local authorIcons = {
	-- zhCN Server
	["Player-2133-0EA906AC"] = windIcon, -- Tabideath-影之哀伤
	["Player-2133-0EA9374F"] = windIcon, -- Tabimonk-影之哀伤
	["Player-2133-0EDB2623"] = windIcon, -- Tabidruid-影之哀伤
	["Player-858-0390AAA9"] = windIcon, -- Tabiwarrior-寒冰皇冠
	["Player-858-03954572"] = windIcon, -- Tabihunter-寒冰皇冠
	["Player-858-05BB0270"] = windIcon, -- Tabipaladin-寒冰皇冠
	["Player-858-05BB1B12"] = windIcon, -- Tabimonk-寒冰皇冠
	["Player-877-063EB5E7"] = windIcon, -- Tabimonk-回音山
	["Player-877-063FCBC6"] = windIcon, -- Tabideath-回音山
	["Player-877-063FCBF2"] = windIcon, -- Tabishaman-回音山
	["Player-877-064192F7"] = windIcon, -- Tabidemon-回音山
	["Player-877-0641A41C"] = windIcon, -- Tabilock-回音山
	["Player-877-0641A424"] = windIcon, -- Tabihunter-回音山
	["Player-877-0641A42C"] = windIcon, -- Tabiwarrior-回音山
	["Player-877-0641A431"] = windIcon, -- Tabimage-回音山
	["Player-877-0641A435"] = windIcon, -- Tabidruid-回音山
	["Player-877-0641A43A"] = windIcon, -- Tabipriest-回音山
	["Player-877-0641A43C"] = windIcon, -- Tabirogue-回音山
	["Player-877-0641A443"] = windIcon, -- Tabipaladin-回音山
	-- zhTW Server
	["Player-963-04504559"] = windIcon, -- Tabidruid-暗影之月
	["Player-963-0450457B"] = windIcon, -- Tabilock-暗影之月
	["Player-963-0450459F"] = windIcon, -- Tabishaman-暗影之月
	["Player-963-045045AA"] = windIcon, -- Tabipaladin-暗影之月
	["Player-963-04507626"] = windIcon, -- Tabiwarrior-暗影之月
	["Player-963-046DDD41"] = windIcon, -- Tabidh-暗影之月
	["Player-963-04C27464"] = windIcon, -- Tabimonk-暗影之月
	["Player-963-04CBB42D"] = windIcon, -- Tabikaeru-暗影之月
	["Player-963-04CBB440"] = windIcon, -- Tabihunter-暗影之月
	["Player-963-04DD3C38"] = windIcon, -- Tabideath-暗影之月
	["Player-963-06DB939B"] = windIcon, -- Tabievoker-暗影之月
	["Player-980-06DCA63A"] = windIcon, -- Tabievoker-水晶之刺
	["Player-980-07E14771"] = windIcon, -- Tabidruid-水晶之刺
	["Player-980-07E1E1DC"] = windIcon, -- Tabipaladin-水晶之刺
	["Player-980-07E1E1F0"] = windIcon, -- Tabimonk-水晶之刺
}

CH:AddPluginIcons(function(sender)
	if authorIcons[sender] then
		return authorIcons[sender]
	end
end)

local function AddSpaceForAsianText(text, revert)
	if W.Locale == "zhCN" or W.Locale == "zhTW" or W.Locale == "koKR" then
		return revert and " " .. text or text .. " "
	end
	return text
end

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

		_G.INLINE_TANK_ICON = CT.cache.blizzardRoleIcons.Tank
		_G.INLINE_HEALER_ICON = CT.cache.blizzardRoleIcons.Healer
		_G.INLINE_DAMAGER_ICON = CT.cache.blizzardRoleIcons.DPS
	elseif pack == "BLIZZARD" then
		roleIcons = {
			TANK = gsub(CT.cache.blizzardRoleIcons.Tank, ":16:16", sizeString),
			HEALER = gsub(CT.cache.blizzardRoleIcons.Healer, ":16:16", sizeString),
			DAMAGER = gsub(CT.cache.blizzardRoleIcons.DPS, ":16:16", sizeString),
		}

		_G.INLINE_TANK_ICON = CT.cache.blizzardRoleIcons.Tank
		_G.INLINE_HEALER_ICON = CT.cache.blizzardRoleIcons.Healer
		_G.INLINE_DAMAGER_ICON = CT.cache.blizzardRoleIcons.DPS
	else
		roleIcons = {
			TANK = E:TextureString(W.Media.RoleIcons[pack].TANK, sizeString),
			HEALER = E:TextureString(W.Media.RoleIcons[pack].HEALER, sizeString),
			DAMAGER = E:TextureString(W.Media.RoleIcons[pack].DAMAGER, sizeString),
		}

		_G.INLINE_TANK_ICON = roleIcons.TANK
		_G.INLINE_HEALER_ICON = roleIcons.HEALER
		_G.INLINE_DAMAGER_ICON = roleIcons.DAMAGER
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
			local communityID = strmatch(name, "Community:(%d+):")
			if communityID then
				local communityInfo = C_Club_GetClubInfo(communityID)

				if communityInfo.clubType == 0 then
					if communityInfo.name and CT.db and CT.db.customAbbreviation then
						abbr = CT.db.customAbbreviation[communityInfo.name]
					end
					abbr = abbr or strupper(utf8sub(communityInfo.name, 1, 2))
					abbr = E:TextGradient(abbr, 0.000, 0.592, 0.902, 0.000, 0.659, 1.000)
				elseif communityInfo.clubType == 1 then
					if CT.db and CT.db.customAbbreviation then
						abbr = CT.db.customAbbreviation[communityInfo.name]
					end
					abbr = abbr or communityInfo.shortName or strupper(utf8sub(communityInfo.name, 1, 2))
					abbr = C.StringWithRGB(abbr, 0.902, 0.494, 0.133)
				end
			else
				if CT.db and CT.db.customAbbreviation then
					abbr = CT.db.customAbbreviation[name]
				end
				abbr = abbr or utf8sub(name, 1, 1)
			end
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
	if CT.db and CT.db.abbreviation == "SHORT" and W.ChineseLocale then
		-- Use full-width colon in Chinese client
		msg = gsub(msg, utf8sub(_G.CHAT_WHISPER_GET, 3), L["[ABBR] Whisper"] .. "：")
		msg = gsub(msg, utf8sub(_G.CHAT_WHISPER_INFORM_GET, 1, 3), L["[ABBR] Whisper"])
		msg = gsub(msg, utf8sub(_G.CHAT_SAY_GET, 3), L["[ABBR] Say"] .. "：")
		msg = gsub(msg, utf8sub(_G.CHAT_YELL_GET, 3), L["[ABBR] Yell"] .. "：")
		msg = gsub(msg, "： ", "：")
	end

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
	if E:IsSecretValue(nameString) or not nameString or nameString == "" then
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

-- [SIRUS] Keep ElvUI's native filters, channel routing and history arguments intact.
function CT:MessageFormatter(frame, info, chatType, chatGroup, chatTarget, channelLength, coloredName, historySavedName, ...)
	local body = CT.cache.MessageFormatter(CH, frame, info, chatType, chatGroup, chatTarget, channelLength, CT:HandleName(coloredName), historySavedName, ...)
	local sender = select(2, ...)
	if not body or not sender or sender == "" or not CT.db.removeBrackets or strsub(chatType, 1, 9) == "RAID_BOSS" or strsub(chatType, 1, 7) == "MONSTER" then
		return body
	end

	-- Only the sender label changes; the hyperlink and message contents stay intact.
	body = gsub(body, "(|Hplayer:[^|]+|h)(.-)(|h)", function(link, label, close)
		if strmatch(link, "^|Hplayer:([^:|]+)") ~= sender then return link .. label .. close end
		if strsub(label, 1, 1) == "[" and strsub(label, -1) == "]" then
			label = strsub(label, 2, -2)
		end
		return link .. label .. close
	end, 1)
	return body
end

function CT:EditBoxHeader_SetText(header, text, skip)
	if not self.db.enable or not self.db.trimEditBoxHeader or not text or skip then
		return
	end

	local after = strtrim(text)
	if text ~= after then
		header:SetText(after, true)
	end
end

function CT:EditBoxHeader_SetFormattedText(header, fmt, ...)
	if not self.db.enable or not self.db.trimEditBoxHeader or not fmt then
		return
	end

	local args = { ... }
	local last = args[#args]

	if type(last) == "boolean" and last == true then
		return
	end

	local after = strtrim(fmt)
	if fmt ~= after then
		args[#args + 1] = true
		header:SetFormattedText(after, unpack(args))
	end
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

	-- Override only presentation; ElvUI owns event filtering and chat history.
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
	if self.db.enable and self.db.trimEditBoxHeader and W.Locale == "zhCN" then
		for i = 1, Constants_ChatFrameConstants_MaxChatWindows do
			local editBox = _G["ChatFrame" .. i .. "EditBox"]
			if editBox and editBox.header then
				local header = editBox.header
				if not self:IsHooked(header, "SetText") then
					self:SecureHook(header, "SetText", "EditBoxHeader_SetText")
					self:SecureHook(header, "SetFormattedText", "EditBoxHeader_SetFormattedText")
					self:EditBoxHeader_SetText(header, header:GetText())
				end
			end
		end
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
						message = gsub(
							achievementMessageTemplate,
							"%%player%%",
							AddSpaceForAsianText(self:MayHaveBrackets(players[1]))
						)
					elseif #players > 1 then
						message = gsub(
							achievementMessageTemplateMultiplePlayers,
							"%%players%%",
							AddSpaceForAsianText(strjoin(", ", self:MayHaveBrackets(unpack(players))))
						)
					end

					if message then
						message = gsub(
							message,
							"%%achievement%%",
							AddSpaceForAsianText(strjoin(", ", unpack(achievementLinks)), true)
						)

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
	if not frame or E:IsSecretValue(msg) or not msg then
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

		coloredName = AddSpaceForAsianText(self:MayHaveBrackets(coloredName))
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

local battleNetFriendsCharacters = {}
local battleNetFriendStatusUpdateTime = {}

local function getElementNumberOfTable(t)
	if not t then
		return 0
	end

	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local function UpdateBattleNetFriendStatus(friendIndex)
	local friendInfo = friendIndex and C_BattleNet_GetFriendAccountInfo(friendIndex)
	if not friendInfo then
		return
	end

	local savedCharacters = battleNetFriendsCharacters[friendInfo.bnetAccountID]
	local numberOfSavedCharacters = getElementNumberOfTable(savedCharacters)
	local characters = {}
	local numberOfCharacters = 0

	if battleNetFriendStatusUpdateTime[friendInfo.bnetAccountID] then
		local timeSinceLastUpdate = time() - battleNetFriendStatusUpdateTime[friendInfo.bnetAccountID]
		if timeSinceLastUpdate < 2 then
			return
		end
	end

	local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(friendIndex)
	if numGameAccounts and numGameAccounts > 0 then
		for accountIndex = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(friendIndex, accountIndex)
			if gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE and gameAccountInfo.characterName then
				numberOfCharacters = numberOfCharacters + 1
				characters[gameAccountInfo.characterName] = {
					faction = gameAccountInfo.factionName,
					realm = gameAccountInfo.realmName,
					class = E:UnlocalizedClassName(gameAccountInfo.className),
				}
			end
		end
	end

	local changed, changedCharacters

	if numberOfSavedCharacters == 0 then
		if numberOfCharacters > 0 then
			changed = true
			changedCharacters = {}

			for character, data in pairs(characters) do
				changedCharacters[character] = {
					type = "online",
					data = data,
				}
			end
		end
	else
		if numberOfCharacters ~= numberOfSavedCharacters then
			changed = true
			changedCharacters = {}

			for character, data in pairs(characters) do
				changedCharacters[character] = {
					type = "online",
					data = data,
				}
			end

			for character, data in pairs(savedCharacters) do
				if not changedCharacters[character] then
					changedCharacters[character] = {
						type = "offline",
						data = data,
					}
				else
					changedCharacters[character] = nil
				end
			end
		end
	end

	battleNetFriendsCharacters[friendInfo.bnetAccountID] = characters
	battleNetFriendStatusUpdateTime[friendInfo.bnetAccountID] = time()
	return changed, friendInfo.accountName, friendInfo.bnetAccountID, changedCharacters
end

-- [SIRUS] Guild roster data is native; communities are not the guild API here.
function CT:GUILD_ROSTER_UPDATE()
	wipe(guildPlayerCache)
	for index = 1, GetNumGuildMembers() do
		local name, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(index)
		if name and class then
			guildPlayerCache[Ambiguate(name, "none")] = class
		end
	end
end
function CT:BN_FRIEND_INFO_CHANGED(_, friendIndex, appTexture, noRetry)
	if not appTexture and not noRetry then
		GetTitleIconTexture("App", TitleIconVersion_Small, function(success, texture)
			if success then
				self:BN_FRIEND_INFO_CHANGED(_, friendIndex, texture, true)
			end
		end)

		return
	end

	if not self.bnetFriendDataCached or not (self.db.bnetFriendOnline or self.db.bnetFriendOffline) then
		return
	end

	local changed, accountName, accountID, characters = UpdateBattleNetFriendStatus(friendIndex)
	if not changed then
		return
	end

	local appTextureString = appTexture and GetClientTexture(appTexture, 16, 16, 12) .. " " or ""
	local displayAccountName = appTextureString .. format("|cff82c5ff%s|r", accountName)
	local bnetLink = GetBNPlayerLink(accountName, displayAccountName, accountID, 0, 0, 0)

	local onlineCharacters = {}
	local offlineCharacters = {}

	---@diagnostic disable-next-line: param-type-mismatch
	for character, characterData in pairs(characters) do
		local fullName = characterData.data.realm and format("%s-%s", character, characterData.data.realm) or character

		-- to avoid duplicate message
		if not guildPlayerCache[Ambiguate(fullName, "none")] then
			local classIcon = self.db.classIcon
				and F.GetClassIconStringWithStyle(characterData.data.class, CT.db.classIconStyle, 16, 16)
			classIcon = classIcon and classIcon .. " " or ""
			local coloredName = C.StringWithClassColor(character, characterData.data.class)

			local playerName = coloredName
				and format("|Hplayer:%s|h%s%s|h", fullName, classIcon, self:MayHaveBrackets(coloredName))

			if self.db.factionIcon then
				local factionIcon =
					F.GetIconString(factionTextures[characterData.data.faction] or factionTextures["Neutral"], 18)
				playerName = playerName and factionIcon and format("%s %s", factionIcon, playerName) or playerName
			end

			if playerName then
				tinsert(
					characterData.type == "online" and onlineCharacters or offlineCharacters,
					AddSpaceForAsianText(playerName)
				)
			end
		end
	end

	local function sendMessage(template, players, ...)
		local message = gsub(template, "%%players%%", players)
		message = gsub(message, "%%bnet%%", bnetLink)

		for i = 1, Constants_ChatFrameConstants_MaxChatWindows do
			local chatFrame = _G["ChatFrame" .. i]
			if chatFrame and chatFrame:IsEventRegistered("CHAT_MSG_BN_INLINE_TOAST_ALERT") then
				chatFrame:AddMessage(message, ...)
			end
		end
	end

	if #onlineCharacters > 0 and self.db.bnetFriendOnline then
		sendMessage(
			bnetFriendOnlineMessageTemplate,
			strjoin(", ", unpack(onlineCharacters)),
			C.ExtractRGBFromTemplate("green-400")
		)
	end

	if #offlineCharacters > 0 and self.db.bnetFriendOffline then
		sendMessage(
			bnetFriendOfflineMessageTemplate,
			strjoin(", ", unpack(offlineCharacters)),
			C.ExtractRGBFromTemplate("rose-500")
		)
	end
end

function CT:PLAYER_ENTERING_WORLD(event)
	if C_BattleNet_GetFriendAccountInfo and C_BattleNet_GetFriendNumGameAccounts and C_BattleNet_GetFriendGameAccountInfo then
		for friendIndex = 1, BNGetNumFriends() do
			UpdateBattleNetFriendStatus(friendIndex)
		end
	end
	self:GUILD_ROSTER_UPDATE()
	self.bnetFriendDataCached = true
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
	if C_BattleNet_GetFriendAccountInfo and C_BattleNet_GetFriendNumGameAccounts and C_BattleNet_GetFriendGameAccountInfo and GetTitleIconTexture then
		self:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	end
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
