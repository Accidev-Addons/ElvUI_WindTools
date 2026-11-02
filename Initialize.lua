local E, _, V, P, G = unpack(ElvUI) ---@type ElvUI
local addonName, addon = ...
local EP = E.Libs.EP
local AceAddon = E.Libs.AceAddon
local L = E.Libs.ACL:GetLocale("ElvUI", E.global.general.locale)

local _G = _G
local collectgarbage = collectgarbage
local format = format
local hooksecurefunc = hooksecurefunc
local next = next
local print = print
local strfind = strfind
local strmatch = strmatch
local tContains = tContains

local GetAddOnMetadata = GetAddOnMetadata

---@class WindTools : AceAddon, AceConsole-3.0, AceEvent-3.0, AceTimer-3.0, AceHook-3.0
local W = AceAddon:NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

V.WT = {} ---@class ProfileDB
P.WT = {} ---@class PrivateDB
G.WT = {} ---@class GlobalDB

addon[1] = W
addon[2] = {} ---@class Functions
addon[3] = E
addon[4] = L ---@alias LocaleTable table<string, string>
addon[5] = V.WT
addon[6] = P.WT
addon[7] = G.WT

_G["WindTools"] = addon

local versionString = GetAddOnMetadata(addonName, "Version")
local xVersionString = GetAddOnMetadata(addonName, "X-Version")

local function getVersion()
	local version, variant, subversion

	-- Git
	if strfind(versionString, "project%-version") then
		return xVersionString, "git", nil
	end

	version, variant = strmatch(versionString, "^(%d+%.%d+)(.*)$")

	if not version then
		return xVersionString, nil, nil
	end

	if not variant or variant == "" then
		return version, nil, nil
	end

	local variantName, subversionNum = strmatch(variant, "^%-([%w]+)%-?(%d*)$")
	if variantName and subversionNum then
		variant = variantName
		subversion = subversionNum ~= "" and subversionNum or nil
	end

	return version, variant, subversion
end

W.Version, W.Variant, W.SubVersion = getVersion()

W.DisplayVersion = W.Version
if W.Variant then
	W.DisplayVersion = format("%s-%s", W.DisplayVersion, W.Variant)
	if W.SubVersion then
		W.DisplayVersion = format("%s-%s", W.DisplayVersion, W.SubVersion)
	end
end

-- Pre-register some WindTools modules
W.Modules = {
	---@class Misc : AceModule, AceHook-3.0, AceEvent-3.0
	Misc = W:NewModule("Misc", "AceHook-3.0", "AceEvent-3.0"),
	---@class Skins : AceModule, AceHook-3.0, AceEvent-3.0, AceTimer-3.0
	Skins = W:NewModule("Skins", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0"),
	---@class Tooltips : AceModule, AceHook-3.0, AceEvent-3.0
	Tooltips = W:NewModule("Tooltips", "AceHook-3.0", "AceEvent-3.0"),
	---@class MoveFrames : AceModule, AceHook-3.0, AceEvent-3.0
	MoveFrames = W:NewModule("MoveFrames", "AceEvent-3.0", "AceHook-3.0"),
}

W:NewModule("QuestProgress", "AceEvent-3.0")

-- Utilities namespace
W.Utilities = {}

-- Pre-register libs into ElvUI
E:AddLib("WTItemEnchant", "LibItemEnchant-WT")

function W:Initialize()
	-- ElvUI -> WindTools -> WindTools Modules
	if not self:CheckElvUIVersion() then
		return
	end

	self:AddCustomLinkSupport()
	self:UpdateScripts()
	self.initialized = true

	-- To avoid the update tips from ElvUI when alpha/beta versions are used
	EP:RegisterPlugin(addonName, W.OptionsCallback, false, xVersionString)

	self:SecureHook(E, "UpdateAll", "UpdateModules")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- Init Modules
	self:InitializeModules()
end

function W:AutoCopyPrivateProfile()
	if
		not E.global.WT.core.autoCopyPrivateProfile.enable
		or E.global.WT.core.autoCopyPrivateProfile.initializedCharacters[E.mynameRealm]
	then
		return
	end

	local copyFrom = E.global.WT.core.autoCopyPrivateProfile.copyFrom
	if not copyFrom or E.charSettings:GetCurrentProfile() == copyFrom then
		return
	end

	local profiles = E.charSettings:GetProfiles()
	if tContains(profiles, copyFrom) then
		E.charSettings:CopyProfile(copyFrom)
		E.global.WT.core.autoCopyPrivateProfile.initializedCharacters[E.mynameRealm] = true
	end
end

do
	local checked = false
	function W:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
		if isInitialLogin then
			self:AutoCopyPrivateProfile()
			E:UpdateMedia()
			E:UpdateFontTemplates()
			E:Delay(6, self.ChangelogReadAlert, self)
			if E.global.WT.core.loginMessage then
				local icon = addon[2].GetIconString(self.Media.Textures.smallLogo, 14)
				print(
					format(
						icon .. " " .. L["%s %s Loaded."] .. " " .. L["Join our Discord: %s"],
						self.Title,
						self.Version,
						"https://discord.gg/CXtYebMBb"
					)
				)
			end
		end

		if not (checked or _G.ElvUIInstallFrame) then
			self:CheckCompatibility()
			checked = true
		end

		if _G.ElvDB then
			if isInitialLogin or not _G.ElvDB.WT then
				_G.ElvDB.WT = {
					DisabledAddOns = {},
				}
			end

			if next(_G.ElvDB.WT.DisabledAddOns) then
				E:Delay(4, self.PrintDebugEnviromentTip)
			end
		end

		self:HookUIError()
		self:GameFixing()

		E:Delay(1, collectgarbage, "collect")
	end
end

EP:HookInitialize(W, W.Initialize)
