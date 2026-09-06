local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local pairs = pairs

function S:WorldMapFrame()
	if not self:CheckDB("worldmap", "worldMap") then
		return
	end

	-- [SIRUS] Quest details and rewards are native map scroll frames.
	for _, frame in pairs({
		_G.WorldMapFrame, _G.WorldMapDetailFrame, _G.WorldMapQuestScrollFrame,
		_G.WorldMapQuestDetailScrollFrame, _G.WorldMapQuestRewardScrollFrame,
	}) do
		self:CreateBackdropShadow(frame)
	end
end

S:AddCallback("WorldMapFrame")
