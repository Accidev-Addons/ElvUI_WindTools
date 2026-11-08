local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins
local GB = W:NewModule("GameBar", "AceEvent-3.0", "AceHook-3.0")
local DT = E:GetModule("DataTexts")
local async = W.Utilities.Async
local C = W.Utilities.Color

local _G = _G
local collectgarbage = collectgarbage
local date = date
local floor = floor
local format = format
local gsub = gsub
local ipairs = ipairs
local max = max
local min = min
local mod = mod
local pairs = pairs
local random = random
local select = select
local strfind = strfind
local tContains = tContains
local tinsert = tinsert
local tonumber = tonumber
local tostring = tostring
local type = type

local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GenerateClosure = GenerateClosure
local GetBindLocation = GetBindLocation
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetFramerate = GetFramerate
local GetGameTime = GetGameTime
local GetNetStats = GetNetStats
local GetNumGuildMembers = GetNumGuildMembers
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsInGuild = IsInGuild
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local PlayerHasToy = PlayerHasToy
local RegisterStateDriver = RegisterStateDriver
local ReloadUI = ReloadUI
local ResetCPUUsage = ResetCPUUsage
local Screenshot = Screenshot
local SetCVar = SetCVar
local ShowUIPanel = ShowUIPanel
local ToggleCalendar = ToggleCalendar
local ToggleTimeManager = ToggleTimeManager
local UnregisterStateDriver = UnregisterStateDriver

local C_Item_GetItemCooldown = GetItemCooldown
local C_Item_GetItemCount = GetItemCount
local C_SpellBook_IsSpellKnown = IsSpellKnown
local C_Spell_GetSpellCooldown = GetSpellCooldown
local function C_Timer_NewTicker(delay, callback)
	return C_Timer:NewTicker(delay, callback)
end

local RED_FONT_COLOR = RED_FONT_COLOR

local NUM_PANEL_BUTTONS = 7
local BUTTON_ACTION_ATTRIBUTES = {
	"type*", "macrotext1", "macrotext2", "macrotext3", "item1", "item2", "clickbutton",
}
local ICON_STRING = "|T%s:16:18:0:0:64:64:4:60:7:57"
local LEFT_BUTTON_ICON = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t"
local RIGHT_BUTTON_ICON = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t"
local SCROLL_BUTTON_ICON = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t"
local ASTRAL_RECALL_SPELL_ID = 556
local ASTRAL_RECALL_KEY = "SPELL:556"

local HEARTSTONE_SIDE_SETTINGS = {
	left = {
		primaryKey = "left",
		fallbackKey = "leftFallback",
		attribute = "macrotext1",
		tooltipPrefix = LEFT_BUTTON_ICON,
	},
	middle = {
		primaryKey = "middle",
		fallbackKey = "middleFallback",
		attribute = "macrotext3",
		tooltipPrefix = SCROLL_BUTTON_ICON,
	},
	right = {
		primaryKey = "right",
		fallbackKey = "rightFallback",
		attribute = "macrotext2",
		tooltipPrefix = RIGHT_BUTTON_ICON,
	},
}

local friendOnline = gsub(_G.ERR_FRIEND_ONLINE_SS, "\124Hplayer:%%s\124h%[%%s%]\124h", "")
local friendOffline = gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "")

GB.AnimationManager = { frame = nil, groups = nil }

local hearthstones = {
	6948,
	54452,
	64488,
	93672,
}

local hearthstoneAndToyIDList = {
	6948,
	54452,
	64488,
	93672,
	18984,
	18986,
	30542,
	30544,
	48933,
	87215,
}

local hearthstonesAndToysData
local availableHearthstones

local function copyRGB(color, target)
	target.r = color.r
	target.g = color.g
	target.b = color.b
end

local function updateSystemInfo(panel)
	local hex = E.media.hexvaluecolor
	panel.text:SetFormattedText("FPS: %s%d|r MS: %s%d|r", hex, GetFramerate(), hex, select(3, GetNetStats()))
end

function GB.AnimationManager:Drop()
	self.frame = nil
	self.groups = nil
end

function GB.AnimationManager:DropIfMatched(frame, group)
	if frame and self.frame == frame or self.groups and tContains(self.groups, group) then
		self:Drop()
	end
end

function GB.AnimationManager:SetCurrent(frame, groups)
	if self.frame and self.frame ~= frame or self.groups and tContains(self.groups, groups[1]) then
		E:Delay(0.01, GB.AnimationOnLeave, GB, self.frame)
	end
	self.frame = frame
	self.groups = groups
end

local function animationReset(self)
	self.StartR, self.StartG, self.StartB = GB.normalRGB.r, GB.normalRGB.g, GB.normalRGB.b
	self.EndR, self.EndG, self.EndB = GB.mouseOverRGB.r, GB.mouseOverRGB.g, GB.mouseOverRGB.b
	self:SetChange(self.EndR - self.StartR, self.EndG - self.StartG, self.EndB - self.StartB)
	self:SetDuration(GB.animationDuration)
	self:SetEasing(GB.animationInEase)
	self:Reset()
end

local function animationSwitch(self, isEnterMode)
	local elapsed = min(max(0, self:GetProgressByTimer()), GB.animationDuration)
	self.Timer = isEnterMode == self.isEnterMode and elapsed or (GB.animationDuration - elapsed)
	local startRGB = isEnterMode and GB.normalRGB or GB.mouseOverRGB
	local endRGB = isEnterMode and GB.mouseOverRGB or GB.normalRGB
	self.StartR, self.StartG, self.StartB = startRGB.r, startRGB.g, startRGB.b
	self.EndR, self.EndG, self.EndB = endRGB.r, endRGB.g, endRGB.b
	self:SetChange(endRGB.r, endRGB.g, endRGB.b)
	self:SetEasing(isEnterMode and GB.animationInEase or GB.animationOutEase)
	self.isEnterMode = isEnterMode
end

local function copyAnimationData(self, target)
	target.StartR, target.StartG, target.StartB = self.StartR, self.StartG, self.StartB
	target.EndR, target.EndG, target.EndB = self.EndR, self.EndG, self.EndB
	target:SetChange(self:GetChange())
	target:SetDuration(self:GetDuration())
	target:SetEasing(self:GetEasing())
	target.Timer = self.Timer
	target.isEnterMode = self.isEnterMode
end

local function animationSetFinished(anim)
	anim:SetScript("OnFinished", function(self)
		if not self.isEnterMode then
			GB.AnimationManager:DropIfMatched(nil, self.Group)
		end
	end)
end

