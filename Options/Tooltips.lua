local W, F, E, L, V, P, G = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
local options = W.options.tooltips.args
local C = W.Utilities.Color
local LFGPI = W.Utilities.LFGPlayerInfo

local format = format
local pairs = pairs

local cache = {
	groupInfo = {},
}

options.desc = {
	order = 1,
	type = "group",
	inline = true,
	name = L["Description"],
	args = {
		feature = {
			order = 1,
			type = "description",
			name = L["Add some additional information to your tooltips."],
			fontSize = "medium",
		},
	},
}

options.general = {
	order = 2,
	type = "group",
	name = L["General"],
	get = function(info)
		return E.private.WT.tooltips[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.tooltips[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	args = {
		modifier = {
			order = 1,
			type = "select",
			name = L["General Modifier Key"],
			desc = format(L["The modifier key to show additional information from %s."], W.Title),
			set = function(info, value)
				E.private.WT.tooltips[info[#info]] = value
			end,
			values = {
				NONE = L["None"],
				SHIFT = L["Shift"],
				CTRL = L["Ctrl"],
				ALT = L["Alt"],
				ALT_SHIFT = format("%s + %s", L["Alt"], L["Shift"]),
				CTRL_SHIFT = format("%s + %s", L["Ctrl"], L["Shift"]),
				CTRL_ALT = format("%s + %s", L["Ctrl"], L["Alt"]),
				CTRL_ALT_SHIFT = format("%s + %s + %s", L["Ctrl"], L["Alt"], L["Shift"]),
			},
		},
		titleIcon = {
			order = 3,
			type = "group",
			name = L["Title Icon"],
			inline = true,
			get = function(info)
				return E.private.WT.tooltips.titleIcon[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.tooltips.titleIcon[info[#info]] = value
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Add an icon to the title of items, spells, achievements, and more."],
				},
				width = {
					order = 2,
					type = "range",
					name = L["Icon Width"],
					min = 1,
					max = 50,
					step = 1,
					disabled = function()
						return not E.private.WT.tooltips.titleIcon.enable
					end,
				},
				height = {
					order = 3,
					type = "range",
					name = L["Icon Height"],
					min = 1,
					max = 50,
					step = 1,
					disabled = function()
						return not E.private.WT.tooltips.titleIcon.enable
					end,
				},
			},
		},
		factionIcon = {
			order = 4,
			type = "toggle",
			name = L["Faction Icon"],
			desc = L["Show a faction icon in the top right of tooltips."],
		},
	},
}

options.elvUITweaks = {
	order = 3,
	type = "group",
	name = L["ElvUI Tooltip Tweaks"],
	get = function(info)
		return E.db.WT.tooltips[info[#info - 2]][info[#info - 1]][info[#info]]
	end,
	set = function(info, value)
		E.db.WT.tooltips[info[#info - 2]][info[#info - 1]][info[#info]] = value
	end,
	args = {
		healthBar = {
			order = 1,
			type = "group",
			inline = true,
			name = L["Health Bar"],
			args = {
				barYOffset = {
					order = 1,
					type = "range",
					name = L["Health Bar Y-Offset"],
					desc = L["Change the position of the health bar."],
					min = -50,
					max = 50,
					step = 1,
				},
				textYOffset = {
					order = 2,
					type = "range",
					name = L["Health Text Y-Offset"],
					desc = L["Change the position of the health text."],
					min = -50,
					max = 50,
					step = 1,
				},
			},
		},
		specIcon = {
			order = 2,
			type = "group",
			name = L["Spec Icon"],
			inline = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Show the icon of the specialization."],
				},
				width = {
					order = 2,
					type = "range",
					name = L["Icon Width"],
					min = 1,
					max = 50,
					step = 1,
					disabled = function()
						return not E.db.WT.tooltips.elvUITweaks.specIcon.enable
					end,
				},
				height = {
					order = 3,
					type = "range",
					name = L["Icon Height"],
					min = 1,
					max = 50,
					step = 1,
					disabled = function()
						return not E.db.WT.tooltips.elvUITweaks.specIcon.enable
					end,
				},
			},
		},
		raceIcon = {
			order = 3,
			type = "group",
			name = L["Race Icon"],
			inline = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Show the icon of the player race."],
				},
				width = {
					order = 2,
					type = "range",
					name = L["Icon Width"],
					min = 1,
					max = 50,
					step = 1,
					disabled = function()
						return not E.db.WT.tooltips.elvUITweaks.raceIcon.enable
					end,
				},
				height = {
					order = 3,
					type = "range",
					name = L["Icon Height"],
					min = 1,
					max = 50,
					step = 1,
					disabled = function()
						return not E.db.WT.tooltips.elvUITweaks.raceIcon.enable
					end,
				},
			},
		},
	},
}

options.progression = {
	order = 4,
	type = "group",
	name = L["Raid Progression"],
	get = function(info)
		return E.db.WT.tooltips.progression[info[#info]]
	end,
	set = function(info, value)
		E.db.WT.tooltips.progression[info[#info]] = value
	end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			desc = L["Display the raid progression of max level players while the general modifier key is held."],
		},
		checkAchievements = {
			order = 2,
			type = "toggle",
			name = L["Check Achievements"],
			desc = L["Check achievement completion instead of boss kill stats.\nSome servers log incorrect boss kill statistics, this is an alternative way to get player progress."],
			disabled = function()
				return not E.db.WT.tooltips.progression.enable
			end,
		},
		checkPlayer = {
			order = 3,
			type = "toggle",
			name = L["Check Player"],
			desc = L["Also show your own progression on your tooltip."],
			disabled = function()
				return not E.db.WT.tooltips.progression.enable
			end,
		},
		tiers = {
			order = 4,
			type = "multiselect",
			name = L["Raids"],
			get = function(_, key)
				return E.db.WT.tooltips.progression.tiers[key]
			end,
			set = function(_, key, value)
				E.db.WT.tooltips.progression.tiers[key] = value
			end,
			disabled = function()
				return not E.db.WT.tooltips.progression.enable
			end,
			values = {
				RS = L["Ruby Sanctum"],
				ICC = L["Icecrown Citadel"],
				ToC = L["Trial of the Crusader"],
				Ulduar = L["Ulduar"],
			},
		},
	},
}

options.groupInfo = {
	order = 6,
	type = "group",
	get = function(info)
		return E.db.WT.tooltips.groupInfo[info[#info]]
	end,
	set = function(info, value)
		E.db.WT.tooltips.groupInfo[info[#info]] = value
	end,
	name = L["Group Info"],
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			desc = L["Add LFG group info to tooltip."],
		},
		excludeDungeon = {
			order = 2,
			type = "toggle",
			name = L["Exclude Dungeons"],
			desc = L["It will not show the group info for dungeons."],
		},
		hideBlizzard = {
			order = 3,
			type = "toggle",
			name = L["Hide Blizzard"],
			desc = L["Hide the default Blizzard group information."],
		},
		title = {
			order = 4,
			type = "toggle",
			name = L["Add Title"],
			desc = L["Display an additional title."],
		},
		mode = {
			order = 5,
			name = L["Mode"],
			type = "select",
			values = {
				NORMAL = L["Normal"],
				COMPACT = L["Compact"],
			},
		},
		classIconStyle = {
			order = 6,
			name = L["Class Icon Style"],
			type = "select",
			values = function()
				local result = {}
				for _, style in pairs(F.GetClassIconStyleList()) do
					local warriorIcon = F.GetClassIconStringWithStyle("WARRIOR", style)
					local druidIcon = F.GetClassIconStringWithStyle("DRUID", style)
					local paladinIcon = F.GetClassIconStringWithStyle("PALADIN", style)

					if warriorIcon and druidIcon and paladinIcon then
						result[style] = format("%s %s %s", warriorIcon, druidIcon, paladinIcon)
					end
				end
				return result
			end,
		},
		betterAlign1 = {
			order = 7,
			type = "description",
			name = "",
			width = "full",
		},
		template = {
			order = 8,
			type = "input",
			name = L["Template"],
			desc = L["Please click the button below to read reference."],
			width = "full",
			get = function(info)
				return cache.groupInfo.template or E.db.WT.tooltips[info[#info - 1]].template
			end,
			set = function(info, value)
				cache.groupInfo.template = value
			end,
		},
		useDefaultTemplate = {
			order = 10,
			type = "execute",
			name = L["Default"],
			func = function(info)
				E.db.WT.tooltips[info[#info - 1]].template = P.tooltips[info[#info - 1]].template
				cache.groupInfo.template = nil
			end,
		},
		applyButton = {
			order = 11,
			type = "execute",
			name = L["Apply"],
			disabled = function()
				return not cache.groupInfo.template
			end,
			func = function(info)
				E.db.WT.tooltips[info[#info - 1]].template = cache.groupInfo.template
			end,
		},
		betterAlign2 = {
			order = 12,
			type = "description",
			name = "",
			width = "full",
		},
		previewText = {
			order = 13,
			type = "description",
			name = function(info)
				LFGPI:SetClassIconStyle(E.db.WT.tooltips[info[#info - 1]].classIconStyle)
				local text =
					LFGPI:ConductPreview(cache.groupInfo.template or E.db.WT.tooltips[info[#info - 1]].template)
				return L["Preview"] .. ": " .. text
			end,
		},
	},
}
