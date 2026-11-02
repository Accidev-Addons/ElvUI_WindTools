local W ---@class WindTools
local F, E ---@type Functions, ElvUI
W, F, E = unpack((select(2, ...)))

local ipairs = ipairs
local pairs = pairs
local type = type

local GetAchievementInfo = GetAchievementInfo
local GetSpellInfo = GetSpellInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = C_Item.GetItemInfo
local setmetatable = setmetatable
local select = select
local tonumber = tonumber

local ItemMethods = {}
ItemMethods.__index = ItemMethods
function ItemMethods:IsItemEmpty() return not self.id end
function ItemMethods:GetItemID() return self.id end
function ItemMethods:GetItemName() return (select(1, GetItemInfo(self.link))) end
function ItemMethods:GetItemIcon() return (select(10, GetItemInfo(self.link))) end
function ItemMethods:GetItemQuality() return (select(3, GetItemInfo(self.link))) end
function ItemMethods:GetCurrentItemLevel() return (select(4, GetItemInfo(self.link))) end
function ItemMethods:GetItemQualityColor()
	return ITEM_QUALITY_COLORS[self:GetItemQuality() or 1]
end
function ItemMethods:GetItemQualityColorRGB()
	local color = self:GetItemQualityColor()
	return color.r, color.g, color.b
end
function ItemMethods:ContinueOnItemLoad(callback)
	if GetItemInfo(self.link) then
		callback()
	else
		C_Item.RequestServerCache(self.id, function()
			if GetItemInfo(self.link) then callback() end
		end)
	end
end
local Item = {}
function Item:CreateFromItemID(itemID)
	return setmetatable({ id = itemID, link = itemID }, ItemMethods)
end
function Item:CreateFromItemLink(link)
	return setmetatable({ id = tonumber(link:match("item:(%d+)")), link = link }, ItemMethods)
end
function Item:CreateFromEquipmentSlot(slot)
	local link = GetInventoryItemLink("player", slot)
	return self:CreateFromItemLink(link or "")
end

local SpellMethods = {}
SpellMethods.__index = SpellMethods
function SpellMethods:IsSpellEmpty() return not GetSpellInfo(self.id) end
function SpellMethods:GetSpellID() return self.id end
function SpellMethods:GetSpellName() return (GetSpellInfo(self.id)) end
function SpellMethods:GetSpellTexture() return (select(3, GetSpellInfo(self.id))) end
function SpellMethods:ContinueOnSpellLoad(callback)
	if not self:IsSpellEmpty() then callback() end
end
local Spell = {}
function Spell:CreateFromSpellID(spellID)
	return setmetatable({ id = spellID }, SpellMethods)
end

---@cast F Functions

---@class AsyncUtility Asynchronous operation utilities
W.Utilities.Async = {}

---@type table<string, table> Cache for loaded items and spells
local cache = {
	item = {},
	spell = {},
}

---@alias ItemCallback fun(itemInstance:ItemMixin)

---Load item data asynchronously and execute callback by item ID
---@param itemID number The item ID to load
---@param callback ItemCallback? Callback function to execute when item is loaded
---@return any? item Cached item data if available
function W.Utilities.Async.WithItemID(itemID, callback)
	if type(itemID) ~= "number" then
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	if cache.item[itemID] then
		cache.item[itemID]:ContinueOnItemLoad(function() callback(cache.item[itemID]) end)
		return cache.item[itemID]
	end

	local itemInstance = Item:CreateFromItemID(itemID)
	if itemInstance:IsItemEmpty() then
		F.Developer.LogDebug("Failed to create item instance for itemID: " .. itemID)
		return
	end

	itemInstance:ContinueOnItemLoad(function()
		callback(itemInstance)
	end)

	cache.item[itemID] = itemInstance

	return itemInstance
end

---Load item data asynchronously and execute callback by item link
---@param itemLink string The item link to load
---@param callback ItemCallback? Callback function to execute when item is loaded
---@return any
function W.Utilities.Async.WithItemLink(itemLink, callback)
	if type(itemLink) ~= "string" then
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	local item = Item:CreateFromItemLink(itemLink)
	if item:IsItemEmpty() then return end
	item:ContinueOnItemLoad(function() callback(item) end)
	return item
end

---@alias SpellCallback fun(spellInstance:SpellMixin)

---Load spell data asynchronously and execute callback
---@param spellID number The spell ID to load
---@param callback SpellCallback? Callback function to execute when spell is loaded
---@return any? spell Cached spell data if available
function W.Utilities.Async.WithSpellID(spellID, callback)
	if type(spellID) ~= "number" then
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	if cache.spell[spellID] then
		callback(cache.spell[spellID])
		return cache.spell[spellID]
	end

	local spellInstance = Spell:CreateFromSpellID(spellID)

	if spellInstance:IsSpellEmpty() then
		F.Developer.LogDebug("Failed to create spell instance for spellID: " .. spellID)
		return
	end

	spellInstance:ContinueOnSpellLoad(function()
		---Execute callback when spell data is loaded
		callback(spellInstance)
	end)

	cache.spell[spellID] = spellInstance

	return spellInstance
end

