local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local M = W.Modules.Misc ---@class Misc

local _G = _G
local format = format
local ipairs = ipairs
local next = next
local select = select
local strsplit = strsplit
local tonumber = tonumber

local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local hooksecurefunc = hooksecurefunc

local ROW_HEIGHT = 18
local ROW_SPACING = 2
local STAGE_FINISHED = 5
local CONVERTED_ITEMS = { [-1] = 43308, [-2] = 43307 }

local panel, charData

local function RewardKey(itemID, amount, isJackpot)
	return format("%d:%d:%d", itemID, amount or 0, isJackpot and 1 or 0)
end

local function AccountTotals(key)
	local wins, total = 0, 0
	for _, data in next, E.global.WT.misc.rouletteHistory do
		wins = wins + (data[key] or 0)
		total = total + (data.TOTAL or 0)
	end
	return wins, total
end

local function FormatChance(wins, total)
	if wins > 0 and total > 0 then
		return format("%.3f%%", wins / total * 100)
	end
	return "|cffff3333" .. _G.UNKNOWN .. "|r"
end

local function Row_OnEnter(row)
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:" .. row.itemID)

	local wins = charData[row.key] or 0
	GameTooltip:AddDoubleLine(L["Won:"], format(L["%d time(s)"], wins), 1, 1, 1, 1, 1, 1)
	if charData.TOTAL > 0 then
		GameTooltip:AddDoubleLine(L["Win chance:"], FormatChance(wins, charData.TOTAL), 1, 1, 1, 1, 1, 1)
	end

	local accountWins, accountTotal = AccountTotals(row.key)
	if accountTotal > 0 then
		GameTooltip:AddLine(L["All characters:"])
		GameTooltip:AddDoubleLine(L["Won:"], format(L["%d time(s)"], accountWins), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Win chance:"], FormatChance(accountWins, accountTotal), 1, 1, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function CreateText(row, width, anchor)
	local text = row:CreateFontString(nil, "OVERLAY")
	text:FontTemplate(nil, 11)
	text:SetJustifyH("LEFT")
	text:Height(ROW_HEIGHT)
	if width then
		text:Width(width)
	end
	if anchor then
		text:SetPoint("LEFT", anchor, "RIGHT", 3, 0)
	else
		text:SetPoint("LEFT", 4, 0)
	end
	return text
end

local function GetRow(index)
	local row = panel.rows[index]
	if row then
		return row
	end

	row = CreateFrame("Button", nil, panel)
	row:Height(ROW_HEIGHT)
	row:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -24 - (index - 1) * (ROW_HEIGHT + ROW_SPACING))
	row:SetPoint("RIGHT", panel, "RIGHT", -4, 0)
	row:SetTemplate("Transparent")
	row:SetScript("OnEnter", Row_OnEnter)
	row:SetScript("OnLeave", GameTooltip_Hide)

	row.name = CreateText(row, 170)
	row.count = CreateText(row, 30, row.name)
	row.wins = CreateText(row, 40, row.count)
	row.chance = CreateText(row, nil, row.wins)
	row.chance:SetPoint("RIGHT", -4, 0)

	panel.rows[index] = row
	return row
end

local function UpdatePanel()
	local rewards = _G.Custom_RouletteFrame.rewardList
	local numRows = 0

	for _, reward in ipairs(rewards) do
		if reward.itemID and reward.amountMin then
			numRows = numRows + 1

			local row = GetRow(numRows)
			row.itemID = reward.itemID
			row.key = RewardKey(reward.itemID, reward.amountMin, reward.isJackpot)

			local name, link = _G.C_Item.GetItemInfo(reward.itemID)
			row.name:SetText(link or name or reward.itemID)
			row.count:SetText(reward.amountMin > 1 and format("x%d", reward.amountMin) or "")

			local wins = charData[row.key] or 0
			row.wins:SetText(wins)
			row.chance:SetText(FormatChance(wins, charData.TOTAL))
			row:Show()
		end
	end

	for i = numRows + 1, #panel.rows do
		panel.rows[i]:Hide()
	end

	local _, accountTotal = AccountTotals("TOTAL")
	panel.charTotal:SetFormattedText(L["Spins on this character: %d"], charData.TOTAL)
	panel.accountTotal:SetFormattedText(L["Spins on this account: %d"], accountTotal)
	panel:Height(24 + numRows * (ROW_HEIGHT + ROW_SPACING) + 44)
end

local function OnEvent(_, _, prefix, msg, channel, sender)
	if prefix ~= "ASMSG_LOTTERY_REWARD" or channel ~= "UNKNOWN" or sender ~= E.myname or not msg or msg == "" then
		return
	end

	local itemID, amount, isJackpot = strsplit(":", msg)
	itemID = tonumber(itemID)
	if not itemID then
		return
	end

	local key = RewardKey(CONVERTED_ITEMS[itemID] or itemID, tonumber(amount), isJackpot == "1")
	charData[key] = (charData[key] or 0) + 1
	charData.TOTAL = charData.TOTAL + 1
end

function M:RouletteHistory()
	local frame = _G.Custom_RouletteFrame
	if not E.private.WT.misc.rouletteHistory or not frame or select(4, GetAddOnInfo("SirusRouletteHistory")) then
		return
	end

	local db = E.global.WT.misc.rouletteHistory
	charData = db[E.mynameRealm] or {}
	charData.TOTAL = charData.TOTAL or 0
	db[E.mynameRealm] = charData

	panel = CreateFrame("Frame", "WTRouletteHistory", frame)
	panel:Width(320)
	panel:SetPoint("TOPLEFT", frame, "TOPRIGHT", 2, 0)
	panel:SetTemplate("Transparent")
	panel:EnableMouse(true)
	panel:Hide()
	panel.rows = {}

	local title = panel:CreateFontString(nil, "OVERLAY")
	title:FontTemplate(nil, 14)
	title:SetPoint("TOP", 0, -5)
	title:SetText(L["Roulette History"])

	panel.accountTotal = panel:CreateFontString(nil, "OVERLAY")
	panel.accountTotal:FontTemplate(nil, 12)
	panel.accountTotal:SetPoint("BOTTOMLEFT", 6, 6)

	panel.charTotal = panel:CreateFontString(nil, "OVERLAY")
	panel.charTotal:FontTemplate(nil, 12)
	panel.charTotal:SetPoint("BOTTOMLEFT", panel.accountTotal, "TOPLEFT", 0, 4)

	panel:SetScript("OnShow", UpdatePanel)
	panel:RegisterEvent("CHAT_MSG_ADDON")
	panel:SetScript("OnEvent", OnEvent)

	hooksecurefunc(frame, "ChangeStage", function(_, stage)
		if stage == STAGE_FINISHED and panel:IsVisible() then
			UpdatePanel()
		end
	end)

	local toggle = CreateFrame("Button", nil, frame)
	toggle:Size(26)
	toggle:SetNormalTexture([[Interface\PVPFrame\Icons\PVP-Banner-Emblem-47]])
	toggle:SetHighlightTexture(E.media.blankTex)
	toggle:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.15)
	toggle:SetPoint("RIGHT", frame.CloseButton or _G.Custom_RouletteFrameCloseButton, "LEFT", -4, 0)
	toggle:SetScript("OnClick", function()
		panel:SetShown(not panel:IsShown())
	end)
	toggle:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Show/Hide roulette history."])
		GameTooltip:Show()
	end)
	toggle:SetScript("OnLeave", GameTooltip_Hide)
end

M:AddCallback("RouletteHistory")
