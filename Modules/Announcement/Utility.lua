local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local A = W:GetModule("Announcement") ---@class Announcement
local async = W.Utilities.Async

local format = format
local gsub = gsub
local tostring = tostring

local GetSpellLink = GetSpellLink

local function FormatMessage(message, spellID)
	message = gsub(message, "%%player%%", E.name)
	message = gsub(message, "%%spell%%", GetSpellLink(spellID))
	return message
end

local UtilityType = {
	Spell = "spell",
	Feast = "feast",
	Portal = "portal",
	Toy = "toy",
	Bot = "bot",
}

local UtilitySpells = {
	[698] = UtilityType.Spell,
	[29893] = UtilityType.Spell,
	[43987] = UtilityType.Spell,

	[49844] = UtilityType.Toy,
	[61031] = UtilityType.Toy,

	[57301] = UtilityType.Feast,
	[57426] = UtilityType.Feast,
	[58465] = UtilityType.Feast,
	[58474] = UtilityType.Feast,
	[66476] = UtilityType.Feast,

	[10059] = UtilityType.Portal,
	[11416] = UtilityType.Portal,
	[11419] = UtilityType.Portal,
	[32266] = UtilityType.Portal,
	[33691] = UtilityType.Portal,
	[49360] = UtilityType.Portal,
	[11417] = UtilityType.Portal,
	[11418] = UtilityType.Portal,
	[11420] = UtilityType.Portal,
	[32267] = UtilityType.Portal,
	[49361] = UtilityType.Portal,
	[53142] = UtilityType.Portal,

	[22700] = UtilityType.Bot,
	[44389] = UtilityType.Bot,
	[54711] = UtilityType.Bot,
	[67826] = UtilityType.Bot,
}

local UtilitySpellAliases = {
	[58887] = 29893,
	[58659] = 43987,
	[61993] = 698,
	[35717] = 33691,
	[57676] = 33691,
	[316475] = 33691,
	[300059] = 57426,
}

A.ConfigurableUtilitySpells = {}

function A:GetAvailableUtilitySpells()
	async.WithSpellIDTable(UtilitySpells, "key", function(spell)
		local id, tex, name = spell:GetSpellID(), spell:GetSpellTexture(), spell:GetSpellName()
		local desc = format("%s %s (%s)", F.GetIconString(tex, 14, 18, true), name, id)
		self.ConfigurableUtilitySpells[tostring(id)] = desc
	end)
end

function A:Utility(castID)
	local spellID = UtilitySpellAliases[castID] or castID
	if not UtilitySpells[spellID] or not self.db or not self.db.utility then
		return
	end

	local db = self.db.utility
	local config = db.custom[tostring(spellID)] or db.general[UtilitySpells[spellID]]

	if not config or not config.enable then
		return
	end

	self:SendMessage(FormatMessage(config.text, castID), self:GetChannel(db.channel), config.raidWarning)
end
