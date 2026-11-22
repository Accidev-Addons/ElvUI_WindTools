local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[430] = {
	RELEASE_DATE = "2026/11/22",
	NEW = {
		["enUS"] = {
			"[LFG List] While your group is listed in the group finder, every member can browse other groups. The Browse Groups button is now shown to all members, not only to the leader, and the group list no longer closes by itself. The button in the list returns you to your raid or group. To turn this off, use Browse Groups While Listed in the LFG List settings.",
			"[Group Info] The player template has a new tag, {{keyRating}}, for the Mythic+ rating of each group member, and a block, {{keyColorStart}}...{{keyColorEnd}}, that colors it with the game's rating colors. Ratings are requested from the server when the tooltip opens. A ready-made template, With Mythic+ rating, is added.",
		},
		["ruRU"] = {
			"[Список LFG] Пока ваша группа стоит в поиске, любой её участник может смотреть другие группы. Кнопка «Просмотр групп» теперь видна не только лидеру, а список групп не закрывается сам. Кнопка в списке возвращает в свой рейд или группу. Отключается в настройках списка LFG, пункт «Просмотр групп из своей группы».",
			"[Информация о группе] В шаблон игрока добавлен тег {{keyRating}} с рейтингом ключей каждого участника и блок {{keyColorStart}}...{{keyColorEnd}}, который красит его цветом из игры. Рейтинг запрашивается у сервера, когда открывается подсказка. Добавлен готовый шаблон «С рейтингом ключей».",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Objective Tracker] The backdrop now covers only the visible part of the tracker. It shrinks when the tracker or one of its sections is collapsed and no longer stretches over the empty area below the objectives.",
			"[Objective Tracker] The X offsets of the backdrop now move the edge their names say: Top Left Offset X moves the left edge, Bottom Right Offset X moves the right edge. Before, they were swapped. Saved offsets are converted, so the backdrop stays where it was.",
			"[Contacts] The contacts button in the mail window moved to the title bar, next to the close button. The Cash on Delivery option no longer overlaps it.",
			"[Skins] Immersion: fixed the error that left the skin half applied. The addon's own gold borders no longer show over the skin.",
			"[Tags] The Lua error caused by [smart-power] and other WindTools tags in unit frame texts is fixed in ElvUI. Update ElvUI to 9.09.21.",
		},
		["ruRU"] = {
			"[Трекер заданий] Фон теперь занимает только видимую часть трекера. Он уменьшается, когда трекер или его раздел свёрнут, и больше не тянется на пустую область под заданиями.",
			"[Трекер заданий] Смещения фона по X теперь двигают тот край, который указан в названии: «Верхний левый угол, смещение X» двигает левый край, «Нижнее правое смещение X» двигает правый. Раньше они были перепутаны. Сохранённые смещения пересчитываются, фон остаётся на месте.",
			"[Контакты] Кнопка контактов в окне почты переехала в заголовок, к кнопке закрытия. Пункт «Наложенный платеж» больше её не перекрывает.",
			"[Скины] Immersion: исправлена ошибка, из-за которой оформление применялось наполовину. Золотые рамки аддона больше не видны поверх оформления.",
			"[Теги] Ошибка Lua из-за [smart-power] и других тегов WindTools в тексте фреймов юнитов исправлена в ElvUI. Обновите ElvUI до 9.09.21.",
		},
	},
}
