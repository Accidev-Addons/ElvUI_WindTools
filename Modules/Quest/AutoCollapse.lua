local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local AC = W:NewModule("AutoCollapse", "AceHook-3.0", "AceEvent-3.0") ---@class AutoCollapse: AceModule, AceHook-3.0, AceEvent-3.0

local _G = _G
local ipairs = ipairs

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsResting = IsResting
local UnitAffectingCombat = UnitAffectingCombat
local UnitInVehicle = UnitInVehicle

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

	local inCombat = event == "PLAYER_REGEN_DISABLED" or event ~= "PLAYER_REGEN_ENABLED" and UnitAffectingCombat("player")
	if inCombat and self.db.combat ~= "none" then
		self.state = self.db.combat
		return
	end

	local inVehicle = event == "UNIT_ENTERED_VEHICLE" or event ~= "UNIT_EXITED_VEHICLE" and UnitInVehicle("player")
	if inVehicle and self.db.vehicle ~= "none" then
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

local function CanChangeVisibility(frame)
	return not (InCombatLockdown() and frame:IsProtected())
end

function AC:OnExpandButtonClick()
	if self.db.ignoreManualToggle then
		return
	end

	self.state = "none"
	self:SetContentCollapsed(_G.ObjectiveTrackerFrame, false)
end

function AC:SetContentCollapsed(tracker, collapsed)
	if not collapsed == not self.contentCollapsed or not CanChangeVisibility(tracker.ScrollFrame) then
		return
	end

	if not self.expandButton then
		local minimize = tracker.Header.MinimizeButton
		local button = CreateFrame("Button", nil, tracker.Header)
		button:SetAllPoints(minimize)
		button:SetFrameLevel(minimize:GetFrameLevel() + 1)
		button:SetScript("OnClick", function()
			self:OnExpandButtonClick()
		end)
		self.expandButton = button
	end

	if collapsed then
		self.nineSliceAlpha = tracker.NineSlice:GetAlpha()
	end

	self.contentCollapsed = collapsed
	tracker.ScrollFrame:SetShown(not collapsed)
	tracker.NineSlice:SetAlpha(collapsed and 0 or self.nineSliceAlpha or 1)
	tracker.Header:SetCollapsed(collapsed or tracker:IsCollapsed())
	self.expandButton:SetShown(collapsed)
end

function AC:HideTracker(tracker)
	if tracker:GetParent() ~= E.HiddenFrame and CanChangeVisibility(tracker) then
		self.trackerParent = tracker:GetParent()
		tracker:SetParent(E.HiddenFrame)
	end
end

function AC:RestoreTracker(tracker)
	if tracker:GetParent() == E.HiddenFrame and not InCombatLockdown() then
		tracker:SetParent(self.trackerParent or _G.UIParent)
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
		self:HideTracker(tracker)
		return
	end

	self:RestoreTracker(tracker)

	if self.state ~= "none" then
		self:SetContentCollapsed(tracker, self.state == "collapse")
	end
end

function AC:ObjectiveTrackerFrame_SetCollapsed(frame)
	if not self.db or not self.db.enable or self.db.ignoreManualToggle or self.state == "hide" then
		return
	end

	local minimize = frame.Header and frame.Header.MinimizeButton
	if minimize and minimize:IsMouseOver() then
		self.state = "none"
	end
end

function AC:ObjectiveTrackerFrame_SetBackgroundAlpha(frame, alpha)
	if self.contentCollapsed then
		self.nineSliceAlpha = alpha
		frame.NineSlice:SetAlpha(0)
	end
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
			self:SetContentCollapsed(_G.ObjectiveTrackerFrame, false)
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
		if not self:IsHooked(tracker, "SetBackgroundAlpha") then
			self:SecureHook(tracker, "SetBackgroundAlpha", "ObjectiveTrackerFrame_SetBackgroundAlpha")
		end
	end

	self:Apply()
end

AC.Initialize = AC.ProfileUpdate

W:RegisterModule(AC:GetName())
