local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local M = W.Modules.Misc ---@class Misc

local CreateFrame = CreateFrame

local LeaveParty = LeaveParty

local function createInvisibleButton(name, buttonType, content)
	local button = CreateFrame("Button", name, E.UIParent, "SecureActionButtonTemplate")

	if buttonType == "onclick" then
		button:SetScript("OnClick", content)
	elseif buttonType == "macro" then
		button:SetAttribute("type", "macro")
		button:SetAttribute("macrotext", content)
	end

	button:RegisterForClicks(W.UseKeyDown and "AnyDown" or "AnyUp")

	return button
end

function M:ExtraBindingButtons()
	self.ExtraBindingButtons = {}

	self.ExtraBindingButtons.Logout = createInvisibleButton("WTExtraBindingButtonLogout", "macro", "/logout")

	self.ExtraBindingButtons.LeaveParty = createInvisibleButton("WTExtraBindingButtonLeaveGroup", "onclick", function()
		LeaveParty()
	end)
end

M:AddCallback("ExtraBindingButtons")
