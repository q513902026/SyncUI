
local _G, tinsert, tremove = _G, table.insert, table.remove
local buttonSize, maxRows, perRow, perBankRow, dropDownItemID = 38, 15, 7, 10
local ItemCategories = {
	[1] = INVENTORY_TOOLTIP,
	[2] = NEW,
	[3] = BAG_FILTER_TRADE_GOODS,
	[4] = BAG_FILTER_CONSUMABLES,
	[5] = BAG_FILTER_EQUIPMENT,
	[6] = BAG_FILTER_EQUIPMENT.." (" .. ITEM_SOULBOUND .. ")",
}
local deleteQueue = {
	[0] = {},
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
}


-- Misc functions
local function SellGreyItems()
	for bagID = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bagID) do
			local itemID = GetContainerItemID(bagID,slot)
			
			if itemID then
				local quality = select(3, GetItemInfo(itemID))
				
				if quality and quality == 0 then
					UseContainerItem(bagID,slot)
				end
			end
		end
	end
end

local function SortContainer(a, b)
	if a == nil or b == nil then
		return false
	end
	
	if a.rarity ~= b.rarity then
		if a.rarity and b.rarity then
			return a.rarity > b.rarity
		elseif a.rarity == nil or b.rarity == nil then
			return a.rarity and true or false
		else
			return false
		end
	elseif a.ilvl ~= b.ilvl then
		if a.ilvl and b.ilvl then
			return a.ilvl > b.ilvl
		elseif a.ilvl == nil or b.ilvl == nil then
			return a.ilvl and true or false
		else
			return false
		end
	elseif a.type ~= b.type then
		return a.type < b.type
	elseif a.name ~= b.name then
		return a.name < b.name
	else
		return a.count < b.count
	end
end

local function SortReagents(a, b)
	if a == nil or b == nil then return false end
	
	if a.type ~= b.type then
		if a.type and b.type then
			return a.type > b.type
		elseif a.type == nil or b.type == nil then
			return a.type and true or false
		else
			return false
		end
	elseif a.rarity ~= b.rarity then
		return a.rarity > b.rarity
	elseif a.name ~= b.name then
		return a.name < b.name
	elseif a.count ~= b.count then
		return a.count < b.count
	else
		return false
	end
end

local function SortEmptySlot(self)
	if not self.DropSlot then return end
	
	for k, v in pairs(self.buttons) do
		if v == self.DropSlot then
			tremove(self.buttons,k)
		end
	end
	
	tinsert(self.buttons,self.DropSlot)
end

local function isBank(bagID)
	for _, value in pairs({-1,5,6,7,8,9,10,11}) do
		if bagID == value then
			return true
		end
	end
	
	return false
end

local function isEnabled(container, button)
	if container.buttons then
		for _, ref in pairs(container.buttons) do
			if ref == button then
				return false
			end
		end

		return true
	end
end

local function SplitStacks(button, split)
	SplitContainerItem(button:GetParent():GetID(), button:GetID(), split)
end		


-- Assign / Remove Functions
local function CreateNewContainer()
	local dataBase = SyncUI_Data["Bags"]["ContainerList"]
	local numDefault = #ItemCategories
	local numTotal = numDefault + #dataBase or 0
	
	-- Bags
	for index = numDefault + 1, numTotal do
		do -- Bags
			local container = _G["SyncUI_BagFrame_Container"..index]
			local parent = SyncUI_BagFrame.ScrollFrame.ScrollChild
			
			if not container then
				local prevFrame = _G["SyncUI_BankFrame_Container"..index-1]
				
				container = CreateFrame("Frame", "SyncUI_BagFrame_Container"..index, parent, "SyncUI_ItemContainerTemplate")
				container:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT")
				container:SetID(index)
				container:Hide()
			end
		end
		
		do -- Bank
			local container = _G["SyncUI_BankFrame_Container"..index]
			local parent = SyncUI_BankFrame.Normal.ScrollFrame.ScrollChild
			
			if not container then
				container = CreateFrame("Frame","SyncUI_BankFrame_Container"..index,parent,"SyncUI_ItemContainerTemplate")
				container:SetPoint("TOPLEFT",_G["SyncUI_BankFrame_Container"..index-1],"BOTTOMLEFT")
				container:SetID(index)
				container:Hide()
			end
		end
	end
end

local function AddButtonToContainer(container, button)
	button.container = container
	
	if container == SyncUI_BankFrame_ReagentBank then
		for k, v in pairs(container.buttons) do
			if v == button then
				return
			end
		end	
	end
	
	table.insert(container.buttons,button)
end

local function RemoveButtonFromContainer(container, button)
	for i, ref in pairs(container.buttons) do
		if button == ref then
			table.remove(container.buttons,i)
		end
	end
end


-- Get Info Functions
local function isEquip(itemID)
	local isEquip = select(9, GetItemInfo(itemID))
	
	if isEquip ~= "" and isEquip ~= "INVTYPE_BAG" then
		return true
	end
	
	return
end

local function GetNumContainers()
	local dataBase = SyncUI_Data["Bags"]["ContainerList"]
	local standard = #ItemCategories
	local custom = #dataBase or 0
	
	return standard + custom
end

local function GetNumContainerRows(container, isBank)
	local numButtons = #container.buttons
	local numRows;
	
	if isBank then
		numRows = math.ceil(numButtons/perBankRow)
	else
		numRows = math.ceil(numButtons/perRow)
	end
	
	numRows = numRows + 1
	
	if container.collapsed then
		return 1
	end
	
	return numRows
end

local function GetDefaultContainerID(itemID, bagID, slot)
	local quality = select(3, GetItemInfo(itemID))
	local itemType = select(12, GetItemInfo(itemID))

	if quality == 0 then			-- Junk
		return 1
	elseif itemType == 7 then		-- Trade Goods
		return 3
	elseif itemType == 0 then		-- Consumables
		return 4
	elseif isEquip(itemID) then		-- Weapons + Armor
		local isBound = C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bagID, slot));

		return isBound and 6 or 5;
	else
		return 1
	end
