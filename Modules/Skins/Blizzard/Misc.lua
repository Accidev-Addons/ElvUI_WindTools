local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins
local ES = E.Skins

local _G = _G
local pairs = pairs

function S:BlizzardMiscFrames()
	if not self:CheckDB("misc") then
		return
	end

	-- [SIRUS] These windows are styled directly by ElvUI 9.07.
	for _, frame in pairs({
		_G.AutoCompleteBox, _G.GhostFrame, _G.StackSplitFrame,
		_G.ChatConfigFrame, _G.ColorPickerFrame, _G.OpacityFrame,
		_G.MovieFrame and _G.MovieFrame.CloseDialog,
	}) do
		self:CreateShadow(frame)
	end

	for _, frame in pairs({ _G.ChatMenu, _G.EmoteMenu, _G.LanguageMenu, _G.VoiceMacroMenu }) do
		self:CreateShadow(frame)
		self:SecureHookScript(frame, "OnShow", "CreateShadow")
	end

	self:SecureHook(ES, "DropDownMenu_SkinMenu", function(_, prefix, name)
		local backdrop = prefix and _G[name]
		if backdrop and backdrop.template then
			self:CreateShadow(backdrop)
		end
	end)

	self:SecureHook(ES, "HandleIconSelectionFrame", function(_, frame)
		self:CreateShadow(frame)
	end)
end

S:AddCallback("BlizzardMiscFrames")
