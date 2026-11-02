local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[410] = {
	RELEASE_DATE = "2026/02/05",
	IMPORTANT = {
		["enUS"] = {
			"[Advanced] - [Profiles] Fixed an issue where export and import strings did not correctly include all configurations.",
		},
		["ruRU"] = {
			"[Расширенные] - [Профили] Исправлена ошибка, из-за которой строки экспорта и импорта не включали все настройки.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Skins] Added a skin for the Blizzard Damage Meter.",
			"[Extra Item Bar] Re-added groups like POSTIONSL, FLASKDF that existed in the old version.",
			"[Extra Item Bar] Separated POTIONGN from POTIONTWW and POTIONMN, specifically for placing some cross-version items, such as Healthstones.",
		},
		["ruRU"] = {
			"[Скины] Добавлен скин для измерителя урона от Blizzard.",
			"[Дополнительная панель предметов] Повторно добавлены такие группы, как POSTIONSL, FLASKDF, которые существовали в старой версии.",
			"[Дополнительная панель предметов] POTIONGN была отделена от POTIONTWW и POTIONMN специально для размещения некоторых предметов, доступных в разных версиях игры, таких как Камни здоровья.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Chat Text] Synchronized the chat text processing code from the latest version of ElvUI.",
			"[Tags] You can now view the additionally added tags on ElvUI's Available Tags page.",
			"[Skins] Optimized Rematch skin.",
		},
		["ruRU"] = {
			"[Текст чата] Синхронизирован код обработки текста чата из последней версии ElvUI.",
			"[Теги] Теперь Вы можете просматривать дополнительно добавленные теги на странице доступных тегов ElvUI.",
			"[Скины] Оптимизирован скин Rematch.",
		},
	},
}
