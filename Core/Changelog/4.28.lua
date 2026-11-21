local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[428] = {
	RELEASE_DATE = "2026/11/21",
	IMPORTANT = {
		["enUS"] = {
			"[Turn In] Select Reward is removed because ElvUI already does it: use General > Blizzard Improvements > Quests > Select Quest Reward. Get Best Reward is now a separate option and needs ElvUI 9.09.17 or newer. With an older ElvUI it does nothing.",
		},
		["ruRU"] = {
			"[Сдача заданий] «Выбрать награду» удалена, потому что это уже делает ElvUI: «Общие → Улучшения Blizzard → Задания → Выбирать награду за задание». «Сдавать с лучшей наградой» теперь отдельная опция и работает с ElvUI 9.09.17 и новее. Со старым ElvUI она ничего не делает.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Turn In] Get Best Reward takes the same most valuable reward as the ElvUI gold coin (the sell price times the stack size) and waits for item data before completing the quest. Without Get Best Reward, Turn In does not pick a reward when there are several.",
			"[Rectangle Minimap] The map no longer moves off its mover at the top or bottom screen edge. The mover stops where the whole map still fits on screen.",
			"[Rectangle Minimap] With a minimap scale other than 100%, the border, the minimap data panel and the location text stay aligned with the visible map.",
			"[Rectangle Minimap] If ElvUI rebuilds the minimap during combat, the rectangular shape comes back right after combat.",
			"[Rectangle Minimap] Enabling the module in the options works without a reload, and changing its options no longer causes a Lua error when the ElvUI minimap is disabled.",
			"[Rectangle Minimap] The ElvUI Location Text mode Above Minimap is supported: the location panel sits right above the visible map, and the mover includes it.",
			"[Extend Merchant Pages] The module no longer changes MERCHANT_ITEMS_PER_PAGE and fills the extra slots the same way the client does: currency prices no longer overlap neighbouring slots, names use quality colours, and paging, tooltips and buying work on every page. The buyback slot sits in the bottom right corner of the frame.",
			"[Extend Merchant Pages] GnomishVendorShrinker compatibility: slots are no longer drawn over its list, and GVS fills the whole widened frame in several columns (requires a GVS version with column support).",
			"[Skins] The group finder eye button in the objective tracker is no longer covered by the button background.",
			"[Skins] Quest item icons in the objective tracker are no longer covered by their backdrop.",
			"[Skins] The selected entry fill in the ElvUI options tree no longer covers its text.",
		},
		["ruRU"] = {
			"[Сдача заданий] «Сдавать с лучшей наградой» берёт тот же самый дорогой предмет, что помечен монеткой ElvUI (цена продажи с учётом количества), и ждёт данных предметов перед сдачей задания. Без этой опции при нескольких наградах модуль награду не выбирает.",
			"[Прямоугольная миникарта] У верхнего и нижнего края экрана карта больше не съезжает с фиксатора. Фиксатор останавливается там, где карта ещё целиком помещается на экране.",
			"[Прямоугольная миникарта] При масштабе миникарты не 100 % рамка, панель инфотекстов и название локации больше не отстают от видимой части карты.",
			"[Прямоугольная миникарта] Если ElvUI перестроил миникарту в бою, прямоугольная форма возвращается сразу после боя.",
			"[Прямоугольная миникарта] Включение модуля в настройках работает без перезагрузки интерфейса, а изменение его настроек больше не вызывает ошибку Lua, если миникарта ElvUI отключена.",
			"[Прямоугольная миникарта] Поддержан режим ElvUI «Текст локации: Над миникартой»: панель с названием локации стоит вплотную над видимой картой, а фиксатор её учитывает.",
			"[Расширение страниц торговца] Модуль больше не меняет MERCHANT_ITEMS_PER_PAGE и заполняет дополнительные плитки так же, как клиент: цены в валюте не налезают на соседние плитки, имена окрашены по качеству, листание, подсказки и покупка работают на всех страницах. Слот выкупа стоит в правом нижнем углу окна.",
			"[Расширение страниц торговца] Совместимость с GnomishVendorShrinker: плитки не рисуются поверх списка, а GVS занимает всё расширенное окно в несколько колонок (нужна версия GVS с поддержкой колонок).",
			"[Скины] Значок поиска группы в трекере заданий больше не закрыт фоном кнопки.",
			"[Скины] Иконка предмета задания в трекере больше не закрыта подложкой.",
			"[Скины] Заливка выбранного пункта в дереве настроек ElvUI больше не закрывает его текст.",
		},
	},
}
