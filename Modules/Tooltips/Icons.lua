local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local T = W.Modules.Tooltips ---@class Tooltips

local _G = _G
local pairs = pairs
local select = select
local strfind = strfind
local tInsertUnique = tInsertUnique
local tonumber = tonumber

local GetAchievementInfo = GetAchievementInfo
local UnitIsPlayer = UnitIsPlayer

local C_Unit_GetFactionInfo = C_Unit.GetFactionInfo

local tooltips = {
	"GameTooltip",
	"ItemRefTooltip",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
	"ElvUI_SpellBookTooltip",
}

local function AddTitleIcon(tt, icon)
	if not icon or not tt:GetName() then
		return
	end
	local row = _G[tt:GetName() .. "TextLeft1"]
	local title = row and row:GetText()
	if not title or strfind(title, "^|T") then
		return
	end
	local db = E.private.WT.tooltips.titleIcon
	row:SetText(F.GetIconString(icon, db.height, db.width, true) .. " " .. title)
end

local function HookIconTooltip(tt)
	if not tt or tt.windIconHooked then
		return
	end
	tt.windIconHooked = true
	tt:HookScript("OnTooltipSetItem", function(tooltip)
		local _, link = tooltip:GetItem()
		AddTitleIcon(tooltip, link and select(10, GetItemInfo(link)))
	end)
	tt:HookScript("OnTooltipSetSpell", function(tooltip)
		local name, _, id = tooltip:GetSpell()
		AddTitleIcon(tooltip, GetSpellTexture(id or name))
	end)
	hooksecurefunc(tt, "SetHyperlink", function(tooltip, link)
		local id = tonumber(link and link:match("^achievement:(%d+)"))
		if id then
			AddTitleIcon(tooltip, select(10, GetAchievementInfo(id)))
		end
	end)
end

function T:AddFactionIcon(tt, unit, guid)
	if UnitIsPlayer(unit) then
		local _, _, faction = C_Unit_GetFactionInfo(unit)
		if faction and faction ~= "Neutral" then
			if not tt.factionFrame then
				local f = tt:CreateTexture(nil, "OVERLAY")
				f:Point("TOPRIGHT", 0, -5)
				f:Size(35)
				f:SetBlendMode("ADD")
				f:SetAlpha(0.5)
				tt.factionFrame = f
			end
			if faction == "Renegade" then
				tt.factionFrame:SetAtlas("bfa-landingbutton-renegade-up")
			else
				tt.factionFrame:SetTexture("Interface\\FriendsFrame\\PlusManz-" .. faction)
				tt.factionFrame:SetTexCoord(0, 1, 0, 1)
			end
			tt.factionFrame:Show()
		end
	end
end

function T:ClearFactionIcon(tt)
	if tt.factionFrame then
		tt.factionFrame:Hide()
	end
end

function T:Icons()
	if E.private.WT.tooltips.titleIcon.enable then
		for _, name in pairs(tooltips) do
			HookIconTooltip(_G[name])
		end
	end

	if E.private.WT.tooltips.factionIcon then
		self:AddInspectInfoCallback(2, "AddFactionIcon", false, "ClearFactionIcon")
	end
end

function T:AddIconTooltip(name)
	tInsertUnique(tooltips, name)
	if self.initialized and E.private.WT.tooltips.titleIcon.enable then
		HookIconTooltip(_G[name])
	end
end

T:AddCallback("Icons")
