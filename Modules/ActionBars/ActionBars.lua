

local defaultPaging = "[overridebar] 14; [shapeshift] 13; [vehicleui] 12; [possessbar] 12; [bar:6] 6; [bar:5] 5; [bar:4] 4; [bar:3] 3; [bar:2] 2; [bonusbar:5] 11; [bonusbar:4] 10; [bonusbar:3] 9; [bonusbar:2] 8; [bonusbar:1] 7; 1"

local function HandleDefaultBars()
	SyncUI_DisableFrame(MainMenuBar)
	SyncUI_DisableFrame(MainMenuBarArtFrame)
	SyncUI_DisableFrame(OverrideActionBar)
	SyncUI_DisableFrame(MultiBarBottomLeft, true)
	SyncUI_DisableFrame(MultiBarBottomRight, true)
	SyncUI_DisableFrame(MultiBarLeft, true)
	SyncUI_DisableFrame(MultiBarRight, true)
	
	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	
	local bars = {"Action", "OverrideActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarLeft", "MultiBarRight"}
	
	for index, bar in pairs(bars) do
		local limit = (index == 2 and 6) or 12
		
		for i = 1, limit do
			local button = _G[bar.."Button"..i]
			
			if button then
				button:Hide()
				button:UnregisterAllEvents()
				button:SetAttribute("statehidden", true)
			end
		end
	end
end

local function GetStanceIcon(index)
	local class = select(2, UnitClass("player"))
	local icon;
	
	if index and index ~= 0 then
		formID = select(4, GetShapeshiftFormInfo(index));
		icon = select(3, GetSpellInfo(formID));
	end
	
	-- special class treatments
	if class == "DRUID" and IsStealthed() then	
		icon = select(3, GetSpellInfo(5215));
	end
	
	if class == "ROGUE" then
		if index == 1 then	-- stealth
			icon = select(3, GetSpellInfo(1784))
		elseif index == 2 then	-- Vanish + Shadow Dance
			for i = 1, 40 do
				local spellID = select(11, UnitBuff("player",i))
				
				if spellID == 51713 or spellID == 11327 then
					icon = select(3, GetSpellInfo(spellID))
					break
				end
			end
		end
	end

	if class == "SHAMAN" and index == 1 then
		icon = select(3, GetSpellInfo(2645))
	end
	
	if class == "WARRIOR" and index == 1 then
		local active = GetSpecialization()
		local specID;
		
		if active then
			specID = GetSpecializationInfo(active)
		end
		
		if specID then
			local choice = select(2, GetTalentRowSelectionInfo(7))
			
			if choice == 21 then
				icon = select(3, GetSpellInfo(156291))
			end
		end
	end

	return icon
end

