local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:WardrobeFrame()
	if not self:CheckDB("wardrobe", "transmogrify") then
		return
	end

	self:CreateShadow(_G.WardrobeFrame)
	self:CreateShadow(_G.WardrobeOutfitEditFrame)
end

S:AddCallback("WardrobeFrame")
