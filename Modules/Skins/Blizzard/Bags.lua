local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local S = W.Modules.Skins ---@type Skins

local _G = _G
local hooksecurefunc = hooksecurefunc

local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES

function S:Bank()
	if E.private.bags.enable or not self:CheckDB("bags") then
		return
	end

	self:CreateBackdropShadow(_G.BankFrame)
end

local skinnedButtons = {}

local function SkinItemButton(button)
	if not button or not button.IconBorder or skinnedButtons[button] then
		return
	end

	skinnedButtons[button] = true

	hooksecurefunc(button.IconBorder, "SetAlpha", function(border, alpha)
		if alpha ~= 0 then
			border:SetAlpha(0)
		end
	end)
end

local function SkinBag(bagID, bag)
	local container = bag or _G["ContainerFrame" .. bagID]
	if not container then
		return
	end

	S:CreateShadow(container)

	-- Some other addons like Zygor may change the alpha, so make the alpha more robust
	hooksecurefunc(container, "UpdateItems", function()
		for _, button in container:EnumerateValidItems() do
			SkinItemButton(button)
		end
	end)
end

function S:Bag()
	if E.private.bags.enable or not self:CheckDB("bags") then
		return
	end

	for bagID = 1, NUM_CONTAINER_FRAMES do
		SkinBag(bagID)
	end

	SkinBag(1, _G.ContainerFrameCombinedBags)
end

S:AddCallback("Bag")
S:AddCallback("Bank")
