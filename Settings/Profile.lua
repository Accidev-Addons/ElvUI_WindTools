local P ---@class ProfileDB
local W, F, E, L, V, G ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB, GlobalDB
W, F, E, L, V, P, G = unpack((select(2, ...)))

---@cast W WindTools
local C = W.Utilities.Color

local format = format

---@class ProfileDB.announcement
P.announcement = {
	enable = false,
	emoteFormat = ": %s",
	sameMessageInterval = 10,
	goodbye = {
		enable = false,
		text = L["Thanks all!"],
		delay = 3,
		channel = {
			party = "PARTY",
			raid = "RAID",
		},
	},
	quest = {
		enable = false,
		paused = true,
		includeDetails = false,
		hideLevelOnMaxLevel = true,
		hideLevelIfSameAsPlayer = true,
		channel = {
			party = "PARTY",
			raid = "RAID",
		},
		template = "{{level}}{{link}} {{progress}}",
	},
	resetInstance = {
		enable = true,
		difficultyChange = true,
		channel = {
			party = "PARTY",
			raid = "RAID",
		},
	},
	utility = {
		enable = true,
		channel = {
			solo = "NONE",
			party = "PARTY",
			raid = "RAID",
		},
		general = {
			feast = {
				enable = true,
				raidWarning = true,
				text = L["%spell% is up! Come get some while it's hot!"],
			},
			toy = {
				enable = true,
				raidWarning = false,
				text = L["I put out my %spell%!"],
			},
			bot = {
				enable = true,
				raidWarning = false,
				text = L["I have summoned %spell%!"],
			},
			portal = {
				enable = true,
				raidWarning = false,
				text = L["%spell% is open!"],
			},
			spell = {
				enable = true,
				raidWarning = false,
				text = L["I used %spell%!"],
			},
		},
		custom = {
			["698"] = {
				enable = true,
				raidWarning = true,
				text = L["I am casting %spell%, please assist!"],
			},
			["29893"] = {
				enable = true,
				raidWarning = false,
				text = L["Healthstones here! Get them before we pull!"],
			},
			["43987"] = {
				enable = true,
				raidWarning = false,
				text = L["Table is up! Grab your food and water!"],
			},
		},
	},
	keystone = {
		enable = true,
		text = L["My new keystone is %keystone%."],
		channel = {
			party = "PARTY",
		},
		command = true,
	},
}

---@class ProfileDB.combat
P.combat = {
	combatAlert = {
		enable = true,
		speed = 1,
		animation = true,
		animationSize = 1,
		text = true,
		enterText = L["Enter Combat"],
		leaveText = L["Leave Combat"],
		enterColor = {
			left = C.GetRGBFromTemplate("rose-300"),
			right = C.GetRGBFromTemplate("rose-500"),
		},
		leaveColor = {
			left = C.GetRGBFromTemplate("emerald-300"),
			right = C.GetRGBFromTemplate("emerald-500"),
		},
		font = {
			name = E.db.general.font,
			size = 25,
			style = "OUTLINE",
		},
		enterSound = {
			enable = false,
			sound = "None",
			channel = "Master",
		},
		leaveSound = {
			enable = false,
			sound = "None",
			channel = "Master",
		},
	},
	raidMarkers = {
		enable = true,
		mouseOver = false,
		tooltip = true,
		visibility = "DEFAULT",
		backdrop = true,
		backdropSpacing = 3,
		buttonSize = 30,
		buttonBackdrop = true,
		buttonAnimation = true,
		buttonAnimationDuration = 0.2,
		buttonAnimationScale = 1.33,
		spacing = 4,
		orientation = "HORIZONTAL",
		modifier = "shift",
		readyCheck = true,
		countDown = true,
		countDownTime = 5,
		inverse = false,
	},
	quickKeystone = {
		enable = true,
	},
	interruptTracker = {
		size = 32,
	},
}