end

local function GetContainerID(container, itemID, bagID, slot)
	-- Custom Containers
	for index, name in pairs(SyncUI_Data["Bags"]["ContainerList"]) do
		if container == name then
			return index + #ItemCategories
		end
	end
	
	-- Base Containers
	for index, name in pairs(ItemCategories) do
		if container == name then
			return index
		end
	end

	if itemID then
		return GetDefaultContainerID(itemID, bagID, slot)
	end
end

local function GetContainerForItem(bagID, slot)
	local itemID = GetContainerItemID(bagID, slot)
	local newItem = C_NewItems.IsNewItem(bagID, slot)

	if newItem and not SyncUI_IsDev() then
		return SyncUI_BagFrame_Container2
	end
	
	if itemID then
		local dataBase = SyncUI_Data
		local isBank = isBank(bagID)
		local container, index
		
		if dataBase then
			container = dataBase["Bags"]["ItemList"][itemID]
		end
		
		if container then
			index = GetContainerID(container, itemID, bagID, slot)
		else	
			index = GetDefaultContainerID(itemID, bagID, slot)
		end
		
		if isBank then
			return _G["SyncUI_BankFrame_Container"..index]
		else
			return _G["SyncUI_BagFrame_Container"..index]
		end
	end
end

local function GetNumFreeSlots(isBank)
	totalFreeSlots = 0
	
	if isBank then
		for bagID = 5, 11 do
			totalFreeSlots = totalFreeSlots + GetContainerNumFreeSlots(bagID)
		end
		
		totalFreeSlots = totalFreeSlots + GetContainerNumFreeSlots(BANK_CONTAINER)
	else
		for bagID = 0, 4 do
			totalFreeSlots = totalFreeSlots + GetContainerNumFreeSlots(bagID)
		end
	end
	
	return totalFreeSlots
end

local function GetPrevContainer(self, containerID, isBank)
	local index = containerID - 1
	local container;
	
	if index < 1 then return end
	
	repeat
		if isBank then
			container = _G["SyncUI_BankFrame_Container"..index]
		else
			container = _G["SyncUI_BagFrame_Container"..index]
		end
		
		if container:IsShown() then
			return container:GetName()
		else
			index = index - 1
		end

	until index == 0
end

local function GetButton(bagID, slot)
	if bagID and slot then
		if bagID == REAGENTBANK_CONTAINER then
			return _G["SyncUI_BankFrame_ReagentBank_Slot"..slot]
		elseif isBank(bagID) then
			if bagID == BANK_CONTAINER then
				return _G["SyncUI_BankFrame_Bag1_Slot"..slot]
			else
				return _G["SyncUI_BankFrame_Bag"..bagID-3 .."_Slot"..slot]
			end
		else
			return _G["SyncUI_BagFrame_Bag"..bagID+1 .."_Slot"..slot]
		end
	end
end

local function GetItemUpgradeLevel(itemLink)
	if not itemLink or not GetItemInfo(itemLink) then
		return
	end
	
	local scanTooltip = SyncUI_ScanTooltip

	if scanTooltip then
		local limit = min(4, scanTooltip:NumLines())
		
		scanTooltip:ClearLines()
		scanTooltip:SetHyperlink(itemLink)
		
		for i = 2, limit do
			local text = _G[scanTooltip:GetName().."TextLeft"..i]:GetText()
			local UPGRADE_LEVEL = gsub(ITEM_LEVEL," %d","")
			
			if text and text:find(UPGRADE_LEVEL) then
				local itemLevel = string.match(text,"%d+")

				if itemLevel then
					return tonumber(itemLevel)
				end
			end
		end
	end
end


-- Update Functions
local function UpdateFrameSize(self, numRows, isBank)
	local paddingH, paddingV = 20, 56
	local width = buttonSize * perRow + paddingH
	local height = buttonSize * numRows + paddingV
	local minHeight = buttonSize + paddingV
	local maxHeight = buttonSize * maxRows + paddingV
	
	if isBank then
		width = buttonSize * perBankRow + paddingH
	end
	
	if height > maxHeight then
		height = maxHeight
	elseif height < minHeight then
		height = minHeight
	end
	
	self:SetSize(width,height)
end

local function UpdateScrollChild(self, isBank)
	local scrollFrame = self:GetParent()
	local frame = scrollFrame:GetParent()
	local numRows = 0
	local container
	
	for i = 1, GetNumContainers() do
		if isBank then
			container = _G["SyncUI_BankFrame_Container"..i]
		else
			container = _G["SyncUI_BagFrame_Container"..i]
		end
		
		if container and container:IsShown() then
			numRows = numRows + GetNumContainerRows(container, isBank)
		end
	end

	local height = buttonSize * numRows
	
	self:SetHeight(height)
	UpdateFrameSize(frame, numRows, isBank)
end

local function UpdateContainerAnchors(isBank)
	local container, containerID, containerAnchor;
	
	for i = 1, GetNumContainers() do
		if isBank then
			container = _G["SyncUI_BankFrame_Container"..i]
		else
			container = _G["SyncUI_BagFrame_Container"..i]
		end

		if container and container:IsShown() then
			containerID = container:GetID()
			
			if containerID ~= 1 then
				containerAnchor = GetPrevContainer(container,containerID,isBank)

				container:ClearAllPoints()
				container:SetPoint("TOPLEFT",containerAnchor,"BOTTOMLEFT")
			end
		end
	end
end

