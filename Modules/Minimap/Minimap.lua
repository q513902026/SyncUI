
local _G = _G
local tinsert = table.insert
local maxMinimapButtons = 12
local mmbSize = 20
local PreButtonList, ButtonList, IgnoreList = {}, {}, {
	"MiniMapWorldMapButton",
	"MiniMapRecordingButton",
	"MiniMapVoiceChatFrame",
	"MinimapZoomIn",
	"MinimapZoomOut",
	"TimeManagerClockButton",
	"GameTimeFrame",
	
	-- AddOn Stuff
	"HandyNotesPin",
	"GatherNote",
	"GatherMatePin",
	"ExplorerCoordsMinimapTargetFrame",
	"ZGVMarker",
}
local FuckUp_AddOnButtons = {
	"BagSync_MinimapButton",
	"LSItemTrackerMinimapButton",
}


-- Minimap
local function CleanUp()
	local frames = {
		"MiniMapWorldMapButton",
		"MinimapZoneTextButton",
		"MiniMapMailFrame",
		"MinimapNorthTag",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MinimapBackdrop",
		"GameTimeFrame",
		"MinimapBorderTop",
	}
	for _, frame in pairs(frames) do
		_G[frame]:Hide()
		_G[frame].Show = function() end
	end
	
	SyncUI_DisableFrame(MiniMapInstanceDifficulty,ignore)
	SyncUI_DisableFrame(GuildInstanceDifficulty,ignore)
	SyncUI_DisableFrame(MiniMapChallengeMode,ignore)	
end

local function SetupStyle(self)
    MinimapCluster:EnableMouse(false)
	Minimap:SetParent(self)
	Minimap:SetSize(175,175)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPLEFT",-10,10)
	Minimap:SetMaskTexture(SYNCUI_MEDIA_PATH.."Minimap-Mask")
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(_, zoom)
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	UIParent:HookScript("OnShow",function()
		Minimap:Show()
	end)
	UIParent:HookScript("OnHide",function()
		Minimap:Hide()
	end)
end

local function GetDungeonText()
	local instance, type = select(2, GetInstanceInfo())
	--local currentZoneID = select(8,  GetInstanceInfo())
	local text = ""
	
	-- Normal
	if type == 1 or type == 3 or type == 4 or type == 12 or type == 14 then
		text = PLAYER_DIFFICULTY1
	end

	-- Heroic
	if type == 2 or type == 5 or type == 6 or type == 11 or type == 15 then
		text = PLAYER_DIFFICULTY2
	end
	
	-- Mythic
	if type == 16 or type == 23 then
		text = PLAYER_DIFFICULTY6
	end
	
	-- Mythic + (challenge mode)
	if type == 8 then
		local level = C_ChallengeMode.GetActiveKeystoneInfo();
		text = PLAYER_DIFFICULTY6.."+ "..level
	end

	-- Timewalking
	if type == 24 then
		text = PLAYER_DIFFICULTY_TIMEWALKER
	end
	
	-- Raid Finder
	if type == 7 or type == 17 then
		text = PLAYER_DIFFICULTY3
	end
	
	-- 10 Man
	if type == 3 or type == 5 then
		text = text.." (10)"
	end
	
	-- 25 Man
	if type == 4 or type == 6 then
		text = text.." (25)"
	end

	-- 40 Man
	if type == 9 then
		text = "(40)"
	end

	-- Arena
	if instance == "arena" then
		if IsArenaSkirmish then
			text = ARENA_CASUAL
		else
			text = ARENA
		end
	end
		
	return text
end

function SyncUI_Minimap_OnLoad(self)
	CleanUp()
	SetupStyle(self)
	
	SyncUI_RegisterDragFrame(self,MINIMAP_LABEL,nil,true)
end

function SyncUI_Minimap_Mail_OnEvent(self, event, ...)
	if event == "UPDATE_PENDING_MAIL" then
		if HasNewMail() then
			self:Show()
			
			if GameTooltip:IsOwned(self) then
				MinimapMailFrameUpdate()
			end
		else
			self:Hide()
		end
	end
	
	if event == "MAIL_CLOSED" then
		local numInboxItems = select(2, GetInboxNumItems())
		
		if HasNewMail() and numInboxItems == 0 then
			self:Hide()
		end
	end
end

function SyncUI_Minimap_Mail_OnEnter(self)
	local s1, s2, s3 = GetLatestThreeSenders()
	local text;
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")

	if s1 or s2 or s3 then
		text = HAVE_MAIL_FROM
	else
		text = HAVE_MAIL
	end
	if s1 then
		text = text.."\n"..s1
	end
	if s2 then
		text = text.."\n"..s2
	end
	if s3 then
		text = text.."\n"..s3
	end
	
	GameTooltip:SetText(text, 1,1,1)
end

function SyncUI_Minimap_Instance_OnEvent(self, event, ...)
	if IsInInstance() then
		self.Text:SetText(GetDungeonText())
	else
		self.Text:SetText("")
	end
end

