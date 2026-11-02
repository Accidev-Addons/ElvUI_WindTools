local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local TI = W:NewModule("TurnIn", "AceEvent-3.0") ---@class TurnIn: AceModule, AceEvent-3.0

local _G = _G
local format = format
local select = select
local strfind = strfind
local strlen = strlen
local strmatch = strmatch
local strsub = strsub
local strupper = strupper
local tonumber = tonumber

local AcceptQuest = AcceptQuest
local CloseQuest = CloseQuest
local CompleteQuest = CompleteQuest
local ConfirmAcceptQuest = ConfirmAcceptQuest
local GetActiveTitle = GetActiveTitle
local GetAvailableQuestInfo = GetAvailableQuestInfo
local GetAvailableTitle = GetAvailableTitle
local GetGossipActiveQuests = GetGossipActiveQuests
local GetGossipAvailableQuests = GetGossipAvailableQuests
local GetGossipOptions = GetGossipOptions
local GetItemInfo = GetItemInfo
local GetNumActiveQuests = GetNumActiveQuests
local GetNumAvailableQuests = GetNumAvailableQuests
local GetNumQuestChoices = GetNumQuestChoices
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestMoneyToGet = GetQuestMoneyToGet
local GetQuestReward = GetQuestReward
local GetTitleText = GetTitleText
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsModifierKeyDown = IsModifierKeyDown
local IsQuestCompletable = IsQuestCompletable
local IsShiftKeyDown = IsShiftKeyDown
local QuestFlagsPVP = QuestFlagsPVP
local QuestGetAutoAccept = QuestGetAutoAccept
local QuestInfoItem_OnClick = QuestInfoItem_OnClick
local QuestIsDaily = QuestIsDaily
local QuestIsWeekly = QuestIsWeekly
local SelectActiveQuest = SelectActiveQuest
local SelectAvailableQuest = SelectAvailableQuest
local SelectGossipActiveQuest = SelectGossipActiveQuest
local SelectGossipAvailableQuest = SelectGossipAvailableQuest
local StaticPopup_Hide = StaticPopup_Hide
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitPlayerControlled = UnitPlayerControlled

local MAX_NUM_ITEMS = MAX_NUM_ITEMS

local SKIP_STRING = "^.+|cFFFF0000<.+>|r"

local choiceQueued = false
local repeatableQuests = {}

local ignoreQuestNPC = {
	[4311] = true, -- 霍加尔·雷斧
	[14847] = true, -- 萨杜斯·帕雷教授
}

local cashRewards = {
	[45724] = 1e5, -- 冠军的钱包
}

---@param title string?
---@return boolean
local function IsRepeatableQuest(title)
	if not title then
		return false
	end

	if repeatableQuests[title] then
		return true
	end

	for index = 1, GetNumQuestLogEntries() do
		local questTitle, _, _, _, isHeader, _, _, isDaily = GetQuestLogTitle(index)
		if not isHeader and questTitle == title then
			return isDaily and true or false
		end
	end

	return false
end

---@return boolean
local function IsRepeatableQuestFrame()
	return QuestIsDaily() or QuestIsWeekly() or IsRepeatableQuest(GetTitleText())
end

---@param isRepeatable any
---@return boolean
function TI:EnableOnQuest(isRepeatable)
	if not self.db or not self.db.enableCondition then
		return true
	end

	if isRepeatable and self.db.enableCondition.repeatable then
		return true
	end

	return self.db.enableCondition.other
end

function TI:GetNPCID(unit)
	local guid = UnitGUID(unit or "npc")
	local unitType = guid and tonumber(strsub(guid, 5, 5), 16)
	if unitType and (unitType % 8 == 3 or unitType % 8 == 5) then
		return tonumber(strsub(guid, 6, 12), 16)
	end
end

