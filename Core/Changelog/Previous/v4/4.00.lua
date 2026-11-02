local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[400] = {
	RELEASE_DATE = "2025/10/09",
	IMPORTANT = {
		["enUS"] = {
			"Support for WoW 11.2.5.",
			"Minimum supported ElvUI version is now 14.02.",
			"Update Korean translation",
			"[Inspect] The module has been completely rewritten. Due to changes in options, the saved options related to this module will be reset.",
		},
		["ruRU"] = {
			"Поддержка WoW 11.2.5.",
			"Минимальная поддерживаемая версия ElvUI теперь 14.02.",
			"Обновлен корейский перевод",
			"[Осмотр] Модуль был полностью переписан. Из-за изменений в параметрах сохраненные параметры, связанные с этим модулем, будут сброшены.",
		},
	},
	NEW = {
		["enUS"] = {
			"New font [LINE Seed].",
			"New font [Chivo Mono].",
			"[Skins] Added skin for the Blizzard Game Menu (Esc key menu).",
			"[Skins] Added skin for Advanced Interface Options.",
			"[Skins] Added skin for Rematch.",
			"[Others] Added [Achievement Tracker] module. Made by: Dack",
			"[Friend List] Now able to display icons for Legion Remix players.",
		},
		["ruRU"] = {
			"Новый шрифт [LINE Seed].",
			"Новый шрифт [Chivo Mono].",
			"[Скины] Добавлен скин для игрового меню Blizzard (меню клавиши Esc).",
			"[Скины] Добавлен скин для Advanced Interface Options.",
			"[Скины] Добавлен скин для Rematch.",
			"[Прочее] Добавлен модуль [Отслеживание достижений]. Автор: Dack",
			"[Список друзей] Теперь можно отображать значки для игроков Legion Remix.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Tooltip] Fix the problem that the icon could not be displayed in some non-Asian languages.",
			"[Skins] Optimize the performance of the module skins.",
			"[Extra Items Bar] Added some openable items for Legion Remix.",
			"[Friend List] WoW retail friends will no longer be incorrectly shown with the Remix icon.",
		},
		["ruRU"] = {
			"[Подсказки] Исправлена проблема, из-за которой значок не отображался в некоторых неазиатских языках.",
			"[Скины] Оптимизирована производительность скинов модулей.",
			"[Дополнительная панель предметов] Добавлены некоторые открываемые предметы для Legion Remix.",
			"[Список друзей] Друзья WoW на официальном сервере больше не будут неправильно отображаться с иконкой Remix.",
		},
	},
}
