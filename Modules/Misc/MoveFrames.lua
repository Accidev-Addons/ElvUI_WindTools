local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local MF = W.Modules.MoveFrames ---@class MoveFrames
local B = E:GetModule("Bags")

local _G = _G
local pairs = pairs
local strsplit = strsplit
local tDeleteItem = tDeleteItem
local type = type

local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local RunNextFrame = RunNextFrame

local BlizzardFrames = {
	"AlliedRacesFrame",
	"AuctionHouseFrame",
	"BankFrame",
	"BlackMarketFrame",
	"ChallengesKeystoneFrame",
	"ChatConfigFrame",
	"CinematicFrame",
	"ClassTrainerFrame",
	"CollectionsJournal",
	"ContainerFrame1",
	"ContainerFrameCombinedBags",
	"DeathRecapFrame",
	"DressUpFrame",
	"FriendsFrame",
	"GameMenuFrame",
	"GossipFrame",
	"GroupLootContainer",
	"GuildInviteFrame",
	"GuildRegistrarFrame",
	"HelpFrame",
	"InspectFrame",
	"InspectRecipeFrame",
	"ItemSocketingFrame",
	"ItemTextFrame",
	"ItemUpgradeFrame",
	"LFDDungeonReadyDialog",
	"LFDDungeonReadyStatus",
	"LFDRoleCheckPopup",
	"LootFrame",
	"MacroFrame",
	"MerchantFrame",
	"PetitionFrame",
	"PlayerTalentFrame",
	"QuestFrame",
	"QuickKeybindFrame",
	"ReadyCheckFrame",
	"TabardFrame",
	"TaxiFrame",
	"TimeManagerFrame",
	"TradeFrame",
	"TutorialFrame",
	"WorldMapFrame",
	["CalendarFrame"] = {
		"CalendarCreateEventFrame",
		"CalendarCreateEventInviteListScrollFrame",
		"CalendarViewEventFrame",
		"CalendarViewEventInviteListScrollFrame",
		"CalendarViewHolidayFrame",
	},
	["CharacterFrame"] = {
		"PaperDollFrame",
		"ReputationFrame",
		"TokenFrame",
		"TokenFramePopup",
	},
	["EncounterJournal"] = {
		"EncounterJournal.encounter.info.overviewScroll",
		"EncounterJournal.encounter.info.detailsScroll",
	},
	["MailFrame"] = {
		"SendMailFrame",
		"MailFrameInset",
		"OpenMailFrame",
	},
}

local BlizzardFramesOnDemand = {
	["Blizzard_AchievementUI"] = {
		["AchievementFrame"] = {
			"AchievementFrameHeader",
		},
	},
	["Blizzard_BindingUI"] = {
		"KeyBindingFrame",
	},
	["Blizzard_GMChatUI"] = {
		"GMChatStatusFrame",
	},
	["Blizzard_GuildBankUI"] = {
		"GuildBankFrame",
	},
}

local ignorePositionRememberingFrames = {
	["GameMenuFrame"] = true,
}

local disabled = {}
local framePaths = {}
local moveTargets = {}

local function GetFrame(frameOrName)
	local frame

	if frameOrName then
		if frameOrName.GetName then
			frame = frameOrName
		else
			frame = _G
			local path = { strsplit(".", frameOrName) }
			for i = 1, #path do
				frame = frame[path[i]]
			end
		end
	end

	return frame
end

function MF:Remember(frame)
	if not self.db.rememberPositions or self.StopRunning then
		return
	end

	local path = framePaths[frame]
	if not path or path == "" or ignorePositionRememberingFrames[path] then
		return
	end

	local numPoints = frame:GetNumPoints()
	if numPoints and numPoints > 0 then
		self.db.framePositions[path] = {}
		for index = 1, numPoints do
			local anchorPoint, relativeFrame, relativePoint, offX, offY = frame:GetPoint(index)
			self.db.framePositions[path][index] = {
				anchorPoint = anchorPoint,
				relativeFrame = relativeFrame and relativeFrame:GetName() or "UIParent",
				relativePoint = relativePoint,
				offX = offX,
				offY = offY,
			}
		end
	end

	self:EnsureWindowInTheScreen(frame)
