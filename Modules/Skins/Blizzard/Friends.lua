local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local pairs = pairs

local function ReskinFriendButton(button)
	if not button.right then
		button.right = button:CreateTexture(nil, "BACKGROUND")
		button.right:SetTexture(E.media.blankTex)
		button.right:SetGradientAlpha("HORIZONTAL", 0.243, 0.57, 1, 0, 0.243, 0.57, 1, 0.25)
		button.right:SetPoint("TOPLEFT", button, "TOP", 0, 0)
		button.right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	end
	button.right:SetShown(button.gameIcon and button.gameIcon:IsShown())
end

function S:FriendsFrame()
	if not self:CheckDB("friends") then
		return
	end

	for _, frame in pairs({
		_G.FriendsFrame, _G.AddFriendFrame, _G.FriendsFriendsFrame,
	}) do
		self:CreateShadow(frame)
	end

	for i = 1, 4 do
		self:ReskinTab(_G["FriendsFrameTab" .. i])
	end

	-- [SIRUS] The native dynamic scroll frame updates rows through SetButton.
	self:SecureHook("FriendsFrame_SetButton", ReskinFriendButton)
	local scroll = _G.FriendsFrameFriendsScrollFrame
	if scroll and scroll.buttons then
		for _, button in pairs(scroll.buttons) do
			ReskinFriendButton(button)
		end
	end
end

S:AddCallback("FriendsFrame")