---Load multiple items asynchronously from a table
---@param itemIDTable table Table containing item IDs
---@param tType string? Type of table processing
---@param callback ItemCallback? Callback for individual items
---@param tableCallback function? Callback for completed table
function W.Utilities.Async.WithItemIDTable(itemIDTable, tType, callback, tableCallback)
	if type(itemIDTable) ~= "table" then
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	if not tableCallback then
		tableCallback = function(...) end
	end

	if type(tableCallback) ~= "function" then
		return
	end

	if type(tType) ~= "string" then
		tType = "value"
	end

	local totalItems = 0
	local completedItems = 0
	local results = {}

	-- Count total items first
	if tType == "list" then
		totalItems = #itemIDTable
	elseif tType == "value" then
		for _ in pairs(itemIDTable) do
			totalItems = totalItems + 1
		end
	elseif tType == "key" then
		for _, value in pairs(itemIDTable) do
			if value then
				totalItems = totalItems + 1
			end
		end
	end

	---Handle completion of individual item loading
	---@param itemID number The item ID that was loaded
	---@param itemInstance any The loaded item instance
	local function onItemComplete(itemID, itemInstance)
		completedItems = completedItems + 1
		results[itemID] = itemInstance

		-- Call individual callback
		callback(itemInstance)

		-- Check if all items are complete
		if completedItems >= totalItems then
			tableCallback(results, itemIDTable)
		end
	end

	if tType == "list" then
		for _, itemID in ipairs(itemIDTable) do
			W.Utilities.Async.WithItemID(itemID, function(itemInstance)
				---Callback wrapper for list processing
				onItemComplete(itemID, itemInstance)
			end)
		end
	elseif tType == "value" then
		for _, itemID in pairs(itemIDTable) do
			W.Utilities.Async.WithItemID(itemID, function(itemInstance)
				---Callback wrapper for value processing
				onItemComplete(itemID, itemInstance)
			end)
		end
	elseif tType == "key" then
		for itemID, value in pairs(itemIDTable) do
			if value then
				W.Utilities.Async.WithItemID(itemID, function(itemInstance)
					---Callback wrapper for key processing
					onItemComplete(itemID, itemInstance)
				end)
			end
		end
	end

	-- Handle empty table case
	if totalItems == 0 then
		tableCallback({}, itemIDTable)
	end
end

---Load multiple spells asynchronously from a table
---@param spellIDTable table Table containing spell IDs
---@param tType string? Type of table processing
---@param callback SpellCallback? Callback for individual spells
---@param tableCallback function? Callback for completed table
function W.Utilities.Async.WithSpellIDTable(spellIDTable, tType, callback, tableCallback)
	if type(spellIDTable) ~= "table" then
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	if not tableCallback then
		tableCallback = function(...) end
	end

	if type(tableCallback) ~= "function" then
		return
	end

	if type(tType) ~= "string" then
		tType = "value"
	end

	local totalItems = 0
	local completedItems = 0
	local results = {}

	-- Count total items first
	if tType == "list" then
		totalItems = #spellIDTable
	elseif tType == "value" then
		for _ in pairs(spellIDTable) do
			totalItems = totalItems + 1
		end
	elseif tType == "key" then
		for _, value in pairs(spellIDTable) do
			if value then
				totalItems = totalItems + 1
			end
		end
	end

	local function onSpellComplete(spellID, spellInstance)
		completedItems = completedItems + 1
		results[spellID] = spellInstance

		-- Call individual callback
		callback(spellInstance)

		-- Check if all spells are complete
		if completedItems >= totalItems then
			tableCallback(results, spellIDTable)
		end
	end

	if tType == "list" then
		for _, spellID in ipairs(spellIDTable) do
			W.Utilities.Async.WithSpellID(spellID, function(spellInstance)
				onSpellComplete(spellID, spellInstance)
			end)
		end
	elseif tType == "value" then
		for _, spellID in pairs(spellIDTable) do
			W.Utilities.Async.WithSpellID(spellID, function(spellInstance)
				onSpellComplete(spellID, spellInstance)
			end)
		end
	elseif tType == "key" then
		for spellID, value in pairs(spellIDTable) do
			if value then
				W.Utilities.Async.WithSpellID(spellID, function(spellInstance)
					onSpellComplete(spellID, spellInstance)
				end)
			end
		end
	end

	-- Handle empty table case
	if totalItems == 0 then
		tableCallback({}, spellIDTable)
	end
end

function W.Utilities.Async.WithItemSlotID(itemSlotID, callback)
	if type(itemSlotID) ~= "number" then
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	local itemInstance = Item:CreateFromEquipmentSlot(itemSlotID)
	if itemInstance:IsItemEmpty() then
		F.Developer.LogDebug("Failed to create item instance for itemSlotID: " .. itemSlotID)
		return
	end

	itemInstance:ContinueOnItemLoad(function()
		callback(itemInstance)
	end)

	return itemInstance
end

local function onAchievementInfoFetched(achievementID, callback, attempt)
	attempt = attempt or 1
	if attempt > 20 then
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	local result = { GetAchievementInfo(achievementID) }
	if not result or not result[1] or not result[2] or result[2] == "" or not result[10] then
		E:Delay(0.1, onAchievementInfoFetched, achievementID, callback, attempt + 1)
		return
	end

	callback(result)
end

function W.Utilities.Async.WithAchievementID(achievementID, callback)
	if type(achievementID) ~= "number" then
		F.Developer.LogDebug("Invalid achievementID: " .. achievementID)
		return
	end

	if not callback then
		callback = function(...) end
	end

	if type(callback) ~= "function" then
		return
	end

	onAchievementInfoFetched(achievementID, callback)
end
