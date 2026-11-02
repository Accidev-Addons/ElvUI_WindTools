local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local A = W:NewModule("Absorb", "AceHook-3.0") ---@class Absorb: AceModule, AceHook-3.0, AceEvent-3.0
local LSM = E.Libs.LSM
local UF = E.UnitFrames

function A:UpdateStatusBarTexture(bar, texture, dbKey)
	if not bar then
		return
	end

	local db = self.db and self.db.enable and self.db[dbKey]
	local custom
	if db and db.enable then
		if db.blizzardStyle then
			custom = "Interface/RaidFrame/Shield-Fill"
		elseif db.custom then
			custom = LSM:Fetch("statusbar", db.custom)
		end
	end
	bar:SetStatusBarTexture(custom or texture)
end

function A:Configure_HealComm(_, frame)
	local obj = frame.HealCommBar
	if not obj then
		return
	end

	local health = frame.Health
	if not health then
		return
	end
	local healthTexture = health:GetStatusBarTexture()
	local texture = not health.isTransparent and healthTexture and healthTexture:GetTexture() or E.media.blankTex
	self:UpdateStatusBarTexture(obj.absorbBar, texture, "damageAbsorb")
	self:UpdateStatusBarTexture(obj.healAbsorbBar, texture, "healAbsorb")
	self:UpdateStatusBarTexture(obj.myBar, texture, "healPrediction")
	self:UpdateStatusBarTexture(obj.otherBar, texture, "healPrediction")

	local bar = obj.absorbBar
	if not bar then
		return
	end

	if self.db and self.db.enable and self.db.blizzardAbsorbOverlay then
		if not bar.__shieldOverlay then
			local overlay = bar:CreateTexture(nil, "ARTWORK", nil, 1)
			overlay:SetTexture("Interface/RaidFrame/Shield-Overlay", true, true)
			overlay:SetHorizTile(true)
			overlay:SetVertTile(true)
			bar.__shieldOverlay = overlay
		end
		bar.__shieldOverlay:SetAllPoints(bar:GetStatusBarTexture())
		bar.__shieldOverlay:Show()
	elseif bar.__shieldOverlay then
		bar.__shieldOverlay:Hide()
	end
end

function A:Initialize()
	self.db = E.db.WT.unitFrames.absorb

	if not self.db or not self.db.enable or self.initialized then
		return
	end

	self:SecureHook(UF, "Configure_HealComm")

	self.initialized = true
	UF:Update_AllFrames()
end

function A:ProfileUpdate()
	self:Initialize()
	UF:Update_AllFrames()
end

W:RegisterModule(A:GetName())