function GB:AnimationOnEnter(button)
	if button.mainTex then
		local group, anim = button.mainTex.group, button.mainTex.group.anim
		if group:IsPlaying() then
			group:Pause()
		end

		animationSwitch(anim, true)
		group:Play()

		self.AnimationManager:SetCurrent(button, { group })
		return
	end

	if button.hour and button.minutes then
		local group1, anim1 = button.hour.group, button.hour.group.anim
		local group2, anim2 = button.minutes.group, button.minutes.group.anim
		if group1:IsPlaying() then
			group1:Pause()
		end
		if group2:IsPlaying() then
			group2:Pause()
		end

		animationSwitch(anim1, true)
		copyAnimationData(anim1, anim2)
		group1:Play()
		group2:Play()

		self.AnimationManager:SetCurrent(button, { group1, group2 })
	end
end
function GB:AnimationOnLeave(button)
	if button.mainTex then
		local group, anim = button.mainTex.group, button.mainTex.group.anim
		if group:IsPlaying() then
			group:Pause()
		end

		animationSwitch(anim, false)
		group:Play()
	end

	if button.hour and button.minutes then
		local group1, anim1 = button.hour.group, button.hour.group.anim
		local group2, anim2 = button.minutes.group, button.minutes.group.anim
		if group1:IsPlaying() then
			group1:Pause()
		end
		if group2:IsPlaying() then
			group2:Pause()
		end

		animationSwitch(anim1, false)
		animationSwitch(anim2, false)
		group1:Play()
		group2:Play()
	end
end

function GB:GetHearthstoneSetting(side)
	if not self.db or not self.db.hearthstone then
		return nil, nil
	end

	local sideSettings = HEARTSTONE_SIDE_SETTINGS[side] or HEARTSTONE_SIDE_SETTINGS.left

	local primary = self.db.hearthstone[sideSettings.primaryKey]
	local fallback = self.db.hearthstone[sideSettings.fallbackKey]

	return primary and tostring(primary) or nil, fallback and tostring(fallback) or nil
end

local function IsHearthstoneActionUsable(actionData)
	if not actionData then
		return false
	end

	if actionData.actionType == "spell" then
		return C_SpellBook_IsSpellKnown(actionData.actionID)
	elseif actionData.actionType == "toy" then
		return PlayerHasToy(actionData.actionID)
	elseif actionData.actionType == "random" then
		return availableHearthstones and #availableHearthstones > 0
	elseif actionData.actionType == "item" then
		local usesCount = C_Item_GetItemCount(actionData.actionID, nil, true)
		if usesCount and usesCount > 0 then
			return true
		end
		return PlayerHasToy(actionData.actionID)
	end

	return false
end

function GB:ResolveHearthstoneAction(side)
	if not hearthstonesAndToysData then
		return nil
	end

	local primary, fallback = self:GetHearthstoneSetting(side)
	local primaryData = primary and hearthstonesAndToysData[primary] or nil

	if IsHearthstoneActionUsable(primaryData) then
		return primaryData
	end

	local fallbackData = fallback and hearthstonesAndToysData[fallback] or nil
	if IsHearthstoneActionUsable(fallbackData) then
		return fallbackData
	end

	return nil
end

local function AddDoubleLineForItem(actionData, prefix, button, side)
	if not actionData then
		return
	end

	prefix = prefix and prefix .. " " or ""

	-- For random hearthstones, use the icon of the actual selected hearthstone
	local iconID = actionData.icon
	local cooldownAction = actionData
	if actionData.actionType == "random" and button and side and availableHearthstones then
		local randomIndex = button["randomHearthstoneIndex" .. side]
		if randomIndex then
			local actualItemID = availableHearthstones[randomIndex]
			if actualItemID and hearthstonesAndToysData and hearthstonesAndToysData[tostring(actualItemID)] then
				cooldownAction = hearthstonesAndToysData[tostring(actualItemID)]
				iconID = cooldownAction.icon
			end
		end
	end

	local icon = format(ICON_STRING .. ":255:255:255|t", iconID)

	local startTime, duration = 0, 0
	if cooldownAction.actionType == "spell" or cooldownAction.actionType == "toy" then
		startTime, duration = C_Spell_GetSpellCooldown(cooldownAction.spellID or cooldownAction.actionID)
	else
		startTime, duration = C_Item_GetItemCooldown(cooldownAction.actionID)
	end

	local cooldownTime = (startTime or 0) + (duration or 0) - GetTime()
	local canUse = cooldownTime <= 0
	local cooldownTimeString
	if not canUse then
		local m = floor(cooldownTime / 60)
		local s = floor(mod(cooldownTime, 60))
		cooldownTimeString = format("%02d:%02d", m, s)
	end

	local name = actionData.name

	if actionData.actionType == "random" then
		name = L["Random Hearthstone"]
	end

	if
		GB.db
		and GB.db.hearthstone
		and GB.db.hearthstone.showBindLocation
		and (
			actionData.actionType == "item" and tContains(hearthstones, actionData.actionID)
			or actionData.actionType == "spell" and actionData.actionID == ASTRAL_RECALL_SPELL_ID
			or actionData.actionType == "random"
		)
	then
		local bindLocation = GetBindLocation()
		if bindLocation and bindLocation ~= "" then
			name = name .. format(" > %s", bindLocation)
		end
	end

	DT.tooltip:AddDoubleLine(
		prefix .. icon .. " " .. name,
		canUse and L["Ready"] or cooldownTimeString,
		1,
		1,
		1,
		canUse and 0 or 1,
		canUse and 1 or 0,
		0
	)
end

local VirtualDTEvent = {
	Friends = nil,
	Guild = "GUILD_ROSTER_UPDATE",
	Time = "UPDATE_INSTANCE_INFO",
}

local VirtualDT = {}
for _, name in ipairs({ "Friends", "Guild", "System", "Time" }) do
	local frame = CreateFrame("Frame")
	frame:Hide()
	frame.name = name
	frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	VirtualDT[name] = frame
end

local sharedCache = {
	friends = {},
}

