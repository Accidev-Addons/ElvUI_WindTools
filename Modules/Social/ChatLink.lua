local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local C = W.Utilities.Color
local CL = W:NewModule("ChatLink") ---@class ChatLink : AceModule

local _G = _G
local format = format
local gsub = gsub
local pairs = pairs
local select = select
local strmatch = strmatch
local tonumber = tonumber

local ChatFrameUtil_AddMessageEventFilter = ChatFrameUtil.AddMessageEventFilter
local GetAchievementInfo = GetAchievementInfo
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local GetTalentInfoByID = GetTalentInfoByID

local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_Item_GetItemInfo = C_Item.GetItemInfo
local function GetSpellIcon(spellID)
	return select(3, GetSpellInfo(spellID))
end

local RETRIEVING_ITEM_INFO = RETRIEVING_ITEM_INFO
local ITEM_LEVEL = ITEM_LEVEL
local ITEM_LEVEL_ALT = ITEM_LEVEL_ALT
local ITEM_MIN_LEVEL = ITEM_MIN_LEVEL

local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local MATCH_MIN_LEVEL = ITEM_MIN_LEVEL:gsub("%%d", "(%%d+)")
local MATCH_ITEM_LEVEL_ALT = ITEM_LEVEL_ALT and ITEM_LEVEL_ALT:gsub("%%d(%s?)%(%%d%)", "%%d+%1%%((%%d+)%%)")

local function ParseItemLevelFromTooltipLine(text)
	if not text or text == "" then
		return
	end
	local ilvl = (MATCH_ITEM_LEVEL_ALT and strmatch(text, MATCH_ITEM_LEVEL_ALT))
		or (not strmatch(text, MATCH_MIN_LEVEL) and strmatch(text, MATCH_ITEM_LEVEL))
	return ilvl and tonumber(ilvl)
end

--- Prefer the level displayed by the native item tooltip.
local function GetDisplayedItemLevelFromHyperlink(link)
	local info = E:ScanTooltip_HyperlinkInfo(link)
	if not info or not info.lines then
		return
	end
	local firstLine = info.lines[1]
	local firstText = firstLine and firstLine.leftText
	if firstText == RETRIEVING_ITEM_INFO then
		return
	end
	for i = 1, #info.lines do
		local line = info.lines[i]
		if line then
			local lv = ParseItemLevelFromTooltipLine(line.leftText)
			if lv then
				return lv
			end
			lv = ParseItemLevelFromTooltipLine(line.rightText)
			if lv then
				return lv
			end
		end
	end
end

local SearchArmorType = {
	INVTYPE_HEAD = true,
	INVTYPE_SHOULDER = true,
	INVTYPE_CHEST = true,
	INVTYPE_WRIST = true,
	INVTYPE_HAND = true,
	INVTYPE_WAIST = true,
	INVTYPE_LEGS = true,
	INVTYPE_FEET = true,
}

local abbrList = {
	INVTYPE_HEAD = L["[ABBR] Head"],
	INVTYPE_NECK = L["[ABBR] Neck"],
	INVTYPE_SHOULDER = L["[ABBR] Shoulders"],
	INVTYPE_CLOAK = L["[ABBR] Back"],
	INVTYPE_CHEST = L["[ABBR] Chest"],
	INVTYPE_WRIST = L["[ABBR] Wrist"],
	INVTYPE_HAND = L["[ABBR] Hands"],
	INVTYPE_WAIST = L["[ABBR] Waist"],
	INVTYPE_LEGS = L["[ABBR] Legs"],
	INVTYPE_FEET = L["[ABBR] Feet"],
	INVTYPE_HOLDABLE = L["[ABBR] Held In Off-hand"],
	INVTYPE_FINGER = L["[ABBR] Finger"],
	INVTYPE_TRINKET = L["[ABBR] Trinket"],
}

local tierColor = {
	["1"] = "|cffa5493b",
	["2"] = "|cffaaaeb2",
	["3"] = "|cffe4c55b",
	["4"] = "|cff09d3ff",
	["5"] = "|cffe8ac1b",
}

