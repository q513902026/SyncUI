
local specQuery;

local specID, DragFrames, defaultPos = 1, {}, {
	-- UnitFrames
	["SyncUI_PlayerFrame"] = {
		"BOTTOM",
		"SyncUI_ActionBar",
		"TOP",
		-220,
		185,
	},
	["SyncUI_TargetFrame"] = {
		"BOTTOM",
		"SyncUI_ActionBar",
		"TOP",
		220,
		185,
	},
	["SyncUI_FocusFrame"] = {
		"LEFT",
		"SyncUI_UIParent",
		"LEFT",
		250,
		0,
	},
	["SyncUI_PetFrame"] = {
		"TOPLEFT",
		"SyncUI_PlayerFrame",
		"BOTTOMLEFT",
		0,
		-45,
	},	
	["SyncUI_ToTFrame"] = {
		"LEFT",
		"SyncUI_TargetFrame",
		"RIGHT",
		0,
		0,
	},
	["SyncUI_ToFFrame"] = {
		"RIGHT",
		"SyncUI_FocusFrame",
		"LEFT",
		0,
		0,
	},
	["SyncUI_BossFrameContainer"] = {
		"TOPRIGHT",
		"SyncUI_UIParent",
		"TOPRIGHT",
		-100,
		-300,
	},
	["SyncUI_ArenaFrameContainer"] = {
		"RIGHT",
		"SyncUI_UIParent",
		"RIGHT",
		-150,
		50,
	},
	["SyncUI_PartyFrameContainer_Normal"] = {
		"TOPLEFT",
		"SyncUI_UIParent",
		"TOPLEFT",
		100,
		-300,
	},
	["SyncUI_PartyFrameContainer_Heal"] = {
		"BOTTOM",
		"SyncUI_MultiBar",
		"TOP",
		0,
		40,
	},
	["SyncUI_RaidFrameContainer_Heal"] = {
		"BOTTOMLEFT",
		"SyncUI_UIParent",
		"BOTTOMLEFT",
		20,
		275,
	},
	
	-- Other UI Elements
	["SyncUI_PlayerCastingBar"] = {
		"BOTTOM",
		"SyncUI_MultiBar",
		"TOP",
		0,
		10,
	},
	["SyncUI_PlayerFrameBuffHeader"] = {
		"TOPRIGHT",
		"SyncUI_UIParent",
		"TOPRIGHT",
		-195,
		-10,
	},
	["SyncUI_PlayerFrameDebuffHeader"] = {
		"RIGHT",
		"SyncUI_PlayerFrame",
		"LEFT",
		0,
		0,
	},
	["SyncUI_ResourceBar"] = {
		"TOP",
		"SyncUI_PlayerFrame",
		"BOTTOM",
		0,
		0,
	},
	["SyncUI_ReactiveAuraBar"] = {
		"BOTTOMRIGHT",
		"SyncUI_PlayerFrame",
		"TOPRIGHT",
		-1,
		3,
	},
	["SyncUI_ZoneAbilityFrame"] = {
		"BOTTOM",
		"SyncUI_ActionBar",
		"TOP",
		0,
		165,
	},
	["SyncUI_EnvironmentFrame"] = {
		"TOP",
		"SyncUI_UIParent",
		"TOP",
		0,
		-45,
	},
	["SyncUI_ReadyCheckWindow"] = {
		"TOPLEFT",
		"SyncUI_UIParent",
		"TOPLEFT",
		230,
		-15,
	},
	["SyncUI_WorldMarkerBar"] = {
		"TOP",
		"SyncUI_GroupControl",
		"BOTTOM",
		0,
		5,
	},
	["SyncUI_Tooltip"] = {
		"BOTTOMRIGHT",
		"SyncUI_UIParent",
		"BOTTOMRIGHT",
		-10,
		65,
	},
	["SyncUI_AlertFrame"] = {
		"TOP",
		"SyncUI_UIParent",
		"TOP",
		0,
		-100,
	},
	["SyncUI_LootFrame"] = {
		"TOPLEFT",
		"SyncUI_UIParent",
		"TOPLEFT",
		245,
		-200,
	},
	["SyncUI_ObjTracker"] = {
		"TOPRIGHT",
		"SyncUI_UIParent",
		"TOPRIGHT",
		-10,
		-200,
	},
	["SyncUI_Minimap"] = {
		"TOPRIGHT",
		"SyncUI_UIParent",
		"TOPRIGHT",
		-15,
		-25,
	},
	["SyncUI_SideBar"] = {
		"BOTTOMRIGHT",
		"SyncUI_UIParent",
		"BOTTOMRIGHT",
		-40,
		50,
	},
	["SyncUI_TalkingHead"] = {
		"TOP",
		"SyncUI_UIParent",
		"TOP",
		0,
		-50,
	},	
	
	--Blizzard Frames
	["VehicleSeatIndicator"] = {
		"BOTTOMRIGHT",
		"SyncUI_ActionBar",
		"BOTTOMLEFT",
		80,
		60,
	},
	
	-- ["DurabilityFrame"] = {
		-- "BOTTOMLEFT",
		-- "SyncUI_ActionBar",
		-- "BOTTOMRIGHT",
		-- -80,
		-- 60,
	-- },
}