---@class ProfileDB.item
P.item = {
	contacts = {
		enable = true,
		defaultPage = "ALTS",
	},
	delete = {
		enable = true,
		delKey = true,
		fillIn = "CLICK",
	},
	alreadyKnown = {
		enable = true,
		mode = "COLOR",
		color = { r = 0, g = 1, b = 0 },
	},
	fastLoot = {
		enable = true,
		limit = 0.3,
	},
	trade = {
		enable = true,
		thanksButton = true,
		thanksText = L["Thank you!"],
	},
	extraItemsBar = {
		enable = true,
		customList = {},
		blackList = {},
		bar1 = {
			enable = true,
			mouseOver = false,
			globalFade = false,
			visibility = "show",
			fadeTime = 0.3,
			alphaMin = 0,
			alphaMax = 1,
			numButtons = 12,
			backdrop = true,
			backdropSpacing = 3,
			buttonWidth = 35,
			buttonHeight = 30,
			buttonsPerRow = 12,
			anchor = "TOPLEFT",
			spacing = 3,
			tooltip = true,
			countFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			bindFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			include = "QUEST,BANNER,EQUIP,HOLIDAY,OPENABLE",
		},
		bar2 = {
			enable = true,
			mouseOver = false,
			globalFade = false,
			visibility = "show",
			fadeTime = 0.3,
			alphaMin = 0,
			alphaMax = 1,
			numButtons = 12,
			backdrop = true,
			backdropSpacing = 3,
			buttonWidth = 35,
			buttonHeight = 30,
			buttonsPerRow = 12,
			anchor = "TOPLEFT",
			spacing = 3,
			tooltip = true,
			countFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			bindFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			include = "POTION,FLASK,UTILITY",
		},
		bar3 = {
			enable = true,
			mouseOver = false,
			globalFade = false,
			visibility = "show",
			fadeTime = 0.3,
			alphaMin = 0,
			alphaMax = 1,
			numButtons = 12,
			backdrop = true,
			backdropSpacing = 3,
			buttonWidth = 35,
			buttonHeight = 30,
			buttonsPerRow = 12,
			anchor = "TOPLEFT",
			spacing = 3,
			tooltip = true,
			countFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			bindFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			include = "MAGEFOOD,FOOD,FOODVENDOR,CUSTOM",
		},
		bar4 = {
			enable = false,
			mouseOver = false,
			globalFade = false,
			visibility = "show",
			fadeTime = 0.3,
			alphaMin = 0,
			alphaMax = 1,
			numButtons = 12,
			backdrop = true,
			backdropSpacing = 3,
			buttonWidth = 35,
			buttonHeight = 30,
			buttonsPerRow = 12,
			anchor = "TOPLEFT",
			spacing = 3,
			tooltip = true,
			countFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			bindFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			include = "CUSTOM",
		},
		bar5 = {
			enable = false,
			mouseOver = false,
			globalFade = false,
			visibility = "show",
			fadeTime = 0.3,
			alphaMin = 0,
			alphaMax = 1,
			numButtons = 12,
			backdrop = true,
			backdropSpacing = 3,
			buttonWidth = 35,
			buttonHeight = 30,
			buttonsPerRow = 12,
			anchor = "TOPLEFT",
			spacing = 3,
			tooltip = true,
			countFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			bindFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = {
					r = 1,
					g = 1,
					b = 1,
				},
			},
			include = "CUSTOM",
		},
	},
	inspect = {
		enable = true,
		player = true,
		inspect = true,
		playerOnInspect = true,
		itemIcon = {
			enable = true,
			qualityBorder = true,
			indicator = true,
			width = 20,
			height = 16,
		},
		gemIcon = {
			enable = true,
			size = 17,
			showAddableSockets = true,
		},
		slotText = {
			name = E.db.general.font,
			size = W.CompatibleFont and 12 or 10,
			style = "OUTLINE",
		},
		levelText = {
			name = F.GetCompatibleFont("Chivo Mono"),
			size = 14,
			style = "OUTLINE",
		},
		itemNameText = {
			name = E.db.general.font,
			size = 14,
			style = "OUTLINE",
		},
		statistics = {
			enable = true,
			text = {
				name = E.db.general.font,
				size = 13,
				style = "OUTLINE",
			},
			comparison = {
				enable = true,
				hideIfBothZero = true,
				higherColor = C.GetRGBFromTemplate("green-400"),
				lowerColor = C.GetRGBFromTemplate("rose-400"),
			},
		},
	},
	---@class ProfileDB.item.itemLevel
	itemLevel = {
		enable = true,
		---@class ProfileDB.item.itemLevel.flyout
		flyout = {
			enable = true,
			useBagsFontSetting = false,
			qualityColor = true,
			font = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 11,
				style = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
				color = { r = 1, g = 1, b = 1 },
			},
		},
	},
}

---@class ProfileDB.maps
P.maps = {
	rectangleMinimap = {
		enable = false,
		heightPercentage = 0.8,
		fixHereBeDragons = true,
		pinHidingTolerance = 10,
	},
	worldMap = {
		reveal = {
			enable = false,
			color = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
		},
	},
}

