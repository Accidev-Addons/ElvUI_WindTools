local W ---@class WindTools
local F, E, L, V, P, G ---@type Functions, ElvUI, LocaleTable, PrivateDB, ProfileDB, GlobalDB
W, F, E, L, V, P, G = unpack((select(2, ...)))

function W:UpdateScripts()
	local profile = E.db.WT
	local gameBar = profile.misc and profile.misc.gameBar
	if gameBar and (gameBar.visibility == "[petbattle]hide;show" or gameBar.visibility == "[petbattle] hide; show") then
		gameBar.visibility = "show"
	end
	local itemBars = profile.item and profile.item.extraItemsBar
	if itemBars then
		for i = 1, 5 do
			local bar = itemBars["bar" .. i]
			if bar and (bar.visibility == "[petbattle]hide;show" or bar.visibility == "[petbattle] hide; show") then
				bar.visibility = "show"
			end
		end
	end

	E.global.WT.version = W.Version
	E.db.WT.version = W.Version
	E.private.WT.version = W.Version
end
