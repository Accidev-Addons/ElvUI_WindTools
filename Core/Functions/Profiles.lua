local F ---@class Functions
local W, F, E, L, V, P, G ---@type WindTools, Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
W, F, E, L, V, P, G = unpack((select(2, ...)))

local gsub = gsub
local next = next
local strmatch = strmatch
local type = type

local LibDeflate = E.Libs.Deflate
local Serializer = E.Distributor

---@cast F Functions

F.Profiles = {}

---@type table Generated keys configuration for profile data
local generatedKeys = {
	profile = {
		announcement = { utility = { custom = true } },
		item = { extraItemsBar = { customList = true, blackList = true } },
		misc = {
			keybindAlias = { list = true },
			gameBar = { hearthstone = { custom = true, randomPool = true } },
		},
		social = {
			chatText = { customAbbreviation = true },
			chatBar = { channels = { world = { config = true } } },
		},
		quest = { turnIn = { customIgnoreNPCs = true } },
	},
	private = {
		combat = { destroyTotem = { keys = true } },
		misc = {
			moveFrames = { framePositions = true },
			lfgList = { filter = { hidden = true } },
		},
	},
	global = {
		item = { contacts = { alts = true, favorites = true } },
	},
}

for scope, keys in next, generatedKeys do
	Serializer.GeneratedKeys[scope].WT = keys
end

local defaultFont, defaultStatusBar = E.db.general.font, E.db.unitframe.statusbar

local function KeepElvUIDefaults(data, current, defaults)
	for key, value in next, defaults do
		local currentValue = current[key]
		if type(value) == "table" then
			if type(currentValue) == "table" then
				local sub = KeepElvUIDefaults(data[key] or {}, currentValue, value)
				if next(sub) ~= nil then
					data[key] = sub
				end
			end
		elseif
			currentValue ~= nil
			and (value == defaultFont or value == defaultStatusBar or (key == "size" and defaults.name == defaultFont))
		then
			data[key] = currentValue
		end
	end

	return data
end

---@class Functions
---Generate compressed and encoded string from data
---@param data table The data to serialize and compress
---@return string? encodedString The compressed and encoded string
function F.Profiles.GenerateString(data)
	local serializedData = Serializer:Serialize(data)
	if not serializedData then
		F.Print("Error serializing data.")
		return
	end

	local compressedData = LibDeflate:CompressDeflate(serializedData, Serializer.CompressLevel)
	if not compressedData then
		F.Print("Error compressing data.")
		return
	end

	local encodedData = LibDeflate:EncodeForPrint(compressedData)
	if not encodedData then
		F.Print("Error encoding data.")
		return
	end

	return encodedData
end

---@class Functions
---Extract and deserialize data from encoded string
---@param dataString string The encoded data string
---@return table? data The deserialized data or nil if failed
function F.Profiles.ExactString(dataString)
	local decodedData = LibDeflate:DecodeForPrint(dataString)
	if not decodedData then
		F.Print("Error decoding data.")
		return
	end

	local decompressed = LibDeflate:DecompressDeflate(decodedData)
	if not decompressed then
		F.Print("Error decompressing data.")
		return
	end

	local success, data = Serializer:Deserialize(decompressed)
	if not success or type(data) ~= "table" then
		F.Print("Error deserializing data.")
		return
	end

	return data
end

---@class Functions
---Get output string for profile and private data export
---@param profile boolean Include profile data in export
---@param private boolean Include private data in export
---@return string outputString The combined export string
function F.Profiles.GetOutputString(profile, private)
	local profileData = {}
	if profile then
		profileData = E:CopyTable(profileData, E.db.WT)
		profileData = E:RemoveTableDuplicates(profileData, P, generatedKeys.profile)
		KeepElvUIDefaults(profileData, E.db.WT, P)
	end

	local privateData = {}
	if private then
		privateData = E:CopyTable(privateData, E.private.WT)
		privateData = E:RemoveTableDuplicates(privateData, V, generatedKeys.private)
		KeepElvUIDefaults(privateData, E.private.WT, V)
	end

	local profileString = F.Profiles.GenerateString(profileData)
	local privateString = F.Profiles.GenerateString(privateData)
	if not profileString or not privateString then
		F.Print("Error exporting profile.")
		return ""
	end

	return profileString .. "{}" .. privateString
end

---@class Functions
---Import profile and private data from string
---@param importString string The import string containing profile and private data
function F.Profiles.ImportByString(importString)
	local profileString, privateString = strmatch(gsub(importString, "%s", ""), "^(.-){}(.+)$")
	if not profileString or not privateString then
		F.Print("Error importing profile. String is invalid or corrupted!")
		return
	end

	local profileData = F.Profiles.ExactString(profileString)
	local privateData = F.Profiles.ExactString(privateString)
	if not profileData or not privateData then
		return
	end

	if type(next(profileData)) ~= "nil" then
		E.db.WT = E:CopyTable(E:CopyTable({}, P), profileData)
	end

	if type(next(privateData)) ~= "nil" then
		E.private.WT = E:CopyTable(E:CopyTable({}, V), privateData)
	end

	return true
end
