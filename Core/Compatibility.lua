local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local MF = W.Modules.MoveFrames
local S = W.Modules.Skins
local ES = E.Skins
local C = W.Utilities.Color

local _G = _G
local format = format
local gsub = gsub
local ipairs = ipairs
local strlen = strlen
local strsplit = strsplit
local type = type

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded

function W:ConstructCompatibilityFrame()
	local frame = CreateFrame("Frame", "WTCompatibilityFrame", E.UIParent)
	frame:Size(550, 500)
	frame:Point("CENTER")
	frame:CreateBackdrop("Transparent")
	S:CreateShadowModule(frame.backdrop)
	S:MerathilisUISkin(frame.backdrop)
	frame.numModules = 0
	frame:Hide()
	frame:SetScript("OnHide", function()
		if frame.configChanged then
			E:StaticPopup_Show("PRIVATE_RL")
		end
	end)

	frame:SetFrameStrata("TOOLTIP")
	frame:SetFrameLevel(9000)
	MF:InternalHandle(frame)

	local close = F.Widgets.New("CloseButton", frame)
	if close then
		close:Point("TOPRIGHT", frame.backdrop, "TOPRIGHT")
		close:SetFrameLevel(frame:GetFrameLevel() + 1)
	end

	local title = frame:CreateFontString(nil, "ARTWORK")
	F.FontTemplate(title)
	F.SetFont(title, nil, "2")
	title:SetText(W.Title .. " " .. L["Compatibility Check"])
	title:Point("TOP", frame, "TOP", 0, -10)

	local desc = frame:CreateFontString(nil, "ARTWORK")
	F.FontTemplate(desc)
	desc:SetJustifyH("LEFT")
	desc:Width(420)
	F.SetFont(desc, nil, "-1")
	desc:SetText(
		L["There are many modules from different addons or ElvUI plugins, but several of them are almost the same functionality."]
			.. " "
			.. format(L["Have a good time with %s!"], W.Title)
	)
	desc:Point("TOPLEFT", frame, "TOPLEFT", 10, -40)

	local largeTip = frame:CreateFontString(nil, "ARTWORK")
	F.FontTemplate(largeTip)
	largeTip:SetJustifyH("CENTER")
	largeTip:Width(500)
	F.SetFont(largeTip, nil, "7")
	largeTip:SetText(
		format(
			"%s %s %s",
			C.StringWithRGB("[", E.db.general.valuecolor),
			L["Choose the module you would like to |cff00d1b2use|r"],
			C.StringWithRGB("]", E.db.general.valuecolor)
		)
	)
	largeTip:Point("TOPLEFT", desc, "BOTTOMLEFT", 0, -10)

	local tex = frame:CreateTexture("WTCompatibilityFrameIllustration", "ARTWORK")
	tex:Size(64)
	tex:SetTexture(W.Media.Textures.illMurloc1)
	tex:Point("TOPRIGHT", frame, "TOPRIGHT", -20, -25)

	local bottomDesc = frame:CreateFontString(nil, "ARTWORK")
	F.FontTemplate(bottomDesc)
	bottomDesc:SetJustifyH("LEFT")
	bottomDesc:Width(530)
	F.SetFont(bottomDesc, nil, "-1")
	bottomDesc:SetText(
		L["You can disable/enable compatibility check via the option in the bottom of [WindTools]-[Advanced]-[Core]."]
	)
	bottomDesc:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)

	local completeButton =
		CreateFrame("Button", "WTCompatibilityFrameCompleteButton", frame, "UIPanelButtonTemplate")
	---@cast completeButton Button
	completeButton.Text:SetText(L["Complete"])
	completeButton.Text:SetJustifyH("CENTER")
	completeButton.Text:SetJustifyV("MIDDLE")
	F.SetFont(completeButton.Text, E.db.general.font, "4")
	completeButton:Size(350, 35)
	completeButton:Point("BOTTOM", bottomDesc, "TOP", 0, 10)
	S:Proxy("HandleButton", completeButton)
	completeButton:SetScript("OnClick", function()
		frame:Hide()
	end)

	local scrollFrameParent =
		CreateFrame("ScrollFrame", "WTCompatibilityFrameScrollFrameParent", frame, "UIPanelScrollFrameTemplate")
	scrollFrameParent:CreateBackdrop("Transparent")
	scrollFrameParent:Point("TOPLEFT", largeTip, "BOTTOMLEFT", 0, -10)
	scrollFrameParent:Point("RIGHT", frame, "RIGHT", -32, 0)
	scrollFrameParent:Point("BOTTOM", completeButton, "TOP", 0, 10)
	S:Proxy("HandleScrollBar", scrollFrameParent.ScrollBar)
	local scrollFrame = CreateFrame("Frame", "WTCompatibilityFrameScrollFrame", scrollFrameParent)
	scrollFrame:Size(scrollFrameParent:GetSize())

	scrollFrameParent:SetScrollChild(scrollFrame)
	frame.scrollFrameParent = scrollFrameParent
	frame.scrollFrame = scrollFrame

	W.CompatibilityFrame = frame
end

