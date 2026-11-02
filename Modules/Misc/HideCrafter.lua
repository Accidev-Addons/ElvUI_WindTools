local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local M = W.Modules.Misc ---@class Misc

local _G = _G
local gsub = gsub
local ipairs = ipairs
local strmatch = strmatch

local crafterPattern = "^" .. gsub(_G.ITEM_CREATED_BY, "%%s", ".+") .. "$"

local tooltips = {
	"GameTooltip",
	"ItemRefTooltip",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
}

local function removeCraftInformation(tooltip)
	if not E.db.WT.misc.hideCrafter then
		return
	end

	local tooltipName = tooltip:GetName()
	for lineIndex = tooltip:NumLines(), 1, -1 do
		local line = _G[tooltipName .. "TextLeft" .. lineIndex]
		local text = line and line:GetText()
		if text and strmatch(text, crafterPattern) then
			line:SetText("")
		end
	end
end

function M:HideCrafter()
	for _, tooltipName in ipairs(tooltips) do
		local tooltip = _G[tooltipName]
		if tooltip then
			tooltip:HookScript("OnTooltipSetItem", removeCraftInformation)
		end
	end
end

M:AddCallback("HideCrafter")
