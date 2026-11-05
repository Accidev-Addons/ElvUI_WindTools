local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local TT = E:GetModule("Tooltip")
local DT = E:GetModule("DataTexts")
local S = W.Modules.Skins ---@type Skins

local _G = _G
local pairs = pairs

local function StyleIconsInLine(line)
	if not F.CanAccessWidget(line) then
		return
	end

	local text = line:GetText()
	if not text then
		return
	end

	local styled = S:StyleTextureString(text)
	if styled and styled ~= text then
		F.CallMethod(line, "SetText", styled)
	end
end

function S:StyleIconsInTooltip(tt)
	if not F.CanAccessWidget(tt) or not tt.NumLines or (E.db.general.cropIcon or 0) == 0 then
		return
	end
	local name = tt:GetName()
	if not name then
		return
	end

	for i = 2, tt:NumLines() do
		StyleIconsInLine(_G[name .. "TextLeft" .. i])
		StyleIconsInLine(_G[name .. "TextRight" .. i])
	end
	for i = 1, 30 do
		local texture = _G[name .. "Texture" .. i]
		if not texture or not texture:IsShown() then
			break
		end
		self:TryCropTexture(texture)
	end
end

function S:ReskinTooltip(tt)
	if not F.CanAccessWidget(tt) or tt == E.ScanTooltip or tt.IsEmbedded then
		return
	end

	self:CreateShadow(tt)
	if not self:IsHooked(tt, "Show") then
		self:SecureHook(tt, "Show", "StyleIconsInTooltip")
	end
end

function S:TooltipFrames()
	if not self:CheckDB("tooltip", "tooltips") then
		return
	end

	for _, tt in pairs({
		_G.ItemRefTooltip, _G.ItemRefShoppingTooltip1, _G.ItemRefShoppingTooltip2, _G.ItemRefShoppingTooltip3,
		_G.FriendsTooltip, _G.ConsolidatedBuffsTooltip, _G.GameTooltip, _G.WorldMapTooltip,
		_G.ShoppingTooltip1, _G.ShoppingTooltip2, _G.ShoppingTooltip3,
		_G.WorldMapCompareTooltip1, _G.WorldMapCompareTooltip2, _G.WorldMapCompareTooltip3,
		E.ConfigTooltip, E.SpellBookTooltip, DT.tooltip, _G.LibDBIconTooltip,
	}) do
		self:ReskinTooltip(tt)
	end

	self:SecureHook(TT, "SetStyle", function(_, tt)
		self:ReskinTooltip(tt)
	end)
	self:CreateBackdropShadow(_G.GameTooltipStatusBar)
end

S:AddCallback("TooltipFrames")
