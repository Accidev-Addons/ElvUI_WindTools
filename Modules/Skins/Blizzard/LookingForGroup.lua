local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local pairs = pairs

function S:LookingForGroupFrames()
	if not self:CheckDB("lfd", "lookingForGroup") then
		return
	end

	local frames = {
		_G.LFDParentFrame,
		_G.LFDDungeonReadyDialog,
		_G.LFDDungeonReadyStatus,
		_G.LFDRoleCheckPopup,
		_G.ReadyCheckFrame,
		_G.QueueStatusFrame,
		_G.LFGListInviteDialog,
		_G.LFGListApplicationDialog,
	}

	for _, frame in pairs(frames) do
		self:CreateShadow(frame)
	end

	for i = 1, 4 do
		self:ReskinTab(_G["LFDParentFrameTab" .. i])
	end

	if _G.LFDQueueFrameRandomScrollFrameChildFrame then
		local frame = _G.LFDQueueFrameRandomScrollFrameChildFrame
		F.SetFont(frame.title, E.db.general.font)
		F.SetFont(frame.description, E.db.general.font)
		F.SetFont(frame.rewardsLabel, E.db.general.font)
		F.SetFont(frame.rewardsDescription, E.db.general.font)
	end
end

S:AddCallback("LookingForGroupFrames")
