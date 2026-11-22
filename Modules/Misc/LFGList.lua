local W, F, E, L, V = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB
local LL = W:NewModule("LFGList", "AceHook-3.0", "AceEvent-3.0") ---@class LFGList : AceModule, AceHook-3.0, AceEvent-3.0
local S = W.Modules.Skins ---@type Skins
local LFGPI = W.Utilities.LFGPlayerInfo
local C = W.Utilities.Color
local LSM = E.Libs.LSM

local _G = _G
local floor = floor
local format = format
local gmatch = gmatch
local ipairs = ipairs
local max = max
local min = min
local pairs = pairs
local select = select
local sort = sort
local strfind = strfind
local strjoin = strjoin
local strlower = strlower
local strtrim = strtrim
local tinsert = tinsert
local tremove = tremove
local wipe = wipe

local AddOrDelIgnore = AddOrDelIgnore
local ChatFrame_SendTell = ChatFrame_SendTell
local CreateFrame = CreateFrame
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local FauxScrollFrame_OnVerticalScroll = FauxScrollFrame_OnVerticalScroll
local FauxScrollFrame_Update = FauxScrollFrame_Update
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local GetItemLevelColor = GetItemLevelColor
local GetNumRaidMembers = GetNumRaidMembers
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetTime = GetTime
local HandleURL = HandleURL
local IsAddOnLoaded = IsAddOnLoaded
local IsIgnored = IsIgnored

local C_Inspect_GetArmoryCharacterLink = C_Inspect.GetArmoryCharacterLink
local C_LFGList_GetApplicantMemberInfo = C_LFGList.GetApplicantMemberInfo
local C_LFGList_GetApplicationInfo = C_LFGList.GetApplicationInfo
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_LFGList_GetSearchResultPlayerInfo = C_LFGList.GetSearchResultPlayerInfo
local C_LFGList_HasActiveEntryInfo = C_LFGList.HasActiveEntryInfo

local lower = utf8 and utf8.lower or strlower

local ACTIVITY_ROW_HEIGHT = 18
local ACTIVITY_ROWS = 11

LL.activityCounts = {}
LL.filterTotal = 0
LL.filterShown = 0
LL.browseKickTime = 0

---Reskins and customizes role icons in LFG (Looking for Group) lists with various visual enhancements.
---When role is nil, the icon and its elements are hidden by setting alpha to 0.
---@param parent Frame? The parent frame that contains the icon. Required for leader indicator and class line features.
---@param icon Texture The texture object representing the role icon to be reskinned.
---@param role "TANK" | "HEALER" | "DAMAGER" | nil The player's role. If nil, the icon will be hidden.
---@param data [ClassFile, string, boolean]? Optional cached data containing [class, specialization, isLeader] information.
function LL:ReskinIcon(parent, icon, role, data)
	local class, spec, isLeader
	if data then
		class, spec, isLeader = data[1], data[2], data[3]
	end

	if role then
		if self.db.icon.reskin then
			-- if not class and spec info, use square style instead
			local pack = self.db.icon.pack
			if pack == "SPEC" and (not class or not spec) then
				pack = "SQUARE"
			end

			if pack == "SQUARE" then
				icon:SetTexture(W.Media.Textures.ROLES)
				icon:SetTexCoord(F.GetRoleTexCoord(role))
			elseif pack == "SPEC" then
				local tex = LFGPI.GetIconTextureWithClassAndSpecName(class, spec)
				icon:SetTexture(tex)
				icon:SetTexCoords()
			else
				icon:SetTexture(W.Media.RoleIcons[pack][role])
				icon:SetTexCoord(0, 1, 0, 1)
			end
		end

		icon:Size(self.db.icon.size)

		if self.db.icon.border and not icon.backdrop then
			icon:CreateBackdrop("Transparent")
		end

		icon:SetAlpha(self.db.icon.alpha)
		if icon.backdrop then
			icon.backdrop:SetAlpha(self.db.icon.alpha)
		end
	else
		icon:SetAlpha(0)
		if icon.backdrop then
			icon.backdrop:SetAlpha(0)
		end
	end

	if parent then
		if self.db.icon.leader then
			if not icon.leader then
				local leader = parent:CreateTexture(nil, "OVERLAY")
				leader:SetTexture(W.Media.Icons.leader)
				leader:Size(10, 8)
				leader:Point("BOTTOM", icon, "TOP", 0, 1)
				icon.leader = leader
			end

			icon.leader:SetShown(isLeader)
		end

		-- Create bar in class color behind
		if class and self.db.line.enable then
			if not icon.line then
				local line = parent:CreateTexture(nil, "ARTWORK")
				line:SetTexture(LSM:Fetch("statusbar", self.db.line.tex) or E.media.normTex)
				line:Size(self.db.line.width, self.db.line.height)
				line:Point("TOP", icon, "BOTTOM", self.db.line.offsetX, self.db.line.offsetY)
				icon.line = line
			end

			local color = E:ClassColor(class, false)
			icon.line:SetVertexColor(color.r, color.g, color.b)
			icon.line:SetAlpha(self.db.line.alpha)
		elseif parent and icon.line then
			icon.line:SetAlpha(0)
		end
	end