local ButtonTypes = {
	ACHIEVEMENTS = {
		name = L["Achievements"],
		icon = W.Media.Icons.barAchievements,
		macro = {
			LeftButton = _G.SLASH_ACHIEVEMENTUI1,
		},
		tooltips = {
			L["Achievements"],
		},
	},
	BAGS = {
		name = L["Bags"],
		icon = W.Media.Icons.barBags,
		click = {
			LeftButton = function()
				_G.ToggleAllBags()
			end,
		},
		tooltips = "Bags",
	},
	BLIZZARD_SHOP = {
		name = L["Blizzard Shop"],
		icon = W.Media.Icons.barBlizzardShop,
		macro = {
			LeftButton = "/click StoreMicroButton",
		},
		tooltips = {
			L["Blizzard Shop"],
		},
	},
	CHARACTER = {
		name = L["Character"],
		icon = W.Media.Icons.barCharacter,
		macro = {
			LeftButton = "/click CharacterMicroButton",
		},
		tooltips = {
			L["Character"],
		},
	},
	COLLECTIONS = {
		name = L["Collections"],
		icon = W.Media.Icons.barCollections,
		macro = {
			LeftButton = "/click CollectionsJournalCloseButton\n/click CollectionsMicroButton\n/click CollectionsJournalTab1",
			RightButton = "/click MountJournalSummonRandomFavoriteButton",
		},
		tooltips = {
			L["Collections"],
			"\n",
			LEFT_BUTTON_ICON .. " " .. L["Show Collections"],
			RIGHT_BUTTON_ICON .. " " .. L["Random Favorite Mount"],
		},
	},
	ENCOUNTER_JOURNAL = {
		name = L["Encounter Journal"],
		icon = W.Media.Icons.barEncounterJournal,
		macro = {
			LeftButton = "/click EncounterJournalMicroButton",
		},
		tooltips = {
			LEFT_BUTTON_ICON .. " " .. L["Encounter Journal"],
		},
	},
	FRIENDS = {
		name = L["Friend List"],
		icon = W.Media.Icons.barFriends,
		macro = {
			LeftButton = "/click FriendsMicroButton",
		},
		additionalText = function()
			local online = 0
			for index = 1, GetNumFriends() do
				if select(5, GetFriendInfo(index)) then
					online = online + 1
				end
			end
			return online > 0 and online or ""
		end,
		tooltips = "Friends",
		events = {
			"FRIENDLIST_UPDATE",
			"CHAT_MSG_SYSTEM",
		},
		eventHandler = function(button, event, message)
			if event == "CHAT_MSG_SYSTEM" then
				if not (strfind(message, friendOnline) or strfind(message, friendOffline)) then
					return
				end
			end
			local now = GetTime()
			local cache = sharedCache.friends
			if now - (cache.lastEvent or 0) > 1 then
				cache.lastEvent = now
				E:Delay(1, function()
					button.additionalText:SetFormattedText(button.additionalTextFormat, button.additionalTextFunc())
				end)
			end
		end,
	},
	GAMEMENU = {
		name = L["Game Menu"],
		icon = W.Media.Icons.barGameMenu,
		click = {
			LeftButton = function()
				if not InCombatLockdown() then
					-- Open game menu | From ElvUI
					if not _G.GameMenuFrame:IsShown() then
						CloseMenus()
						CloseAllWindows()
						PlaySound(850) --IG_MAINMENU_OPEN
						ShowUIPanel(_G.GameMenuFrame)
					else
						PlaySound(854) --IG_MAINMENU_QUIT
						HideUIPanel(_G.GameMenuFrame)
					end
				else
					_G.UIErrorsFrame:AddMessage(_G.ERR_NOT_IN_COMBAT, RED_FONT_COLOR:GetRGBA())
				end
			end,
		},
		tooltips = {
			L["Game Menu"],
		},
	},
	GROUP_FINDER = {
		name = L["Group Finder"],
		icon = W.Media.Icons.barGroupFinder,
		macro = {
			LeftButton = "/click LFDMicroButton",
		},
		tooltips = {
			LEFT_BUTTON_ICON .. " " .. L["Group Finder"],
		},
	},
	GUILD = {
		name = L["Guild"],
		icon = W.Media.Icons.barGuild,
		macro = {
			LeftButton = "/click GuildMicroButton",
		},
		additionalText = function()
			return IsInGuild() and GetNumGuildMembers() or ""
		end,
		tooltips = "Guild",
		events = {
			"GUILD_ROSTER_UPDATE",
			"PLAYER_GUILD_UPDATE",
		},
		eventHandler = function(button, event, message)
			button.additionalText:SetFormattedText(button.additionalTextFormat, button.additionalTextFunc())
		end,
	},
	HEARTHSTONE = {
		name = L["Hearthstone"],
		icon = W.Media.Icons.barHearthstone,
		item = {},
		tooltips = function(button)
			local function Update()
				DT.tooltip:ClearLines()
				DT.tooltip:SetText(L["Hearthstone"])
				DT.tooltip:AddLine("\n")
				for _, side in ipairs({ "left", "middle", "right" }) do
					local sideSettings = HEARTSTONE_SIDE_SETTINGS[side]
					AddDoubleLineForItem(GB:ResolveHearthstoneAction(side), sideSettings.tooltipPrefix, button, side)
				end
				DT.tooltip:Show()
			end

			button.tooltipsUpdateTimer = C_Timer_NewTicker(1, Update)
			Update()
		end,
		tooltipsLeave = function(button)
			if button.tooltipsUpdateTimer and button.tooltipsUpdateTimer.Cancel then
				button.tooltipsUpdateTimer:Cancel()
			end
		end,
	},
	NONE = {
		name = L["None"],
	},
	PET_JOURNAL = {
		name = L["Pet Journal"],
		icon = W.Media.Icons.barPetJournal,
		macro = {
			LeftButton = "/click CollectionsJournalCloseButton\n/click CollectionsMicroButton\n/click CollectionsJournalTab2",
			RightButton = "/click PetJournalSummonRandomFavoritePetButton",
		},
		tooltips = {
			L["Pet Journal"],
			"\n",
			LEFT_BUTTON_ICON .. " " .. L["Show Pet Journal"],
			RIGHT_BUTTON_ICON .. " " .. L["Random Favorite Pet"],
		},
	},
	PROFESSION = {
		name = L["Profession"],
		icon = W.Media.Icons.barProfession,
		macro = {
			LeftButton = "/click SpellBookFrameCloseButton\n/click SpellbookMicroButton\n/click SpellBookFrameTab2",
		},
		tooltips = {
			L["Profession"],
		},
	},
	SCREENSHOT = {
		name = L["Screenshot"],
		icon = W.Media.Icons.barScreenShot,
		click = {
			LeftButton = function()
				DT.tooltip:Hide()
				Screenshot()
			end,
			RightButton = function()
				E:Delay(2, function()
					Screenshot()
				end)
			end,
		},
		tooltips = {
			L["Screenshot"],
			"\n",
			LEFT_BUTTON_ICON .. " " .. L["Screenshot immediately"],
			RIGHT_BUTTON_ICON .. " " .. L["Screenshot after 2 secs"],
		},
	},
	SPELLBOOK = {
		name = L["Spell Book"],
		icon = W.Media.Icons.barSpellBook,
		macro = {
			LeftButton = "/click SpellbookMicroButton",
		},
		tooltips = {
			L["Spell Book"],
		},
	},
	TALENTS = {
		name = L["Talents"],
		icon = W.Media.Icons.barTalents,
		macro = {
			LeftButton = "/click TalentMicroButton",
		},
		tooltips = {
			L["Talents"],
		},
	},
	TOY_BOX = {
		name = L["Toy Box"],
		icon = W.Media.Icons.barToyBox,
		macro = {
			LeftButton = "/click CollectionsJournalCloseButton\n/click CollectionsMicroButton\n/click CollectionsJournalTab4",
		},
		tooltips = {
			L["Toy Box"],
		},
	},
	VOLUME = {
		name = L["Volume"],
		icon = W.Media.Icons.barVolume,
		click = {
			LeftButton = function()
				local vol = GetCVar("Sound_MasterVolume")
				local volNum = vol and tonumber(vol) or 0
				SetCVar("Sound_MasterVolume", min(volNum + 0.1, 1))
			end,
			MiddleButton = function()
				local enabled = tonumber(GetCVar("Sound_EnableAllSound")) == 1
				SetCVar("Sound_EnableAllSound", enabled and 0 or 1)
			end,
			RightButton = function()
				local vol = GetCVar("Sound_MasterVolume")
				local volNum = vol and tonumber(vol) or 0
				SetCVar("Sound_MasterVolume", max(volNum - 0.1, 0))
			end,
		},
		tooltips = function(button)
			local vol = GetCVar("Sound_MasterVolume")
			local volNum = vol and tonumber(vol) or 0
			DT.tooltip:ClearLines()
			DT.tooltip:SetText(L["Volume"] .. format(": %d%%", volNum * 100))
			DT.tooltip:AddLine("\n")
			DT.tooltip:AddLine(LEFT_BUTTON_ICON .. " " .. L["Increase the volume"] .. " (+10%)", 1, 1, 1)
			DT.tooltip:AddLine(RIGHT_BUTTON_ICON .. " " .. L["Decrease the volume"] .. " (-10%)", 1, 1, 1)
			DT.tooltip:AddLine(SCROLL_BUTTON_ICON .. " " .. L["Sound ON/OFF"], 1, 1, 1)
			DT.tooltip:Show()

			button.tooltipsUpdateTimer = C_Timer_NewTicker(0.3, function()
				local _vol = GetCVar("Sound_MasterVolume")
				local _volNum = _vol and tonumber(_vol) or 0
				DT.tooltip:ClearLines()
				DT.tooltip:SetText(L["Volume"] .. format(": %d%%", _volNum * 100))
				DT.tooltip:AddLine("\n")
				DT.tooltip:AddLine(LEFT_BUTTON_ICON .. " " .. L["Increase the volume"] .. " (+10%)", 1, 1, 1)
				DT.tooltip:AddLine(RIGHT_BUTTON_ICON .. " " .. L["Decrease the volume"] .. " (-10%)", 1, 1, 1)
				DT.tooltip:AddLine(SCROLL_BUTTON_ICON .. " " .. L["Sound ON/OFF"], 1, 1, 1)
				DT.tooltip:Show()
			end)
		end,
		tooltipsLeave = function(button)
			if button.tooltipsUpdateTimer and button.tooltipsUpdateTimer.Cancel then
				button.tooltipsUpdateTimer:Cancel()
			end
		end,
	},
}

