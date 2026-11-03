local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:Blizzard_UIPanels_Game()
	if not self:CheckDB("character") then
		return
	end

	-- Character
	self:CreateShadow(_G.CharacterFrame)
	self:CreateBackdropShadow(_G.GearManagerDialogPopup)
	self:CreateShadow(_G.EquipmentFlyoutFrameButtons)
	for i = 1, 4 do
		self:ReskinTab(_G["CharacterFrameTab" .. i])
	end

	-- Token
	self:CreateShadow(_G.TokenFramePopup)

	-- Reputation
	self:CreateShadow(_G.ReputationDetailFrame)
	_G.ReputationDetailFrame:ClearAllPoints()
	_G.ReputationDetailFrame:Point("TOPLEFT", _G.ReputationFrame, "TOPRIGHT", 3, 0)
end

S:AddCallback("Blizzard_UIPanels_Game")