end

function LL:UpdateEnumerate(Enumerate, numPlayers)
	local button = Enumerate:GetParent():GetParent()

	if not button.resultID then
		return
	end

	local result = C_LFGList_GetSearchResultInfo(button.resultID)
	if not result then
		return
	end

	if self.db.icon.enable then
		---@type table<string, [ClassFile, string, boolean][]>
		local cache = { TANK = {}, HEALER = {}, DAMAGER = {} }

		for i = 1, result.numMembers do
			local playerInfo = C_LFGList_GetSearchResultPlayerInfo(button.resultID, i)
			if playerInfo and cache[playerInfo.assignedRole] then
				local role, class, spec, isLeader =
					playerInfo.assignedRole, playerInfo.classFilename, playerInfo.specName, playerInfo.isLeader
				tinsert(cache[role], { class, spec, isLeader })
			end
		end

		for i = min(numPlayers or 5, 5), 1, -1 do -- The index of icon starts from right
			local icon = Enumerate["Icon" .. i]
			local roleIcon = icon.RoleIcon
			local classCircle = icon.ClassCircle

			if roleIcon and roleIcon.SetTexture then
				if #cache.TANK > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "TANK", cache.TANK[1])
					tremove(cache.TANK, 1)
				elseif #cache.HEALER > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "HEALER", cache.HEALER[1])
					tremove(cache.HEALER, 1)
				elseif #cache.DAMAGER > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "DAMAGER", cache.DAMAGER[1])
					tremove(cache.DAMAGER, 1)
				else
					self:ReskinIcon(Enumerate, roleIcon)
				end
			end

			if classCircle and self.db.icon.hideDefaultClassCircle then
				classCircle:Hide()
			end
		end
	end
end

function LL:UpdateRoleCount(RoleCount)
	if not self.db.icon.enable then
		return
	end

	if RoleCount.TankIcon then
		self:ReskinIcon(nil, RoleCount.TankIcon, "TANK")
	end
	if RoleCount.HealerIcon then
		self:ReskinIcon(nil, RoleCount.HealerIcon, "HEALER")
	end
	if RoleCount.DamagerIcon then
		self:ReskinIcon(nil, RoleCount.DamagerIcon, "DAMAGER")
	end
end

function LL:UpdateEntry(button)
	local db = self.db.row
	local group = button.resultID and LFGPI:GetGroup(button.resultID)
	if not group then
		return
	end

	local info = button.WTInfo
	if db.info and button.DataDisplay:IsShown() then
		if not info then
			info = button:CreateFontString(nil, "ARTWORK")
			info:SetJustifyH("RIGHT")
			info:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -8, 2)
			button.WTInfo = info
		end

		if info.fontSize ~= db.fontSize then
			info:FontTemplate(nil, db.fontSize, "OUTLINE")
			info.fontSize = db.fontSize
		end

		button.DataDisplay:SetPoint("RIGHT", button, "RIGHT", 0, 6)
		info:SetText(LFGPI:RenderGroup(db.template, group))
		info:Show()
	elseif info then
		info:Hide()
		button.DataDisplay:SetPoint("RIGHT", button, "RIGHT", 0, -1)
	end

	button:SetAlpha(db.dimUnqualified and not group.qualified and 0.5 or 1)

	if db.markIgnored and group.leaderIgnored then
		button.Name:SetTextColor(1, 0.33, 0.33)
	end
