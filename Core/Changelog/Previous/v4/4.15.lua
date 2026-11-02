local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[415] = {
	RELEASE_DATE = "2026/03/14",
	IMPORTANT = {
		["enUS"] = {
			"Continue to optimize the stability of the plugin and improve the processing of secret values.",
		},
		["ruRU"] = {
			"Повышена стабильность плагина и улучшена обработка секретных значений.",
		},
	},
	NEW = {
		["enUS"] = {
			"Added a new module [Combat] - [Damage Meter Layout]. This module helps you quickly set up multiple aligned layouts and automatically switch between them based on conditions. Disabled by default.",
			"Added a new module [Quest & Achieve] - [Auto Collapse]. This module automatically collapses or expands the objective tracker based on the player's location or status. Disabled by default.",
			"Added a new module [Quest & Achieve] - [Prey Hunt]. This module can display specific progress text on the default progress UI, and automatically track related quests when hunting. More practical features are planned to be added in the future. Enabled by default.",
			"[Skins] Added a new skin for Extra Quest Button.",
			"[Skins] Added a new skin for Addon Profiler.",
		},
		["ruRU"] = {
			"Добавлен новый модуль [Бой] - [Макет счетчика урона]. Этот модуль помогает быстро настроить несколько выровненных макетов и автоматически переключаться между ними в зависимости от условий. По умолчанию отключено.",
			"Добавлен новый модуль [Задания и достижения] - [Автосворачивание]. Этот модуль автоматически сворачивает или разворачивает отслеживатель задач в зависимости от местоположения или статуса игрока. По умолчанию отключено.",
			"Добавлен новый модуль [Задания и достижения] - [Охота на добычу]. Этот модуль может отображать конкретный текст прогресса на стандартном интерфейсе прогресса и автоматически отслеживать связанные задания при охоте. В будущем планируется добавить больше практических функций. По умолчанию включено.",
			"[Скины] Добавлен новый скин для Extra Quest Button.",
			"[Скины] Добавлен новый скин для Addon Profiler.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Objective Tracker] Significantly optimized the memory usage.",
			"[Quest Progress] Optimized the issue where the profession tier icons show as garbled text in the progress.",
			"[Game Bar] Fixed an issue where clicking the friends list icon sometimes changed to add friend.",
			"[Game Bar] Fixed an issue where it sometimes prompts hearthstone not found.",
			"[Inspect] Updated the display logic for additional gem sockets in Midnight.",
			"[Context Menu] Relaxed the anti-taint strategy, now only requiring Ctrl to show the menu when right-clicking a Battle.net friend, and no longer requiring Ctrl for other cases.",
			"[Extra Item Bar] Updated the profession items for Midnight, and separated the profession item lists for different versions. You can use PROFTWW, PROFMN to use the profession item lists for different versions.",
			"[Extra Item Bar] Added some missing potions for Midnight.",
			"[Tooltip] - [Progress] Tweaked the default enabled M+ special achievements.",
			"[Objective Tracker] Updated quest IDs, now the recognition will be more accurate.",
			"[Skins] Optimized the skinning performance for Blizzard's bags.",
			"[Skins] The damage meter skin now supports completely hiding the window backdrop.",
			"[Skins] The damage meter skin now supports adjusting the scrollbar.",
			"[Skins] Optimized the skinning for widgets, supporting more progress bars.",
			"[Skins] The widget skin now attempts to use colors close to the original when skinning status bars.",
			"[Skins] Fixed an issue where the scenario campaign skin may cause some timer bars to not show.",
			"[Skins] Optimized the BigWigs skin, supporting BigWigs built-in tooltip skinning.",
		},
		["ruRU"] = {
			"[Отслеживание задач] Значительно оптимизировано использование памяти.",
			"[Прогресс заданий] Оптимизирована проблема, из-за которой иконки уровней профессий отображались в виде нечитаемых символов в прогрессе.",
			"[Панель игры] Исправлена проблема, из-за которой при нажатии на значок списка друзей иногда происходило добавление друга.",
			"[Панель игры] Исправлена проблема, из-за которой иногда появлялось сообщение 'Камень возвращения не найден'.",
			"[Осмотр] Обновлена логика отображения дополнительных слотов для самоцветов в 'Полночи'.",
			"[Контекстное меню] Упрощена стратегия предотвращения ошибок Blizzard. Теперь для отображения меню при ПКМ на друга в Battle.net требуется нажать Ctrl, а в других случаях Ctrl больше не требуется.",
			"[Дополнительная панель предметов] Обновлены предметы профессий для 'Полночи', а также разделены списки предметов профессий для разных версий. Вы можете использовать PROFTWW, PROFMN для использования списков профессиональных предметов для разных версий.",
			"[Дополнительная панель предметов] Добавлены некоторые отсутствующие зелья для 'Полночи'.",
			"[Подсказка] - [Прогресс] Изменены настройки специальных достижений для M+, включенных по умолчанию.",
			"[Отслеживание задач] Обновлены ID заданий, теперь распознавание будет более точным.",
			"[Скины] Оптимизирована производительность скинов для сумок Blizzard.",
			"[Скины] Скин для счетчика урона теперь поддерживает полное скрытие фона окна.",
			"[Скины] Скин для счетчика урона теперь поддерживает настройку полосы прокрутки.",
			"[Скины] Оптимизировано оформление виджетов, поддерживается больше полос прогресса.",
			"[Скины] Оформление виджетов теперь при оформлении полос здоровья пытается использовать цвета, близкие к оригиналу.",
			"[Скины] Исправлена проблема, из-за которой скин для сценариев мог привести к тому, что некоторые таймеры не отображались.",
			"[Скины] Оптимизирован скин для BigWigs, поддерживается встроенное оформление подсказок BigWigs.",
		},
	},
}
