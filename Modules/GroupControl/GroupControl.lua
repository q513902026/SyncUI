
-- World Markers
local WorldMarkers = {
	[1] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
	[2] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
	[3] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
	[4] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
	[5] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
	[6] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
	[7] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
	[8] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
}

function SyncUI_WorldMarkerButton_OnLoad(self)
	local index = self:GetID()
	local icon = WorldMarkers[index]
	
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type", "macro")
	self:SetAttribute("macrotext1", string.format("/wm %d",index))
	self:SetAttribute("shift-type*", "macro")
	self:SetAttribute("shift-macrotext1", string.format("/cwm %d",index))
	self.Icon:SetTexture(icon)
	self.Highlight:SetTexture(icon)
end

function SyncUI_WorldMarkerBar_OnLoad(self)
	local frame = SyncUI_RaidToolMenu
	local button = frame["Button3"]
	
	button:SetFrameRef("Bar", self)
	button:SetAttribute("_onclick", [[
		local bar = self:GetFrameRef("Bar")
		
		if bar:IsShown() then
			bar:Hide()
		else
			bar:Show()
		end
		
		self:GetFrameRef("Menu"):Hide()					
	]])
	
	self:RegisterForDrag("LeftButton")
	SyncUI_RegisterDragFrame(self,SYNCUI_STRING_PLACEMENT_TOOL_LABEL_WORLD_MARK_BAR)

end

function SyncUI_WorldMarkerBar_OnUpdate(self, elapsed)
	for i = 1, 8 do
		local marker = self["Marker"..i]
		local index = marker:GetID()
		
		if IsRaidMarkerActive(index) then
			marker.Text:Show()
		else
			marker.Text:Hide()
		end
	end
end

-- Group Control General
local function RegisterMenuToggles(self)
	do	-- Raid Tool Toggle
		local frame = self.RaidTool
		
		frame:RegisterForClicks("LeftButtonUp")
		frame:SetFrameRef("menu", SyncUI_RaidToolMenu)
		frame:SetAttribute("_onclick", [[
			local menu = self:GetFrameRef("menu")
			
			if menu:IsShown() then
				menu:Hide()
			else
				menu:Show()
			end
		]])
	end
	do	-- Group Layout Toggle
		local frame = self.GroupLayout
		
		frame:RegisterForClicks("LeftButtonUp")
		frame:SetFrameRef("menu", SyncUI_GroupLayoutMenu)
		frame:SetAttribute("_onclick", [[
			local menu = self:GetFrameRef("menu")
			
			if menu:IsShown() then
				menu:Hide()
			else
				menu:Show()
			end
		]])
	end
	do	-- LootSpec Toggle
		local frame = self.LootSpec
		
		frame:RegisterForClicks("LeftButtonUp")
		frame:SetFrameRef("menu", SyncUI_LootSpecMenu)
		frame:SetAttribute("_onclick", [[
			local menu = self:GetFrameRef("menu")
			
			if menu:IsShown() then
				menu:Hide()
			else
				menu:Show()
			end
		]])
	end
	do	-- Raid Frame Toggle
		local frame = self.Toggle
		
		frame:RegisterForClicks("LeftButtonUp")
		frame:SetFrameRef("raid", SyncUI_RaidFrameContainer)
		frame:SetAttribute("_onclick", [[
			local raid = self:GetFrameRef("raid")
			
			if raid:IsShown() then
				raid:Hide()
			else
				raid:Show()
			end
		]])
		frame:HookScript("OnClick", function()
			local profile = SyncUI_GetProfile()
			
			GameTooltip:SetOwner(frame, "ANCHOR_BOTTOM")
		
			if frame:GetChecked() then
				profile.GroupControl.Toggle = true
				GameTooltip:AddLine(SYNCUI_STRING_GROUP_CONTROL_MAXIMIZE_RAID, 1,1,1)
			else
				profile.GroupControl.Toggle = false
				GameTooltip:AddLine(SYNCUI_STRING_GROUP_CONTROL_MINIMIZE_RAID, 1,1,1)
			end
			
			GameTooltip:Show()
		end)
	end
end