end

local function playerMenu(name)
	return {
		{
			text = _G.WHISPER,
			notCheckable = true,
			func = function()
				ChatFrame_SendTell(name)
			end,
		},
		{
			text = _G.WEBSITE_PROFILE or L["Website profile"],
			notCheckable = true,
			disabled = not C_Inspect_GetArmoryCharacterLink(name),
			func = function()
				local url = C_Inspect_GetArmoryCharacterLink(name)
				if url then
					HandleURL(url)
				end
			end,
		},
		{
			text = L["Copy name"],
			notCheckable = true,
			func = function()
				E:StaticPopup_Show("ELVUI_EDITBOX", nil, nil, name)
			end,
		},
		{
			text = IsIgnored(name) and L["Remove from ignore list"] or L["Add to ignore list"],
			notCheckable = true,
			func = function()
				AddOrDelIgnore(name)
			end,
		},
	}
end

function LL:UpdateEntryMenu(resultID)
	if self.menuBusy then
		return
	end

	self.menuBusy = true
	local menu = _G.LFGListUtil_GetSearchEntryMenu(resultID)
	self.menuBusy = false

	for i = #menu, 1, -1 do
		if menu[i].windTools then
			tremove(menu, i)
		end
	end

	local group = self.db.menu.enable and LFGPI:GetGroup(resultID)
	if not group then
		return
	end

	local position = #menu
	local function add(item)
		item.windTools = true
		tinsert(menu, position, item)
		position = position + 1
	end

	if group.leaderName then
		for index, item in ipairs(playerMenu(group.leaderName)) do
			if index > 1 then
				item.text = format("%s: %s", L["Leader"], item.text)
				add(item)
			end
		end
	end

	local members = {}
	for _, member in ipairs(LFGPI:SortMembers(group.members, "ROLE")) do
		members[#members + 1] = {
			text = LFGPI:RenderPlayer(
				"{{roleIcon:14}} {{classColorStart}}{{name}}{{classColorEnd}} {{ilvlColorStart}}{{ilvl}}{{ilvlColorEnd}}",
				member
			),
			notCheckable = true,
			hasArrow = true,
			menuList = playerMenu(member.name),
		}
	end

	if #members > 0 then
		add({ text = L["Members"], notCheckable = true, hasArrow = true, menuList = members })
	end
end

function LL:UpdateApplicantMember(member, appID, memberIdx)
	local db = self.db.applicant
	if not db.enable then
		return
	end

	local name, _, _, _, itemLevel, _, _, _, _, relationship, _, specID, classID =
		C_LFGList_GetApplicantMemberInfo(appID, memberIdx)
	if not name then
		return
	end

	if db.itemLevelColor and itemLevel then
		local color = GetItemLevelColor(itemLevel)
		member.ItemLevel:SetTextColor(color.r, color.g, color.b)
	end

	local icon = db.specIcon and classID and specID and select(4, GetSpecializationInfoForClassID(classID, specID))
	if icon then
		local limit = relationship and 78 or 100
		member.Name:SetWidth(0)
		member.Name:SetText(F.GetIconString(icon, 12, 12) .. " " .. name)
		if member.Name:GetWidth() > limit then
			member.Name:SetWidth(limit)
		end
	end
end

local filterWords = { include = {}, exclude = {} }

