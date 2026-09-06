local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local pairs = pairs

local function SkinQuestRewards()
	-- [SIRUS] Fixed named reward buttons replace retail reward pools.
	for i = 1, _G.MAX_NUM_ITEMS do
		local button = _G["QuestInfoItem" .. i]
		if button and not button.__windSkin then
			S:CreateShadow(button)
			S:BindShadowColorWithBorder(button)
			local icon = button.Icon or _G["QuestInfoItem" .. i .. "IconTexture"]
			S:CreateBackdropShadow(icon)
			F.SetFont(_G["QuestInfoItem" .. i .. "Name"])
			button.__windSkin = true
		end
	end
end

local function SkinQuestText()
	for _, text in pairs({
		_G.QuestInfoTitleHeader, _G.QuestInfoDescriptionHeader, _G.QuestInfoObjectivesHeader,
		_G.QuestInfoRewardsHeader, _G.QuestInfoDescriptionText, _G.QuestInfoObjectivesText,
		_G.QuestInfoGroupSize, _G.QuestInfoRewardText, _G.QuestInfoItemChooseText,
		_G.QuestInfoItemReceiveText, _G.QuestInfoSpellLearnText,
	}) do
		F.SetFont(text)
	end
	for i = 1, _G.MAX_OBJECTIVES do
		F.SetFont(_G["QuestInfoObjective" .. i])
	end
end

function S:BlizzardQuestFrames()
	if not self:CheckDB("quest") then
		return
	end

	self:CreateShadow(_G.QuestFrame)
	self:CreateShadow(_G.QuestLogFrame)
	SkinQuestRewards()
	SkinQuestText()

	-- ElvUI owns reward layout and objective/quality colors; retain those updates.
	self:SecureHook("QuestInfo_ShowRewards", SkinQuestRewards)
	self:SecureHook("QuestInfo_Display", SkinQuestText)
end

S:AddCallback("BlizzardQuestFrames")
