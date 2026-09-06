local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G

local function SkinOption(frame)
	if frame.__windSkin then
		return
	end
	S:CreateBackdropShadow(frame.DecrementButton)
	S:CreateBackdropShadow(frame.IncrementButton)
	F.SetFont(frame.Label)
	frame.__windSkin = true
end

function S:Blizzard_BarbershopUI()
	if not self:CheckDB("barber", "barberShop") then
		return
	end

	-- [SIRUS] Character customization is backported into CustomBarberShopFrame.
	local frame = _G.CustomBarberShopFrame
	self:CreateBackdropShadow(frame.ResetButton)
	self:CreateBackdropShadow(frame.CancelButton)
	self:CreateBackdropShadow(frame.AcceptButton)

	local customize = _G.CharCustomizeFrame
	self:CreateBackdropShadow(customize.RandomizeAppearanceButton)
	self:SecureHook(_G.CharCustomizeOptionSelectionFrameMixin, "SetupOption", SkinOption)
end

S:AddCallbackForAddon("Blizzard_BarbershopUI")
