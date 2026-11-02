local W, F, E = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI
local S = W.Modules.Skins ---@type Skins

function S:SettingsPanel()
	if not self:CheckDB("blizzardOptions", "settingsPanel") then
		return
	end

	self:CreateShadow(_G.InterfaceOptionsFrame)
	self:CreateShadow(_G.VideoOptionsFrame)
	self:CreateShadow(_G.AudioOptionsFrame)
end

S:AddCallback("SettingsPanel")