local specialPos = {
	["SyncUI_PlayerFrame_CastingBar"] = {"BOTTOM","SyncUI_AlternatePowerBarFrame","TOP"}
}

local function GetDataBase(specID)
	local profile = SyncUI_GetProfile()
	
	return profile["FramePos"][specID]
end

local function isSpecial(frameName)
	local info = specialPos[frameName]
	
	if info then
		local point, relativeTo, relativePoint = unpack(info)
		return true, point, _G[relativeTo], relativePoint
	end
end

local function UpdateButtonText(button, specID)
	local text = select(2, GetSpecializationInfo(specID))
	local icon = select(4, GetSpecializationInfo(specID))
	local string = "|T"..icon..":18:18:0:0:64:64:5:59:5:59|t "..text
	
	button:SetText(string)
end

local function LoadFramePositions(specID)
	local dataBase = GetDataBase(specID)

	-- Pre Reset All Frame Positions
	for frameName, info in pairs(defaultPos) do
		local frame = _G[frameName]
		
		local isSpecial, point, relativeTo, relativePoint = isSpecial(frameName)
		
		if frame then
			frame:ClearAllPoints()
			
			if isSpecial and relativeTo and relativeTo:IsShown() then 
				frame:SetPoint(point, relativeTo, relativePoint)
			else
				frame:SetPoint(unpack(info))
			end
			
			frame.isPlaced = nil
		end
	end
	
	-- Load Saved Frame Positions
	for frameName, info in pairs(dataBase) do
		local frame = _G[frameName]

		if frame then
			frame:ClearAllPoints()
			frame:SetPoint(unpack(info))
			frame.isPlaced = true
		end
	end
end

local function ResetFramePositions()
	for parent, dragFrame in pairs(DragFrames) do
		local info = defaultPos[parent:GetName()]
		
		if info then
			local dataBase = GetDataBase(specID)
			
			dataBase[parent:GetName()] = nil
			parent.isPlaced = nil
			parent:ClearAllPoints()
			parent:SetPoint(unpack(info))
		end
	end
end

local function OnDragStart(self)
	local parent = self.parent
	
	self.Flashing:Play()
	
	parent:StartMoving()
	parent.isMoving = true	
end

local function OnDragStop(self)
	local parent = self.parent
	local dataBase = GetDataBase(specID)
	
	self.Flashing:Stop()
	
	parent:StopMovingOrSizing()
	parent:SetUserPlaced(false)
	parent.isMoving = false
	parent.isPlaced = true
	
	dataBase[parent:GetName()] = {parent:GetPoint()}
end