local function getWords(kind, text)
	local cache = filterWords[kind]
	if cache.raw ~= text then
		cache.raw = text
		cache.words = {}
		for word in gmatch(lower(text or ""), "[^,;]+") do
			word = strtrim(word)
			if word ~= "" then
				cache.words[#cache.words + 1] = word
			end
		end
	end
	return cache.words
end

local function containsAny(text, words)
	for _, word in ipairs(words) do
		if strfind(text, word, 1, true) then
			return true
		end
	end
	return false
end

local function activityKey(group)
	return group.activity.shortName or group.activity.fullName or ""
end

function LL:PassesFilter(group, db)
	local activity, info = group.activity, group.info

	if select(2, C_LFGList_GetApplicationInfo(group.id)) ~= "none" then
		return true
	end

	if db.hidden[activityKey(group)] then
		return false
	end
	if db.hideSaved and group.saved then
		return false
	end
	if db.hideFull and group.max > 0 and group.free == 0 then
		return false
	end
	if db.hideUnqualified and not group.qualified then
		return false
	end
	if db.hideIgnored and #group.ignored > 0 then
		return false
	end
	if db.onlyFresh and #group.bosses > 0 then
		return false
	end
	if db.onlyFriends and group.friends == 0 then
		return false
	end
	if db.onlyVoice and (info.voiceChat or "") == "" then
		return false
	end
	if db.tank ~= "ANY" and (db.tank == "YES") ~= (group.tanks > 0) then
		return false
	end
	if db.healer ~= "ANY" and (db.healer == "YES") ~= (group.healers > 0) then
		return false
	end
	if db.difficulty ~= "ANY" and (activity.isNormalActivity or activity.isHeroicActivity) then
		if (db.difficulty == "HEROIC") ~= (activity.isHeroicActivity == true) then
			return false
		end
	end
	if db.size ~= 0 and (group.max == 10 or group.max == 25) and group.max ~= db.size then
		return false
	end
	if group.num < db.minMembers then
		return false
	end
	if db.minIlvl > 0 and group.avgIlvl < db.minIlvl then
		return false
	end
	if db.maxAge > 0 and (info.age or 0) > db.maxAge * 60 then
		return false
	end

	local include, exclude = getWords("include", db.include), getWords("exclude", db.exclude)
	if #include > 0 or #exclude > 0 then
		local text = lower(strjoin(" ", info.name or "", info.comment or "", info.raidRules or "", activity.fullName or ""))
		if #include > 0 and not containsAny(text, include) then
			return false
		end
		if containsAny(text, exclude) then
			return false
		end
	end

	return true
end

local sorters = {
	NEWEST = function(a, b)
		return (a.info.age or 0) < (b.info.age or 0)
	end,
	MEMBERS = function(a, b)
		return a.num > b.num
	end,
	FREE = function(a, b)
		return a.free < b.free
	end,
	ILVL = function(a, b)
		return a.avgIlvl > b.avgIlvl
	end,
	REQUIREMENT = function(a, b)
		return a.reqIlvl < b.reqIlvl
	end,
	BOSSES = function(a, b)
		return #a.bosses < #b.bosses
	end,
	ACTIVITY = function(a, b)
		return (a.activity.fullName or "") < (b.activity.fullName or "")
	end,
}

function LL:FilterResults(results)
	local db = self.db.filter
	self.filterTotal, self.filterShown = #results, #results
	wipe(self.activityCounts)

	if not db.enable then
		return
	end

	local groups = {}
	for i = #results, 1, -1 do
		local id = results[i]
		local group = LFGPI:GetGroup(id)
		groups[id] = group
		if group then
			local key = activityKey(group)
			self.activityCounts[key] = (self.activityCounts[key] or 0) + 1
			if db.active and not self:PassesFilter(group, db) then
				tremove(results, i)
			end
		end
	end

	local compare = db.active and sorters[db.sort]
	if compare then
		local reverse = db.reverse
		sort(results, function(x, y)
			local a, b = groups[x], groups[y]
			if not a or not b then
				return x < y
			end
			if reverse then
				a, b = b, a
			end
			if compare(a, b) then
				return true
			elseif compare(b, a) then
				return false
			end
			return x < y
		end)
	end

	self.filterShown = #results

	local searchPanel = _G.LFGListFrame.SearchPanel
	local selected = searchPanel.selectedResult
	if selected then
		local found
		for _, id in ipairs(results) do
			if id == selected then
				found = true
				break
			end
		end
		if not found then
			searchPanel.selectedResult = nil
		end
	end

	self:UpdateFilterStatus()
end

function LL:RefreshResults()
	local searchPanel = _G.LFGListFrame and _G.LFGListFrame.SearchPanel
	if searchPanel and searchPanel:IsVisible() and not searchPanel.searching then
		_G.LFGListSearchPanel_UpdateResultList(searchPanel)
	end
end

function LL:UpdateFilterStatus()
	local button = self.filterButton
	if not button then
		return
	end

	local hidden = self.filterTotal - self.filterShown
	button:SetText(hidden > 0 and format("%s (-%d)", L["Filter"], hidden) or L["Filter"])

	local panel = self.filterPanel
	if panel and panel:IsShown() then
		panel.Status:SetText(format(L["Shown %d of %d"], self.filterShown, self.filterTotal))
		panel:UpdateActivities()
	end
end

local function setTooltip(frame, title, text)
	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(title, 1, 1, 1)
		if text then
			GameTooltip:AddLine(text, nil, nil, nil, true)
		end
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", GameTooltip_Hide)
end

function LL:CreateFilterPanel()
	local db = self.db.filter
	local parent = _G.LFDParentFrame
	local panel = CreateFrame("Frame", "WTLFGListFilterPanel", _G.LFGListFrame.SearchPanel)
	panel:Size(456, parent:GetHeight())
	panel:Point("TOPLEFT", parent, "TOPRIGHT", 5, 0)
	panel:SetTemplate("Transparent")
	panel:EnableMouse(true)
	S:CreateShadow(panel)
	panel.widgets = {}
	self.filterPanel = panel

	local function label(text, x, y, template)
		local fontString = panel:CreateFontString(nil, "ARTWORK", template or "GameFontHighlightSmall")
		fontString:Point("TOPLEFT", panel, "TOPLEFT", x, y)
		fontString:SetText(text)
		F.SetFont(fontString)
		return fontString
	end

	local function changed()
		if not panel.updating then
			LL:RefreshResults()
		end
	end

	local function check(key, text, tip, x, y)
		local button = CreateFrame("CheckButton", "WTLFGListFilter" .. key, panel, "UICheckButtonTemplate")
		button:Size(20)
		button:Point("TOPLEFT", panel, "TOPLEFT", x, y)
		button.text:SetText(text)
		button.text:SetTextColor(1, 1, 1)
		F.SetFont(button.text)
		button:SetHitRectInsets(0, -170, 0, 0)
		S:Proxy("HandleCheckBox", button)
		button:SetScript("OnClick", function(self)
			db[key] = self:GetChecked() and true or false
			changed()
		end)
		setTooltip(button, text, tip)
		panel.widgets[#panel.widgets + 1] = function()
			button:SetChecked(db[key])
		end
		return button
	end

	local function dropdown(key, text, tip, options, x, y)
		local title = label(text, x, y - 6)
		local button = CreateFrame("Button", "WTLFGListFilter" .. key, panel, "WowStyle1DropdownTemplate")
		button:Point("TOPLEFT", panel, "TOPLEFT", x + 84, y)
		S:Proxy("HandleDropDownBox", button, 126)
		button:SetupMenu(function(_, root)
			for _, option in ipairs(options) do
				root:CreateRadio(option[2], function()
					return db[key] == option[1]
				end, function()
					db[key] = option[1]
					changed()
				end, option[1])
			end
		end)
		setTooltip(button, text, tip)
		panel.widgets[#panel.widgets + 1] = function()
			button:GenerateMenu()
		end
		return button, title
	end

	local function slider(key, text, tip, minValue, maxValue, step, x, y)
		local frame = CreateFrame("Slider", "WTLFGListFilter" .. key, panel)
		frame:Size(206, 12)
		frame:Point("TOPLEFT", panel, "TOPLEFT", x, y - 16)
		frame:SetOrientation("HORIZONTAL")
		frame:SetMinMaxValues(minValue, maxValue)
		frame:SetValueStep(step)
		frame:EnableMouseWheel(true)
		S:Proxy("HandleSliderFrame", frame)
		frame.Text = label("", x, y)

		local function update()
			local value = db[key]
			frame.Text:SetText(format("%s: %s", text, value > 0 and C.StringByTemplate(value, "blue-400") or L["Any"]))
		end

		frame:SetScript("OnValueChanged", function(_, value)
			value = floor(value / step + 0.5) * step
			if value ~= db[key] then
				db[key] = value
				update()
				changed()
			end
		end)
		frame:SetScript("OnMouseWheel", function(self, delta)
			self:SetValue(self:GetValue() + delta * step)
		end)
		setTooltip(frame, text, tip)
		panel.widgets[#panel.widgets + 1] = function()
			frame:SetValue(db[key])
			update()
		end
		return frame
	end

	local function edit(key, text, tip, x, y)
		label(text, x, y)
		local box = CreateFrame("EditBox", "WTLFGListFilter" .. key, panel, "InputBoxTemplate")
		box:SetAutoFocus(false)
		box:Size(204, 18)
		box:Point("TOPLEFT", panel, "TOPLEFT", x + 2, y - 15)
		S:Proxy("HandleEditBox", box)
		box:SetScript("OnEnterPressed", box.ClearFocus)
		box:SetScript("OnEscapePressed", box.ClearFocus)
		box:SetScript("OnTextChanged", function(self)
			local value = self:GetText()
			if value ~= db[key] then
				db[key] = value
				changed()
			end
		end)
		setTooltip(box, text, tip)
		panel.widgets[#panel.widgets + 1] = function()
			box:SetText(db[key])
		end
		return box
	end

	local function button(text, width, onClick)
		local frame = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		frame:Size(width, 20)
		frame:SetText(text)
		S:Proxy("HandleButton", frame)
		frame:SetScript("OnClick", onClick)
		return frame
	end

	label(W.Title .. " - " .. L["Filter"], 10, -10, "GameFontNormal")

	panel.Status = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	panel.Status:Point("TOPRIGHT", panel, "TOPRIGHT", -34, -12)
	F.SetFont(panel.Status)

	local close = CreateFrame("Button", "WTLFGListFilterClose", panel, "UIPanelCloseButton")
	close:Point("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
	S:Proxy("HandleCloseButton", close)
	close:SetScript("OnClick", function()
		LL:ToggleFilterPanel()
	end)

	local left, right = 10, 238
	local anyYesNo = { { "ANY", L["Any"] }, { "YES", L["Present"] }, { "NO", L["Absent"] } }

	check("active", L["Filter enabled"], L["Turn every filter and the sort order on or off without losing the settings."], left, -32)
	check("hideSaved", L["Hide saved instances"], L["Hide groups for instances you are already saved to."], left, -54)
	check("hideFull", L["Hide full groups"], L["Hide groups with no free slots."], left, -74)
	check("hideUnqualified", L["Hide groups above my item level"], L["Hide groups whose required item level is higher than yours."], left, -94)
	check("hideIgnored", L["Hide groups with ignored players"], L["Hide groups that contain a player from your ignore list."], left, -114)
	check("onlyFresh", L["Only fresh runs"], L["Show only groups with no defeated bosses."], left, -134)
	check("onlyFriends", L["Only with friends or guild"], L["Show only groups with your friends or guild members."], left, -154)
	check("onlyVoice", L["Only with voice chat"], L["Show only groups that list a voice chat."], left, -174)

	dropdown("tank", L["Tank"], L["Whether the group already has a tank."], anyYesNo, left, -200)
	dropdown("healer", L["Healer"], L["Whether the group already has a healer."], anyYesNo, left, -226)
	dropdown("difficulty", L["Difficulty"], L["Raid or dungeon difficulty."], {
		{ "ANY", L["Any"] },
		{ "NORMAL", L["Normal"] },
		{ "HEROIC", L["Heroic"] },
	}, left, -252)
	dropdown("size", L["Size"], L["Raid size."], { { 0, L["Any"] }, { 10, "10" }, { 25, "25" } }, left, -278)

	slider("minMembers", L["Minimum members"], L["Hide groups with fewer members."], 0, 25, 1, left, -310)
	slider("minIlvl", L["Minimum average item level"], L["Hide groups whose average item level is lower."], 0, 300, 5, left, -348)
	slider("maxAge", L["Maximum age (minutes)"], L["Hide groups listed longer ago."], 0, 120, 5, left, -386)

	dropdown("sort", L["Sort"], L["Order of the group list."], {
		{ "DEFAULT", L["Default"] },
		{ "NEWEST", L["Newest first"] },
		{ "MEMBERS", L["Most members"] },
		{ "FREE", L["Fewest free slots"] },
		{ "ILVL", L["Highest average item level"] },
		{ "REQUIREMENT", L["Lowest required item level"] },
		{ "BOSSES", L["Fewest defeated bosses"] },
		{ "ACTIVITY", L["Activity name"] },
	}, right, -32)
	check("reverse", L["Reverse order"], L["Reverse the chosen sort order."], right, -58)

	local wordsTip = L["Words are separated by commas. The group name, comment, rules and activity name are searched."]
	edit("include", L["Must contain any of the words"], wordsTip, right, -84)
	edit("exclude", L["Must not contain the words"], wordsTip, right, -124)

	label(L["Activities in the list"], right, -168)

	local rows = {}
	local names = {}
	local scroll = CreateFrame("ScrollFrame", "WTLFGListFilterActivityScroll", panel, "FauxScrollFrameTemplate")
	scroll:Point("TOPLEFT", panel, "TOPLEFT", right, -184)
	scroll:Size(186, ACTIVITY_ROW_HEIGHT * ACTIVITY_ROWS)
	S:Proxy("HandleSirusScrollBar", _G.WTLFGListFilterActivityScrollScrollBar)

	function panel:UpdateActivities()
		wipe(names)
		for name in pairs(LL.activityCounts) do
			names[#names + 1] = name
		end
		for name in pairs(db.hidden) do
			if not LL.activityCounts[name] then
				names[#names + 1] = name
			end
		end
		sort(names)

		FauxScrollFrame_Update(scroll, #names, ACTIVITY_ROWS, ACTIVITY_ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(scroll)
		for i, row in ipairs(rows) do
			local name = names[i + offset]
			if name then
				row.name = name
				row:SetChecked(not db.hidden[name])
				row.text:SetText(format("%s |cff999999(%d)|r", name, LL.activityCounts[name] or 0))
				row:Show()
			else
				row:Hide()
			end
		end
	end

	scroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ACTIVITY_ROW_HEIGHT, function()
			panel:UpdateActivities()
		end)
	end)

	for i = 1, ACTIVITY_ROWS do
		local row = CreateFrame("CheckButton", "WTLFGListFilterActivity" .. i, panel, "UICheckButtonTemplate")
		row:Size(ACTIVITY_ROW_HEIGHT)
		row:Point("TOPLEFT", scroll, "TOPLEFT", 0, -(i - 1) * ACTIVITY_ROW_HEIGHT)
		row.text:SetTextColor(1, 1, 1)
		row.text:SetWidth(164)
		row.text:SetHeight(ACTIVITY_ROW_HEIGHT)
		row.text:SetJustifyH("LEFT")
		F.SetFont(row.text)
		row:SetHitRectInsets(0, -164, 0, 0)
		S:Proxy("HandleCheckBox", row)
		row:SetScript("OnClick", function(self)
			db.hidden[self.name] = not self:GetChecked() and true or nil
			changed()
		end)
		rows[i] = row
	end

	local all = button(L["All"], 66, function()
		wipe(db.hidden)
		changed()
	end)
	all:Point("TOPLEFT", scroll, "BOTTOMLEFT", 0, -6)

	local none = button(L["None"], 66, function()
		for name in pairs(LL.activityCounts) do
			db.hidden[name] = true
		end
		changed()
	end)
	none:Point("LEFT", all, "RIGHT", 4, 0)

	local reset = button(L["Reset"], 66, function()
		wipe(db.hidden)
		E:CopyTable(db, V.misc.lfgList.filter)
		db.panelShown = true
		panel:UpdateWidgets()
		LL:RefreshResults()
	end)
	reset:Point("LEFT", none, "RIGHT", 4, 0)
	setTooltip(reset, L["Reset"], L["Reset every filter to its default value."])

	function panel:UpdateWidgets()
		self.updating = true
		for _, update in ipairs(self.widgets) do
			update()
		end
		self.updating = false
		LL:UpdateFilterStatus()
	end

	panel:SetScript("OnShow", panel.UpdateWidgets)
	panel:UpdateWidgets()

	return panel
end

function LL:ToggleFilterPanel()
	local db = self.db.filter
	local panel = self.filterPanel or self:CreateFilterPanel()
	db.panelShown = not db.panelShown
	panel:SetShown(db.panelShown)
end

function LL:UpdateFilterButton()
	local db = self.db.filter
	local searchPanel = _G.LFGListFrame and _G.LFGListFrame.SearchPanel
	if not searchPanel then
		return
	end

	local button = self.filterButton
	if db.enable and not button then
		button = CreateFrame("Button", "WTLFGListFilterButton", searchPanel, "UIPanelButtonTemplate")
		button:Size(88, 22)
		button:Point("RIGHT", searchPanel.RefreshButton, "LEFT", -4, 0)
		button:SetText(L["Filter"])
		S:Proxy("HandleButton", button)
		button:SetScript("OnClick", function()
			LL:ToggleFilterPanel()
		end)
		setTooltip(button, L["Filter"], L["Open the WindTools filter and sort panel."])
		self.filterButton = button

		if db.panelShown then
			self:CreateFilterPanel():Show()
		end
	end

	if button then
		button:SetShown(db.enable)
	end
	if self.filterPanel then
		self.filterPanel:SetShown(db.enable and db.panelShown)
	end
end

function LL:KeepBrowsing(frame)
	if not self.browsing then
		return
	end

	if not C_LFGList_HasActiveEntryInfo() then
		self.browsing = nil
	elseif frame.activePanel == frame.ApplicationViewer then
		local now = GetTime()
		if now - self.browseKickTime < 0.3 then
			self.browsing = nil
			return
		end
		self.browseKickTime = now
		_G.LFGListFrame_SetActivePanel(frame, frame.SearchPanel)
	end
end

function LL:UpdateBrowseButtons()
	if not self.db.browseWhileListed or not C_LFGList_HasActiveEntryInfo() then
		return
	end

	local frame = _G.LFGListFrame
	local button = frame.SearchPanel.BackToGroupButton
	button:SetText(GetNumRaidMembers() > 0 and L["Return to my raid"] or L["Return to my group"])
	button:SetWidth(max(144, button:GetTextWidth() + 24))
	button:Show()
	frame.SearchPanel.BackButton:Hide()
	frame.ApplicationViewer.BrowseGroupsButton:Show()
end

function LL:Refresh()
	if not self.initialized then
		return
	end

	self:UpdateFilterButton()
	self:RefreshResults()
end

function LL:Initialize()
	if IsAddOnLoaded("PremadeGroupsFilter") then
		self.StopRunning = L["Premade Groups Filter"]
		return
	end

	self.db = E.private.WT.misc.lfgList
	if not self.db.enable or not _G.LFGListFrame then
		return
	end

	self:SecureHook("LFGListGroupDataDisplayEnumerate_Update", "UpdateEnumerate")
	self:SecureHook("LFGListGroupDataDisplayRoleCount_Update", "UpdateRoleCount")
	self:SecureHook("LFGListSearchEntry_Update", "UpdateEntry")
	self:SecureHook("LFGListUtil_SortSearchResults", "FilterResults")
	self:SecureHook("LFGListUtil_GetSearchEntryMenu", "UpdateEntryMenu")
	self:SecureHook("LFGListApplicationViewer_UpdateApplicantMember", "UpdateApplicantMember")
	self:SecureHook("LFGListFrame_FixPanelValid", "KeepBrowsing")
	self:SecureHook("LFGListApplicationViewer_UpdateInfo", "UpdateBrowseButtons")
	self:SecureHook("LFGListSearchPanel_UpdateButtonStatus", "UpdateBrowseButtons")

	local frame = _G.LFGListFrame
	frame.ApplicationViewer.BrowseGroupsButton:HookScript("OnClick", function()
		self.browsing = self.db.browseWhileListed
	end)
	frame.SearchPanel.BackToGroupButton:HookScript("OnClick", function()
		self.browsing = nil
	end)
	frame:HookScript("OnHide", function()
		self.browsing = nil
	end)

	self.initialized = true
	self:UpdateFilterButton()
end

W:RegisterModule(LL:GetName())
