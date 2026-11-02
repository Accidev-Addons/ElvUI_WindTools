local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

function S:Blizzard_DebugTools()
	if not self:CheckDB("debug", "debugTools") then
		return
	end

	self:CreateShadow(_G.ScriptErrorsFrame)
	self:CreateBackdropShadow(_G.ScriptErrorsFrameScrollFrame)
	self:CreateShadow(_G.EventTraceFrame)
	if self:CheckDB("tooltip", "tooltips") then
		self:ReskinTooltip(_G.FrameStackTooltip)
		self:ReskinTooltip(_G.EventTraceTooltip)
	end
end

S:AddCallbackForAddon("Blizzard_DebugTools")
