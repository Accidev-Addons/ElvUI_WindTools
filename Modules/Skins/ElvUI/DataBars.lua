local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local pairs = pairs

function S:ElvUI_DataBars()
	if not (E.private.WT.skins.elvui.enable and E.private.WT.skins.elvui.dataBars) then
		return
	end

	local bars = {
		_G.ElvUI_ExperienceBarHolder,
		_G.ElvUI_PetExperienceBarHolder,
		_G.ElvUI_ReputationBarHolder,
		_G.ElvUI_HonorBarHolder,
		_G.ElvUI_ThreatBarHolder,
	}
	for _, bar in pairs(bars) do
		if bar then
			self:CreateShadow(bar)
		end
	end
end

S:AddCallback("ElvUI_DataBars")
