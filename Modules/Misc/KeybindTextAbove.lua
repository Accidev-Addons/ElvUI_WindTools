local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local M = W.Modules.Misc ---@class Misc
local AB = E.ActionBars

local hooksecurefunc = hooksecurefunc
local pairs = pairs

local CreateFrame = CreateFrame

local function ReplaceHotKeyParent(button)
	if not button.cooldown or not button.HotKey then
		return
	end

	if not button.windHotKeyFrame then
		button.windHotKeyFrame = CreateFrame("Frame", nil, button)
		button.windHotKeyFrame:SetAllPoints(button)
		button.windHotKeyFrame:SetFrameStrata("LOW")
		button.windHotKeyFrame:SetFrameLevel(button.cooldown:GetFrameLevel() + 11) -- The glow is about 10
	end

	button.HotKey:SetParent(button.windHotKeyFrame)
end

function M:KeybindTextAbove()
	if not E.private.actionbar.enable or not E.db.cooldown.enable or not E.private.WT.misc.keybindTextAbove then
		return
	end

	hooksecurefunc(E, "RegisterCooldown", function(_, cooldown)
		local button = cooldown:GetParent()
		if button and AB.handledbuttons[button] then
			ReplaceHotKeyParent(button)
		end
	end)

	hooksecurefunc(AB, "StyleButton", function(_, button)
		if button and button.windHotKeyFrame then
			ReplaceHotKeyParent(button)
		end
	end)

	for button in pairs(AB.handledbuttons) do
		ReplaceHotKeyParent(button)
	end
end

M:AddCallback("KeybindTextAbove")
