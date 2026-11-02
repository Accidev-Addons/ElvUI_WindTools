local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[419] = {
	RELEASE_DATE = "2026/07/20",
	IMPORTANT = {
		["enUS"] = {
			"Compatible with WoW 12.0.7.",
			"Minimum supported ElvUI version raised to 15.18.",
			"Synced the latest versions of LibKeystone and LibOpenRaid.",
		},
		["ruRU"] = {
			"Совместимо с WoW 12.0.7.",
			"Минимальная поддерживаемая версия ElvUI повышена до 15.18.",
			"Синхронизированы последние версии LibKeystone и LibOpenRaid.",
		},
	},
	NEW = {
		["enUS"] = {},
		["ruRU"] = {},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Core] Unified all FontTemplate calls through the F.FontTemplate wrapper to ensure consistent font application and alignment, adapted to ElvUI 15.17 font object mechanism.",
		},
		["ruRU"] = {
			"[Ядро] Все вызовы FontTemplate объединены через обёртку F.FontTemplate для обеспечения согласованности применения шрифтов и выравнивания, адаптация к механизму объектных шрифтов ElvUI 15.17.",
		},
	},
}
