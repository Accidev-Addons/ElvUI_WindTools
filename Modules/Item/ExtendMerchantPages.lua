local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local EMP = W:NewModule("ExtendMerchantPages", "AceHook-3.0")

local _G = _G
local ceil = math.ceil
local max = math.max
local pairs = pairs

local CreateFrame = CreateFrame
local GetMerchantItemCostInfo = GetMerchantItemCostInfo
local GetMerchantItemID = GetMerchantItemID
local GetMerchantItemInfo = GetMerchantItemInfo
local GetMerchantItemInfoEx = GetMerchantItemInfoEx
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantNumItems = GetMerchantNumItems
local IsAddOnLoaded = IsAddOnLoaded

local BLIZZARD_MERCHANT_ITEMS_PER_PAGE = 10
local BLIZZARD_BUYBACK_ITEMS_PER_PAGE = 12

local function SetItemColors(merchantButton, itemButton, nameR, nameG, nameB, slotR, slotG, slotB, r, g, b)
	SetItemButtonNameFrameVertexColor(merchantButton, nameR, nameG, nameB)
	SetItemButtonSlotVertexColor(merchantButton, slotR, slotG, slotB)
	SetItemButtonTextureVertexColor(itemButton, r, g, b)
	SetItemButtonNormalTextureVertexColor(itemButton, r, g, b)
end

local function UpdateItem(i, index, numItems)
	local prefix = "MerchantItem" .. i
	local merchantButton = _G[prefix]
	local itemButton = _G[prefix .. "ItemButton"]
	local moneyFrame = _G[prefix .. "MoneyFrame"]
	local altCurrencyFrame = _G[prefix .. "AltCurrencyFrame"]

	if index > numItems then
		itemButton.price = nil
		itemButton.hasItem = nil
		itemButton:Hide()
		SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5)
		SetItemButtonSlotVertexColor(merchantButton, 0.4, 0.4, 0.4)
		merchantButton.Name:SetText("")
		moneyFrame:Hide()
		altCurrencyFrame:Hide()
		return
	end

	local name, texture, price, quantity, numAvailable, _, extendedCost = GetMerchantItemInfo(index)
	local canUseItem, canPurchase, isAlreadyKnown = GetMerchantItemInfoEx(index)
	merchantButton.Name:SetText(name)
	SetItemButtonCount(itemButton, quantity)
	SetItemButtonStock(itemButton, numAvailable)
	SetItemButtonTexture(itemButton, texture)

	local link = GetMerchantItemLink(index)
	if not link then
		local itemID = GetMerchantItemID(index)
		link = itemID and C_Item.GetItemLinkCache(itemID)
	end

	if link then
		local honorPoints, arenaPoints = GetMerchantItemCostInfo(index)
		local requirementType, requiredRating = C_Item.GetRequiredPVPRating(link, honorPoints, arenaPoints)
		local types = Enum.ItemRequirementType
		if
			requirementType == types.Removed
			or requirementType == types.Battleground and C_PvP.GetRatedBattlegroundRating() >= requiredRating
			or requirementType == types.Arena
				and max(C_PvP.GetArenaRating(1), C_PvP.GetArenaRating(2)) >= requiredRating
		then
			canPurchase = true
		end
	end

	itemButton.price = price
	itemButton.extendedCost = extendedCost and true or nil
	itemButton.link = link
	itemButton.texture = texture

	if extendedCost then
		MerchantFrame_UpdateAltCurrency(index, i)
		altCurrencyFrame:ClearAllPoints()
		if price > 0 then
			MoneyFrame_Update(moneyFrame:GetName(), price)
			altCurrencyFrame:SetPoint("LEFT", moneyFrame, "RIGHT", -14, 0)
			moneyFrame:Show()
		else
			itemButton.price = nil
			altCurrencyFrame:SetPoint("BOTTOMLEFT", prefix .. "NameFrame", "BOTTOMLEFT", 0, 31)
			moneyFrame:Hide()
		end
		altCurrencyFrame:Show()
	else
		MoneyFrame_Update(moneyFrame:GetName(), price)
		altCurrencyFrame:Hide()
		moneyFrame:Show()
	end

	itemButton.Checkmark:SetShown(isAlreadyKnown)
	itemButton.hasItem = true
	itemButton:SetID(index)
	itemButton:Show()

	local unusable = not canUseItem or not canPurchase
	if numAvailable == 0 then
		local c = unusable and 0 or 0.5
		SetItemColors(merchantButton, itemButton, 0.5, c, c, 0.5, c, c, 0.5, c, c)
	elseif unusable then
		SetItemColors(merchantButton, itemButton, 1, 0, 0, 1, 0, 0, 0.9, 0, 0)
	else
		local c = isAlreadyKnown and 0.8 or 1
		SetItemColors(merchantButton, itemButton, 0.5, 0.5, 0.5, 1, 1, 1, c, c, c)
	end
end

function EMP:AnchorBuybackItem()
	_G.MerchantBuyBackItem:ClearAllPoints()
	_G.MerchantBuyBackItem:Point("BOTTOMRIGHT", _G.MerchantFrame, "BOTTOMRIGHT", -7, 33)
end

function EMP:SetupGVS(frame)
	self.gvsReady = true

	if frame.SetNumColumns then
		frame:SetWidth(_G.MerchantFrame:GetWidth() - 21)
		frame:SetNumColumns(self.db.numberOfPages)
	end

	self:AnchorBuybackItem()