do
	local modiferFunctionTable = {
		["SHIFT"] = IsShiftKeyDown,
		["CTRL"] = IsControlKeyDown,
		["ALT"] = IsAltKeyDown,
		["ANY"] = IsModifierKeyDown,
		["NONE"] = function()
			return false
		end,
	}

	function TI:IsPaused(moduleEvent)
		if not self.db or moduleEvent and self.db.mode ~= "ALL" and moduleEvent ~= self.db.mode then
			return true
		end

		local func = modiferFunctionTable[self.db.pauseModifier]
		if func and func() then
			return true
		end

		return false
	end
end

function TI:IsIgnoredNPC(npcID)
	npcID = npcID or self:GetNPCID()

	if npcID and ignoreQuestNPC[npcID] then
		return true
	end

	return npcID and self.db and self.db.customIgnoreNPCs and self.db.customIgnoreNPCs[npcID]
end

local function CompleteGossipQuest(...)
	for i = 1, select("#", ...), 4 do
		local title, _, _, isComplete = select(i, ...)
		if isComplete and TI:EnableOnQuest(IsRepeatableQuest(title)) then
			SelectGossipActiveQuest((i + 3) / 4)
			return true
		end
	end
end

local function HasSkipOption(...)
	for i = 1, select("#", ...), 2 do
		local text = select(i, ...)
		if text and strfind(text, SKIP_STRING) then
			return true
		end
	end
end

local function AcceptGossipQuest(...)
	for i = 1, select("#", ...), 5 do
		local title, _, isTrivial, isDaily, isRepeatable = select(i, ...)
		local isRepeatableQuest = isDaily or isRepeatable
		if title and isRepeatableQuest then
			repeatableQuests[title] = true
		end

		if not isTrivial and TI:EnableOnQuest(isRepeatableQuest) then
			SelectGossipAvailableQuest((i + 4) / 5)
			return
		end
	end
end

function TI:QUEST_GREETING()
	if self:IsIgnoredNPC() then
		return
	end

	if not self:IsPaused("COMPLETE") then
		for index = 1, GetNumActiveQuests() do
			local title, isComplete = GetActiveTitle(index)
			if isComplete and self:EnableOnQuest(IsRepeatableQuest(title)) then
				SelectActiveQuest(index)
				return
			end
		end
	end

	for index = 1, GetNumAvailableQuests() do
		local isTrivial, isDaily, isRepeatable = GetAvailableQuestInfo(index)
		local title = GetAvailableTitle(index)
		local isRepeatableQuest = isDaily or isRepeatable
		if title and isRepeatableQuest then
			repeatableQuests[title] = true
		end

		if not isTrivial and self:EnableOnQuest(isRepeatableQuest) and not self:IsPaused("ACCEPT") then
			SelectAvailableQuest(index)
			return
		end
	end
end

function TI:GOSSIP_SHOW()
	if self:IsPaused() or self:IsIgnoredNPC() then
		return
	end

	if not self:IsPaused("COMPLETE") and CompleteGossipQuest(GetGossipActiveQuests()) then
		return
	end

	if HasSkipOption(GetGossipOptions()) then
		return
	end

	if not self:IsPaused("ACCEPT") then
		AcceptGossipQuest(GetGossipAvailableQuests())
	end
end

function TI:QUEST_DETAIL()
	if self:IsPaused("ACCEPT") or self:IsIgnoredNPC() then
		return
	end

	if not self:EnableOnQuest(IsRepeatableQuestFrame()) then
		return
	end

	if QuestGetAutoAccept() then
		CloseQuest()
		return
	end

	if QuestFlagsPVP() then
		return
	end

	E:Delay(0.3, function()
		AcceptQuest()
	end)
end

function TI:QUEST_ACCEPT_CONFIRM()
	if self:IsPaused("ACCEPT") then
		return
	end

	if self:EnableOnQuest() then
		ConfirmAcceptQuest()
		E:Delay(0, StaticPopup_Hide, "QUEST_ACCEPT")
	end
end

function TI:QUEST_ACCEPTED()
	if _G.QuestFrame:IsShown() and QuestGetAutoAccept() then
		CloseQuest()
	end
end

function TI:QUEST_ITEM_UPDATE()
	if choiceQueued and _G.QuestFrameRewardPanel:IsShown() then
		choiceQueued = false
		self:QUEST_COMPLETE()
	end
