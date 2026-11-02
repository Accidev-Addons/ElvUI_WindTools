local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:DressUpFrame()
	if not self:CheckDB("dressingroom", "dressingRoom") then
		return
	end

	self:CreateShadow(_G.DressUpFrame)
	self:CreateBackdropShadow(_G.DressUpModel)
	self:CreateBackdropShadow(_G.DressUpFrameCancelButton)
	self:CreateBackdropShadow(_G.DressUpFrameResetButton)
end

S:AddCallback("DressUpFrame")
