local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[404] = {
	RELEASE_DATE = "2025/11/20",
	IMPORTANT = {
		["enUS"] = {
			"Minimum supported ElvUI version raise to 14.03.",
			"Add 6 new sound effects: WT Accept, WT Complete, WT Win, WT Simple, WT Clear, WT Success. You can use these sound effects in the WindTools or other addons like BigWigs.",
			"Add Legion Remix Phase 4 Mythic+ dungeon data.",
			"[Skins] Remove TinyInspect skin, you can use the new Inspect module as a replacement.",
			"[Event Tracker] After considering maintenance cost and actual usage, the Dragonflight Fishing Net support has been removed.",
		},
		["ruRU"] = {
			"Минимальная поддерживаемая версия ElvUI повышена до 14.03.",
			"Добавлены 6 новых звуковых эффектов: WT Accept, WT Complete, WT Win, WT Simple, WT Clear, WT Success. Вы можете использовать эти звуковые эффекты в WindTools или других аддонах, таких как BigWigs.",
			"Добавлены данные подземелий Легиона Ремикс Фазы 4 для мифических ключей.",
			"[Скины] Удален скин TinyInspect, в качестве замены можно использовать новый модуль осмотра.",
			"[Трекер событий] После учета затрат на обслуживание и фактического использования поддержка рыболовной сети Dragonflight была удалена.",
		},
	},
	NEW = {
		["enUS"] = {
			"[Skins] Add Murlok Export skin.",
			"[Skins] Re-add NetEase Meeting Stone skin. The previous skin code has been significantly rewritten and optimized.",
			"[Skins] Separate ElioteDropDownMenu library skin from Simple Addon Manager skin.",
		},
		["ruRU"] = {
			"[Скины] Добавлен скин Murlok Export.",
			"[Скины] Повторно добавлен скин NetEase Meeting Stone. Предыдущий код скина был значительно переписан и оптимизирован.",
			"[Скины] Отделен скин библиотеки ElioteDropDownMenu от скина Simple Addon Manager.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Skins] Redesign Blizzard bag and bank skins, and optimize ElvUI skin handling to resolve border rendering issues when mixing with other addons like Zygor.",
			"[Skins] Optimize friend list skin.",
			"[Skins] Optimize event tracker skin.",
			"[Skins] Fix text styling in buff icons of the cooldown manager.",
			"[Move Frames] Optimize movement of friend list subframes.",
			"[Combat Alert] Slightly adjust the starting position of combat text.",
			"[Extra Item Bar] Update the list of items that can be enabled.",
			"[Event Tracker] Optimize bar color display logic, now all bars show as gray when waiting.",
			"[Event Tracker] Optimize notification text color rendering logic, event names will be uniformly yellow, time parts will be uniformly green.",
			"[Announcements]-[Quests] Improve the stability and accuracy of quest status updates, now announce when world quests are completed.",
			"[Progress] Optimize world quest completion progress trigger logic, now display progress more promptly after quest completion.",
			"[Turn In] Optimize auto turn-in logic for certain quests, especially for the handling of Legion Remix daily quests.",
			"[Rectangle Minimap] Further improve compatibility with addons using the HereBeDragons-Pins library, allowing for stricter hiding of icons that exceed the boundaries of the rectangle minimap.",
			"[LFG List] Optimize the layout of the right panel to better display when there are many dungeons.",
			"[Game Bar] When loading the NetEase Meeting Stone, the LFG buttons will now automatically change to left-click to open the Meeting Stone and right-click to open the default Blizzard LFG interface.",
		},
		["ruRU"] = {
			"[Скины] Переработаны скины сумок и банка Blizzard, а также оптимизирована обработка скинов ElvUI для решения проблем с рендерингом границ при использовании с другими аддонами, такими как Zygor.",
			"[Скины] Оптимизирован скин списка друзей.",
			"[Скины] Оптимизирован скин трекера событий.",
			"[Скины] Исправлен стиль текста в иконках баффов в Трекере восстановлений.",
			"[Перемещение фреймов] Оптимизировано перемещение подфреймов списка друзей.",
			"[Боевое оповещение] Скорректирована начальная позиция текста боя.",
			"[Дополнительная панель предметов] Обновлен список предметов, которые можно включить.",
			"[Трекер событий] Оптимизирована логика отображения цвета полос, теперь все полосы отображаются серым при ожидании.",
			"[Трекер событий] Оптимизирована логика рендеринга цвета текста уведомлений, названия событий будут равномерно желтыми, а временные интервалы - зелеными.",
			"[Объявления]-[Задания] Повышена стабильность и точность обновлений статуса заданий, теперь при завершении мировых заданий будет происходить объявление.",
			"[Прогресс] Оптимизирована логика триггера прогресса завершения мировых заданий. Теперь прогресс отображается более оперативно после завершения задания.",
			"[Сдача заданий] Оптимизирована логика автоматической сдачи для определенных заданий, особенно для обработки ежедневных заданий Легиона Ремикс.",
			"[Прямоугольная миникарта] Дополнительно улучшена совместимость с аддонами, использующими библиотеку HereBeDragons-Pins, что позволяет более строго скрывать значки, выходящие за пределы прямоугольной миникарты.",
			"[Список поиска группы] Оптимизирован макет правой панели для лучшего отображения при большом количестве подземелий.",
			"[Игровая панель] При загрузке NetEase Meeting Stone кнопки LFG теперь автоматически изменяются на левый клик для открытия Камня встреч и правый клик для открытия стандартного интерфейса LFG Blizzard.",
		},
	},
}
