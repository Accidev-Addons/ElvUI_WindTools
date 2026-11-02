local V ---@class PrivateDB
local W, F, E, L, P, G ---@type WindTools, Functions, ElvUI, LocaleTable, ProfileDB, GlobalDB
W, F, E, L, V, P, G = unpack((select(2, ...)))

---@cast W WindTools

local C = W.Utilities.Color

local norm = C.StringByTemplate(L["[ABBR] Normal"], "green-500")
local hero = C.StringByTemplate(L["[ABBR] Heroic"], "blue-500")
local myth = C.StringByTemplate(L["[ABBR] Mythic"], "purple-500")
local lfr = C.StringByTemplate(L["[ABBR] Looking for raid"], "orange-500")

---@class PrivateDB.combat
V.combat = {
	---@class PrivateDB.combat.destroyTotem
	destroyTotem = {
		enable = false,
		keys = {
			[1] = nil,
			[2] = nil,
			[3] = nil,
			[4] = nil,
		},
	},
}

---@class PrivateDB.item
V.item = {
	extendMerchantPages = {
		enable = false,
		numberOfPages = 2,
	},
}

---@class PrivateDB.maps
V.maps = {
	---@class PrivateDB.maps.instanceDifficulty
	instanceDifficulty = {
		enable = false,
		hideBlizzard = true,
		align = "LEFT",
		font = {
			name = E.db.general.font,
			size = E.db.general.fontSize,
			style = "OUTLINE",
		},
		difficulty = {
			custom = false,
			customStrings = {
				["PvP"] = format("|cffFFFF00%s|r", "PvP"),
				["5-player Normal"] = "5" .. norm,
				["5-player Heroic"] = "5" .. hero,
				["10-player Normal"] = "10" .. norm,
				["25-player Normal"] = "25" .. norm,
				["10-player Heroic"] = "10" .. hero,
				["25-player Heroic"] = "25" .. hero,
				["LFR"] = lfr,
				["Mythic Keystone"] = C.StringByTemplate(L["[ABBR] Mythic Keystone"], "rose-500") .. "%mplus%",
				["40-player"] = "40",
				["Normal Scenario"] = format("%s %s", norm, L["[ABBR] Scenario"]),
				["Heroic Scenario"] = format("%s %s", hero, L["[ABBR] Scenario"]),
				["Mythic Scenario"] = format("%s %s", myth, L["[ABBR] Scenario"]),
				["Normal Raid"] = "%numPlayers%" .. norm,
				["Heroic Raid"] = "%numPlayers%" .. hero,
				["Mythic Raid"] = "%numPlayers%" .. myth,
				["LFR Raid"] = "%numPlayers%" .. lfr,
				["Event Scenario"] = L["[ABBR] Event Scenario"],
				["Mythic Party"] = "5" .. myth,
				["Timewalking"] = L["[ABBR] Timewalking"],
				["World PvP Scenario"] = format("|cffFFFF00%s |r", "PvP"),
				["PvEvP Scenario"] = "PvEvP",
				["Timewalking Raid"] = L["[ABBR] Timewalking"],
				["PvP Heroic"] = format("|cffFFFF00%s |r", "PvP"),
				["Warfronts Normal"] = L["[ABBR] Warfronts"],
				["Warfronts Heroic"] = format("|cffff7d0aH|r%s", L["[ABBR] Warfronts"]),
				["Normal Scaling Party"] = L["[ABBR] Normal Scaling Party"],
				["Visions of N'Zoth"] = L["[ABBR] Visions of N'Zoth"],
				["Teeming Island"] = L["[ABBR] Teeming Island"],
				["Torghast"] = L["[ABBR] Torghast"],
				["Path of Ascension: Courage"] = L["[ABBR] Path of Ascension"],
				["Path of Ascension: Loyalty"] = L["[ABBR] Path of Ascension"],
				["Path of Ascension: Wisdom"] = L["[ABBR] Path of Ascension"],
				["Path of Ascension: Humility"] = L["[ABBR] Path of Ascension"],
				["World Boss"] = L["[ABBR] World Boss"],
				["Challenge Level 1"] = L["[ABBR] Challenge Level 1"],
				["Follower"] = L["[ABBR] Follower"],
				["Delves"] = L["[ABBR] Delves"],
				["Quest"] = L["[ABBR] Quest"],
				["Story"] = L["[ABBR] Story"],
				["Lorewalking"] = L["[ABBR] Lorewalking"],
			},
		},
	},
	worldMap = {
		enable = true,
		scale = {
			enable = true,
			size = 1.24,
		},
	},
	minimapButtons = {
		enable = true,
		mouseOver = false,
		buttonsPerRow = 6,
		buttonSize = 30,
		backdrop = true,
		backdropSpacing = 3,
		spacing = 2,
		inverseDirection = false,
		reverseOrder = false,
		orientation = "HORIZONTAL",
		sortingPriority = "_BugSack, _Saved, _Wind",
		hiddenPatterns = "",
		ignorePatterns = "",
	},
}

