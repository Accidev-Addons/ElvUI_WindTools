local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local T = W.Modules.Tooltips
local LFGPI = W.Utilities.LFGPlayerInfo

local C = W.Utilities.Color

local _G = _G
local format = format
local gsub = gsub
local ipairs = ipairs

local IsAddOnLoaded = IsAddOnLoaded
local SecondsToTime = SecondsToTime
local UnitIsGroupLeader = UnitIsGroupLeader

local C_CategorySpell_GetCategoryInfo = C_CategorySpell.GetCategoryInfo
local C_LFGList_GetLootMethodString = C_LFGList.GetLootMethodString
local C_LFGList_GetPlaystyleString = C_LFGList.GetPlaystyleString
local C_LFGList_GetRaidRulesString = C_LFGList.GetRaidRulesString

local LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE = LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE

local function addBlank(_, state)
	state.gap = true
end

local function flushGap(tooltip, state)
	if state.gap then
		tooltip:AddLine(" ")
		state.gap = false
	end
end

local function addLine(tooltip, state, text, r, g, b, wrap)
	if text and text ~= "" then
		flushGap(tooltip, state)
		tooltip:AddLine(text, r, g, b, wrap)
	end
end

local function addDoubleLine(tooltip, state, left, right)
	flushGap(tooltip, state)
	tooltip:AddDoubleLine(left, right, 1, 1, 1, 1, 1, 1)
end

local function colorRequirement(text, passed)
	return (gsub(text, "|c[fF][fF][fF][fF][fF][fF][fF][fF]", passed and "|cff55ff55" or "|cffff5555", 1))
end

local function addMembers(tooltip, state, db, group)
	if db.memberMode ~= "COMPOSITION" then
		local lastRole
		for _, member in ipairs(LFGPI:SortMembers(group.members, db.roleHeaders and "ROLE" or db.sortBy)) do
			if db.roleHeaders and member.role ~= lastRole then
				lastRole = member.role
				addBlank(tooltip, state)
				addLine(tooltip, state, LFGPI:RenderPlayer("{{roleIcon:14}} {{roleColorStart}}{{roleName}}{{roleColorEnd}}", member))
			end

			addLine(tooltip, state, LFGPI:RenderPlayer(db.playerTemplate, member), 1, 1, 1)
		end
	end

	if db.memberMode ~= "PLAYERS" then
		if db.memberMode == "BOTH" then
			addBlank(tooltip, state)
		end

		local composition = LFGPI:GetComposition(group)
		for _, role in ipairs(LFGPI:GetRoleOrder()) do
			for _, entry in ipairs(composition[role]) do
				addLine(tooltip, state, LFGPI:RenderPlayer("{{roleIcon:14}} " .. db.template, entry), 1, 1, 1)
			end
		end
	end
end