local function ActionButton_Setup(self, buttonType)
	self.float = _G[self:GetName().."FloatingBG"]
	self.itemBorder = _G[self:GetName().."Border"]
	self.Normal = self:GetNormalTexture()
	self.Pushed = self:GetPushedTexture()
	self.Checked = self:GetCheckedTexture()
	self.Highlight = self:GetHighlightTexture()

	self:SetSize(42,42)

	if buttonType then
		self.buttonType = buttonType
	end

	-- Modify
	if self.icon then
		self.icon:SetTexCoord(0.075,0.925,0.075,0.925)
		self.icon:SetDrawLayer("BACKGROUND", 1)
	end
	if self.Checked then
		self.Checked:SetSize(46,46)
		self.Checked:ClearAllPoints()
		self.Checked:SetPoint("CENTER")
		self.Checked:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.Checked:SetTexCoord(0.734375,0.9140625,0,0.71875)
		self.Checked:SetBlendMode("BLEND")
		self.Checked:SetDrawLayer("ARTWORK")
	end
	if self.Highlight then
		self.Highlight:ClearAllPoints()
		self.Highlight:SetPoint("CENTER")
		self.Highlight:SetSize(40,40)
		self.Highlight:SetColorTexture(1,1,1,0.25)
	end
	if self.Name then
		self.Name:SetFontObject(SyncUI_GameFontNormal_Medium)
		self.Name:SetSize(42,10)
		self.Name:SetPoint("BOTTOM",0,1)
		self.Name:SetShadowOffset(0,0)	
	end
	if self.HotKey then
		self.HotKey:SetFontObject(SyncUI_GameFontNormal_Large)
		self.HotKey:SetSize(40,12)
		self.HotKey:ClearAllPoints()
		self.HotKey:SetPoint("TOPRIGHT",1,-3)
		self.HotKey:SetShadowColor(0,0,0)
		self.HotKey:SetShadowOffset(1,-1)
		self.HotKey:SetJustifyH("RIGHT")
	end
	if self.Count then
		self.Count:SetFontObject(SyncUI_GameFontNormal_Large)
		self.Count:SetSize(40,12)
		self.Count:ClearAllPoints()
		self.Count:SetPoint("BOTTOMRIGHT",0,1)
	end
	if self.FlyoutArrow then
		self.FlyoutArrow:SetSize(24,15)
		self.FlyoutArrow:SetTexture(SYNCUI_MEDIA_PATH.."Elements\\Arrows")
		self.FlyoutArrow:SetTexCoord(0.125,0.5,0.53125,1)
		self.FlyoutBorder:SetTexture("")
		self.FlyoutBorderShadow:SetTexture("")
	end
	if self.Cooldown then
		self.Cooldown:SetFontObject(SyncUI_GameFontNormal_Huge)
	end
	if self.cooldown then
		self.cooldown:ClearAllPoints()
		self.cooldown:SetPoint("TOPLEFT",1,-1)
		self.cooldown:SetPoint("BOTTOMRIGHT",-1,1)
		SyncUI_Cooldown_OnRegister(self.cooldown)
	end

	-- Kill
	if self.Normal then
		self.Normal:SetTexture("")
		self.Normal:SetAlpha(0)
	end
	if self.Pushed then
		self.Pushed:SetTexture("")
	end
	if self.Border then
		self.Border:SetTexture("")
	end
	if self.itemBorder then
		self.itemBorder:SetTexture("")
	end
	if self.style then
		self.style:SetAlpha(0)
	end
	if self.float then
		self.float:SetTexture("")
	end
	
	-- New
	if not self.bg then
		self.bg = self:CreateTexture(nil,"BACKGROUND")
		self.bg:SetSize(46,46)
		self.bg:SetPoint("CENTER",0,0)
		self.bg:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.bg:SetTexCoord(0.1953125,0.375,0,0.71875)
		self.bg:SetDrawLayer("BACKGROUND", -1)
	end
	if not self.border then
		self.border = self:CreateTexture(nil,"BORDER")
		self.border:SetSize(50,50)
		self.border:SetPoint("CENTER",0,0)
		self.border:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.border:SetTexCoord(0,0.1953125,0,0.78125)
	end
	if not self.glass then
		self.glass = self:CreateTexture(nil,"ARTWORK")
		self.glass:SetSize(46,46)
		self.glass:SetPoint("CENTER",0,0)
		self.glass:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.glass:SetTexCoord(0.5546875,0.734375,0,0.71875)
	end
	self:UpdateHotkeys(self.buttonType)
	--ActionButton_UpdateHotkeys(self, self.buttonType)
end