local function UpdateContainer(self)
	if not self then return end
	
	local isBank = self:GetName():find("Bank")
	local perRow = perRow
	local numSlots = #self.buttons
	
	table.sort(self.buttons,SortContainer)
	SortEmptySlot(self)
	
	if isBank then
		perRow = perBankRow
	end
		
	for i, button in pairs(self.buttons) do
		local pos = (i-1) % perRow + 1
		local row = math.ceil(i / perRow)
		local xPos = buttonSize * (pos-1)
		local yPos = -buttonSize - (buttonSize * (row-1))
		if self.collapsed then
			button:Hide()
		else
			button:Show()
		end
		
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", self, xPos, yPos)
	end

	if not numSlots or numSlots == 0 then
		if self:GetID() ~= 1 then
			self:Hide()
		end
	elseif numSlots > 0 then
		local width = buttonSize*perRow
		local numRows = math.ceil(numSlots / perRow)
		local height = (numRows + 1) * buttonSize

		if self.collapsed then
			height = buttonSize
		end

		self:SetSize(width, height)
		self:Show()
	end

	do	-- Update Header
		local buttonID = self:GetID()
		local adjust = #ItemCategories
		local text
		
		if buttonID <= adjust and buttonID >= 1 then
			text = ItemCategories[buttonID]
		else
			text = SyncUI_Data["Bags"]["ContainerList"][buttonID - adjust]
		end
		
		self.Header:SetText(text)
		
		local width = math.ceil(self.Header:GetStringWidth())
		local space;
		
		if width % 2 == 0 then
			space = 12
		else
			space = 13
		end
		
		self.Header:SetWidth(width+space)
	end
	
	UpdateContainerAnchors(isBank)
	UpdateScrollChild(self:GetParent(), isBank)
end

local function UpdateAllContainers(isBank)
	for i = 1, GetNumContainers() do
		local container;
		
		if isBank then
			container = _G["SyncUI_BankFrame_Container"..i]
		else
			container = _G["SyncUI_BagFrame_Container"..i]
		end
		
		UpdateContainer(container)
	end
end

local function UpdateSlot(bagID, slot)
	local button = GetButton(bagID,slot)

	if bagID == REAGENTBANK_CONTAINER then
		local container = SyncUI_BankFrame_ReagentBank
		local itemLink = GetContainerItemLink(bagID, slot)
		
		if button then
			if itemLink then
				AddButtonToContainer(container, button)
			else
				RemoveButtonFromContainer(container, button)
			end
			
			SyncUI_ItemSlot_ForceUpdate(button, bagID, slot)
		end
		
		SyncUI_ReagentBank_ForceUpdate(container)
	else
		local container = GetContainerForItem(bagID, slot)
		
		if button then
			SyncUI_ItemSlot_ForceUpdate(button, bagID, slot)
		end
			
		if container then
			if button then
				local isEnabled = isEnabled(container, button)		
				
				if button.container and button.container ~= container then
					RemoveButtonFromContainer(button.container, button)
					UpdateContainer(button.container)
				end
				
				if isEnabled then
					AddButtonToContainer(container, button)
					UpdateContainer(container)
				end
			end
		elseif button and button.container then
			RemoveButtonFromContainer(button.container, button)
			UpdateContainer(button.container)
		end
	end
end

local function UpdateBag(bagID)
	local numSlots = GetContainerNumSlots(bagID)
	
	for slot = 1, numSlots do
		UpdateSlot(bagID,slot)
	end
end

local function UpdateAllBags(isBank)
	if isBank then
		if not SyncUI_BankFrame:IsShown() then
			return
		end
		
		for _, bagID in pairs({-1,5,6,7,8,9,10,11}) do
			UpdateBag(bagID)
		end
	else
		for bagID = 0, 4 do
			UpdateBag(bagID)
		end
	end
end

local function UpdateBankBagSlots()
	local numSlots, full = GetNumBankSlots()
	local cost = GetBankSlotCost(numSlots)
	local purchaseButton = SyncUI_BankFrame.BagFrame.Purchase
	
	for i = 1, NUM_BANKBAGSLOTS, 1 do
		local button = SyncUI_BankFrame.BagFrame["Bag"..i]

		local textureName = GetInventoryItemTexture("player",button:GetInventorySlot())
		local slotTextureName = select(2, GetInventorySlotInfo("Bag"..i))
		
		if textureName then
			button.icon:SetTexture(textureName)
			button.icon:Show()
			SetItemButtonCount(button, GetInventoryItemCount("player", button:GetInventorySlot()))
			button.hasItem = 1
		elseif slotTextureName and button.isBag then
			button.icon:SetTexture(slotTextureName)

			SetItemButtonCount(button,0)
			button.icon:Show()
		end
		
		if i <= numSlots then
			SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0)
			button.tooltipText = BANK_BAG
		else
			SetItemButtonTextureVertexColor(button, 1.0,0.1,0.1)
			button.tooltipText = BANK_BAG_PURCHASE
		end
	end
	
	BankFrame.nextSlotCost = cost
	
	if full then
		purchaseButton:Hide()
	else
		purchaseButton:Show()
	end
end