---@class ProfileDB.skins
P.skins = {
	---@class ProfileDB.skins.vignetting
	vignetting = {
		enable = true,
		level = 30,
	},
}

---@class ProfileDB.social
P.social = {
	---@class ProfileDB.social.chatBar
	chatBar = {
		enable = true,
		style = "BLOCK",
		blockShadow = true,
		autoHide = false,
		mouseOver = false,
		backdrop = false,
		backdropSpacing = 3,
		buttonWidth = 40,
		buttonHeight = 5,
		spacing = 5,
		orientation = "HORIZONTAL",
		tex = "WindTools Glow",
		font = {
			name = E.db.general.font,
			size = 12,
			style = "OUTLINE",
		},
		color = true,
		channels = {
			["SAY"] = {
				enable = true,
				cmd = "s",
				color = { r = 1, g = 1, b = 1, a = 1 },
				abbr = L["[ABBR] Say"],
			},
			["YELL"] = {
				enable = true,
				cmd = "y",
				color = { r = 1, g = 0.25, b = 0.25, a = 1 },
				abbr = L["[ABBR] Yell"],
			},
			["EMOTE"] = {
				enable = false,
				cmd = "e",
				color = { r = 1, g = 0.5, b = 0.25, a = 1 },
				abbr = L["[ABBR] Emote"],
			},
			["PARTY"] = {
				enable = true,
				cmd = "p",
				color = { r = 0.67, g = 0.67, b = 1, a = 1 },
				abbr = L["[ABBR] Party"],
			},
			["RAID"] = {
				enable = true,
				cmd = "raid",
				color = { r = 1, g = 0.5, b = 0, a = 1 },
				abbr = L["[ABBR] Raid"],
			},
			["RAID_WARNING"] = {
				enable = false,
				cmd = "rw",
				color = { r = 1, g = 0.28, b = 0, a = 1 },
				abbr = L["[ABBR] Raid Warning"],
			},
			["GUILD"] = {
				enable = true,
				cmd = "g",
				color = { r = 0.25, g = 1, b = 0.25, a = 1 },
				abbr = L["[ABBR] Guild"],
			},
			["OFFICER"] = {
				enable = false,
				cmd = "o",
				color = { r = 0.25, g = 0.75, b = 0.25, a = 1 },
				abbr = L["[ABBR] Officer"],
			},
			world = {
				enable = true,
				config = {},
				color = { r = 0.2, g = 0.6, b = 0.86, a = 1 },
				abbr = L["[ABBR] World"],
			},
			emote = {
				enable = true,
				icon = true,
				color = { r = 1, g = 0.33, b = 0.52, a = 1 },
				abbr = L["[ABBR] Wind Emote"],
			},
			roll = {
				enable = true,
				icon = true,
				color = { r = 0.56, g = 0.56, b = 0.56, a = 1 },
				abbr = L["[ABBR] Roll"],
			},
		},
	},
	chatLink = {
		enable = true,
		translateItem = true,
		level = true,
		icon = true,
		iconWidth = 18,
		iconHeight = 16,
		armorCategory = true,
		weaponCategory = true,
		keepRatio = true,
	},
	chatText = {
		enable = true,
		abbreviation = "SHORT",
		removeBrackets = true,
		roleIconSize = 16,
		roleIconStyle = "SUNUI",
		removeRealm = true,
		customAbbreviation = {},
		classIcon = true,
		classIconStyle = "flatborder2",
		guildMemberStatus = true,
		guildMemberStatusInviteLink = true,
		mergeAchievement = true,
	},
	emote = {
		enable = true,
		size = 16,
		panel = true,
		chatBubbles = true,
	},
	friendList = {
		enable = true,
		level = true,
		hideMaxLevel = true,
		useClassColor = true,
		useNoteAsName = false,
		hideRealm = false,
		textures = {
			status = "square",
		},
		areaColor = {
			r = 1,
			g = 1,
			b = 1,
		},
		nameFont = {
			name = E.db.general.font,
			size = 13,
			style = "OUTLINE",
		},
		infoFont = {
			name = E.db.general.font,
			size = 11,
			style = "OUTLINE",
		},
	},
	smartTab = {
		enable = true,
		whisperCycle = false,
		yell = false,
		battleground = false,
		raidWarning = false,
		officer = false,
		world = false,
		historyLimit = 10,
	},
}

