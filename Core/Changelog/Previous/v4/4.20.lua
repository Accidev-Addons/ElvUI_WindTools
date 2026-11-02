local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[420] = {
	RELEASE_DATE = "2026/08/14",
	IMPORTANT = {
		["enUS"] = {
			"Minimum supported ElvUI version raised to 15.21.",
			"ElvUI no longer ships LibDeflate; WindTools now vendors it for LibOpenRaid and profile import/export.",
			"Adapted to ElvUI FontTemplate API change: argument is now an LSM font name, not a font path.",
		},
		["ruRU"] = {
			"Минимальная поддерживаемая версия ElvUI повышена до 15.21.",
			"ElvUI больше не поставляет LibDeflate; WindTools теперь включает эту библиотеку для LibOpenRaid и импорта/экспорта профилей.",
			"Адаптация к новому API FontTemplate ElvUI: аргумент теперь имя шрифта LSM, а не путь к файлу.",
		},
	},
	NEW = {
		["enUS"] = {},
		["ruRU"] = {},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"Fixed a nil E.global.WT error from initializing too early; WindTools now starts after ElvUI AceDB is ready again.",
			"Updated F.FontTemplate / F.SetFont helpers to correctly handle LSM names versus font file paths.",
			"[World Map] Update fog removal database.",
			"[Tooltips] Update 12.1 tier set tooltips.",
			"[Tooltips] Add new 12.1 raid progression tooltips.",
			"[Tooltips] Update S2 Mythic+ dungeons tooltips.",
			"[LFG List] Update S2 Mythic+ dungeons data.",
		},
		["ruRU"] = {
			"Исправлена ошибка nil E.global.WT из‑за слишком ранней инициализации; WindTools снова запускается после готовности AceDB ElvUI.",
			"Обновлены помощники F.FontTemplate / F.SetFont для корректной работы с именами LSM и путями к файлам шрифтов.",
			"[Карта мира] Обновлена база данных по удалению тумана.",
			"[Подсказки] Обновлены подсказки для комплектов брони (12.1).",
			"[Подсказки] Добавлены новые подсказки для рейдов 12.1.",
			"[Подсказки] Обновлены подсказки для М+ 2-го сезона.",
			"[Поиск группы] Обновлены данные для М+ 2-го сезона.",
		},
	},
}