local function UpdateItemDropSlot(self, isBank, isReagent)
	if isReagent then
		local numFreeSlots = 98 - (#self.buttons - 1)
		self.DropSlot.Count:SetText(numFreeSlots)	
	else
		local container = _G[self:GetName().."_Container1"]
		container.DropSlot.Count:SetText(GetNumFreeSlots(isBank))
	end
end

local function UpdateSearchResults(frame, searchValue)
	local bagID = frame:GetID()
	local numSlots = GetContainerNumSlots(bagID)
	
	for slot = 1, numSlots do
		local button = _G[frame:GetName().."_Slot"..slot]
		local isFiltered = select(8, GetContainerItemInfo(bagID, slot))
		local itemID = GetContainerItemID(bagID,slot)
	
		if itemID then
			local itemName = string.lower(GetItemInfo(itemID))
			local isMatching = string.find(itemName, searchValue) or string.find(itemID, searchValue);
			
			if isMatching and not button.shouldDelete then
				button.searchOverlay:Hide()
			else
				button.searchOverlay:Show()
			end
		end
	end
end

local function UpdateCollapseStates(name, isCollapsed)
	local index = GetContainerID(name)
	
	if index and isCollapsed then
		local container = _G["SyncUI_BagFrame_Container"..index]

		if container then
			container.Collapse:Click()
		end
	else
		SyncUI_CharData["Bags"][name] = nil
	end
end


-- Global Functions
function SyncUI_ItemSlot_OnLoad(self)
	local bagID = self:GetParent():GetID()
	local slot = self:GetID()
	
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:RegisterForDrag("LeftButton")
	self.SplitStack = SplitStacks
	self.container = GetContainerForItem(bagID, slot)
	
	if bagID ~= REAGENTBANK_CONTAINER then
		self.UpdateTooltip = SyncUI_ItemSlot_OnEnter
		self:HookScript("OnClick", SyncUI_ItemSlot_OnClick)
	end

	if self.BattlepayItemTexture then
		self.BattlepayItemTexture:Hide()
	end
	
	self:SetSize(buttonSize, buttonSize)
	self:SetNormalTexture("")
	self:SetPushedTexture("")
	
	if not self.cooldown then
		self.cooldown = _G[self:GetName().."Cooldown"]
		self.cooldown:ClearAllPoints()
		self.cooldown:SetPoint("TOPLEFT",self.icon)
		self.cooldown:SetPoint("BOTTOMRIGHT",self.icon)
		self.cooldown:SetFrameLevel(self:GetFrameLevel())
		SyncUI_Cooldown_OnRegister(self.cooldown)
	end
end

function SyncUI_ItemSlot_OnEnter(self)
	local bagID = self:GetParent():GetID()
	local slot = self:GetID()
	local x = self:GetRight()

	if x >= (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

	local showSell = nil
	local hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetBagItem(bagID, slot)
	
	-- Battle Pets
	if speciesID and speciesID > 0 then
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)
		return
	else
		if BattlePetTooltip then
			BattlePetTooltip:Hide()
		end
	end

	-- Repair Mode
	if InRepairMode() and (repairCost and repairCost > 0) then
		GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true)
		SetTooltipMoney(GameTooltip, repairCost)
		GameTooltip:Show()
	elseif MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 then
		showSell = 1
	end

	-- Modifier
	if IsControlKeyDown() and IsAltKeyDown() and bagID ~= REAGENTBANK_CONTAINER then
		SetCursor("INTERACT_CURSOR")
	elseif IsModifiedClick("DRESSUP") and self.hasItem then
		ShowInspectCursor()
	elseif showSell then
		ShowContainerSellCursor(bagID,slot)
	elseif self.readable then
		ShowInspectCursor()
	else
		ResetCursor()
	end
end

function SyncUI_ItemSlot_OnClick(self, button)
	local bagID = self:GetParent():GetID()
	local slot = self:GetID()
	
	if IsControlKeyDown() and IsAltKeyDown() then
		--[[if button == "LeftButton" then
			local itemID = GetContainerItemID(bagID, slot);
			local itemLink = select(2, GetItemInfo(itemID));
			local class, subclass = select(6, GetItemInfo(itemID));
			print(itemLink, class, subclass)
		end
		--]]
		if button == "RightButton" then
			if #SyncUI_Data["Bags"]["ContainerList"] > 0 then
				dropDownItemID = GetContainerItemID(bagID,slot)
				SyncUI_DropDownMenu_Toggle(self.DropDown, nil, "TOPLEFT", self, "TOPRIGHT", -1, 1)
			end
		end
	elseif (IsAltKeyDown() and button == "LeftButton" and bagID <= 4 and bagID >= 0) then
		if self.shouldDelete then
			local isFiltered = select(8, GetContainerItemInfo(bagID, slot))
			
			if isFiltered then
				self.searchOverlay:Show()
			end
			
			self.delete:Hide()
			self.shouldDelete = false
			deleteQueue[bagID][slot] = nil
		else
			self.delete:Show()
			self.searchOverlay:Hide()
			self.shouldDelete = true
			deleteQueue[bagID][slot] = true
		end
	end
end
 
function SyncUI_ItemSlot_OnUpdate(self, elapsed)
	if not self.timer then
		self.timer = 0
	end
	
	self.timer = self.timer + elapsed
	
	while self.timer > 1 do
		local bagID = self:GetParent():GetID()
		local slot = self:GetID()
		local start, duration, isEnabled = GetContainerItemCooldown(bagID, slot)
		
		if isEnabled then
			CooldownFrame_Set(self.cooldown,start,duration,isEnabled)
		end
		
		self.timer = self.timer - 1
	end
end

function SyncUI_ItemSlot_ForceUpdate(self, bagID, slot)
	local itemLink = GetContainerItemLink(bagID, slot)

	if itemLink then
		local texture, itemCount, locked, rarity, readable = GetContainerItemInfo(bagID, slot)
		local noValue, itemID = select(9, GetContainerItemInfo(bagID, slot))
		local isQuest, questID, isActive = GetContainerItemQuestInfo(bagID, slot)
		local isEquip = isEquip(itemLink)
		local itemLevel = select(4, GetItemInfo(itemLink))

		SetItemButtonTexture(self, texture)
		SetItemButtonCount(self, itemCount)
		SetItemButtonDesaturated(self, locked)
		--self.Count:SetText(itemCount);
		
		-- Quality Indicator
		if isQuest or questID then
			self.quality:SetVertexColor(0.8,0.6,0)
			self.quality:Show()			
		elseif not rarity or rarity <= 1 then
			self.quality:Hide()
		else
			local c = ITEM_QUALITY_COLORS[rarity]
			self.quality:SetVertexColor(c.r,c.g,c.b)
			self.quality:Show()
		end
		
		-- Quest Indicator
		if questID and not isActive then
			self.quest:Show()
		else
			self.quest:Hide()
		end

		-- Junk Indicator
		if self.JunkIcon then
			if rarity == LE_ITEM_QUALITY_POOR and not noValue then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		-- Rarity
		if itemID == 110560 or itemID == 6948 or itemID == 140192 then
			self.rarity = 10
		else
			self.rarity = rarity
		end
		
		-- Stacks + iLvl
		if isEquip then
			local itemLevelUpgrade = GetItemUpgradeLevel(itemLink)
			
			if itemLevelUpgrade then
				itemLevel = itemLevelUpgrade
			end
			
			SetItemButtonCount(self, itemLevel)
			self.Count:SetVertexColor(1,0.8,0)
		else
			self.Count:SetVertexColor(1,1,1)
		end
		
		self.hasItem = true
		self.name = GetItemInfo(itemLink)
		self.type = select(7, GetItemInfo(itemLink))
		self.count = itemCount
		self.ilvl = itemLevel
		self.readable = readable		

		if not (self.container and self.container.collapsed) then
			self:Show()
		end
	else
		self.hasItem = nil
		self:Hide()
	end

	if self.delete then
		if bagID <= 4 and bagID >= 0 then
			deleteQueue[bagID][slot] = nil
		end
	
		self.shouldDelete = nil
		self.delete:Hide()
	end
