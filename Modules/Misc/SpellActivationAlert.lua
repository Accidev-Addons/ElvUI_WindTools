local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable

local SA = W:NewModule("SpellActivationAlert") ---@class SpellActivationAlert : AceModule

local _G = _G
local pairs = pairs
local tonumber = tonumber

local GetCVar = GetCVar

local OVERLAY_TEXTURE_PATH = "Interface\\SpellActivationOverlay\\"

function SA:Update()
	if not self.db then
		return
	end

	local scale = self.db.enable and self.db.scale or 1
	_G.SpellActivationOverlayFrame:SetScale(scale)

	local opacityCVar = GetCVar("spellActivationOverlayOpacity")
	local opacity = opacityCVar and tonumber(opacityCVar)
	if opacity then
		_G.SpellActivationOverlayFrame:SetAlpha(opacity)
	end
end

local previewData = {
	TOP = { texture = "generictop_01" },
	BOTTOM = { texture = "generictop_01", vFlip = true },
	LEFT = { texture = "killing_machine" },
	RIGHT = { texture = "killing_machine", hFlip = true },
}

function SA:Preview()
	local frame = _G.SpellActivationOverlayFrame
	for position, data in pairs(previewData) do
		_G.SpellActivationOverlay_ShowOverlay(
			frame,
			0,
			OVERLAY_TEXTURE_PATH .. data.texture,
			position,
			1,
			1,
			1,
			1,
			data.vFlip,
			data.hFlip
		)
	end

	self.previewID = (self.previewID or 0) + 1
	local previewID = self.previewID
	E:Delay(3, function()
		if previewID == self.previewID then
			_G.SpellActivationOverlay_HideAllOverlays(frame)
		end
	end)
end

function SA:Initialize()
	self.db = E.db.WT.misc.spellActivationAlert

	if not self.db.enable then
		return
	end

	F.TaskManager:AfterLogin(self.Update, self)
end

function SA:ProfileUpdate()
	self.db = E.db.WT.misc.spellActivationAlert
	self:Update()
end

W:RegisterModule(SA:GetName())
