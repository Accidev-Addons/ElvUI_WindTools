local W ---@class WindTools
local F, E ---@type Functions, ElvUI
W, F, E = unpack((select(2, ...)))

local KI = W:NewModule("KeystoneInfo", "AceEvent-3.0") ---@class KeystoneInfo : AceModule, AceEvent-3.0

local select = select
local strsplit = strsplit
local tonumber = tonumber

local GetContainerItemID = GetContainerItemID
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots

local C_Item_IsItemKeystoneByID = C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel

local NUM_BAG_SLOTS = NUM_BAG_SLOTS

---@class KeystoneInfoData
---@field level number
---@field challengeMapID number
---@field rating number

---@class KeystoneInfo.PlayerKeystone
---@field level number?
---@field mapID number?
KI.PlayerKeystone = {}

function KI:GetPlayerKeystoneLink()
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, GetContainerNumSlots(bagIndex) do
			local itemID = GetContainerItemID(bagIndex, slotIndex)
			if itemID and C_Item_IsItemKeystoneByID(itemID) then
				return GetContainerItemLink(bagIndex, slotIndex)
			end
		end
	end
end

---@return number? mapID
---@return number? level
---@return string? link
function KI:GetPlayerKeystone()
	local link = self:GetPlayerKeystoneLink()
	if not link then
		return nil, nil, nil
	end

	local challengeMapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID and C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local level = C_MythicPlus_GetOwnedKeystoneLevel and C_MythicPlus_GetOwnedKeystoneLevel()

	if challengeMapID and level and challengeMapID > 0 and level > 0 then
		return challengeMapID, level, link
	end

	local challengeMapID, level = select(4, strsplit(":", link))
	if not challengeMapID or not level then
		return nil, nil, link
	end

	local mapID = tonumber(challengeMapID)
	local keystoneLevel = tonumber(level)

	if not mapID or not keystoneLevel then
		return nil, nil, link
	end

	return mapID, keystoneLevel, link
end

---@param skipEmit boolean? the flag to skip sending custom message to other modules
function KI:CheckPlayerKeystone(skipEmit)
	local mapID, level, link = self:GetPlayerKeystone()

	if self.PlayerKeystone.mapID ~= mapID or self.PlayerKeystone.level ~= level then
		if not skipEmit then
			self:SendMessage("WINDTOOLS_PLAYER_KEYSTONE_CHANGED", mapID, level, link)
		end
	end

	self.PlayerKeystone.mapID, self.PlayerKeystone.level = mapID, level
end

function KI:DelayedCheckPlayerKeystone()
	E:Delay(0.5, KI.CheckPlayerKeystone, KI)
end

---@param unit UnitToken
---@return KeystoneInfoData?
function KI:UnitData(unit) end

function KI:CHALLENGE_MODE_COMPLETED()
	self:CheckPlayerKeystone()
end

E:RegisterEventForObject("CHALLENGE_MODE_COMPLETED", KI, KI.CHALLENGE_MODE_COMPLETED)
KI:RegisterEvent("BAG_UPDATE", "DelayedCheckPlayerKeystone")
KI:RegisterEvent("ITEM_PUSH", "DelayedCheckPlayerKeystone")

F.TaskManager:AfterLogin(KI.CheckPlayerKeystone, KI, true)