function GB:OnEnter()
	if self.db and self.db.mouseOver then
		E:UIFrameFadeIn(self.bar, self.db.fadeTime, self.bar:GetAlpha(), 1)
	end
end

function GB:OnLeave()
	if self.db and self.db.mouseOver then
		E:UIFrameFadeOut(self.bar, self.db.fadeTime, self.bar:GetAlpha(), 0)
	end
end

function GB:ConstructBar()
	if self.bar then
		return
	end

	local bar = CreateFrame("Frame", "WTGameBar", E.UIParent)
	bar:Size(800, 60)
	bar:Point("TOP", 0, -20)
	bar:SetFrameStrata("MEDIUM")

	bar:SetScript("OnEnter", GenerateClosure(self.OnEnter, self))
	bar:SetScript("OnLeave", GenerateClosure(self.OnLeave, self))

	local middlePanel = CreateFrame("Button", "WTGameBarMiddlePanel", bar, "SecureActionButtonTemplate")
	middlePanel:Size(81, 50)
	middlePanel:Point("CENTER")
	middlePanel:CreateBackdrop("Transparent")
	middlePanel:RegisterForClicks(W.UseKeyDown and "AnyDown" or "AnyUp")
	bar.middlePanel = middlePanel

	local leftPanel = CreateFrame("Frame", "WTGameBarLeftPanel", bar)
	leftPanel:Size(300, 40)
	leftPanel:Point("RIGHT", middlePanel, "LEFT", -10, 0)
	leftPanel:CreateBackdrop("Transparent")
	bar.leftPanel = leftPanel

	local rightPanel = CreateFrame("Frame", "WTGameBarRightPanel", bar)
	rightPanel:Size(300, 40)
	rightPanel:Point("LEFT", middlePanel, "RIGHT", 10, 0)
	rightPanel:CreateBackdrop("Transparent")
	bar.rightPanel = rightPanel

	S:CreateShadowModule(leftPanel.backdrop)
	S:CreateShadowModule(middlePanel.backdrop)
	S:CreateShadowModule(rightPanel.backdrop)
	S:MerathilisUISkin(leftPanel.backdrop)
	S:MerathilisUISkin(middlePanel.backdrop)
	S:MerathilisUISkin(rightPanel.backdrop)

	self.bar = bar

	E:CreateMover(self.bar, "WTGameBarAnchor", L["Game Bar"], nil, nil, nil, "ALL,WINDTOOLS", function()
		return GB.db and GB.db.enable
	end, "WindTools,misc,gameBar")
end

function GB:UpdateBar()
	if self.db and self.db.mouseOver then
		self.bar:SetAlpha(0)
	else
		self.bar:SetAlpha(1)
	end

	RegisterStateDriver(self.bar, "visibility", self.db.visibility)
end

