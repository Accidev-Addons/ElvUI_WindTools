local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local ES = E.Skins
local S = W.Modules.Skins ---@type Skins
local TT = E:GetModule("Tooltip")

local _G = _G
local pairs = pairs

function S:Immersion_ReskinTitleButton(frame)
	for _, button in pairs({ frame.TitleButtons:GetChildren() }) do
		if button and not button.__windSkin then
			self:Proxy("HandleButton", button, nil, nil, nil, true, "Transparent")
			button.backdrop:ClearAllPoints()
			button.backdrop:Point("TOPLEFT", button, "TOPLEFT", 3, -3)
			button.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -10, 3)
			self:CreateBackdropShadow(button)
			self:MerathilisUISkin(button.backdrop)

			button.Hilite:SetBackdrop(nil)
			button.Overlay:SetBackdrop(nil)
			button:SetBackdrop(nil)
			F.SetFont(button.Label)
			button.__windSkin = true
		end
	end
end

function S:AttemptReskinButton()
	self.reskinButtonAttemptCount = self.reskinButtonAttemptCount + 1
	self:Immersion_ReskinTitleButton(_G.ImmersionFrame)
	if self.reskinButtonAttemptCount == 10 then
		self:CancelTimer(self.reskinButtonTimer)
	end
end

function S:Immersion_Show()
	self:Immersion_SpeechProgressText()
	self:Immersion_ReskinTitleButton(_G.ImmersionFrame)
	self.reskinButtonAttemptCount = 0
	self.reskinButtonTimer = self:ScheduleRepeatingTimer("AttemptReskinButton", 0.1)
	E:Delay(0.1, S.Immersion_ReskinItems, S)
end

function S:Immersion_ReskinItems()
	for i = 1, 20 do
		local rButton = _G["ImmersionQuestInfoItem" .. i]
		if not rButton then
			break
		end

		if not rButton.__windSkin then
			if rButton.NameFrame then
				rButton.NameFrame:StripTextures()
				rButton.NameFrame:CreateBackdrop("Transparent")
				rButton.NameFrame.backdrop:ClearAllPoints()
				rButton.NameFrame.backdrop:SetOutside(rButton.NameFrame, -18, -15)
				self:CreateBackdropShadow(rButton.NameFrame)
			end
			rButton.__windSkin = true
		end
	end

	for i = 1, 20 do
		local rButton = _G["ImmersionProgressItem" .. i]
		if not rButton then
			break
		end

		if not rButton.__windSkin then
			if rButton.NameFrame then
				rButton.NameFrame:StripTextures()
				rButton.NameFrame:CreateBackdrop("Transparent")
				rButton.NameFrame.backdrop:ClearAllPoints()
				rButton.NameFrame.backdrop:SetOutside(rButton.NameFrame, -18, -15)
				self:CreateBackdropShadow(rButton.NameFrame)
			end
			rButton.__windSkin = true
		end
	end
end

do -- If there is no speech progress text in first time, the skin will not be apply
	local reskin = false
	function S:Immersion_SpeechProgressText()
		if reskin then
			return
		end
		local talkBox = _G.ImmersionFrame and _G.ImmersionFrame.TalkBox
		if talkBox and talkBox.TextFrame and talkBox.TextFrame.SpeechProgress then
			F.SetFont(talkBox.TextFrame.SpeechProgress, F.GetCompatibleFont("Montserrat"), 13)
			reskin = true
		end
	end
end

function S:Immersion_ReskinTooltips(frame)
	for tooltip in frame.Inspector.tooltipFramePool:EnumerateActive() do
		TT:SetStyle(tooltip)
		tooltip.Hilite:SetBackdrop(nil)
	end
end

