local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local QP = W:GetModule("QuestProgress") ---@class QuestProgress : AceModule, AceEvent-3.0
local A = W:GetModule("Announcement") ---@class Announcement
local C = W.Utilities.Color

local _G = _G
local assert = assert
local format = format
local gsub = gsub
local pairs = pairs
local strmatch = strmatch
local strtrim = strtrim
local tinsert = tinsert
local tonumber = tonumber
local tostring = tostring

local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLink = GetQuestLink
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetQuestLogTitle = GetQuestLogTitle
local GetTime = GetTime
local UIErrorsFrame = _G.UIErrorsFrame
local UnitLevel = UnitLevel

---@class QuestStatusType : number
---@type table<string, QuestStatusType>
local QUEST_STATUS = {
	ACCEPTED = 1,
	COMPLETED = 2,
	QUEST_UPDATE = 3,
	OBJECTIVE_UPDATE = 4,
}

local cachedQuests ---@type table<number, QuestProgressData>
local cachedNumQuests = 0

---@class QuestProgressData
---@field questID number Quest ID
---@field title string Quest title
---@field link string Quest link
---@field level number Quest level
---@field suggestedGroup number Suggested group size
---@field isComplete boolean Quest completion status
---@field isDaily boolean Daily quest
---@field tag? string Quest tag name
---@field objectives QuestObjectiveData[] List of quest objectives

---@class QuestObjectiveData
---@field item string
---@field finished boolean
---@field numFulfilled number
---@field numRequired number

---@alias QuestProgressContext table<string, string?>

---@param text string
---@return string? item
---@return number? numFulfilled
---@return number? numRequired
local function ParseObjective(text)
	local item, numFulfilled, numRequired = strmatch(text, "^(.*):%s*(%d+)%s*/%s*(%d+)")
	if not item then
		numFulfilled, numRequired, item = strmatch(text, "(%d+)/(%d+) ?(.*)")
	end
	return item, tonumber(numFulfilled), tonumber(numRequired)
end

---Get all current quest progress data
---@return table<number, QuestProgressData> quests
---@return number numQuests
---@return boolean isPartial
local function FetchAllQuestProgressData()
	local quests = {} ---@type table<number, QuestProgressData>
	local numEntries, numQuests = GetNumQuestLogEntries()
	local numVisible = 0

	for questIndex = 1, numEntries do
		local title, level, questTag, suggestedGroup, isHeader, _, isComplete, isDaily, questID =
			GetQuestLogTitle(questIndex)
		if title and not isHeader and questID then
			numVisible = numVisible + 1

			local objectiveData = {}
			for objectiveIndex = 1, GetNumQuestLeaderBoards(questIndex) do
				local text, _, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
				if text then
					local item, numFulfilled, numRequired = ParseObjective(text)
					tinsert(objectiveData, {
						item = item,
						finished = finished and true or (numFulfilled and numRequired and numFulfilled >= numRequired),
						numFulfilled = numFulfilled,
						numRequired = numRequired,
					})
				end
			end

			quests[questID] = {
				title = title,
				questID = questID,
				level = level,
				suggestedGroup = suggestedGroup,
				isComplete = isComplete == 1,
				isDaily = isDaily and true or false,
				tag = questTag,
				link = GetQuestLink(questIndex),
				objectives = objectiveData,
			}
		end
	end

	numQuests = numQuests or numVisible

	return quests, numQuests, numVisible < numQuests
end

---Check if objective data has been updated
---@param newData QuestObjectiveData
---@param oldData QuestObjectiveData?
---@return boolean
local function IsObjectiveDataUpdated(newData, oldData)
	if not oldData then
		return true
	end

	if newData.numFulfilled ~= oldData.numFulfilled then
		return true
	end

	if newData.numRequired ~= oldData.numRequired then
		return true
	end

	local serverDataWrong = oldData.item and strtrim(oldData.item) == "" or newData.item and strtrim(newData.item) == ""
	if not serverDataWrong and oldData.item ~= newData.item then
		return true
	end

	return false
end

---Apply color to placeholder text
---@param text? string|number
---@param template? string
---@param color { left: RGB, right: RGB }
---@return string? plainText
---@return string? coloredText
local function Render(text, template, color)
	if not text then
		return
	end

	text = tostring(text)
	if template then
		text = format(template, tostring(text))
	end

	return text, C.GradientStringByRGB(text, color.left, color.right)
end

---Render template with contexts
---@param template string
---@param context QuestProgressContext
---@return string
function QP:RenderTemplate(template, context)
	local result = gsub(template, "{{(%w+)}}", function(key)
		return context[key] or ""
	end)

	result = gsub(result, "%s+", " ")
	result = gsub(result, "^%s+", "")
	result = gsub(result, "%s+$", "")

	return result
end

