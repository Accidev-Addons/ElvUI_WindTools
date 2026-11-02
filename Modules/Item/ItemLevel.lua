local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local IL = W:NewModule("ItemLevel", "AceEvent-3.0", "AceHook-3.0")
local B = E:GetModule("Bags")
local LSM = E.Libs.LSM

local _G = _G
local pairs = pairs
local tostring = tostring
local type = type

local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local async = W.Utilities.Async
local ItemLocation = ItemLocation

local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION

---@param text FontString
---@param db ProfileDB.item.itemLevel.flyout
local function UpdateFlyoutItemLevelTextStyle(text, db)
	if db.useBagsFontSetting then
		F.FontTemplate(text, LSM:Fetch("font", B.db.itemLevelFont), B.db.itemLevelFontSize, B.db.itemLevelFontOutline)
		text:ClearAllPoints()
		text:Point(B.db.itemLevelPosition, B.db.itemLevelxOffset, B.db.itemLevelyOffset)
		return
	end

	F.SetFontWithDB(text, db.font)
	text:ClearAllPoints()
	text:Point("BOTTOMRIGHT", db.font.xOffset, db.font.yOffset)
end

---Refresh the item level text for a given item
---@param text FontString
---@param db ProfileDB.item.itemLevel.flyout
---@param location ItemLocation
local function RefreshItemLevel(text, db, location)
	if not text then
		return
	end

	local bag, slot = location:GetBagAndSlot()
	local equipmentSlot = location:GetEquipmentSlot()
	local link = bag and slot and GetContainerItemLink(bag, slot)
		or equipmentSlot and GetInventoryItemLink("player", equipmentSlot)
	text.windItemLink = link
	text:SetText("")
	if not link then
		return
	end

	UpdateFlyoutItemLevelTextStyle(text, db)
	async.WithItemLink(link, function(item)
		if text.windItemLink ~= link then
			return
		end
		local itemLevel = item and item:GetCurrentItemLevel()
		text:SetText(itemLevel and tostring(itemLevel) or "")
		F.SetFontColorWithDB(text, db.qualityColor and item:GetItemQualityColor() or db.font.color)
	end)
end

function IL:FlyoutButton()
	local flyout = _G.EquipmentFlyoutFrame
	local buttons = flyout.buttons
	local flyoutSettings = flyout.button:GetParent().flyoutSettings

	if not self.db.enable or not self.db.flyout.enable then
		if buttons then
			for _, button in pairs(buttons) do
				if button.itemLevel then
					button.itemLevel.windItemLink = nil
					button.itemLevel:SetText("")
				end
			end
		end
		return
	end

	for _, button in pairs(buttons) do
		if not button.itemLevel then
			button.itemLevel = button:CreateFontString(nil, "ARTWORK", nil, 1)
			UpdateFlyoutItemLevelTextStyle(button.itemLevel, self.db.flyout)
		end

		local itemLocation

		if flyoutSettings.useItemLocation then
			itemLocation = button.itemLocation
		elseif
			button.location
			and type(button.location) == "number"
			and not (button.location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION)
		then
			local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(button.location)
			if bags then
				itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
			elseif player or bank then
				itemLocation = ItemLocation:CreateFromEquipmentSlot(slot)
			end
		end

		if itemLocation then
			RefreshItemLevel(button.itemLevel, self.db.flyout, itemLocation --[[@as ItemLocation]])
		else
			button.itemLevel.windItemLink = nil
			button.itemLevel:SetText("")
		end
	end
end

function IL:ProfileUpdate()
	self.db = E.db.WT.item.itemLevel

	if self.db.enable and not self.initialized then
		self:SecureHook("EquipmentFlyout_UpdateItems", "FlyoutButton")
		self.initialized = true
	end
end

IL.Initialize = IL.ProfileUpdate

W:RegisterModule(IL:GetName())