function S:Immersion()
	if not E.private.WT.skins.enable or not E.private.WT.skins.addons.immersion then
		return
	end

	S:DisableAddOnSkin("Immersion")

	local frame = _G.ImmersionFrame

	-- TalkBox
	local talkBox = frame.TalkBox

	-- Backdrop
	talkBox.BackgroundFrame:StripTextures()
	talkBox:CreateBackdrop("Transparent")
	talkBox.backdrop:ClearAllPoints()
	talkBox.backdrop:Point("TOPLEFT", talkBox, "TOPLEFT", 10, -10)
	talkBox.backdrop:Point("BOTTOMRIGHT", talkBox, "BOTTOMRIGHT", -10, 10)
	self:CreateBackdropShadow(talkBox)
	self:MerathilisUISkin(talkBox.backdrop)

	-- Use colored backdrop edge as highlight
	talkBox.Hilite:SetBackdrop(nil)
	talkBox:HookScript("OnEnter", function(box)
		ES.SetModifiedBackdrop(box)

		if box.backdrop.shadow then
			box.backdrop.shadow:SetBackdropBorderColor(box.backdrop:GetBackdropBorderColor())
		end
	end)

	talkBox:HookScript("OnLeave", function(box)
		ES.SetOriginalBackdrop(box)

		if box.backdrop.shadow then
			box.backdrop.shadow:SetBackdropBorderColor(box.backdrop:GetBackdropBorderColor())
		end
	end)

	-- Remove background of model
	talkBox.PortraitFrame:StripTextures()
	talkBox.MainFrame.Model.ModelShadow:StripTextures()
	talkBox.MainFrame.Model.PortraitBG:StripTextures()

	-- No Sheen
	talkBox.MainFrame.Sheen:StripTextures()
	talkBox.MainFrame.TextSheen:StripTextures()
	talkBox.MainFrame.Overlay:StripTextures()

	-- Text
	F.SetFont(talkBox.NameFrame.Name)
	F.SetFont(talkBox.TextFrame.Text, nil, 15)

	-- Close Button
	self:Proxy("HandleCloseButton", talkBox.MainFrame.CloseButton)

	-- Indicator
	talkBox.MainFrame.Indicator:ClearAllPoints()
	talkBox.MainFrame.Indicator:Point("RIGHT", talkBox.MainFrame.CloseButton, "LEFT", -2, 0)

	local progressionBar = talkBox.ProgressionBar
	self:Proxy("HandleStatusBar", progressionBar)
	progressionBar:ClearAllPoints()
	progressionBar:Point("BOTTOMLEFT", talkBox.backdrop, "BOTTOMLEFT", 2, 2)
	progressionBar:Point("BOTTOMRIGHT", talkBox.backdrop, "BOTTOMRIGHT", -2, 2)

	-- Backdrop of elements (bottom window)
	local elements = talkBox.Elements
	elements:SetBackdrop(nil)
	self:SecureHook(elements, "SetBackdrop", function(_, backdrop)
		if backdrop then
			elements:SetBackdrop(nil)
		end
	end)
	elements:CreateBackdrop("Transparent")
	elements.backdrop:ClearAllPoints()
	elements.backdrop:Point("TOPLEFT", elements, "TOPLEFT", 10, -5)
	elements.backdrop:Point("BOTTOMRIGHT", elements, "BOTTOMRIGHT", -10, 5)
	F.SetFont(elements.Progress.ReqText)
	S:CreateBackdropShadow(elements)
	S:MerathilisUISkin(elements.backdrop)

	-- Details
	local content = elements.Content
	F.SetFont(content.ObjectivesHeader)
	F.SetFont(content.ObjectivesText)
	F.SetFont(content.RewardText)
	F.SetFont(content.RewardsFrame.Header)
	F.SetFont(content.RewardsFrame.TitleFrame.Name)
	F.SetFont(content.RewardsFrame.XPFrame.ReceiveText)
	F.SetFont(content.RewardsFrame.XPFrame.ValueText)
	F.SetFont(content.RewardsFrame.ItemReceiveText)
	F.SetFont(content.RewardsFrame.ItemChooseText)
	F.SetFont(content.RewardsFrame.PlayerTitleText)

	-- Buttons
	self:SecureHookScript(frame, "OnEvent", "Immersion_ReskinTitleButton")
	self:SecureHook(frame, "Show", "Immersion_Show")
	self:SecureHook(frame, "ShowItems", "Immersion_ReskinTooltips")
end

S:AddCallbackForAddon("Immersion")
