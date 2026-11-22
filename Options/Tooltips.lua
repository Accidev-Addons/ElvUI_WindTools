local W, F, E, L, V, P, G = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
local options = W.options.tooltips.args
local C = W.Utilities.Color
local LFGPI = W.Utilities.LFGPlayerInfo

local format = format
local ipairs = ipairs
local pairs = pairs
local tconcat = table.concat

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
					set = function(info, value)
						E.private.WT.tooltips.titleIcon[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
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

local groupInfoSections = {
	{ "activity", L["Activity name"] },
	{ "header", L["Summary line"] },
	{ "playstyle", L["Playstyle"] },
	{ "comment", L["Comment"] },
	{ "rules", L["Raid rules"] },
	{ "loot", L["Loot method"] },
	{ "requirements", L["Requirements"] },
	{ "voice", L["Voice chat"] },
	{ "leader", L["Leader"] },
	{ "age", L["Listing age"] },
	{ "members", L["Members"] },
	{ "missing", L["Missing classes"] },
	{ "friends", L["Friends"] },
	{ "ignored", L["Ignored players"] },
	{ "bosses", L["Defeated bosses"] },
	{ "autoAccept", L["Auto accept"] },
	{ "saved", L["Saved instance warning"] },
}

local playerTemplatePresets = {
	{ L["Like the default tooltip"], P.tooltips.groupInfo.playerTemplate },
	{
		L["With icons"],
		"{{roleIcon:14}} {{classIcon:14}} {{specIcon:14}} {{classColorStart}}{{name}}{{classColorEnd}} {{ilvlColorStart}}{{ilvl}}{{ilvlColorEnd}}{{categoryStart}} {{categoryIcon:14}}{{categoryEnd}}{{leaderStart}} {{leaderIcon:12}}{{leaderEnd}}",
	},
	{
		L["Compact"],
		"{{classColorStart}}{{name}}{{classColorEnd}} {{ilvlColorStart}}{{ilvl}}{{ilvlColorEnd}}{{leaderStart}} {{leaderIcon:12}}{{leaderEnd}}",
	},
	{
		L["Detailed"],
		"{{roleIcon:14}} {{specIcon:14}} {{classColorStart}}{{name}}{{classColorEnd}} {{grayStart}}{{specName}}{{grayEnd}} {{ilvlColorStart}}{{ilvl}}{{ilvlColorEnd}}{{categoryStart}} {{categoryIcon:14}} {{grayStart}}{{categoryName}}{{grayEnd}}{{categoryEnd}}{{leaderStart}} {{leaderIcon:12}}{{leaderEnd}}{{relationStart}} {{relation}}{{relationEnd}}",
	},
	{
		L["With Mythic+ rating"],
		"{{roleIcon:14}} {{classColorStart}}{{name}} - {{specName}}{{classColorEnd}} {{ilvlColorStart}}({{ilvl}}){{ilvlColorEnd}}{{keyRatingStart}} {{keyColorStart}}{{keyRating}}{{keyColorEnd}}{{keyRatingEnd}}{{leaderStart}} {{leaderIcon:12}}{{leaderEnd}}",
	},
}

local headerTemplatePresets = {
	{ L["Default"], P.tooltips.groupInfo.headerTemplate },
	{
		L["Compact"],
		"{{members}}{{maxStart}}/{{max}}{{maxEnd}}{{avgIlvlStart}}  {{ilvlColorStart}}{{avgIlvl}}{{ilvlColorEnd}}{{avgIlvlEnd}}",
	},
	{
		L["Detailed"],
		"{{members}}{{maxStart}}/{{max}}{{maxEnd}}{{freeStart}} {{greenStart}}(+{{free}}){{greenEnd}}{{freeEnd}}  {{tankIcon:14}} {{tanks}}  {{healerIcon:14}} {{healers}}  {{dpsIcon:14}} {{dps}}{{avgIlvlStart}}  {{ilvlColorStart}}{{avgIlvl}}{{ilvlColorEnd}} {{grayStart}}({{minIlvl}}-{{maxIlvl}}){{grayEnd}}{{avgIlvlEnd}}{{bossesStart}}  {{skull:12}}{{redStart}}{{bosses}}{{redEnd}}{{bossesEnd}}  {{grayStart}}{{age}}{{grayEnd}}",
	},
	{ L["Class icons"], "{{members}}{{maxStart}}/{{max}}{{maxEnd}}  {{classes:14}}" },
}

local function groupInfoDB()
	return E.db.WT.tooltips.groupInfo
end

local function groupInfoDisabled()
	return not groupInfoDB().enable
end

local function presetValues(presets)
	local values = {}
	for index, preset in ipairs(presets) do
		values[index] = preset[1]
	end
	return values
end

local function presetIndex(presets, template)
	for index, preset in ipairs(presets) do
		if preset[2] == template then
			return index
		end
	end
end

local function previewText(lines)
	return "\n" .. C.StringByTemplate(L["Preview"], "blue-400") .. ":\n" .. tconcat(lines, "\n") .. "\n"
end

options.groupInfo = {
	order = 6,
	type = "group",
	childGroups = "tab",
	get = function(info)
		return groupInfoDB()[info[#info]]
	end,
	set = function(info, value)
		groupInfoDB()[info[#info]] = value
	end,
	name = L["Group Info"],
	args = {
		general = {
			order = 1,
			type = "group",
			name = L["General"],
			args = {
				desc = {
					order = 0,
					type = "description",
					name = L["Rebuilds the tooltip of a group in the group finder. By default it looks like the standard tooltip with ElvUI icons; every part can be turned off and every line is a template."],
					fontSize = "medium",
				},
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
					disabled = groupInfoDisabled,
				},
				title = {
					order = 3,
					type = "toggle",
					name = L["Add Title"],
					desc = L["Display an additional title."],
					disabled = groupInfoDisabled,
				},
				highlightRequirements = {
					order = 4,
					type = "toggle",
					name = L["Highlight Requirements"],
					desc = L["Color the required item level green when you meet it and red when you do not."],
					disabled = groupInfoDisabled,
				},
				classIconStyle = {
					order = 5,
					name = L["Class Icon Style"],
					type = "select",
					disabled = groupInfoDisabled,
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
				sections = {
					order = 10,
					type = "multiselect",
					name = L["Tooltip Sections"],
					desc = L["Choose which parts of the tooltip are shown."],
					disabled = groupInfoDisabled,
					get = function(_, key)
						return groupInfoDB().sections[key]
					end,
					set = function(_, key, value)
						groupInfoDB().sections[key] = value
					end,
					values = function()
						local values = {}
						for _, section in ipairs(groupInfoSections) do
							values[section[1]] = section[2]
						end
						return values
					end,
				},
			},
		},
		members = {
			order = 2,
			type = "group",
			name = L["Members"],
			disabled = groupInfoDisabled,
			args = {
				memberMode = {
					order = 1,
					type = "select",
					name = L["Mode"],
					desc = L["Players: one line per player. Composition: players grouped by class and specialization."],
					values = {
						PLAYERS = L["Players"],
						COMPOSITION = L["Composition"],
						BOTH = L["Players and composition"],
					},
				},
				sortBy = {
					order = 2,
					type = "select",
					name = L["Sort"],
					values = {
						ROLE = L["Role, then item level"],
						ILVL = L["Item level"],
						CLASS = L["Class"],
						NAME = L["Name"],
						NONE = L["Server order"],
					},
				},
				roleHeaders = {
					order = 3,
					type = "toggle",
					name = L["Role Headers"],
					desc = L["Group players under tank, healer and damage headers."],
				},
				playerPreset = {
					order = 10,
					type = "select",
					name = L["Presets"],
					desc = L["Fill the player template with a ready-made example."],
					values = function()
						return presetValues(playerTemplatePresets)
					end,
					get = function()
						return presetIndex(playerTemplatePresets, groupInfoDB().playerTemplate)
					end,
					set = function(_, index)
						groupInfoDB().playerTemplate = playerTemplatePresets[index][2]
					end,
				},
				playerTemplate = {
					order = 11,
					type = "input",
					name = L["Player Template"],
					desc = function()
						return LFGPI:GetTagHelp("player")
					end,
					width = "full",
				},
				playerPreview = {
					order = 12,
					type = "description",
					name = function()
						LFGPI:SetClassIconStyle(groupInfoDB().classIconStyle)
						local lines = {}
						for _, member in ipairs(LFGPI:GetPreviewGroup().members) do
							lines[#lines + 1] = LFGPI:RenderPlayer(groupInfoDB().playerTemplate, member)
						end
						return previewText(lines)
					end,
				},
				template = {
					order = 20,
					type = "input",
					name = L["Composition Template"],
					desc = function()
						return LFGPI:GetTagHelp("player")
					end,
					width = "full",
				},
				templatePreview = {
					order = 21,
					type = "description",
					name = function()
						LFGPI:SetClassIconStyle(groupInfoDB().classIconStyle)
						local member = LFGPI:GetPreviewGroup().members[1]
						return previewText({ LFGPI:RenderPlayer("{{roleIcon:14}} " .. groupInfoDB().template, member) })
					end,
				},
				useDefaultTemplate = {
					order = 30,
					type = "execute",
					name = L["Default"],
					desc = L["Reset the template to default value."],
					func = function()
						groupInfoDB().playerTemplate = P.tooltips.groupInfo.playerTemplate
						groupInfoDB().template = P.tooltips.groupInfo.template
					end,
				},
			},
		},
		header = {
			order = 3,
			type = "group",
			name = L["Summary line"],
			disabled = groupInfoDisabled,
			args = {
				headerPreset = {
					order = 1,
					type = "select",
					name = L["Presets"],
					desc = L["Fill the summary template with a ready-made example."],
					values = function()
						return presetValues(headerTemplatePresets)
					end,
					get = function()
						return presetIndex(headerTemplatePresets, groupInfoDB().headerTemplate)
					end,
					set = function(_, index)
						groupInfoDB().headerTemplate = headerTemplatePresets[index][2]
					end,
				},
				headerTemplate = {
					order = 2,
					type = "input",
					name = L["Summary Template"],
					desc = function()
						return LFGPI:GetTagHelp("group")
					end,
					width = "full",
				},
				headerPreview = {
					order = 3,
					type = "description",
					name = function()
						LFGPI:SetClassIconStyle(groupInfoDB().classIconStyle)
						return previewText({ LFGPI:RenderGroup(groupInfoDB().headerTemplate, LFGPI:GetPreviewGroup()) })
					end,
				},
				useDefaultHeader = {
					order = 4,
					type = "execute",
					name = L["Default"],
					desc = L["Reset the template to default value."],
					func = function()
						groupInfoDB().headerTemplate = P.tooltips.groupInfo.headerTemplate
					end,
				},
			},
		},
		help = {
			order = 4,
			type = "group",
			name = L["Tag Reference"],
			args = {
				usage = {
					order = 1,
					type = "description",
					name = L["A template is plain text with tags in double braces. A tag is replaced with a value of the player or the group. Hover a template field to see this list next to it."]
						.. "\n",
					fontSize = "medium",
				},
				player = {
					order = 2,
					type = "group",
					inline = true,
					name = L["Player Template"] .. " / " .. L["Composition Template"],
					args = {
						text = {
							order = 1,
							type = "description",
							name = function()
								return LFGPI:GetTagHelp("player")
							end,
						},
					},
				},
				group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Summary Template"] .. " / " .. L["Row Template"],
					args = {
						text = {
							order = 1,
							type = "description",
							name = function()
								return LFGPI:GetTagHelp("group")
							end,
						},
					},
				},
			},
		},
	},
}
