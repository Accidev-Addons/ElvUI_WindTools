local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local AK = W:NewModule("AlreadyKnown", "AceEvent-3.0", "AceHook-3.0") ---@class AlreadyKnown : AceModule, AceEvent-3.0, AceHook-3.0

local _G = _G
local min = min
local select = select
local strfind = strfind

local GetBuybackItemInfo = GetBuybackItemInfo
local GetMerchantItemInfo = GetMerchantItemInfo
local GetMerchantItemInfoEx = GetMerchantItemInfoEx
local GetMerchantNumItems = GetMerchantNumItems
local GetNumBuybackItems = GetNumBuybackItems
local IsAddOnLoaded = IsAddOnLoaded
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor

local BUYBACK_ITEMS_PER_PAGE = BUYBACK_ITEMS_PER_PAGE
local ITEM_SPELL_KNOWN = ITEM_SPELL_KNOWN

local function IsBuybackItemKnown(index)
	local tt = E.ScanTooltip
	tt:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
	tt:SetBuybackItem(index)
	for i = 2, tt:NumLines() do
		local text = _G["ElvUI_ScanTooltipTextLeft" .. i]:GetText()
		if text and strfind(text, ITEM_SPELL_KNOWN, 1, true) then
			tt:Hide()
			return true
		end
	end
	tt:Hide()
end

function AK:Highlight(button, known, unavailable)
	local icon = button and button.icon
	if not icon then
		return
	end

	if not known then
		icon:SetDesaturated(false)
	elseif self.db.mode == "MONOCHROME" then
		icon:SetDesaturated(true)
	else
		local r, g, b = self.db.color.r, self.db.color.g, self.db.color.b
		if unavailable then
			r, g, b = r * 0.5, g * 0.5, b * 0.5
		end
		SetItemButtonTextureVertexColor(button, 0.9 * r, 0.9 * g, 0.9 * b)
	end
end

function AK:Merchant()
	if not self.db.enable then
		return
	end

	local numItems = GetMerchantNumItems()
	for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
		local index = (_G.MerchantFrame.page - 1) * _G.MERCHANT_ITEMS_PER_PAGE + i
		if index > numItems then
			return
		end

		local canUseItem, _, isAlreadyKnown = GetMerchantItemInfoEx(index)
		local numAvailable = select(5, GetMerchantItemInfo(index))
		self:Highlight(_G["MerchantItem" .. i .. "ItemButton"], canUseItem and isAlreadyKnown, numAvailable == 0)
	end
end

function AK:Buyback()
	if not self.db.enable then
		return
	end

	for index = 1, min(GetNumBuybackItems(), BUYBACK_ITEMS_PER_PAGE) do
		local isUsable = select(6, GetBuybackItemInfo(index))
		self:Highlight(_G["MerchantItem" .. index .. "ItemButton"], isUsable and IsBuybackItemKnown(index))
	end
end

function AK:Initialize()
	if IsAddOnLoaded("AlreadyKnown") then
		self.StopRunning = "AlreadyKnown"
		return
	end

	if not E.db.WT.item.alreadyKnown.enable then
		return
	end

	self.db = E.db.WT.item.alreadyKnown
	self.initialized = true
	self:SecureHook("MerchantFrame_UpdateMerchantInfo", "Merchant")
	self:SecureHook("MerchantFrame_UpdateBuybackInfo", "Buyback")
end

function AK:ToggleSetting()
	if IsAddOnLoaded("AlreadyKnown") then
		self.StopRunning = "AlreadyKnown"
		return
	end

	self.db = E.db.WT.item.alreadyKnown

	if self.db.enable and not self.initialized then
		self:Initialize()
	end
end

AK.ProfileUpdate = AK.ToggleSetting

W:RegisterModule(AK:GetName())
