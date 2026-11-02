local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[411] = {
	RELEASE_DATE = "2026/02/12",
	IMPORTANT = {
		["enUS"] = {
			"Compatible with 12.0.1 API.",
			"Minimum supported ElvUI version raised to 15.05.",
			"SetPassThroughButtons fix is disabled by default, you can enable it anytime in [Advanced] settings.",
			"The Midnight API fix has been removed, switching to ElvUI API for minimal fix.",
			"[Announcement] Rewrote the announcement feature for utility skills, now you can announce your own skills without Blizzard restrictions.",
			"[Who Clicked Minimap] Due to Blizzard's complete encryption of minimap click events, this feature can no longer be implemented, so the module has been removed.",
		},
		["ruRU"] = {
			"Совместимость с API 12.0.1.",
			"Минимальная поддерживаемая версия ElvUI повышена до 15.05.",
			"Исправление SetPassThroughButtons отключено по умолчанию, Вы можете включить его в любое время в настройках [Дополнительно].",
			"Исправление API 'Midnight' было удалено, для минимального исправления используется API ElvUI.",
			"[Оповещения] Переписана функция оповещений для вспомогательных навыков, теперь Вы можете оповещать о своих собственных навыках без ограничений Blizzard.",
			"[Кто нажал на миникарту] Из-за полной шифровки событий кликов по миникарте Blizzard эта функция больше не может быть реализована, поэтому модуль был удален.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Combat Reminder] Added sound settings options for entering and leaving combat. Disabled by default.",
			"[Skins] Added shadow skin for ElvUI Nameplates.",
			"[Objective Tracker] Added position and scale adjustment options for the POI button. Disabled by default.",
			"[Move Frames] Added an option to automatically reset off-screen frame positions. Enabled by default.",
		},
		["ruRU"] = {
			"[Боевое напоминание] Добавлены параметры настройки звука для входа и выхода из боя. По умолчанию отключено.",
			"[Скины] Добавлен скин теней для индикаторов здоровья ElvUI.",
			"[Трекер заданий] Добавлены параметры настройки позиции и масштаба для кнопки POI. По умолчанию отключено.",
			"[Перемещение фреймов] Добавлена ​​опция автоматического сброса позиций фреймов за пределами экрана. По умолчанию включено.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"Optimized a global variable leak issue.",
			"[Announcement] Removed all in-combat restricted features in Announcement module.",
			"[Absorb] Now custom textures are only applied to damage absorbs.",
			"[Extra Items Bar] Quest items are now sorted by quest distance.",
			"[Skins] Optimized Cooldown Manager skin, eliminating gaps between cooldown animations and icons.",
			"[Move Frames] Optimized the stability of frame position saving, hoping to reduce the occurrence of frames flying off the screen.",
			"[Move Frames] Minimized data writing to frames to prevent taint.",
		},
		["ruRU"] = {
			"Оптимизирована проблема утечки глобальных переменных.",
			"[Оповещения] Удалены все функции, ограниченные в бою, в модуле 'Оповещения'.",
			"[Поглощение] Теперь пользовательские текстуры применяются только к поглощениям урона.",
			"[Дополнительная панель предметов] Предметы, получаемые в ходе выполнения задания, теперь сортируются по расстоянию до места выполнения задания.",
			"[Скины] Оптимизирован скин для 'Менеджера перезарядок', устранены зазоры между анимациями перезарядки и иконками.",
			"[Перемещение фреймов] Оптимизирована стабильность сохранения позиции фреймов, что должно уменьшить случаи их вылета за пределы экрана.",
			"[Перемещение фреймов] Минимизирована запись данных во фреймы для предотвращения загрязнения.",
		},
	},
}
