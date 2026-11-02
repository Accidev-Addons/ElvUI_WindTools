local W, F, E, L, V, P, G = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
local C = W.Utilities.Color

local options = W.options.information.args

local format = format
local gsub = gsub
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber
local tostring = tostring

options.help = {
	order = 1,
	type = "group",
	name = L["Help"],
	args = {
		about = {
			order = 1,
			type = "group",
			inline = true,
			name = W.Title,
			args = {
				team = {
					order = 1,
					type = "description",
					fontSize = "medium",
					name = format("%s: %s", L["Team"], "Accidev"),
				},
				discord = {
					order = 2,
					type = "execute",
					name = "Discord",
					image = W.Media.Icons.discord,
					func = function()
						E:StaticPopup_Show("WINDTOOLS_EDITBOX", nil, nil, "https://discord.gg/CXtYebMBb")
					end,
					width = 0.7,
				},
				debug = {
					order = 3,
					type = "description",
					fontSize = "medium",
					name = format(
						C.StringByTemplate(
							L["Before you submit a bug, please enable debug mode with %s and test it one more time."],
							"rose-500"
						),
						C.StringByTemplate("/wtdebug on", "teal-500")
					),
				},
			},
		},
		version = {
			order = 2,
			name = L["Version"],
			type = "group",
			inline = true,
			args = {
				elvui = {
					order = 1,
					type = "description",
					name = "ElvUI: " .. C.StringByTemplate(E.versionString, "blue-500"),
				},
				windtools = {
					order = 2,
					type = "description",
					name = W.Title .. ": " .. C.StringByTemplate(W.DisplayVersion, "blue-500"),
				},
				build = {
					order = 3,
					type = "description",
					name = L["WoW Build"]
						.. ": "
						.. C.StringByTemplate(format("%s (%s)", E.wowpatch, E.wowbuild), "blue-500"),
				},
			},
		},
	},
}

options.changelog = {
	order = 3,
	type = "group",
	childGroups = "select",
	name = L["Changelog"],
	args = {},
}

local function renderChangeLogLine(line)
	line = gsub(line, "%[[^%[]+%]", function(text)
		return C.StringByTemplate(text, "blue-500")
	end)
	return line
end

for version, data in pairs(W.Changelog) do
	local versionString = format("%d.%02d", version / 100, mod(version, 100))
	local changelogVer = tonumber(versionString)
	local addonVer = tonumber(W.Version)
	local dateTable = { strsplit("/", data.RELEASE_DATE) }
	local dateString = data.RELEASE_DATE
	if #dateTable == 3 then
		dateString = L["%month%-%day%-%year%"]
		dateString = gsub(dateString, "%%year%%", dateTable[1])
		dateString = gsub(dateString, "%%month%%", dateTable[2])
		dateString = gsub(dateString, "%%day%%", dateTable[3])
	end

	options.changelog.args[tostring(version)] = {
		order = 1000 - version,
		name = versionString,
		type = "group",
		args = {},
	}

	local page = options.changelog.args[tostring(version)].args

	page.date = {
		order = 1,
		type = "description",
		name = "|cffbbbbbb" .. dateString .. " " .. L["Released"] .. "|r",
		fontSize = "small",
	}

	page.version = {
		order = 2,
		type = "description",
		name = L["Version"] .. " " .. C.StringByTemplate(versionString, "blue-500"),
		fontSize = "large",
	}

	local importantPart = data.IMPORTANT and (data.IMPORTANT[E.global.general.locale] or data.IMPORTANT["enUS"])
	if importantPart and #importantPart > 0 then
		page.importantHeader = {
			order = 3,
			type = "header",
			name = C.StringByTemplate(L["Important"], "blue-500"),
		}
		page.important = {
			order = 4,
			type = "description",
			name = function()
				local text = ""
				for index, line in ipairs(importantPart) do
					text = text .. format("%02d", index) .. ". " .. renderChangeLogLine(line) .. "\n"
				end
				return text .. "\n"
			end,
			fontSize = "medium",
		}
	end

	local newPart = data.NEW and (data.NEW[E.global.general.locale] or data.NEW["enUS"])
	if newPart and #newPart > 0 then
		page.newHeader = {
			order = 5,
			type = "header",
			name = C.StringByTemplate(L["New"], "blue-500"),
		}
		page.new = {
			order = 6,
			type = "description",
			name = function()
				local text = ""
				for index, line in ipairs(newPart) do
					text = text .. format("%02d", index) .. ". " .. renderChangeLogLine(line) .. "\n"
				end
				return text .. "\n"
			end,
			fontSize = "medium",
		}
	end

	local improvementPart = data.IMPROVEMENT and (data.IMPROVEMENT[E.global.general.locale] or data.IMPROVEMENT["enUS"])
	if improvementPart and #improvementPart > 0 then
		page.improvementHeader = {
			order = 7,
			type = "header",
			name = C.StringByTemplate(L["Improvement"], "blue-500"),
		}
		page.improvement = {
			order = 8,
			type = "description",
			name = function()
				local text = ""
				for index, line in ipairs(improvementPart) do
					text = text .. format("%02d", index) .. ". " .. renderChangeLogLine(line) .. "\n"
				end
				return text .. "\n"
			end,
			fontSize = "medium",
		}
	end

	page.beforeConfirm1 = {
		order = 9,
		type = "description",
		name = " ",
		width = "full",
		hidden = function()
			local dbVer = E.global.WT and E.global.WT.changelogRead and tonumber(E.global.WT.changelogRead)
			return dbVer and dbVer >= changelogVer or addonVer < changelogVer
		end,
	}

	page.beforeConfirm2 = {
		order = 10,
		type = "description",
		name = " ",
		width = "full",
		hidden = function()
			local dbVer = E.global.WT and E.global.WT.changelogRead and tonumber(E.global.WT.changelogRead)
			return dbVer and dbVer >= changelogVer or addonVer < changelogVer
		end,
	}

	page.confirm = {
		order = 11,
		type = "execute",
		name = C.StringByTemplate(L["I got it!"], "teal-400"),
		desc = L["Mark as read, the changelog message will be hidden when you login next time."],
		width = "full",
		hidden = function()
			local dbVer = E.global.WT and E.global.WT.changelogRead and tonumber(E.global.WT.changelogRead)
			return dbVer and dbVer >= changelogVer or addonVer < changelogVer
		end,
		func = function()
			E.global.WT.changelogRead = versionString
		end,
	}
end
