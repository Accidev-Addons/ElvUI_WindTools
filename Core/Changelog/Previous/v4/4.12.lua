local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[412] = {
	RELEASE_DATE = "2026/02/25",
	IMPORTANT = {
		["enUS"] = {
			"[Skins] UI Errors Skin now uses a private frame and synchronizes native frame visibility logic to reduce taint risk.",
			"[Skins] UI Errors Skin is now enabled by default, and a height option has been added.",
		},
		["ruRU"] = {
			"[Скины] Теперь интерфейс ошибок использует закрытый фрейм и синхронизирует собственную логику видимости фрейма для снижения риска загрязнения.",
			"[Скины] Теперь интерфейс ошибок включен по умолчанию, также добавлена ​​опция регулировки высоты.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Datatext] Added Quest and Garrison options to the micro menu.",
			"[Minimap Button] Added options for hiding and ignoring regex.",
			"[Skins] Added skin for HandyNotes MapNotes.",
			"[Skins] Added a separate skin for damage statistics interface, which can be found in [Skins] - [Damage Meter].",
			"[Game Bar] Now the hearthstone button support fallback options, which can automatically switch to the fallback item when the selected hearthstone is not available.",
			"[Game Bar] Hearthstone button can now select spells, such as Shaman's Astral Recall.",
			"[Game Bar] Added middle mouse button setting for hearthstone button, which can be set to use different items or spells.",
		},
		["ruRU"] = {
			"[Текст данных] В микроменю добавлены опции 'Задания' и 'Гарнизон'.",
			"[Кнопка миникарты] Добавлены опции для скрытия и игнорирования регулярных выражений.",
			"[Скины] Добавлена тема для HandyNotes MapNotes.",
			"[Скины] Добавлена отдельная тема для интерфейса статистики урона, которую можно найти в [Скины] - [Дамагметр].",
			"[Игровая панель] Теперь кнопка камня возвращения поддерживает опции резервного использования, которые могут автоматически переключаться на запасной предмет, когда выбранный камень возвращения недоступен.",
			"[Игровая панель] Кнопка камня возвращения теперь может выбирать заклинания, такие как Астральная телепортация шамана.",
			"[Игровая панель] Добавлена настройка средней кнопки мыши для кнопки камня возвращения, которая может быть настроена на использование различных предметов или заклинаний.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Skins] Fixed the skin for Simple Addon Manager.",
			"[Skins] Optimized the skin for Collectionator, supporting its decor page.",
			"[Skins] Added shadow borders to the aura icons for ElvUI Nameplate skin.",
			"[Skins] Optimized the skin for Guild & Community, reducing the possibility of causing taint.",
			"[Skins] Optimized the skin for Cooldown Manager Setting, reducing the possibility of causing taint.",
			"[Tooltips] Fixed multiple errors that may occur when querying tooltip information.",
			"[World Map] Fixed an issue where removing fog of war may not correctly display the Argus area on the Broken Isles map.",
			"[Smart Tab] Fixed a secret value error that may occur when trying to record whisper targets during combat.",
			"[Chat Text] Synchronized ElvUI chat code for improved stability.",
			"[Chat Text] Fixed an issue where clicking to quickly set whisper targets may not work when the server has spaces.",
			"[Quick Focus] Optimized an issue where using non-left-click may not set focus correctly.",
		},
		["ruRU"] = {
			"[Скины] Исправлена тема для Simple Addon Manager.",
			"[Скины] Оптимизирована тема для Collectionator, поддерживающая его последнюю страницу декора.",
			"[Скины] Добавлены теневые границы к иконкам аур для темы табличек с именем ElvUI.",
			"[Скины] Оптимизирована тема для Гильдии и Сообщества, что снижает вероятность загрязнения.",
			"[Скины] Оптимизирована тема для настроек Менеджера перезарядки, что снижает вероятность загрязнения.",
			"[Подсказки] Исправлено несколько ошибок, которые могут возникать при запросе информации в подсказках.",
			"[Карта мира] Исправлена проблема, из-за которой удаление тумана войны может некорректно отображать область Аргуса на карте Расколотых островов.",
			"[Умная вкладка] Исправлена ошибка секретного значения, которая может возникать при попытке записать цели шепота во время боя.",
			"[Текст чата] Синхронизирован код чата ElvUI для улучшения стабильности.",
			"[Текст чата] Исправлена проблема, из-за которой при клике для быстрого назначения целей шепота может не работать, если сервер содержит пробелы.",
			"[Быстрый фокус] Оптимизирована проблема, из-за которой использование не левой кнопки мыши может неправильно устанавливать фокус.",
		},
	},
}
