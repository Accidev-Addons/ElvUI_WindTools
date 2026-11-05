local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local max = max
local unpack = unpack

local PADDING = 4

function S:LossOfControlFrame_UpdateSize(frame)
	local db = self.db.lossOfControl
	local hasText = not db.abilityName.hide or not db.timeLeft.hide

	local height = db.icon.iconSize
	if hasText then
		height = height + PADDING * 2 + 28
	end

	local width = db.icon.iconSize
	if hasText then
		width = max(width, 200)
	else
		width = width + 12
	end

	frame:Size(width, height)
end

function S:LossOfControlFrame_SetUpDisplay(frame)
	if not frame then
		return
	end

	local db = self.db.lossOfControl

	frame.Cooldown:SetAlpha(db.icon.hideCooldown and 0 or 1)

	frame.Icon:ClearAllPoints()
	frame.Icon:Point(db.icon.anchor, frame, db.icon.anchor, db.icon.offsetX, db.icon.offsetY)
	frame.Icon:Size(db.icon.iconSize)

	if db.icon.iconShadow then
		if not frame.Icon.backdrop then
			frame.Icon:CreateBackdrop()
		end
		if not frame.Icon.__windShadow then
			self:CreateBackdropShadow(frame.Icon, true)
			if frame.Icon.__windShadow then
				self:BindShadowColorWithBorder(frame.Icon.backdrop)
			end
		end
		if frame.Icon.backdrop and frame.Icon.backdrop.shadow then
			frame.Icon.backdrop.shadow:Show()
		end

		local backdropDB = db.backdrop
		if backdropDB.useCustomColor and backdropDB.r then
			frame.Icon.backdrop:SetBackdropBorderColor(backdropDB.r, backdropDB.g, backdropDB.b)
		else
			frame.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	elseif frame.Icon.backdrop and frame.Icon.backdrop.shadow then
		frame.Icon.backdrop.shadow:Hide()
	end

	if db.abilityName.hide then
		frame.AbilityName:Hide()
	else
		frame.AbilityName:Show()
		frame.AbilityName:ClearAllPoints()
		if db.abilityName.justifyH == "LEFT" then
			frame.AbilityName:Point("LEFT", frame, "CENTER", db.abilityName.offsetX, db.abilityName.offsetY)
		elseif db.abilityName.justifyH == "RIGHT" then
			frame.AbilityName:Point("RIGHT", frame, "CENTER", db.abilityName.offsetX, db.abilityName.offsetY)
		else
			frame.AbilityName:Point("CENTER", frame, "CENTER", db.abilityName.offsetX, db.abilityName.offsetY)
		end
		F.SetFontWithDB(frame.AbilityName, db.abilityName.font)
	end

	if db.timeLeft.hide then
		frame.TimeLeft:Hide()
	else
		frame.TimeLeft:Show()
		frame.TimeLeft:ClearAllPoints()
		frame.TimeLeft.NumberText:ClearAllPoints()
		frame.TimeLeft.SecondsText:ClearAllPoints()
		if db.timeLeft.justifyH == "LEFT" then
			frame.TimeLeft:Point("LEFT", frame, "CENTER", db.timeLeft.offsetX, db.timeLeft.offsetY)
			frame.TimeLeft.NumberText:Point("LEFT", frame.TimeLeft, "LEFT", 0, 0)
			frame.TimeLeft.SecondsText:Point("LEFT", frame.TimeLeft.NumberText, "RIGHT", 3, 0)
		elseif db.timeLeft.justifyH == "RIGHT" then
			frame.TimeLeft:Point("RIGHT", frame, "CENTER", db.timeLeft.offsetX, db.timeLeft.offsetY)
			frame.TimeLeft.SecondsText:Point("RIGHT", frame.TimeLeft, "RIGHT", 0, 0)
			frame.TimeLeft.NumberText:Point("RIGHT", frame.TimeLeft.SecondsText, "LEFT", -3, 0)
		else
			frame.TimeLeft:Point("CENTER", frame, "CENTER", db.timeLeft.offsetX, db.timeLeft.offsetY)
			frame.TimeLeft.NumberText:Point("CENTER", frame.TimeLeft, "CENTER", 0, 0)
			frame.TimeLeft.SecondsText:Point("LEFT", frame.TimeLeft.NumberText, "RIGHT", 3, 0)
		end
		F.SetFontWithDB(frame.TimeLeft.NumberText, db.timeLeft.font)
		F.SetFontWithDB(frame.TimeLeft.SecondsText, db.timeLeft.font)
		local numberColor = db.timeLeft.numberColor
		frame.TimeLeft.NumberText:SetTextColor(numberColor.r, numberColor.g, numberColor.b)
	end

	self:LossOfControlFrame_UpdateSize(frame)
end

function S:LossOfControlFrame()
	if not self:CheckDB("losscontrol", "lossOfControl") then
		return
	end

	self:SecureHook("LossOfControlFrame_SetUpDisplay", "LossOfControlFrame_SetUpDisplay")
	self:SecureHook(_G.LossOfControlFrame.AbilityName, "Show", function(f)
		if self.db.lossOfControl.abilityName.hide then
			f:Hide()
		end
	end)
	self:SecureHook(_G.LossOfControlFrame.TimeLeft, "Show", function(f)
		if self.db.lossOfControl.timeLeft.hide then
			f:Hide()
		end
	end)

	self:LossOfControlFrame_UpdateSize(_G.LossOfControlFrame)

	E:CreateMover(
		_G.LossOfControlFrame,
		"WTLossOfControlFrameMover",
		W.Title .. " - " .. L["Loss Of Control"],
		nil,
		nil,
		nil,
		"ALL,WINDTOOLS",
		function()
			return not self:CheckDB("losscontrol", "lossOfControl")
		end,
		"WindTools,skins,lossOfControl"
	)
end

S:AddCallback("LossOfControlFrame")
