local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local A = W:NewModule("Announcement", "AceEvent-3.0") ---@class Announcement : AceModule, AceEvent-3.0
local ChatThrottleLib = _G.ChatThrottleLib

local _G = _G

local format = format
local pairs = pairs
local strbyte = strbyte
local strfind = strfind
local strlen = strlen
local strmatch = strmatch
local strsub = strsub
local time = time

local IsEveryoneAssistant = IsEveryoneAssistant
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsRaidOfficer = IsRaidOfficer
local UnitIsGroupLeader = UnitIsGroupLeader

A.history = {}

local function TruncateMessage(text)
	if strlen(text) <= 255 then
		return text
	end

	local cut = 255
	local nextByte = strbyte(text, cut + 1)
	while nextByte >= 128 and nextByte < 192 do
		cut = cut - 1
		nextByte = strbyte(text, cut + 1)
	end
	text = strsub(text, 1, cut)

	local colorStart
	local position = 1
	while true do
		local found = strfind(text, "|c", position, true)
		if not found then
			break
		end
		colorStart, position = found, found + 2
	end

	if colorStart and not strfind(text, "|r", colorStart, true) then
		text = strsub(text, 1, colorStart - 1)
	end

	if strlen(strmatch(text, "|*$")) % 2 == 1 then
		text = strsub(text, 1, -2)
	end

	return text
end

function A:AddHistory(text, channel)
	if not self.db.sameMessageInterval or self.db.sameMessageInterval == 0 then
		return
	end

	self.history[text .. "_@@@_" .. channel] = time()
end

function A:CheckBeforeSend(text, channel)
	if not self.db.sameMessageInterval or self.db.sameMessageInterval == 0 then
		return true
	end

	local key = text .. "_@@@_" .. channel

	if self.history[key] and time() < self.history[key] + self.db.sameMessageInterval then
		return false
	end

	self.history[key] = time()
	return true
end

---Send Message
---@param text string The text you want to send to others
---@param channel any The channel in Blizzard codes format
---@param raidWarning any Let the function send raid warning if possible
---@param whisperTarget any The target if the channel is whisper
function A:SendMessage(text, channel, raidWarning, whisperTarget)
	-- Skip if the channel is NONE
	if channel == "NONE" then
		return
	end

	if channel == "SELF" then
		_G.DEFAULT_CHAT_FRAME:AddMessage(text)
		return
	end

	if channel == "WHISPER" then
		if whisperTarget then
			ChatThrottleLib:SendChatMessage("NORMAL", "WT", TruncateMessage(text), channel, nil, whisperTarget)
		end
		return
	end

	if channel == "EMOTE" then
		if self.db and self.db.emoteFormat then
			text = format(self.db.emoteFormat, text)
		else
			text = ": " .. text
		end
	end

	if channel == "RAID" and raidWarning and IsInRaid() then
		if UnitIsGroupLeader("player") or IsRaidOfficer() or IsEveryoneAssistant() then
			channel = "RAID_WARNING"
		end
	end

	if self:CheckBeforeSend(text, channel) then
		ChatThrottleLib:SendChatMessage("NORMAL", "WT", TruncateMessage(text), channel)
	end
end

---Fetch the most suitable channel configuration
---@param channelDB table Channel configuration table
---@return string
function A:GetChannel(channelDB)
	if IsInRaid() and channelDB.raid then
		return channelDB.raid
	elseif IsInGroup() and channelDB.party then
		return channelDB.party
	elseif channelDB.solo then
		return channelDB.solo
	end
	return "NONE"
end

function A:Initialize()
	self.db = E.db.WT.announcement

	if not self.db.enable or self.initialized then
		return
	end

	for _, event in pairs(self.EventList) do
		self:RegisterEvent(event)
	end

	for _, message in pairs(self.MessageList) do
		self:RegisterMessage(message)
	end

	E:RegisterEventForObject("CHALLENGE_MODE_COMPLETED", self, self.CHALLENGE_MODE_COMPLETED)

	self.initialized = true
end

function A:ProfileUpdate()
	self:Initialize()

	if self.db.enable or not self.initialized then
		return
	end

	for _, event in pairs(self.EventList) do
		A:UnregisterEvent(event)
	end

	for _, message in pairs(self.MessageList) do
		A:UnregisterMessage(message)
	end

	E:UnregisterEventForObject("CHALLENGE_MODE_COMPLETED", self, self.CHALLENGE_MODE_COMPLETED)

	self.initialized = false
end

W:RegisterModule(A:GetName())
