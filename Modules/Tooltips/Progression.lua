local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local T = W.Modules.Tooltips

local _G = _G
local format = format
local ipairs = ipairs
local select = select
local tinsert = tinsert
local tonumber = tonumber
local wipe = wipe

local ClearAchievementComparisonUnit = ClearAchievementComparisonUnit
local GetAchievementComparisonInfo = GetAchievementComparisonInfo
local GetAchievementInfo = GetAchievementInfo
local GetComparisonStatistic = GetComparisonStatistic
local GetStatistic = GetStatistic
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local SetAchievementComparisonUnit = SetAchievementComparisonUnit
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel

local difficulties = { "H25", "H10", "N25", "N10" }
local tierOrder = { "RS", "ICC", "ToC", "Ulduar" }
local tierNames = {
	RS = L["[ABBR] Ruby Sanctum"],
	ICC = L["[ABBR] Icecrown Citadel"],
	ToC = L["[ABBR] Trial of the Crusader"],
	ToGC = L["[ABBR] Trial of the Grand Crusader"],
	Ulduar = L["Ulduar"],
}

local statistics = {
	RS = {
		{ 4823 },
		{ 4822 },
		{ 4820 },
		{ 4821 },
	},
	ICC = {
		{ 4642, 4656, 4661, 4664, 4667, 4670, 4673, 4676, 4679, 4682, 4685, 4688 },
		{ 4640, 4654, 4659, 4662, 4665, 4668, 4671, 4674, 4677, 4680, 4684, 4686 },
		{ 4641, 4655, 4660, 4663, 4666, 4669, 4672, 4675, 4678, 4681, 4683, 4687 },
		{ 4639, 4643, 4644, 4645, 4646, 4647, 4648, 4649, 4650, 4651, 4652, 4653 },
	},
	ToC = {
		{ 4029, 4035, 4039, 4043, 4047 },
		{ 4030, 4033, 4037, 4041, 4045 },
		{ 4031, 4034, 4038, 4042, 4046 },
		{ 4028, 4032, 4036, 4040, 4044 },
	},
	Ulduar = {
		{},
		{},
		{ 2872, 2873, 2874, 2884, 2885, 2875, 2882, 3256, 3257, 3258, 2879, 2880, 2883, 2881 },
		{ 2856, 2857, 2858, 2859, 2860, 2861, 2868, 2862, 2863, 2864, 2865, 2866, 2869, 2867 },
	},
}

local achievements = {
	RS = {
		{ 4816 },
		{ 4818 },
		{ 4815 },
		{ 4817 },
	},
	ICC = {
		{ 4632, 4633, 4634, 4635, 4584 },
		{ 4628, 4629, 4630, 4631, 4583 },
		{ 4604, 4605, 4606, 4607, 4597 },
		{ 4531, 4528, 4529, 4527, 4530 },
	},
	ToC = {
		{ 3812 },
		{ 3918 },
		{ 3916 },
		{ 3917 },
	},
	Ulduar = {
		{},
		{},
		{ 2887, 2889, 2891, 2893, 3037 },
		{ 2886, 2888, 2890, 2892, 3036 },
	},
}

local cache = {}
local compareGUID

local function GetPlayerAchievement(id)
	return select(4, GetAchievementInfo(id))
end

local function IsDone(value)
	return value == true or (tonumber(value) or 0) > 0
end

local function UpdateProgression(guid, isPlayer)
	local useAchievements = T.profiledb.progression.checkAchievements
	local tiers = useAchievements and achievements or statistics
	local check
	if useAchievements then
		check = isPlayer and GetPlayerAchievement or GetAchievementComparisonInfo
	else
		check = isPlayer and GetStatistic or GetComparisonStatistic
	end

	local data = cache[guid] or {}
	cache[guid] = data
	data.time = GetTime()
	data.achievements = useAchievements

	for _, tier in ipairs(tierOrder) do
		local lines = data[tier] or {}
		wipe(lines)
		data[tier] = lines

		for index, ids in ipairs(tiers[tier]) do
			local killed = 0
			for _, id in ipairs(ids) do
				if IsDone(check(id)) then
					killed = killed + 1
				end
			end

			if killed > 0 then
				local name = (tier == "ToC" and index <= 2) and "ToGC" or tier
				tinsert(lines, format("%s [%s]:", tierNames[name], difficulties[index]))
				tinsert(lines, format("%d/%d", killed, #ids))

				if killed == #ids then
					break
				end
			end
		end
	end

	return data
end

local function AddLines(tt, data)
	local tiers = T.profiledb.progression.tiers
	for _, tier in ipairs(tierOrder) do
		if tiers[tier] then
			local lines = data[tier]
			for i = 1, #lines, 2 do
				tt:AddDoubleLine(lines[i], lines[i + 1], nil, nil, nil, 1, 1, 1)
			end
		end
	end
end

local function RestoreComparison()
	compareGUID = nil
	T:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")

	local comparison = _G.AchievementFrameComparison
	if comparison then
		comparison:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
	end
end

function T:INSPECT_ACHIEVEMENT_READY()
	local guid = compareGUID
	local achievementFrame = _G.AchievementFrame
	if achievementFrame and achievementFrame:IsShown() then
		RestoreComparison()
		return
	end

	UpdateProgression(guid)
	ClearAchievementComparisonUnit()
	RestoreComparison()

	if UnitExists("mouseover") and UnitGUID("mouseover") == guid then
		_G.GameTooltip:SetUnit("mouseover")
	end
end

function T:AddProgression(tt, unit, guid)
	local db = self.profiledb.progression
	if not db.enable or InCombatLockdown() then
		return
	end

	if UnitIsUnit(unit, "player") then
		if db.checkPlayer then
			AddLines(tt, UpdateProgression(guid, true))
		end

		return
	end

	if (UnitLevel(unit) or 0) < W.MaxLevelForPlayerExpansion then
		return
	end

	local data = cache[guid]
	local achievementFrame = _G.AchievementFrame
	local frameShown = achievementFrame and achievementFrame:IsShown()

	if data and data.achievements == db.checkAchievements and (frameShown or GetTime() - data.time < 600) then
		AddLines(tt, data)
	elseif not frameShown and guid ~= compareGUID then
		compareGUID = guid
		self:RegisterEvent("INSPECT_ACHIEVEMENT_READY")

		local comparison = _G.AchievementFrameComparison
		if comparison then
			comparison:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")

			if not self:IsHooked(achievementFrame, "OnShow") then
				self:SecureHookScript(achievementFrame, "OnShow", RestoreComparison)
			end
		end

		ClearAchievementComparisonUnit()
		SetAchievementComparisonUnit(unit)
	end
end

T:AddInspectInfoCallback(1, "AddProgression", true)
