local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins
local GH = W:NewModule("GuildFinderHistory")

local _G = _G
local format = format
local ipairs = ipairs
local select = select
local tinsert = tinsert
local tonumber = tonumber
local wipe = wipe
local band, bor, lshift = bit.band, bit.bor, bit.lshift

local CreateFrame = CreateFrame
local GetCVar = GetCVar
local SendServerMessage = SendServerMessage
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local FauxScrollFrame_OnVerticalScroll = FauxScrollFrame_OnVerticalScroll
local FauxScrollFrame_Update = FauxScrollFrame_Update
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel
local C_Timer = C_Timer

local ROW_HEIGHT = 18
local NUM_ROWS = 19
local LOAD_MANY_REQUESTS = 20
local LOAD_MANY_INTERVAL = 0.2

local history, historyByID = {}, {}
local panel

local function PackFlags(value, first, last)
	local flags = 0
	for param = first, last do
		if band(value, lshift(1, param - 1)) ~= 0 then
			flags = bor(flags, lshift(1, param - first))
		end
	end
	return flags
end

local function RequestJoin(guildID, text)
	for i = 1, _G.GetNumRecruitingGuilds() do
		if _G.GetRecruitingGuildID(i) == guildID then
			_G.RequestGuildMembership(i, text)
			return
		end
	end

	local value = tonumber(GetCVar("lfGuildSettings")) or 0
	SendServerMessage(
		"ACMSG_GF_ADD_RECRUIT",
		format(
			"%d|%d|%d|%d|%d|%s",
			PackFlags(value, _G.LFGUILD_PARAM_TANK, _G.LFGUILD_PARAM_DAMAGE),
			PackFlags(value, _G.LFGUILD_PARAM_QUESTS, _G.LFGUILD_PARAM_CASUAL),
			PackFlags(value, _G.LFGUILD_PARAM_WEEKDAYS, _G.LFGUILD_PARAM_WEEKENDS),
			guildID,
			PackFlags(value, _G.LFGUILD_PARAM_MORNING, _G.LFGUILD_PARAM_NIGHT),
			text
		)
	)
end

local function UpdateRows()
	local offset = FauxScrollFrame_GetOffset(panel.scroll)
	for i, row in ipairs(panel.rows) do
		local entry = history[offset + i]
		row.entry = entry
		if entry then
			row.name:SetText(entry.name)
			row.tank:SetShown(entry.tank)
			row.healer:SetShown(entry.healer)
			row.damage:SetShown(entry.damage)
			row:Show()
		else
			row:Hide()
		end
	end

	FauxScrollFrame_Update(panel.scroll, #history, NUM_ROWS, ROW_HEIGHT)
end

local function CollectGuilds()
	for i = 1, _G.GetNumRecruitingGuilds() do
		local guildID = _G.GetRecruitingGuildID(i)
		local name, level, members, comment = _G.GetRecruitingGuildInfo(i)
		if guildID and name then
			local entry = historyByID[guildID]
			if not entry then
				entry = { id = guildID }
				historyByID[guildID] = entry
				tinsert(history, 1, entry)
			end

			entry.name, entry.level, entry.members, entry.comment = name, level, members, comment
			entry.tank, entry.healer, entry.damage = select(_G.LFGUILD_PARAM_TANK, _G.GetRecruitingGuildSettings(i))
		end
	end

	if panel:IsVisible() then
		UpdateRows()
	end
end

local function Row_OnEnter(row)
	local entry = row.entry
	if not entry then
		return
	end

	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	GameTooltip:AddLine(entry.name, 1, 1, 1)
	GameTooltip:AddLine(format(L["Guild Level: %d"], entry.level or 0))
	GameTooltip:AddLine(format(L["Members: %d"], entry.members or 0))
	if entry.comment and entry.comment ~= "" then
		GameTooltip:AddLine(entry.comment, 1, 1, 1, true)
	end
	GameTooltip:AddLine(L["Click to send a join request."], 0.6, 0.6, 0.6)
	GameTooltip:Show()
end

local function Row_OnClick(row)
	local entry = row.entry
	if entry then
		E:StaticPopup_Show("WINDTOOLS_GUILD_FINDER_REQUEST", entry.name, nil, entry.id)
	end
end

local function Row_OnMouseWheel(_, delta)
	if panel.scroll:IsShown() then
		ScrollFrameTemplate_OnMouseWheel(panel.scroll, delta)
	end
end

local function CreateRoleIcon(row, texture, anchor)
	local icon = row:CreateTexture(nil, "OVERLAY")
	icon:Size(ROW_HEIGHT - 2)
	icon:SetTexture(texture)
	if anchor then
		icon:SetPoint("RIGHT", anchor, "LEFT", -1, 0)
	else
		icon:SetPoint("RIGHT", row, "RIGHT", -2, 0)
	end
	return icon
end

local function CreateRow(index)
	local row = CreateFrame("Button", nil, panel)
	row:Height(ROW_HEIGHT)
	row:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -6 - (index - 1) * ROW_HEIGHT)
	row:SetPoint("RIGHT", panel, "RIGHT", -26, 0)
	row:SetHighlightTexture(E.media.blankTex)
	row:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.12)
	row:EnableMouseWheel(true)
	row:SetScript("OnEnter", Row_OnEnter)
	row:SetScript("OnLeave", GameTooltip_Hide)
	row:SetScript("OnClick", Row_OnClick)
	row:SetScript("OnMouseWheel", Row_OnMouseWheel)

	row.damage = CreateRoleIcon(row, E.Media.Textures.DPS)
	row.healer = CreateRoleIcon(row, E.Media.Textures.Healer, row.damage)
	row.tank = CreateRoleIcon(row, E.Media.Textures.Tank, row.healer)

	row.name = row:CreateFontString(nil, "OVERLAY")
	row.name:FontTemplate(nil, 12)
	row.name:SetJustifyH("LEFT")
	row.name:SetPoint("LEFT", 2, 0)
	row.name:SetPoint("RIGHT", row.tank, "LEFT", -4, 0)

	return row