-- Frame Position
function SyncUI_LoadFramePosition(self)
	local frameName = self:GetName()
	local dataBase = GetDataBase(specID)	
	local defaultInfo = defaultPos[frameName]
	local savedInfo = dataBase[frameName]

	if savedInfo then
		self:ClearAllPoints()
		self:SetPoint(unpack(savedInfo))
	elseif defaultPos[self:GetName()] then
		self:ClearAllPoints()
		self:SetPoint(unpack(defaultInfo))
	end
end

function SyncUI_LoadFramePositions()
	specID = GetSpecialization() or 1
	LoadFramePositions(specID)
end


-- Drag Frames
function SyncUI_RegisterDragFrame(frame, headerText, securefunc, isGlowFrame)
	local dragFrame = CreateFrame("Button", nil, SyncUI_UIParent, "SyncUI_DragFrameTemplate")
	local adj = 0
	
	if isGlowFrame then
		adj = 10
	end
	
	dragFrame:Hide()
	dragFrame:SetPoint("TOPLEFT",frame,-adj,adj)
	dragFrame:SetPoint("BOTTOMRIGHT",frame,adj,-adj)
	dragFrame:SetScript("OnDragStart", OnDragStart)
	dragFrame:SetScript("OnDragStop", OnDragStop)
	dragFrame.Header:SetText(headerText)
	dragFrame.parent = frame
	dragFrame.name = headerText

	if securefunc then
		hooksecurefunc(frame, "SetPoint", function(self)
			local dataBase = SyncUI_Data and GetDataBase(specID)
			local info = dataBase and dataBase[self:GetName()]
			local point, relativeTo, relativePoint, xPos, yPos

			if info then	
				point, relativeTo, relativePoint, xPos, yPos = unpack(info)
			else
				point, relativeTo, relativePoint, xPos, yPos = unpack(defaultPos[self:GetName()])
			end

			self:ClearAllPoints()
			getmetatable(self).__index.SetPoint(self, point, relativeTo, relativePoint, xPos, yPos)
		end)
	end
	
	frame:SetClampedToScreen(true)
	frame:SetClampRectInsets(-(5+adj), (5+adj), (5+adj), -(35+adj))
	frame:SetMovable(true)
	frame.DragFrame = dragFrame

	DragFrames[frame] = frame.DragFrame
end

function SyncUI_UnregisterDragFrame(parent)
	DragFrames[parent] = nil
end

function SyncUI_DragFrame_OnEnter(self)
	GameTooltip_Hide()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:AddLine(self.name,1,1,1)
	GameTooltip:SetPrevLineJustify("CENTER")
	GameTooltip:AddDivider()
	GameTooltip:AddLine(SYNCUI_STRING_PLACEMENT_TOOL_DRAG_TO_MOVE,1,1,1)
	GameTooltip:AddLine(SYNCUI_STRING_PLACEMENT_TOOL_CLICK_TO_RESET,1,1,1)
	GameTooltip:Show()
	
	self.Border:SetColorTexture(1,1,1,0.5)
end

function SyncUI_DragFrame_OnLeave(self)
	GameTooltip_Hide()
	
	self.Border:SetColorTexture(0.4,1,0,0.5)
end

function SyncUI_DragFrame_OnClick(self,button)
	if button == "RightButton" and IsShiftKeyDown() then
		for parent, dragFrame in pairs(DragFrames) do
			if self == dragFrame then
				local info = defaultPos[parent:GetName()]
			
				if info then
					local dataBase = GetDataBase(specID)
					dataBase[parent:GetName()] = nil
					parent.isPlaced = false
					parent:ClearAllPoints()
					parent:SetPoint(unpack(info))
				end
			end
		end
	end
end


-- Placement Tool
local function SelectSpec(i)
	specID = i
	LoadFramePositions(specID)
	UpdateButtonText(SyncUI_PlacementTool.Select.DropDown, specID)
end

