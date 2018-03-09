
local brokerTypes, usedBroker = {}, {}

local function GetBrokerList()
	if not SyncUI_Data["Broker"] then
		SyncUI_Data["Broker"] = {}
	end
	if not SyncUI_Data["Broker"]["List"] then
		SyncUI_Data["Broker"]["List"] = {}
	end
	return SyncUI_Data["Broker"]["List"]
end

local function OpenMenu(broker)
	local maxButtons = getn(brokerTypes)
	local padding, numShown = 30, 0
	local menu = SyncUI_BrokerMenu
	local oldRef = menu.ref
	
	if oldRef and oldRef ~= broker and not oldRef.brokerType then
		menu.ref:SetAlpha(0)
	end
	
	for i = 1, 20 do
		SyncUI_BrokerMenu["Button"..i]:Hide()
	end
	
	for brokerType, info in pairs(brokerTypes) do
		local isUsed = usedBroker[brokerType]
		
		if not isUsed then
			numShown = numShown + 1
			
			-- Add Broker Button to the menu
			local button = SyncUI_BrokerMenu["Button"..numShown]

			if button then
				button.ref = broker
				button.brokerType = brokerType
				button.info = info
				button:SetNormalTexture(info.icon or "Interface\\Icons\\inv_misc_questionmark")
				button:SetText(info.title)
				button:Show()
			end
		end
	end
	
	if numShown == 0 then
		padding = padding - 10
	end
	
	if broker.brokerType then
		padding = padding + 35
		menu.Clear:Show()
	else
		menu.Clear:Hide()
	end
	
	menu.ref = broker
	menu:SetHeight(25 * numShown + padding)
	menu:ClearAllPoints()
	menu:SetPoint("BOTTOM",broker,"TOP",0,10)
	menu:Show()
	
	GameTooltip_Hide()
end

local function SetButton(button,index,brokerType,info,isInit)
	button:SetAlpha(1)
	button.brokerType = brokerType
	button.clickFunc = info.clickFunc
	button.updateFunc = info.updateFunc
	button.tooltipFunc = info.tooltipFunc
	button:SetText(info.title)

	usedBroker[brokerType] = index
	
	-- Save Setting
	if not isInit then
		SyncUI_Data["Broker"]["List"][index] = brokerType
	end
	
	if info.initFunc then
		info.initFunc()
	end
	
	if info.icon then
		button:SetNormalTexture(info.icon)
		button.Text:SetPoint("TOPLEFT",28,-8)
		button.Highlight:SetPoint("TOPLEFT",28,-8)
		button.Icon:Show()
		button.IconEdge:Show()
	else
		button.Text:SetPoint("TOPLEFT",8,-8)
		button.Highlight:SetPoint("TOPLEFT",8,-8)
		button.Icon:Hide()
		button.IconEdge:Hide()
	end
end


function SyncUI_BrokerButton_OnClick(self, button)
	if button == "LeftButton" and self.clickFunc then
		self.clickFunc(self)
	end

	if button == "RightButton" then
		OpenMenu(self)
	end
end

function SyncUI_BrokerButton_OnEnter(self)
	local menu = SyncUI_BrokerMenu
	
	if self.tooltipFunc and not menu:IsShown() then
		self.tooltipFunc(self)
	elseif not self.brokerType then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine("Right-Click to open broker list",1,1,1)
		GameTooltip:Show()
	end
	
	if self.brokerType then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.5)
	end
end

function SyncUI_BrokerButton_OnLeave(self)
	local menu = SyncUI_BrokerMenu
	
	if self.brokerType then
		self:SetAlpha(1)
	elseif menu:IsShown() and menu.ref == self then
		self:SetAlpha(0.5)
	else
		self:SetAlpha(0)
	end
	
	GameTooltip_Hide()
end

function SyncUI_BrokerButton_OnUpdate(self, elapsed)
	if self.updateFunc then
		self.update = self.update + elapsed

		while self.update > self.interval do
			self.updateFunc(self)
			self.update = self.update - self.interval
		end
	end
end

function SyncUI_BrokerButton_OnReset(self,noSave)
	local dataBase = GetBrokerList()

	if self.brokerType then
		usedBroker[self.brokerType] = nil
	end
	if not noSave then
		dataBase[self:GetID()] = nil
	end
	
	self.brokerType = nil
	self.clickFunc = nil
	self.updateFunc = nil
	self.tooltipFunc = nil
	self.Text:SetPoint("TOPLEFT",8,-8)
	self.Highlight:SetPoint("TOPLEFT",8,-8)
	self:SetText("")
	self:SetNormalTexture("")
	self.Icon:Hide()
	self.IconEdge:Hide()
	self:SetAlpha(0)
	
	SyncUI_BrokerMenu:Hide()
end

function SyncUI_BrokerMenu_OnInit(self)
	local menu = SyncUI_InfoBar
	local dataBase = GetBrokerList()

	for index, brokerType in pairs(dataBase) do
		local button = menu["Broker"..index]
		local info = brokerTypes[brokerType]
		
		if info then
			SetButton(button,index,brokerType,info,true)
		end
	end
	
	SyncUI_UpdateBrokerVisibility()

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function SyncUI_BrokerMenuButton_OnClick(self)
	local button, brokerType, info = self.ref, self.brokerType, self.info
	local index = button:GetID()
	
	-- Free Prev Broker
	if button.brokerType then
		usedBroker[button.brokerType] = nil
	end
	
	SetButton(button,index,brokerType,info)
	
	SyncUI_BrokerMenu:Hide()
end

function SyncUI_UpdateBrokerVisibility()
	local bar = SyncUI_ActionBar
	local padding = 50
	
	for i = 1, 4 do
		local button = _G["Broker"..i]
		local buttonSpace = button:GetRight()
		local barSpace = bar:GetLeft() + padding
		
		if buttonSpace > barSpace then
			button:Hide()
			SyncUI_BrokerButton_OnReset(button,true)
		else
			button:Show()
		end
	end
	
	for i = 5, 8 do
		local button = _G["Broker"..i]
		local buttonSpace = button:GetLeft()
		local barSpace = bar:GetRight() - padding
		
		if buttonSpace < barSpace then
			button:Hide()
			SyncUI_BrokerButton_OnReset(button,true)
		else
			button:Show()
		end
	end
end

function SyncUI_RegisterBrokerType(brokerType, brokerInfo)
	brokerTypes[brokerType] = brokerInfo
end