local function ActionButtonSmall_Setup(self, buttonType)
	self.float = _G[self:GetName().."FloatingBG"]
	self.itemBorder = _G[self:GetName().."Border"]
	self.Normal = self:GetNormalTexture()
	self.Pushed = self:GetPushedTexture()
	self.Checked = self:GetCheckedTexture()
	self.Highlight = self:GetHighlightTexture()
	
	self:SetSize(38,38)

	if buttonType then
		self.buttonType = buttonType
	end

	-- Modify
	if self.icon then
		self.icon:SetSize(32,32)
		self.icon:ClearAllPoints()
		self.icon:SetPoint("CENTER")
		self.icon:SetTexCoord(0.075,0.925,0.075,0.925)
		self.icon:SetDrawLayer("BACKGROUND", 1)
	end
	if self.Checked then
		self.Checked:SetTexture("")
		self.Checked:SetSize(38,38)
		self.Checked:ClearAllPoints()
		self.Checked:SetPoint("CENTER")
		self.Checked:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton_Small")
		self.Checked:SetTexCoord(0.4609375,0.609375,0,0.59375)
		self.Checked:SetBlendMode("BLEND")
		self.Checked:SetDrawLayer("ARTWORK")
	end
	if self.Highlight then
		self.Highlight:ClearAllPoints()
		self.Highlight:SetPoint("CENTER")
		self.Highlight:SetSize(32,32)
		self.Highlight:SetColorTexture(1,1,1,0.25)
	end
	if self.Name then
		self.Name:SetFontObject(SyncUI_GameFontNormal_Small)
		self.Name:SetSize(32,10)
		self.Name:SetPoint("BOTTOM",0,-1)
		self.Name:SetShadowOffset(0,0)
	end
	if self.HotKey then
		self.HotKey:SetFontObject(SyncUI_GameFontNormal_Medium)
		self.HotKey:SetSize(32,10)
		self.HotKey:ClearAllPoints()
		self.HotKey:SetPoint("TOPRIGHT",2,-1)
		self.HotKey:SetShadowColor(0,0,0)
		self.HotKey:SetShadowOffset(1,-1)
	end
	if self.Count then
		self.Count:SetFontObject(SyncUI_GameFontNormal_Medium)
		self.Count:SetSize(32,10)
		self.Count:ClearAllPoints()
		self.Count:SetPoint("BOTTOMRIGHT",1,0)
	end
	if self.FlyoutArrow then
		self.FlyoutArrow:SetSize(24,15)
		self.FlyoutArrow:SetTexture(SYNCUI_MEDIA_PATH.."Elements\\Arrows")
		self.FlyoutArrow:SetTexCoord(0.125,0.5,0.53125,1)
		self.FlyoutBorder:SetTexture("")
		self.FlyoutBorderShadow:SetTexture("")
	end
	if self.Cooldown then
		self.Cooldown:SetFontObject(SyncUI_GameFontNormal_Large)
	end
	if self.cooldown then
		self.cooldown:ClearAllPoints()
		self.cooldown:SetPoint("TOPLEFT", self.icon)
		self.cooldown:SetPoint("BOTTOMRIGHT", self.icon)
		SyncUI_Cooldown_OnRegister(self.cooldown)
	end
	
	-- Kill
	if self.Normal then
		self.Normal:SetTexture("")
		self.Normal:SetAlpha(0)
	end
	if self.Pushed then
		self.Pushed:SetTexture("")
	end
	if self.Border then
		self.Border:SetTexture("")
	end
	if self.itemBorder then
		self.itemBorder:SetTexture("")
	end
	if self.style then
		self.style:SetTexture("")
	end
	if self.float then
		self.float:SetTexture("")
	end
	
	-- New
	if not self.bg then
	self.bg = self:CreateTexture(nil,"BACKGROUND")
	self.bg:SetSize(38,38)
	self.bg:SetPoint("CENTER",0,0)
	self.bg:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton_Small")
	self.bg:SetTexCoord(0.1640625,0.3125,0,0.59375)
	self.bg:SetDrawLayer("BACKGROUND", -1)
	end
	if not self.border then
		self.border = self:CreateTexture(nil,"ARTWORK")
		self.border:SetSize(42,42)
		self.border:SetPoint("CENTER",0,0)
		self.border:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton_Small")
		self.border:SetTexCoord(0,0.1640625,0,0.65625)
	end
	if not self.glass then
		self.glass = self:CreateTexture(nil,"OVERLAY")
		self.glass:SetSize(38,38)
		self.glass:SetPoint("CENTER",0,0)
		self.glass:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton_Small")
		self.glass:SetTexCoord(0.3125,0.4609375,0,0.59375)
	end
	--self:UpdateHotkeys(self.buttonType)
	--ActionButton_UpdateHotkeys(self, self.buttonType)
end

local function ExtraActionButton_Setup(self)
	ExtraActionBarFrame:SetParent(self)
	ExtraActionBarFrame:SetToplevel(true)
	ExtraActionBarFrame:SetSize(84,58)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER",self.ExitButton)
	ExtraActionBarFrame.ignoreFramePositionManager = true
	
	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		
		if button then
			ActionButton_Setup(button, "EXTRAACTIONBUTTON")
		end
	end
end

