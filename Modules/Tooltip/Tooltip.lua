
local font = SyncUI_GameFontShadow_Medium

local tooltips = {
	GameTooltip,
	FriendsTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	--WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
	
	-- Garrison Specific Tooltips
	GarrisonBonusAreaTooltip,
	GarrisonFollowerTooltip,
	GarrisonFollowerAbilityTooltip,
	GarrisonMissionMechanicTooltip,
	GarrisonMissionMechanicFollowerCounterTooltip,
	GarrisonShipyardMapMissionTooltip,
	GarrisonShipyardFollowerTooltip,
	FloatingGarrisonShipyardFollowerTooltip,
}

local backdrop = {
	bgFile = SYNCUI_MEDIA_PATH.."Backdrops\\Backdrop-BgFile",
	edgeFile = SYNCUI_MEDIA_PATH.."Backdrops\\Backdrop-EdgeFile",
	edgeSize = 16, tileSize = 16, insets = {left = 7, right = 7, top = 7, bottom = 7},
}


-- New Widgets
local function SetArrow(self, direction)
	local xSize,ySize
	local point,relativePoint,xPos,yPos
	local left,right,top,bottom

	if direction == "LEFT" then
		xSize, ySize = 15,24
		point,relativePoint,xPos,yPos = "RIGHT","LEFT",4,0
		left,right,top,bottom = 0.765625,1,0,0.75
	end
	if direction == "RIGHT" then
		xSize, ySize = 15,24
		point,relativePoint,xPos,yPos = "LEFT","RIGHT",-4,0
		left,right,top,bottom = 0.5,0.734375,0.25,1
	end
	if direction == "TOP" then
		xSize, ySize = 24,15
		point,relativePoint,xPos,yPos = "BOTTOM","TOP",0,-4
		left,right,top,bottom = 0.125,0.5,0.53125,1
	end
	if direction == "BOTTOM" then
		xSize, ySize = 24, 15
		point,relativePoint,xPos,yPos = "TOP","BOTTOM",0,4
		left,right,top,bottom = 0,0.375,0,0.46875
	end
	
	self.arrow:SetSize(xSize,ySize)
	self.arrow:ClearAllPoints()
	self.arrow:SetPoint(point,self,relativePoint,xPos,yPos)
	self.arrow:SetTexCoord(left,right,top,bottom)
	self.arrow:Show()
end

local function SetIcon(self, spellID, isItem)
	local icon;
	
	if isItem then
		icon = select(10, GetItemInfo(spellID))
	else
		icon = select(3, GetSpellInfo(spellID))
	end

	if icon then
		self.icon:Show()
		self.tex:SetTexture(icon)
		self.tex:SetTexCoord(0.075,0.925,0.075,0.925)
	end
end

local function SetUnitIcon(self, unitID)
	local class = select(2, UnitClass(unitID))

	self.tex:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
	self.tex:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
	self.icon:Show()
end

local function CreateDivider(self, line)
	self.divider[line] = CreateFrame("Frame",nil,self)
	
	local divider = self.divider[line]
	divider:SetHeight(2)
	divider.tex = divider:CreateTexture(nil,"BACKGROUND")
	divider.tex:SetColorTexture(0,0,0)
	divider.tex:SetHeight(1)
	divider.tex:SetPoint("TOPLEFT")
	divider.tex:SetPoint("TOPRIGHT")
	divider.tex2 = divider:CreateTexture(nil,"BACKGROUND")
	divider.tex2:SetColorTexture(1,1,1,0.2)
	divider.tex2:SetHeight(1)
	divider.tex2:SetPoint("BOTTOMLEFT")
	divider.tex2:SetPoint("BOTTOMRIGHT")

	return divider
end

local function AddDivider(self)
	self:AddLine(" ")
	
	-- local line = self:NumLines()
	-- local relativeTo = _G[self:GetName().."TextLeft"..line]
	-- local divider = self.divider[line] or self:CreateDivider(line)

	-- divider:ClearAllPoints()
	-- divider:SetPoint("RIGHT",-10,0)
	-- divider:SetPoint("LEFT",relativeTo,0,1)
	-- divider:Show()
end

local function SetPrevLineJustify(self, justify)
	local index = self:NumLines()
	local line = _G[self:GetName().."TextLeft"..index]

	self.justify[line] = justify