end

function EMP:MerchantFrame_UpdateMerchantInfo()
	local gvs = _G.GVSFrame
	if gvs then
		if not self.gvsReady then
			self:SetupGVS(gvs)
		end

		for i = BLIZZARD_BUYBACK_ITEMS_PER_PAGE + 1, self.itemsPerPage do
			_G["MerchantItem" .. i]:Hide()
		end
		return
	end

	local page = _G.MerchantFrame.page
	local numItems = GetMerchantNumItems()
	local offset = (page - 1) * self.itemsPerPage

	for i = page == 1 and BLIZZARD_MERCHANT_ITEMS_PER_PAGE + 1 or 1, self.itemsPerPage do
		UpdateItem(i, offset + i, numItems)
	end

	_G.MerchantItem11:ClearAllPoints()
	_G.MerchantItem11:SetPoint("TOPLEFT", _G.MerchantItem2, "TOPRIGHT", 12, 0)
	for i = BLIZZARD_MERCHANT_ITEMS_PER_PAGE + 1, self.itemsPerPage do
		_G["MerchantItem" .. i]:Show()
	end

	local numPages = ceil(numItems / self.itemsPerPage)
	_G.MerchantPageText:SetFormattedText(_G.MERCHANT_PAGE_NUMBER, page, numPages)

	if numItems > self.itemsPerPage then
		if page >= numPages then
			_G.MerchantNextPageButton:Disable()
		else
			_G.MerchantNextPageButton:Enable()
		end
	else
		_G.MerchantPageText:Hide()
		_G.MerchantPrevPageButton:Hide()
		_G.MerchantNextPageButton:Hide()
	end
end

function EMP:MerchantFrame_UpdateBuybackInfo()
	_G.MerchantItem11:ClearAllPoints()
	_G.MerchantItem11:SetPoint("TOPLEFT", _G.MerchantItem9, "BOTTOMLEFT", 0, -15)

	for i = BLIZZARD_BUYBACK_ITEMS_PER_PAGE + 1, self.itemsPerPage do
		_G["MerchantItem" .. i]:Hide()
	end
end

function EMP:MerchantFrame_CloseStackSplitFrame()
	local owner = _G.StackSplitFrame:IsShown() and _G.StackSplitFrame.owner
	if not owner then
		return
	end

	for i = BLIZZARD_BUYBACK_ITEMS_PER_PAGE + 1, self.itemsPerPage do
		if owner == _G["MerchantItem" .. i .. "ItemButton"] then
			_G.StackSplitFrameCancel_Click()
			return
		end
	end
end

function EMP:Initialize()
	for _, addon in pairs({
		"ExtVendor",
		"Krowi_ExtendedVendorUI",
		"CompactVendor",
	}) do
		if IsAddOnLoaded(addon) then
			self.StopRunning = addon
			return
		end
	end

	if not E.private.WT.item.extendMerchantPages.enable then
		return
	end

	self.db = E.private.WT.item.extendMerchantPages
	self.itemsPerPage = self.db.numberOfPages * BLIZZARD_MERCHANT_ITEMS_PER_PAGE

	_G.MerchantFrame:Width(336 + (self.db.numberOfPages - 1) * 330)

	for i = BLIZZARD_BUYBACK_ITEMS_PER_PAGE + 1, self.itemsPerPage do
		local item = _G["MerchantItem" .. i]
			or CreateFrame("Frame", "MerchantItem" .. i, _G.MerchantFrame, "MerchantItemTemplate")

		item:ClearAllPoints()
		if i % BLIZZARD_MERCHANT_ITEMS_PER_PAGE == 1 then
			item:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - BLIZZARD_MERCHANT_ITEMS_PER_PAGE + 1)], "TOPRIGHT", 12, 0)
		elseif i % 2 == 0 then
			item:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", 12, 0)
		else
			item:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 2)], "BOTTOMLEFT", 0, -8)
		end
	end

	self:AnchorBuybackItem()

	-- Position page navigation buttons relative to the extended frame width
	local buttonOffset = 25 + ((self.db.numberOfPages - 1) * 165) -- Center the buttons in the extended frame

	_G.MerchantPrevPageButton:ClearAllPoints()
	_G.MerchantPrevPageButton:Point("CENTER", _G.MerchantFrame, "BOTTOMLEFT", buttonOffset, 93)
	F.SetFont(_G.MerchantPageText)
	_G.MerchantPageText:ClearAllPoints()
	_G.MerchantPageText:Point("BOTTOM", _G.MerchantFrame, "BOTTOM", 0, 86)
	_G.MerchantNextPageButton:ClearAllPoints()
	_G.MerchantNextPageButton:Point("CENTER", _G.MerchantFrame, "BOTTOMRIGHT", -buttonOffset, 93)

	self:SecureHook("MerchantFrame_UpdateMerchantInfo", "MerchantFrame_UpdateMerchantInfo")
	self:SecureHook("MerchantFrame_UpdateBuybackInfo", "MerchantFrame_UpdateBuybackInfo")
	self:SecureHook("MerchantFrame_CloseStackSplitFrame", "MerchantFrame_CloseStackSplitFrame")

	self.initialized = true
end

function EMP:ProfileUpdate()
	self.db = E.private.WT.item.extendMerchantPages

	if self.db.enable and not self.initialized then
		self:Initialize()
	end
end

W:RegisterModule(EMP:GetName())
