local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local A = W:GetModule("Announcement") ---@class Announcement

local RunNextFrame = RunNextFrame

A.EventList = {
	"CHALLENGE_MODE_COMPLETED",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_SYSTEM",
	"LFG_COMPLETION_REWARD",
	"PARTY_LEADER_CHANGED",
	"PLAYER_ENTERING_WORLD",
	"UNIT_SPELLCAST_SUCCEEDED",
}

A.MessageList = {
	"WINDTOOLS_PLAYER_KEYSTONE_CHANGED",
}

-- CHAT_MSG_SYSTEM: text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons
function A:CHAT_MSG_SYSTEM(event, text)
	self:ResetInstanceUpdateIgnoreState(event, text)
	RunNextFrame(function()
		self:ResetInstance(text)
	end)
end

function A:CHAT_MSG_PARTY(event, ...)
	self:KeystoneLink(event, ...)
end

function A:CHAT_MSG_PARTY_LEADER(event, ...)
	self:KeystoneLink(event, ...)
end

function A:CHAT_MSG_GUILD(event, ...)
	self:KeystoneLink(event, ...)
end

function A:LFG_COMPLETION_REWARD()
	self:DelayedGoodbye()
end

function A:CHALLENGE_MODE_COMPLETED()
	self:DelayedGoodbye()
end

function A:UNIT_SPELLCAST_SUCCEEDED(_, unit, spellName)
	if unit == "player" and spellName then
		self:Utility(spellName)
	end
end

function A:PARTY_LEADER_CHANGED(event)
	self:ResetInstanceUpdateIgnoreState(event)
end

function A:WINDTOOLS_PLAYER_KEYSTONE_CHANGED(_, ...)
	self:Keystone(...)
end

function A:PLAYER_ENTERING_WORLD()
	self:GetAvailableUtilitySpells()
end
