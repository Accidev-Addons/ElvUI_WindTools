local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[421] = {
	RELEASE_DATE = "2026/11/02",
	IMPORTANT = {
		["enUS"] = {
			"This build is adapted for Sirus (WotLK 3.3.5a, DF UI) and works only with ElvUI for Sirus 9.09.13 or newer.",
			"Modules and skins that exist only on retail were removed.",
			"Libraries now come from ElvUI (LibDeflate, LibRangeCheck). Profile import and export work again.",
		},
		["ruRU"] = {
			"Эта сборка адаптирована для Sirus (WotLK 3.3.5a, DF UI) и работает только с ElvUI для Sirus 9.09.13 или новее.",
			"Модули и скины, которые существуют только на ретейле, удалены.",
			"Библиотеки берутся из ElvUI (LibDeflate, LibRangeCheck). Импорт и экспорт профилей снова работают.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Renegades] The third faction is recognized in chat bar channels, the friend list, contacts and tooltip faction icons.",
			"[Instance Difficulty] Shows Sirus dungeon and raid difficulties and the active Mythic+ keystone.",
			"[Chat Text] GM flags, plugin icons and the Renegade language header from ElvUI are kept.",
		},
		["ruRU"] = {
			"[Ренегаты] Третья фракция учитывается в каналах панели чата, списке друзей, контактах и иконках фракций в подсказках.",
			"[Сложность подземелья] Показывает сложности подземелий и рейдов Sirus и активный ключ Mythic+.",
			"[Текст чата] Метки ГМ, иконки плагинов и заголовок языка ренегатов из ElvUI сохраняются.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Game Bar] Character, Spellbook, Talents, Professions and Shop open through the Sirus micro buttons, so spells and talents are not blocked afterwards.",
			"[Quest] Turn In, Quest Progress and Achievement Tracker rebuilt on the 3.3.5a API.",
			"[Item] Extra Item Bar, Inspect, Contacts and Fast Loot rebuilt on the 3.3.5a API; the Extra Item Bar and announcements use WotLK items and spells.",
			"[Skins] Only Blizzard and addon frames that exist on Sirus are skinned; AceGUI widget skins apply once the ElvUI options load.",
			"[Information] Our Discord contact; upstream links and credits removed.",
		},
		["ruRU"] = {
			"[Игровая панель] Персонаж, книга заклинаний, таланты, профессии и магазин открываются через микрокнопки Sirus, поэтому заклинания и таланты после этого не блокируются.",
			"[Задания] Сдача заданий, прогресс заданий и трекер достижений переписаны под API 3.3.5a.",
			"[Предметы] Панель предметов, осмотр, контакты и быстрый лут переписаны под API 3.3.5a; панель предметов и объявления используют предметы и заклинания WotLK.",
			"[Скины] Оформляются только окна Blizzard и аддонов, которые есть на Sirus; скины виджетов AceGUI применяются после загрузки настроек ElvUI.",
			"[Информация] Наш Discord; ссылки и благодарности оригинального аддона удалены.",
		},
	},
}