function SyncUI_Minimap_Zone_OnEnter(self)
	local pvpType, _, factionName = GetZonePVPInfo()
    local zone, subZone = GetZoneText(), GetSubZoneText()
	
    if subZone == zone then
		subZone = ""
    end
	
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")	
    GameTooltip:AddLine(zone, 1,1,1)
	
	if pvpType == "sanctuary" then
		GameTooltip:AddLine(subZone, 0.41,0.8,0.94)
		GameTooltip:AddLine(SANCTUARY_TERRITORY, 0.41,0.8,0.94)
	elseif pvpType == "arena" then
		GameTooltip:AddLine(subZone, 1,0.1,0.1)
		GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, 1,0.1,0.1)
	elseif pvpType == "friendly" then
		GameTooltip:AddLine(subZone, 0.1,1,0.1)
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY,factionName),0.1,1,0.1)
	elseif pvpType == "hostile" then
		GameTooltip:AddLine(subZone, 1,0.1,0.1)
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY,factionName),1,0.1,0.1)
	elseif pvpType == "contested" then
		GameTooltip:AddLine(subZone, 1,0.7,0.)
		GameTooltip:AddLine(CONTESTED_TERRITORY, 1.0, 0.7, 0.0)
	elseif pvpType == "combat" then
		GameTooltip:AddLine(subZone, 1,0.1,0.1)
		GameTooltip:AddLine(COMBAT_ZONE, 1,0.1,0.1)
	else
		GameTooltip:AddLine(subZone, 1,1,1)
	end
	
    GameTooltip:Show()
end

function SyncUI_Minimap_Garrison_OnLoad(self)
	self:RegisterEvent("GARRISON_SHOW_LANDING_PAGE")
	self:RegisterEvent("GARRISON_HIDE_LANDING_PAGE")
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE")
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATED")
	self:RegisterEvent("GARRISON_ARCHITECT_OPENED")
	self:RegisterEvent("GARRISON_MISSION_FINISHED")
	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED")
	self:RegisterEvent("GARRISON_SHIPYARD_NPC_OPENED")
	self:RegisterEvent("GARRISON_INVASION_AVAILABLE")
	self:RegisterEvent("GARRISON_INVASION_UNAVAILABLE")
	self:RegisterEvent("SHIPMENT_UPDATE")
	
	hooksecurefunc("GarrisonMinimap_ClearPulse", function()
		self.Notification:Hide()
	end)
end

function SyncUI_Minimap_Garrison_OnEvent(self, event, ...)
	if event == "GARRISON_HIDE_LANDING_PAGE" then
		self:Hide()
	elseif event == "GARRISON_SHOW_LANDING_PAGE" then
		self:Show()
	elseif event == "GARRISON_BUILDING_ACTIVATABLE" then
		self.Notification:Show()
	elseif event == "GARRISON_BUILDING_ACTIVATED" or event == "GARRISON_ARCHITECT_OPENED" then
		self.Notification:Hide()
	elseif event == "GARRISON_MISSION_FINISHED" then
		self.Notification:Show()
	elseif event == "GARRISON_MISSION_NPC_OPENED" then
		self.Notification:Hide()
	elseif event == "GARRISON_SHIPYARD_NPC_OPENED" then
		self.Notification:Hide()
	elseif event == "GARRISON_INVASION_AVAILABLE" then
		self.Notification:Show()
	elseif event == "GARRISON_INVASION_UNAVAILABLE" then
		self.Notification:Hide()
	elseif event == "SHIPMENT_UPDATE" then
		local shipmentStarted = ...
		if shipmentStarted then
			self.Notification:Show()
		end
	end
end

function SyncUI_Minimap_Queue_OnLoad(self)
	local frame = QueueStatusMinimapButton
	
	frame:SetParent(self)
	frame:SetSize(16,16)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER")
	frame:SetNormalTexture([[Interface\AddOns\SyncUI\Media\Textures\Icons\Eye]])
	frame:GetNormalTexture():SetVertexColor(0.75,0.75,0.75)
	frame:SetHighlightTexture([[Interface\AddOns\SyncUI\Media\Textures\Icons\Eye]])
	frame:GetHighlightTexture():SetBlendMode("BLEND")
	frame.Eye:Hide()
	
	QueueStatusMinimapButtonBorder:Hide()
end


-- Minimap Button Frame
local function IsFuckUpButton(button)
	for _, name in pairs(FuckUp_AddOnButtons)	do
		if button:GetName():find(name) then
			return true
		end
	end	
end

local function HasChildButton(parent)
	for _, child in pairs({parent:GetChildren()}) do
		local name = child:GetName()
		local type = child:GetObjectType()
		
		if name and type and child:HasScript("OnClick") then
			parent.childButton = child
			return child
		end
	end
end

