local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local WM = W:NewModule("WorldMap", "AceHook-3.0")

-- [SIRUS] The world map uses native window modes, not retail map-art pins.
function WM:Scale()
	if not self.db.scale.enable then
		return
	end

	WorldMapFrame:SetClampedToScreen(true)
	WorldMapFrame:SetScale(WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE and self.db.scale.size or 1)
end

function WM:Initialize()
	if IsAddOnLoaded("Mapster") then
		self.StopRunning = "Mapster"
		return
	end

	self.db = E.private.WT.maps.worldMap
	if not self.db or not self.db.enable then
		return
	end

	self:Scale()
	self:SecureHook("WorldMapFrame_ToggleWindowSize", "Scale")
end

W:RegisterModule(WM:GetName())