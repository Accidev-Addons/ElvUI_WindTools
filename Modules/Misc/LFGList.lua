local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local KI = W:GetModule("KeystoneInfo")
local S = W.Modules.Skins ---@type Skins
local LL = W:NewModule("LFGList", "AceHook-3.0", "AceEvent-3.0") ---@class LFGList : AceModule, AceHook-3.0, AceEvent-3.0
local LFGPI = W.Utilities.LFGPlayerInfo
local C = W.Utilities.Color
local LSM = E.Libs.LSM

local _G = _G
local floor = floor
local format = format
local gsub = gsub
local ipairs = ipairs
local tinsert = tinsert
local tremove = tremove

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local IsInGroup = IsInGroup
local UnitClassBase = UnitClassBase
local UnitName = UnitName

local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local C_LFGList_GetActivityInfoTable = C_LFGList.GetActivityInfoTable
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_LFGList_GetSearchResultPlayerInfo = C_LFGList.GetSearchResultPlayerInfo

function LL:UpdateAdditionalText(button, score, best)
	local db = self.db.additionalText

	if not db.enable or not button.Name or not button.ActivityName then
		return
	end

	if not db.template or not score or not best then
		return
	end

	if db.shortenDescription then
		local descriptionText = button.ActivityName:GetText()
		descriptionText = gsub(descriptionText, "%([^%)]+%)", "")
		button.ActivityName:SetText(descriptionText)
	end

	local target = button[db.target == "TITLE" and "Name" or "ActivityName"]

	local text = target:GetText()

	local result = db.template

	result = gsub(result, "{{score}}", score)
	result = gsub(result, "{{best}}", best)
	result = gsub(result, "{{text}}", text)

	target:SetText(result)
end

---Reskins and customizes role icons in LFG (Looking for Group) lists with various visual enhancements.
---When role is nil, the icon and its elements are hidden by setting alpha to 0.
---@param parent Frame? The parent frame that contains the icon. Required for leader indicator and class line features.
---@param icon Texture The texture object representing the role icon to be reskinned.
---@param role "TANK" | "HEALER" | "DAMAGER" | nil The player's role. If nil, the icon will be hidden.
---@param data [ClassFile, string, boolean]? Optional cached data containing [class, specialization, isLeader] information.
function LL:ReskinIcon(parent, icon, role, data)
	local class, spec, isLeader
	if data then
		class, spec, isLeader = data[1], data[2], data[3]
	end

	if role then
		if self.db.icon.reskin then
			-- if not class and spec info, use square style instead
			local pack = self.db.icon.pack
			if pack == "SPEC" and (not class or not spec) then
				pack = "SQUARE"
			end

			if pack == "SQUARE" then
				icon:SetTexture(W.Media.Textures.ROLES)
				icon:SetTexCoord(F.GetRoleTexCoord(role))
			elseif pack == "SPEC" then
				local tex = LFGPI.GetIconTextureWithClassAndSpecName(class, spec)
				icon:SetTexture(tex)
				icon:SetTexCoords()
			else
				icon:SetTexture(W.Media.RoleIcons[pack][role])
				icon:SetTexCoord(0, 1, 0, 1)
			end
		end

		icon:Size(self.db.icon.size)

		if self.db.icon.border and not icon.backdrop then
			icon:CreateBackdrop("Transparent")
		end

		icon:SetAlpha(self.db.icon.alpha)
		if icon.backdrop then
			icon.backdrop:SetAlpha(self.db.icon.alpha)
		end
	else
		icon:SetAlpha(0)
		if icon.backdrop then
			icon.backdrop:SetAlpha(0)
		end
	end

	if parent then
		if self.db.icon.leader then
			if not icon.leader then
				local leader = parent:CreateTexture(nil, "OVERLAY")
				leader:SetTexture(W.Media.Icons.leader)
				leader:Size(10, 8)
				leader:Point("BOTTOM", icon, "TOP", 0, 1)
				icon.leader = leader
			end

			icon.leader:SetShown(isLeader)
		end

		-- Create bar in class color behind
		if class and self.db.line.enable then
			if not icon.line then
				local line = parent:CreateTexture(nil, "ARTWORK")
				line:SetTexture(LSM:Fetch("statusbar", self.db.line.tex) or E.media.normTex)
				line:Size(self.db.line.width, self.db.line.height)
				line:Point("TOP", icon, "BOTTOM", self.db.line.offsetX, self.db.line.offsetY)
				icon.line = line
			end

			local color = E:ClassColor(class, false)
			icon.line:SetVertexColor(color.r, color.g, color.b)
			icon.line:SetAlpha(self.db.line.alpha)
		elseif parent and icon.line then
			icon.line:SetAlpha(0)
		end
	end
