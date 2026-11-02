local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[408] = {
	RELEASE_DATE = "2026/01/26",
	IMPORTANT = {
		["enUS"] = {
			"Added [Advanced] - [Game Fixes] - [Midnight API Fix] option to fix some Blizzard caused Lua errors. Taking over some Blizzard functions may cause some Blizzard frames' memory usage to be counted as WindTools, which has no actual impact. Enabled by default. Some fix codes are from NDui.",
			"Fixed multiple errors caused by secret value changes.",
			"Removed all Remix related codes.",
			"Removed Legion Remix Helper skin.",
		},
		["ruRU"] = {
			"Добавлена опция [Дополнительно] - [Исправления игры] - [Исправление Midnight API] для исправления некоторых ошибок Lua, вызванных Blizzard. Взятие на себя некоторых функций Blizzard может привести к тому, что использование памяти некоторых фреймов Blizzard будет учитываться как WindTools, что не оказывает фактического влияния. По умолчанию включено. Некоторые исправления кода взяты из NDui.",
			"Исправлены несколько ошибок, вызванных изменениями секретных значений.",
			"Удалены все связанные с Remix коды.",
			"Удалена оболочка Legion Remix Helper.",
		},
	},
	NEW = {
		["enUS"] = {},
		["ruRU"] = {},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Raid Markers] Fixed clear button and stop countdown functionality.",
			"[Switch Button] Fixed an issue where the quest announce module might not be able to be enabled when toggling announce on.",
			"[Inspect] Improved the method of obtaining item level, now able to correctly get the true item level of some items.",
			"[Quick Focus] Improved the logic of focus switching, fixed the automatic marking feature.",
			"[Skins] Fixed some issues related to Cooldown Manager.",
			"[Chat Text] Synchronized the latest changes in ElvUI chat, fixed some errors.",
		},
		["ruRU"] = {
			"[Метки рейда] Исправлена функция кнопки очистки и остановки обратного отсчета.",
			"[Переключатель] Исправлена проблема, из-за которой модуль объявления заданий мог не включаться при переключении объявления.",
			"[Осмотр] Улучшен метод получения уровня предмета, теперь можно правильно получить истинный уровень предмета некоторых предметов.",
			"[Быстрый фокус] Улучшена логика переключения фокуса, исправлена функция автоматической маркировки.",
			"[Скины] Исправлены некоторые проблемы, связанные с менеджером перезарядки.",
			"[Текст чата] Синхронизированы последние изменения в чате ElvUI, исправлены некоторые ошибки.",
		},
	},
}
