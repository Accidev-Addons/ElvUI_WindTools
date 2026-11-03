local W ---@class WindTools
local F, E, L ---@type Functions, ElvUI, LocaleTable
W, F, E, L = unpack((select(2, ...)))

local tinsert = tinsert

local GetCVar = GetCVar
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

local C_Service = C_Service

E.myClassColor = E.myClassColor or E:ClassColor(E.myclass, true)

-- WindTools
W.Title = L["WindTools"]

-- Environment
W.SupportElvUIVersion = 9.0914
W.UseKeyDown = GetCVar("ActionButtonUseKeyDown") == "1"

-- Game
W.MaxLevelForPlayerExpansion = MAX_PLAYER_LEVEL

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