function SyncUI_PlacementTool_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:SetClampRectInsets(-15, 15, 15, -45)
	
	UIPanelWindows[self:GetName()] = { area = "center", pushable = 0, whileDead = 1 }
end

function SyncUI_PlacementTool_OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		specID = GetSpecialization() or 1
		LoadFramePositions(specID)
	end
	
	if event == "ACTIVE_TALENT_GROUP_CHANGED" then
		if not InCombatLockdown() then
			specID = GetSpecialization() or 1
			LoadFramePositions(specID)
		end
	end
	
	if event == "PLAYER_REGEN_DISABLED" then
		HideUIPanel(self)
	end
end

function SyncUI_PlacementTool_OnShow(self)
	for parent, dragFrame in pairs(DragFrames) do
		dragFrame:Show()
	end
	
	specID = GetSpecialization() or 1
	LoadFramePositions(specID)
	UpdateButtonText(self.Select.DropDown, specID)
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:ClearAllPoints()
	self:SetPoint("TOP",0,-200)
end

function SyncUI_PlacementTool_OnHide(self)
	for parent, dragFrame in pairs(DragFrames) do
		dragFrame:Hide()
		parent:StopMovingOrSizing()
		parent:SetUserPlaced(false)
	end

	if not InCombatLockdown() then
		specID = GetSpecialization() or 1
		LoadFramePositions(specID)
	end
	
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	StaticPopup_Hide("SYNCUI_RESET_POSITIONS")
	OptionsFrame_OnHide(self)
end

function SyncUI_PlacementTool_SelectSpec_InitDropDown(self)
	for i = 1, 4 do
		local numSpecs = GetNumSpecializations()

		if i <= numSpecs then
			local info = {}
			info.text = select(2, GetSpecializationInfo(i))
			info.icon = select(4, GetSpecializationInfo(i))
			info.tCoordLeft = 0.1
			info.tCoordRight = 0.9
			info.tCoordTop = 0.1
			info.tCoordBottom = 0.9
			info.height = 18
			info.clickFunc = function() SelectSpec(i) end
			SyncUI_DropDownMenu_AddButton(info)
		end
	end
end

function SyncUI_PlacementTool_CopySpec_InitDropDown(self)
	local profile = SyncUI_GetProfile()
	local dataBase = profile["FramePos"]
	local numSpecs = GetNumSpecializations()
	
	for i, data in pairs(dataBase) do
		if i ~= specID and i <= numSpecs then
			local _, text, _ , icon = GetSpecializationInfo(i)
			local info = {}
			info.text = select(2, GetSpecializationInfo(i))
			info.icon = select(4, GetSpecializationInfo(i))
			info.tCoordLeft = 0.1
			info.tCoordRight = 0.9
			info.tCoordTop = 0.1
			info.tCoordBottom = 0.9
			info.height = 18
			info.clickFunc = function()
				local text = select(2, GetSpecializationInfo(specID))
				local icon = select(4, GetSpecializationInfo(specID))
				
				specQuery = i
				UpdateButtonText(self:GetParent(), i)
				StaticPopup_Show("SYNCUI_COPYSPEC", icon, text)
			end
			SyncUI_DropDownMenu_AddButton(info)
		end
	end
end

StaticPopupDialogs["SYNCUI_RESET_POSITIONS"] = {
	text = SYNCUI_STRING_PLACEMENT_TOOL_RESET_POSITION,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ResetFramePositions()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["SYNCUI_COPYSPEC"] = {
	text = SYNCUI_STRING_PLACEMENT_TOOL_COPY_QUERY,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local profile = SyncUI_GetProfile()
		local dataBase = profile["FramePos"]

		dataBase[specID] = CopyTable(dataBase[specQuery])
		LoadFramePositions(specID)

		SyncUI_PlacementTool.Copy.DropDown:SetText("")
		specQuery = nil
	end,
	OnCancel = function()
		SyncUI_PlacementTool.Copy.DropDown:SetText("")
		specQuery = nil
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
