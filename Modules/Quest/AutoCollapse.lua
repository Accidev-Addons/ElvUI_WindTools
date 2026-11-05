local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local AC = W:NewModule("AutoCollapse", "AceHook-3.0", "AceEvent-3.0") ---@class AutoCollapse: AceModule, AceHook-3.0, AceEvent-3.0

local _G = _G
local ipairs = ipairs

local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsResting = IsResting

local instanceTypeKeyMap = {
	none = "outOfInstance",
	pvp = "battleground",
	arena = "arena",
	party = "dungeon",
	raid = "raid",
}

function AC:UpdateState(event)
	if not self.db or not self.db.enable then
		self.state = "none"
		return
	end

	if event == "PLAYER_REGEN_DISABLED" and self.db.combat ~= "none" then
		self.state = self.db.combat
		return
	end

	if event == "UNIT_ENTERED_VEHICLE" and self.db.vehicle ~= "none" then
		self.state = self.db.vehicle
		return
	end

	if IsResting() and self.db.resting ~= "none" then
		self.state = self.db.resting
		return
	end

	local _, instanceType = IsInInstance()
	local key = instanceTypeKeyMap[instanceType]
	if key and self.db[key] and self.db[key] ~= "none" then
		self.state = self.db[key] --[[@as "none" | "collapse" | "expand" | "hide"]]
		return
	end

	self.state = self.db.default
end

local function ApplyCollapseState(tracker, state)
	local collapse = state ~= "expand"
	local isCollapsed = tracker:IsCollapsed() and true or false
	if isCollapsed ~= collapse then
		tracker:SetCollapsed(collapse)
	end
end

local function CanChangeVisibility(tracker)
	return not (InCombatLockdown() and tracker:IsProtected())
end

function AC:RestoreTracker(tracker)
	if self.hidden and CanChangeVisibility(tracker) then
		self.hidden = nil
		tracker:Update()
	end
end

function AC:Apply(event, arg1)
	if (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and arg1 ~= "player" then
		return
	end

	local tracker = _G.ObjectiveTrackerFrame
	if not tracker then
		return
	end

	self:UpdateState(event)

	if self.state == "hide" then
		if CanChangeVisibility(tracker) then
			self.hidden = true
			tracker:Hide()
		end
		return
	end

	self:RestoreTracker(tracker)

	if self.state ~= "none" then
		ApplyCollapseState(tracker, self.state)
	end
end

function AC:ObjectiveTrackerFrame_Show(frame)
	if self.db and self.db.enable and self.state == "hide" and CanChangeVisibility(frame) then
		frame:Hide()
	end
end

function AC:ObjectiveTrackerFrame_SetCollapsed(frame)
	if not self.db or not self.db.enable or self.state == "none" or self.state == "hide" then
		return
	end

	local header = frame.Header
	local isUserAction = header and header.MinimizeButton and header.MinimizeButton:IsMouseOver()

	if not self.db.ignoreManualToggle and isUserAction then
		self.state = "none"
		return
	end

	ApplyCollapseState(frame, self.state)
end

local events = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_UPDATE_RESTING",
	"UNIT_ENTERED_VEHICLE",
	"UNIT_EXITED_VEHICLE",
	"ZONE_CHANGED_NEW_AREA",
}

function AC:ProfileUpdate()
	self.db = E.db.WT.quest.autoCollapse

	if not self.db.enable then
		self:UnregisterAllEvents()
		self.eventRegistered = false
		self.state = "none"
		if _G.ObjectiveTrackerFrame then
			self:RestoreTracker(_G.ObjectiveTrackerFrame)
		end
		return
	end

	if not self.eventRegistered then
		for _, event in ipairs(events) do
			self:RegisterEvent(event, "Apply")
		end
		self.eventRegistered = true
	end

	local tracker = _G.ObjectiveTrackerFrame
	if tracker then
		if not self:IsHooked(tracker, "SetCollapsed") then
			self:SecureHook(tracker, "SetCollapsed", "ObjectiveTrackerFrame_SetCollapsed")
		end
		if not self:IsHooked(tracker, "Show") then
			self:SecureHook(tracker, "Show", "ObjectiveTrackerFrame_Show")
		end
	end

	self:Apply()
end

AC.Initialize = AC.ProfileUpdate

W:RegisterModule(AC:GetName())