function GB:ConstructTimeArea()
	local colon = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	colon:Point("CENTER")
	F.SetFontWithDB(colon, self.db.time.font)
	self.bar.middlePanel.colon = colon

	local hour = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	hour:Point("RIGHT", colon, "LEFT", 1, 0)
	F.SetFontWithDB(hour, self.db.time.font)
	self.bar.middlePanel.hour = hour

	hour.group = _G.CreateAnimationGroup(hour)
	hour.group.anim = hour.group:CreateAnimation("color")
	hour.group.anim:SetColorType("text")
	animationSetFinished(hour.group.anim)

	local minutes = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	minutes:Point("LEFT", colon, "RIGHT", 0, 0)
	F.SetFontWithDB(minutes, self.db.time.font)
	self.bar.middlePanel.minutes = minutes

	minutes.group = _G.CreateAnimationGroup(minutes)
	minutes.group.anim = minutes.group:CreateAnimation("color")
	minutes.group.anim:SetColorType("text")

	local text = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	text:Point("TOP", self.bar, "BOTTOM", 0, -5)
	F.SetFontWithDB(text, self.db.time.systemInfoFont)
	text:SetAlpha(self.db.time.alwaysSystemInfo and 1 or 0)
	self.bar.middlePanel.text = text

	self.bar.middlePanel:Size(self.db.timeAreaWidth, self.db.timeAreaHeight)

	self:UpdateTime()
	self.timeAreaUpdateTimer = C_Timer_NewTicker(self.db.time.interval, function()
		GB:UpdateTime()
	end)

	DT.RegisteredDataTexts["Time"].eventFunc(VirtualDT["Time"], "ELVUI_FORCE_UPDATE")
	updateSystemInfo(self.bar.middlePanel)

	if self.db.time.alwaysSystemInfo then
		self.alwaysSystemInfoTimer = C_Timer_NewTicker(1, function()
			updateSystemInfo(self.bar.middlePanel)
		end)
	end

	self:HookScript(self.bar.middlePanel, "OnEnter", function(panel)
		if self.tooltipTimer then
			self.tooltipTimer:Cancel()
			self.tooltipTimer = nil
		end

		self:OnEnter()
		self:AnimationOnEnter(panel)

		updateSystemInfo(panel)
		if not self.db.time.alwaysSystemInfo then
			E:UIFrameFadeIn(panel.text, self.db.fadeTime, panel.text:GetAlpha(), 1)
		end

		if self.db.tooltipsAnchor == "ANCHOR_TOP" then
			DT.tooltip:SetOwner(panel, "ANCHOR_TOP", 0, 10)
		else
			DT.tooltip:SetOwner(panel, "ANCHOR_NONE")
			DT.tooltip:ClearAllPoints()
			DT.tooltip:SetPoint("TOP", panel.text, "BOTTOM", 0, -10)
		end

		if IsModifierKeyDown() then
			DT.RegisteredDataTexts["System"].eventFunc()
			DT.RegisteredDataTexts["System"].onEnter()

			self.tooltipTimer = C_Timer_NewTicker(1, function()
				updateSystemInfo(panel)
				DT.RegisteredDataTexts["System"].eventFunc()
				DT.RegisteredDataTexts["System"].onEnter()
			end)
		else
			DT.RegisteredDataTexts["Time"].eventFunc(VirtualDT["Time"], VirtualDTEvent["Time"])
			DT.RegisteredDataTexts["Time"].onEnter()
			DT.RegisteredDataTexts["Time"].onLeave()

			self.tooltipTimer = C_Timer_NewTicker(1, function()
				updateSystemInfo(panel)
			end)

			DT.tooltip:AddLine("\n")
			DT.tooltip:AddDoubleLine(format("%s %s", LEFT_BUTTON_ICON, L["Left Button"]), L["Calendar"], 1, 1, 1)
			DT.tooltip:AddDoubleLine(format("%s %s", RIGHT_BUTTON_ICON, L["Right Button"]), L["Time Manager"], 1, 1, 1)
			DT.tooltip:AddDoubleLine(format("%s %s", SCROLL_BUTTON_ICON, L["Middle Button"]), L["Reload UI"], 1, 1, 1)
			DT.tooltip:AddDoubleLine(format("Shift + %s", L["Any"]), L["Collect Garbage"], 1, 1, 1)
			DT.tooltip:AddDoubleLine(format("Ctrl + Shift + %s", L["Any"]), L["Toggle CPU Profiling"], 1, 1, 1)

			DT.tooltip:Show()
		end
	end)

	self:HookScript(self.bar.middlePanel, "OnLeave", function(panel)
		if self.tooltipTimer then
			self.tooltipTimer:Cancel()
			self.tooltipTimer = nil
		end

		self:OnLeave()
		self:AnimationOnLeave(panel)

		if not self.db.time.alwaysSystemInfo then
			E:UIFrameFadeOut(panel.text, self.db.fadeTime, panel.text:GetAlpha(), 0)
		end

		DT.RegisteredDataTexts["System"].onLeave()
		DT.tooltip:Hide()
	end)

	self.bar.middlePanel:SetScript("OnClick", function(_, mouseButton)
		if IsShiftKeyDown() then
			if IsControlKeyDown() then
				SetCVar("scriptProfile", GetCVarBool("scriptProfile") and 0 or 1)
				ReloadUI()
			else
				collectgarbage("collect")
				ResetCPUUsage()
				DT.RegisteredDataTexts["System"].eventFunc()
				DT.RegisteredDataTexts["System"].onEnter()
			end
		elseif mouseButton == "LeftButton" then
			if not InCombatLockdown() then
				ToggleCalendar()
			else
				_G.UIErrorsFrame:AddMessage(_G.ERR_NOT_IN_COMBAT, RED_FONT_COLOR:GetRGBA())
			end
		elseif mouseButton == "RightButton" then
			ToggleTimeManager()
		elseif mouseButton == "MiddleButton" then
			if not InCombatLockdown() or not self.db.time.avoidReloadInCombat then
				ReloadUI()
			end
		end
	end)
end

function GB:UpdateTimeTicker()
	self.timeAreaUpdateTimer:Cancel()
	self.timeAreaUpdateTimer = C_Timer_NewTicker(self.db.time.interval, function()
		GB:UpdateTime()
	end)
end
function GB:UpdateTime()
	local panel = self.bar.middlePanel
	if not panel or not self.db or not self.db.time or not self.db.additionalText then
		return
	end

	F.SetFontWithDB(panel.hour, self.db.time.font)
	F.SetFontWithDB(panel.minutes, self.db.time.font)
	F.SetFontWithDB(panel.colon, self.db.time.font)
	F.SetFontWithDB(panel.text, self.db.time.systemInfoFont)

	panel.hour.group:Stop()
	animationReset(panel.hour.group.anim)
	panel.hour.group.anim.isEnterMode = true

	panel.minutes.group:Stop()
	animationReset(panel.minutes.group.anim)
	panel.minutes.group.anim.isEnterMode = true

	local hour, minute

	if self.db.time.localTime then
		hour = self.db.time.twentyFour and date("%H") or date("%I")
		minute = date("%M")
	else
		hour, minute = GetGameTime()
		hour = self.db.time.twentyFour and hour or mod(hour, 12)
		hour = format("%02d", hour)
		minute = format("%02d", minute)
	end

	panel.colon:SetText(C.StringWithRGB(":", self.mouseOverRGB))
	panel.hour:SetText(hour)
	panel.minutes:SetText(minute)
	panel.colon:ClearAllPoints()

	local offset = (panel.hour:GetStringWidth() - panel.minutes:GetStringWidth()) / 2
	panel.colon:Point("CENTER", offset, -1)
end