end

function SyncUI_ItemSlot_InitDropDown(self, level)
	local dataBase = SyncUI_Data["Bags"]["ContainerList"]
	local bagID = self:GetParent():GetParent():GetID()
	local slot = self:GetParent():GetID()
	local itemID = GetContainerItemID(bagID,slot)
	
	if itemID then
		local itemName,_,quality = GetItemInfo(itemID)
		local colorCode = "|c"..select(4, GetItemQualityColor(quality or 0))
		
		local info = {}
		info.text = itemName
		info.colorCode = colorCode
		info.isTitle = true
		info.justifyH = "CENTER"
		info.height = 20
		SyncUI_DropDownMenu_AddButton(info, level)
	end
	
	local info = {}
	info.isDivider = true
	SyncUI_DropDownMenu_AddButton(info, level)
	
	local info = {}
	info.text = RESET_TO_DEFAULT
	info.clickFunc = function(self) SyncUI_ItemDropDownButton_OnClick(self) end
	SyncUI_DropDownMenu_AddButton(info, level)
	
	local info = {}
	info.isDivider = true
	SyncUI_DropDownMenu_AddButton(info, level)
	
	for index, containerName in pairs(dataBase) do
		local info = {}
		info.buttonID = index
		info.text = containerName
		info.clickFunc = function(self) SyncUI_ItemDropDownButton_OnClick(self) end
		SyncUI_DropDownMenu_AddButton(info, level)
	end
	
	local info = {}
	info.isDivider = true
	SyncUI_DropDownMenu_AddButton(info, level)
	
	local info = {}
	info.text = CANCEL
	info.height = 20
	info.clickFunc = function(self) self:GetParent():Hide() end
	SyncUI_DropDownMenu_AddButton(info, level)
end

function SyncUI_ItemDropDownButton_OnClick(self, button)
	local itemID = dropDownItemID
	local dataBase = SyncUI_Data["Bags"]["ItemList"]
	local category = self:GetText()	
	local buttonID = self:GetID()
	
	if itemID then
		if buttonID > 0 then
			dataBase[itemID] = category
		else
			dataBase[itemID] = nil
		end
	end
	
	UpdateAllBags()
	UpdateAllBags(true)
end

function SyncUI_DropItemSlot_OnClick(self)
	local container = self:GetParent():GetName()
	local containerID = self:GetParent():GetID()
	
	-- Bank
	if (container:find("Bank") and container:find("Container1")) then
		for _, bagID in pairs({-1,5,6,7,8,9,10,11}) do
			for slot = 1, GetContainerNumSlots(bagID) do
				if not GetContainerItemInfo(bagID,slot) then
					return PickupContainerItem(bagID, slot)
				end
			end
		end
	end
	
	-- Reagent Bank
	if containerID == REAGENTBANK_CONTAINER then
		for slot = 1, GetContainerNumSlots(containerID) do
			if not GetContainerItemInfo(containerID, slot) then
				return PickupContainerItem(containerID, slot)
			end
		end
	end
	
	-- Normal Bags
	for bagID = 0, 4 do
		for slot = 1, GetContainerNumSlots(bagID) do
			if not GetContainerItemInfo(bagID,slot) then
				if InCombatLockdown() then
					if bagID == 0 then
						return PutItemInBackpack()
					else
						return PutItemInBag(bagID + 19)
					end
				else
					return PickupContainerItem(bagID, slot)
				end
			end
		end
	end
	
	return false
end