end

function LL:UpdateEnumerate(Enumerate)
	local button = Enumerate:GetParent():GetParent()

	if not button.resultID then
		return
	end

	local result = C_LFGList_GetSearchResultInfo(button.resultID)
	if not result then
		return
	end

	local info = C_LFGList_GetActivityInfoTable(result.activityID)

	if self.db.icon.enable then
		---@type table<string, [ClassFile, string, boolean][]>
		local cache = { TANK = {}, HEALER = {}, DAMAGER = {} }

		for i = 1, result.numMembers do
			local playerInfo = C_LFGList_GetSearchResultPlayerInfo(button.resultID, i)
			if playerInfo then
				local role, class, spec, isLeader =
					playerInfo.assignedRole, playerInfo.classFilename, playerInfo.specName, playerInfo.isLeader
				tinsert(cache[role], { class, spec, isLeader })
			end
		end

		for i = 5, 1, -1 do -- The index of icon starts from right
			local icon = Enumerate["Icon" .. i]
			local roleIcon = icon.RoleIcon
			local classCircle = icon.ClassCircle

			if roleIcon and roleIcon.SetTexture then
				if #cache.TANK > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "TANK", cache.TANK[1])
					tremove(cache.TANK, 1)
				elseif #cache.HEALER > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "HEALER", cache.HEALER[1])
					tremove(cache.HEALER, 1)
				elseif #cache.DAMAGER > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "DAMAGER", cache.DAMAGER[1])
					tremove(cache.DAMAGER, 1)
				else
					self:ReskinIcon(Enumerate, roleIcon)
				end
			end

			if classCircle and self.db.icon.hideDefaultClassCircle then
				classCircle:Hide()
			end
		end
	end

	if self.db.additionalText.enable and result and info and info.isMythicPlusActivity then
		local scoreText, bestText

		local score = result.leaderOverallDungeonScore or 0
		local color = score and C_ChallengeMode_GetDungeonScoreRarityColor(score) or { r = 1.0, g = 1.0, b = 1.0 }
		scoreText = C.StringWithRGB(score, color)

		local bestRun = result.leaderBestDungeonScoreInfo and result.leaderBestDungeonScoreInfo.bestRunLevel
		if bestRun then
			local template = result.leaderBestDungeonScoreInfo.finishedSuccess and "green-400" or "gray-400"
			bestText = C.StringByTemplate("+" .. bestRun, template)
		end

		self:UpdateAdditionalText(button, scoreText, bestText)
	end
end

function LL:UpdateRoleCount(RoleCount)
	if not self.db.icon.enable then
		return
	end

	if RoleCount.TankIcon then
		self:ReskinIcon(nil, RoleCount.TankIcon, "TANK")
	end
	if RoleCount.HealerIcon then
		self:ReskinIcon(nil, RoleCount.HealerIcon, "HEALER")
	end
	if RoleCount.DamagerIcon then
		self:ReskinIcon(nil, RoleCount.DamagerIcon, "DAMAGER")
	end
end

-- Used for Details! command check
local FakeChatEditBox = {}
function FakeChatEditBox:GetText()
	return "/keystone"
end

