local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:Blizzard_BlackMarketUI()
	if not self:CheckDB(nil, "blackMarket") then
		return
	end

	self:CreateShadow(_G.BlackMarketFrame)
end

S:AddCallback("Blizzard_BlackMarketUI")