function GB:UpdateTimeArea()
	local panel = self.bar.middlePanel

	if self.db.time.flash then
		E:Flash(panel.colon, 1, true)
	else
		E:StopFlash(panel.colon)
	end

	panel.text:ClearAllPoints()
	if self.db.tooltipsAnchor == "ANCHOR_TOP" then
		panel.text:Point("BOTTOM", self.bar, "TOP", 0, 5)
	else
		panel.text:Point("TOP", self.bar, "BOTTOM", 0, -5)
	end

	if self.db.time.alwaysSystemInfo then
		updateSystemInfo(panel)
		panel.text:SetAlpha(1)
		-- Cancel old timer if exists and running
		if self.alwaysSystemInfoTimer and not self.alwaysSystemInfoTimer:IsCancelled() then
			self.alwaysSystemInfoTimer:Cancel()
		end
		-- Always create new timer to ensure fresh state
		self.alwaysSystemInfoTimer = C_Timer_NewTicker(1, function()
			updateSystemInfo(panel)
		end)
	else
		panel.text:SetAlpha(0)
		if self.alwaysSystemInfoTimer and not self.alwaysSystemInfoTimer:IsCancelled() then
			self.alwaysSystemInfoTimer:Cancel()
		end
	end

	self:UpdateTime()
end

function GB:ButtonOnEnter(button)
	self:AnimationOnEnter(button)
	self:OnEnter()
	if button.tooltips then
		if self.db.tooltipsAnchor == "ANCHOR_TOP" then
			DT.tooltip:SetOwner(button, "ANCHOR_TOP", 0, 20)
		else
			DT.tooltip:SetOwner(button, "ANCHOR_BOTTOM", 0, -10)
		end

		if type(button.tooltips) == "table" then
			DT.tooltip:ClearLines()
			for index, line in ipairs(button.tooltips) do
				if index == 1 then
					DT.tooltip:SetText(line)
				else
					DT.tooltip:AddLine(line, 1, 1, 1)
				end
			end
			DT.tooltip:Show()
		elseif type(button.tooltips) == "string" then
			local DTModule = DT.RegisteredDataTexts[button.tooltips]

			if VirtualDT[button.tooltips] and DTModule and DTModule.eventFunc then
				DTModule.eventFunc(VirtualDT[button.tooltips], VirtualDTEvent[button.tooltips])
			end

			if DTModule and DTModule.onEnter then
				DTModule.onEnter()
			end

			-- If ElvUI Datatext tooltip not shown, display a simple information (e.g. button name) to player
			if not DT.tooltip:IsShown() then
				DT.tooltip:ClearLines()
				DT.tooltip:SetText(button.name)
				DT.tooltip:Show()
			end
		elseif type(button.tooltips) == "function" then
			button.tooltips(button)
		end
	end

end

function GB:ButtonOnLeave(button)
	self:AnimationOnLeave(button)
	self:OnLeave()
	DT.tooltip:Hide()
	if button.tooltipsLeave then
		button.tooltipsLeave(button)
	end
end

function GB:ConstructButton()
	if not self.bar then
		return
	end

	local button = CreateFrame("Button", nil, self.bar, "SecureActionButtonTemplate")
	button:Size(self.db.buttonSize, self.db.buttonSize)
	button:RegisterForClicks(W.UseKeyDown and "AnyDown" or "AnyUp")

	local mainTex = button:CreateTexture(nil, "ARTWORK")
	mainTex:Point("CENTER")
	mainTex:Size(self.db.buttonSize, self.db.buttonSize)
	mainTex.group = _G.CreateAnimationGroup(mainTex)
	mainTex.group.anim = mainTex.group:CreateAnimation("color")
	mainTex.group.anim:SetColorType("vertex")
	animationSetFinished(mainTex.group.anim)
	button.mainTex = mainTex

	local additionalText = button:CreateFontString(nil, "OVERLAY")
	additionalText:Point(self.db.additionalText.anchor, self.db.additionalText.x, self.db.additionalText.y)
	F.SetFontWithDB(additionalText, self.db.additionalText.font)
	additionalText:SetJustifyH("CENTER")
	additionalText:SetJustifyV("MIDDLE")
	button.additionalText = additionalText

	self:HookScript(button, "OnEnter", "ButtonOnEnter")
	self:HookScript(button, "OnLeave", "ButtonOnLeave")

	tinsert(self.buttons, button)
end

_G.WTGameBar_UpdateHearthstoneButtons = function()
	F.TaskManager:OutOfCombat(function()
		for _, btn in pairs(GB.HearthstoneButtons) do
			if btn.type == "HEARTHSTONE" then
				for _, side in ipairs({ "left", "middle", "right" }) do
					GB:UpdateHearthstoneButtonMacro(btn, side)
				end
			end
		end
	end)
end

function GB:UpdateButton(button, buttonType)
	if InCombatLockdown() then
		return
	end

	if not ButtonTypes[buttonType] then
		buttonType = "NONE"
	end
	local config = ButtonTypes[buttonType]
	button:Size(self.db.buttonSize, self.db.buttonSize)
	button.type = buttonType
	button.name = config.name
	button.tooltips = config.tooltips
	button.tooltipsLeave = config.tooltipsLeave

	for _, attribute in ipairs(BUTTON_ACTION_ATTRIBUTES) do
		button:SetAttribute(attribute, nil)
	end
	button.Click = nil

	-- Click
	if buttonType == "HEARTHSTONE" then
		button:SetAttribute("type*", "macro")
		for _, side in ipairs({ "left", "middle", "right" }) do
			self:UpdateHearthstoneButtonMacro(button, side)
		end
		tinsert(self.HearthstoneButtons, button)
	elseif config.macro then
		button:SetAttribute("type*", "macro")
		button:SetAttribute("macrotext1", config.macro.LeftButton or "")
		button:SetAttribute("macrotext2", config.macro.RightButton or config.macro.LeftButton or "")
		button:SetAttribute("macrotext3", "")
	elseif config.click then
		button.Click = function(_, mouseButton)
			local func = config.click[mouseButton] or config.click.LeftButton
			func(GB.bar.middlePanel)
		end
		button:SetAttribute("type*", "click")
		button:SetAttribute("clickbutton", button)

	elseif config.item then
		button:SetAttribute("type*", "item")
		button:SetAttribute("item1", config.item.item1 or "")
		button:SetAttribute("item2", config.item.item2 or "")
	end

	-- Normal
	button.mainTex.group:Stop()
	button.mainTex:SetTexture(config.icon)
	button.mainTex:Size(self.db.buttonSize, self.db.buttonSize)
	animationReset(button.mainTex.group.anim)
	button.mainTex.group.anim.isEnterMode = true

	-- Additional text
	if button.registeredEvents then
		for _, event in pairs(button.registeredEvents) do
			button:UnregisterEvent(event)
		end
	end

	button:SetScript("OnEvent", nil)
	button.registeredEvents = nil
	button.additionalTextFunc = nil

	if button.additionalTextTimer and not button.additionalTextTimer:IsCancelled() then
		button.additionalTextTimer:Cancel()
	end

	button.additionalTextFormat = C.StringWithRGB("%s", self.mouseOverRGB)

	if config.additionalText and self.db.additionalText.enable then
		button.additionalText:SetFormattedText(
			button.additionalTextFormat,
			config.additionalText and config.additionalText() or ""
		)

		if config.events and config.eventHandler then
			button:SetScript("OnEvent", config.eventHandler)
			button.additionalTextFunc = config.additionalText
			button.registeredEvents = {}
			for _, event in pairs(config.events) do
				button:RegisterEvent(event)
				tinsert(button.registeredEvents, event)
			end
		else
			button.additionalTextTimer = C_Timer_NewTicker(self.db.additionalText.slowMode and 10 or 1, function()
				button.additionalText:SetFormattedText(
					button.additionalTextFormat,
					config.additionalText and config.additionalText() or ""
				)
			end)
		end

		button.additionalText:ClearAllPoints()
		button.additionalText:Point(self.db.additionalText.anchor, self.db.additionalText.x, self.db.additionalText.y)
		F.SetFontWithDB(button.additionalText, self.db.additionalText.font)
		button.additionalText:Show()
	else
		button.additionalText:Hide()
	end

	button:Show()
