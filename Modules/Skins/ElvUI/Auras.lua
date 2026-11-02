local W, F, E = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI
local S = W.Modules.Skins ---@type Skins
local A = E:GetModule("Auras")
local UF = E:GetModule("UnitFrames")
local NP = E:GetModule("NamePlates")

local ipairs = ipairs
local pairs = pairs

local function SkinAuraButton(button, setting)
	local skins = E.private.WT.skins
	if not (skins.enable and skins.elvui.enable and skins.elvui[setting]) then
		return
	end
	if not button or button.__windSkin or not F.CanAccessWidget(button) then
		return
	end

	S:CreateShadow(button)
	S:BindShadowColorWithBorder(button)
	button.__windSkin = true
end

local function SkinAuraContainer(container, setting)
	if not container then return end
	for _, button in ipairs(container.buttons or container) do
		SkinAuraButton(button, setting)
	end
end

local function SkinUnitFrame(frame, setting)
	if not frame then return end
	SkinAuraContainer(frame.Buffs, setting)
	SkinAuraContainer(frame.Debuffs, setting)
end

function S:ElvUI_Auras_SkinExistingButtons()
	SkinAuraContainer(A.BuffFrame, "auras")
	SkinAuraContainer(A.DebuffFrame, "auras")
	if A.BuffFrame then
		for _, button in ipairs(A.BuffFrame.consolidated or {}) do
			SkinAuraButton(button, "auras")
		end
	end

	for unit in pairs(UF.units) do
		SkinUnitFrame(UF[unit], "unitFrames")
	end
	for unit in pairs(UF.groupunits) do
		SkinUnitFrame(UF[unit], "unitFrames")
	end
	for groupName in pairs(UF.headers) do
		local group = UF[groupName]
		if group and group.GetChildren then
			for _, child in ipairs({ group:GetChildren() }) do
				if child.Health then
					SkinUnitFrame(child, "unitFrames")
				elseif child.GetChildren then
					for _, nested in ipairs({ child:GetChildren() }) do
						SkinUnitFrame(nested, "unitFrames")
					end
				end
			end
		end
	end
	for frame in pairs(NP.CreatedPlates) do
		SkinUnitFrame(frame.ElvUIFrame, "nameplates")
	end
end

function S:ElvUI_Auras()
	local skins = E.private.WT.skins.elvui
	if not skins.enable or not (skins.auras or skins.unitFrames or skins.nameplates) then
		return
	end

	if not self:IsHooked(A, "CreateIcon") then
		self:SecureHook(A, "CreateIcon", function(_, button)
			SkinAuraButton(button, "auras")
		end)
	end
	if not self:IsHooked(UF, "UpdateAuraSettings") then
		-- Existing oUF PostCreateIcon callbacks retain the original constructor reference.
		self:SecureHook(UF, "UpdateAuraSettings", function(_, container, button)
			SkinAuraButton(button, "unitFrames")
		end)
	end
	if not self:IsHooked(NP, "Construct_AuraIcon") then
		self:SecureHook(NP, "Construct_AuraIcon", function(_, container, index)
			SkinAuraButton(container[index], "nameplates")
		end)
	end
	self:ElvUI_Auras_SkinExistingButtons()
end

S:AddCallback("ElvUI_Auras")
