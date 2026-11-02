local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local DI = W:NewModule("DeleteItem", "AceEvent-3.0")
local S = W.Modules.Skins ---@type Skins
local C = W.Utilities.Color

local _G = _G
local strmatch = strmatch
local strsplit = strsplit
local ipairs = ipairs

local CreateFrame = CreateFrame
local StaticPopupDialogs = _G.StaticPopupDialogs
local STATICPOPUP_NUMDIALOGS = _G.STATICPOPUP_NUMDIALOGS

local DELETE_ITEM_CONFIRM_STRING = DELETE_ITEM_CONFIRM_STRING

local dialogs = {
	["DELETE_ITEM"] = true,
	["DELETE_GOOD_ITEM"] = true,
}

local function ClearKeySupport(frame)
	local handler = frame.windDeleteItemKeyHandler
	if not handler then
		return
	end
	if frame:GetScript("OnKeyDown") == handler then
		frame:SetScript("OnKeyDown", frame.windDeleteItemPreviousKeyHandler)
	end
	frame.windDeleteItemKeyHandler = nil
	frame.windDeleteItemPreviousKeyHandler = nil
end

function DI:AddKeySupport(dialog)
	local targetFrame = dialog

	if self.db.fillIn == "AUTO" and dialog.editBox then
		targetFrame = dialog.editBox
	end

	-- 添加说明
	if dialog.which ~= "DELETE_ITEM" then
		local hint = L["Press the |cffffd200Delete|r key as confirmation."]
		local msg = dialog.text:GetText()
		local msgTable = { strsplit("\n\n", msg) }

		msg = ""

		for _, v in ipairs(msgTable) do
			if (v ~= "") and (v ~= hint) and (not strmatch(v, DELETE_ITEM_CONFIRM_STRING)) then
				msg = msg .. v .. "\n\n"
			end
		end

		msg = msg .. hint
		dialog.text:SetText(msg)
	end

	-- 按键删除
	local previous = targetFrame:GetScript("OnKeyDown")
	if previous == targetFrame.windDeleteItemKeyHandler then
		previous = targetFrame.windDeleteItemPreviousKeyHandler
	end
	local which = dialog.which
	local handler
	handler = function(frame, key)
		if key == "DELETE" and frame.windDeleteItemKeyHandler == handler and dialog.which == which and dialog:IsShown() then
			dialog.button1:Enable()
		elseif previous then
			previous(frame, key)
		end
	end
	targetFrame.windDeleteItemPreviousKeyHandler = previous
	targetFrame.windDeleteItemKeyHandler = handler
	targetFrame:SetScript("OnKeyDown", handler)

	if not targetFrame.windDeleteItemKeyHooked then
		targetFrame:HookScript("OnHide", ClearKeySupport)
		targetFrame.windDeleteItemKeyHooked = true
	end
end

function DI:ShowFillInButton(dialog)
	local editBoxFrame = dialog.editBox
	local yesButton = dialog.button1
	if not editBoxFrame or not yesButton then
		return
	end

	-- 初始化填入按钮
	if not self.fillInButton then
		local button = CreateFrame("Button", nil, E.UIParent, "UIPanelButtonTemplate")
		button:SetFrameStrata("TOOLTIP")
		S:Proxy("HandleButton", button)
		self.fillInButton = button
	end

	self.fillInButtonOwner = dialog

	-- 覆盖住
	editBoxFrame:Hide()
	self.fillInButton:Point("TOPLEFT", editBoxFrame, "TOPLEFT", -2, -4)
	self.fillInButton:Point("BOTTOMRIGHT", editBoxFrame, "BOTTOMRIGHT", 2, 4)

	-- 点击后填入 Delete
	self.fillInButton:SetText(C.StringByTemplate(L["Click to confirm"], "rose-500"))
	self.fillInButton:SetScript("OnClick", function(_)
		yesButton:Enable()
		self.fillInButton:SetText("|cff2ecc71" .. L["Confirmed"] .. "|r")
	end)
	self.fillInButton:Show()
end

function DI.HideFillInButton(dialog)
	if dialog and dialog ~= DI.fillInButtonOwner then
		return
	end
	DI.fillInButtonOwner = nil
	if DI.fillInButton then
		DI.fillInButton:Hide()
		DI.fillInButton:SetScript("OnClick", nil)
	end
end

function DI:DELETE_ITEM_CONFIRM()
	for index = 1, STATICPOPUP_NUMDIALOGS do
		local dialog = _G["StaticPopup" .. index]
		local info = dialog and dialogs[dialog.which] and StaticPopupDialogs[dialog.which]
		if info and dialog:IsShown() then
			if self.db.delKey then
				self:AddKeySupport(dialog)
			end

			-- Delete 填入
			if info.hasEditBox == 1 then
				if self.db.fillIn == "CLICK" then
					self:ShowFillInButton(dialog)
					if not dialog.windDeleteItemFillInHooked then
						dialog:HookScript("OnHide", DI.HideFillInButton)
						dialog.windDeleteItemFillInHooked = true
					end
				elseif self.db.fillIn == "AUTO" then
					dialog.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
				end
			end
		end
	end
end

function DI:Initialize()
	if not E.db.WT.item.delete.enable then
		return
	end

	self.db = E.db.WT.item.delete

	self:RegisterEvent("DELETE_ITEM_CONFIRM")
end

function DI:ProfileUpdate()
	local owner = self.fillInButtonOwner
	self.HideFillInButton()
	if owner and owner:IsShown() then
		owner.editBox:Show()
	end
	for index = 1, STATICPOPUP_NUMDIALOGS do
		local dialog = _G["StaticPopup" .. index]
		if dialog then
			ClearKeySupport(dialog)
			ClearKeySupport(dialog.editBox)
		end
	end

	if not E.db.WT.item.delete.enable then
		self:UnregisterEvent("DELETE_ITEM_CONFIRM")
	else
		self:Initialize()
	end
end

W:RegisterModule(DI:GetName())