function SyncUI_ItemContainer_Collapse(self)
	local container = self:GetParent()
	local index = container:GetID()
	local name = ItemCategories[index] or SyncUI_Data["Bags"]["ContainerList"][index-#ItemCategories]
	local isBank = container:GetName():find("Bank")
	
	if not self:GetChecked() then
		container.collapsed = false
		
		if not isBank then
			SyncUI_CharData["Bags"][name] = nil
		end
	else		
		container.collapsed = true
		
		if not isBank then
			SyncUI_CharData["Bags"][name] = true
		end
	end
	
	UpdateContainer(container)
end


do	-- Check Bag AddOns
	local BagAddons = {"Bagnon", "ArkInventory", "cargBags_Nivaya", "AdiBags", "Inventorian", "LiteBag", "Baggins"}

	for _, addon in pairs(BagAddons) do
		if IsAddOnLoaded(addon) then
			return
		end
	end
end


-- Bag Functions
function SyncUI_BagFrame_OnLoad(self)
	tinsert(UISpecialFrames, self:GetName())
	
	hooksecurefunc("ToggleAllBags", SyncUI_BagFrame_Toggle)
	
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("MERCHANT_CLOSED")
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MAIL_CLOSED")
	self:RegisterEvent("AUCTION_HOUSE_SHOW"	)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_REMOVED")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
	self:RegisterEvent("ADDON_LOADED")
	
	for i = 1, 13 do
		SyncUI_DisableFrame("ContainerFrame"..i)
	end
	
	ContainerFrameItemButton_OnEnter = function() end
end

function SyncUI_BagFrame_OnEvent(self, event, ...)
	if event == "MERCHANT_SHOW" or event == "MAIL_SHOW" or event == "AUCTION_HOUSE_SHOW" then
		SyncUI_BagFrame:Show()
		
		if event == "MERCHANT_SHOW" then
			local profile = SyncUI_GetProfile()
			
			if profile.Options.Misc.AutoSellJunk then
				SellGreyItems()
			end
			if profile.Options.Misc.AutoRepair then
				if profile.Options.Misc.UseGuildRepair and CanGuildBankRepair() then
					local repairCost = GetRepairAllCost()
					local amount = GetGuildBankWithdrawMoney()
					local guildMoney = GetGuildBankMoney()
					
					if amount == -1 then
						amount = guildMoney
					else
						amount = min(amount, guildMoney)
					end
					
					if amount >= repairCost then
						RepairAllItems(true)
					else
						RepairAllItems()
					end
				else
					RepairAllItems()
				end
			end
		end
	end
	
	if event == "MERCHANT_CLOSED" or event == "MAIL_CLOSED" or event == "AUCTION_HOUSE_CLOSED" then
		SyncUI_BagFrame:Hide()
	end

	if event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED" then
		UpdateAllBags()
	end
	
	if event == "ITEM_LOCKED" then
		local button = GetButton(...)
		if button then
			button.icon:SetDesaturated(true)
		end
	end

	if event == "ITEM_UNLOCKED" then
		local button = GetButton(...)
		if button then
			button.icon:SetDesaturated(false)
		end
	end	

	if event == "BAG_UPDATE" then
		local bagID = ...
		
		UpdateBag(bagID)

		if bagID < 0 or bagID > 4 then
			UpdateItemDropSlot(SyncUI_BankFrame,true)
		else
			UpdateItemDropSlot(self)
		end
		
		if MerchantFrame:IsShown() then
			local profile = SyncUI_GetProfile()
			
			if profile.Options.Misc.AutoSellJunk then
				SellGreyItems()
			end
		end
	end

	if event == "BAG_NEW_ITEMS_UPDATED" then
		UpdateAllBags()
	end
	
	if event == "ADDON_LOADED" and ... == "SyncUI" then
		CreateNewContainer()
		
		if SyncUI_CharData["Bags"] then
			for name, isCollapsed in pairs(SyncUI_CharData["Bags"]) do
				UpdateCollapseStates(name, isCollapsed)
			end
		else
			SyncUI_CharData["Bags"] = {}
		end
	end
end

function SyncUI_BagFrame_OnShow(self)
	self:RegisterEvent("ITEM_LOCKED")
	self:RegisterEvent("ITEM_UNLOCKED")
	
	if not self.firstTime then
		UpdateAllBags()
		UpdateAllContainers()
		UpdateItemDropSlot(self)
		
		self.firstTime = true
	end
end

function SyncUI_BagFrame_OnHide(self)
	SyncUI_DropDownMenu_Hide()
	SyncUI_BagCategoryMenu:Hide()
	
	self:UnregisterEvent("ITEM_LOCKED")
	self:UnregisterEvent("ITEM_UNLOCKED")

	C_NewItems.ClearAll()
	UpdateAllBags()
end

function SyncUI_BagFrame_Toggle()
	--if SyncUI_BagFrame:IsShown() and not BankFrame:IsShown() then
	if SyncUI_BagFrame:IsShown() then
		SyncUI_BagFrame:Hide()
	else
		SyncUI_BagFrame:Show()
	end
end

function SyncUI_BagFrame_BagContainer_OnLoad(self)
	self:SetBackdropColor(1,1,1,0.75)
	
	for i = 0, 3 do
		local button = _G["CharacterBag"..i.."Slot"]
		
		button.Highlight = button:GetHighlightTexture()
	
		button:SetParent(self)
		button:SetSize(32,32)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT",self,13+buttonSize*i,-13)
		button:SetNormalTexture("")
		button:SetPushedTexture("")
		--button:SetCheckedTexture("")
		button.IconBorder:SetAlpha(0)
		button.icon:SetTexCoord(0.075,0.925,0.075,0.925)
		button:HookScript("OnUpdate", function(self)
			PaperDollItemSlotButton_Update(self)
		end)	
		
		if button.Highlight then
			button.Highlight:ClearAllPoints()
			button.Highlight:SetPoint("CENTER")
			button.Highlight:SetSize(32,32)
			button.Highlight:SetColorTexture(1,1,1,0.25)
		end
	
		button.border = button:CreateTexture(nil,"BORDER")
		button.border:SetSize(42,42)
		button.border:SetPoint("CENTER")
		button.border:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton_Small")
		button.border:SetTexCoord(0,0.1640625,0,0.65625)
		
		button.glass = button:CreateTexture(nil,"OVERLAY")
		button.glass:SetSize(buttonSize, buttonSize)
		button.glass:SetPoint("CENTER",0,0)
		button.glass:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton_Small")
		button.glass:SetTexCoord(0.3125,0.4609375,0,0.59375)
	end
end

function SyncUI_BagFrame_DeleteItems(self)
	local string = ""
	
	for bagID, slots in pairs(deleteQueue) do
		for slot, canDelete in pairs(slots) do
			if canDelete then
				PickupContainerItem(bagID, slot)
				DeleteCursorItem()
				
				string = string .. GetContainerItemLink(bagID, slot)
			end
		end
	end
	
	if string ~= "" then
		print(SYNCUI_STRING_UI_LABEL.." - Deleted Items: "..string)
	end
	
	deleteQueue = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	}