local function RegisterButton(button)
	local name = button:GetName()
	local type = button:GetObjectType()

	-- filter bad buttons!
	if name and type then
		if tContains(PreButtonList, button) then
			return
		end

		if IsFuckUpButton(button) then
			-- do nothing, cause the button sucks!
		else
			if type ~= "Button" and ( type == "Frame" and not HasChildButton(button) ) then
				return
			end

			for _, ref in pairs(IgnoreList) do
				if name:find(ref) then
					return
				end
			end
		end
	else
		return
	end

	-- hook good buttons
	if not button.isHooked then
		button:SetScript("OnShow", function(self)
			if self.childButton then self.childButton:Show() end
			SyncUI_Minimap.ButtonFrame.forceUpdate = true
		end)
		button:SetScript("OnHide", function(self)
			if self.childButton then self.childButton:Hide() end
			SyncUI_Minimap.ButtonFrame.forceUpdate = true
		end)
		button.isHooked = true
	end

	tinsert(PreButtonList,button)
end

local function SkinButton(index, button)
	local parent = SyncUI_Minimap.ButtonFrame["Button"..index]
	
	if button.childButton then	-- overwrite button children
		button = button.childButton
	end
	
	if parent then
		do	-- fix fuck up buttons
			if button == BattlegroundTargets_MinimapButton then
				local pushed = button:GetPushedTexture()
				pushed:SetSize(mmbSize,mmbSize)
				pushed:SetTexCoord(0,1,0,1)
				pushed:ClearAllPoints()
				pushed:SetPoint("CENTER")
			end
			if button == BagSync_MinimapButton then
				button.texture = bgMinimapButtonTexture
				button.texture:SetTexture("Interface\\Icons\\inv_misc_bag_10_green")
			end
		end
		do	-- setup button itself
			parent:SetAlpha(1)
			
			button:SetParent(parent)
			button:SetToplevel(false)
			button:SetSize(mmbSize,mmbSize)
			button:ClearAllPoints()
			button:SetPoint("CENTER",parent,0,0)
			button:SetHitRectInsets(0,0,0,0)
			button:RegisterForDrag()
		end
		do	-- setup highlight
			local type = button:GetObjectType()
			
			if type == "Button" then
				local highlight = button:GetHighlightTexture()
				
				if highlight then
					highlight:ClearAllPoints()
					highlight:SetPoint("TOPLEFT")
					highlight:SetPoint("BOTTOMRIGHT")
					highlight:SetColorTexture(1,1,1,0.25)
				end
			end
			
			if type == "Frame" then
				if not button.highlight then
					button.highlight = button:CreateTexture(nil,"OVERLAY")
					button.highlight:SetColorTexture(1,1,1,0.25)
					button.highlight:SetPoint("TOPLEFT")
					button.highlight:SetPoint("BOTTOMRIGHT")
					button.highlight:Hide()
					
					button:HookScript("OnEnter",function(self)
						self.highlight:Show()
					end)
					button:HookScript("OnLeave",function(self)
						self.highlight:Hide()
					end)
				end
			end
		end
		do	-- setup icon
			local icon = button.icon or button.Icon or button.texture or _G[button:GetName().."Icon"] or _G[button:GetName().."_Icon"] or button:GetNormalTexture()
			
			if icon then
				button:HookScript("OnMouseDown", function()
					icon:SetTexCoord(0,1,0,1)
				end)
				button:HookScript("OnMouseUp", function()
					icon:SetTexCoord(0.05,0.95,0.05,0.95)
				end)

				icon:SetTexCoord(0.05,0.95,0.05,0.95)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT")
				icon:SetPoint("BOTTOMRIGHT")
				icon.ClearAllPoints = function() end
				icon.SetPoint = function() end
			end
		end
		
		for _, region in pairs({button:GetRegions()}) do
			if region:GetObjectType() == "Texture" then
				local file = tostring(region:GetTexture())

				if file and ( file:find("Border") or file:find("Background") or file:find("AlphaMask") or file:find(136430) or file:find(136467) ) then
					region:SetTexture("")
				end
			end
		end
	end
end

local function GetButtons()
	for _, button in pairs({Minimap:GetChildren()}) do
		RegisterButton(button)
	end
end

local function UpdateButtons()
	for i = 1, maxMinimapButtons do
		SyncUI_Minimap.ButtonFrame["Button"..i]:SetAlpha(0)
	end

	wipe(ButtonList)
	
	for _, button in ipairs(PreButtonList) do
		if button:IsShown() then
			tinsert(ButtonList,button)
		end
	end

	table.sort(ButtonList, function(a,b)
		return a:GetName() < b:GetName()
	end)

	for index, button in ipairs(ButtonList) do
		SkinButton(index,button)
	end
end

function SyncUI_MinimapButtonFrame_OnEvent(self, event, arg1, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		LoadAddOn("Blizzard_OrderHallUI")
		SyncUI_DisableFrame(OrderHallCommandBar)
		
		self.numButtons = Minimap:GetNumChildren()
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")	
	end
	
	GetButtons()
	UpdateButtons()
end

function SyncUI_MinimapButtonFrame_OnUpdate(self)
	local numChildren = Minimap:GetNumChildren()

	if self.numButtons ~= numChildren then
		self.numButtons = Minimap:GetNumChildren()

		GetButtons()
		UpdateButtons()
	end

	if self.forceUpdate then
		self.forceUpdate = false
		
		UpdateButtons()
	end
end