local function AddButtonToCompatibilityFrame(data)
	local frame = W.CompatibilityFrame
	frame.numModules = frame.numModules + 1

	local leftButton = CreateFrame(
		"Button",
		"WTCompatibilityFrameLeftButton" .. frame.numModules,
		frame.scrollFrame,
		"UIPanelButtonTemplate"
	)
	---@cast leftButton Button
	leftButton.Text:SetText(format("%s\n%s", data.module1, data.plugin1))
	leftButton.Text:SetJustifyH("CENTER")
	leftButton.Text:SetJustifyV("MIDDLE")
	F.SetFont(leftButton.Text, E.db.general.font)
	leftButton:Size(220, 40)
	leftButton:Point("TOPLEFT", frame.scrollFrame, "TOPLEFT", 5, -frame.numModules * 50 + 45)
	S:Proxy("HandleButton", leftButton)
	leftButton:SetScript("OnClick", function(self)
		data.func1()
		frame.configChanged = true
		local name = gsub(self:GetName(), "LeftButton", "MiddleTexture")
		if _G[name] then
			_G[name]:SetTexture(E.Media.Textures.ArrowUp)
			_G[name]:SetRotation(ES.ArrowRotation.left)
			_G[name]:SetVertexColor(0, 0.82, 0.698)
		end
	end)

	local middleTexture =
		frame.scrollFrame:CreateTexture("WTCompatibilityFrameMiddleTexture" .. frame.numModules, "ARTWORK")
	middleTexture:Point("CENTER")
	middleTexture:Size(20)
	middleTexture:SetTexture(W.Media.Icons.convert)
	middleTexture:SetVertexColor(1, 1, 1)
	middleTexture:Point("CENTER", frame.scrollFrame, "TOP", 0, -frame.numModules * 50 + 25)

	local rightButton = CreateFrame(
		"Button",
		"WTCompatibilityFrameRightButton" .. frame.numModules,
		frame.scrollFrame,
		"UIPanelButtonTemplate"
	)
	---@cast rightButton Button
	rightButton.Text:SetText(format("%s\n%s", data.module2, data.plugin2))
	rightButton.Text:SetJustifyH("CENTER")
	rightButton.Text:SetJustifyV("MIDDLE")
	F.SetFont(rightButton.Text, E.db.general.font)
	rightButton:Size(220, 40)
	rightButton:Point("TOPRIGHT", frame.scrollFrame, "TOPRIGHT", -5, -frame.numModules * 50 + 45)
	S:Proxy("HandleButton", rightButton)
	rightButton:SetScript("OnClick", function(self)
		data.func2()
		frame.configChanged = true
		local name = gsub(self:GetName(), "RightButton", "MiddleTexture")
		if _G[name] then
			_G[name]:SetTexture(E.Media.Textures.ArrowUp)
			_G[name]:SetRotation(ES.ArrowRotation.right)
			_G[name]:SetVertexColor(1, 0.22, 0.376)
		end
	end)
end

local function GetDatabaseRealValue(path)
	local accessTable, accessKey, accessValue = nil, nil, E

	for _, key in ipairs({ strsplit(".", path) }) do
		if key and strlen(key) > 0 then
			if accessValue and accessValue[key] ~= nil then
				if type(accessValue[key]) == "boolean" then
					accessTable = accessValue
					accessKey = key
				end
				accessValue = accessValue[key]
			else
				F.Developer.LogDebug("[Compatibility] database path not found\n" .. path)
				return
			end
		end
	end

	return accessTable, accessKey, accessValue
end

--- Creates a compatibility check function for a specific target addon
---@param targetAddonName string The name of the target addon to check compatibility with
---@param targetAddonLocales string The localized name of the target addon
---@return fun(myModuleName: string, targetAddonModuleName: string, myDB: string, targetAddonDB: string)
local function GetCheckCompatibilityFunction(targetAddonName, targetAddonLocales)
	if not IsAddOnLoaded(targetAddonName) then
		return E.noop
	end

	return function(myModuleName, targetAddonModuleName, myDB, targetAddonDB)
		if not (myDB and targetAddonDB and type(myDB) == "string" and type(targetAddonDB) == "string") then
			return
		end

		local myTable, myKey, myValue = GetDatabaseRealValue(myDB)
		local targetTable, targetKey, targetValue = GetDatabaseRealValue(targetAddonDB)

		if myValue == true and targetValue == true then
			AddButtonToCompatibilityFrame({
				module1 = myModuleName,
				plugin1 = W.Title,
				func1 = function()
					---@diagnostic disable-next-line: need-check-nil
					myTable[myKey], targetTable[targetKey] = true, false
				end,
				module2 = targetAddonModuleName,
				plugin2 = targetAddonLocales,
				func2 = function()
					---@diagnostic disable-next-line: need-check-nil
					myTable[myKey], targetTable[targetKey] = false, true
				end,
			})
		end
	end
end

local CheckElvUIEnhanced = GetCheckCompatibilityFunction("ElvUI_Enhanced", "ElvUI Enhanced")

function W:CheckCompatibility()
	if not E.global.WT.core.compatibilityCheck then
		return
	end

	self:ConstructCompatibilityFrame()

	CheckElvUIEnhanced(
		L["Minimap Buttons"],
		L["Minimap Button Bar"],
		"private.WT.maps.minimapButtons.enable",
		"private.enhanced.minimapButtonGrabber"
	)

	if self.CompatibilityFrame.numModules > 0 then
		self.CompatibilityFrame:Show()
	end
end