function LL:InitializePartyKeystoneFrame()
	local frame = CreateFrame("Frame", "WTPartyKeystoneFrame", _G.ChallengesFrame)
	frame:Size(190, 150)
	frame:SetTemplate("Transparent")
	frame:Point("BOTTOMRIGHT", _G.ChallengesFrame, "BOTTOMRIGHT", -8, 85)

	frame.lines = {}

	frame.Title = frame:CreateFontString(nil, "OVERLAY")
	F.SetFontWithDB(frame.Title, self.db.partyKeystone.font)
	frame.Title:Point("TOPLEFT", frame, "TOPLEFT", 8, -10)
	frame.Title:SetJustifyH("LEFT")
	frame.Title:SetText(F.GetWindStyleText(L["Party Keystone"]))

	frame.MoreButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.MoreButton:Size(40, self.db.partyKeystone.font.size + 4)
	F.SetFontWithDB(frame.MoreButton.Text, self.db.partyKeystone.font)
	F.SetFont(frame.MoreButton.Text, nil, "-2")
	frame.MoreButton:SetText(L["More"])
	frame.MoreButton:Point("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
	S:Proxy("HandleButton", frame.MoreButton)

	frame.MoreButton:SetScript("OnClick", function()
		if _G.SlashCmdList["bwkey"] then
			_G.SlashCmdList["bwkey"]()
		elseif _G.SlashCmdList["KEYSTONE"] then
			_G.SlashCmdList["KEYSTONE"]("", FakeChatEditBox)
		else
			F.Print(L["You need to install Bigwigs or Details! first."])
		end
	end)

	frame.MoreButton:SetScript("OnEnter", function(s)
		_G.GameTooltip:SetOwner(s, "ANCHOR_TOP", 0, 3)
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine(L["Click to open Bigwigs or Details! keystone info window."])
		_G.GameTooltip:Show()
	end)

	frame.MoreButton:SetScript("OnLeave", function()
		_G.GameTooltip:Hide()
	end)

	frame.SendToPartyChatButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.SendToPartyChatButton:Size(40, self.db.partyKeystone.font.size + 4)
	F.SetFontWithDB(frame.SendToPartyChatButton.Text, self.db.partyKeystone.font)
	F.SetFont(frame.SendToPartyChatButton.Text, nil, "-2")
	frame.SendToPartyChatButton:SetText(L["Send"])
	frame.SendToPartyChatButton:Point("RIGHT", frame.MoreButton, "LEFT", -5, 0)
	S:Proxy("HandleButton", frame.SendToPartyChatButton)

	frame.SendToPartyChatButton:SetScript("OnClick", function()
		if not IsInGroup() then
			F.Print(L["You are not in a party."])
			return
		end

		if not frame.partyMessages or #frame.partyMessages == 0 then
			return
		end

		for i, msg in ipairs(frame.partyMessages) do
			E:Delay((i - 1) * 0.5, function()
				_G.SendChatMessage(msg, "PARTY")
			end)
		end
	end)

	frame.SendToPartyChatButton:SetScript("OnEnter", function(s)
		_G.GameTooltip:SetOwner(s, "ANCHOR_TOP", 0, 3)
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine(L["Click to send keystone info to party chat."])
		_G.GameTooltip:Show()
	end)

	frame.SendToPartyChatButton:SetScript("OnLeave", function()
		_G.GameTooltip:Hide()
	end)

	for i = 1, 5 do
		local yOffset = (2 + self.db.partyKeystone.font.size) * (i - 1) + 5

		local rightText = frame:CreateFontString(nil, "OVERLAY")
		F.SetFontWithDB(rightText, self.db.partyKeystone.font)
		rightText:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, yOffset)
		rightText:SetJustifyH("RIGHT")
		rightText:Width(90)

		local leftText = frame:CreateFontString(nil, "OVERLAY")
		F.SetFontWithDB(leftText, self.db.partyKeystone.font)
		leftText:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -100, yOffset)
		leftText:SetJustifyH("LEFT")
		leftText:Width(90)

		frame.lines[i] = { left = leftText, right = rightText }
	end

	self.PartyKeystoneFrame = frame
end