---@param data QuestProgressData
---@return QuestProgressContext plainContext
---@return QuestProgressContext coloredContext
function QP:BuildContext(data)
	local db = self.db
	local plainContext, coloredContext = {}, {}

	plainContext.tag, coloredContext.tag = Render(data.tag, db.tag.template, db.tag.color)
	plainContext.title, coloredContext.title = Render(data.title, db.title.template, db.title.color)
	plainContext.level, coloredContext.level = Render(data.level, db.level.template, db.level.color)
	plainContext.link, coloredContext.link = data.link, data.link

	if data.isDaily then
		plainContext.daily, coloredContext.daily = Render(data.link, db.daily.template, db.daily.color)
	end

	if data.suggestedGroup and data.suggestedGroup > 1 then
		plainContext.suggestedGroup, coloredContext.suggestedGroup =
			Render(data.suggestedGroup, db.suggestedGroup.template, db.suggestedGroup.color)
	end

	if data.level and data.level ~= UnitLevel("player") then
		coloredContext.autoHideLevel = coloredContext.level
	end

	plainContext.rawLevel = data.level

	return plainContext, coloredContext
end

---@param objectiveData QuestObjectiveData
---@return boolean
function QP:ValidateObjectiveData(objectiveData)
	if not objectiveData then
		return false
	end

	local numFulfilled = objectiveData.numFulfilled
	local numRequired = objectiveData.numRequired

	if
		(numFulfilled and numFulfilled > 0)
		and (numRequired and numRequired > 0)
		and (numFulfilled >= numRequired or numRequired <= self.db.disableIfRequiredOver)
	then
		return true
	end

	return false
end

function QP:ProcessQuestUpdate()
	local currentQuests, numQuests, isPartial = FetchAllQuestProgressData()
	if not cachedQuests then
		cachedQuests = currentQuests
		cachedNumQuests = numQuests
		return
	end

	local hasNewQuest = numQuests > cachedNumQuests

	for id, questData in pairs(currentQuests) do
		local previousQuestData = cachedQuests[id]
		if not previousQuestData then
			if hasNewQuest then
				self:HandleQuestProgress(QUEST_STATUS.ACCEPTED, questData)
			end
		elseif not previousQuestData.isComplete then
			if questData.isComplete then
				self:HandleQuestProgress(QUEST_STATUS.COMPLETED, questData)
			elseif #previousQuestData.objectives > 0 and #questData.objectives > 0 then
				for objectiveIndex = 1, #questData.objectives do
					local objectiveData = questData.objectives[objectiveIndex]
					local previousObjectiveData = previousQuestData.objectives[objectiveIndex]
					if
						IsObjectiveDataUpdated(objectiveData, previousObjectiveData)
						and self:ValidateObjectiveData(objectiveData)
					then
						self:HandleQuestProgress(QUEST_STATUS.QUEST_UPDATE, questData, objectiveData)
					end
				end
			end
		end
	end

	if isPartial then
		for id, questData in pairs(cachedQuests) do
			if not currentQuests[id] then
				currentQuests[id] = questData
			end
		end
	end

	cachedQuests = currentQuests
	cachedNumQuests = numQuests
end

---@param context QuestProgressContext
---@return QuestProgressContext
function QP:FilterContext(context)
	-- Use autoHideLevel for level if hideOnCharacterLevel is enabled
	if self.db.level.hideOnCharacterLevel and context.level then
		context.level = context.autoHideLevel
	end

	context.autoHideLevel = nil

	return context
end

local lastPlayedTime = {} ---@type table<QuestStatusType, number>

---@param status QuestStatusType
function QP:PlaySoundEffect(status)
	if not self.db.soundEffects.enable then
		return
	end

	local db
	if status == QUEST_STATUS.ACCEPTED then
		db = self.db.soundEffects.accept
	elseif status == QUEST_STATUS.COMPLETED then
		db = self.db.soundEffects.fullyComplete
	elseif status == QUEST_STATUS.QUEST_UPDATE then
		db = self.db.soundEffects.partialComplete
	elseif status == QUEST_STATUS.OBJECTIVE_UPDATE then
		db = self.db.soundEffects.objectiveProgress
	end

	if not db or not db.enable then
		return
	end

	local currentTime = GetTime()
	if lastPlayedTime[status] and currentTime - lastPlayedTime[status] < 1 then
		return
	end

	lastPlayedTime[status] = currentTime
	F.PlayLSMSound(db.sound)
end

