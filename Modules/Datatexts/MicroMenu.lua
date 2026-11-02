local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local DT = E:GetModule("DataTexts")

local _G = _G

local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local ToggleFrame = ToggleFrame

local MenuUtil_CreateContextMenu = MenuUtil.CreateContextMenu

local function GenerateDayContextMenu(owner, rootDescription)
	rootDescription:SetTag("WT_MICRO_MENU")

	rootDescription:CreateTitle(_G.MAINMENU_BUTTON)
	rootDescription:CreateButton(_G.CHARACTER_BUTTON, function()
		_G.ToggleCharacter("PaperDollFrame")
	end)
	rootDescription:CreateButton(_G.QUESTLOG_BUTTON, function()
		ToggleFrame(_G.QuestLogFrame)
	end)
	rootDescription:CreateButton(_G.ACHIEVEMENT_BUTTON, function()
		_G.ToggleAchievementFrame()
	end)
	rootDescription:CreateButton(_G.MOUNTS, function()
		_G.ToggleCollectionsJournal(1)
	end)
	rootDescription:CreateButton(_G.PETS, function()
		_G.ToggleCollectionsJournal(2)
	end)
	rootDescription:CreateButton(_G.TOY_BOX, function()
		_G.ToggleCollectionsJournal(4)
	end)
	rootDescription:CreateButton(_G.HEIRLOOMS, function()
		_G.ToggleCollectionsJournal(5)
	end)
	rootDescription:CreateButton(_G.SOCIAL_BUTTON, function()
		_G.ToggleFriendsFrame(1)
	end)
	rootDescription:CreateButton(IsInGuild() and _G.GUILD or _G.LOOKINGFORGUILD, function()
		_G.ToggleGuildFrame()
	end)
	rootDescription:CreateButton(_G.LFG_TITLE, function()
		_G.ToggleLFDParentFrame()
	end)
	rootDescription:CreateButton(_G.RAID, function()
		_G.ToggleFriendsFrame(_G.FRIEND_TAB_RAID)
	end)
	rootDescription:CreateButton(_G.ADVENTURE, function()
		_G.ToggleEncounterJournalFrame()
	end)
	rootDescription:CreateButton(_G.HELP_BUTTON, function()
		_G.ToggleHelpFrame()
	end)
	rootDescription:CreateButton("|cfffe7b2cElvUI|r", function()
		E:ToggleOptions()
	end)
	rootDescription:CreateButton(W.Title, function()
		E:ToggleOptions("WindTools")
	end)
end

local function OnEvent(self, event, unit)
	self.text:SetFormattedText("%s", _G.MAINMENU_BUTTON)
end

local function OnClick(self, button)
	if InCombatLockdown() then
		_G.UIErrorsFrame:AddMessage(E.InfoColor .. _G.ERR_NOT_IN_COMBAT)
		return
	end

	if button == "LeftButton" then
		MenuUtil_CreateContextMenu(self, GenerateDayContextMenu)
	elseif button == "RightButton" then
		ToggleFrame(_G.GameMenuFrame)
	end
end

DT:RegisterDatatext("Micro Menu", nil, { "PLAYER_ENTERING_WORLD" }, OnEvent, nil, OnClick, nil, nil, L["Micro Menu"])
