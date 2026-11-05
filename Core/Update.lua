local W ---@class WindTools
local F, E, L, V, P, G ---@type Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
W, F, E, L, V, P, G = unpack((select(2, ...)))

local enhancedTrackerStates = {
	EXPAND = "expand",
	COLLAPSE = "collapse",
	COLLAPSED = "collapse",
	HIDE = "hide",
	HIDDEN = "hide",
	NONE = "none",
}

local enhancedTrackerContexts = {
	city = "resting",
	pvp = "battleground",
	arena = "arena",
	party = "dungeon",
	raid = "raid",
	noOne = "outOfInstance",
}

local enhancedTrackerDefaults = { pvp = "HIDE", arena = "HIDE" }

function W:ConvertEnhanced()
	local profile, private = E.db.enhanced, E.private.enhanced

	local tracker = type(profile) == "table" and profile.watchframe
	if type(tracker) == "table" then
		if tracker.enable then
			local db, defaults = E.db.WT.quest.autoCollapse, P.quest.autoCollapse
			db.enable = true
			for old, new in pairs(enhancedTrackerContexts) do
				local state = enhancedTrackerStates[tracker[old] or enhancedTrackerDefaults[old]]
				if state and db[new] == defaults[new] then
					db[new] = state
				end
			end
		end
		if tracker.level then
			E.private.WT.quest.objectiveTracker.showLevel = true
		end
		profile.watchframe = nil
	end

	local fog = type(profile) == "table" and type(profile.map) == "table" and profile.map.fogClear
	if type(fog) == "table" then
		E:CopyTable(E.db.WT.maps.worldMap.reveal, fog)
	end

	local progress = type(profile) == "table" and type(profile.tooltip) == "table" and profile.tooltip.progressInfo
	if type(progress) == "table" then
		local db = E.db.WT.tooltips.progression
		for _, key in ipairs({ "enable", "checkAchievements", "checkPlayer" }) do
			if progress[key] ~= nil then
				db[key] = progress[key]
			end
		end
		if type(progress.tiers) == "table" then
			for tier in pairs(P.tooltips.progression.tiers) do
				if progress.tiers[tier] ~= nil then
					db.tiers[tier] = progress.tiers[tier]
				end
			end
		end
		if progress.modifier then
			E.private.WT.tooltips.modifier = progress.modifier == "ALL" and "NONE" or progress.modifier
		end
	end

	local tracker = type(private) == "table" and private.interruptTracker
	if type(tracker) == "table" then
		local db = E.private.WT.combat.interruptTracker
		for _, key in ipairs({ "enable", "everywhere", "arena", "battleground" }) do
			if tracker[key] ~= nil then
				db[key] = tracker[key]
			end
		end
		private.interruptTracker = nil
	end
	local trackerSize = type(profile) == "table" and type(profile.interruptTracker) == "table" and profile.interruptTracker.size
	if trackerSize then
		E.db.WT.combat.interruptTracker.size = trackerSize
	end
	local trackerMovers = E.db.movers
	if trackerMovers and trackerMovers.ElvUI_InterruptTrackerHeaderMover and not trackerMovers.WTInterruptTrackerMover then
		trackerMovers.WTInterruptTrackerMover = trackerMovers.ElvUI_InterruptTrackerHeaderMover
		trackerMovers.ElvUI_InterruptTrackerHeaderMover = nil
	end

	local control = type(private) == "table" and private.loseControl
	if type(control) == "table" then
		if control.enable then
			local db = E.private.WT.skins.lossOfControl
			if type(control.colorNumberText) == "table" then
				db.timeLeft.numberColor = E:CopyTable({}, control.colorNumberText)
			end
			db.icon.hideCooldown = not control.enableCooldownFrame
			local size = type(profile) == "table" and type(profile.loseControl) == "table" and profile.loseControl.iconSize
			if size then
				db.icon.iconSize = size
			end
		end
		private.loseControl = nil
	end

	local movers = E.db.movers
	if movers and movers.LossControlMover then
		movers.WTLossOfControlFrameMover = movers.WTLossOfControlFrameMover or movers.LossControlMover
		movers.LossControlMover = nil
	end

	if type(profile) == "table" then
		profile.loseControl = nil
		profile.map = nil
		profile.tooltip = nil
		profile.interruptTracker = nil
		if not next(profile) then
			E.db.enhanced = nil
		end
	end
	if type(private) == "table" and not next(private) then
		E.private.enhanced = nil
	end
end

function W:UpdateScripts()
	local profile = E.db.WT
	local gameBar = profile.misc and profile.misc.gameBar
	if gameBar and (gameBar.visibility == "[petbattle]hide;show" or gameBar.visibility == "[petbattle] hide; show") then
		gameBar.visibility = "show"
	end
	local chatText = profile.social and profile.social.chatText
	if chatText and chatText.abbreviation == "NONE" then
		chatText.abbreviation = "DEFAULT"
		E.db.chat.hideChannels = true
	end
	local itemBars = profile.item and profile.item.extraItemsBar
	if itemBars then
		for i = 1, 5 do
			local bar = itemBars["bar" .. i]
			if bar and (bar.visibility == "[petbattle]hide;show" or bar.visibility == "[petbattle] hide; show") then
				bar.visibility = "show"
			end
		end
	end

	self:ConvertEnhanced()

	E.global.WT.version = W.Version
	E.db.WT.version = W.Version
	E.private.WT.version = W.Version
end
