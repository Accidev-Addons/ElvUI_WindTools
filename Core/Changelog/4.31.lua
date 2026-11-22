local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[431] = {
	RELEASE_DATE = "2026/11/22",
	IMPROVEMENT = {
		["enUS"] = {
			"[Inspect] The gear panels now appear when you inspect a player who is not in your group. Before, they appeared only for members of your group or raid. If the server is slow to send the item level, the panels open after a second and the item level is filled in when it arrives.",
			"[Inspect] Items that the game has not loaded yet are no longer shown as Not Equipped. The panel requests them from the server and redraws when they arrive, and the stats comparison counts them.",
			"[Inspect] When you inspect yourself, one panel is shown instead of two copies with a comparison against yourself.",
			"[Inspect] The specialization of an inspected player outside your group is shown. This needs ElvUI 9.09.22.",
			"[Objective Tracker] Battle Pass quests and quests for returning players are styled like the other tracker sections.",
			"[Options] A click on a tab no longer presses a hidden button that was scrolled under the tabs, for example on the Reset page. This is fixed in ElvUI. Update ElvUI to 9.09.22.",
		},
		["ruRU"] = {
			"[Осмотр] Панели снаряжения теперь появляются при осмотре игрока не из вашей группы. Раньше они появлялись только для участников группы или рейда. Если сервер долго не присылает уровень предметов, панели открываются через секунду, а уровень предметов подставляется, когда придёт.",
			"[Осмотр] Предметы, которые игра ещё не загрузила, больше не показываются как «Не оборудовано». Панель запрашивает их у сервера и перерисовывается, когда они приходят. Сравнение характеристик их учитывает.",
			"[Осмотр] При осмотре себя показывается одна панель, а не две копии со сравнением с собой.",
			"[Осмотр] Специализация осматриваемого игрока показывается и для игроков не из вашей группы. Нужен ElvUI 9.09.22.",
			"[Трекер заданий] Задания боевого пропуска и задания для вернувшихся игроков оформлены так же, как остальные разделы трекера.",
			"[Настройки] Клик по вкладке больше не попадает в скрытую кнопку, которая при прокрутке уехала под вкладки, например на странице «Сброс». Исправлено в ElvUI. Обновите ElvUI до 9.09.22.",
		},
	},
}
