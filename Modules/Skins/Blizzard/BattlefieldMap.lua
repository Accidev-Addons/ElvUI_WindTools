local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:Blizzard_BattlefieldMinimap()
	if not self:CheckDB("bgmap", "battlefieldMap") then
		return
	end

	self:CreateBackdropShadow(_G.BattlefieldMinimap)
end

S:AddCallbackForAddon("Blizzard_BattlefieldMinimap")
