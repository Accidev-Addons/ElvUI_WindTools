local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local ET = E:GetModule("Tooltip")
local T = W.Modules.Tooltips

function T:ChangeHealthBarPosition(_, tt)
	local barYOffset = E.db.WT.tooltips.elvUITweaks.healthBar.barYOffset
	local textYOffset = E.db.WT.tooltips.elvUITweaks.healthBar.textYOffset

	if E.private.tooltip.enable ~= true then
		return
	end

	if not F.CanAccessWidget(tt) or not ET.db.visibility then
		return
	end

	if tt:GetAnchorType() ~= "ANCHOR_NONE" then
		return
	end

	local statusBar = tt.StatusBar
	if statusBar then
		local spacing = E.Spacing * 3
		local position = ET.db.healthBar.statusPosition
		if position == "BOTTOM" then
			statusBar:ClearAllPoints()
			statusBar:Point("TOPLEFT", tt, "BOTTOMLEFT", E.Border, -spacing + barYOffset)
			statusBar:Point("TOPRIGHT", tt, "BOTTOMRIGHT", -E.Border, -spacing + barYOffset)
		else
			statusBar:ClearAllPoints()
			statusBar:Point("BOTTOMLEFT", tt, "TOPLEFT", E.Border, spacing + barYOffset)
			statusBar:Point("BOTTOMRIGHT", tt, "TOPRIGHT", -E.Border, spacing + barYOffset)
		end
		if statusBar.text then
			statusBar.text:ClearAllPoints()
			statusBar.text:Point("CENTER", statusBar, 0, textYOffset)
		end
	end
end

function T:HealthBar()
	T:SecureHook(ET, "GameTooltip_SetDefaultAnchor", "ChangeHealthBarPosition")
end

T:AddCallback("HealthBar")