local function RegisterMenu(self)
	do 	-- Raid Tool Menu
		local frame = SyncUI_RaidToolMenu
		
		frame:SetFrameRef("GroupLayout", SyncUI_GroupLayoutMenu)
		frame:SetFrameRef("LootSpec", SyncUI_LootSpecMenu)
		frame:SetAttribute("_onshow", [[
			self:GetFrameRef("GroupLayout"):Hide()
			self:GetFrameRef("LootSpec"):Hide()
		]])
		
		for i = 1, 5 do
			local button = frame["Button"..i]
			
			button:SetFrameRef("Menu", frame)
			button:SetAttribute("_onclick", [[
				self:GetFrameRef("Menu"):Hide()
			]])			
			button:HookScript("OnClick", function(self)
				if i == 1 then
					ToggleFriendsFrame(4)
				end
				if i == 2 then
					SyncUI_ToggleFrame(RaidInfoFrame)
				end
				if i == 4 then
					DoReadyCheck()
				end
				if i == 5 then
					InitiateRolePoll()
				end
			end)
		end
	end
	do	-- Group Layout Menu
		local frame = SyncUI_GroupLayoutMenu
		
		for i = 1, 2 do
			local button = frame["Button"..i]

			button:RegisterForClicks('LeftButtonUp')
			button:SetFrameRef("pNormal", SyncUI_PartyFrameContainer.Normal)
			button:SetFrameRef("pHeal", SyncUI_PartyFrameContainer.Heal)
			button:SetFrameRef("rNormal", SyncUI_RaidFrameContainer.Normal)
			button:SetFrameRef("rHeal", SyncUI_RaidFrameContainer.Heal)
			button:SetFrameRef("Menu", frame)

			if i == 1 then
				button:SetAttribute("_onclick", [[
					if button == "LeftButton" then
						self:GetFrameRef("Menu"):Hide()
						self:GetFrameRef("pHeal"):Hide()
						self:GetFrameRef("rHeal"):Hide()
						self:GetFrameRef("pNormal"):Show()
						self:GetFrameRef("rNormal"):Show()
					end
				]])
				button:HookScript("OnClick", function()
					local profile = SyncUI_GetProfile()
					profile.GroupControl.Layout = "Normal"
					frame:GetParent().GroupLayout:SetText(SYNCUI_STRING_GROUP_CONTROL_LAYOUT_NORMAL)
				end)
			end
			if i == 2 then
				button:SetAttribute("_onclick", [[
					if button == "LeftButton" then
						self:GetFrameRef("Menu"):Hide()
						self:GetFrameRef("pNormal"):Hide()
						self:GetFrameRef("rNormal"):Hide()
						self:GetFrameRef("pHeal"):Show()
						self:GetFrameRef("rHeal"):Show()
					end
				]])
				button:HookScript("OnClick", function()
					local profile = SyncUI_GetProfile()
					profile.GroupControl.Layout = "Heal"
					frame:GetParent().GroupLayout:SetText(SYNCUI_STRING_GROUP_CONTROL_LAYOUT_HEAL)
				end)
			end
		end
		
		frame:SetFrameRef("RaidTool", SyncUI_RaidToolMenu)
		frame:SetFrameRef("LootSpec", SyncUI_LootSpecMenu)
		frame:SetAttribute("_onshow", [[
			self:GetFrameRef("RaidTool"):Hide()
			self:GetFrameRef("LootSpec"):Hide()
		]])	
	end
	do	-- Loot Spec Menu
		local frame = SyncUI_LootSpecMenu
		
		frame:SetFrameRef("RaidTool", SyncUI_RaidToolMenu)
		frame:SetFrameRef("GroupLayout", SyncUI_GroupLayoutMenu)
		frame:SetAttribute("_onshow", [[
			self:GetFrameRef("RaidTool"):Hide()
			self:GetFrameRef("GroupLayout"):Hide()
		]])
		
		-- Menu Buttons
		for i = 0, 4 do
			local button = frame["Button"..i]
			
			button:SetFrameRef("Menu", frame)
			button:SetAttribute("_onclick", [[
				self:GetFrameRef("Menu"):Hide()
			]])
			button:HookScript("OnClick", function(self)
				local btn = SyncUI_GroupControl.LootSpec
				local index = self:GetID()
				local specID = GetSpecializationInfo(index)
				local icon = select(4, GetSpecializationInfo(index))
				
				if index == 0 then
					specID = 0
					
					if GetSpecialization() then
						icon = select(4, GetSpecializationInfo(GetSpecialization()))
					else
						icon = "Interface\\Icons\\inv_misc_questionmark"
					end
				end

				SetLootSpecialization(specID)
				btn.Icon:SetTexture(icon)				
			end)
		end
	end
end


function SyncUI_GroupControl_OnLoad(self)
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	
	RaidInfoFrame:SetParent(self:GetParent())
	RaidInfoFrame:ClearAllPoints()
	RaidInfoFrame:SetPoint("CENTER",UIParent)
	tinsert(UISpecialFrames, "RaidInfoFrame")

	RegisterMenuToggles(self)
	RegisterMenu(self)

	RegisterStateDriver(self, "visibility", "[@raid1,exists] show; [@party1,exists] show; hide")
end

function SyncUI_GroupControl_OnEvent(self, event, arg1, ...)
	if event == "PLAYER_LOGIN" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		do	-- Update Loot Spec Toggle Button
			local button = SyncUI_GroupControl.LootSpec
			local specID = GetLootSpecialization()
			local icon
			
			if specID > 0 then
				icon = select(4, GetSpecializationInfoByID(specID))
			else
				specID = GetSpecialization()
				
				if specID then
					icon = select(4, GetSpecializationInfo(specID))
				else
					icon = "Interface\\Icons\\inv_misc_questionmark"
				end
			end
			
			button.Icon:SetTexture(icon)			
		end
		do	-- Update Loot Spec Menu Button: 'Current'
			local frame = SyncUI_LootSpecMenu
			local button = frame["Button0"]
			local text = SYNCUI_STRING_LOOTMETHOD_CURRENT_SPEC
			local icon = "Interface\\Icons\\inv_misc_questionmark"

			if GetSpecialization() then
				icon = select(4, GetSpecializationInfo(GetSpecialization()))
			end
			
			button:SetText(text)
			button:SetNormalTexture(icon)
		end
	end
	
	-- Change Loot Menu Size, based on num Specs
	if event == "PLAYER_LOGIN" then
		local frame = SyncUI_LootSpecMenu
		local numSpecs = GetNumSpecializations()

		for i = 1, 4 do
			local button = frame["Button"..i]

			if i <= numSpecs then
				local text = select(2, GetSpecializationInfo(i))
				local icon = select(4, GetSpecializationInfo(i))
				
				button:SetText(text)
				button:SetNormalTexture(icon)
			else
				button:Hide()
			end
		end
		
		frame:SetHeight(25 * (numSpecs+1) + 35)
	end
end
