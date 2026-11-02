local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

local hooksecurefunc = hooksecurefunc
local select = select
local unpack = unpack

local C_ChallengeMode_GetAffixInfo = C_ChallengeMode.GetAffixInfo

local function ScenarioObjectiveTrackerChallengeMode_SetUpAffixes(block)
	for frame in block.affixPool:EnumerateActive() do
		if frame.affixID then
			if not frame.__windSkin then
				frame.Border:SetAlpha(0)
				frame:CreateBackdrop("Transparent")
				frame.backdrop:ClearAllPoints()
				frame.backdrop:SetOutside(frame.Portrait)
				frame.__windSkin = true
			end
			frame.Portrait:SetTexture(select(3, C_ChallengeMode_GetAffixInfo(frame.affixID)))
			frame.Portrait:SetTexCoords()
		end
	end
end

local function ScenarioObjectiveTrackerChallengeMode_Activate(block)
	if block.__windSkin then
		return
	end

	-- Block background
	block.TimerBG:Hide()
	block.TimerBGBack:Hide()
	block.Timer:Hide()

	block:CreateBackdrop("Transparent")
	block.backdrop:ClearAllPoints()
	block.backdrop:SetInside(block, 6, 2)
	S:CreateBackdropShadow(block)

	-- Time bar
	block.StatusBar:CreateBackdrop()
	block.StatusBar.backdrop:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.6)
	block.StatusBar:SetStatusBarTexture(E.media.normTex)
	block.StatusBar:SetStatusBarColor(unpack(E.media.rgbvaluecolor))
	block.StatusBar:Height(12)

	block.__windSkin = true
end

function S:ScenarioStage()
	if not self:CheckDB(nil, "scenario") then
		return
	end

	local block = _G.ScenarioObjectiveTracker and _G.ScenarioObjectiveTracker.ChallengeModeBlock
	if not block then
		return
	end

	hooksecurefunc(block, "Activate", ScenarioObjectiveTrackerChallengeMode_Activate)
	hooksecurefunc(block, "SetUpAffixes", ScenarioObjectiveTrackerChallengeMode_SetUpAffixes)

	if block:IsActive() then
		ScenarioObjectiveTrackerChallengeMode_Activate(block)
		ScenarioObjectiveTrackerChallengeMode_SetUpAffixes(block)
	end
end

S:AddCallback("ScenarioStage")