end

local function OverwriteStyle(self)
	if not self.bgFile then
		local r,g,b,a = 1,1,1,1
		
		self.bgFile = CreateFrame("Frame",nil,self,"BackdropTemplate")
		self.bgFile:SetPoint("TOPLEFT",-5,5)
		self.bgFile:SetPoint("BOTTOMRIGHT",5,-5)
		self.bgFile:SetFrameLevel(self:GetFrameLevel())
		self.bgFile:SetBackdrop(backdrop)
		self.bgFile:SetBackdropColor(r,g,b,a)

		self:SetBackdrop({})
		self.SetBackdrop = function() end
		
		-- use a fake reference to inherit addon based tooltips
		self.GetBackdrop = function() return backdrop end
		self.GetBackdropColor = function() return r,g,b,a end
	end

	if self.BorderTop then
		self.BorderTopLeft:Hide()
		self.BorderTopRight:Hide()
		self.BorderBottomLeft:Hide()
		self.BorderBottomRight:Hide()
		self.BorderTop:Hide()
		self.BorderLeft:Hide()
		self.BorderRight:Hide()
		self.BorderBottom:Hide()
		self.Background:Hide()
	end
	
	-- Specific Hooks
	if self == FriendsTooltip then
		local fonts = {"Header","OtherGameAccounts","NoteText","BroadcastText","LastOnline","GameAccountMany","GameAccount1Name","GameAccount1Info","GameAccount2Name","GameAccount2Info","GameAccount3Name","GameAccount3Info","GameAccount4Name","GameAccount4Info","GameAccount5Name","GameAccount5Info"}
		
		for _, fontString in pairs(fonts) do
			_G[self:GetName()..fontString]:SetFontObject(font)
		end
	end

	if self == GameTooltip then
		for line, justify in pairs(self.justify) do
			local width = self:GetWidth()-20

			line:SetWidth(width)
			line:SetJustifyH(justify)
		end	
	end
	
	if self == ItemRefTooltip then
		local closeBtn = ItemRefCloseButton

		closeBtn:SetSize(17,17)
		closeBtn:ClearAllPoints()
		closeBtn:SetPoint("TOPRIGHT",-4,-4)
		closeBtn:SetNormalTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
		closeBtn:GetNormalTexture():SetAlpha(0.5)
		closeBtn:SetPushedTexture("")
		closeBtn:SetHighlightTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
		closeBtn:GetHighlightTexture():SetBlendMode("BLEND")
	end
end


-- Hooks
local function Hook_Reset(self)
	if self.icon then
		self.icon:Hide()
	end
	if self.arrow then
		self.arrow:Hide()
	end
	if self.justify then
		for line, justify in pairs(self.justify) do
			line:SetJustifyH("LEFT")
		end
		
		self.justify = {}
	end
	if self.divider then
		for line, divider in pairs(self.divider) do
			divider:Hide()
		end
	end

	self.spellLine = nil
	self.isTalent = nil
end

local function Hook_SetSpell(self)
	local spellID = select(3, self:GetSpell())
	local isTalent = self:GetOwner().isTalent
	
	if spellID and not isTalent then			
		self:SetIcon(spellID)
		
		if not self.spellLine then
			GameTooltip:AddDivider()
			GameTooltip:AddLine(format(SYNCUI_STRING_SPELLID, spellID),1,1,1)
			self.spellLine = true
		end
	end
end

local function Hook_SetItem(self)
	local name, link = self:GetItem()

	if name and link then
		local itemID = select(3, string.find(link, "item:(%d+)"))

		self:SetIcon(link, true)
		self:AddDivider()
		self:AddLine(format(SYNCUI_STRING_ITEMID, itemID),1,1,1)
		self:Show()
	end
end