end

local function CreateButton(text, point, x)
	local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button:Size(130, 22)
	button:SetPoint(point, panel, point, x, 6)
	button:SetText(text)
	S:Proxy("HandleButton", button)
	return button
end

function GH:Initialize()
	local finder = _G.LookingForGuildFrame
	if not E.private.WT.social.guildFinderHistory.enable or not finder or not _G.RequestRecruitingGuildsList then
		return
	end

	E.PopupDialogs.WINDTOOLS_GUILD_FINDER_REQUEST = {
		text = L["Send a request to join %s? You can add a note."],
		button1 = _G.ACCEPT,
		button2 = _G.CANCEL,
		hasEditBox = 1,
		editBoxWidth = 260,
		maxLetters = 255,
		OnShow = function(self)
			self.editBox:SetText("")
			self.editBox:SetFocus()
		end,
		OnAccept = function(self, guildID)
			RequestJoin(guildID, self.editBox:GetText())
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	}

	panel = CreateFrame("Frame", "WTGuildFinderHistory", finder)
	panel:Size(300, 400)
	panel:SetPoint("LEFT", finder, "RIGHT", 40, 0)
	panel:SetTemplate("Transparent")
	panel:EnableMouse(true)

	panel.scroll = CreateFrame("ScrollFrame", "WTGuildFinderHistoryScrollFrame", panel, "FauxScrollFrameTemplate")
	panel.scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -6)
	panel.scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -26, 34)
	panel.scroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, UpdateRows)
	end)
	S:Proxy("HandleSirusScrollBar", _G.WTGuildFinderHistoryScrollFrameScrollBar)

	panel.rows = {}
	for i = 1, NUM_ROWS do
		panel.rows[i] = CreateRow(i)
	end

	CreateButton(L["Clear History"], "BOTTOMRIGHT", -6):SetScript("OnClick", function()
		wipe(history)
		wipe(historyByID)
		UpdateRows()
	end)

	local remaining = 0
	CreateButton(L["Load Many"], "BOTTOMLEFT", 6):SetScript("OnClick", function(button)
		if remaining > 0 then
			return
		end

		remaining = LOAD_MANY_REQUESTS
		button:Disable()
		C_Timer:NewTicker(LOAD_MANY_INTERVAL, function()
			remaining = remaining - 1
			_G.RequestRecruitingGuildsList("")
			if remaining <= 0 then
				button:Enable()
			end
		end, LOAD_MANY_REQUESTS)
	end)

	panel:SetScript("OnShow", UpdateRows)
	E:RegisterEventForObject("LF_GUILD_BROWSE_UPDATED", panel, CollectGuilds)
end

W:RegisterModule(GH:GetName())