end

function GB:ConstructButtons()
	if self.buttons then
		return
	end

	self.buttons = {}
	for _ = 1, NUM_PANEL_BUTTONS * 2 do
		self:ConstructButton()
	end
end

function GB:UpdateButtons()
	if InCombatLockdown() then
		F.TaskManager:AfterCombat(self.UpdateButtons, self)
		return
	end

	self.HearthstoneButtons = {}

	for i = 1, NUM_PANEL_BUTTONS do
		self:UpdateButton(self.buttons[i], self.db.left[i])
		self:UpdateButton(self.buttons[i + NUM_PANEL_BUTTONS], self.db.right[i])
	end
end

function GB:UpdateLayout()
	if InCombatLockdown() then
		F.TaskManager:AfterCombat(self.UpdateLayout, self)
		return
	end

	if self.db.backdrop then
		self.bar.leftPanel.backdrop:Show()
		self.bar.middlePanel.backdrop:Show()
		self.bar.rightPanel.backdrop:Show()
	else
		self.bar.leftPanel.backdrop:Hide()
		self.bar.middlePanel.backdrop:Hide()
		self.bar.rightPanel.backdrop:Hide()
	end

	local numLeftButtons, numRightButtons = 0, 0

	-- Left Panel
	local lastButton = nil
	for i = 1, NUM_PANEL_BUTTONS do
		local button = self.buttons[i]
		if button.name ~= L["None"] then
			button:Show()
			button:ClearAllPoints()
			if not lastButton then
				button:Point("LEFT", self.bar.leftPanel, "LEFT", self.db.backdropSpacing, 0)
			else
				button:Point("LEFT", lastButton, "RIGHT", self.db.spacing, 0)
			end
			lastButton = button
			numLeftButtons = numLeftButtons + 1
		else
			button:Hide()
		end
	end

	if numLeftButtons == 0 then
		self.bar.leftPanel:Hide()
	else
		self.bar.leftPanel:Show()
		local panelWidth = self.db.backdropSpacing * 2
			+ (numLeftButtons - 1) * self.db.spacing
			+ numLeftButtons * self.db.buttonSize
		local panelHeight = self.db.backdropSpacing * 2 + self.db.buttonSize
		self.bar.leftPanel:Size(panelWidth, panelHeight)
	end

	-- Right Panel
	lastButton = nil
	for i = 1, NUM_PANEL_BUTTONS do
		local button = self.buttons[i + NUM_PANEL_BUTTONS]
		if button.name ~= L["None"] then
			button:Show()
			button:ClearAllPoints()
			if not lastButton then
				button:Point("LEFT", self.bar.rightPanel, "LEFT", self.db.backdropSpacing, 0)
			else
				button:Point("LEFT", lastButton, "RIGHT", self.db.spacing, 0)
			end
			lastButton = button
			numRightButtons = numRightButtons + 1
		else
			button:Hide()
		end
	end

	if numRightButtons == 0 then
		self.bar.rightPanel:Hide()
	else
		self.bar.rightPanel:Show()
		local panelWidth = self.db.backdropSpacing * 2
			+ (numRightButtons - 1) * self.db.spacing
			+ numRightButtons * self.db.buttonSize
		local panelHeight = self.db.backdropSpacing * 2 + self.db.buttonSize
		self.bar.rightPanel:Size(panelWidth, panelHeight)
	end

	-- Time Panel
	self.bar.middlePanel:Size(self.db.timeAreaWidth, self.db.timeAreaHeight)

	-- Update the size of moveable zones
	local areaWidth = 20 + self.bar.middlePanel:GetWidth()
	local leftWidth = self.bar.leftPanel:IsShown() and self.bar.leftPanel:GetWidth() or 0
	local rightWidth = self.bar.rightPanel:IsShown() and self.bar.rightPanel:GetWidth() or 0
	areaWidth = areaWidth + 2 * max(leftWidth, rightWidth)

	local areaHeight = self.bar.middlePanel:GetHeight()
	local leftHeight = self.bar.leftPanel:IsShown() and self.bar.leftPanel:GetHeight() or 0
	local rightHeight = self.bar.rightPanel:IsShown() and self.bar.rightPanel:GetHeight() or 0
	areaHeight = max(max(leftHeight, rightHeight), areaHeight)

	self.bar:Size(areaWidth, areaHeight)
end

function GB:PLAYER_ENTERING_WORLD()
	E:Delay(1, function()
		F.TaskManager:OutOfCombat(function()
			self:ProfileUpdate()
		end)
	end)
end

function GB:Initialize()
	self.db = E.db.WT.misc.gameBar

	if not self.db or not self.db.enable then
		return
	end

	if InCombatLockdown() then
		F.TaskManager:OutOfCombat(function()
			self:Initialize()
		end)
		return
	end

	for name, vDT in pairs(VirtualDT) do
		if DT.RegisteredDataTexts[name] and DT.RegisteredDataTexts[name].applySettings then
			DT.RegisteredDataTexts[name].applySettings(vDT, E.media.hexvaluecolor)
		end
	end

	self:UpdateMetadata()
	self:UpdateHearthStoneTable()
	self:ConstructBar()
	self:ConstructTimeArea()
	self:ConstructButtons()
	self:UpdateTimeArea()
	self:UpdateButtons()
	self:UpdateLayout()
	self:UpdateBar()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.initialized = true
end

