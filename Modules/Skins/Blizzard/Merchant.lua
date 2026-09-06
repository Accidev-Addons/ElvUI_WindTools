local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local pairs = pairs

function S:HandleMerchantItem(index)
	for currencyIndex = 1, 2 do
		local itemLine = _G["MerchantItem" .. index .. "AltCurrencyFrameItem" .. currencyIndex]
		if itemLine then
			for _, region in pairs({ itemLine:GetRegions() }) do
				if region:GetObjectType() == "Texture" then
					region:SetTexCoords()
				end
			end
		end
	end
end

function S:MerchantFrame()
	if not self:CheckDB("merchant") then
		return
	end

	self:CreateShadow(_G.MerchantFrame)
	for i = 1, 2 do
		self:CreateBackdropShadow(_G["MerchantFrameTab" .. i])
	end
	for i = 1, 12 do
		self:HandleMerchantItem(i)
	end

	-- [SIRUS] MoneyFrame children use global names, not parent keys.
	local gold = _G.MerchantMoneyFrameGoldButton
	for _, region in pairs({ gold:GetRegions() }) do
		if region:GetObjectType() == "Texture" then
			F.Move(region, 0, 4)
		end
	end
end

S:AddCallback("MerchantFrame")