end

function SyncUI_BagSearch_OnTextChanged(self)
	local searchValue = self:GetText();
	
	for i = 1, 5 do
		local bag = _G["SyncUI_BagFrame_Bag"..i];
		UpdateSearchResults(bag, searchValue);
	end
	
	for i = 1, 8 do
		local bag = _G["SyncUI_BankFrame_Bag"..i];
		UpdateSearchResults(bag, searchValue);
	end
end

function SyncUI_BagSearch_OnChar(self)
	local MIN_REPEAT_CHARACTERS = 4;
	local searchString = self:GetText();
	
	if (string.len(searchString) >= MIN_REPEAT_CHARACTERS) then
		local repeatChar = true;
		
		for i=1, MIN_REPEAT_CHARACTERS - 1, 1 do
			if ( string.sub(searchString,(0-i), (0-i)) ~= string.sub(searchString,(-1-i),(-1-i)) ) then
				repeatChar = false;
				break;
			end
		end
		
		if ( repeatChar ) then
			self:ClearFocus();
		end
	end
end



-- Bank Functions
function SyncUI_BankSlot_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetInventoryItem("player", self:GetInventorySlot())
	GameTooltip:Show()
end

function SyncUI_BankBag1_OnLoad(self)
	self:SetID(BANK_CONTAINER)
	
	for i = 1, self:GetNumChildren() do
		local button = _G[self:GetName().."_Slot"..i]

		button.GetInventorySlot = ButtonInventorySlot
		button.UpdateTooltip = SyncUI_BankSlot_OnEnter
		button:SetScript("OnEnter", SyncUI_BankSlot_OnEnter)
	end
end

function SyncUI_BankFrame_OnShow(self)
	BankFrame:Show()
	BankFrame:UnregisterAllEvents()
	BankFrame.selectedTab = 1
	
	SyncUI_BagFrame:Show()
	
	self.Normal:Show()
	self.Reagent:Hide()

	if not self.firstTime then
		UpdateAllContainers(true)
		UpdateAllBags(true)
		UpdateAllContainers(true)
		UpdateBankBagSlots()
		UpdateItemDropSlot(self,true)
		
		self.firstTime = true
	end
end

function SyncUI_BankFrame_OnLoad(self)
	local frame = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate");
	frame:Hide();
	BankFrame:SetParent(frame);
	--BankFrame:UnregisterEvent("BANKFRAME_OPENED");
	--BankFrame:UnregisterEvent("BANKFRAME_CLOSED");
	--ReagentBankFrame:UnregisterAllEvents()
	
	BankFrame:SetPoint("TOPRIGHT",UIParent,"TOPLEFT")
	
	
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	--self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")

	UIPanelWindows[self:GetName()] = { area = "left", pushable = 0, width = 464 }
end

function SyncUI_BankFrame_OnEvent(self, event, ...)
	if event == "BANKFRAME_OPENED" then		
		ShowUIPanel(self)
	end
	
	if event == "BANKFRAME_CLOSED" then
		HideUIPanel(self)
	end

	if event == "PLAYERBANKSLOTS_CHANGED" then
		UpdateAllBags(true)
		UpdateBankBagSlots()
		UpdateItemDropSlot(self,true)
	end
	
	if event == "PLAYERREAGENTBANKSLOTS_CHANGED" then
		local slot = ...
		-- TODO: Something?
	end
	
	if event == "PLAYERBANKBAGSLOTS_CHANGED" then
		UpdateBankBagSlots()
		UpdateItemDropSlot(self,true)
	end
end

function SyncUI_BankFrame_Switch()
	local frame = BankFrame
	local normal = SyncUI_BankFrame.Normal	
	local reagent = SyncUI_BankFrame.Reagent
	
	if frame.selectedTab == 2 then
		normal:Show()
		reagent:Hide()
		frame.selectedTab = 1
	else
		normal:Hide()
		reagent:Show()
		frame.selectedTab = 2
	end
end


-- Reagent Bank Functions
function SyncUI_ReagentBank_OnLoad(self)
	self:RegisterEvent("REAGENTBANK_PURCHASED")
	self:RegisterEvent("REAGENTBANK_UPDATE")
	self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
	self:SetID(REAGENTBANK_CONTAINER)
	self.buttons = {}
	
	for i = 1, 98 do
		local button = _G["SyncUI_BankFrame_ReagentBank_Slot"..i]
		
		SyncUI_ItemSlot_OnLoad(button)
		
		table.insert(self.buttons,button)
	end
end

function SyncUI_ReagentBank_OnShow(self)
	UpdateBag(self:GetID())
	
	if not IsReagentBankUnlocked() then
		self.UnlockFrame:Show()
		self.DropSlot:Hide()
		self.Deposite:Hide()
		self.Restack:Hide()
	end
end

function SyncUI_ReagentBank_OnEvent(self, event, ...)
	if event == "REAGENTBANK_PURCHASED" then
		self.UnlockFrame:Hide()
		self.DropSlot:Show()
		self.Deposite:Show()
		self.Restack:Show()
		SyncUI_BankFrame.Normal.Deposite:Enable()
		SyncUI_ReagentBank_ForceUpdate(self)
	end
	
	if event == "REAGENTBANK_UPDATE" then
		UpdateBag(self:GetID())
	end
	
	if event == "PLAYERREAGENTBANKSLOTS_CHANGED" then
		UpdateSlot(self:GetID(),...)
	end
end