local function Hook_SetUnit(self,unit)
	local name, unitID = self:GetUnit()
	
	if not unitID then
		unitID = GetMouseFocus() and GetMouseFocus():GetAttribute("unit")
	end
	
	if not unitID and UnitExists("mouseover") then
		unitID = "mouseover"
	end
	
	if not unitID then
		return
	end
	
	if UnitIsUnit(unitID,"mouseover") then
		unit = "mouseover"
	end
	
	if unitID and UnitIsPlayer(unitID) then
		local guid = UnitGUID(unitID)
		local class = select(2, GetPlayerInfoByGUID(guid))
		
		if class then
			local r,g,b = unpack(SYNCUI_CLASS_COLORS[class])
			local left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[class])
			local adjust = 0.02
			
			
			self.tex:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			self.tex:SetTexCoord(left+adjust,right-adjust,top+adjust,bottom-adjust)
			self.icon:Show()
			
			do	-- Color Name 
				local name, realm = UnitName(unitID)
				local titledName = UnitPVPName(unitID)
				local string = SyncUI_GetColorizedText(titledName or name,r,g,b)
				
				GameTooltipTextLeft1:SetText(string)
			end
			do	-- Color Guild
				local guildName = GetGuildInfo(unitID)
				
				if guildName then	
					GameTooltipTextLeft2:SetText(SyncUI_GetColorizedText(guildName,0.18,0.6,1))
				end
			end
			do	-- Color Character Info
				local guildName = GetGuildInfo(unitID)
				local level = UnitLevel(unitID)
				local race = UnitRace(unitID)
				local class = UnitClass(unitID)
				local classString = SyncUI_GetColorizedText(class,r,g,b)
				
				if level == -1 then
					level = "??"
				end
				
				local string = format(TOOLTIP_UNIT_LEVEL_RACE_CLASS,level,race,classString)
				
				if guildName then
					GameTooltipTextLeft3:SetText(string)
				else
					GameTooltipTextLeft2:SetText(string)
				end
			end

			GameTooltipStatusBar:SetStatusBarColor(r,g,b)
		else
			self.icon:Hide()
		end
	else
		self.icon:Hide()
	end
	
	if unitID then
		if unitID ~= "player" then
			local target = unitID.."target"
			local name, realm = UnitName(target)


			if target and name then
				if UnitIsUnit("player",target) then
					GameTooltip:AddLine(TARGET..": "..YOU,1,1,1)
				else
					if UnitIsPlayer(target) then
						local class = select(2, UnitClass(target))
						local r,g,b
						
						if class then
							r,g,b = unpack(SYNCUI_CLASS_COLORS[class])
						end
						
						if r and g and b then
							name = SyncUI_GetColorizedText(name,r,g,b)
						end
					elseif UnitIsEnemy("player", target) then
						name = SyncUI_GetColorizedText(name,1,0,0)
					elseif UnitIsFriend("player", target) then
						name = SyncUI_GetColorizedText(name,0,1,0)
					end

					GameTooltip:AddLine(TARGET..": "..(name or UNKNOWN),1,1,1)
				end
			end
		end
	end
end

local function Hook_SetUnitAura(self, unitID, index, filter)
	local spellID = select(11, UnitAura(unitID, index, filter))
	
	if spellID then
		self:AddDivider()
		self:AddLine(format(SYNCUI_STRING_AURAID, spellID),1,1,1)
		self:Show()
	end
end

local function Hook_SetDefaultAnchor(self, parent)
	if cursor and GetMouseFocus() == WorldFrame then
		self:SetOwner(parent, "ANCHOR_CURSOR")
	else
		self:SetOwner(parent, "ANCHOR_NONE")
		-- MARKED: might fix the anchor family connection thingy
		self:ClearAllPoints();
		self:SetPoint("BOTTOMRIGHT", "SyncUI_Tooltip", "TOPRIGHT")
		self.default = 1
	end
end

local function Hook_SetMoney(self)
	if not self.shownMoneyFrames then
		return
	end

	for i = 1, self.shownMoneyFrames do
		local moneyFrame = _G[self:GetName().."MoneyFrame"..i]
		
		if moneyFrame then
			local name = moneyFrame:GetName()
			local prefix, suffix, gBtn, sBtn, cBtn = _G[name.."PrefixText"], _G[name.."SuffixText"], _G[name.."GoldButtonText"], _G[name.."SilverButtonText"], _G[name.."CopperButtonText"]
			
			for _, frame in pairs({prefix,suffix,gBtn,sBtn,cBtn}) do
				frame:SetFontObject(font)
			end
		end
	end
end