local function AddItemInfo(link)
	-- [SIRUS] GetItemInfo is the native tuple; cache misses must not suppress chat.
	local localizedName, _, _, nativeLevel, _, itemType, itemSubType, _, itemEquipLoc, icon = C_Item_GetItemInfo(link)
	if not localizedName then
		return link
	end

	if CL.db.translateItem then
		if localizedName then
			local professionIcon = strmatch(link, "|A:Professions.-|a")
			if professionIcon then
				localizedName = localizedName .. " " .. professionIcon
			end
			link = gsub(link, "|h%[(.+)%]|h", function()
				return "|h[" .. localizedName .. "]|h"
			end)
		end
	end

	if CL.db.numericalQualityTier then
		link = gsub(link, "|A:Professions%-ChatIcon%-Quality%-Tier(%d):(%d+):(%d+)::1|a", function(tier, width, height)
			if tierColor[tier] then
				return tierColor[tier] .. tier .. "|r"
			end
			return format("|A:Professions-ChatIcon-Quality-Tier%s:%s:%s::1|a", tier, width, height)
		end)
	end

	local level, slot

	-- item level: tooltip display value, fallback if hyperlink data not ready
	if CL.db.level then
		level = GetDisplayedItemLevelFromHyperlink(link) or nativeLevel
	end

	-- armor
	if itemType == _G.ARMOR and CL.db.armorCategory then
		if itemEquipLoc and itemEquipLoc ~= "" then
			if SearchArmorType[itemEquipLoc] then
				if E.global.general.locale == "zhTW" or E.global.general.locale == "zhCN" then
					slot = itemSubType .. (abbrList[itemEquipLoc] or _G[itemEquipLoc])
				else
					slot = itemSubType .. " " .. (abbrList[itemEquipLoc] or _G[itemEquipLoc])
				end
			else
				slot = abbrList[itemEquipLoc] or _G[itemEquipLoc]
			end
		end
	end

	-- weapon
	if itemType == _G.WEAPON and CL.db.weaponCategory then
		if itemEquipLoc and itemEquipLoc ~= "" then
			slot = itemSubType or abbrList[itemEquipLoc] or _G[itemEquipLoc]
		end
	end

	if level and slot then
		link = gsub(link, "|h%[(.-)%]|h", "|h[" .. level .. "-" .. slot .. ":%1]|h")
	elseif level then
		link = gsub(link, "|h%[(.-)%]|h", "|h[" .. level .. ":%1]|h")
	elseif slot then
		link = gsub(link, "|h%[(.-)%]|h", "|h[" .. slot .. ":%1]|h")
	end

	if CL.db.icon and icon then
		link = F.GetIconString(icon, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio) .. " " .. link
	end

	return link
end

local function AddKeystoneIcon(link)
	local itemID, mapID, level = strmatch(link, "Hkeystone:(%d-):(%d-):(%d-):")
	if not (itemID and mapID and level and itemID == "180653") then
		return
	end

	if CL.db.icon then
		local mapIDNum = tonumber(mapID)
		local texture = mapIDNum and select(6, C_ChallengeMode_GetMapUIInfo(mapIDNum))
		local icon = texture and F.GetIconString(texture, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio)
		if icon then
			link = icon .. " " .. link
		end
	end

	return link
end

local function AddSpellInfo(link)
	-- spell icon
	local id = strmatch(link, "Hspell:(%d-):")
	if not id then
		return
	end

	if CL.db.icon then
		local spellIDNum = tonumber(id)
		local texture = spellIDNum and GetSpellIcon(spellIDNum)
		local icon = texture and F.GetIconString(texture, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio)
		if icon then
			link = icon .. C.StringByTemplate(link, "sky-400")
		end
	end

	return link
end

local function AddEnchantInfo(link)
	-- enchant
	local id = strmatch(link, "Henchant:(%d-)\124")
	if not id then
		return
	end

	if CL.db.icon then
		local enchantIDNum = tonumber(id)
		local texture = enchantIDNum and GetSpellIcon(enchantIDNum)
		local icon = texture and F.GetIconString(texture, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio)
		if icon then
			link = icon .. " " .. link
		end
	end

	return link
end