---@class PrivateDB.misc
V.misc = {
	keybindTextAbove = false,
	autoToggleChatBubble = false,
	---@class PrivateDB.misc.moveFrames
	moveFrames = {
		enable = true,
		elvUIBags = true,
		tradeSkillMasterCompatible = true,
		rememberPositions = false,
		autoResetOffScreenFrames = true,
		framePositions = {},
	},
	---@class PrivateDB.misc.lfgList
	lfgList = {
		enable = true,
		icon = {
			enable = true,
			hideDefaultClassCircle = true,
			leader = true,
			reskin = true,
			pack = "SQUARE",
			size = 16,
			border = false,
			alpha = 1,
		},
		line = {
			enable = true,
			tex = "WindTools Glow",
			width = 16,
			height = 3,
			offsetX = 0,
			offsetY = -1,
			alpha = 1,
		},
		additionalText = {
			enable = true,
			target = "DESC",
			shortenDescription = true,
			template = "{{score}} {{text}}",
		},
		partyKeystone = {
			enable = true,
			font = {
				name = E.db.general.font,
				size = 12,
				style = "OUTLINE",
			},
		},
		rightPanel = {
			enable = true,
			autoRefresh = true,
			autoJoin = false,
			skipConfirmation = false,
			adjustFontSize = 0,
			filterButtonTooltip = true,
		},
	},
}

---@class PrivateDB.quest
V.quest = {
	---@class PrivateDB.quest.objectiveTracker
	objectiveTracker = {
		enable = false,
		noDash = true,
		colorfulProgress = true,
		percentage = false,
		colorfulPercentage = false,
		backdrop = {
			enable = false,
			transparent = true,
			topLeftOffsetX = 0,
			topLeftOffsetY = 0,
			bottomRightOffsetX = 0,
			bottomRightOffsetY = 0,
		},
		header = {
			name = E.db.general.font,
			size = E.db.general.fontSize + 2,
			style = "OUTLINE",
			classColor = false,
			color = { r = 1, g = 1, b = 1 },
			uppercase = false,
		},
		cosmeticBar = {
			enable = true,
			texture = "WindTools Glow",
			widthMode = "ABSOLUTE",
			heightMode = "ABSOLUTE",
			width = 250,
			height = 2,
			offsetX = 0,
			offsetY = -12,
			border = "SHADOW",
			borderAlpha = 1,
			color = {
				mode = "GRADIENT",
				normalColor = { r = 0.000, g = 0.659, b = 1.000, a = 1 },
				gradientColor1 = { r = 0.32941, g = 0.52157, b = 0.93333, a = 1 },
				gradientColor2 = { r = 0.25882, g = 0.84314, b = 0.86667, a = 1 },
			},
		},
		title = {
			name = E.db.general.font,
			size = E.db.general.fontSize + 1,
			style = "OUTLINE",
			wordWrap = true,
			uppercase = false,
		},
		info = {
			name = E.db.general.font,
			size = E.db.general.fontSize - 1,
			style = "OUTLINE",
			wordWrap = true,
		},
		titleColor = {
			enable = true,
			classColor = false,
			customColorNormal = { r = 0.000, g = 0.659, b = 1.000 },
			customColorHighlight = { r = 0.282, g = 0.859, b = 0.984 },
		},
		infoColor = {
			enable = true,
			classColor = false,
			customColorNormal = { r = 0.842, g = 0.815, b = 0.677 },
			customColorHighlight = { r = 0.992, g = 0.965, b = 0.827 },
		},
		menuTitle = {
			enable = true,
			classColor = false,
			color = { r = 0.000, g = 0.659, b = 1.000 },
			font = {
				name = E.db.general.font,
				size = E.db.general.fontSize,
				style = "OUTLINE",
			},
		},
	},
}

