local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[405] = {
	RELEASE_DATE = "2025/12/04",
	IMPORTANT = {
		["enUS"] = {
			"Support for WoW 11.2.7.",
			"Minimum supported ElvUI version is now 14.04.",
			"Major update to Spanish translation",
			"Spanish translation is now optimized to support both Spain and Latin America variants.",
		},
		["ruRU"] = {
			"Поддержка WoW 11.2.7.",
			"Минимальная поддерживаемая версия ElvUI теперь 14.04.",
			"Большое обновление испанского перевода",
			"Испанский перевод теперь оптимизирован для поддержки как испанского, так и латиноамериканского вариантов.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Announcement]-[Reset Instance] Add an option to announce instance difficulty changes. Enabled by default.",
			"[Extra Item Bar] Add a new option in the blacklist to exclude all quantum items to avoid accidentally using them. Disabled by default.",
			"[Game Bar] A new option is added in the options to freely swap the left and right clicks of the Group Finder button, now adjusted back to the default left click to open the Blizzard Group Finder.",
			"[Progress] Add progress update sound notifications. Disabled by default.",
		},
		["ruRU"] = {
			"[Объявления]-[Сброс подземелья] Добавлена опция для объявления об изменении сложности подземелья. Включено по умолчанию.",
			"[Дополнительная панель предметов] Добавлена новая опция в черном списке для исключения всех квантовых предметов, чтобы избежать их случайного использования. Отключено по умолчанию.",
			"[Игровая панель] В параметры добавлена новая опция, позволяющая свободно менять местами левый и правый клики кнопки 'Поиска группы'. Теперь вместо щелчка ЛКМ по умолчанию открывается 'Поиск групп Blizzard'.",
			"[Прогресс] Добавлены звуковые уведомления об обновлении прогресса. Отключено по умолчанию.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"Optimize variable taint that may be caused by removing fog of war on the world map.",
			"[Announcement] Use ChatThrottleLib to prevent lag and disconnection issues in extreme cases.",
			"[Context Menu] Add armory support for players on China mainland servers.",
			"[Skins] Optimize the highlight effect of Boss buttons in the Encounter Journal.",
			"[Skins] Optimize the TomTom skin.",
			"[Skins] Optimize the Weakauras skin.",
			"[Move Frames] Added support for new frames in 11.2.7.",
		},
		["ruRU"] = {
			"Оптимизация загрязнения переменных, которое может быть вызвано удалением тумана войны на карте мира.",
			"[Объявления] Используйте ChatThrottleLib, чтобы предотвратить проблемы с задержкой и отключением в экстремальных случаях.",
			"[Контекстное меню] Добавлена поддержка арены для игроков на серверах материкового Китая.",
			"[Скины] Оптимизирован эффект подсветки кнопок боссов в журнале подземелий.",
			"[Скины] Оптимизирован скин TomTom.",
			"[Скины] Оптимизирован скин Weakauras.",
			"[Перемещение фреймов] Добавлена поддержка новых фреймов в версии 11.2.7.",
		},
	},
}
