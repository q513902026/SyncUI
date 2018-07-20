
local maxLootButtons = 6
local buttonSize = 38

local function UpdateButton(self)
	local index = self:GetID()

	if LootSlotHasItem(index) then
		local texture, item, count,currency, quality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(index)

		if texture then
			self:SetNormalTexture(texture)
			self:SetText(item)
		end
		
		if count > 1 then
			self.Count:SetText(count)
		else
			self.Count:SetText("")
		end
		
		if quality > 1 then
			local c = ITEM_QUALITY_COLORS[quality]
			self.Quality:SetVertexColor(c.r,c.g,c.b)
			self.Quality:Show()
		else
			self.Quality:Hide()
		end
		
		self:Show()
	else
		self:Hide()
	end
end

local function UpdateAllButtons(self)
	for i = 1, maxLootButtons do
		local button = self["Button"..i]
		
		UpdateButton(button)
	end
	
	SyncUI_LootFrame_OnScrollUpdate(self.ScrollFrame)
end

local function UpdateFrameSize(self)
	local padding = 30
	local width, height = 210, 0
	local numItems = GetNumLootItems()
	local numItemsPerPage
	
	if numItems > maxLootButtons then
		numItemsPerPage = maxLootButtons
	else
		numItemsPerPage = numItems
	end
	
	height = height + numItemsPerPage * buttonSize + padding
	
	self:SetSize(width,height)	
end


function SyncUI_LootFrame_OnLoad(self)
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_SLOT_CHANGED")

	SyncUI_DisableFrame(LootFrame)
	SyncUI_RegisterDragFrame(self,LOOT,nil,true)

	tinsert(UISpecialFrames,self:GetName())
end

function SyncUI_LootFrame_OnEvent(self, event, ...)
	if XLootFrame then return end
	
	if event == "LOOT_OPENED" then
		local autoLoot = ...;
		
		SyncUI_LootFrame_Show(self)
		
		if not self:IsShown() then
			CloseLoot(autoLoot == 0)
		end
	end
	
	if event == "LOOT_SLOT_CLEARED" or event == "LOOT_SLOT_CHANGED" then
		UpdateAllButtons(self)
	end

	if event == "LOOT_CLOSED" then
		StaticPopup_Hide("LOOT_BIND")
		HideUIPanel(self)
	end
end

function SyncUI_LootFrame_Show(self)
	if GetCVar("lootUnderMouse") == "1" then
		local x, y = GetCursorPosition()

		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		local posX = x - 175
		local posY = y + 25

		if GetNumLootItems() > 0 then
			posX = x - 40
			posY = y + 55
			posY = posY + 40
		end

		if posY < 350  then
			posY = 350
		end

		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY)
		self:GetCenter()
		self:Raise()
		self:Show()
	else
		SyncUI_LoadFramePosition(self)
		ShowUIPanel(self)
	end
	
	UpdateAllButtons(self)
	UpdateFrameSize(self)
end

function SyncUI_LootFrame_OnHide(self)
	CloseLoot()
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	MasterLooterFrame:Hide()
end

function SyncUI_LootFrame_OnScrollUpdate(self)
	local offset = FauxScrollFrame_GetOffset(self)
	local parent = self:GetParent()
	local size = GetNumLootItems()
	
	SyncUI_ScrollFrame_Update(self, size, maxLootButtons, buttonSize)
	
	for i = 1, maxLootButtons do
		local button = parent["Button"..i]
		local newID = offset + i
		
		button:SetID(newID)
		UpdateButton(button)
	end
end

function SyncUI_LootButton_OnClick(self, button)
	-- Close any loot distribution confirmation windows
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	MasterLooterFrame:Hide()
	
	local method, LMParty, LMRaid = GetLootMethod()

	if method == "master" then
		local isLootMaster

		if IsInRaid() then
			if UnitGUID("raid"..LMRaid) == UnitGUID("player") then
				isLootMaster = true
			end
		elseif IsInGroup() and LMParty == 0 then
			isLootMaster = true
		end

		if isLootMaster then
			ToggleDropDownMenu(1, nil, GroupLootDropDown, self, 0, 0)
		end
	end
	
	LootSlot(self:GetID())
end

function SyncUI_LootButton_OnEnter(self)
	local slot = self:GetID()
	local slotType = GetLootSlotType(slot)
	
	if slotType == LOOT_SLOT_ITEM then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	if slotType == LOOT_SLOT_CURRENCY then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootCurrency(slot)
		CursorUpdate(self)
	end
end
