local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[434] = {
	RELEASE_DATE = "2026/11/28",
	NEW = {
		["enUS"] = {
			"[Quest Progress] Battle Pass quests show their progress at the top of the screen in the WindTools format, with the quest name and the count. Daily and weekly quests have separate toggles. The quest description is off by default and can be turned on. Quests that require more than the set amount are not shown, so long counters do not spam the screen.",
		},
		["ruRU"] = {
			"[Прогресс заданий] Задания боевого пропуска показывают прогресс вверху экрана в формате WindTools: название задания и счётчик. Для ежедневных и еженедельных заданий есть отдельные переключатели. Описание задания по умолчанию выключено, его можно включить. Задания, которые требуют больше заданного числа, не показываются, чтобы длинные счётчики не засоряли экран.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Quest Progress] A finished objective is marked \"(Completed)\".",
			"[Quest Progress] The default message about killed players for a quest is hidden like the other quest messages.",
			"[Skins] The WindTools shadow is added to the windows that had none: Spellbook, Talents, Battle Pass, Guild, Shop, PvP, professions, quest details, Raid Finder, leaderboards and other Sirus windows.",
			"[Skins] Tabs get the shadow too: Talents and Glyphs, the Spellbook, all five Inspect tabs, Macros, Interface Options, the Bank and the tabs of the windows above.",
			"[Extra Item Bar] Potions, flasks and food are taken from your bags by item type and sorted from the highest item level. You no longer need a fixed list of items for them. The Crafted Food module is now called Food.",
			"[Extra Item Bar] A quest item stays on the bar while it is in your bags, even after the quest no longer shows it.",
			"[Extra Item Bar] The tabard slot (19) is supported in the equipment module and the slot filter.",
			"[Extra Item Bar] An item is shown on a bar only once, even if several modules include it.",
			"[Extra Item Bar] The bar does not fade out while the mouse is over the bar or the gaps between its buttons, and the global fade also works when you hover the bar.",
			"[Extra Item Bar] After you delete an item from the custom list, the selection is cleared, so a second click does not delete the next item.",
			"[Extra Item Bar] By default the third bar shows your custom items first, then the food.",
		},
		["ruRU"] = {
			"[Прогресс заданий] Выполненная цель помечается «(Завершено)».",
			"[Прогресс заданий] Стандартное сообщение об убитых игроках для задания скрывается, как и остальные сообщения заданий.",
			"[Скины] Тень WindTools появилась на окнах, где её не было: книга заклинаний, таланты, боевой пропуск, гильдия, магазин, PvP, профессии, описание задания, поиск рейда, таблицы лидеров и другие окна Sirus.",
			"[Скины] Вкладки тоже получили тень: «Таланты» и «Символы», книга заклинаний, все пять вкладок осмотра, макросы, настройки интерфейса, банк и вкладки окон выше.",
			"[Панель предметов] Зелья, настои и еда берутся из сумок по типу предмета и сортируются от самого высокого уровня предмета. Фиксированный список предметов для них больше не нужен. Модуль «Крафтовая еда» теперь называется «Еда».",
			"[Панель предметов] Предмет задания остаётся на панели, пока лежит в сумках, даже если задание его больше не показывает.",
			"[Панель предметов] Модуль экипировки и фильтр слотов поддерживают слот гербовой накидки (19).",
			"[Панель предметов] Предмет показывается на панели один раз, даже если его включают несколько модулей.",
			"[Панель предметов] Панель не гаснет, пока курсор над ней или над промежутками между кнопками, а общее затухание работает и при наведении на саму панель.",
			"[Панель предметов] После удаления предмета из своего списка выбор сбрасывается, и второй клик не удаляет следующий предмет.",
			"[Панель предметов] По умолчанию третья панель показывает сначала свои предметы, затем еду.",
		},
	},
}