end

function MF:Reposition(frame, _, _, _, _, _, skip)
	if skip or InCombatLockdown() or not self.db or not self.db.rememberPositions or self.StopRunning then
		return
	end

	local path = framePaths[frame]
	if path == "" or ignorePositionRememberingFrames[path] then
		self.db.framePositions[path] = nil
		return
	end

	if not path or not self.db.framePositions[path] or #self.db.framePositions[path] == 0 then
		return
	end

	frame:ClearAllPoints()
	for _, record in pairs(self.db.framePositions[path]) do
		if type(record.relativeFrame) ~= "string" then
			record.relativeFrame = "UIParent"
		end
		local relativeFrame = GetFrame(record.relativeFrame or "UIParent")
		frame:Point(record.anchorPoint, relativeFrame, record.relativePoint, record.offX, record.offY, true)
	end

	self:EnsureWindowInTheScreen(frame)
end

---Check and ensure the window is completely within the screen bounds, it not, forget its remembered position
---@param frame Frame The frame to check
function MF:EnsureWindowInTheScreen(frame)
	if not self.db or not self.db.autoResetOffScreenFrames then
		return
	end

	local path = framePaths[frame]
	if not path or not self.db.framePositions[path] then
		return
	end

	local isOffScreen = false
	local left, right = frame:GetLeft(), frame:GetRight()
	local top, bottom = frame:GetTop(), frame:GetBottom()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()

	if left and right and (right < 3 or left > screenWidth - 3) then
		isOffScreen = true
	end

	if top and bottom and (bottom < 3 or top > screenHeight - 3) then
		isOffScreen = true
	end

	if isOffScreen then
		self.db.framePositions[path] = nil
	end
end

function MF:Frame_StartMoving(this, button)
	local moveTarget = moveTargets[this]
	if InCombatLockdown() and (this:IsProtected() or moveTarget and moveTarget:IsProtected()) then
		return
	end

	if button == "LeftButton" and moveTarget and moveTarget:IsMovable() and not disabled[moveTarget] then
		moveTarget:StartMoving()
	end
end

function MF:Frame_StopMoving(this, button)
	local moveTarget = moveTargets[this]
	if InCombatLockdown() and (this:IsProtected() or moveTarget and moveTarget:IsProtected()) then
		return
	end

	if button == "LeftButton" and moveTarget then
		moveTarget:StopMovingOrSizing()
		MF:Remember(moveTarget)
	end
end

function MF:HandleFrame(this, bindTo)
	local thisFrame = GetFrame(this)
	local bindingTargetFrame = GetFrame(bindTo)

	if not thisFrame or moveTargets[thisFrame] then
		return
	end

	if InCombatLockdown() and thisFrame:IsProtected() then
		F.TaskManager:AfterCombat(function()
			self:HandleFrame(this, bindTo)
			-- Manually trigger a reposition after combat ends
			-- Some frames may need to run the fix function first, so reposition should be run next frame to avoid issues
			RunNextFrame(function()
				local repositionFrame = GetFrame(this)
				local moveTarget = repositionFrame and moveTargets[repositionFrame]
				if moveTarget then
					self:Reposition(moveTarget)
				end
			end)
		end)
		return
	end

	thisFrame:SetMovable(true)
	thisFrame:SetClampedToScreen(true)
	thisFrame:EnableMouse(true)
	moveTargets[thisFrame] = bindingTargetFrame or thisFrame

	framePaths[thisFrame] = this
	if not framePaths[moveTargets[thisFrame]] then
		framePaths[moveTargets[thisFrame]] = bindTo
	end

	self:SecureHookScript(thisFrame, "OnMouseDown", "Frame_StartMoving")
	self:SecureHookScript(thisFrame, "OnMouseUp", "Frame_StopMoving")

	if moveTargets[thisFrame] and not self:IsHooked(moveTargets[thisFrame], "SetPoint") then
		self:SecureHook(moveTargets[thisFrame], "SetPoint", "Reposition")
	end
end

