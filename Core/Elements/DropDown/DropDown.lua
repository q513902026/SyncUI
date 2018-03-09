
local _G = _G
local DROPDOWNMENU_OPENED = nil
local minButtonWidth, maxButtonsPerMenu, maxLevel = 100, 50, 1
	
local function CreateNewButton(listFrame,index)
	local newButton = CreateFrame("Button", nil, listFrame, "SyncUI_DropDownButtonTemplate")

	listFrame["Button"..index] = newButton

	if index == 1 then
		newButton:SetPoint("TOPLEFT",listFrame,15,-10)
	else
		newButton:SetPoint("TOPLEFT",listFrame["Button"..index-1],"BOTTOMLEFT",0,0)
	end
	
	return newButton
end

local function GetButtonWidth(button)
	local width = 0
	
	if button.Text:GetText() then
		width = math.ceil(button.Text:GetStringWidth() + 25)
		
		if button.Icon:IsShown() then
			width = width + 20
		end
	end
	
	if width < minButtonWidth then
		width = minButtonWidth
	end
	
	if button.padding then
		width = width + button.padding
	end
	
	return width
end

local function GetButtonHeight(button)
	if button.height then
		return button.height
	elseif button.Icon:IsShown() then
		return 20
	elseif button.Divider:IsShown() then
		return 10
	else
		return 14
	end
end

local function RefreshDropDownSize(self)
	local maxWidth, maxHeight = 0, 20
	
	for index = 1, self.numButtons do
		local button = self["Button"..index]
		
		if button and button:IsShown() then
			local buttonWidth = GetButtonWidth(button)
			local buttonHeight = GetButtonHeight(button)
			
			button:SetHeight(buttonHeight)
			
			maxHeight = maxHeight + buttonHeight

			if buttonWidth > maxWidth then
				maxWidth = buttonWidth
			end
		end
	end
	
	maxWidth = maxWidth + 10
	
	self:SetSize(maxWidth, maxHeight)
end


function SyncUI_DropDownMenu_AddButton(info, level)
	if not level then
		level = 1
	end
	
	local listFrame = _G["SyncUI_DropDownList"..level]
	local index = listFrame and (listFrame.numButtons + 1) or 1
	local button = listFrame["Button"..index] or CreateNewButton(listFrame,index)
	local icon = button.Icon

	-- Set the number of buttons in the menu
	listFrame.numButtons = index
	
	button:Enable()
	button.Icon:Hide()
	button.ListDot:Hide()
	button.ListChecked:Hide()
	
	-- setup button
	if info.isTitle then
		info.disabled = true
		
		--[[	Colorize Title
		if info.text and not info.colorCode then
			info.text = "|cFF00FF99"..info.text
		end
		--]]
	end

	if info.isDivider then
		info.disabled = true
		button.Divider:Show()
	else
		button.Divider:Hide()
	end
	
	if info.disabled then
		button:Disable()
		button.MouseHandler:Show()
	else
		button:Enable()
		button.MouseHandler:Hide()
	end

	if info.isList then
		button.ListDot:Show()
		info.padding = 16
		
		if info.isChecked then
			button.ListChecked:Show()
		end
	end
	
	if info.padding then
		button.Icon:SetPoint("TOPLEFT",info.padding,0)
	else
		button.Icon:SetPoint("TOPLEFT")
	end
		
	if info.text then
		if info.colorCode then
			info.text = info.colorCode..info.text.."|r"
		end

		if info.icon then	
			if info.tCoordLeft then
				icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom);
			else
				icon:SetTexCoord(0,1,0,1)
			end
			if info.height then
				icon:SetSize(info.height,info.height)
			else
				icon:SetSize(20,20)
			end

			button.Text:ClearAllPoints()
			button.Text:SetPoint("TOPLEFT",icon,"TOPRIGHT",5,0)
			button.Text:SetPoint("BOTTOMRIGHT")
			icon:SetTexture(info.icon)
			icon:Show()
		else
			button.Text:ClearAllPoints()
			button.Text:SetPoint("TOPLEFT",info.padding or 0, 0)
			button.Text:SetPoint("BOTTOMRIGHT")
			icon:Hide()
		end

		if info.justifyH then
			button.Text:SetJustifyH(info.justifyH)
		else
			button.Text:SetJustifyH("LEFT")
		end
		
		if info.justifyV then
			button.Text:SetJustifyV(info.justifyV)
		else
			button.Text:SetJustifyV("CENTER")
		end

		button:SetText(info.text)
	else
		button:SetText("")
	end
	
	if info.buttonID then
		button:SetID(info.buttonID)
	end

	button.value = info.value
	button.padding = info.padding
	button.height = info.height
	button.clickFunc = info.clickFunc
	button.tooltipFunc = info.tooltipFunc
	
	button:Show()
