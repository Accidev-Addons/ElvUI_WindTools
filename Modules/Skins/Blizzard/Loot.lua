local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:LootFrame()
	if not self:CheckDB("loot") or E.private.general.loot then
		return
	end

	-- [SIRUS] ElvUI styles the native loot window when its own loot module is disabled.
	self:CreateShadow(_G.LootFrame)
	for i = 1, _G.LOOTFRAME_NUMBUTTONS do
		self:CreateBackdropShadow(_G["LootButton" .. i])
	end
end

S:AddCallback("LootFrame")