function GB:UpdateMetadata()
	self.normalRGB = self.normalRGB or { r = 1, g = 1, b = 1 }
	if self.db.normalColor == "CUSTOM" then
		copyRGB(self.db.customNormalColor, self.normalRGB)
	elseif self.db.normalColor == "CLASS" then
		copyRGB(E:ClassColor(E.myclass, true), self.normalRGB)
	elseif self.db.normalColor == "VALUE" then
		copyRGB(E.media.rgbvaluecolor, self.normalRGB)
	else
		copyRGB({ r = 1, g = 1, b = 1 }, self.normalRGB)
	end

	self.mouseOverRGB = self.mouseOverRGB or { r = 1, g = 1, b = 1 }
	if self.db.hoverColor == "CUSTOM" then
		copyRGB(self.db.customHoverColor, self.mouseOverRGB)
	elseif self.db.hoverColor == "CLASS" then
		copyRGB(E:ClassColor(E.myclass, true), self.mouseOverRGB)
	elseif self.db.hoverColor == "VALUE" then
		copyRGB(E.media.rgbvaluecolor, self.mouseOverRGB)
	else
		copyRGB({ r = 1, g = 1, b = 1 }, self.mouseOverRGB)
	end

	self.animationDuration = self.db.animation.duration
	self.animationInEase = self.db.animation.ease == "linear" and "linear" or "in-" .. self.db.animation.ease
	self.animationOutEase = self.db.animation.ease == "linear" and "linear" or "out-" .. self.db.animation.ease
	if self.db.animation.easeInvert then
		self.animationInEase, self.animationOutEase = self.animationOutEase, self.animationInEase
	end
end

function GB:ProfileUpdate()
	self.db = E.db.WT.misc.gameBar
	if not self.db then
		return
	end

	if InCombatLockdown() then
		F.TaskManager:AfterCombat(self.ProfileUpdate, self)
		return
	end

	if self.db.enable then
		self:UpdateMetadata()
		if self.initialized then
			self.bar:Show()
			self:UpdateHearthstoneButton()
			self:UpdateTimeArea()
			self:UpdateTime()
			self:UpdateButtons()
			self:UpdateLayout()
			self:UpdateBar()
		else
			F.TaskManager:OutOfCombat(function()
				self:Initialize()
			end)
		end
	else
		if self.initialized then
			UnregisterStateDriver(self.bar, "visibility")
			self.bar:Hide()
		end
	end
end

function GB:GetNextRandomHearthstone(currentIndex, times)
	if not availableHearthstones or #availableHearthstones <= 1 or times and times >= 10 then
		return 1, availableHearthstones and availableHearthstones[1] or 6948
	end

	local randomIndex = random(1, #availableHearthstones)
	local itemID = availableHearthstones[randomIndex]
	if currentIndex and randomIndex == currentIndex then
		return self:GetNextRandomHearthstone(currentIndex, (times or 0) + 1)
	end

	return randomIndex, itemID
end

local function HearthstoneMacro(actionData)
	if actionData.actionType == "spell" or actionData.actionType == "toy" then
		return "/cast " .. actionData.name
	end
	return format("/use item:%d", actionData.actionID)
end

function GB:UpdateHearthstoneButtonMacro(button, mouseButton)
	if not button or not mouseButton or not availableHearthstones then
		return
	end

	local side = "left"
	if mouseButton == "right" or mouseButton == "RightButton" then
		side = "right"
	elseif mouseButton == "middle" or mouseButton == "MiddleButton" then
		side = "middle"
	end

	local sideSettings = HEARTSTONE_SIDE_SETTINGS[side]
	local actionData = self:ResolveHearthstoneAction(side)
	local attribute = sideSettings.attribute
	local macro =
		format('/run UIErrorsFrame:AddMessage("%s", RED_FONT_COLOR:GetRGBA())', L["Hearthstone not found or usable."])

	if actionData and actionData.actionType == "random" then
		local currentIndex = button["randomHearthstoneIndex" .. side]
		local randomIndex, itemID = self:GetNextRandomHearthstone(currentIndex)
		button["randomHearthstoneIndex" .. side] = randomIndex
		local selected = hearthstonesAndToysData[tostring(itemID)]
		if selected then
			macro = HearthstoneMacro(selected) .. "\n/run _G.WTGameBar_UpdateHearthstoneButtons()"
		end
	elseif actionData then
		macro = HearthstoneMacro(actionData)
	end

	button:SetAttribute(attribute, macro)
end

function GB:UpdateHearthstoneButton()
	local left = self:ResolveHearthstoneAction("left")
	local middle = self:ResolveHearthstoneAction("middle")
	local right = self:ResolveHearthstoneAction("right")

	ButtonTypes.HEARTHSTONE.item = {
		item1 = left and left.name,
		item3 = middle and middle.name,
		item2 = right and right.name,
	}
end

function GB:UpdateHearthStoneTable()
	hearthstonesAndToysData = {
		["RANDOM"] = {
			name = L["Random Hearthstone"],
			icon = "Interface\\Icons\\INV_Misc_Rune_01",
			actionType = "random",
			actionID = 6948,
		},
	}

	async.WithSpellID(ASTRAL_RECALL_SPELL_ID, function(spell)
		hearthstonesAndToysData[ASTRAL_RECALL_KEY] = {
			name = spell:GetSpellName(),
			icon = spell:GetSpellTexture(),
			actionType = "spell",
			actionID = ASTRAL_RECALL_SPELL_ID,
		}

		self:UpdateHearthstoneButton()
		if self.initialized then
			self:UpdateButtons()
		end
	end)

	local hearthstonesTable = {}
	for i = 1, #hearthstones do
		local itemID = hearthstones[i]
		hearthstonesTable[itemID] = true
	end

	availableHearthstones = {}

	async.WithItemIDTable(hearthstoneAndToyIDList, "value", function(item)
		local id = item:GetItemID()
		if not id then
			return
		end

		if hearthstonesTable[id] then
			if C_Item_GetItemCount(id) >= 1 or PlayerHasToy(id) then
				tinsert(availableHearthstones, id)
			end
		end

		local toyItemID, toySpellID, toyName, toyIcon
		if PlayerHasToy(id) then
			toyItemID, toySpellID, toyName, toyIcon = C_ToyBox.GetToyInfo(id)
		end
		hearthstonesAndToysData[tostring(id)] = {
			name = toySpellID and toyName or item:GetItemName(),
			icon = toySpellID and toyIcon or item:GetItemIcon(),
			actionType = toySpellID and "toy" or "item",
			actionID = id,
			spellID = toySpellID,
		}
	end, function()
		self:UpdateHearthstoneButton()
		if self.initialized then
			self:UpdateButtons()
		end
	end)
end

function GB:GetHearthStoneTable(includeSpell)
	if not hearthstonesAndToysData then
		return {}
	end

	if includeSpell then
		return hearthstonesAndToysData
	end

	local filteredTable = {}
	for id, data in pairs(hearthstonesAndToysData) do
		if data.actionType ~= "spell" then
			filteredTable[id] = data
		end
	end

	return filteredTable
end

function GB:GetAvailableButtons()
	local buttons = {}

	for key, data in pairs(ButtonTypes) do
		buttons[key] = data.name
	end

	return buttons
end

W:RegisterModule(GB:GetName())
