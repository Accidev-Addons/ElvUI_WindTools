local W, F, E, L, V, P, G = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
local options = W.options.skins.args
local LSM = E.Libs.LSM
local S = W.Modules.Skins ---@type Skins
local C = W.Utilities.Color

local _G = _G
local format = format
local pairs = pairs
local select = select
local type = type

local GetSpellInfo = GetSpellInfo
local GetTime = GetTime

local function DoesAddOnExist(name)
	return select(6, _G.GetAddOnInfo(name)) ~= "MISSING"
end

local RED_FONT_COLOR = RED_FONT_COLOR
local YELLOW_FONT_COLOR = YELLOW_FONT_COLOR

local function ApplyLossOfControlLive()
	local frame = _G.LossOfControlFrame
	if frame and frame:IsShown() then
		S:LossOfControlFrame_SetUpDisplay(frame)
	end
end

options.desc = {
	order = 1,
	type = "group",
	inline = true,
	name = L["Description"],
	args = {
		feature_1 = {
			order = 1,
			type = "description",
			name = L["WindTools provides a new shadow style for original ElvUI."],
			fontSize = "medium",
		},
		feature_2 = {
			order = 2,
			type = "description",
			name = L["You can customize the global shadow color, disable some skins, set the level of vignetting, etc."],
			fontSize = "medium",
		},
		feature_3 = {
			order = 3,
			type = "description",
			name = L["WindSkins is all in control, enjoy your own ElvUI interface!"],
			fontSize = "medium",
		},
	},
}