function MF:HandleFramesWithTable(table, parent)
	for key, value in pairs(table) do
		if type(key) == "number" and type(value) == "string" then
			self:HandleFrame(value, parent)
		elseif type(key) == "string" and type(value) == "table" then
			self:HandleFrame(key, parent)
			self:HandleFramesWithTable(value, key)
		end
	end
end

function MF:HandleAddon(_, addon)
	local frameTable = BlizzardFramesOnDemand[addon]

	if not frameTable then
		return
	end

	self:HandleFramesWithTable(frameTable)
end

function MF:HandleElvUIBag(frameName)
	if not self.db.elvUIBags then
		return
	end
	local frame = B[frameName]

	if not frame or framePaths[frame] then
		return
	end

	frame:SetScript("OnDragStart", function(dragFrame)
		dragFrame:StartMoving()
	end)

	if frame.helpButton then
		frame.helpButton:SetScript("OnEnter", function(helpButton)
			local GameTooltip = _G.GameTooltip
			GameTooltip:SetOwner(helpButton, "ANCHOR_TOPLEFT", 0, 4)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(L["Drag"] .. ":", L["Temporary Move"], 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Hold Control + Right Click:"], L["Reset Position"], 1, 1, 1)
			GameTooltip:Show()
		end)
	end

	framePaths[frame] = "ElvUI_" .. frameName
end

---Check if the MoveFrames module is running
---@return boolean Whether the MoveFrames module is running
function MF:IsRunning()
	return E.private.WT.misc.moveFrames.enable and not W.Modules.MoveFrames.StopRunning
end

---Get the move target frame for a given frame
---@param frame Frame The frame to get the move target for
---@return Frame|nil The move target frame, or nil if not found
function MF:GetMoveTarget(frame)
	return moveTargets[frame]
end

---Handle the internal frame movement
---@param frame Frame The frame to move
---@param bindTo Frame|string? The frame to bind to, if not provided, it will bind to the same frame
---@param remember boolean? Whether to remember the frame position
function MF:InternalHandle(frame, bindTo, remember)
	if not self:IsRunning() then
		return
	end

	self:HandleFrame(frame, bindTo)

	if remember == false then
		framePaths[frame] = ""
	end
end

function MF:SetMovable(frame, movable)
	if not self:IsRunning() then
		return
	end

	local targetFrame = GetFrame(frame)
	if not targetFrame then
		return
	end

	disabled[targetFrame] = not movable
end

function MF:Initialize()
	if IsAddOnLoaded("BlizzMove") then
		self.StopRunning = "BlizzMove"
		return
	end

	if IsAddOnLoaded("MoveAnything") then
		self.StopRunning = "MoveAnything"
		return
	end

	self.db = E.private.WT.misc.moveFrames
	if not self.db or not self.db.enable then
		return
	end

	-- Trade Skill Master Speical Handling
	if IsAddOnLoaded("TradeSkillMaster") and self.db.tradeSkillMasterCompatible then
		tDeleteItem(BlizzardFrames, "MerchantFrame")
	end

	-- Setup Blizzard Frames that are always loaded
	self:HandleFramesWithTable(BlizzardFrames)

	-- Setup Blizzard Frames that are loaded on demand
	self:RegisterEvent("ADDON_LOADED", "HandleAddon")
	for addon in pairs(BlizzardFramesOnDemand) do
		if IsAddOnLoaded(addon) then
			self:HandleAddon(nil, addon)
		end
	end

	-- ElvUI Bag & Bank Frames
	F.TaskManager:OutOfCombat(self.HandleElvUIBag, self, "BagFrame")
	F.TaskManager:OutOfCombat(self.HandleElvUIBag, self, "BankFrame")

	local GetBagsShown = _G.ContainerFrameSettingsManager.GetBagsShown
	self:SecureHook(_G.ContainerFrameSettingsManager, "GetBagsShown", function()
		for _, bag in pairs(GetBagsShown(_G.ContainerFrameSettingsManager) or {}) do
			bag:ClearAllPoints()
		end
	end)
end

W:RegisterModule(MF:GetName())