local function BattlePetActionButton_Setup(self,isPetAction)
	if not self.setup then
		self.Highlight = self:GetHighlightTexture()

		self:SetSize(42,42)
		self:SetNormalTexture("")
		self:SetPushedTexture("")
		self.Icon:SetTexCoord(0.075,0.925,0.075,0.925)

		if not isPetAction then
			self.Checked = self:GetCheckedTexture()
			self.Checked:SetSize(46,46)
			self.Checked:ClearAllPoints()
			self.Checked:SetPoint("CENTER")
			self.Checked:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
			self.Checked:SetTexCoord(0.734375,0.9140625,0,0.71875)
			self.Checked:SetBlendMode("BLEND")
		end
		
		if self.Highlight then
			self.Highlight:ClearAllPoints()
			self.Highlight:SetPoint("CENTER")
			self.Highlight:SetSize(40,40)
			self.Highlight:SetColorTexture(1,1,1,0.25)
		end

		if self.HotKey then
			self.HotKey:SetFontObject(SyncUI_GameFontNormal_Large)
			self.HotKey:ClearAllPoints()
			self.HotKey:SetPoint("TOPRIGHT",1,-3)
			self.HotKey:SetShadowColor(0,0,0)
			self.HotKey:SetShadowOffset(1,-1)
		end

		if self.SelectedHighlight then
			self.SelectedHighlight:SetSize(46,46)
			self.SelectedHighlight:ClearAllPoints()
			self.SelectedHighlight:SetPoint("CENTER")
			self.SelectedHighlight:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
			self.SelectedHighlight:SetTexCoord(0.734375,0.9140625,0,0.71875)
			self.SelectedHighlight:SetBlendMode("BLEND")
		end

		self.bg = self:CreateTexture(nil,"BACKGROUND")
		self.bg:SetSize(46,46)
		self.bg:SetPoint("CENTER",0,0)
		self.bg:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.bg:SetTexCoord(0.1953125,0.375,0,0.71875)
		self.bg:SetDrawLayer("BACKGROUND", -1)
		
		self.border = self:CreateTexture(nil,"ARTWORK")
		self.border:SetSize(50,50)
		self.border:SetPoint("CENTER",0,0)
		self.border:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.border:SetTexCoord(0,0.1953125,0,0.78125)
		
		self.glass = self:CreateTexture(nil,"OVERLAY")
		self.glass:SetSize(46,46)
		self.glass:SetPoint("CENTER",0,0)
		self.glass:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.glass:SetTexCoord(0.5546875,0.734375,0,0.71875)
	end	

	if self.Lock then
		self.Lock:SetSize(20,22)
		self.Lock:ClearAllPoints()
		self.Lock:SetPoint("CENTER")
		self.Lock:SetTexture(SYNCUI_MEDIA_PATH.."ActionBars\\ActionButton")
		self.Lock:SetTexCoord(0.9140625,0.9921875,0,0.34375)
	end
	
	if self.Cooldown then
		self.Cooldown:SetFontObject(SyncUI_GameFontNormal_Huge)
	end

	if self.CooldownFlash then
		self.CooldownFlash:Hide()
	end
	
	self.setup = true
end

local function ExitButton_Disable(self)
	self:SetButtonState("DISABLED", true)
	self.Chip:Show()
	self.Lock:Show()
	self.Icon:Hide()
end

local function ExitButton_Enable(self)
	self:SetButtonState("NORMAL")
	self.Chip:Hide()
	self.Lock:Hide()
	self.Icon:Show()
end


HandleDefaultBars()



