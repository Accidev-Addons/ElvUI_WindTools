local W, F, E, L, V, P, G = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
local options = W.options.maps.args
local LSM = E.Libs.LSM
local C = W.Utilities.Color
local MB = W:GetModule("MinimapButtons")
local RM = W:GetModule("RectangleMinimap")
local WM = W:GetModule("WorldMap")

local format = format
local gsub = gsub
local pairs = pairs

options.rectangleMinimap = {
	order = 2,
	type = "group",
	name = L["Rectangle Minimap"],
	get = function(info)
		return E.db.WT.maps.rectangleMinimap[info[#info]]
	end,
	set = function(info, value)
		E.db.WT.maps.rectangleMinimap[info[#info]] = value
		RM:ChangeShape()
	end,
	args = {
		desc = {
			order = 1,
			type = "group",
			inline = true,
			name = L["Description"],
			args = {
				feature = {
					order = 1,
					type = "description",
					name = L["Change the shape of ElvUI minimap."],
					fontSize = "medium",
				},
			},
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			width = "full",
		},
		heightPercentage = {
			order = 3,
			type = "range",
			name = L["Height Percentage"],
			desc = L["Percentage of ElvUI minimap size."],
			min = 0.01,
			max = 1,
			step = 0.01,
		},
		fixHereBeDragons = {
			order = 4,
			type = "toggle",
			name = L["Fix HereBeDragons"],
			desc = format(
				"%s (%s)",
				L["Fix pins added by HereBeDragons to hide correctly on rectangular minimaps."],
				format(L["Related addons: %s"], strjoin(", ", "HandyNotes", "SilverDragon", "RareScanner"))
			),
		},
		pinHidingTolerance = {
			order = 5,
			type = "range",
			name = L["Pin Hiding Tolerance"],
			desc = L["Prevents pins from appearing outside the rectangular minimap boundaries. Increase this value to hide pins further from the edge."],
			min = 0,
			max = 100,
			step = 1,
		},
	},
}

options.minimapButtons = {
	order = 3,
	type = "group",
	name = L["Minimap Buttons"],
	args = {
		desc = {
			order = 1,
			type = "group",
			inline = true,
			name = L["Description"],
			args = {
				feature = {
					order = 1,
					type = "description",
					name = function()
						if MB.StopRunning then
							local errorMsg = format(L["Because of %s, this module will not be loaded."], MB.StopRunning)
							return C.StringByTemplate(errorMsg, "rose-500")
						else
							return L["Add an extra bar to collect minimap buttons."]
						end
					end,
					fontSize = "medium",
				},
			},
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			desc = L["Toggle minimap buttons bar."],
			get = function(info)
				return E.private.WT.maps.minimapButtons[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.maps.minimapButtons[info[#info]] = value
				if value then
					E.private.general.minimapButtonGrabber.enable = false
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		mouseOver = {
			order = 3,
			type = "toggle",
			name = L["Mouse Over"],
			desc = L["Only show minimap buttons bar when you mouse over it."],
			get = function(info)
				return E.private.WT.maps.minimapButtons[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.maps.minimapButtons[info[#info]] = value
				MB:UpdateMouseOverConfig()
			end,
		},
		barConfig = {
			order = 4,
			type = "group",
			inline = true,
			name = L["Minimap Buttons Bar"],
			get = function(info)
				return E.private.WT.maps.minimapButtons[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.maps.minimapButtons[info[#info]] = value
				MB:UpdateLayout()
			end,
			args = {
				backdrop = {
					order = 1,
					type = "toggle",
					name = L["Bar Backdrop"],
					desc = L["Show a backdrop of the bar."],
				},
				backdropSpacing = {
					order = 2,
					type = "range",
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0,
					max = 30,
					step = 1,
				},
				inverseDirection = {
					order = 3,
					type = "toggle",
					name = L["Inverse Direction"],
					desc = L["Reverse the direction of adding buttons."],
				},
				reverseOrder = {
					order = 4,
					type = "toggle",
					name = L["Reverse Order"],
					desc = L["Reverse the sort order of buttons."],
				},
				orientation = {
					order = 5,
					type = "select",
					name = L["Orientation"],
					desc = L["Arrangement direction of the bar."],
					values = {
						NOANCHOR = L["Drag"],
						HORIZONTAL = L["Horizontal"],
						VERTICAL = L["Vertical"],
					},
					set = function(info, value)
						E.private.WT.maps.minimapButtons[info[#info]] = value
						MB:UpdateLayout()
					end,
				},
				betterAlign = {
					order = 6,
					type = "description",
					name = " ",
					width = "full",
				},
				sortingPriority = {
					order = 7,
					type = "input",
					multiline = 3,
					width = "full",
					name = L["Sorting Priority"],
					desc = format(
						"%s\n\n%s\n%s\n%s\n\n%s\n%s",
						L["Set the sorting priority of minimap buttons by patterns."],
						L["Enter a comma-separated list of Lua regex patterns."],
						L["Buttons matching earlier patterns will appear first."],
						L["Leading and trailing whitespace in each pattern will be automatically trimmed."],
						L["If you are not familiar with Lua regex, try using AI to help you."],
						format(
							L["Use command %s to view all handled buttons and their states"],
							C.StringByTemplate("/wtmmb all", "teal-300")
						)
					),
					set = function(info, value)
						E.private.WT.maps.minimapButtons[info[#info]] = value
						MB:UpdateLayout()
					end,
				},
				resetSortingPriority = {
					order = 8,
					type = "execute",
					name = L["Reset"],
					desc = L["Reset sorting priority to default value."],
					func = function()
						E.private.WT.maps.minimapButtons.sortingPriority = V.maps.minimapButtons.sortingPriority
						MB:UpdateLayout()
					end,
				},
				hiddenPatterns = {
					order = 9,
					type = "input",
					multiline = 3,
					width = "full",
					name = L["Hidden Patterns"],
					desc = format(
						"%s\n\n%s\n%s\n%s\n\n%s\n%s",
						L["Set the buttons to be completely hidden on the minimap."],
						L["Enter a comma-separated list of Lua regex patterns."],
						L["Buttons matching any of these patterns will be hidden."],
						L["Leading and trailing whitespace in each pattern will be automatically trimmed."],
						L["If you are not familiar with Lua regex, try using AI to help you."],
						format(
							L["Use command %s to view all handled buttons and their states"],
							C.StringByTemplate("/wtmmb all", "teal-300")
						)
					),
					set = function(info, value)
						E.private.WT.maps.minimapButtons[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				resetHiddenPatterns = {
					order = 10,
					type = "execute",
					name = L["Reset"],
					desc = L["Reset hidden patterns to default value."],
					func = function()
						E.private.WT.maps.minimapButtons.hiddenPatterns = V.maps.minimapButtons.hiddenPatterns
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				ignorePatterns = {
					order = 11,
					type = "input",
					multiline = 3,
					width = "full",
					name = L["Ignore Patterns"],
					desc = format(
						"%s\n\n%s\n%s\n%s\n\n%s\n%s",
						L["Set the buttons to be ignored by this module."],
						L["Enter a comma-separated list of Lua regex patterns."],
						L["Buttons matching any of these patterns will be ignored, meaning they won't be moved to the bar or hidden."],
						L["Leading and trailing whitespace in each pattern will be automatically trimmed."],
						L["If you are not familiar with Lua regex, try using AI to help you."],
						format(
							L["Use command %s to view all handled buttons and their states"],
							C.StringByTemplate("/wtmmb all", "teal-300")
						)
					),
					set = function(info, value)
						E.private.WT.maps.minimapButtons[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				resetIgnorePatterns = {
					order = 12,
					type = "execute",
					name = L["Reset"],
					desc = L["Reset ignore patterns to default value."],
					func = function()
						E.private.WT.maps.minimapButtons.ignorePatterns = V.maps.minimapButtons.ignorePatterns
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
			},
		},
		buttonsConfig = {
			order = 5,
			type = "group",
			inline = true,
			name = L["Buttons"],
			get = function(info)
				return E.private.WT.maps.minimapButtons[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.maps.minimapButtons[info[#info]] = value
				MB:UpdateLayout()
			end,
			args = {
				buttonsPerRow = {
					order = 1,
					type = "range",
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1,
					max = 30,
					step = 1,
				},
				buttonSize = {
					order = 2,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the buttons."],
					get = function(info)
						return E.private.WT.maps.minimapButtons[info[#info]]
					end,
					set = function(info, value)
						E.private.WT.maps.minimapButtons[info[#info]] = value
						MB:SkinMinimapButtons()
					end,
					min = 15,
					max = 60,
					step = 1,
				},
				spacing = {
					order = 3,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = 0,
					max = 30,
					step = 1,
				},
			},
		},
	},
}

options.worldMap = {
	order = 4,
	type = "group",
	name = L["World Map"],
	get = function(info)
		return E.private.WT.maps.worldMap[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.maps.worldMap[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	args = {
		desc = {
			order = 1,
			type = "group",
			inline = true,
			name = L["Description"],
			args = {
				feature = {
					order = 1,
					type = "description",
					name = function()
						if WM.StopRunning then
							local errorMsg = format(L["Because of %s, this module will not be loaded."], WM.StopRunning)
							return C.StringByTemplate(errorMsg, "rose-500")
						else
							return L["Resize world map."]
						end
					end,
					fontSize = "medium",
				},
			},
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
		},
		scale = {
			order = 4,
			type = "group",
			inline = true,
			name = L["Scale"],
			desc = L["Resize world map."],
			get = function(info)
				return E.private.WT.maps.worldMap.scale[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.maps.worldMap.scale[info[#info]] = value
				E:StaticPopup_Show("PRIVATE_RL")
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Resize world map."],
				},
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					min = 0.1,
					max = 3,
					step = 0.01,
				},
			},
		},
	},
}

options.instanceDifficulty = {
	order = 5,
	type = "group",
	name = L["Instance Difficulty"],
	get = function(info)
		return E.private.WT.maps.instanceDifficulty[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.maps.instanceDifficulty[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	args = {
		desc = {
			order = 1,
			type = "group",
			inline = true,
			name = L["Description"],
			args = {
				feature = {
					order = 1,
					type = "description",
					name = L["Reskin the instance difficulty in text style."],
					fontSize = "medium",
				},
			},
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
		},
		align = {
			order = 3,
			type = "select",
			name = L["Text Align"],
			values = {
				LEFT = L["Left"],
				CENTER = L["Center"],
				RIGHT = L["Right"],
			},
		},
		hideBlizzard = {
			order = 4,
			type = "toggle",
			name = L["Hide Blizzard Indicator"],
		},
		font = {
			order = 5,
			type = "group",
			name = L["Font"],
			inline = true,
			get = function(info)
				return E.private.WT.maps.instanceDifficulty.font[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.maps.instanceDifficulty.font[info[#info]] = value
				E:StaticPopup_Show("PRIVATE_RL")
			end,
			args = {
				name = {
					order = 1,
					type = "select",
					dialogControl = "LSM30_Font",
					name = L["Font"],
					values = LSM:HashTable("font"),
				},
				style = {
					order = 2,
					type = "select",
					name = L["Outline"],
					values = {
						NONE = L["None"],
						OUTLINE = L["Outline"],
						THICKOUTLINE = L["Thick"],
						SHADOW = L["|cff888888Shadow|r"],
						SHADOWOUTLINE = L["|cff888888Shadow|r Outline"],
						SHADOWTHICKOUTLINE = L["|cff888888Shadow|r Thick"],
						MONOCHROME = L["|cFFAAAAAAMono|r"],
						MONOCHROMEOUTLINE = L["|cFFAAAAAAMono|r Outline"],
						MONOCHROMETHICKOUTLINE = L["|cFFAAAAAAMono|r Thick"],
					},
				},
				size = {
					order = 3,
					name = L["Size"],
					type = "range",
					min = 5,
					max = 60,
					step = 1,
				},
			},
		},
		difficulty = {
			order = 6,
			type = "group",
			name = L["Difficulty"],
			inline = true,
			get = function(info)
				return E.private.WT.maps.instanceDifficulty.difficulty[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.maps.instanceDifficulty.difficulty[info[#info]] = value
				E:StaticPopup_Show("PRIVATE_RL")
			end,
			args = {
				custom = {
					order = 1,
					type = "toggle",
					name = L["Custom"],
				},
				customStrings = {
					order = 2,
					type = "group",
					inline = true,
					name = L["Custom Strings"],
					hidden = function()
						return not E.private.WT.maps.instanceDifficulty.difficulty.custom
					end,
					args = {},
				},
			},
		},
	},
}

do
	local order = 1
	for k, v in pairs(V.maps.instanceDifficulty.difficulty.customStrings) do
		options.instanceDifficulty.args.difficulty.args.customStrings.args[k] = {
			order = order,
			type = "group",
			inline = true,
			name = "* " .. v,
			args = {
				text = {
					order = 1,
					type = "input",
					name = L["Custom String"],
					desc = format(
						"%s\n%s\n%s\n\n%s\n%s",
						L["Placeholders"] .. ":",
						format("%s - %s", C.StringByTemplate("%mplus%", "blue-400"), L["M+ Level"]),
						format("%s - %s", C.StringByTemplate("%numPlayers%", "blue-400"), L["Number of Players"]),
						L["Custom color can be used by adding the following code"] .. ":",
						format("\124\124cff|cffff0000rr|r|cff00ff00gg|r|cff0000ffbb|r%s\124\124r", L["Custom String"])
					),
					get = function()
						return E.private.WT.maps.instanceDifficulty.difficulty.customStrings[k]
					end,
					set = function(_, value)
						E.private.WT.maps.instanceDifficulty.difficulty.customStrings[k] =
							gsub(value, "\124\124", "\124")
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				useDefault = {
					order = 2,
					type = "execute",
					name = L["Use Default"],
					func = function()
						E.private.WT.maps.instanceDifficulty.difficulty.customStrings[k] = v
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
			},
		}

		order = order + 1
	end
end
