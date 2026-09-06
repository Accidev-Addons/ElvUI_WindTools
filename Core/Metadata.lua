local W ---@class WindTools
local F, E, L ---@type Functions, ElvUI, LocaleTable
W, F, E, L = unpack((select(2, ...)))

local tinsert = tinsert
local tostring = tostring

local GetCurrentRegionName = GetCurrentRegionName
local GetLocale = GetLocale
local GetMaxLevelForPlayerExpansion = GetMaxLevelForPlayerExpansion
local GetRealmID = GetRealmID
local GetRealmName = GetRealmName
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local C_CVar_GetCVarBool = C_CVar.GetCVarBool

E.myClassColor = E.myClassColor or E:ClassColor(E.myclass, true)

-- WindTools
W.Title = L["WindTools"]
W.PlainTitle = gsub(W.Title, "|c........([^|]+)|r", "%1")

-- Environment
W.Locale = GetLocale()
W.ChineseLocale = strsub(W.Locale, 0, 2) == "zh"
W.AsianLocale = W.ChineseLocale or W.Locale == "koKR"
W.SupportElvUIVersion = 9.07
W.UseKeyDown = C_CVar_GetCVarBool("ActionButtonUseKeyDown")

-- Game
W.MaxLevelForPlayerExpansion = GetMaxLevelForPlayerExpansion()

-- [SIRUS] Dungeon IDs and upgrade timers come from the server.
W.MythicPlusMapData = {}
W.MythicPlusSeasonAchievementData = {}
W.RaidData = {}

function W:GetMythicPlusMapData()
	for _, id in ipairs(C_ChallengeMode.GetMapTable()) do
		local name, _, timeLimit, secondTimer, thirdTimer, texture = C_ChallengeMode_GetMapUIInfo(id)
		if name then
			local data = W.MythicPlusMapData[id] or {}
			data.name, data.abbr, data.tex = name, name, texture
			data.idString, data.timeLimit = tostring(id), timeLimit
			data.timers = { thirdTimer, secondTimer, timeLimit }
			W.MythicPlusMapData[id] = data
		end
	end
	return W.MythicPlusMapData
end

W.SpecializationInfo = {}

W.RealRegion = (function()
	local region = GetCurrentRegionName()
	if region == "KR" and W.ChineseLocale then
		region = "TW" -- Fix taiwan server region issue
	end

	return region
end)()

W.CurrentRealmID = GetRealmID()
W.CurrentRealmName = GetRealmName()

W.EquipmentSlots = {
	HEADSLOT,
	NECKSLOT,
	SHOULDERSLOT,
	SHIRTSLOT,
	CHESTSLOT,
	WAISTSLOT,
	LEGSSLOT,
	FEETSLOT,
	WRISTSLOT,
	HANDSSLOT,
	FINGER0SLOT_UNIQUE,
	FINGER1SLOT_UNIQUE,
	TRINKET0SLOT_UNIQUE,
	TRINKET1SLOT_UNIQUE,
	BACKSLOT,
	MAINHANDSLOT,
	SECONDARYHANDSLOT,
	RANGEDSLOT,
	TABARDSLOT,
}

W.CurrentTierSetTable = {}
W.CurrentTierSetItemIDTable = {}
W.RealmSlugs = {}

function W:InitializeMetadata()
	self:GetMythicPlusMapData()
	for classID = 1, GetNumClasses() do
		local class = {}
		for specIndex = 1, 4 do
			local id, name, _, icon, role = GetSpecializationInfoForClassID(classID, specIndex)
			if id then
				tinsert(class, { specID = id, name = name, icon = icon, role = role })
			end
		end
		W.SpecializationInfo[classID] = class
	end
end
