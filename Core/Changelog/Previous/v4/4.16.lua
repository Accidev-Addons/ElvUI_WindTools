local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[416] = {
	RELEASE_DATE = "2026/03/20",
	IMPORTANT = {
		["enUS"] = {
			"Continue to optimize the stability of the plugin and improve the processing of secret values.",
			"Localization file updated",
			"[Tooltip] - [Progress] The objective progress (e.g. +4%) for world quests have been updated for the Midnight Expansion, and more data will be added in future versions.",
			"[Tooltip] - [Progress] Due to the large amount of data for the objective progress, it will significantly increase the memory usage of the addon. Now, by default, only the data for the current expansion will be retained. If you need data for other expansions, you can download it through the button in the settings.",
		},
		["ruRU"] = {
			"Повышена стабильность плагина и улучшена обработка секретных значений.",
			"Файл локализации обновлен",
			"[Подсказка] - [Прогресс] Подсказки по прогрессу монстров для мировых заданий добавили много данных для 'Полночи', и в будущих версиях будет добавлено ещё больше данных.",
			"[Подсказка] - [Прогресс] Из-за большого объема данных для подсказок по прогрессу монстров, это значительно увеличивает использование памяти аддоном. Теперь по умолчанию сохраняются только данные для текущего дополнения. Если вам нужны данные для других дополнений, вы можете скачать их через кнопку в настройках.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Minimap Button] Added a new option to toggle the Garrison notification. The Garrison notification is disabled by default.",
		},
		["ruRU"] = {
			"[Кнопка миникарты] Добавлена новая опция для переключения уведомления о гарнизоне. Уведомление о гарнизоне отключено по умолчанию.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Skins] Adapted to more alert frames.",
			"[Inspect] Fixed an error caused by secret values",
			"[Chat Text] Synchronized with the latest version of the ElvUI chat module, improving stability.",
			"[Chat Text] Optimized the logic for retrieving guild member information, significantly reducing the performance overhead when retrieving guild member information, which is more noticeable in larger guilds.",
			"[Chat Link] Optimized the item level retrieval logic, now it will more accurately display the real value after item level compression.",
			"[Extra Item Bar] Updated the item list for Runes (RUNE) and Banners (BANNER).",
			"[LFG List] Fixed an issue where the quick access buttons on the right panel were not fully displayed.",
		},
		["ruRU"] = {
			"[Скины] Адаптировано к большему количеству фреймов оповещений.",
			"[Осмотр] Исправлена ошибка, вызванная секретными значениями",
			"[Текст в чате] Синхронизировано с последней версией модуля чата ElvUI, улучшая стабильность.",
			"[Текст в чате] Оптимизирована логика получения информации о членах гильдии, значительно снижая нагрузку на производительность при получении информации о членах гильдии, что более заметно в больших гильдиях.",
			"[Ссылка в чате] Оптимизирована логика получения уровня предмета, теперь он будет более точно отображать реальное значение после сжатия уровня предмета.",
			"[Дополнительная панель предметов] Обновлен список предметов для рун (RUNE) и знамен (BANNER).",
			"[Список LFG] Исправлена проблема, из-за которой кнопки быстрого доступа на правой панели отображались не полностью.",
		},
	},
}