end

function TI:QUEST_PROGRESS()
	if self:IsPaused("COMPLETE") or self:IsIgnoredNPC() then
		return
	end

	if not IsQuestCompletable() then
		return
	end

	if not self:EnableOnQuest(IsRepeatableQuestFrame()) then
		return
	end

	CompleteQuest()
end

function TI:QUEST_COMPLETE()
	if self:IsPaused("COMPLETE") or self:IsIgnoredNPC() then
		return
	end

	if not self:EnableOnQuest(IsRepeatableQuestFrame()) then
		return
	end

	local money = GetQuestMoneyToGet()
	if money and money > 0 then
		return
	end

	local choices = GetNumQuestChoices()
	if choices <= 1 then
		GetQuestReward(1)
	elseif self.db and self.db.selectReward then
		local bestSellPrice, bestIndex = 0, nil

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			local itemSellPrice = link and select(11, GetItemInfo(link))
			if not itemSellPrice then
				choiceQueued = true
				return GetQuestItemInfo("choice", index)
			end

			itemSellPrice = cashRewards[tonumber(strmatch(link, "item:(%d+)"))] or itemSellPrice

			if itemSellPrice > bestSellPrice then
				bestSellPrice, bestIndex = itemSellPrice, index
			end
		end

		if not bestIndex then
			return
		end

		for i = 1, MAX_NUM_ITEMS do
			local button = _G["QuestInfoItem" .. i]
			if button and button:IsShown() and button.type == "choice" and button:GetID() == bestIndex then
				QuestInfoItem_OnClick(button)
				break
			end
		end

		if self.db.getBestReward then
			GetQuestReward(bestIndex)
		end
	end
end

function TI:AddTargetToBlacklist()
	if not UnitExists("target") then
		F.Print(L["Target does not exist."])
		return
	end
	if UnitPlayerControlled("target") then
		F.Print(L["Target is not an NPC."])
		return
	end
	local npcID = self:GetNPCID("target")
	if npcID then
		local list = E.db.WT.quest.turnIn.customIgnoreNPCs
		list[npcID] = UnitName("target")
		F.Print(format(L["%s has been added to the ignore list."], list[npcID]))
	end
end

_G.SLASH_WINDTOOLS_TURN_IN1 = "/wti"
_G.SLASH_WINDTOOLS_TURN_IN2 = "/windturnin"
_G.SLASH_WINDTOOLS_TURN_IN3 = "/windquestturnin"

_G.SlashCmdList["WINDTOOLS_TURN_IN"] = function(msg)
	if msg and strlen(msg) > 0 then
		msg = strupper(msg)
		if msg == "ON" or msg == "1" or msg == "TRUE" or msg == "ENABLE" then
			TI.db.enable = true
		elseif msg == "OFF" or msg == "0" or msg == "FALSE" or msg == "DISABLE" then
			TI.db.enable = false
		elseif msg == "ADDTARGET" or msg == "ADD" or msg == "IGNORE" or msg == "ADD TARGET" then
			TI:AddTargetToBlacklist()
			return
		end
	else
		TI.db.enable = not TI.db.enable
	end
	TI:ProfileUpdate()
	local SB = W:GetModule("SwitchButtons")
	if SB then
		SB:ProfileUpdate()
	end

	F.Print(format("%s %s", L["Turn In"], TI.db.enable and L["Enabled"] or L["Disabled"]))
end

function TI:Initialize()
	self.db = E.db.WT.quest.turnIn
	if not self.db.enable or self.initialized then
		return
	end

	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
	self:RegisterEvent("QUEST_COMPLETE")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("QUEST_ITEM_UPDATE")
	self:RegisterEvent("QUEST_PROGRESS")

	self.initialized = true
end

function TI:ProfileUpdate()
	self:Initialize()

	if self.initialized and not self.db.enable then
		self:UnregisterAllEvents()
		self.initialized = false
	end
end

W:RegisterModule(TI:GetName())
