local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[421] = {
	RELEASE_DATE = "2026/11/03",
	IMPORTANT = {
		["enUS"] = {
			"This build is adapted for Sirus (WotLK 3.3.5a, DF UI) and works only with ElvUI for Sirus 9.09.14 or newer.",
			"Modules and skins that exist only on retail were removed, including the keystone tooltip, the party keystone panel, the Mythic+ score in the group finder, the Inspect enchant icons and the Auctionator skin.",
			"Libraries now come from ElvUI (LibDeflate, LibRangeCheck). Profile import and export work again.",
		},
		["ruRU"] = {
			"Эта сборка адаптирована для Sirus (WotLK 3.3.5a, DF UI) и работает только с ElvUI для Sirus 9.09.14 или новее.",
			"Модули и скины, которые существуют только на ретейле, удалены, в том числе ключ в подсказке, панель ключей группы, рейтинг Mythic+ в поиске группы, значки зачарований в осмотре и скин Auctionator.",
			"Библиотеки берутся из ElvUI (LibDeflate, LibRangeCheck). Импорт и экспорт профилей снова работают.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Renegades] The third faction is recognized in chat bar channels, the friend list, contacts and tooltip faction icons.",
			"[Instance Difficulty] Shows Sirus dungeon and raid difficulties and the active Mythic+ keystone.",
			"[Chat Text] GM flags, plugin icons and the Renegade language header from ElvUI are kept.",
			"[Already Known] Learned items are highlighted at merchants by the Sirus server flag, and in buyback by the Already known tooltip line.",
			"[Move Frames] The spellbook, quest log, guild, group finder, PvP, options, shop, pet stable, wardrobe, professions and battle pass windows can be moved.",
			"[Minimap Buttons] If ElvUI and WindTools both collect minimap buttons, a dialog at login asks which one keeps them.",
		},
		["ruRU"] = {
			"[Ренегаты] Третья фракция учитывается в каналах панели чата, списке друзей, контактах и иконках фракций в подсказках.",
			"[Сложность подземелья] Показывает сложности подземелий и рейдов Sirus и активный ключ Mythic+.",
			"[Текст чата] Метки ГМ, иконки плагинов и заголовок языка ренегатов из ElvUI сохраняются.",
			"[Уже изучено] У торговца изученные предметы подсвечиваются по флагу сервера Sirus, в выкупе — по строке «Уже известно» в подсказке.",
			"[Перемещение окон] Двигаются книга заклинаний, журнал заданий, гильдия, поиск группы, PvP, настройки, магазин, стойла, гардероб, профессии и боевой пропуск.",
			"[Кнопки мини-карты] Если кнопки собирают и ElvUI, и WindTools, при входе появляется окно выбора, какой из них их оставит.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Game Bar] Character, Spellbook, Talents, Professions and Shop open through the Sirus micro buttons, so spells and talents are not blocked afterwards.",
			"[Quest] Turn In, Quest Progress and Achievement Tracker rebuilt on the 3.3.5a API.",
			"[Item] Extra Item Bar, Inspect, Contacts and Fast Loot rebuilt on the 3.3.5a API; the Extra Item Bar and announcements use WotLK items and spells.",
			"[Skins] Only Blizzard and addon frames that exist on Sirus are skinned; AceGUI widget skins apply once the ElvUI options load.",
			"[Information] Our Discord contact; upstream links and credits removed.",
			"[Tags] Class color and class icon tags list only the classes that exist on Sirus.",
			"[Hide Crafter] The hidden crafter line no longer leaves an empty gap in the tooltip.",
		},
		["ruRU"] = {
			"[Игровая панель] Персонаж, книга заклинаний, таланты, профессии и магазин открываются через микрокнопки Sirus, поэтому заклинания и таланты после этого не блокируются.",
			"[Задания] Сдача заданий, прогресс заданий и трекер достижений переписаны под API 3.3.5a.",
			"[Предметы] Панель предметов, осмотр, контакты и быстрый лут переписаны под API 3.3.5a; панель предметов и объявления используют предметы и заклинания WotLK.",
			"[Скины] Оформляются только окна Blizzard и аддонов, которые есть на Sirus; скины виджетов AceGUI применяются после загрузки настроек ElvUI.",
			"[Информация] Наш Discord; ссылки и благодарности оригинального аддона удалены.",
			"[Теги] Теги цвета и значка класса перечисляют только классы, которые есть на Sirus.",
			"[Скрыть создателя] Скрытая строка о создателе больше не оставляет пустой промежуток в подсказке.",
		},
	},
}