function T:AddGroupInfo(tooltip, resultID, autoAcceptOption)
	local db = E.db.WT.tooltips.groupInfo
	if not db or not db.enable then
		return
	end

	if db.excludeDungeon and LFGPI:IsIDDungeons(resultID) then
		return
	end

	local group = LFGPI:GetGroup(resultID)
	if not group then
		return
	end

	local info, activity, show = group.info, group.activity, db.sections
	local state = { gap = false }

	LFGPI:SetClassIconStyle(db.classIconStyle)

	tooltip:ClearLines()
	tooltip:SetText(info.name, 1, 1, 1, true)

	if db.title then
		addLine(tooltip, state, W.Title .. " " .. L["Party Info"])
	end

	if show.activity then
		addLine(tooltip, state, activity.fullName)
	end

	if show.header then
		addLine(tooltip, state, LFGPI:RenderGroup(db.headerTemplate, group), 1, 1, 1)
	end

	if show.playstyle and info.playstyle and info.playstyle > 0 then
		addLine(tooltip, state, C_LFGList_GetPlaystyleString(info.playstyle, activity), 0.1, 1, 0.1)
	end

	if show.comment then
		local comment = info.comment
		if (not comment or comment == "") and info.questID then
			comment = _G.LFGListUtil_GetQuestDescription(info.questID)
		end
		if comment and comment ~= "" then
			addLine(tooltip, state, format(_G.LFG_LIST_COMMENT_FORMAT, comment), 0.6, 0.6, 0.6, true)
		end
	end

	if show.rules and info.raidRules and info.raidRules ~= "" then
		addBlank(tooltip, state)
		addLine(tooltip, state, _G.LFG_LIST_RAID_RULES)
		addLine(tooltip, state, C_LFGList_GetRaidRulesString(info.raidRules), 1, 1, 1, true)
	end

	if show.loot and info.lootMethod then
		addBlank(tooltip, state)
		addLine(tooltip, state, _G.LFG_LIST_LOOT_METHOD_LABEL)
		addLine(tooltip, state, C_LFGList_GetLootMethodString(info.lootMethod), 1, 1, 1, true)
	end

	addBlank(tooltip, state)

	if show.requirements then
		if info.requiredDungeonScore and info.requiredDungeonScore > 0 then
			addLine(tooltip, state, format(_G.GROUP_FINDER_MYTHIC_RATING_REQ_TOOLTIP, info.requiredDungeonScore))
		end
		if group.reqIlvl > 0 then
			local text = format(_G.LFG_LIST_TOOLTIP_ILVL, group.reqIlvl)
			if db.highlightRequirements then
				text = colorRequirement(text, group.qualified)
			end
			addLine(tooltip, state, text)
		end
		if info.categorySpell and info.categorySpell > 0 then
			addLine(tooltip, state, format(_G.LFG_LIST_TOOLTIP_CATEGORY_SPELL, (C_CategorySpell_GetCategoryInfo(info.categorySpell)) or ""))
		end
	end

	if show.voice and info.voiceChat and info.voiceChat ~= "" then
		addLine(tooltip, state, format(_G.LFG_LIST_TOOLTIP_VOICE_CHAT, info.voiceChat), nil, nil, nil, true)
	end

	addBlank(tooltip, state)

	if show.leader and group.leaderName then
		local leader = format("%s: %s", L["Leader"], LFGPI:RenderGroup("{{leaderName}}", group))
		if group.leaderScore then
			local score = LFGPI:RenderGroup("{{leaderScoreColorStart}}{{leaderScore}}{{leaderScoreColorEnd}}", group)
			addDoubleLine(tooltip, state, leader, "M+ " .. score)
		else
			addLine(tooltip, state, leader)
		end
	end

	if show.age and info.age and info.age > 0 then
		addLine(tooltip, state, format(_G.LFG_LIST_TOOLTIP_AGE, SecondsToTime(info.age, false, false, 1, false)))
	end

	addBlank(tooltip, state)

	if show.members then
		if activity.displayType ~= _G.Enum.LFGListDisplayType.HideAll then
			addLine(tooltip, state, _G.MEMBERS_COLON)
			addMembers(tooltip, state, db, group)
		else
			addLine(tooltip, state, format(_G.LFG_LIST_TOOLTIP_MEMBERS, group.num, group.tanks, group.healers, group.dps))
		end
	end

	if show.missing and group.num >= 5 then
		local missing = LFGPI:RenderGroup("{{missing:14}}", group)
		if missing ~= "" then
			addBlank(tooltip, state)
			addLine(tooltip, state, L["Missing classes"] .. ": " .. missing)
		end
	end

	if show.friends and group.friends > 0 then
		addBlank(tooltip, state)
		addLine(tooltip, state, _G.LFG_LIST_TOOLTIP_FRIENDS_IN_GROUP)
		addLine(tooltip, state, _G.LFGListSearchEntryUtil_GetFriendList(resultID), 1, 1, 1, true)
	end

	if show.ignored and #group.ignored > 0 then
		addBlank(tooltip, state)
		addLine(tooltip, state, L["Ignored players in the group"] .. ": " .. LFGPI:RenderGroup("{{ignored}}", group), 1, 0.33, 0.33, true)
	end

	if show.bosses and #group.bosses > 0 then
		addBlank(tooltip, state)
		addLine(tooltip, state, _G.LFG_LIST_BOSSES_DEFEATED)
		for _, boss in ipairs(group.bosses) do
			addLine(tooltip, state, boss, 1, 0.1, 0.1)
		end
	end

	if show.autoAccept and info.autoAccept and (autoAcceptOption or LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE) == LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE then
		addBlank(tooltip, state)
		addLine(tooltip, state, _G.LFG_LIST_TOOLTIP_AUTO_ACCEPT, 0.5, 0.5, 1)
	end

	if info.isDelisted then
		addBlank(tooltip, state)
		addLine(tooltip, state, _G.LFG_LIST_ENTRY_DELISTED, 1, 0.1, 0.1, true)
	end

	if show.saved and group.saved and not UnitIsGroupLeader("player") then
		addBlank(tooltip, state)
		addLine(tooltip, state, _G.LFG_LIST_ENTRY_SAVED_INSTANCE, 0.5, 0.5, 0.5, true)
	end

	tooltip:Show()
end

function T:GroupInfo()
	if IsAddOnLoaded("PremadeGroupsFilter") and E.db.WT.tooltips.groupInfo.enable then
		F.Print(
			format(
				L["%s detected, %s will be disabled automatically."],
				C.StringByTemplate(L["Premade Groups Filter"], "yellow-400"),
				C.StringByTemplate(L["Tooltips"] .. " - " .. L["Group Info"], "sky-400")
			)
		)
		E.db.WT.tooltips.groupInfo.enable = false
	end

	self:SecureHook("LFGListUtil_SetSearchEntryTooltip", "AddGroupInfo")
end

T:AddCallback("GroupInfo")
