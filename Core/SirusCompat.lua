local _G = _G
local pairs = pairs
local type = type
local select = select
local unpack = unpack

local function Namespace(name)
	local tbl = _G[name]
	if type(tbl) ~= "table" then
		tbl = {}
		_G[name] = tbl
	end
	return tbl
end

local function Fill(tbl, map)
	for key, value in pairs(map) do
		if tbl[key] == nil and value ~= nil then
			tbl[key] = value
		end
	end
	return tbl
end

Fill(Namespace("C_AddOns"), {
	DisableAddOn = _G.DisableAddOn,
	EnableAddOn = _G.EnableAddOn,
	GetAddOnDependencies = _G.GetAddOnDependencies,
	GetAddOnEnableState = _G.GetAddOnEnableState,
	GetAddOnInfo = _G.GetAddOnInfo,
	GetAddOnMetadata = _G.GetAddOnMetadata,
	GetNumAddOns = _G.GetNumAddOns,
	IsAddOnLoaded = _G.IsAddOnLoaded,
	IsAddOnLoadOnDemand = _G.IsAddOnLoadOnDemand,
	LoadAddOn = _G.LoadAddOn,
})

Fill(Namespace("C_CVar"), {
	GetCVar = _G.GetCVar,
	GetCVarBool = _G.GetCVarBool,
	GetCVarDefault = _G.GetCVarDefault,
	RegisterCVar = _G.RegisterCVar,
	ResetTestCVars = _G.ResetTestCVars,
	SetCVar = _G.SetCVar,
})

Fill(Namespace("C_UI"), {
	Reload = _G.ReloadUI,
})

Fill(Namespace("C_Spell"), {
	GetSpellLink = _G.GetSpellLink,
	GetSpellTexture = _G.GetSpellTexture,
})

Fill(Namespace("C_PartyInfo"), {
	InviteUnit = _G.InviteUnit,
})

Fill(Namespace("C_Container"), {
	GetContainerItemID = _G.GetContainerItemID,
	GetContainerItemLink = _G.GetContainerItemLink,
	GetContainerNumFreeSlots = _G.GetContainerNumFreeSlots,
	GetContainerNumSlots = _G.GetContainerNumSlots,
})

Fill(Namespace("C_RestrictedActions"), {
	IsAddOnRestrictionActive = function()
		return false
	end,
})

Fill(Namespace("C_StringUtil"), {
	TruncateWhenZero = function(value)
		if not value or value == 0 then
			return ""
		end
		return value
	end,
})

Fill(Namespace("C_LootJournal"), {
	GetItemSetItems = function()
		return {}
	end,
})

Namespace("C_EncodingUtil")
Namespace("C_EquipmentSet")
Namespace("C_QuestLog")
Namespace("C_PlayerInfo")

local Enum = Namespace("Enum")

if not Enum.PowerType then
	Enum.PowerType = {
		Mana = 0,
		Rage = 1,
		Focus = 2,
		Energy = 3,
		ComboPoints = 4,
		Runes = 5,
		RunicPower = 6,
	}
end

if not Enum.AddOnRestrictionType then
	Enum.AddOnRestrictionType = {
		None = 0,
		ChallengeMode = 1,
	}
end

if not Enum.CompressionMethod then
	Enum.CompressionMethod = { Deflate = 1 }
end

if not Enum.CompressionLevel then
	Enum.CompressionLevel = { Default = 0 }
end

if not Enum.TooltipDataType then
	Enum.TooltipDataType = {
		Item = 0,
		Spell = 1,
		Unit = 2,
		Corpse = 3,
		Object = 4,
		Currency = 5,
		BattlePet = 6,
		UnitAura = 7,
		AzeriteEssence = 8,
		CompanionPet = 9,
		Mount = 10,
		PetAction = 11,
		Achievement = 12,
		EnhancedConduit = 13,
		EquipmentSet = 14,
		InstanceLock = 15,
		PvPBrawl = 16,
		RecipeRankInfo = 17,
		Totem = 18,
		Toy = 19,
		CorruptionCleanser = 20,
		MinimapMouseover = 21,
		Flyout = 22,
		Quest = 23,
		QuestPartyProgress = 24,
		Macro = 25,
	}
end

if not _G.CurveConstants then
	_G.CurveConstants = { ScaleTo100 = 1 }
end

Fill(Namespace("TooltipDataProcessor"), {
	AddTooltipPostCall = function() end,
	AddTooltipPreCall = function() end,
	ClearTooltipPostCall = function() end,
	ClearTooltipPreCall = function() end,
})

Fill(Namespace("FrameUtil"), {
	RegisterForTopLevelParentChanged = function() end,
})

if not _G.GenerateFlatClosure then
	function _G.GenerateFlatClosure(func, ...)
		local count = select("#", ...)
		if count == 0 then
			return function()
				return func()
			end
		end
		local args = { ... }
		return function()
			return func(unpack(args, 1, count))
		end
	end
end

if not _G.GetMaxLevelForPlayerExpansion then
	function _G.GetMaxLevelForPlayerExpansion()
		return _G.MAX_PLAYER_LEVEL or 80
	end
end

if not _G.GetCurrentRegionName then
	function _G.GetCurrentRegionName()
		return "EU"
	end
end

if not _G.GetRealmID then
	function _G.GetRealmID()
		local C_Service = _G.C_Service
		if C_Service and C_Service.GetRealmID then
			return C_Service.GetRealmID()
		end
		return 0
	end
end

local E = _G.ElvUI and _G.ElvUI[1]
if E then
	if not E.IsSecretValue then
		function E:IsSecretValue()
			return false
		end
	end

	if not E.NotSecretValue then
		function E:NotSecretValue()
			return true
		end
	end

	if not E.IsSecretUnit then
		function E:IsSecretUnit()
			return false
		end
	end
end