local function Hook_ToggleDropDown(level)
	if not level then
		level = 1
	end
	local menu = _G["DropDownList"..level]
	local bgDrop = _G[menu:GetName().."MenuBackdrop"]

	OverwriteStyle(bgDrop)
	
	for index = 1, menu.numButtons do
		local button = _G[menu:GetName().."Button"..index]
		local yPos = select(5, button:GetPoint())
		
		button:SetNormalFontObject(font)
		button:SetHighlightFontObject(font)
		button:SetDisabledFontObject(font)
		
		_G[button:GetName().."ExpandArrow"]:SetPoint("TOPRIGHT", menu, -9, yPos)
		_G[button:GetName().."Icon"]:SetPoint("TOPRIGHT", menu, -11, yPos)
	end
end

local function Hook_SetButtonClickState(level, id)
	_G["DropDownList"..level.."Button"..id]:SetDisabledFontObject(font)
end


-- Tooltip API
local function Tooltip_SetHooks()
	--GameTooltip:HookScript("OnTooltipSetSpell", Hook_SetSpell)
	GameTooltip:HookScript("OnTooltipSetItem", Hook_SetItem)
	GameTooltip:HookScript("OnTooltipSetUnit", Hook_SetUnit)
	
	--hooksecurefunc(GameTooltip, "SetUnitAura", Hook_SetUnitAura)
	hooksecurefunc(GameTooltip, "SetOwner", Hook_Reset)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Hook_SetDefaultAnchor)
	hooksecurefunc("SetTooltipMoney", Hook_SetMoney)
	hooksecurefunc("ToggleDropDownMenu", Hook_ToggleDropDown)
	hooksecurefunc("UIDropDownMenu_SetButtonNotClickable", Hook_SetButtonClickState)
	hooksecurefunc("UIDropDownMenu_SetButtonClickable", Hook_SetButtonClickState)
end

local function Tooltip_AddWidgets()
	for _, tooltip in pairs(tooltips) do
		tooltip.justify = {}
		tooltip.divider = {}
		
		tooltip.SetArrow = SetArrow
		tooltip.SetIcon = SetIcon
		tooltip.SetUnitIcon = SetUnitIcon
		--tooltip.CreateDivider = CreateDivider
		tooltip.AddDivider = AddDivider
		tooltip.SetPrevLineJustify = SetPrevLineJustify
		tooltip:HookScript("OnShow", OverwriteStyle)
	end
end

local function Tooltip_AddObjects()
	GameTooltip.icon = CreateFrame("Frame", nil, GameTooltip, "SyncUI_LayerBackdropTemplate")
	GameTooltip.icon:SetSize(50,50)
	GameTooltip.icon:SetPoint("TOPRIGHT", GameTooltip, "TOPLEFT", 5, 5)
	GameTooltip.icon:Hide()
	
	GameTooltip.tex = GameTooltip.icon:CreateTexture(nil, "BORDER")
	GameTooltip.tex:SetPoint("TOPLEFT", 7, -7)
	GameTooltip.tex:SetPoint("BOTTOMRIGHT", -7, 7)
	
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", 3, 1)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", -3, 1)
	GameTooltipStatusBar:SetHeight(8)
	GameTooltipStatusBar:SetStatusBarTexture(SYNCUI_MEDIA_PATH.."Elements\\Tooltip-StatusBar")
	GameTooltipStatusBar:SetStatusBarColor(0,1,0)
	
	GameTooltip.arrow = GameTooltip:CreateTexture(nil, "BACKGROUND")
	GameTooltip.arrow:SetDrawLayer("BACKGROUND", 2)
	GameTooltip.arrow:SetSize(32, 32)
	GameTooltip.arrow:SetTexture(SYNCUI_MEDIA_PATH.."Elements\\Arrows")
	GameTooltip.arrow:Hide()
end

local function Tooltip_SetFonts()
	GameTooltipHeaderText:SetFontObject(font)
	GameTooltipText:SetFontObject(font)
	Tooltip_Small:SetFontObject(SyncUI_GameFontShadow_Small)
end

function SyncUI_Tooltip_OnLoad(self)
	SyncUI_RegisterDragFrame(self,SYNCUI_STRING_PLACEMENT_TOOL_LABEL_TOOLTIP)

	Tooltip_SetHooks()
	Tooltip_AddWidgets()
	Tooltip_AddObjects()
	Tooltip_SetFonts()
end

