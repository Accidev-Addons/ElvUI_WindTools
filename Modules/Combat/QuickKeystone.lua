local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local QK = W:NewModule("QuickKeystone", "AceHook-3.0")

local _G = _G

local ClearCursor = ClearCursor
local CursorHasItem = CursorHasItem
local GetContainerItemID = GetContainerItemID
local GetContainerNumSlots = GetContainerNumSlots
local PickupContainerItem = PickupContainerItem

local C_ChallengeMode_SlotKeystone = C_ChallengeMode.SlotKeystone
local C_MythicPlus_GetOwnerKeystoneInfo = C_MythicPlus.GetOwnerKeystoneInfo

local NUM_BAG_SLOTS = NUM_BAG_SLOTS

function QK:PutKeystone()
	if CursorHasItem() then
		return
	end

	local keystoneItemID = C_MythicPlus_GetOwnerKeystoneInfo()
	if not keystoneItemID then
		return
	end

	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, GetContainerNumSlots(bagIndex) do
			if GetContainerItemID(bagIndex, slotIndex) == keystoneItemID then
				PickupContainerItem(bagIndex, slotIndex)
				C_ChallengeMode_SlotKeystone()
				if CursorHasItem() then
					ClearCursor()
				end
				return
			end
		end
	end
end

function QK:ProfileUpdate()
	self.db = E.db.WT.combat.quickKeystone

	local frame = _G.ChallengesKeystoneFrame
	if not frame then
		return
	end

	if self.db.enable then
		if not self:IsHooked(frame, "OnShow") then
			self:SecureHookScript(frame, "OnShow", "PutKeystone")
		end
	elseif self:IsHooked(frame, "OnShow") then
		self:Unhook(frame, "OnShow")
	end
end

QK.Initialize = QK.ProfileUpdate

W:RegisterModule(QK:GetName())