local function AddPvPTalentInfo(link)
	-- PVP talent
	local id = strmatch(link, "Hpvptal:(%d-)|")
	if not id then
		return
	end

	if CL.db.icon then
		local pvpTalentIDNum = tonumber(id)
		local texture = pvpTalentIDNum and GetPvpTalentInfoByID and select(3, GetPvpTalentInfoByID(pvpTalentIDNum))
		local icon = texture and F.GetIconString(texture, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio)
		if icon then
			link = icon .. " " .. link
		end
	end

	return link
end

local function AddTalentInfo(link)
	-- talent
	local id = strmatch(link, "Htalent:(%d-)|")
	if not id then
		return
	end

	if CL.db.icon then
		local talentIDNum = tonumber(id)
		local texture = talentIDNum and GetTalentInfoByID and select(3, GetTalentInfoByID(talentIDNum))
		local icon = texture and F.GetIconString(texture, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio)
		if icon then
			link = icon .. " " .. link
		end
	end

	return link
end

local function AddAchievementInfo(link)
	-- achievement
	local id = strmatch(link, "Hachievement:(%d+)")
	if not id then
		return
	end

	if CL.db.icon then
		local achievementIDNum = tonumber(id)
		local texture = achievementIDNum and select(10, GetAchievementInfo(achievementIDNum))
		local icon = texture and F.GetIconString(texture, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio)
		if icon then
			link = icon .. " " .. link
		end
	end

	return link
end

local function AddCurrencyInfo(link)
	-- currency
	local id = strmatch(link, "Hcurrency:(%d+)")
	if not id then
		return
	end

	if CL.db.icon then
		local texture = select(3, C_CurrencyInfo_GetCurrencyInfo(tonumber(id)))
		local icon = texture and F.GetIconString(texture, CL.db.iconHeight, CL.db.iconWidth, CL.db.keepRatio)
		if icon then
			link = icon .. " " .. link
		end
	end

	return link
end

function CL:Filter(event, msg, ...)
	if CL.db.enable and E:NotSecretValue(msg) then
		msg = gsub(msg, "(|cffa335ee|Hkeystone:%d+:.-|h.-|h|r)", AddKeystoneIcon)
		msg = gsub(msg, "(|Hitem:%d+:.-|h.-|h)", AddItemInfo)
		msg = gsub(msg, "(|Hcurrency:%d+:.-|h.-|h)", AddCurrencyInfo)
		msg = gsub(msg, "(|Hspell:%d+:%d+|h.-|h)", AddSpellInfo)
		msg = gsub(msg, "(|Henchant:%d+|h.-|h)", AddEnchantInfo)
		msg = gsub(msg, "(|Htalent:%d+|h.-|h)", AddTalentInfo)
		msg = gsub(msg, "(|Hpvptal:%d+|h.-|h)", AddPvPTalentInfo)
		msg = gsub(msg, "(|Hachievement:%d+:.-|h.-|h)", AddAchievementInfo)
	end
	return false, msg, ...
end

function CL:Initialize()
	self.db = E.db.WT.social.chatLink

	local events = {
		"CHAT_MSG_ACHIEVEMENT",
		"CHAT_MSG_BATTLEGROUND",
		"CHAT_MSG_BN_WHISPER",
		"CHAT_MSG_CHANNEL",
		"CHAT_MSG_COMMUNITIES_CHANNEL",
		"CHAT_MSG_EMOTE",
		"CHAT_MSG_GUILD",
		"CHAT_MSG_INSTANCE_CHAT",
		"CHAT_MSG_INSTANCE_CHAT_LEADER",
		"CHAT_MSG_LOOT",
		"CHAT_MSG_OFFICER",
		"CHAT_MSG_PARTY",
		"CHAT_MSG_PARTY_LEADER",
		"CHAT_MSG_RAID",
		"CHAT_MSG_RAID_LEADER",
		"CHAT_MSG_SAY",
		"CHAT_MSG_TRADESKILLS",
		"CHAT_MSG_WHISPER",
		"CHAT_MSG_WHISPER_INFORM",
		"CHAT_MSG_YELL",
	}

	for _, event in pairs(events) do
		ChatFrameUtil_AddMessageEventFilter(event, self.Filter)
	end

	self.initialized = true
end

function CL:ProfileUpdate()
	self.db = E.db.WT.social.chatLink

	if self.db.enable and not self.initialized then
		self:Initialize()
	end
end

W:RegisterModule(CL:GetName())
