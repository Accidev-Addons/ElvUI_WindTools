local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local FL = W:NewModule("FriendList", "AceHook-3.0")
local C = W.Utilities.Color

local _G = _G
local pairs = pairs
local strsplit = strsplit

local FriendsFrame_Update = FriendsFrame_Update
local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor

local CHAT_FLAG_AFK = CHAT_FLAG_AFK
local CHAT_FLAG_DND = CHAT_FLAG_DND
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW
local FRIENDS_TEXTURE_AFK = FRIENDS_TEXTURE_AFK
local FRIENDS_TEXTURE_DND = FRIENDS_TEXTURE_DND
local FRIENDS_TEXTURE_OFFLINE = FRIENDS_TEXTURE_OFFLINE
local FRIENDS_TEXTURE_ONLINE = FRIENDS_TEXTURE_ONLINE
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE

local MediaPath = "Interface\\Addons\\ElvUI_WindTools\\Media\\FriendList\\"

local cache = {}

local statusIcons = {
	default = {
		Online = FRIENDS_TEXTURE_ONLINE,
		Offline = FRIENDS_TEXTURE_OFFLINE,
		DND = FRIENDS_TEXTURE_DND,
		AFK = FRIENDS_TEXTURE_AFK,
	},
	square = {
		Online = MediaPath .. "StatusIcons\\Square\\Online",
		Offline = MediaPath .. "StatusIcons\\Square\\Offline",
		DND = MediaPath .. "StatusIcons\\Square\\DND",
		AFK = MediaPath .. "StatusIcons\\Square\\AFK",
	},
	d3 = {
		Online = MediaPath .. "StatusIcons\\D3\\Online",
		Offline = MediaPath .. "StatusIcons\\D3\\Offline",
		DND = MediaPath .. "StatusIcons\\D3\\DND",
		AFK = MediaPath .. "StatusIcons\\D3\\AFK",
	},
}

local function GetClassColor(className)
	for class, localizedName in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if className == localizedName then
			return E:ClassColor(class)
		end
	end

	for class, localizedName in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		if className == localizedName then
			return E:ClassColor(class)
		end
	end
end

function FL:UpdateFriendButton(button)
	if not self.db.enable then
		if cache.name and cache.info then
			F.SetFontWithDB(button.name, cache.name)
			F.SetFontWithDB(button.info, cache.info)
		end
		return
	end

	if button.buttonType ~= FRIENDS_BUTTON_TYPE_WOW then
		return
	end

	local fullName, level, class, area, connected, status, note = GetFriendInfo(button.id)
	if not fullName then
		return
	end

	local name, server = strsplit("-", fullName)

	local statusKey = "Offline"
	if connected then
		if status == CHAT_FLAG_AFK then
			statusKey = "AFK"
		elseif status == CHAT_FLAG_DND then
			statusKey = "DND"
		else
			statusKey = "Online"
		end
	end

	local pack = statusIcons[self.db.textures.status]
	if pack then
		button.status:SetTexture(pack[statusKey])
	end

	if self.db.useNoteAsName and note and note ~= "" then
		name = note
	end

	local classColor = self.db.useClassColor and GetClassColor(class)
	local nameString = classColor and C.StringWithRGB(name, classColor) or name

	if self.db.level and level and level ~= 0 then
		if level ~= W.MaxLevelForPlayerExpansion or not self.db.hideMaxLevel then
			nameString = nameString .. C.StringWithRGB(": " .. level, GetQuestDifficultyColor(level))
		end
	end

	button.name:SetText(nameString)

	if area then
		if self.db.hideRealm then
			server = nil
		end

		local infoText
		if area ~= "" and server and server ~= "" and server ~= E.myrealm then
			infoText = C.StringWithRGB(area .. " - " .. server, self.db.areaColor)
		elseif area ~= "" then
			infoText = C.StringWithRGB(area, self.db.areaColor)
		else
			infoText = server or ""
		end

		button.info:SetText(infoText)
	end

	if not cache.name then
		local fontName, size, style = button.name:GetFont()
		cache.name = {
			name = fontName,
			size = size,
			style = style,
		}
	end

	if not cache.info then
		local fontName, size, style = button.info:GetFont()
		cache.info = {
			name = fontName,
			size = size,
			style = style,
		}
	end

	F.SetFont(button.name)
	F.SetFontWithDB(button.name, self.db.nameFont)

	F.SetFont(button.info)
	F.SetFontWithDB(button.info, self.db.infoFont)
end

function FL:Initialize()
	if not E.db.WT.social.friendList.enable then
		return
	end

	self.db = E.db.WT.social.friendList

	self:SecureHook(_G.FriendsFrameFriendsScrollFrame, "buttonFunc", "UpdateFriendButton")

	self.initialized = true
end

function FL:ProfileUpdate()
	self.db = E.db.WT.social.friendList

	if self.db and self.db.enable and not self.initialized then
		self:Initialize()
	end

	FriendsFrame_Update()
end

W:RegisterModule(FL:GetName())
