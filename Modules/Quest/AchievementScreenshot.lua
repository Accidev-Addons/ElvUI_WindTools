local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local AS = W:NewModule("AchievementScreenshot", "AceEvent-3.0")
local CA = W:GetModule("CombatAlert") ---@class CombatAlert

local _G = _G

local RunNextFrame = RunNextFrame

local isProcessingScreenshot = false

local function IsAchievementAlertShown()
	for i = 1, _G.MAX_ACHIEVEMENT_ALERTS or 2 do
		local frame = _G["AchievementAlertFrame" .. i]
		if frame and frame:IsShown() then
			return true
		end
	end

	return false
end

function AS:DelayScreenshot()
	if isProcessingScreenshot then
		return
	end

	isProcessingScreenshot = true

	E:Delay(0.1, function()
		F.WaitFor(IsAchievementAlertShown, function()
			local hideCombatAlert = self.db
				and self.db.hideCombatAlert
				and CA
				and CA.AlertFrame
				and CA.AlertFrame:IsShown()
			local forceShowUI = self.db and self.db.forceShowUI and not _G.UIParent:IsShown()
			local chatMessage = self.db and self.db.chatMessage

			if hideCombatAlert then
				CA.AlertFrame:Hide()
			end

			if forceShowUI then
				_G.UIParent:Show()
			end

			E:Delay(1.4, function()
				_G.Screenshot()
				RunNextFrame(function()
					if chatMessage then
						F.Print(L["Screenshot has been automatically taken."])
					end

					if hideCombatAlert then
						CA.AlertFrame:Show()
					end

					isProcessingScreenshot = false
				end)
			end)
		end, 0.1, 20)
	end)
end

function AS:Initialize()
	self.db = E.db.WT.quest.achievementScreenshot

	if self.initialized or not self.db.enable then
		return
	end

	self:RegisterEvent("ACHIEVEMENT_EARNED", "DelayScreenshot")

	self.initialized = true
end

function AS:ProfileUpdate()
	self:Initialize()

	if self.initialized and not self.db.enable then
		self:UnregisterEvent("ACHIEVEMENT_EARNED")
		self.initialized = false
	end
end

W:RegisterModule(AS:GetName())
