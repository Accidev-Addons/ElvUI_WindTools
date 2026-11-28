local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins
local ES = E.Skins

local _G = _G
local pairs = pairs

function S:BlizzardMiscFrames()
	if not self:CheckDB("misc") then
		return
	end

	for _, frame in pairs({
		_G.AutoCompleteBox, _G.GhostFrame, _G.StackSplitFrame,
		_G.ChatConfigFrame, _G.ColorPickerFrame, _G.OpacityFrame,
		_G.MovieFrame and _G.MovieFrame.CloseDialog,
	}) do
		self:CreateShadow(frame)
	end

	F.SetFontWithDB(_G.ActionStatusText, self.db.actionStatus)

	for _, frame in pairs({ _G.ChatMenu, _G.EmoteMenu, _G.LanguageMenu, _G.VoiceMacroMenu }) do
		self:CreateShadow(frame)
		self:SecureHookScript(frame, "OnShow", "CreateShadow")
	end

	self:SecureHook(ES, "DropDownMenu_SkinMenu", function(_, prefix, name)
		local backdrop = prefix and _G[name]
		if backdrop and backdrop.template then
			self:CreateShadow(backdrop)
		end
	end)

	self:SecureHook(ES, "HandleIconSelectionFrame", function(_, frame)
		self:CreateShadow(frame)
	end)
end

S:AddCallback("BlizzardMiscFrames")

local panelShadows = {
	ArenaFrame = { "arena" },
	ArenaRegistrarFrame = { "arenaregistrar" },
	BattlePassFrame = { "battlePass" },
	BattlefieldFrame = { "pvp" },
	ChallengesFrame = { "lfd", "challenges" },
	ChallengesInspectFrame = { "lfd", "challenges" },
	ChooseItemFrame = { "chooseitem" },
	Custom_RouletteFrame = { "roulette" },
	DeathRecapFrame = { "deathRecap" },
	DeclensionFrame = { "misc" },
	DummyControlFrame = { "dummycontrol" },
	GuildControlPopupFrame = { "guild", "guild" },
	GuildFrame = { "guild", "guild" },
	GuildRegistrarFrame = { "guildregistrar", "guild" },
	HardcoreFrame = { "hardcore" },
	HeadHuntingFrame = { "headhunting" },
	HeadHuntingSetRewardExternalFrame = { "headhunting" },
	InspectRecipeFrame = { "tradeskill" },
	ItemBrowser = { "itembrowser" },
	LFRParentFrame = { "lfr", "lookingForGroup" },
	LadderFrame = { "lfd", "lookingForGroup" },
	LookingForGuildFrame = { "guild", "guild" },
	LootCasePreviewFrame = { "lootCasePreview" },
	PVPBannerFrame = { "arenaregistrar" },
	PVPParentFrame = { "pvp" },
	PVPUIFrame = { "lfd", "lookingForGroup" },
	PetitionFrame = { "petition", "guild" },
	PlayerTalentFrame = { "talent" },
	PromoCodeFrame = { "store" },
	QuestLogDetailFrame = { "quest", "quest" },
	SpellBookFrame = { "spellbook" },
	StoreFrame = { "store" },
	TabardFrame = { "tabard", "guild" },
	TradeSkillFrame = { "tradeskill" },
	WorldStateScoreFrame = { "bgscore" },
}

local function CreatePanelShadow(frame)
	if frame.backdrop then
		S:CreateBackdropShadow(frame, true)
	elseif frame.template and frame.template ~= "NoBackdrop" then
		S:CreateShadow(frame)
	end

	for i = 1, frame.numTabs or 0 do
		S:ReskinTab(_G[frame:GetName() .. "Tab" .. i])
	end
end

function S:BlizzardPanelShadows()
	for name, keys in pairs(panelShadows) do
		local frame = _G[name]
		if frame and self:CheckDB(keys[1], keys[2] or "misc") then
			CreatePanelShadow(frame)
			self:SecureHookScript(frame, "OnShow", CreatePanelShadow)
		end
	end
end

S:AddCallback("BlizzardPanelShadows")
