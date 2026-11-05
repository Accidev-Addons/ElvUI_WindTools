local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local IT = W:NewModule("InterruptTracker", "AceEvent-3.0")

local ipairs = ipairs
local unpack = unpack
local band = bit.band
local tinsert = tinsert
local tremove = tremove
local wipe = wipe

local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime

local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE

local COLUMN, SPACING = 5, 6

local spellList = {
	[72] = 12,
	[408] = 20,
	[8643] = 20,
	[1766] = 10,
	[2139] = 24,
	[6552] = 10,
	[8122] = 23,
	[8124] = 23,
	[10888] = 23,
	[10890] = 23,
	[15487] = 45,
	[16979] = 15,
	[19503] = 30,
	[19244] = 24,
	[19647] = 24,
	[23920] = 10,
	[31224] = 90,
	[34490] = 30,
	[44572] = 30,
	[47528] = 10,
	[48707] = 45,
	[47476] = 120,
	[49916] = 120,
	[51514] = 45,
	[57994] = 6,
}

local active = {}

function IT:CreateIcon(i)
	local icon = CreateFrame("Frame", "WTInterruptTrackerIcon" .. i, self.header)
	icon:SetTemplate()

	icon.texture = icon:CreateTexture(nil, "BORDER")
	icon.texture:SetInside()
	icon.texture:SetTexCoord(unpack(E.TexCoords))

	icon.cooldown = CreateFrame("Cooldown", icon:GetName() .. "Cooldown", icon, "CooldownFrameTemplate")
	icon.cooldown:SetInside()
	E:RegisterCooldown(icon.cooldown)

	if i == 1 then
		icon:Point("CENTER", self.header)
	elseif (i - 1) % COLUMN == 0 then
		icon:Point("RIGHT", self.icons[i - COLUMN], "LEFT", -SPACING, 0)
	else
		icon:Point("TOP", self.icons[i - 1], "BOTTOM", 0, -SPACING)
	end

	self.icons[i] = icon
	return icon
end

function IT:Layout()
	local size = self.db.size
	self.header:Size(size)

	for i, entry in ipairs(active) do
		local icon = self.icons[i] or self:CreateIcon(i)
		icon:Size(size)
		icon.texture:SetTexture(entry.texture)
		icon.cooldown:SetCooldown(entry.start, entry.duration)
		icon:Show()
	end

	for i = #active + 1, #self.icons do
		self.icons[i]:Hide()
	end
end

local function Expire(entry)
	for i, e in ipairs(active) do
		if e == entry then
			tremove(active, i)
			IT:Layout()
			return
		end
	end
end

function IT:COMBAT_LOG_EVENT_UNFILTERED(_, _, subEvent, _, _, sourceFlags, _, _, _, spellID)
	local duration = subEvent == "SPELL_CAST_SUCCESS" and spellList[spellID]
	if not duration or band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= COMBATLOG_OBJECT_REACTION_HOSTILE then
		return
	end

	local _, _, texture = GetSpellInfo(spellID)
	local entry = { texture = texture, start = GetTime(), duration = duration }
	tinsert(active, entry)
	self:Layout()
	E:Delay(duration, Expire, entry)
end

function IT:UpdateState()
	if not self.initialized then
		return
	end

	local db = E.private.WT.combat.interruptTracker
	local _, zoneType = GetInstanceInfo()

	if db.everywhere or (db.arena and zoneType == "arena") or (db.battleground and zoneType == "pvp") then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function IT:PLAYER_ENTERING_WORLD()
	wipe(active)
	self:Layout()
	self:UpdateState()
end

function IT:Initialize()
	if not E.private.WT.combat.interruptTracker.enable then
		return
	end

	self.db = E.db.WT.combat.interruptTracker
	self.icons = {}
	self.header = CreateFrame("Frame", "WTInterruptTracker", E.UIParent)
	self.header:Size(self.db.size)
	self.header:Point("CENTER", E.UIParent, "CENTER", -300, 50)

	E:CreateMover(
		self.header,
		"WTInterruptTrackerMover",
		L["Interrupt Tracker"],
		nil,
		nil,
		nil,
		"ALL,WINDTOOLS",
		nil,
		"WindTools,combat,interruptTracker"
	)

	self.initialized = true
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:UpdateState()
end

function IT:ProfileUpdate()
	if not self.initialized then
		return
	end

	self.db = E.db.WT.combat.interruptTracker
	self:Layout()
end

W:RegisterModule(IT:GetName())
