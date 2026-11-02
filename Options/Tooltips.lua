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
		misc = {
			order = 5,
			type = "group",
			name = L["Miscellaneous"],
			inline = true,
			args = {
				forceItemLevel = {
					order = 1,
					type = "toggle",
					name = L["Force Item Level"],
					desc = L["Even you are not pressing the modifier key, the item level will still be shown."]
						.. "\n"
						.. C.StringByTemplate(L["It may broken inspect feature sometimes."], "yellow-400"),
					get = function(info)
						return E.db.WT.tooltips.elvUITweaks.forceItemLevel
					end,
					set = function(info, value)
						E.db.WT.tooltips.elvUITweaks.forceItemLevel = value
					end,
				},
			},
		},
	},
}

options.keystone = {
	order = 5,
	type = "group",
	name = L["Keystone"],
	get = function(info)
		return E.db.WT.tooltips[info[#info - 1]][info[#info]]
	end,
	set = function(info, value)
		E.db.WT.tooltips[info[#info - 1]][info[#info]] = value
	end,
	args = {
		description = {
			order = 1,
			type = "description",
			width = "full",
			name = C.StringByTemplate(
				format(L["The keystone information only available for players who installed Details! or %s."], W.Title),
				"yellow-400"
			),
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			desc = L["Show the keystone information in the tooltip."],
		},
		useAbbreviation = {
			order = 3,
			type = "toggle",
			name = L["Use Abbreviation"],
			desc = L["Use abbreviation for the keystone name."],
			disabled = function()
				return not E.db.WT.tooltips.keystone.enable
			end,
		},
		icon = {
			order = 4,
			type = "toggle",
			name = L["Add Icon"],
			desc = L["Show an icon for the keystone."],
			disabled = function()
				return not E.db.WT.tooltips.keystone.enable
			end,
			get = function(info)
				return E.db.WT.tooltips.keystone.icon.enable
			end,
			set = function(info, value)
				E.db.WT.tooltips.keystone.icon.enable = value
			end,
		},
		width = {
			order = 5,
			type = "range",
			name = L["Icon Width"],
			min = 1,
			max = 50,
			step = 1,
			disabled = function()
				return not E.db.WT.tooltips.keystone.enable or not E.db.WT.tooltips.keystone.icon.enable
			end,
			get = function(info)
				return E.db.WT.tooltips.keystone.icon.width
			end,
			set = function(info, value)
				E.db.WT.tooltips.keystone.icon.width = value
			end,
		},
		height = {
			order = 6,
			type = "range",
			name = L["Icon Height"],
			min = 1,
			max = 50,
			step = 1,
			disabled = function()
				return not E.db.WT.tooltips.keystone.enable or not E.db.WT.tooltips.keystone.icon.enable
			end,
			get = function(info)
				return E.db.WT.tooltips.keystone.icon.height
			end,
			set = function(info, value)
				E.db.WT.tooltips.keystone.icon.height = value
			end,
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
		resourcePage = {
			order = 9,
			type = "execute",
			name = F.GetWindStyleText(L["Reference"]),
			desc = format(
				"|cff00d1b2%s|r (%s)\n%s\n%s\n%s",
				L["Tips"],
				L["Editbox"],
				L["CTRL+A: Select All"],
				L["CTRL+C: Copy"],
				L["CTRL+V: Paste"]
			),
			func = function()
				if E.global.general.locale == "zhCN" or E.global.general.locale == "zhTW" then
					E:StaticPopup_Show(
						"WINDTOOLS_EDITBOX",
						nil,
						nil,
						"https://github.com/wind-addons/ElvUI_WindTools/wiki/预组建队伍玩家信息"
					)
				else
					E:StaticPopup_Show(
						"WINDTOOLS_EDITBOX",
						nil,
						nil,
						"https://github.com/wind-addons/ElvUI_WindTools/wiki/LFG-Player-Info"
					)
				end
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
