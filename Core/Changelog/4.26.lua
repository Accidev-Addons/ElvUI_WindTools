local W = unpack((select(2, ...))) ---@type WindTools

W.Changelog[426] = {
	RELEASE_DATE = "2026/11/08",
	NEW = {
		["enUS"] = {
			"[Game Bar] The hearthstone lists show only what your character has: hearthstones (including the Winter Veil one and the Ethereal Portal), Return Home (PRIME) and (VIP), Astral Recall, Death Gate, Teleport: Moonglade, mage teleports, mythic dungeon teleports and engineering teleports.",
			"[Game Bar] The hearthstone tooltip lists every teleport you have, with its cooldown.",
			"[Game Bar] Add your own item or spell to the hearthstone lists: type its name or ID, drag it onto the box, or Shift+click its link into the box.",
			"[Game Bar] Choose what the random hearthstone picks from.",
		},
		["ruRU"] = {
			"[Игровая панель] В списках камня возвращения только то, что есть у персонажа: камни возвращения (в том числе Зимнего Покрова и Эфириальный портал), «Возвращение домой» (PRIME) и (VIP), Астральное возвращение, Врата смерти, Телепортация: Лунная поляна, телепорты мага, телепорты эпохальных подземелий и инженерные телепорты.",
			"[Игровая панель] Подсказка камня возвращения показывает все ваши телепорты с откатами.",
			"[Игровая панель] В списки камня возвращения можно добавить свой предмет или заклинание: введите название или ID, перетащите его в поле или вставьте ссылку через Shift+клик.",
			"[Игровая панель] Можно выбрать, из чего выбирает случайный камень возвращения.",
		},
	},
	IMPROVEMENT = {
		["enUS"] = {
			"[Game Bar] The right click of the hearthstone button uses Return Home (VIP) by default, then Return Home (PRIME). If neither the chosen option nor its fallback is available, the button uses the first hearthstone you have instead of showing an error.",
			"[Chat Text] Short channel names no longer cause a Lua error when neither Cell nor Details is installed.",
			"[Game Bar] A second click on Collections, Pet Journal, Toy Box or Profession closes the window. If the collections window is open on another tab, the click switches to the tab of this button.",
		},
		["ruRU"] = {
			"[Игровая панель] ПКМ по камню возвращения по умолчанию использует «Возвращение домой» (VIP), затем (PRIME). Если нет ни выбранного варианта, ни запасного, кнопка берёт первый ваш камень возвращения вместо ошибки.",
			"[Текст чата] Сокращение названий каналов больше не вызывает ошибку Lua, если не установлен ни Cell, ни Details.",
			"[Игровая панель] Повторный клик по «Коллекциям», «Журналу питомцев», «Коллекции игрушек» или «Профессии» закрывает окно. Если коллекции открыты на другой вкладке, клик переключает на вкладку этой кнопки.",
		},
	},
}