---@class ProfileDB.quest
P.quest = {
	autoCollapse = {
		enable = false,
		ignoreManualToggle = false,
		combat = "none",
		vehicle = "collapse",
		resting = "none",
		outOfInstance = "none",
		battleground = "collapse",
		arena = "collapse",
		dungeon = "none",
		raid = "none",
		default = "expand",
	},
	---@class ProfileDB.quest.progress
	progress = {
		enable = true,
		disableIfRequiredOver = 75,
		displayTemplate = "{{level}} {{suggestedGroup}} {{tag}} {{daily}} {{title}} - {{progress}} {{icon}}",
		soundEffects = {
			enable = false,
			accept = {
				enable = false,
				sound = "WT Accept",
			},
			objectiveProgress = {
				enable = false,
				sound = "WT Simple",
			},
			partialComplete = {
				enable = false,
				sound = "WT Clear",
			},
			fullyComplete = {
				enable = true,
				sound = "WT Complete",
			},
		},
		tag = {
			template = "[%s]",
			color = {
				left = C.GetRGBFromTemplate("sky-500"),
				right = C.GetRGBFromTemplate("sky-300"),
			},
		},
		suggestedGroup = {
			template = "[%d]",
			color = {
				left = C.GetRGBFromTemplate("rose-400"),
				right = C.GetRGBFromTemplate("rose-300"),
			},
		},
		level = {
			template = "[%d]",
			hideOnCharacterLevel = true,
			color = {
				left = C.GetRGBFromTemplate("fuchsia-500"),
				right = C.GetRGBFromTemplate("pink-400"),
			},
		},
		daily = {
			template = format("[%s]", L["Daily"]),
			color = {
				left = C.GetRGBFromTemplate("cyan-400"),
				right = C.GetRGBFromTemplate("cyan-200"),
			},
		},
		title = {
			template = "%s",
			color = {
				left = C.GetRGBFromTemplate("amber-400"),
				right = C.GetRGBFromTemplate("amber-200"),
			},
		},
		progress = {
			objective = {
				detailTemplate = "%d/%d",
				completeText = format("(%s)", L["Complete"]),
				color = {
					left = C.GetRGBFromTemplate("neutral-100"),
					right = C.GetRGBFromTemplate("neutral-50"),
				},
			},
			complete = {
				text = L["Quest Complete"],
				color = {
					left = C.GetRGBFromTemplate("green-400"),
					right = C.GetRGBFromTemplate("emerald-300"),
				},
			},
			accepted = {
				text = L["Quest Accepted"],
				color = {
					left = C.GetRGBFromTemplate("blue-400"),
					right = C.GetRGBFromTemplate("sky-300"),
				},
			},
		},
	},
	switchButtons = {
		enable = true,
		tooltip = true,
		backdrop = false,
		font = {
			name = E.db.general.font,
			size = 12,
			style = "OUTLINE",
			color = { r = 1, g = 0.82, b = 0 },
		},
		announcement = true,
		turnIn = true,
	},
	turnIn = {
		enable = false,
		mode = "ALL",
		enableCondition = {
			repeatable = true,
			other = false,
		},
		selectReward = true,
		getBestReward = false,
		pauseModifier = "SHIFT",
		customIgnoreNPCs = {},
	},
	achievementScreenshot = {
		enable = false,
		hideCombatAlert = true,
		forceShowUI = true,
		chatMessage = true,
	},
	achievementTracker = {
		enable = true,
		show = true,
		width = 500,
		height = 500,
		threshold = 75,
		tooltip = true,
		scan = {
			batchSize = 20,
			batchInterval = 0.01,
			automation = {
				enable = true,
				onShow = true,
				onLogin = false,
			},
		},
	},
}

---@class ProfileDB.tooltips
P.tooltips = {
	---@class ProfileDB.tooltips.elvUITweaks
	elvUITweaks = {
		healthBar = {
			barYOffset = 0,
			textYOffset = 0,
		},
		raceIcon = {
			enable = true,
			width = 16,
			height = 16,
		},
		specIcon = {
			enable = true,
			width = 16,
			height = 14,
		},
	},
	groupInfo = {
		enable = true,
		excludeDungeon = false,
		hideBlizzard = true,
		title = false,
		mode = "NORMAL",
		classIconStyle = "flat",
		template = "{{classIcon:18}} {{specIcon:14,18}} {{classColorStart}}{{className}} ({{specName}}){{classColorEnd}}{{amountStart}} x {{amount}}{{amountEnd}}",
	},
	progression = {
		enable = false,
		checkAchievements = false,
		checkPlayer = false,
		tiers = {
			RS = true,
			ICC = true,
			ToC = true,
			Ulduar = true,
		},
	},
}

