local W ---@class WindTools
local F, E, L ---@type Functions, ElvUI, LocaleTable
W, F, E, L = unpack((select(2, ...)))

local tinsert = tinsert
local tostring = tostring

local GetCVar = GetCVar
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local C_Service = C_Service

E.myClassColor = E.myClassColor or E:ClassColor(E.myclass, true)

-- WindTools
W.Title = L["WindTools"]

-- Environment
W.SupportElvUIVersion = 9.07
W.UseKeyDown = GetCVar("ActionButtonUseKeyDown") == "1"

-- Game
W.MaxLevelForPlayerExpansion = MAX_PLAYER_LEVEL

W.MythicPlusMapData = {}

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

W.RealRegion = "EU"
W.CurrentRealmID = C_Service and C_Service.GetRealmID and C_Service.GetRealmID() or 0

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