---@class PrivateDB.skins
V.skins = {
	enable = true,
	windtools = true,
	removeParchment = true,
	merathilisUISkin = true,
	shadow = true,
	increasedSize = 0,
	color = { r = 0, g = 0, b = 0 },
	uiErrors = {
		enable = true,
		normalTextClassColor = false,
		height = 60,
		width = 1024,
		normalTextColor = C.GetRGBFromTemplate("neutral-50"),
		redTextColor = C.GetRGBFromTemplate("red-500"),
		yellowTextColor = C.GetRGBFromTemplate("yellow-300"),
	},
	actionStatus = {
		name = E.db.general.font,
		size = 15,
		style = "OUTLINE",
	},
	widgets = {
		button = {
			enable = true,
			backdrop = {
				enable = true,
				texture = "WindTools Glow",
				classColor = false,
				color = { r = 0.145, g = 0.353, b = 0.698 },
				removeBorderEffect = true,
				animation = {
					type = "fade",
					duration = 0.2,
					alpha = 1,
					fadeEase = "quadratic",
					fadeEaseInvert = false,
				},
			},
			selected = {
				enable = true,
				backdropClassColor = false,
				backdropColor = { r = 0.322, g = 0.608, b = 0.961 },
				backdropAlpha = 0.4,
				borderClassColor = false,
				borderColor = { r = 0.145, g = 0.353, b = 0.698 },
				borderAlpha = 1,
			},
			text = {
				enable = true,
				font = {
					name = E.db.general.font,
					style = "OUTLINE",
				},
			},
		},
		tab = {
			enable = true,
			backdrop = {
				enable = true,
				texture = "WindTools Glow",
				classColor = false,
				color = { r = 0.145, g = 0.353, b = 0.698 },
				animation = {
					type = "fade",
					duration = 0.2,
					alpha = 1,
					fadeEase = "quadratic",
					fadeEaseInvert = false,
				},
			},
			selected = {
				enable = true,
				texture = "WindTools Glow",
				backdropClassColor = false,
				backdropColor = { r = 0.322, g = 0.608, b = 0.961 },
				backdropAlpha = 0.4,
				borderClassColor = false,
				borderColor = { r = 0.145, g = 0.353, b = 0.698 },
				borderAlpha = 1,
			},
			text = {
				enable = true,
				normalClassColor = false,
				normalColor = { r = 1, g = 0.82, b = 0 },
				selectedClassColor = false,
				selectedColor = { r = 1, g = 1, b = 1 },
				font = {
					name = E.db.general.font,
					style = "OUTLINE",
				},
			},
		},
		checkBox = {
			enable = true,
			texture = "WindTools Glow",
			classColor = false,
			color = { r = 0.322, g = 0.608, b = 0.961, a = 0.8 },
		},
		slider = {
			enable = true,
			texture = "WindTools Glow",
			classColor = false,
			color = { r = 0.322, g = 0.608, b = 0.961, a = 0.8 },
		},
		treeGroupButton = {
			enable = true,
			backdrop = {
				enable = true,
				texture = "WindTools Glow",
				classColor = false,
				color = { r = 0.145, g = 0.353, b = 0.698 },
				alpha = 1,
				animation = {
					type = "fade",
					duration = 0.2,
					alpha = 1,
					fadeEase = "quadratic",
					fadeEaseInvert = false,
				},
			},
			selected = {
				enable = true,
				texture = "WindTools Glow",
				backdropClassColor = false,
				backdropColor = { r = 0.322, g = 0.608, b = 0.961 },
				backdropAlpha = 0.4,
				borderClassColor = false,
				borderColor = { r = 0.145, g = 0.353, b = 0.698 },
				borderAlpha = 0,
			},
			text = {
				enable = true,
				normalClassColor = false,
				normalColor = { r = 1, g = 0.82, b = 0 },
				selectedClassColor = false,
				selectedColor = { r = 1, g = 1, b = 1 },
				font = {
					name = E.db.general.font,
					style = "OUTLINE",
				},
			},
		},
	},
	lossOfControl = {
		enable = true,
		icon = {
			iconSize = 64,
			iconShadow = true,
			anchor = "LEFT",
			offsetX = 0,
			offsetY = 0,
		},
		abilityName = {
			hide = false,
			justifyH = "LEFT",
			offsetX = -20,
			offsetY = 18,
			font = {
				name = E.db.general.font,
				size = 20,
				style = "OUTLINE",
			},
		},
		timeLeft = {
			hide = false,
			justifyH = "LEFT",
			offsetX = -20,
			offsetY = -18,
			font = {
				name = E.db.general.font,
				size = 25,
				style = "OUTLINE",
			},
		},
		backdrop = {
			useCustomColor = false,
		},
	},
	addons = {
		auctionator = true,
		bugSack = true,
		immersion = true,
		omniCD = true,
		omniCDExtraBar = true,
		omniCDIcon = true,
		omniCDStatusBar = true,
		postal = true,
		tomTom = true,
		whisperPop = true,
	},
	libraries = {
		ace3 = true,
		ace3Dropdown = true,
		elioteDropDownMenu = true,
		libQTip = true,
		secureTabs = true,
	},
	blizzard = {
		enable = true,
		achievements = true,
		alerts = true,
		auctionHouse = true,
		bags = true,
		barberShop = true,
		battlefieldMap = true,
		binding = true,
		blackMarket = true,
		calendar = true,
		challenges = true,
		channels = true,
		character = true,
		collections = true,
		debugTools = true,
		dressingRoom = true,
		encounterJournal = true,
		friends = true,
		gameMenu = true,
		gossip = true,
		guild = true,
		guildBank = true,
		help = true,
		inspect = true,
		itemSocketing = true,
		lookingForGroup = true,
		loot = true,
		lossOfControl = true,
		macro = true,
		mail = true,
		merchant = true,
		microButtons = true,
		mirrorTimers = true,
		misc = true,
		objectiveTracker = true,
		quest = true,
		raidInfo = true,
		scenario = true,
		settingsPanel = true,
		stable = true,
		staticPopup = true,
		taxi = true,
		ticketStatus = true,
		timeManager = true,
		tooltips = true,
		trade = true,
		trainer = true,
		transmogrify = true,
		tutorial = true,
		worldMap = true,
	},
	elvui = {
		enable = true,
		actionBarsBackdrop = true,
		actionBarsButton = true,
		afk = true,
		auras = true,
		bags = true,
		castBars = true,
		chatCopyFrame = true,
		chatDataPanels = true,
		chatPanels = true,
		classBars = true,
		dataBars = true,
		dataPanels = true,
		lootRoll = true,
		miniMap = true,
		nameplates = true,
		option = true,
		panels = true,
		raidUtility = true,
		staticPopup = true,
		statusReport = true,
		totemTracker = true,
		unitFrames = true,
	},
}

---@class PrivateDB.tooltips
V.tooltips = {
	modifier = "SHIFT",
	titleIcon = {
		enable = true,
		width = 18,
		height = 18,
	},
	factionIcon = true,
}

---@class PrivateDB.social
V.social = {
	---@class PrivateDB.social.smartTab
	smartTab = {
		whisperTargets = {},
	},
}

---@class PrivateDB.unitFrames
V.unitFrames = {
	---@class PrivateDB.unitFrames.quickFocus
	quickFocus = {
		enable = false,
		modifier = "shift",
		button = "BUTTON1",
		setMark = false,
		safeMark = false,
		markNumber = 3,
	},
	roleIcon = {
		enable = true,
		roleIconStyle = "SUNUI",
	},
	tags = {
		enable = true,
	},
}