options.general = {
	order = 2,
	type = "group",
	name = L["General"],
	get = function(info)
		return E.private.WT.skins[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.skins[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			width = 0.7,
		},
		merathilisUISkin = {
			order = 3,
			type = "toggle",
			name = format(L["Use %s Skins"], L["MerathilisUI"]),
			width = 1.2,
			desc = format(
				"%s\n%s: %s",
				format(L["Add skins for all modules inside %s with %s functions."], W.Title, L["MerathilisUI"]),
				C.StringByTemplate(L["Notice"], "rose-500"),
				format(L["It doesn't mean that the %s Skins will not be applied."], W.Title)
			),
			hidden = function()
				return not DoesAddOnExist("ElvUI_MerathilisUI")
			end,
		},
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			inline = true,
			disabled = function()
				return not E.private.WT.skins.enable
			end,
			args = {
				windtools = {
					order = 1,
					type = "toggle",
					name = L["WindTools Modules"],
				},
				removeParchment = {
					order = 2,
					type = "toggle",
					name = L["Parchment Remover"],
					set = function(info, value)
						E.private.WT.skins.removeParchment = value
						E.private.skins.parchmentRemoverEnable = E.private.WT.skins.removeParchment
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
			},
		},
		shadow = {
			order = 5,
			type = "group",
			name = L["Shadow"],
			inline = true,
			disabled = function()
				return not E.private.WT.skins.enable
			end,
			args = {
				shadow = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				increasedSize = {
					order = 2,
					type = "range",
					name = L["Increase Size"],
					desc = L["Make shadow thicker."],
					min = 0,
					max = 10,
					step = 1,
				},
				color = {
					order = 3,
					type = "color",
					name = L["Shadow Color"],
					hasAlpha = false,
					get = function(info)
						local db = E.private.WT.skins.color
						local default = V.skins.color
						return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
					end,
					set = function(info, r, g, b)
						local db = E.private.WT.skins.color
						db.r, db.g, db.b = r, g, b
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function()
						return not E.private.WT.skins.enable
					end,
				},
			},
		},
		vignetting = {
			order = 6,
			type = "group",
			name = L["Vignetting"],
			inline = true,
			get = function(info)
				return E.db.WT.skins.vignetting[info[#info]]
			end,
			set = function(info, value)
				E.db.WT.skins.vignetting[info[#info]] = value
				S:UpdateVignettingConfig()
			end,
			disabled = function()
				return not E.private.WT.skins.enable
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				level = {
					order = 2,
					type = "range",
					name = L["Level"],
					desc = L["Change the alpha of vignetting."],
					disabled = function()
						return not E.db.WT.skins.vignetting.enable
					end,
					min = 1,
					max = 100,
					step = 1,
				},
			},
		},
		uiErrors = {
			order = 7,
			type = "group",
			name = W.Title .. " - " .. L["UI Errors Frame"],
			inline = true,
			disabled = function()
				return not E.private.WT.skins.enable
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Replace the native UIErrorsFrame with a custom one that supports skinning."],
					get = function()
						return E.private.WT.skins.uiErrors.enable
					end,
					set = function(_, value)
						E.private.WT.skins.uiErrors.enable = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				desc = {
					order = 2,
					type = "description",
					name = L["The middle top errors / messages frame (also used for quest progress text)."],
				},
				width = {
					order = 3,
					type = "range",
					name = L["Width"],
					desc = L["Set the width of UIErrorsFrame."],
					min = 256,
					max = 4096,
					step = 1,
					disabled = function()
						return not E.private.WT.skins.uiErrors.enable
					end,
					get = function()
						return E.private.WT.skins.uiErrors.width
					end,
					set = function(_, value)
						E.private.WT.skins.uiErrors.width = value
						if W.UIErrorsFrame then
							W.UIErrorsFrame:Width(value)
						end
					end,
				},
				height = {
					order = 4,
					type = "range",
					name = L["Height"],
					min = 20,
					max = 240,
					step = 1,
					disabled = function()
						return not E.private.WT.skins.uiErrors.enable
					end,
					get = function()
						return E.private.WT.skins.uiErrors.height or (V.skins.uiErrors.height or 60)
					end,
					set = function(_, value)
						E.private.WT.skins.uiErrors.height = value
						if W.UIErrorsFrame then
							W.UIErrorsFrame:Height(value)
						end
					end,
				},
				normalTextClassColor = {
					order = 5,
					type = "toggle",
					name = L["Class Color"],
					desc = L["Replace the default color used for messages with class color."],
					disabled = function()
						return not E.private.WT.skins.uiErrors.enable
					end,
					get = function(info)
						return E.private.WT.skins.uiErrors.normalTextClassColor
					end,
					set = function(info, value)
						E.private.WT.skins.uiErrors.normalTextClassColor = value
					end,
				},
				normalTextColor = {
					order = 6,
					type = "color",
					name = L["Default"],
					desc = L["Replace the default color used for messages."],
					hasAlpha = true,
					disabled = function()
						return not E.private.WT.skins.uiErrors.enable
					end,
					get = function(info)
						local db = E.private.WT.skins.uiErrors.normalTextColor
						local default = V.skins.uiErrors.normalTextColor
						return db.r, db.g, db.b, db.a, default.r, default.g, default.b, default.a
					end,
					set = function(info, r, g, b, a)
						local db = E.private.WT.skins.uiErrors.normalTextColor
						db.r, db.g, db.b, db.a = r, g, b, a
					end,
					hidden = function()
						return E.private.WT.skins.uiErrors.normalTextClassColor
					end,
				},
				redTextColor = {
					order = 7,
					type = "color",
					name = L["Red"],
					desc = L["Replace the default color used for error messages."],
					hasAlpha = true,
					disabled = function()
						return not E.private.WT.skins.uiErrors.enable
					end,
					get = function(info)
						local db = E.private.WT.skins.uiErrors.redTextColor
						local default = V.skins.uiErrors.redTextColor
						return db.r, db.g, db.b, db.a, default.r, default.g, default.b, default.a
					end,
					set = function(info, r, g, b, a)
						local db = E.private.WT.skins.uiErrors.redTextColor
						db.r, db.g, db.b, db.a = r, g, b, a
					end,
				},
				yellowTextColor = {
					order = 8,
					type = "color",
					name = L["Yellow"],
					desc = L["Replace the default color used for warning messages."],
					hasAlpha = true,
					disabled = function()
						return not E.private.WT.skins.uiErrors.enable
					end,
					get = function(info)
						local db = E.private.WT.skins.uiErrors.yellowTextColor
						local default = V.skins.uiErrors.yellowTextColor
						return db.r, db.g, db.b, db.a, default.r, default.g, default.b, default.a
					end,
					set = function(info, r, g, b, a)
						local db = E.private.WT.skins.uiErrors.yellowTextColor
						db.r, db.g, db.b, db.a = r, g, b, a
					end,
				},
				testButton = {
					order = 9,
					type = "execute",
					name = L["Test"],
					func = function()
						_G.UIErrorsFrame:AddMessage(format("[%s] %s", L["WindTools"], L["This is a test message"]))
						_G.UIErrorsFrame:AddMessage(
							format("[%s] %s (%s)", L["WindTools"], L["This is a test message"], L["Red"]),
							RED_FONT_COLOR:GetRGBA()
						)
						_G.UIErrorsFrame:AddMessage(
							format("[%s] %s (%s)", L["WindTools"], L["This is a test message"], L["Yellow"]),
							YELLOW_FONT_COLOR:GetRGBA()
						)
					end,
				},
			},
		},
	},
}

options.font = {
	order = 3,
	type = "group",
	name = L["Font"],
	args = {
		actionStatus = {
			order = 1,
			type = "group",
			inline = true,
			name = L["Action Status"],
			get = function(info)
				return E.private.WT.skins.actionStatus[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.actionStatus[info[#info]] = value
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
	},
}

options.lossOfControl = {
	order = 5,
	type = "group",
	name = L["Loss Of Control"],
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info)
				return E.private.WT.skins.lossOfControl[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.lossOfControl[info[#info]] = value
				E:StaticPopup_Show("PRIVATE_RL")
			end,
			disabled = function()
				return not E.private.WT.skins.blizzard.enable
					or not E.private.skins.blizzard.losscontrol
					or not E.private.WT.skins.blizzard.lossOfControl
			end,
		},
		test = {
			order = 2,
			type = "group",
			inline = true,
			name = L["Test"],
			args = {
				testStun = {
					order = 1,
					type = "execute",
					name = L["Test"],
					func = function()
						local frame = _G.LossOfControlFrame
						if not frame then
							return
						end

						_G.LossOfControlFrame_SetUpDisplay(
							frame,
							true,
							"STUN",
							408,
							L["Stunned"],
							select(3, GetSpellInfo(408)),
							GetTime(),
							6,
							6,
							0,
							5,
							1
						)
						frame.fadeDelayTime = nil
						frame.fadeTime = 3600
					end,
				},
				stop = {
					order = 2,
					type = "execute",
					name = L["Stop"],
					func = function()
						local frame = _G.LossOfControlFrame
						if frame then
							frame:Hide()
						end
					end,
				},
			},
		},
		icon = {
			order = 10,
			type = "group",
			inline = true,
			name = L["Icon"],
			get = function(info)
				return E.private.WT.skins.lossOfControl[info[#info - 1]][info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.lossOfControl[info[#info - 1]][info[#info]] = value
				ApplyLossOfControlLive()
			end,
			disabled = function()
				return not E.private.WT.skins.lossOfControl.enable
			end,
			args = {
				iconSize = {
					order = 1,
					type = "range",
					name = L["Icon Size"],
					min = 20,
					max = 120,
					step = 1,
				},
				iconShadow = {
					order = 2,
					type = "toggle",
					name = L["Icon Shadow"],
				},
				anchor = {
					order = 4,
					type = "select",
					name = L["Anchor"],
					desc = L["The anchor point of the icon within the frame."],
					values = {
						TOPLEFT = L["TOPLEFT"],
						TOP = L["TOP"],
						TOPRIGHT = L["TOPRIGHT"],
						LEFT = L["LEFT"],
						CENTER = L["CENTER"],
						RIGHT = L["RIGHT"],
						BOTTOMLEFT = L["BOTTOMLEFT"],
						BOTTOM = L["BOTTOM"],
						BOTTOMRIGHT = L["BOTTOMRIGHT"],
					},
				},
				offsetX = {
					order = 5,
					type = "range",
					name = L["X-Offset"],
					desc = L["Horizontal offset from the anchor point."],
					min = -200,
					max = 200,
					step = 1,
				},
				offsetY = {
					order = 6,
					type = "range",
					name = L["Y-Offset"],
					desc = L["Vertical offset from the anchor point."],
					min = -200,
					max = 200,
					step = 1,
				},
			},
		},
		abilityName = {
			order = 11,
			type = "group",
			inline = true,
			name = L["Ability Name"],
			get = function(info)
				return E.private.WT.skins.lossOfControl[info[#info - 1]][info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.lossOfControl[info[#info - 1]][info[#info]] = value
				ApplyLossOfControlLive()
			end,
			disabled = function()
				return not E.private.WT.skins.lossOfControl.enable
			end,
			args = {
				hide = {
					order = 1,
					type = "toggle",
					name = L["Hide"],
					desc = L["Hide the ability name text and only show the icon."],
				},
				justifyH = {
					order = 2,
					type = "select",
					name = L["Alignment"],
					desc = L["Controls the anchor side of the text relative to the frame center."],
					values = {
						LEFT = L["LEFT"],
						CENTER = L["CENTER"],
						RIGHT = L["RIGHT"],
					},
				},
				offsetX = {
					order = 3,
					type = "range",
					name = L["X-Offset"],
					desc = L["Horizontal offset from the frame center."],
					min = -200,
					max = 200,
					step = 1,
				},
				offsetY = {
					order = 4,
					type = "range",
					name = L["Y-Offset"],
					desc = L["Vertical offset from the frame center."],
					min = -200,
					max = 200,
					step = 1,
				},
				font = {
					order = 5,
					type = "group",
					inline = true,
					name = L["Font"],
					get = function(info)
						return E.private.WT.skins.lossOfControl[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.lossOfControl[info[#info - 2]][info[#info - 1]][info[#info]] = value
						ApplyLossOfControlLive()
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
			},
		},
		timeLeft = {
			order = 12,
			type = "group",
			inline = true,
			name = L["Time Left"],
			get = function(info)
				return E.private.WT.skins.lossOfControl[info[#info - 1]][info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.lossOfControl[info[#info - 1]][info[#info]] = value
				ApplyLossOfControlLive()
			end,
			disabled = function()
				return not E.private.WT.skins.lossOfControl.enable
			end,
			args = {
				hide = {
					order = 1,
					type = "toggle",
					name = L["Hide"],
					desc = L["Hide the time left text."],
				},
				justifyH = {
					order = 2,
					type = "select",
					name = L["Alignment"],
					desc = L["Controls the anchor side of the text relative to the frame center."],
					values = {
						LEFT = L["LEFT"],
						CENTER = L["CENTER"],
						RIGHT = L["RIGHT"],
					},
				},
				offsetX = {
					order = 3,
					type = "range",
					name = L["X-Offset"],
					desc = L["Horizontal offset from the frame center."],
					min = -200,
					max = 200,
					step = 1,
				},
				offsetY = {
					order = 4,
					type = "range",
					name = L["Y-Offset"],
					desc = L["Vertical offset from the frame center."],
					min = -200,
					max = 200,
					step = 1,
				},
				font = {
					order = 5,
					type = "group",
					inline = true,
					name = L["Font"],
					get = function(info)
						return E.private.WT.skins.lossOfControl[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.lossOfControl[info[#info - 2]][info[#info - 1]][info[#info]] = value
						ApplyLossOfControlLive()
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
			},
		},
		backdrop = {
			order = 13,
			type = "group",
			inline = true,
			name = L["Backdrop"],
			get = function(info)
				local db = E.private.WT.skins.lossOfControl.backdrop
				return db[info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.lossOfControl.backdrop[info[#info]] = value
				ApplyLossOfControlLive()
			end,
			disabled = function()
				return not E.private.WT.skins.lossOfControl.enable
			end,
			args = {
				useCustomColor = {
					order = 1,
					type = "toggle",
					name = L["Use Custom Color"],
					desc = L["Use a custom border color for the icon backdrop."],
				},
				borderColor = {
					order = 2,
					type = "color",
					name = L["Border Color"],
					hasAlpha = false,
					get = function(info)
						local db = E.private.WT.skins.lossOfControl.backdrop
						if not db.useCustomColor then
							return E.db.general.bordercolor.r, E.db.general.bordercolor.g, E.db.general.bordercolor.b
						end
						return db.r or 1, db.g or 1, db.b or 1
					end,
					set = function(info, r, g, b)
						local db = E.private.WT.skins.lossOfControl.backdrop
						db.r, db.g, db.b = r, g, b
						ApplyLossOfControlLive()
					end,
					disabled = function()
						return not E.private.WT.skins.lossOfControl.enable
							or not E.private.WT.skins.lossOfControl.backdrop.useCustomColor
					end,
				},
			},
		},
	},
}

options.blizzard = {
	order = 6,
	type = "group",
	name = L["Blizzard"],
	get = function(info)
		return E.private.WT.skins.blizzard[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.skins.blizzard[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	disabled = function()
		return not E.private.WT.skins.enable
	end,
	args = {
		enable = {
			order = 0,
			type = "toggle",
			name = L["Enable"],
		},
		enableAll = {
			order = 1,
			type = "execute",
			name = L["Enable All"],
			func = function()
				for key in pairs(V.skins.blizzard) do
					E.private.WT.skins.blizzard[key] = true
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		disableAll = {
			order = 2,
			type = "execute",
			name = L["Disable All"],
			func = function()
				for key in pairs(V.skins.blizzard) do
					if key ~= "enable" then
						E.private.WT.skins.blizzard[key] = false
					end
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		betterOption = {
			order = 3,
			type = "description",
			name = " ",
			width = "full",
		},
		achievements = {
			order = 10,
			type = "toggle",
			name = L["Achievements"],
		},
		alerts = {
			order = 10,
			type = "toggle",
			name = L["Alert Frames"],
		},
		auctionHouse = {
			order = 10,
			type = "toggle",
			name = L["Auction House"],
		},
		bags = {
			order = 10,
			type = "toggle",
			name = L["Bags"],
		},
		barberShop = {
			order = 10,
			type = "toggle",
			name = L["Barber Shop"],
		},
		battlefieldMap = {
			order = 10,
			type = "toggle",
			name = L["Battlefield Map"],
		},
		binding = {
			order = 10,
			type = "toggle",
			name = L["Binding"],
		},
		blackMarket = {
			order = 10,
			type = "toggle",
			name = L["Black Market"],
		},
		calendar = {
			order = 10,
			type = "toggle",
			name = L["Calendar"],
		},
		challenges = {
			order = 10,
			type = "toggle",
			name = L["Challenges"],
		},
		channels = {
			order = 10,
			type = "toggle",
			name = L["Channels"],
		},
		character = {
			order = 10,
			type = "toggle",
			name = L["Character"],
		},
		collections = {
			order = 10,
			type = "toggle",
			name = L["Collections"],
		},
		debugTools = {
			order = 10,
			type = "toggle",
			name = L["Debug Tools"],
		},
		dressingRoom = {
			order = 10,
			type = "toggle",
			name = L["Dressing Room"],
		},
		encounterJournal = {
			order = 10,
			type = "toggle",
			name = L["Encounter Journal"],
		},
		friends = {
			order = 10,
			type = "toggle",
			name = L["Friend List"],
		},
		gameMenu = {
			order = 10,
			type = "toggle",
			name = L["Game Menu"],
		},
		gossip = {
			order = 10,
			type = "toggle",
			name = L["Gossip Frame"],
		},
		guild = {
			order = 10,
			type = "toggle",
			name = L["Guild"],
		},
		guildBank = {
			order = 10,
			type = "toggle",
			name = L["Guild Bank"],
		},
		help = {
			order = 10,
			type = "toggle",
			name = L["Help Frame"],
		},
		inspect = {
			order = 10,
			type = "toggle",
			name = L["Inspect"],
		},
		itemSocketing = {
			order = 10,
			type = "toggle",
			name = L["Item Socketing"],
		},
		lookingForGroup = {
			order = 10,
			type = "toggle",
			name = L["Looking For Group"],
		},
		loot = {
			order = 10,
			type = "toggle",
			name = L["Loot Frames"],
		},
		lossOfControl = {
			order = 10,
			type = "toggle",
			name = L["Loss Of Control"],
		},
		macro = {
			order = 10,
			type = "toggle",
			name = L["Macros"],
		},
		mail = {
			order = 10,
			type = "toggle",
			name = L["Mail Frame"],
		},
		merchant = {
			order = 10,
			type = "toggle",
			name = L["Merchant"],
		},
		microButtons = {
			order = 10,
			type = "toggle",
			name = L["Micro Bar"],
		},
		mirrorTimers = {
			order = 10,
			type = "toggle",
			name = L["Mirror Timers"],
		},
		misc = {
			order = 10,
			type = "toggle",
			name = L["Misc Frames"],
		},
		objectiveTracker = {
			order = 10,
			type = "toggle",
			name = L["Objective Tracker"],
		},
		quest = {
			order = 10,
			type = "toggle",
			name = L["Quest Frames"],
		},
		raidInfo = {
			order = 10,
			type = "toggle",
			name = L["Raid Info"],
		},
		scenario = {
			order = 10,
			type = "toggle",
			name = L["Scenario"],
		},
		settingsPanel = {
			order = 10,
			type = "toggle",
			name = L["Setting Panel"],
		},
		stable = {
			order = 10,
			type = "toggle",
			name = L["Stable"],
		},
		staticPopup = {
			order = 10,
			type = "toggle",
			name = L["Static Popup"],
		},
		taxi = {
			order = 10,
			type = "toggle",
			name = L["Taxi"],
		},
		ticketStatus = {
			order = 10,
			type = "toggle",
			name = L["Ticket Status"],
		},
		timeManager = {
			order = 10,
			type = "toggle",
			name = L["Stopwatch"],
		},
		tooltips = {
			order = 10,
			type = "toggle",
			name = L["Tooltips"],
		},
		trade = {
			order = 10,
			type = "toggle",
			name = L["Trade"],
		},
		trainer = {
			order = 10,
			type = "toggle",
			name = L["Trainer"],
		},
		transmogrify = {
			order = 10,
			type = "toggle",
			name = L["Transmogrify"],
		},
		tutorial = {
			order = 10,
			type = "toggle",
			name = L["Tutorials"],
		},
		worldMap = {
			order = 10,
			type = "toggle",
			name = L["World Map"],
		},
	},
}

options.elvui = {
	order = 6,
	type = "group",
	name = L["ElvUI"],
	get = function(info)
		return E.private.WT.skins.elvui[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.skins.elvui[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	disabled = function()
		return not E.private.WT.skins.enable
	end,
	args = {
		enable = {
			order = 0,
			type = "toggle",
			name = L["Enable"],
		},
		enableAll = {
			order = 1,
			type = "execute",
			name = L["Enable All"],
			func = function()
				for key in pairs(V.skins.elvui) do
					E.private.WT.skins.elvui[key] = true
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		disableAll = {
			order = 2,
			type = "execute",
			name = L["Disable All"],
			func = function()
				for key in pairs(V.skins.elvui) do
					if key ~= "enable" then
						E.private.WT.skins.elvui[key] = false
					end
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		betterOption = {
			order = 3,
			type = "description",
			name = " ",
			width = "full",
		},
		actionBarsBackdrop = {
			order = 10,
			type = "toggle",
			name = L["Actionbars Backdrop"],
		},
		actionBarsButton = {
			order = 10,
			type = "toggle",
			name = L["Actionbars Button"],
		},
		afk = {
			order = 10,
			type = "toggle",
			name = L["AFK Mode"],
		},
		auras = {
			order = 10,
			type = "toggle",
			name = L["Auras"],
		},
		bags = {
			order = 10,
			type = "toggle",
			name = L["Bags"],
		},
		castBars = {
			order = 10,
			type = "toggle",
			name = L["Cast Bar"],
		},
		chatDataPanels = {
			order = 10,
			type = "toggle",
			name = L["Chat Data Panels"],
		},
		chatPanels = {
			order = 10,
			type = "toggle",
			name = L["Chat Panels"],
		},
		classBars = {
			order = 10,
			type = "toggle",
			name = L["Class Bars"],
		},
		chatCopyFrame = {
			order = 10,
			type = "toggle",
			name = L["Chat Copy Frame"],
		},
		dataBars = {
			order = 10,
			type = "toggle",
			name = L["Data Bars"],
		},
		dataPanels = {
			order = 10,
			type = "toggle",
			name = L["Data Panels"],
		},
		lootRoll = {
			order = 10,
			type = "toggle",
			name = L["Loot Roll"],
		},
		miniMap = {
			order = 10,
			type = "toggle",
			name = L["Minimap"],
		},
		nameplates = {
			order = 10,
			type = "toggle",
			name = L["Nameplates"],
		},
		option = {
			order = 10,
			type = "toggle",
			name = L["Options"],
		},
		panels = {
			order = 10,
			type = "toggle",
			name = L["Panels"],
		},
		raidUtility = {
			order = 10,
			type = "toggle",
			name = L["Raid Utility"],
		},
		staticPopup = {
			order = 10,
			type = "toggle",
			name = L["Static Popup"],
		},
		statusReport = {
			order = 10,
			type = "toggle",
			name = L["Status Report"],
		},
		totemTracker = {
			order = 10,
			type = "toggle",
			name = L["Totem Tracker"],
		},
		unitFrames = {
			order = 10,
			type = "toggle",
			name = L["Unit Frames"],
		},
	},
}

for key, value in pairs(options.elvui.args) do
	if key ~= "enable" then
		value.disabled = function()
			return not E.private.WT.skins.elvui.enable
		end
	end
end

-- WIP label
-- "addon" .. " " .. C.StringByTemplate(L["WIP"], "rose-500"),

options.addons = {
	order = 7,
	type = "group",
	name = L["Addons"],
	get = function(info)
		return E.private.WT.skins.addons[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.skins.addons[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	disabled = function()
		return not E.private.WT.skins.enable
	end,
	args = {
		enableAll = {
			order = 1,
			type = "execute",
			name = L["Enable All"],
			func = function()
				for key in pairs(V.skins.addons) do
					E.private.WT.skins.addons[key] = true
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		disableAll = {
			order = 2,
			type = "execute",
			name = L["Disable All"],
			func = function()
				for key in pairs(V.skins.addons) do
					E.private.WT.skins.addons[key] = false
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		descGroup = {
			order = 3,
			type = "group",
			name = " ",
			inline = true,
			args = {
				desc = {
					order = 1,
					type = "description",
					name = C.StringByTemplate(L["Notice"], "rose-500")
						.. " "
						.. L["Skins only work if you installed and loaded the addon."],
					width = "full",
					fontSize = "medium",
				},
			},
		},
		betterOption = {
			order = 9,
			type = "description",
			name = " ",
			width = "full",
		},
		auctionator = {
			order = 10,
			type = "toggle",
			name = L["Auctionator"],
			addonName = "Auctionator",
			addonskinsKey = "Auctionator",
		},
		bugSack = {
			order = 10,
			type = "toggle",
			name = L["BugSack"],
			addonName = "BugSack",
			addonskinsKey = "BugSack",
		},
		immersion = {
			order = 10,
			type = "toggle",
			name = L["Immersion"],
			addonName = "Immersion",
			addonskinsKey = "Immersion",
		},
		omniCD = {
			order = 10,
			type = "toggle",
			name = L["OmniCD"],
			addonName = "OmniCD",
		},
		omniCDExtraBar = {
			order = 10,
			type = "toggle",
			name = L["OmniCD Extra Bar"],
			desc = L["Add a shadowed background to the group title and adjust its position slightly upward."],
			hidden = function()
				return not E.private.WT.skins.addons.omniCD
			end,
			addonName = "OmniCD",
		},
		omniCDIcon = {
			order = 10,
			type = "toggle",
			name = L["OmniCD Icon"],
			hidden = function()
				return not E.private.WT.skins.addons.omniCD
			end,
			addonName = "OmniCD",
		},
		omniCDStatusBar = {
			order = 10,
			type = "toggle",
			name = L["OmniCD Status Bar"],
			hidden = function()
				return not E.private.WT.skins.addons.omniCD
			end,
			addonName = "OmniCD",
		},
		postal = {
			order = 10,
			type = "toggle",
			name = L["Postal"],
			addonName = "Postal",
			addonskinsKey = "Postal",
		},
		tomTom = {
			order = 10,
			type = "toggle",
			name = L["TomTom"],
			addonName = "TomTom",
			addonskinsKey = "TomTom",
		},
		whisperPop = {
			order = 10,
			type = "toggle",
			name = L["WhisperPop"],
			addonName = "WhisperPop",
			addonskinsKey = "WhisperPop",
		},
	},
}

local function GenerateAddOnSkinsGetFunction(name)
	if type(name) == "string" then
		return function(info)
			return DoesAddOnExist(name) and E.private.WT.skins.addons[info[#info]]
		end
	elseif type(name) == "table" then
		return function(info)
			local isValid = false
			for _, addon in pairs(name) do
				isValid = isValid or DoesAddOnExist(addon)
			end
			return isValid and E.private.WT.skins.addons[info[#info]]
		end
	end
end

local function GenerateAddOnSkinsSetFunction(addonskinsKey)
	if addonskinsKey then
		return function(info, value)
			E.private.WT.skins.addons[info[#info]] = value
			if value then
				S:DisableAddOnSkin(addonskinsKey)
			end
			E:StaticPopup_Show("PRIVATE_RL")
		end
	else
		return function(info, value)
			E.private.WT.skins.addons[info[#info]] = value
			E:StaticPopup_Show("PRIVATE_RL")
		end
	end
end

local function GenerateAddOnSkinsDisabledFunction(name)
	if type(name) == "string" then
		return function(info)
			return not DoesAddOnExist(name) or not E.private.WT.skins.enable
		end
	elseif type(name) == "table" then
		return function(info)
			local isValid = false
			for _, addon in pairs(name) do
				isValid = isValid or DoesAddOnExist(addon)
			end
			return not isValid or not E.private.WT.skins.enable
		end
	end
end

for _, option in pairs(options.addons.args) do
	if option.addonName then
		option.get = GenerateAddOnSkinsGetFunction(option.addonName)
		option.set = GenerateAddOnSkinsSetFunction(option.addonskinsKey)
		option.disabled = GenerateAddOnSkinsDisabledFunction(option.addonName)

		option.addonName = nil
		option.addonskinsKey = nil
		option.width = option.width or 1.5
		option.hidden = option.hidden or false
	end
end

options.widgets = {
	order = 8,
	type = "group",
	name = L["Widgets"],
	disabled = function()
		return not E.private.WT.skins.enable
	end,
	args = {
		enableAll = {
			order = 1,
			type = "execute",
			name = L["Enable All"],
			func = function()
				for key in pairs(V.skins.widgets) do
					E.private.WT.skins.widgets[key].enable = true
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		disableAll = {
			order = 2,
			type = "execute",
			name = L["Disable All"],
			func = function()
				for key in pairs(V.skins.widgets) do
					E.private.WT.skins.widgets[key].enable = false
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		descGroup = {
			order = 3,
			type = "group",
			name = " ",
			inline = true,
			args = {
				desc = {
					order = 1,
					type = "description",
					name = L["These skins will affect all widgets handled by ElvUI Skins."],
					width = "full",
					fontSize = "medium",
				},
			},
		},
		button = {
			order = 10,
			type = "group",
			name = L["Button"],
			desc = function(info)
				return F.GetWidgetTipsString(info[#info])
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					width = "full",
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				tip = {
					order = 2,
					type = "description",
					name = "",
					image = function()
						return W.Media.Textures.widgetsTips, 512, 170
					end,
					imageCoords = function(info)
						return F.GetWidgetTips(info[#info - 1])
					end,
				},
				backdrop = {
					order = 3,
					type = "group",
					name = L["Additional Backdrop"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						texture = {
							order = 2,
							type = "select",
							name = L["Texture"],
							dialogControl = "LSM30_Statusbar",
							values = LSM:HashTable("statusbar"),
						},
						removeBorderEffect = {
							order = 3,
							type = "toggle",
							name = L["Remove Border Effect"],
							width = 1.5,
						},
						classColor = {
							order = 4,
							type = "toggle",
							name = L["Class Color"],
						},
						color = {
							order = 5,
							type = "color",
							name = L["Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].classColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
					},
				},
				selected = {
					order = 4,
					type = "group",
					name = L["Selected Backdrop & Border"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						backdropClassColor = {
							order = 2,
							type = "toggle",
							name = L["Backdrop Class Color"],
							width = 1.5,
						},
						backdropColor = {
							order = 3,
							type = "color",
							name = L["Backdrop Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].backdropClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						backdropAlpha = {
							order = 4,
							type = "range",
							name = L["Backdrop Alpha"],
							min = 0,
							max = 1,
							step = 0.01,
						},
						borderClassColor = {
							order = 5,
							type = "toggle",
							name = L["Border Class Color"],
							width = 1.5,
						},
						borderColor = {
							order = 6,
							type = "color",
							name = L["Border Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].borderClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b, a)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						borderAlpha = {
							order = 7,
							type = "range",
							name = L["Border Alpha"],
							min = 0,
							max = 1,
							step = 0.01,
						},
					},
				},
				text = {
					order = 5,
					type = "group",
					name = L["Text"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						font = {
							order = 6,
							type = "group",
							inline = true,
							name = L["Font Setting"],
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 3]].enable
									or not E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].enable
							end,
							get = function(info)
								return E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].font[info[#info]]
							end,
							set = function(info, value)
								E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].font[info[#info]] = value
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
										OUTLINE = L["OUTLINE"],
										THICKOUTLINE = L["THICKOUTLINE"],
										SHADOW = L["SHADOW"],
										SHADOWOUTLINE = L["SHADOWOUTLINE"],
										SHADOWTHICKOUTLINE = L["SHADOWTHICKOUTLINE"],
										MONOCHROME = L["MONOCHROME"],
										MONOCHROMEOUTLINE = L["MONOCROMEOUTLINE"],
										MONOCHROMETHICKOUTLINE = L["MONOCHROMETHICKOUTLINE"],
									},
								},
							},
						},
					},
				},
			},
		},
		treeGroupButton = {
			order = 11,
			type = "group",
			name = L["Tree Group Button"],
			desc = function(info)
				return F.GetWidgetTipsString(info[#info])
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					width = "full",
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				tip = {
					order = 2,
					type = "description",
					name = "",
					image = function()
						return W.Media.Textures.widgetsTips, 512, 170
					end,
					imageCoords = function(info)
						return F.GetWidgetTips(info[#info - 1])
					end,
				},
				backdrop = {
					order = 3,
					type = "group",
					name = L["Additional Backdrop"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						texture = {
							order = 2,
							type = "select",
							name = L["Texture"],
							dialogControl = "LSM30_Statusbar",
							values = LSM:HashTable("statusbar"),
						},
						classColor = {
							order = 3,
							type = "toggle",
							name = L["Class Color"],
						},
						color = {
							order = 4,
							type = "color",
							name = L["Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].classColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
					},
				},
				selected = {
					order = 4,
					type = "group",
					name = L["Selected Backdrop & Border"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						texture = {
							order = 2,
							type = "select",
							name = L["Texture"],
							dialogControl = "LSM30_Statusbar",
							values = LSM:HashTable("statusbar"),
						},
						backdropClassColor = {
							order = 3,
							type = "toggle",
							name = L["Backdrop Class Color"],
							width = 1.5,
						},
						backdropColor = {
							order = 4,
							type = "color",
							name = L["Backdrop Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].backdropClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						backdropAlpha = {
							order = 5,
							type = "range",
							name = L["Backdrop Alpha"],
							min = 0,
							max = 1,
							step = 0.01,
						},
						borderClassColor = {
							order = 6,
							type = "toggle",
							name = L["Border Class Color"],
							width = 1.5,
						},
						borderColor = {
							order = 7,
							type = "color",
							name = L["Border Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].borderClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						borderAlpha = {
							order = 8,
							type = "range",
							name = L["Border Alpha"],
							min = 0,
							max = 1,
							step = 0.01,
						},
					},
				},
				text = {
					order = 5,
					type = "group",
					name = L["Text"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						normalClassColor = {
							order = 2,
							type = "toggle",
							name = L["Normal Class Color"],
							width = 1.5,
						},
						normalColor = {
							order = 3,
							type = "color",
							name = L["Normal Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].normalClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						selectedClassColor = {
							order = 4,
							type = "toggle",
							name = L["Selected Class Color"],
							width = 1.5,
						},
						selectedColor = {
							order = 5,
							type = "color",
							name = L["Selected Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].selectedClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						font = {
							order = 6,
							type = "group",
							inline = true,
							name = L["Font Setting"],
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 3]].enable
									or not E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].enable
							end,
							get = function(info)
								return E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].font[info[#info]]
							end,
							set = function(info, value)
								E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].font[info[#info]] = value
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
										OUTLINE = L["OUTLINE"],
										THICKOUTLINE = L["THICKOUTLINE"],
										SHADOW = L["SHADOW"],
										SHADOWOUTLINE = L["SHADOWOUTLINE"],
										SHADOWTHICKOUTLINE = L["SHADOWTHICKOUTLINE"],
										MONOCHROME = L["MONOCHROME"],
										MONOCHROMEOUTLINE = L["MONOCROMEOUTLINE"],
										MONOCHROMETHICKOUTLINE = L["MONOCHROMETHICKOUTLINE"],
									},
								},
							},
						},
					},
				},
			},
		},
		tab = {
			order = 12,
			type = "group",
			name = L["Tab"],
			desc = function(info)
				return F.GetWidgetTipsString(info[#info])
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					width = "full",
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
				},
				tip = {
					order = 2,
					type = "description",
					name = "",
					image = function()
						return W.Media.Textures.widgetsTips, 512, 170
					end,
					imageCoords = function(info)
						return F.GetWidgetTips(info[#info - 1])
					end,
				},
				backdrop = {
					order = 3,
					type = "group",
					name = L["Additional Backdrop"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						texture = {
							order = 2,
							type = "select",
							name = L["Texture"],
							dialogControl = "LSM30_Statusbar",
							values = LSM:HashTable("statusbar"),
						},
						classColor = {
							order = 3,
							type = "toggle",
							name = L["Class Color"],
						},
						color = {
							order = 4,
							type = "color",
							name = L["Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].classColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
					},
				},
				selected = {
					order = 4,
					type = "group",
					name = L["Selected Backdrop & Border"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						texture = {
							order = 2,
							type = "select",
							name = L["Texture"],
							dialogControl = "LSM30_Statusbar",
							values = LSM:HashTable("statusbar"),
						},
						backdropClassColor = {
							order = 3,
							type = "toggle",
							name = L["Backdrop Class Color"],
							width = 1.5,
						},
						backdropColor = {
							order = 4,
							type = "color",
							name = L["Backdrop Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].backdropClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						backdropAlpha = {
							order = 5,
							type = "range",
							name = L["Backdrop Alpha"],
							min = 0,
							max = 1,
							step = 0.01,
						},
						borderClassColor = {
							order = 6,
							type = "toggle",
							name = L["Border Class Color"],
							width = 1.5,
						},
						borderColor = {
							order = 7,
							type = "color",
							name = L["Border Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].borderClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b, a)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						borderAlpha = {
							order = 8,
							type = "range",
							name = L["Border Alpha"],
							min = 0,
							max = 1,
							step = 0.01,
						},
					},
				},
				text = {
					order = 5,
					type = "group",
					name = L["Text"],
					inline = true,
					get = function(info)
						return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
					end,
					set = function(info, value)
						E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 2]].enable
							or not E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].enable
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							width = "full",
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 2]].enable
							end,
						},
						normalClassColor = {
							order = 2,
							type = "toggle",
							name = L["Normal Class Color"],
							width = 1.5,
						},
						normalColor = {
							order = 3,
							type = "color",
							name = L["Normal Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].normalClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						selectedClassColor = {
							order = 4,
							type = "toggle",
							name = L["Selected Class Color"],
							width = 1.5,
						},
						selectedColor = {
							order = 5,
							type = "color",
							name = L["Selected Color"],
							hasAlpha = false,
							hidden = function(info)
								return E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]].selectedClassColor
							end,
							get = function(info)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								local default = V.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								return db.r, db.g, db.b, nil, default.r, default.g, default.b, nil
							end,
							set = function(info, r, g, b)
								local db = E.private.WT.skins.widgets[info[#info - 2]][info[#info - 1]][info[#info]]
								db.r, db.g, db.b = r, g, b
							end,
						},
						font = {
							order = 6,
							type = "group",
							inline = true,
							name = L["Font Setting"],
							disabled = function(info)
								return not E.private.WT.skins.widgets[info[#info - 3]].enable
									or not E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].enable
							end,
							get = function(info)
								return E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].font[info[#info]]
							end,
							set = function(info, value)
								E.private.WT.skins.widgets[info[#info - 3]][info[#info - 2]].font[info[#info]] = value
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
										OUTLINE = L["OUTLINE"],
										THICKOUTLINE = L["THICKOUTLINE"],
										SHADOW = L["SHADOW"],
										SHADOWOUTLINE = L["SHADOWOUTLINE"],
										SHADOWTHICKOUTLINE = L["SHADOWTHICKOUTLINE"],
										MONOCHROME = L["MONOCHROME"],
										MONOCHROMEOUTLINE = L["MONOCROMEOUTLINE"],
										MONOCHROMETHICKOUTLINE = L["MONOCHROMETHICKOUTLINE"],
									},
								},
							},
						},
					},
				},
			},
		},
		checkBox = {
			order = 13,
			type = "group",
			name = L["Check Box"],
			desc = function(info)
				return F.GetWidgetTipsString(info[#info])
			end,
			get = function(info)
				return E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.widgets[info[#info - 1]][info[#info]] = value
				E:StaticPopup_Show("PRIVATE_RL")
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					width = "full",
				},
				desc = {
					order = 2,
					type = "description",
					name = C.StringByTemplate(
						L["To enable this feature, you need to enable the check box skin in ElvUI Skins first."],
						"rose-500"
					),
					hidden = function(info)
						return E.private.skins.checkBoxSkin
					end,
				},
				tip = {
					order = 3,
					type = "description",
					name = "",
					image = function()
						return W.Media.Textures.widgetsTips, 512, 170
					end,
					imageCoords = function(info)
						return F.GetWidgetTips(info[#info - 1])
					end,
				},
				texture = {
					order = 4,
					type = "select",
					name = L["Texture"],
					dialogControl = "LSM30_Statusbar",
					values = LSM:HashTable("statusbar"),
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 1]].enable
					end,
				},
				classColor = {
					order = 5,
					type = "toggle",
					name = L["Class Color"],
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 1]].enable
					end,
				},
				color = {
					order = 6,
					type = "color",
					name = L["Color"],
					hasAlpha = true,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 1]].enable
					end,
					hidden = function(info)
						return E.private.WT.skins.widgets[info[#info - 1]].classColor
					end,
					get = function(info)
						local db = E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
						local default = V.skins.widgets[info[#info - 1]][info[#info]]
						return db.r, db.g, db.b, db.a, default.r, default.g, default.b, default.a
					end,
					set = function(info, r, g, b, a)
						local db = E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
						db.r, db.g, db.b, db.a = r, g, b, a
					end,
				},
			},
		},
		slider = {
			order = 14,
			type = "group",
			name = L["Slider"],
			desc = function(info)
				return F.GetWidgetTipsString(info[#info])
			end,
			get = function(info)
				return E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
			end,
			set = function(info, value)
				E.private.WT.skins.widgets[info[#info - 1]][info[#info]] = value
				E:StaticPopup_Show("PRIVATE_RL")
			end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					width = "full",
				},
				tip = {
					order = 2,
					type = "description",
					name = "",
					image = function()
						return W.Media.Textures.widgetsTips, 512, 170
					end,
					imageCoords = function(info)
						return F.GetWidgetTips(info[#info - 1])
					end,
				},
				texture = {
					order = 3,
					type = "select",
					name = L["Texture"],
					dialogControl = "LSM30_Statusbar",
					values = LSM:HashTable("statusbar"),
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 1]].enable
					end,
				},
				classColor = {
					order = 4,
					type = "toggle",
					name = L["Class Color"],
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 1]].enable
					end,
				},
				color = {
					order = 5,
					type = "color",
					name = L["Color"],
					hasAlpha = true,
					disabled = function(info)
						return not E.private.WT.skins.widgets[info[#info - 1]].enable
					end,
					hidden = function(info)
						return E.private.WT.skins.widgets[info[#info - 1]].classColor
					end,
					get = function(info)
						local db = E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
						local default = V.skins.widgets[info[#info - 1]][info[#info]]
						return db.r, db.g, db.b, db.a, default.r, default.g, default.b, default.a
					end,
					set = function(info, r, g, b, a)
						local db = E.private.WT.skins.widgets[info[#info - 1]][info[#info]]
						db.r, db.g, db.b, db.a = r, g, b, a
					end,
				},
			},
		},
	},
}

for _, widget in pairs({ "button", "treeGroupButton", "tab" }) do
	options.widgets.args[widget].args.backdrop.args.animation = {
		order = 10,
		type = "group",
		name = L["Animation Effect"],
		disabled = function()
			return not E.private.WT.skins.enable
				or not E.private.WT.skins.widgets[widget].enable
				or not E.private.WT.skins.widgets[widget].backdrop.enable
		end,
		get = function(info)
			return E.private.WT.skins.widgets[widget].backdrop.animation[info[#info]]
		end,
		set = function(info, value)
			E.private.WT.skins.widgets[widget].backdrop.animation[info[#info]] = value
		end,
		args = {
			type = {
				order = 1,
				type = "select",
				name = L["Type"],
				desc = L["The type of animation activated when a button is hovered."],
				values = {
					fade = L["Fade"],
				},
			},
			duration = {
				order = 2,
				type = "range",
				name = L["Duration"],
				desc = L["The duration of the animation in seconds."],
				min = 0,
				max = 3,
				step = 0.01,
			},
			alpha = {
				order = 3,
				type = "range",
				name = L["Alpha"],
				desc = L["The maximum alpha of the animation."],
				min = 0,
				max = 1,
				step = 0.01,
			},
			fadeEase = {
				order = 4,
				type = "select",
				name = L["Ease"],
				width = 1.3,
				desc = L["The easing function used for fading the backdrop."]
					.. "\n"
					.. L["You can preview the ease type in https://easings.net/"],
				values = W.AnimationEaseTable,
			},
			fadeEaseInvert = {
				order = 5,
				type = "toggle",
				name = L["Invert Ease"],
				desc = L["When enabled, this option inverts the easing function."]
					.. " "
					.. L["(e.g., 'in-quadratic' becomes 'out-quadratic' and vice versa)"]
					.. "\n"
					.. L["Generally, enabling this option makes the value increase faster in the first half of the animation."],
			},
		},
	}
end

options.libraries = {
	order = 9,
	type = "group",
	name = L["Libraries"],
	get = function(info)
		return E.private.WT.skins.libraries[info[#info]]
	end,
	set = function(info, value)
		E.private.WT.skins.libraries[info[#info]] = value
		E:StaticPopup_Show("PRIVATE_RL")
	end,
	disabled = function()
		return not E.private.WT.skins.enable
	end,
	args = {
		enableAll = {
			order = 1,
			type = "execute",
			name = L["Enable All"],
			func = function()
				for key in pairs(V.skins.libraries) do
					E.private.WT.skins.libraries[key] = true
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		disableAll = {
			order = 2,
			type = "execute",
			name = L["Disable All"],
			func = function()
				for key in pairs(V.skins.libraries) do
					E.private.WT.skins.libraries[key] = false
				end
				E:StaticPopup_Show("PRIVATE_RL")
			end,
		},
		betterOption = {
			order = 9,
			type = "description",
			name = " ",
			width = "full",
		},
		ace3 = {
			order = 10,
			type = "toggle",
			name = L["Ace3"],
		},
		ace3Dropdown = {
			order = 10,
			type = "toggle",
			name = L["Ace3 Dropdown"],
			disabled = function()
				return not E.private.WT.skins.libraries.ace3
			end,
		},
		elioteDropDownMenu = {
			order = 10,
			type = "toggle",
			name = L["ElioteDropDownMenu"],
		},
		libQTip = {
			order = 10,
			type = "toggle",
			name = L["LibQTip"],
		},
		secureTabs = {
			order = 10,
			type = "toggle",
			name = L["SecureTabs"],
		},
	},
}