end

function SyncUI_DropDownMenu_Initialize(frame, initFunc, level, init)
	if not level then
		level = 1
	end
	
	local listFrame = _G["SyncUI_DropDownList"..level]
	listFrame.numButtons = 0
	
	if initFunc then
		frame.initFunc = initFunc
		
		if init then
			initFunc(frame)
		end
	end
end

function SyncUI_DropDownMenu_Toggle(dropDownMenu, level, point, relativeTo, relativePoint, xPos, yPos)
	if not level then
		level = 1
	end
	
	local listFrame = _G["SyncUI_DropDownList"..level]
	
	if listFrame:IsShown() and DROPDOWNMENU_OPENED == dropDownMenu then
		listFrame:Hide()
	else
		listFrame:Hide()
		listFrame:ClearAllPoints()
		listFrame:SetPoint(point, relativeTo, relativePoint, xPos, yPos)
		
		-- Pre Hide all Buttons
		for index = 1, maxButtonsPerMenu do
			local button = listFrame["Button"..index]
			
			if button then
				button:Hide()
			end
		end
		
		-- Setup & show Buttons
		SyncUI_DropDownMenu_Initialize(dropDownMenu, dropDownMenu.initFunc, level, true)

		-- Don't show if no buttons are drawn.
		if listFrame.numButtons == 0 then
			return
		end

		-- Save as opened
		DROPDOWNMENU_OPENED = dropDownMenu
		
		listFrame:Show()
	end
end

function SyncUI_DropDownMenu_OnShow(self)
	RefreshDropDownSize(self)
	SyncUI_DropDownMenu_StopFading(self)
end

function SyncUI_DropDownMenu_OnHide(self)
	DROPDOWNMENU_OPENED = nil
	SyncUI_DropDownMenu_StartFading(self)
end

function SyncUI_DropDownMenu_OnUpdate(self,elapsed)
	if not self.fadeTimer or not self.forceFading then
		return
	elseif self.fadeTimer < 0 then
		self:Hide()
		self.fadeTimer = nil
		self.forceFading = nil
	else
		self.fadeTimer = self.fadeTimer - elapsed
	end		
end

function SyncUI_DropDownMenu_StartFading(self)
	self.fadeTimer = 1
	self.forceFading = true
end

function SyncUI_DropDownMenu_StopFading(self)
	self.fadeTimer = nil
	self.forceFading = nil
end

function SyncUI_DropDownMenu_Hide(dropDownMenu)
	if dropDownMenu and DROPDOWNMENU_OPENED ~= dropDownMenu then
		return
	end
	
	for level = 1, maxLevel do
		local listFrame = _G["SyncUI_DropDownList"..level]
		
		if listFrame and listFrame:IsShown() then
			listFrame:Hide()
		end
	end
end


--[[------ATTRIBUTE-LIST----------
----------------------------------
info.text			[STRING]
info.colorCode		[STRING]
info.justifyH		[STRING]
info.justifyV		[STRING]
info.icon			[STRING]
info.tCoordLeft		[NUMBER]
info.tCoordRight	[NUMBER]
info.tCoordTop		[NUMBER]
info.tCoordBottom	[NUMBER]
info.isTitle		[BOOLEAN]	
info.isDivider		[BOOLEAN]
info.isList			[BOOLEAN]
info.isChecked		[BOOLEAN]
info.disabled		[BOOLEAN]
info.height			[NUMBER]
info.padding		[NUMBER]
info.buttonID		[NUMBER]
info.tooltipFunc	[FUNCTION]
info.clickFunc		[FUNCTION]
--------------------------------]]

