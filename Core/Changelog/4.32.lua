local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[432] = {
	RELEASE_DATE = "2026/11/23",
	NEW = {
		["enUS"] = {
			"[Game Bar] New Battle Pass button with a crossed-swords icon. Left click opens or closes the Battle Pass, middle click collects completed quests, right click takes all level rewards. The tooltip lists the pass quests and the season end like the Battle Pass datatext, and the corner shows the pass level with \"!\" when a level reward is waiting. By default it replaces the Pet Journal button on the right side of the bar.",
		},
		["ruRU"] = {
			"[Игровая панель] Новая кнопка «Боевой пропуск» со скрещёнными мечами. ЛКМ открывает и закрывает пропуск, СКМ собирает выполненные задания, ПКМ забирает все награды за уровни. Подсказка показывает задания пропуска и конец сезона, как инфотекст боевого пропуска, а в углу виден уровень пропуска и «!», если ждёт награда за уровень. По умолчанию она стоит на месте кнопки «Журнал питомцев» в правой части панели.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Raid Markers] The Russian tooltips explain the ground markers clearly: Shift + Left Click places a marker on the ground, Shift + Right Click removes it, Shift + Click on the cross removes all of them. A typo in a tooltip is fixed.",
			"[Game Bar] Fixed the Random Hearthstone icon.",
			"[Profiles] Export now carries your lists: custom alerts, extra item bar lists, key aliases, hearthstones, chat channel abbreviations, World channels, ignored NPCs, window positions, hidden groups and totem keys. The ElvUI export carries them too, together with the mail contacts.",
			"[Profiles] Import replaces the WindTools settings instead of merging them with yours. A damaged string applies nothing and does not reload the interface.",
			"[Profiles] Fonts and bar textures look the same as for the author of the string, even if your ElvUI font is different.",
			"[Profiles] Import strings with spaces or line breaks are accepted.",
			"[Profiles] After a private settings import, the objective tracker backdrop offsets are no longer swapped a second time. Strings from older versions are converted once.",
			"[Profiles] The string box and the buttons on the Profiles page are labelled, and the page says what the string contains.",
			"[Inspect] The inspect panels hide while the character window is open and come back when it closes.",
			"[Extra Item Bar] A quick profile switch no longer causes a Lua error.",
		},
		["ruRU"] = {
			"[Метки рейда] Подсказки понятно объясняют метки на земле: Shift + ЛКМ ставит метку на землю, Shift + ПКМ убирает её, Shift + клик по крестику убирает все метки. Исправлена опечатка в подсказке.",
			"[Игровая панель] Исправлена иконка случайного камня возвращения.",
			"[Профили] Экспорт переносит ваши списки: свои оповещения, списки панели предметов, псевдонимы клавиш, камни возвращения, сокращения каналов чата, каналы «Мир», игнорируемых НИП, позиции окон, скрытые группы и клавиши тотемов. Экспорт ElvUI переносит их же вместе с контактами почты.",
			"[Профили] Импорт заменяет настройки WindTools, а не смешивает их с вашими. Повреждённая строка ничего не меняет и не перезагружает интерфейс.",
			"[Профили] Шрифты и текстуры полос выглядят так же, как у автора строки, даже если у вас другой шрифт ElvUI.",
			"[Профили] Строки импорта с пробелами и переносами строк принимаются.",
			"[Профили] После импорта приватных настроек смещения подложки трекера заданий больше не меняются местами второй раз. Строки старых версий преобразуются один раз.",
			"[Профили] На странице профилей подписаны поле строки и кнопки, и объяснено, что входит в строку.",
			"[Осмотр] Панели осмотра скрываются, пока открыто окно персонажа, и возвращаются после его закрытия.",
			"[Панель предметов] Быстрая смена профиля больше не вызывает ошибку Lua.",
		},
	},
}
