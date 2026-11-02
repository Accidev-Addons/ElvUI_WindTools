local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins
local C = W.Utilities.Color

local _G = _G
local hooksecurefunc = hooksecurefunc
local pairs = pairs

local function HandleGameMenuButton(button)
	local text = button:GetFontString()
	if not text then
		return
	end

	F.SetFont(text)
	text:SetTextColor(C.ExtractRGBFromTemplate("neutral-100"))
end

function S:GameMenuFrame()
	if not self:CheckDB("misc", "gameMenu") then
		return
	end

	local GameMenuFrame = _G.GameMenuFrame

	if not GameMenuFrame or E.OtherAddons.ConsolePort then
		return
	end

	self:CreateShadow(GameMenuFrame)

	for _, button in pairs({ GameMenuFrame:GetChildren() }) do
		if button:IsObjectType("Button") then
			HandleGameMenuButton(button)
		end
	end

	if GameMenuFrame.ElvUI then
		hooksecurefunc(GameMenuFrame.ElvUI, "SetFormattedText", HandleGameMenuButton)
	end
end

S:AddCallback("GameMenuFrame")