function SyncUI_ActionBar_OnLoad(self)
	--DurabilityFrame:ClearAllPoints();
	--DurabilityFrame:SetPoint("BOTTOMLEFT", SyncUI_ActionBar, "BOTTOMRIGHT", -80, 60);
	--SyncUI_RegisterDragFrame(DurabilityFrame, DURABILITY, true, false)
		
	self:RegisterEvent("TAXIMAP_OPENED")
	self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
	self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

	ExtraActionButton_Setup(self)
	
	for i = 1, 12 do
		self:SetFrameRef("Button"..i, self["Button"..i])
	end
	
	self:SetFrameRef("MainBar", MainMenuBarArtFrame)
	self:SetFrameRef("OverrideBar", OverrideActionBar)
	self:SetAttribute("_onstate-page", [[
		for i = 1, 12 do
			local button = self:GetFrameRef("Button"..i)
			local action = button:GetAttribute("buttonID")
			local newAction = action + ((newstate-1) * 12)
			
			button:SetAttribute("action", newAction)
		end
		
		self:GetFrameRef("MainBar"):SetAttribute("actionpage", newstate)
		self:GetFrameRef("OverrideBar"):SetAttribute("actionpage", newstate)
	]])	
	RegisterStateDriver(self, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")
	RegisterStateDriver(self, "page", defaultPaging)

	if UnitOnTaxi("player") then
		self.ExitButton:Hide()
		self.SkipButton:Show()
		self:RegisterEvent("PLAYER_CONTROL_GAINED")		
	end
	if UnitInVehicle("player") then
		ExitButton_Enable(self.ExitButton)
	end
end

function SyncUI_ActionBar_OnEvent(self,event,...)
	if event == "UNIT_ENTERED_VEHICLE" then
		ExitButton_Enable(self.ExitButton)
	end
	if event == "UNIT_EXITED_VEHICLE" then
		ExitButton_Disable(self.ExitButton)
	end

	if event == "TAXIMAP_OPENED" then
		self:RegisterEvent("PLAYER_CONTROL_LOST")
	end	
	if event == "PLAYER_CONTROL_LOST" then
		self.SkipButton:Show()
		self.ExitButton:Hide()
		self:RegisterEvent("PLAYER_CONTROL_GAINED")
		self:UnregisterEvent("PLAYER_CONTROL_LOST")
	end
	if event == "PLAYER_CONTROL_GAINED" then
		self.SkipButton:Hide()
		self.ExitButton:Show()
		ExitButton_Disable(self.ExitButton)
		self:UnregisterEvent("PLAYER_CONTROL_GAINED")
	end
end

function SyncUI_SideBar_OnLoad(self)
	SyncUI_RegisterDragFrame(self, "Side Bar")

	self:EnableMouseWheel()
	
	do	-- Register MouseWheel
		self:EnableMouseWheel(true)
		self:SetFrameRef("Bar1",self.Bar1)
		self:SetFrameRef("Bar2",self.Bar2)
		self:SetFrameRef("Bar3",self.Bar3)
		self:SetFrameRef("ScrollUp",self.ScrollUp)
		self:SetFrameRef("ScrollDown",self.ScrollDown)
		self:SetAttribute("_onmousewheel", [[
			local bar1 = self:GetFrameRef("Bar1")
			local bar2 = self:GetFrameRef("Bar2")
			local bar3 = self:GetFrameRef("Bar3")
			
			if delta > 0 then	-- scroll up
				if bar1:IsShown() then
					bar1:Hide()
					bar3:Hide()
					bar2:Show()
				elseif bar2:IsShown() then
					bar1:Hide()
					bar2:Hide()
					bar3:Show()
				--elseif bar3:IsShown() then
					--bar2:Hide()
					--bar3:Hide()
					--bar1:Show()
				end
			else	-- scroll down
				if bar3:IsShown() then
					bar1:Hide()
					bar3:Hide()
					bar2:Show()
				elseif bar2:IsShown() then
					bar2:Hide()
					bar3:Hide()
					bar1:Show()
				--elseif bar1:IsShown() then
					--bar1:Hide()
					--bar2:Hide()
					--bar3:Show()
				end
			end
		]])
	end
	do	-- Register ScrollUp Button
		self.ScrollUp:RegisterForClicks('LeftButtonUp')
		self.ScrollUp:SetAttribute("_onclick", [[
			local bar1 = self:GetFrameRef("Bar1")
			local bar2 = self:GetFrameRef("Bar2")
			local bar3 = self:GetFrameRef("Bar3")
			
			if button == "LeftButton" then
				if bar1:IsShown() then
					bar1:Hide()
					bar3:Hide()
					bar2:Show()
				elseif bar2:IsShown() then
					bar1:Hide()
					bar2:Hide()
					bar3:Show()
				elseif bar3:IsShown() then
					bar2:Hide()
					bar3:Hide()
					bar1:Show()
				end
			end
		]])
		self.ScrollUp:SetFrameRef("Bar1",self.Bar1)
		self.ScrollUp:SetFrameRef("Bar2",self.Bar2)
		self.ScrollUp:SetFrameRef("Bar3",self.Bar3)
	end
	do	-- Register ScrollDown Button
		self.ScrollDown:RegisterForClicks('LeftButtonUp')
		self.ScrollDown:SetAttribute("_onclick", [[
			local bar1 = self:GetFrameRef("Bar1")
			local bar2 = self:GetFrameRef("Bar2")
			local bar3 = self:GetFrameRef("Bar3")
			
			if button == "LeftButton" then
				if bar3:IsShown() then
					bar1:Hide()
					bar3:Hide()
					bar2:Show()
				elseif bar2:IsShown() then
					bar2:Hide()
					bar3:Hide()
					bar1:Show()
				elseif bar1:IsShown() then
					bar1:Hide()
					bar2:Hide()
					bar3:Show()
				end
			end
		]])
		self.ScrollDown:SetFrameRef("Bar1",self.Bar1)
		self.ScrollDown:SetFrameRef("Bar2",self.Bar2)
		self.ScrollDown:SetFrameRef("Bar3",self.Bar3)
	end
end

function SyncUI_VehicleBar_OnLoad(self)
	VehicleSeatIndicator:ClearAllPoints();
	VehicleSeatIndicator:SetPoint("BOTTOMRIGHT", SyncUI_ActionBar, "BOTTOMLEFT", 80, 60);
	VehicleSeatIndicator.SetPoint = function() end
	SyncUI_RegisterDragFrame(VehicleSeatIndicator, SYNCUI_STRING_PLACEMENT_TOOL_LABEL_VEHICLE, true)
	
	for i = 1, 6 do
		local button = self["Button"..i]
		self:SetFrameRef("Button"..i, button)
	end
	self:SetAttribute("_onstate-page", [[
		for i = 1, 6 do
			local button = self:GetFrameRef("Button"..i)
			local newAction = i + ((newstate-1) * 12)

			button:SetAttribute("action", newAction)
		end
	]])
	RegisterStateDriver(self, "visibility", "[petbattle] hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")
	RegisterStateDriver(self, "page", defaultPaging)
	RegisterStateDriver(OverrideActionBar, "visibility", "[overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")		
end


function SyncUI_PetBar_OnLoad(self)
	RegisterStateDriver(self, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; [@pet,exists] show; hide")
end

function SyncUI_PetBattleBar_OnLoad(self)
	self:RegisterEvent("PET_BATTLE_OPENING_START")
	self:RegisterEvent("PET_BATTLE_OPENING_DONE")
	--self:RegisterEvent("PET_BATTLE_TURN_STARTED")
	self:RegisterEvent("PET_BATTLE_PET_CHANGED")
	
	RegisterStateDriver(self, "visibility", "[petbattle] show; hide")
	
	PetBattleFrame:SetParent(self)

	do	-- CleanUp()
		local frame = PetBattleFrame.BottomFrame

		frame.Background:Hide()
		frame.RightEndCap:Hide()
		frame.LeftEndCap:Hide()
		frame.FlowFrame:Hide()
		frame.Delimiter:Hide()
		frame.TurnTimer:Hide()
		frame.TurnTimer:ClearAllPoints()
		frame.TurnTimer:SetPoint("BOTTOM",self,"TOP",0,-20)
		frame.MicroButtonFrame:Hide();
	end
end

function SyncUI_PetBattleBar_OnEvent(self)
	local frame = PetBattleFrame.BottomFrame;
	local dataBase = frame.abilityButtons;
	local dataBase2 = {"SwitchPetButton", "CatchButton", "ForfeitButton"};
	
	frame:SetSize(568, 56);
	xPos, yPos = 120, 28;
	
	for i, value in pairs(dataBase) do
		local button = dataBase[i];

		button:ClearAllPoints();
		button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", xPos + 46 * (i-1), yPos);
		button:SetFrameStrata("MEDIUM");
		
		BattlePetActionButton_Setup(button, true)
	end

	for i, value in pairs(dataBase2) do
		local button = frame[value];

		button:ClearAllPoints();
		button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", xPos + 46 * (i + 2), yPos);
		button:SetFrameStrata("MEDIUM");
		
		BattlePetActionButton_Setup(button, i > 1);
	end
	
	PetBattleFrameXPBar:Hide()
end


function SyncUI_StanceBar_OnLoad(self)
	SyncUI_StanceButton_OnLoad(self:GetParent().StanceButton)

	for i = 1, 10 do
		local button = _G["StanceButton"..i]

		button:SetParent(self)
		button:ClearAllPoints()
		button:SetPoint("BOTTOM", self, 0, 38*(i-1))
		
		ActionButtonSmall_Setup(button, "SHAPESHIFTBUTTON")
	end
end

function SyncUI_StanceButton_OnLoad(self)
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	
	self:SetAttribute("_onclick",[[
		local frame = self:GetFrameRef("Bar")

		if frame:IsShown() then
			frame:Hide()
		else
			frame:Show()
		end
	]])
	self:SetAttribute("_onstate-combat", "self:GetFrameRef('Bar'):Hide()")
	self:SetAttribute("_onstate-stance", "self:GetFrameRef('Bar'):Hide()")
	self:SetFrameRef("Bar", SyncUI_StanceBar)
	
	RegisterStateDriver(self, "combat", "[nocombat] 0; [combat] 1;")
	RegisterStateDriver(self, "stance", "[stance:1] 1; [stance:2] 2; [stance:3] 3; [stance:4] 4; [stance:5] 5;")
end

function SyncUI_StanceButton_OnEvent(self,event,...)
	if InCombatLockdown() then return end

	local numForms = GetNumShapeshiftForms()
	
	if numForms > 0 then
		self:EnableMouse(true)
		self.Lock:Hide()
	else
		self:EnableMouse(false)
		self.Lock:Show()
		self.Icon:Hide()
		
		SyncUI_StanceBar:Hide()
	end
end

function SyncUI_StanceButton_OnUpdate(self)
	local class = select(2, UnitClass("player"))
	local numForms = GetNumShapeshiftForms();

	if class == "SHAMAN" then
		numForms = 1
	end

	if numForms > 0 then
		local form = GetShapeshiftForm()
		local icon = GetStanceIcon(form)

		if icon then
			self.Icon:Show()
			self.Icon:SetTexture(icon)
		else
			self.Icon:Hide()
		end
	end
end

function SyncUI_StanceButton_OnEnter(self)
	
end


function SyncUI_MultiBarToggle_OnLoad(self)
	self:SetFrameRef("Bar", SyncUI_MultiBar)
	self:RegisterForClicks('LeftButtonUp')
	self:SetAttribute("_onclick", [[
		local bar = self:GetFrameRef("Bar")
		
		if button == "LeftButton" then
			if bar:IsShown() then
				bar:Hide()
				self:ClearAllPoints()
				self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, -6)
			else
				bar:Show()
				self:ClearAllPoints()
				self:SetPoint("BOTTOM", bar, "TOP", 0, -6)
			end
		end
	]])
	self:HookScript("OnClick", function()
		if SyncUI_MultiBar:IsShown() then
			self:SetNormalTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Down]])
			self:SetPushedTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Down]])
			self.SlideIn:Play()
			SyncUI_CharData.MultiBarToggle = true
		else
			self:SetNormalTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Up]])
			self:SetPushedTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Up]])
			SyncUI_CharData.MultiBarToggle = false
		end
	end)

	RegisterStateDriver(self, "visibility", "[mod:shift] show; hide")
end

function SyncUI_SideBarToggle_OnLoad(self)
	self:SetFrameRef("Bar", SyncUI_SideBar)
	self:RegisterForClicks('LeftButtonUp')
	self:SetAttribute("_onclick", [[
		local bar = self:GetFrameRef("Bar")
		
		if button == "LeftButton" then
			if bar:IsShown() then
				bar:Hide()
			else
				bar:Show()
			end
		end
	]])
	self:HookScript("OnClick", function()
		if SyncUI_SideBar:IsShown() then
			self:SetNormalTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Down]])
			self:SetPushedTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Down]])
			SyncUI_CharData.SideBarToggle = false
		else
			self:SetNormalTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Up]])
			self:SetPushedTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Up]])
			SyncUI_CharData.SideBarToggle = true
		end
	end)

	RegisterStateDriver(self, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")
	setglobal("BINDING_NAME_CLICK SyncUI_SideBarToggle:LeftButton", SYNCUI_STRING_BINDING_TOGGLE_SIDEBAR)
end

