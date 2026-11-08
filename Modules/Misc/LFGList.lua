local W, F, E, L = unpack((select(2, ...))) ---@type WindTools, Functions, ElvUI, LocaleTable
local LL = W:NewModule("LFGList", "AceHook-3.0", "AceEvent-3.0") ---@class LFGList : AceModule, AceHook-3.0, AceEvent-3.0
local LFGPI = W.Utilities.LFGPlayerInfo
local LSM = E.Libs.LSM

local tinsert = tinsert
local tremove = tremove

local IsAddOnLoaded = IsAddOnLoaded

local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_LFGList_GetSearchResultPlayerInfo = C_LFGList.GetSearchResultPlayerInfo

---Reskins and customizes role icons in LFG (Looking for Group) lists with various visual enhancements.
---When role is nil, the icon and its elements are hidden by setting alpha to 0.
---@param parent Frame? The parent frame that contains the icon. Required for leader indicator and class line features.
---@param icon Texture The texture object representing the role icon to be reskinned.
---@param role "TANK" | "HEALER" | "DAMAGER" | nil The player's role. If nil, the icon will be hidden.
---@param data [ClassFile, string, boolean]? Optional cached data containing [class, specialization, isLeader] information.
function LL:ReskinIcon(parent, icon, role, data)
	local class, spec, isLeader
	if data then
		class, spec, isLeader = data[1], data[2], data[3]
	end

	if role then
		if self.db.icon.reskin then
			-- if not class and spec info, use square style instead
			local pack = self.db.icon.pack
			if pack == "SPEC" and (not class or not spec) then
				pack = "SQUARE"
			end

			if pack == "SQUARE" then
				icon:SetTexture(W.Media.Textures.ROLES)
				icon:SetTexCoord(F.GetRoleTexCoord(role))
			elseif pack == "SPEC" then
				local tex = LFGPI.GetIconTextureWithClassAndSpecName(class, spec)
				icon:SetTexture(tex)
				icon:SetTexCoords()
			else
				icon:SetTexture(W.Media.RoleIcons[pack][role])
				icon:SetTexCoord(0, 1, 0, 1)
			end
		end

		icon:Size(self.db.icon.size)

		if self.db.icon.border and not icon.backdrop then
			icon:CreateBackdrop("Transparent")
		end

		icon:SetAlpha(self.db.icon.alpha)
		if icon.backdrop then
			icon.backdrop:SetAlpha(self.db.icon.alpha)
		end
	else
		icon:SetAlpha(0)
		if icon.backdrop then
			icon.backdrop:SetAlpha(0)
		end
	end

	if parent then
		if self.db.icon.leader then
			if not icon.leader then
				local leader = parent:CreateTexture(nil, "OVERLAY")
				leader:SetTexture(W.Media.Icons.leader)
				leader:Size(10, 8)
				leader:Point("BOTTOM", icon, "TOP", 0, 1)
				icon.leader = leader
			end

			icon.leader:SetShown(isLeader)
		end

		-- Create bar in class color behind
		if class and self.db.line.enable then
			if not icon.line then
				local line = parent:CreateTexture(nil, "ARTWORK")
				line:SetTexture(LSM:Fetch("statusbar", self.db.line.tex) or E.media.normTex)
				line:Size(self.db.line.width, self.db.line.height)
				line:Point("TOP", icon, "BOTTOM", self.db.line.offsetX, self.db.line.offsetY)
				icon.line = line
			end

			local color = E:ClassColor(class, false)
			icon.line:SetVertexColor(color.r, color.g, color.b)
			icon.line:SetAlpha(self.db.line.alpha)
		elseif parent and icon.line then
			icon.line:SetAlpha(0)
		end
	end
end

function LL:UpdateEnumerate(Enumerate)
	local button = Enumerate:GetParent():GetParent()

	if not button.resultID then
		return
	end

	local result = C_LFGList_GetSearchResultInfo(button.resultID)
	if not result then
		return
	end

	if self.db.icon.enable then
		---@type table<string, [ClassFile, string, boolean][]>
		local cache = { TANK = {}, HEALER = {}, DAMAGER = {} }

		for i = 1, result.numMembers do
			local playerInfo = C_LFGList_GetSearchResultPlayerInfo(button.resultID, i)
			if playerInfo and cache[playerInfo.assignedRole] then
				local role, class, spec, isLeader =
					playerInfo.assignedRole, playerInfo.classFilename, playerInfo.specName, playerInfo.isLeader
				tinsert(cache[role], { class, spec, isLeader })
			end
		end

		for i = 5, 1, -1 do -- The index of icon starts from right
			local icon = Enumerate["Icon" .. i]
			local roleIcon = icon.RoleIcon
			local classCircle = icon.ClassCircle

			if roleIcon and roleIcon.SetTexture then
				if #cache.TANK > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "TANK", cache.TANK[1])
					tremove(cache.TANK, 1)
				elseif #cache.HEALER > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "HEALER", cache.HEALER[1])
					tremove(cache.HEALER, 1)
				elseif #cache.DAMAGER > 0 then
					self:ReskinIcon(Enumerate, roleIcon, "DAMAGER", cache.DAMAGER[1])
					tremove(cache.DAMAGER, 1)
				else
					self:ReskinIcon(Enumerate, roleIcon)
				end
			end

			if classCircle and self.db.icon.hideDefaultClassCircle then
				classCircle:Hide()
			end
		end
	end
end

function LL:UpdateRoleCount(RoleCount)
	if not self.db.icon.enable then
		return
	end

	if RoleCount.TankIcon then
		self:ReskinIcon(nil, RoleCount.TankIcon, "TANK")
	end
	if RoleCount.HealerIcon then
		self:ReskinIcon(nil, RoleCount.HealerIcon, "HEALER")
	end
	if RoleCount.DamagerIcon then
		self:ReskinIcon(nil, RoleCount.DamagerIcon, "DAMAGER")
	end
end

function LL:Initialize()
	if IsAddOnLoaded("PremadeGroupsFilter") then
		self.StopRunning = L["Premade Groups Filter"]
		return
	end

	self.db = E.private.WT.misc.lfgList
	if not self.db.enable then
		return
	end

	self:SecureHook("LFGListGroupDataDisplayEnumerate_Update", "UpdateEnumerate")
	self:SecureHook("LFGListGroupDataDisplayRoleCount_Update", "UpdateRoleCount")
end

W:RegisterModule(LL:GetName())
