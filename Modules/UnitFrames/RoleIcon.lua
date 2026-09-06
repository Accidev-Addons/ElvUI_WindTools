local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local UF = E:GetModule("UnitFrames")
local RI = W:NewModule("RoleIcon", "AceHook-3.0")

local nativeIcons = {
	[E.Media.Textures.Tank] = "TANK",
	[E.Media.Textures.Healer] = "HEALER",
	[E.Media.Textures.DPS] = "DAMAGER",
}

function RI:SetRoleTexture(texture, path)
	local role = nativeIcons[path]
	local replacement = role and UF.RoleIconTextures[role]
	if replacement and replacement ~= path then
		texture:SetTexture(replacement)
	end
end

function RI:Configure_RoleIcon(_, frame)
	local texture = frame.GroupRoleIndicator
	if texture and not self:IsHooked(texture, "SetTexture") then
		self:SecureHook(texture, "SetTexture", "SetRoleTexture")
	end
	if texture then
		self:SetRoleTexture(texture, texture:GetTexture())
	end
end

function RI:Initialize()
	self.db = E.private.WT.unitFrames.roleIcon
	local pack = self.db and self.db.enable and self.db.roleIconStyle or "DEFAULT"
	UF.RoleIconTextures = W.Media.RoleIcons[pack] or W.Media.RoleIcons.DEFAULT
	if not self.db or not self.db.enable or self.initialized then
		return
	end
	self:SecureHook(UF, "Configure_RoleIcon")
	self.initialized = true
	UF:Update_AllFrames()
end

W:RegisterModule(RI:GetName())
