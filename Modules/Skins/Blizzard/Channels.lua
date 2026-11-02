local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:ChannelFrame()
	if not self:CheckDB("friends", "channels") then
		return
	end

	self:CreateShadow(_G.ChannelFrameDaughterFrame)
end

S:AddCallback("ChannelFrame")