function SyncUI_ReagentBank_ForceUpdate(self)
	local paddingH, paddingV = 20, 56
	
	table.sort(self.buttons, SortReagents)
	SortEmptySlot(self)
	
	for i, button in pairs(self.buttons) do
		local pos = (i-1) % perBankRow + 1
		local row = math.ceil(i / perBankRow)
		local xPos = 15 + (buttonSize * (pos-1))
		local yPos = -15 - (buttonSize * (row-1))
	
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT",self.ContentLayer,xPos,yPos)
	end
	
	local numSlots = #self.buttons
	local width = buttonSize * perBankRow + paddingH
	local height = math.ceil(numSlots / perBankRow) * buttonSize + paddingV

	if not IsReagentBankUnlocked() then
		height = 4 * buttonSize + paddingV
	end
	
	self:SetSize(width, height)
	
	UpdateItemDropSlot(self,false,true)
end


-- Category Menu
local maxLines = 7
local dragID, newID

local function UpdateLineState(self)
	local lineID = self:GetID()
	
	if dragID then
		if dragID == lineID then
			self:SetButtonState("PUSHED", true)
			self:GetFontString():SetVertexColor(1,1,1)
			self:SetAlpha(1)
		else
			self:SetButtonState("NORMAL")
			
			if self:IsMouseOver() or lineID == newID then
				self:GetFontString():SetVertexColor(0.4,1,0)
				self:SetAlpha(1)
			else
				self:GetFontString():SetVertexColor(1,1,1)
				self:SetAlpha(0.5)
			end
		end
	else
		self:SetButtonState("NORMAL")
		self:GetFontString():SetVertexColor(1,1,1)
		self:SetAlpha(1)
	end
end

function SyncUI_BagCategoryMenu_OnShow(self)
	self.ScrollFrame.ScrollBar:SetValue(0)
	SyncUI_BagCategoryMenu_UpdateScrollFrame(self.ScrollFrame)
end

function SyncUI_BagCategoryMenu_AddCategory()
	local dataBase = SyncUI_Data["Bags"]["ContainerList"];
	local frame = SyncUI_BagCategoryMenu;
	local scrollFrame = frame.ScrollFrame;
	local editBox = frame.EnterName;
	local text = editBox:GetText();

	editBox:ClearFocus();
	editBox:SetText("");
	editBox.Thumbnail:Show();
	editBox.ClearButton:Hide();
	
	if text == "" or text == nil or (text:gsub("%s","") == "") then
		return
	end
	
	for _, container in pairs(dataBase) do
		if string.lower(text) == string.lower(container) then
			return;
		end
	end

	tinsert(dataBase,text)

	scrollFrame.ScrollBar:SetValue(0)
	
	SyncUI_BagCategoryMenu_UpdateScrollFrame(scrollFrame)
	SyncUI_DropDownMenu_Hide()
	
	CreateNewContainer()
	UpdateAllBags()
	UpdateAllBags(true)
end

function SyncUI_BagCategoryMenu_UpdateScrollFrame(self)
	local dataBase = SyncUI_Data["Bags"]["ContainerList"]
	local offset = self.offset
	local size = #dataBase
	
	SyncUI_ScrollFrame_Update(self, size, maxLines, 20)
	
	for i = 1, maxLines do
		local line = SyncUI_BagCategoryMenu["Line"..i]
		local lineID = offset + i
		
		line:SetID(lineID)
		
		if dragID and line:IsMouseOver() then
			newID = lineID
		end
		
		UpdateLineState(line)
		
		SyncUI_BagCategoryLine_Update(line)
	end	
end

function SyncUI_BagCategoryLine_Update(self)
	local dataBase = SyncUI_Data["Bags"]["ContainerList"]
	local index = self:GetID()

	if dataBase[index] then
		local name = dataBase[index]
		
		if name then
			self:SetText(name)
		end
		
		if not self:IsShown() then
			self:Show()
		end
	else
		self:Hide()
		return
	end
end

function SyncUI_BagCategoryLine_Delete(self)
	local dataBase = SyncUI_Data["Bags"]["ContainerList"]
	local scrollFrame = self:GetParent().ScrollFrame
	local name = dataBase[self:GetID()]
	
	tremove(dataBase, self:GetID())
	scrollFrame.ScrollBar:SetValue(0)
	SyncUI_BagCategoryMenu_UpdateScrollFrame(scrollFrame)
	SyncUI_DropDownMenu_Hide()

	UpdateAllBags()
	UpdateAllBags(true)
end

function SyncUI_BagCategoryLine_OnEnter(self, isLine)
	local line = isLine and self or self:GetParent()
	
	if dragID then
		newID = line:GetID()
		UpdateLineState(line)
	else
		line.Delete:SetAlpha(1)
	end
	
	GameTooltip:SetOwner(self);
	GameTooltip:AddLine();
	GameTooltip:Show();
end

function SyncUI_BagCategoryLine_OnLeave(self, isLine)
	local line = isLine and self or self:GetParent()
	
	if dragID then
		newID = nil
		UpdateLineState(line)
	end
	
	if not line:IsMouseOver() then
		line.Delete:SetAlpha(0)
	end	
end

function SyncUI_BagCategoryLine_OnDragStart(self)
	if dragID then
		return
	else
		dragID = self:GetID()
	end

	self.Delete:SetAlpha(0)
		
	for i = 1, maxLines do
		local line = self:GetParent()["Line"..i]
		
		UpdateLineState(line)
	end
	
	SyncUI_BagCategoryLine_OnLeave(self, true)
end

function SyncUI_BagCategoryLine_OnDragStop(self)
	local dataBase = SyncUI_Data["Bags"]["ContainerList"]
	local name = dataBase[dragID]

	if newID and newID ~= dragID then
		tremove(dataBase, dragID)
		tinsert(dataBase, newID, name)
		SyncUI_BagCategoryMenu_UpdateScrollFrame(self:GetParent().ScrollFrame)
		
		UpdateAllBags()
		UpdateAllBags(true)
	end
	
	dragID, newID = nil, nil
	
	for i = 1, maxLines do
		local line = self:GetParent()["Line"..i]
		
		if line:IsMouseOver() then
			line.Delete:SetAlpha(1)
		end
		
		UpdateLineState(line)
	end
end
