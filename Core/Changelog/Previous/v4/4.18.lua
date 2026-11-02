local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[418] = {
	RELEASE_DATE = "2026/04/23",
	IMPORTANT = {
		["enUS"] = {
			"Compatible with WoW 12.0.5.",
			"Minimum ElvUI version required is now 15.12.",
			"Updated library LibOpenRaid.",
			"[Compatibility Check] Optimized compatibility check with mMediaTag.",
			"Removed [Misc] - [Move Speed] module.",
		},
		["ruRU"] = {
			"Совместимо с World of Warcraft 12.0.5.",
			"Минимальная требуемая версия ElvUI теперь 15.12.",
			"Обновлена библиотека LibOpenRaid.",
			"[Проверка совместимости] Оптимизирована проверка совместимости с mMediaTag.",
			"Удален модуль [Прочее] - [Скорость передвижения].",
		},
	},
	NEW = {
		["enUS"] = {
			"[Mute] Added a new mute option for Obsidian Nightwing. Disabled by default.",
			"[Skins] Added new independent options for [Loss of Control] skin. Enabled by default.",
			"[LFG List] Added a tooltip option for filter buttons in the right panel. Enabled by default.",
			"[Absorb] Added the new options to modify the textures for heal absorbs and heal predictions. Disabled by default.",
			"Added new module [Unitframes] - [Name Clip] which provides the functionality of manually setting the length of name element, while being compatible with both ElvUI name element and custom texts.",
		},
		["ruRU"] = {
			"[Отключение звуков] Добавлена новая опция отключения звука для Обсидианового ночного крыла. Отключено по умолчанию.",
			"[Скины] Добавлены новые независимые опции для скина [Потеря контроля]. Включено по умолчанию.",
			"[Поиск группы] Добавлена опция подсказки для кнопок фильтров на правой панели. Включено по умолчанию.",
			"[Поглощение] Добавлены новые опции для изменения текстур поглощения лечения и предсказания лечения. Отключено по умолчанию.",
			"Добавлен новый модуль [Юнит-фреймы] - [Обрезка имени], который предоставляет функциональность ручной настройки длины элемента имени, при этом совместим с элементом имени ElvUI и пользовательскими текстами.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Extra Item Bar] Updated the item data for the Feasts and Portals.",
			"[Extra Item Bar] Updated the item data for openable items.",
			"[LFG List] Optimized the abbreviation of dungeon names in Western languages to better fit the Raider.IO style.",
			"[LFG List] Fixed the issue of leader score filtering and friend display error.",
			"[Skins] Cleaned up World Quest Tab skins.",
			"[Skins] Fixed the issue of Simple Addon Manager right side content not following frame movement quickly.",
			"[Chat Text] Synchronized with ElvUI's chat module, attempting to resolve Lua errors that occur in some cases.",
			"[Unit Frames] - [Tags] Optimized the issue of healabsorbs-autohide event not triggering in a timely manner.",
			"[Tooltips] - [Objective Progress] Added support for more objective progress display.",
		},
		["ruRU"] = {
			"[Дополнительная панель предметов] Обновлены данные предметов для праздников и порталов.",
			"[Дополнительная панель предметов] Обновлены данные предметов для открываемых предметов.",
			"[Поиск группы] Оптимизировано сокращение названий подземелий в западных языках, чтобы лучше соответствовать стилю Raider.IO.",
			"[Поиск группы] Исправлена проблема с фильтрацией очков лидера и ошибкой отображения друзей.",
			"[Скины] Очищены скины World Quest Tab.",
			"[Скины] Исправлена проблема, из-за которой содержимое на правой стороне Simple Addon Manager не могло быстро следовать за движением рамки.",
			"[Текст чата] Синхронизировано с модулем чата ElvUI, попытка решить ошибки Lua, которые возникают в некоторых случаях.",
			"[Юнит-фреймы] - [Теги] Оптимизирована проблема с тем, что событие healabsorbs-autohide не срабатывает своевременно.",
			"[Подсказки] - [Прогресс заданий] Добавлена поддержка отображения отслеживания прогресса.",
		},
	},
}
