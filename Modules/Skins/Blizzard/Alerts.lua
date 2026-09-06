local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

local function SkinAlert(frame)
	if not frame or frame.__windSkin then
		return
	end

	S:CreateBackdropShadow(frame)
	F.SetFrameFontOutline(frame)
	frame.__windSkin = true
end

local function SkinAchievementAlerts()
	-- [SIRUS] Alerts are named frames, created on demand by GetAlertFrame.
	for i = 1, _G.MAX_ACHIEVEMENT_ALERTS do
		local frame = _G["AchievementAlertFrame" .. i]
		if frame and not frame.__windSkin then
			local name = frame:GetName()
			S:CreateBackdropShadow(_G[name .. "Icon"])
			F.SetFont(_G[name .. "Unlocked"])
			F.SetFont(_G[name .. "Name"], nil, "+4")
			SkinAlert(frame)
		end
	end
end

function S:AlertFrames()
	if not self:CheckDB("alertframes", "alerts") then
		return
	end

	SkinAchievementAlerts()
	self:SecureHook("AchievementAlertFrame_ShowAlert", SkinAchievementAlerts)
	SkinAlert(_G.DungeonCompletionAlertFrame1)
	for i = 1, 4 do
		SkinAlert(_G["LootAlertButton" .. i])
	end
end

S:AddCallback("AlertFrames")
