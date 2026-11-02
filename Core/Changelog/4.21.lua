local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[421] = {
	RELEASE_DATE = "2026/08/24",
	IMPORTANT = {
		["enUS"] = {
			"Minimum supported ElvUI version raised to 15.26.",
			"Profile import/export now uses Blizzard's built-in encoding. Strings exported from older WindTools versions can no longer be imported; please re-export after updating.",
		},
		["ruRU"] = {
			"Минимальная поддерживаемая версия ElvUI повышена до 15.26.",
			"Импорт/экспорт профилей теперь использует встроенное кодирование Blizzard. Строки, экспортированные из старых версий WindTools, больше нельзя импортировать — экспортируйте заново после обновления.",
		},
	},
	NEW = {
		["enUS"] = {},
		["ruRU"] = {},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Skins] Update the Blizzard Damage Meter skin for the new window layout.",
			"[Damage Meter Layout] Let the game manage session windows so the combat timer and entries update correctly.",
			"[Skins] Fix Damage Meter session window mouseover interfering with the default UI.",
			"[Exit Phase Diving] Fix an error when checking Phase Diving status in combat.",
			"[Inspect] Fix inspect specialization errors when the target's identity is hidden in combat.",
			"[Skins] ElvUI aura shadows now show on player auras, unit frames, and nameplates.",
		},
		["ruRU"] = {
			"[Скины] Обновлён скин Blizzard Damage Meter под новое расположение окна.",
			"[Макет индикатора урона] Окна сессии снова управляются игрой, поэтому таймер боя и строки обновляются правильно.",
			"[Скины] Исправлено наведение на окно сессии Damage Meter, мешавшее стандартному интерфейсу.",
			"[Выход из фазового погружения] Исправлена ошибка при проверке фазового погружения в бою.",
			"[Осмотр] Исправлена ошибка осмотра специализации, когда личность цели скрыта в бою.",
			"[Скины] Тени аур ElvUI снова отображаются на аурах игрока, рамках юнитов и индикаторах.",
		},
	},
}