function LL:UpdatePartyKeystoneFrame()
	if not self.db or not self.db.partyKeystone or not self.db.partyKeystone.enable then
		if self.PartyKeystoneFrame then
			self.PartyKeystoneFrame:Hide()
		end
		return
	end

	if not self.PartyKeystoneFrame then
		self:InitializePartyKeystoneFrame()
	end

	local frame = self.PartyKeystoneFrame

	local scale = self.db.partyKeystone.font.size / 12
	local heightIncrement = floor(8 * scale)
	local blockWidth = floor(95 * scale)
	local cache = {}

	frame.partyMessages = {}

	local mythicPlusMapData = W:GetMythicPlusMapData()
	for i = 1, 5 do
		local unit = i == 1 and "player" or "party" .. i - 1
		local data = KI:UnitData(unit)
		local mapData = data and data.challengeMapID and mythicPlusMapData[data.challengeMapID]
		if mapData then
			local unitName = UnitName(unit)
			local classFile = UnitClassBase(unit)
			local playerName = unitName or ""
			if classFile and playerName ~= "" then
				playerName = C.StringWithClassColor(playerName, classFile)
			end
			tinsert(cache, {
				level = data.level,
				name = mapData.abbr,
				player = playerName,
				icon = mapData.tex,
			})

			tinsert(frame.partyMessages, format("%s: %s (+%d)", playerName ~= "" and unitName or "?", mapData.name, data.level))
		end
	end

	F.SetFontWithDB(frame.Title, self.db.partyKeystone.font)

	frame.MoreButton:Size(floor(40 * scale), self.db.partyKeystone.font.size + 4)
	F.SetFontWithDB(frame.MoreButton.Text, self.db.partyKeystone.font)
	F.SetFont(frame.MoreButton.Text, nil, "-2")

	frame.SendToPartyChatButton:SetEnabled(#frame.partyMessages ~= 0)
	frame.SendToPartyChatButton:Size(floor(40 * scale), self.db.partyKeystone.font.size + 4)
	F.SetFontWithDB(frame.SendToPartyChatButton.Text, self.db.partyKeystone.font)
	F.SetFont(frame.SendToPartyChatButton.Text, nil, "-2")

	for i = 1, 5 do
		local yOffset = (heightIncrement + self.db.partyKeystone.font.size) * (i - 1) + 10

		F.SetFontWithDB(frame.lines[i].right, self.db.partyKeystone.font)
		frame.lines[i].right:ClearAllPoints()
		frame.lines[i].right:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, yOffset)
		frame.lines[i].right:SetJustifyH("RIGHT")
		frame.lines[i].right:Width(blockWidth)

		F.SetFontWithDB(frame.lines[i].left, self.db.partyKeystone.font)
		frame.lines[i].left:ClearAllPoints()
		frame.lines[i].left:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -blockWidth - 9, yOffset)
		frame.lines[i].left:Width(blockWidth)

		if cache[i] then
			frame.lines[i].right:SetText(cache[i].player)
			frame.lines[i].left:SetFormattedText(
				"%s %s",
				F.GetIconString(cache[i].icon, 16, 18, true),
				C.StringWithKeystoneLevel(format("%s (%s)", cache[i].name, cache[i].level), cache[i].level)
			)
		else
			frame.lines[i].right:SetText("")
			frame.lines[i].left:SetText("")
		end
	end

	frame:Size(
		blockWidth * 2 + 20,
		20 + (heightIncrement + self.db.partyKeystone.font.size) * #cache + self.db.partyKeystone.font.size
	)
	frame:Show()
end

function LL:RequestKeystoneData()
	E:Delay(0.5, self.UpdatePartyKeystoneFrame, self)
	E:Delay(2, self.UpdatePartyKeystoneFrame, self)
end

function LL:Initialize()
	if IsAddOnLoaded("PremadeGroupsFilter") then
		self.StopRunning = L["Premade Groups Filter"]
		return
	end

	self.db = E.private.WT.misc.lfgList
	if not self.db.enable then
		return
	end

	self:SecureHook("LFGListGroupDataDisplayEnumerate_Update", "UpdateEnumerate")
	self:SecureHook("LFGListGroupDataDisplayRoleCount_Update", "UpdateRoleCount")

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "RequestKeystoneData")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "RequestKeystoneData")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RequestKeystoneData")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "RequestKeystoneData")

	E:Delay(2, self.RequestKeystoneData, self)
	E:Delay(2, self.UpdatePartyKeystoneFrame, self)
end

W:RegisterModule(LL:GetName())
