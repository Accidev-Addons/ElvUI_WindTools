local W, F, E = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI
local S = W.Modules.Skins ---@type Skins
local NP = E:GetModule("NamePlates")

local function CreatePlateShadow(frame)
	S:CreateShadow(frame)
	local shadow = frame and frame.__windShadow and frame.shadow
	if shadow then
		local edge = shadow:GetBackdrop().edgeSize
		shadow:SetOutside(frame, edge, edge, nil, true)
	end
end

function S:NP_OnCreated(_, frame)
	local plate = frame and frame.ElvUIFrame
	if not plate then return end

	CreatePlateShadow(plate.Health)
	CreatePlateShadow(plate.CastBar)
	if plate.CastBar then
		CreatePlateShadow(plate.CastBar.Icon)
	end
end

function S:ElvUI_Nameplates()
	if not E.private.nameplates.enable then return end
	if not (E.private.WT.skins.elvui.enable and E.private.WT.skins.elvui.nameplates) then return end

	if not self:IsHooked(NP, "OnCreated") then
		self:SecureHook(NP, "OnCreated", "NP_OnCreated")
	end
	for frame in pairs(NP.CreatedPlates) do
		self:NP_OnCreated(nil, frame)
	end
end

S:AddCallback("ElvUI_Nameplates")