---@class ProfileDB.unitFrames
P.unitFrames = {
	---@class ProfileDB.unitFrames.nameClip
	nameClip = {
		enable = false,
		player = { enable = false, width = 0, target = "__Name__" },
		pet = { enable = false, width = 0, target = "__Name__" },
		target = { enable = false, width = 0, target = "__Name__" },
		targettarget = { enable = false, width = 0, target = "__Name__" },
		targettargettarget = { enable = false, width = 0, target = "__Name__" },
		focus = { enable = false, width = 0, target = "__Name__" },
		focustarget = { enable = false, width = 0, target = "__Name__" },
		pettarget = { enable = false, width = 0, target = "__Name__" },
		party = { enable = false, width = 0, target = "__Name__" },
		raid1 = { enable = false, width = 0, target = "__Name__" },
		raid2 = { enable = false, width = 0, target = "__Name__" },
		raid3 = { enable = false, width = 0, target = "__Name__" },
		raidpet = { enable = false, width = 0, target = "__Name__" },
		arena = { enable = false, width = 0, target = "__Name__" },
		boss = { enable = false, width = 0, target = "__Name__" },
		tank = { enable = false, width = 0, target = "__Name__" },
		assist = { enable = false, width = 0, target = "__Name__" },
	},
	---@class ProfileDB.unitFrames.absorb
	absorb = {
		enable = false,
		damageAbsorb = {
			enable = true,
			blizzardStyle = false,
			custom = E.db.unitframe.statusbar,
		},
		healAbsorb = {
			enable = false,
			blizzardStyle = false,
			custom = E.db.unitframe.statusbar,
		},
		healPrediction = {
			enable = false,
			blizzardStyle = false,
			custom = E.db.unitframe.statusbar,
		},
		blizzardAbsorbOverlay = true,
	},
}

---@class ProfileDB.misc
P.misc = {
	hideCrafter = false,
	---@class ProfileDB.misc.spellActivationAlert
	spellActivationAlert = {
		enable = false,
		scale = 1,
	},
	---@class ProfileDB.misc.gameBar
	gameBar = {
		enable = true,
		mouseOver = false,
		backdrop = true,
		backdropSpacing = 5,
		timeAreaWidth = 110,
		timeAreaHeight = 50,
		buttonSize = 24,
		spacing = 4,
		fadeTime = 0.618,
		normalColor = "DEFAULT",
		hoverColor = "CLASS",
		animation = {
			duration = 0.2,
			ease = "quadratic",
			easeInvert = false,
		},
		customNormalColor = { r = 1, g = 1, b = 1 },
		customHoverColor = { r = 0, g = 0.659, b = 1 },
		visibility = "show",
		tooltipsAnchor = "ANCHOR_BOTTOM",
		time = {
			localTime = true,
			twentyFour = true,
			flash = true,
			interval = 10,
			alwaysSystemInfo = false,
			avoidReloadInCombat = true,
			font = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 25,
				style = "OUTLINE",
			},
			systemInfoFont = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
			},
		},
		hearthstone = {
			left = "6948",
			leftFallback = "6948",
			middle = "6948",
			middleFallback = "6948",
			right = "6948",
			rightFallback = "6948",
			showBindLocation = true,
		},
		additionalText = {
			enable = true,
			slowMode = true,
			anchor = "BOTTOMRIGHT",
			x = 3,
			y = -3,
			font = {
				name = F.GetCompatibleFont("Montserrat"),
				size = 12,
				style = "OUTLINE",
			},
		},
		left = {
			[1] = "CHARACTER",
			[2] = "SPELLBOOK",
			[3] = "TALENTS",
			[4] = "FRIENDS",
			[5] = "GUILD",
			[6] = "GROUP_FINDER",
			[7] = "SCREENSHOT",
		},
		right = {
			[1] = "HEARTHSTONE",
			[2] = "COLLECTIONS",
			[3] = "ACHIEVEMENTS",
			[4] = "ENCOUNTER_JOURNAL",
			[5] = "TOY_BOX",
			[6] = "PET_JOURNAL",
			[7] = "BAGS",
		},
	},
	---@class ProfileDB.misc.automation
	automation = {
		enable = false,
		hideBagAfterEnteringCombat = false,
		hideWorldMapAfterEnteringCombat = false,
		acceptResurrect = false,
		acceptCombatResurrect = false,
		confirmSummon = false,
	},
	---@class ProfileDB.misc.keybindAlias
	keybindAlias = {
		enable = false,
		list = {},
	},
}