---Handle quest progress update event
---@param status QuestStatusType
---@param questData QuestProgressData
---@param objectiveData? QuestObjectiveData
function QP:HandleQuestProgress(status, questData, objectiveData)
	if not self.fiveSecondsAfterLogin then
		return
	end

	local plainContext, coloredContext = self:BuildContext(questData)

	if status == QUEST_STATUS.ACCEPTED then
		local db = self.db.progress.accepted
		plainContext.progress, coloredContext.progress = Render(db.text, nil, db.color)
		coloredContext.icon = format("|T%s:0|t", W.Media.Icons.accept)
		self:PlaySoundEffect(status)
	elseif status == QUEST_STATUS.COMPLETED then
		local db = self.db.progress.complete
		plainContext.progress, coloredContext.progress = Render(db.text, nil, db.color)
		coloredContext.icon = format("|T%s:0|t", W.Media.Icons.complete)
		self:PlaySoundEffect(status)
	elseif status == QUEST_STATUS.QUEST_UPDATE then
		assert(objectiveData, "Objective data is required for progress update")
		local db = self.db.progress.objective
		local objectiveText, coloredObjectiveText = Render(objectiveData.item, "%s", db.color)
		local progressText = format(db.detailTemplate, objectiveData.numFulfilled, objectiveData.numRequired)
		local progressColor = F.GetProgressColor(objectiveData.numFulfilled / objectiveData.numRequired)
		local coloredProgressText = C.StringWithRGB(progressText, progressColor)
		plainContext.progress = format("%s %s", objectiveText, progressText)
		coloredContext.progress = format("%s %s", coloredObjectiveText, coloredProgressText)
		if objectiveData.finished then
			plainContext.progress = plainContext.progress .. " " .. db.completeText
			coloredContext.icon = format("|T%s:0|t", W.Media.Icons.complete)
			self:PlaySoundEffect(QUEST_STATUS.QUEST_UPDATE)
		else
			coloredContext.icon = ""
			self:PlaySoundEffect(QUEST_STATUS.OBJECTIVE_UPDATE)
		end
	end

	-- Send to UIErrorsFrame
	if self.db.enable then
		local message = self:RenderTemplate(self.db.displayTemplate, self:FilterContext(coloredContext))
		UIErrorsFrame:AddMessage(message)
	end

	-- Send to announcement module
	local event ---@type QuestAnnounceEventType
	if status == QUEST_STATUS.ACCEPTED then
		event = A.QUEST_EVENT.ACCEPTED
	elseif status == QUEST_STATUS.COMPLETED then
		event = A.QUEST_EVENT.COMPLETED
	elseif status == QUEST_STATUS.QUEST_UPDATE then
		if objectiveData and objectiveData.finished then
			event = A.QUEST_EVENT.OBJECTIVE_COMPLETED
		else
			event = A.QUEST_EVENT.PROGRESS_UPDATE
		end
	end

	A:AnnounceQuestProgress(event, plainContext)
end

do
	local ERR_QUEST_ADD_ITEM_SII = ERR_QUEST_ADD_ITEM_SII
	local ERR_QUEST_ADD_FOUND_SII = ERR_QUEST_ADD_FOUND_SII
	local ERR_QUEST_ADD_KILL_SII = ERR_QUEST_ADD_KILL_SII
	local ERR_QUEST_UNKNOWN_COMPLETE = ERR_QUEST_UNKNOWN_COMPLETE
	local ERR_QUEST_OBJECTIVE_COMPLETE_S = ERR_QUEST_OBJECTIVE_COMPLETE_S

	function QP:UpdateBlizzardQuestMessage()
		local disabled = not (self.db and self.db.enable)
		_G.ERR_QUEST_ADD_ITEM_SII = disabled and ERR_QUEST_ADD_ITEM_SII or ""
		_G.ERR_QUEST_ADD_FOUND_SII = disabled and ERR_QUEST_ADD_FOUND_SII or ""
		_G.ERR_QUEST_ADD_KILL_SII = disabled and ERR_QUEST_ADD_KILL_SII or ""
		_G.ERR_QUEST_UNKNOWN_COMPLETE = disabled and ERR_QUEST_UNKNOWN_COMPLETE or ""
		_G.ERR_QUEST_OBJECTIVE_COMPLETE_S = disabled and ERR_QUEST_OBJECTIVE_COMPLETE_S or ""
	end
end

function QP:HandleQuestUpdateEvent()
	F.TaskManager:AfterLogin(self.ProcessQuestUpdate, self)
end

---Fetch the context for preview or test
---@return QuestProgressContext plainContext
---@return QuestProgressContext coloredContext
function QP:GetTestContext()
	return self:BuildContext({
		questID = 39987,
		title = L["Test Quest Name"],
		level = 99,
		suggestedGroup = 30,
		isComplete = false,
		isDaily = true,
		tag = L["Test Series"],
		link = format("|cffffff00|Hquest:39987:335|h[%s]|h|r", L["Test Quest Name"]),
		objectives = {},
	})
end

function QP:Initialize()
	self.db = E.db.WT.quest.progress

	if not self.db.enable then
		if self.initialized then
			self:UpdateBlizzardQuestMessage()
		end
		return
	end

	if not self.initialized then
		self:RegisterEvent("QUEST_LOG_UPDATE", "HandleQuestUpdateEvent")
		self:RegisterEvent("QUEST_WATCH_UPDATE", "HandleQuestUpdateEvent")
		self.initialized = true
	end

	F.TaskManager:AfterLogin(function()
		self:UpdateBlizzardQuestMessage()
		self:ProcessQuestUpdate()

		E:Delay(5, function()
			self.fiveSecondsAfterLogin = true
		end)
	end)
end

QP.ProfileUpdate = QP.Initialize

W:RegisterModule(QP:GetName())
