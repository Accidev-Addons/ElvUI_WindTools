local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[414] = {
	RELEASE_DATE = "2026/03/07",
	IMPORTANT = {
		["enUS"] = {
			"The minimum supported ElvUI version has been raised to 15.08.",
			"Updated the LibRangeCheck-3.0 library, which can now detect distances more accurately.",
			"Adjusted the names and descriptions of the quest turn-in related options. Since the default setting is not to automatically turn in quests that are account incomplete and non-daily, you will need to manually enable the conditions in the settings for it to take effect on all quests.",
			"Improved the anti-censorship feature in the Simplified Chinese client, which should no longer pollute the friends list and cause the housing access feature to be unusable.",
			"[Extra Item Bar] The group of food sold by vendors 'FOODVENDOR' no longer includes the TWW foods.",
		},
		["ruRU"] = {
			"Минимальная поддерживаемая версия ElvUI повышена до 15.08.",
			"Обновлена библиотека LibRangeCheck-3.0, которая теперь может более точно определять расстояния.",
			"Изменены названия и описания параметров, связанных со сдачей заданий. Поскольку по умолчанию задания, не выполненные на учетной записи и не являющиеся ежедневными, не сдаются автоматически, Вам потребуется вручную включить соответствующие условия в настройках, чтобы они вступили в силу для всех заданий.",
			"Улучшена функция анти-цензуры в клиенте на упрощенном китайском языке, которая больше не должна загрязнять список друзей и делать функцию доступа к жилью недоступной.",
			"[Дополнительная панель предметов] Группа еды, продаваемой торговцами 'FOODVENDOR', больше не включает еду из TWW.",
		},
	},
	NEW = {
		["enUS"] = {
			"Added a new module [Combat] - [Destroy Totem], which supports binding keys or using macro commands to cancel totems.",
			"[Skins] Added the Angleur skin.",
			"[Event Tracker] Added tracking for some Midnight weekly quests and events.",
			"[Objective Tracker] Added the option to display quest titles and tracker headers in uppercase. This will only take effect in non-Asian locales.",
			"[Game Bar] Added the option to display the hearthstone binding location in the tooltip. Enabled by default.",
			"[Extra Item Bar] Added a new group for fishing-related items in Midnight.",
		},
		["ruRU"] = {
			"Добавлен новый модуль [Бой] - [Уничтожить тотем], который поддерживает привязку клавиш или использование макрокоманд для отмены тотемов.",
			"[Скины] Добавлен скин Angleur.",
			"[Отслеживатель событий] Добавлено отслеживание некоторых еженедельных заданий и событий Полуночи.",
			"[Отслеживатель задач] Добавлена опция отображения названий заданий и заголовков трекера в верхнем регистре. Это будет работать только в неазиатских локалях.",
			"[Игровая панель] Добавлена опция отображения места привязки камня возвращения в подсказке. Включено по умолчанию.",
			"[Дополнительная панель предметов] Добавлена новая группа для предметов, связанных с рыбалкой в Полуночи.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Skins] Fixed the compatibility with the latest version of World Quest Tab.",
			"[Skins] Improved the skinning of the custom anti-error tooltip from World Quest Tab by suppressing the display of the description text in it, which will adapt the skinning for Blizzard's default tooltip to the custom tooltip.",
			"[Minimap Button] Improved compatibility with the RestedXP Guides addon, which should no longer cause a blank area to appear.",
			"[Shield] Improved the display of shield textures.",
			"[Game Bar] Adjusted the default setting for middle mouse button click to teleport to Arcantina.",
			"[Game Bar] Now the icon of Random Hearthstone will show the next randomly selected hearthstone's icon instead of a fixed question mark icon.",
			"[Extra Item Bar] Added more openable items.",
			"[Extra Item Bar] Updated the list of some engineering items in UTILITY.",
			"[Extra Item Bar] Fixed the issue of incorrect item quality icons for the Midnight crafted items.",
		},
		["ruRU"] = {
			"[Скины] Исправлена совместимость с последней версией World Quest Tab.",
			"[Скины] Улучшена обработка пользовательской подсказки от ошибок World Quest Tab путем подавления отображения текста описания в ней, что позволит адаптировать оформление подсказки Blizzard по умолчанию к пользовательской подсказке.",
			"[Кнопка миникарты] Улучшена совместимость с аддоном RestedXP Guides, который больше не должен вызывать появление пустой области.",
			"[Щит] Улучшено отображение текстур щита.",
			"[Игровая панель] Настройка по умолчанию для нажатия средней кнопки мыши изменена на телепортацию в Аркантину.",
			"[Игровая панель] Теперь иконка Случайного Камня возвращения будет показывать иконку следующего случайно выбранного камня возвращения вместо фиксированной иконки вопросительного знака.",
			"[Дополнительная панель предметов] Добавлено больше открываемых предметов.",
			"[Дополнительная панель предметов] Обновлен список некоторых инженерных предметов в UTILITY.",
			"[Дополнительная панель предметов] Исправлена проблема с неправильными иконками качества предметов для предметов, созданных в Полуночи.",
		},
	},
}
