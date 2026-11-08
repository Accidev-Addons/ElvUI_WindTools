local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local DT = E:GetModule("DataTexts")
local RangeCheck = E.Libs.RangeCheck

local strjoin = strjoin

local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitIsUnit = UnitIsUnit

local displayString = ""

local function OnUpdate(self, t)
	if not self.updateTargetRange then
		return
	end

	self.rangeElapsed = (self.rangeElapsed or 0) - t
	if self.rangeElapsed > 0 then
		return
	end

	self.rangeElapsed = 0.25

	local curMinRange, curMaxRange
	if UnitIsConnected("target") and not UnitIsUnit("target", "player") then
		curMinRange, curMaxRange = RangeCheck:GetRange("target")
		if not self.forceUpdate and (curMinRange == self.curMinRange and curMaxRange == self.curMaxRange) then
			return
		end
	end
	self.curMinRange, self.curMaxRange = curMinRange, curMaxRange

	if curMinRange and curMaxRange then
		self.text:SetFormattedText(displayString, L["Distance"], curMinRange, curMaxRange)
	else
		self.text:SetText("")
	end

	self.forceUpdate = false
end

local function OnEvent(self, event)
	self.updateTargetRange = UnitName("target") ~= nil
	self.rangeElapsed = 0
	if self.updateTargetRange then
		self.forceUpdate = true
	else
		self.text:SetText("")
	end
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin("", "%s: ", hex, "%d|r - ", hex, "%d|r")

	OnEvent(self)
end

DT:RegisterDatatext(
	"Target Range",
	nil,
	{ "PLAYER_TARGET_CHANGED" },
	OnEvent,
	OnUpdate,
	nil,
	nil,
	nil,
	L["Target Range"],
	nil,
	ValueColorUpdate
)
