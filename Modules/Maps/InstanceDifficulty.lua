local W, F, E, L = unpack((select(2, ...)))
local ID = W:NewModule("InstanceDifficulty", "AceEvent-3.0", "AceHook-3.0")
local M = E:GetModule("Minimap")

local _G = _G
local gsub = gsub
local ipairs = ipairs

local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance

local C_ChallengeMode_GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo

local function GetDifficultyKey(instanceType, difficulty, maxPlayers, playerDifficulty, isDynamic, keystoneLevel)
	if instanceType == "pvp" or instanceType == "arena" then
		return "PvP"
	elseif instanceType == "party" then
		if keystoneLevel then
			return "Mythic Keystone"
		elseif difficulty == 3 then
			return "Mythic Party"
		elseif difficulty == 2 then
			return "5-player Heroic"
		end
		return "5-player Normal"
	elseif instanceType == "raid" then
		local isHeroic
		if isDynamic then
			isHeroic = playerDifficulty == 1
		else
			isHeroic = difficulty > 2
		end

		if maxPlayers == 40 then
			return "40-player"
		elseif maxPlayers == 10 then
			return isHeroic and "10-player Heroic" or "10-player Normal"
		elseif maxPlayers == 25 then
			return isHeroic and "25-player Heroic" or "25-player Normal"
		end
		return isHeroic and "Heroic Raid" or "Normal Raid"
	end
end

function ID:UpdateFrame()
	local inInstance, instanceType = IsInInstance()
	local _, _, difficulty, _, maxPlayers, playerDifficulty, isDynamic = GetInstanceInfo()
	local keystoneLevel = C_ChallengeMode_GetActiveKeystoneInfo()
	local key = GetDifficultyKey(instanceType, difficulty, maxPlayers, playerDifficulty, isDynamic, keystoneLevel)
	local text = key and self.db.difficulty.customStrings[key] or ""

	text = gsub(text, "%%mplus%%", keystoneLevel or "")
	text = gsub(text, "%%numPlayers%%", maxPlayers or 0)
	self.frame.text:SetText(text)
	self.frame:SetShown(inInstance)
end

function ID:ConstructFrame()
	if not self.db then
		return
	end

	local frame = CreateFrame("Frame", "WTInstanceDifficultyFrame", _G.Minimap)
	frame:Size(30, 20)
	frame:Point("TOPLEFT", M.MapHolder, "TOPLEFT", 10, -10)

	local text = frame:CreateFontString(nil, "OVERLAY")
	F.SetFontWithDB(text, self.db.font)
	text:Point(self.db.align or "LEFT")
	frame.text = text

	E:CreateMover(
		frame,
		"WTInstanceDifficultyFrameMover",
		L["Instance Difficulty"],
		nil,
		nil,
		nil,
		"ALL,WINDTOOLS",
		function()
			return E.private.WT.maps.instanceDifficulty.enable
		end,
		"WindTools,maps"
	)

	self.frame = frame
end

function ID:Initialize()
	self.db = E.private.WT.maps.instanceDifficulty

	if not self.db or not self.db.enable then
		return
	end

	self:ConstructFrame()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateFrame")
	self:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", "UpdateFrame")
	self:RegisterEvent("UPDATE_INSTANCE_INFO", "UpdateFrame")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateFrame")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateFrame")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "UpdateFrame")

	for _, event in ipairs({ "CHALLENGE_MODE_START", "CHALLENGE_MODE_COMPLETED", "CHALLENGE_MODE_RESET" }) do
		E:RegisterEventForObject(event, self, self.UpdateFrame)
	end

	if self.db.hideBlizzard then
		_G.MiniMapInstanceDifficulty:SetAlpha(0)
	end
end

W:RegisterModule(ID:GetName())
