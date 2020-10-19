
local function GetPowerTypeIndex()
	local class = select(2, UnitClass("player"))
	local specID;
	
	if GetSpecialization() then
		specID = select(1, GetSpecializationInfo(GetSpecialization()))
	end
	
	if specID then
		-- Moonkin
		if specID == 102 and GetShapeshiftForm() == 4 then
			return 0;
		end
		
		-- Shadow
		if specID == 258 then
			return 0;
		end
		
		-- Elemental / Enhancement
		if specID == 262 or specID == 263 then
			return 0;
		end
	end	
end

local function GetDebuffColors(type)
	local r,g,b
	
	if type == "Curse" then
		r,g,b = 0.5,0.2,1.0
	elseif type == "Disease" then
		r,g,b = 1.0,0.5,0.0
	elseif type == "Magic" then
		r,g,b = 0.0,0.2,0.8
	elseif type == "Poison" then
		r,g,b = 0.0,1.0,0.0
	else
		r,g,b = 1.0,1.0,1.0
	end
	
	return r,g,b
end


-- Unit Update Functions
local function UpdateBar(self, unitID)
	if self.ManaBar then
		local powerTypeIndex = (unitID == "player" and GetPowerTypeIndex()) or nil
		local power, maxPower = UnitPower(unitID, powerTypeIndex), UnitPowerMax(unitID, powerTypeIndex)
		
		self.ManaBar:SetMinMaxValues(0, maxPower)
		SmoothBar(self.ManaBar, power)

		if power > 0 then
			local powerType = (powerTypeIndex == 0 and "MANA") or select(2, UnitPowerType(unitID))
			local color = SYNCUI_POWER_COLORS[powerType]

			if color then
				local r,g,b = unpack(color)
				self.ManaBar:SetStatusBarColor(r,g,b)
			else
				self.ManaBar:SetStatusBarColor(0.5,0.5,0.5)
			end
		end
	end
	
	if self.HealthBar then
		local health, maxHealth = UnitHealth(unitID), UnitHealthMax(unitID)
		
		self.HealthBar:SetMinMaxValues(0, maxHealth)
		SmoothBar(self.HealthBar,health)

		if UnitIsPlayer(unitID) then
			local class = select(2, UnitClass(unitID))
			
			if class then
				local r,g,b = unpack(SYNCUI_CLASS_COLORS[class])
				self.HealthBar:SetStatusBarColor(r,g,b,0)
			end
		else
			self.HealthBar:SetStatusBarColor(0,0.8,0,0)
		end
	end

	if self.AbsorbBar then
		local health, maxHealth = UnitHealth(unitID), UnitHealthMax(unitID)
		local absorb = UnitGetTotalAbsorbs(unitID) or 0
		local barWidth, barHeight = self.HealthBar:GetSize()
			
		if health + absorb > maxHealth then
			self.AbsorbBar:SetSize((barWidth-(health*barWidth/maxHealth))+0.1,barHeight)
		else
			self.AbsorbBar:SetSize((absorb * barWidth / maxHealth),barHeight)
		end
		if absorb == 0 then
			self.AbsorbBar:SetAlpha(0)
		else
			self.AbsorbBar:SetPoint("TOPLEFT", self.HealthBar:GetStatusBarTexture(), "TOPRIGHT")
			self.AbsorbBar:SetAlpha(1)
		end
	end
end

local function UpdateBarText(self, unitID)
	if self.Mana then
		local powerTypeIndex = (unitID == "player" and GetPowerTypeIndex()) or nil
		local power = UnitPower(unitID, powerTypeIndex)
		
		if UnitIsDeadOrGhost(unitID) then
			self.Mana:SetText()
		else
			if power > 10000 then
				self.Mana:SetText(string.format("%.0f",(power)/1000).."k")
			elseif power > 0 then
				self.Mana:SetText(power)
			else
				self.Mana:SetText()
			end
		end
	end

	if self.Health then
		local health, maxHealth = UnitHealth(unitID), UnitHealthMax(unitID)
		local text = ""
		
		if not UnitIsConnected(unitID) or UnitIsDeadOrGhost(unitID) then
			self.Health:SetText(text)
		else
			if health >= 10000000 then
				text = string.format("%.0f",(health)/1000000).."m".." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%"
			elseif health >= 10000 then
				text = string.format("%.0f",(health)/1000).."k".." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%"
			elseif health > 0 then
				text = health.." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%"
			end
			
			if SecureButton_GetModifiedUnit(self) == "pet" and SecureButton_GetUnit(self) ~= "pet" then
				unitID = "Vehicle"
			end
			
			if unitID == "pet" or unitID == "targettarget" or unitID == "focustarget" then
				text = math.ceil( (health)*100/maxHealth ).."%"
			end
			
			self.Health:SetText(text)
		end
	end
end

local function UpdateLabel(self, unitID)
	if self.Name then
		local name, server = UnitName(unitID)
		
		if unitID == "target" or unitID == "focus" then
			local type = UnitClassification(unitID)
			local level = UnitLevel(unitID)
			
			if level >= 0 then
				local r,g,b = SyncUI_GetEffectiveLevelColor(level)
				level = SyncUI_GetColorizedText(tostring(level), r,g,b)
			else
				level = "??"
			end
			
			if type == "rare" or type == "rareelite" then
				level = level.." "..ITEM_QUALITY3_DESC
			elseif type == "elite" then
				level = level.." "..ELITE
			end
			
			self.Name:SetText(level.." - "..name)
		else
			self.Name:SetText(name)
		end		
	end

	if self.Group then
		if IsInRaid() then
			for index = 1, 40 do
				local name, _,group = GetRaidRosterInfo(index)
				if name == UnitName("player") then
					self.Group:SetText(GROUP.." "..group)
				end
			end
		else
			self.Group:SetText("")
		end
	end
end

local function UpdatePvPState(self, elapsed, unitID)
	if self.PvPTimer then
		if UnitIsPVP(unitID) then
			if self.timeLeftPvP then
				self.timeLeftPvP = self.timeLeftPvP - elapsed * 1000
				
				if self.timeLeftPvP > 0 then
					self.PvPTimer:SetText(PVP.." - "..format(SecondsToTimeAbbrev(floor(self.timeLeftPvP/1000))))
				else
					self.timeLeftPvP = nil
				end
			else
				self.PvPTimer:SetText(PVP)
			end
		else
			self.PvPTimer:SetText("")
		end
	end
end

local function UpdateRaidMarks(self, unitID)
	if self.RaidMark then
		local index = GetRaidTargetIndex(unitID)
		
		if index then
			SetRaidTargetIconTexture(self.RaidMark, index)
			
			if not self.RaidMark:IsShown() then
				self.RaidMark:Show()
				
				if self.PushLabel then
					self.PushLabel:Play()
				end
			end
		else
			if self.RaidMark:IsShown() then
				self.RaidMark:Hide()
				
				if self.PullLabel then
					self.PullLabel:Play()
				end
			end
		end
	end
end

local function UpdateStatusIcons(self, unitID)
	if self.Quest then
		if UnitIsQuestBoss(unitID) then
			self.Quest:Show()
		else
			self.Quest:Hide()
		end
	end

	if self.Tapped then
		if not UnitIsDeadOrGhost(unitID) then
			if UnitAffectingCombat(unitID) and UnitIsTapped(unitID) and not UnitIsTappedByPlayer(unitID) then
				self.Tapped:Show()
			else
				self.Tapped:Hide()
			end
		else
			self.Tapped:Hide()
		end
	end

	if self.Role then
		local role = UnitGroupRolesAssigned(unitID)
		
		if unitID:find("party") and self:GetName():find("Normal") then
			if role == "TANK" or role == "HEALER" then
				if not self.Role:IsShown() then
					self.Name:SetPoint("TOPLEFT",28,2)
				end
			else
				if self.Role:IsShown() then
					self.Name:SetPoint("TOPLEFT",14,2)
				end
			end
		end
		
		if role == "TANK" then
			if not self.Role:IsShown() then
				self.Role:Show()
			end
			self.Role:SetTexCoord(0.625,0.90625,0,0.5625)
		elseif UnitGroupRolesAssigned(unitID) == "HEALER" then
			if not self.Role:IsShown() then
				self.Role:Show()
			end
			self.Role:SetTexCoord(0.3125,0.59375,0,0.5625)
		else
			if self.Role:IsShown() then
				self.Role:Hide()
			end
		end
	end

	if self.StatusIcon then
		if not UnitIsConnected(unitID) then
			self.StatusIcon:SetTexture("Interface\\CHARACTERFRAME\\Disconnect-Icon")
			self.StatusIcon:SetTexCoord(0.2,0.8,0.2,0.8)
			self.StatusIcon:Show()
		elseif UnitHasIncomingResurrection(unitID) then
			self.StatusIcon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
			self.StatusIcon:SetTexCoord(0,1,0,1)
			self.StatusIcon:Show()		
		elseif UnitIsDeadOrGhost(unitID) then
			self.StatusIcon:SetTexture("Interface\\WorldStateFrame\\SkullBones")
			self.StatusIcon:SetTexCoord(0,0.5,0,0.5)
			self.StatusIcon:Show()
		else
			self.StatusIcon:Hide()
		end
	end
	
	if unitID == "target" or unitID == "focus" then
		if not UnitIsConnected(unitID) then
			self.Disconnect:Show()
			self.Death:Hide()
		else
			self.Disconnect:Hide()
			
			if UnitIsDeadOrGhost(unitID) then
				self.Death:Show()
			else
				self.Death:Hide()
			end
		end
	end
	
end

local function UpdateRange(self, unitID)
	if self.isRaid or self.isHeal then
		if UnitInRange(unitID) then
			self:SetAlpha(1)
			self.HealthBar:SetAlpha(1)
		else
			self:SetAlpha(0.8)
			self.HealthBar:SetAlpha(0.5)
		end
	end
end

local function UpdateSelection(self, unitID)
	if self.Selection then
		if UnitGUID(unitID) == UnitGUID("target") then
			self.Selection:Show()
		else
			self.Selection:Hide()
		end
	end
end

local function UpdateDispel(self, unitID)
	if self.Dispel then
		local isDispel,r,g,b;
		
		for index = 1, 40 do
			local type = select(5, UnitDebuff(unitID,index))
			
			if type then
				r,g,b = GetDebuffColors(type)
				isDispel = true
				break
			end
		end

		if isDispel then
			self.Dispel:Show()
			self.Dispel:SetVertexColor(r,g,b)
		else
			self.Dispel:Hide()
		end
	end
end

local function UpdateThreat(self,unitID)
	if self.Threat then
		local feedbackUnit = "player"
		local status;
		
		if feedbackUnit ~= unitID then
			status = UnitThreatSituation(feedbackUnit, unitID)
		else
			status = UnitThreatSituation(feedbackUnit)
		end
		
		if status then
			local isTanking, status, perc = UnitDetailedThreatSituation(feedbackUnit, unitID)

			if isTanking or perc and perc > 0 then
				local role = UnitGroupRolesAssigned("player")
							
				if isTanking and role == "TANK" then
					self.Threat.StatusBar:SetStatusBarColor(0.2,0.5,1)
				else
					self.Threat.StatusBar:SetStatusBarColor(GetThreatStatusColor(status))
				end
				
				if perc < 100 then
					self.Threat.Text:SetText(format("%0.f",perc))
				else
					self.Threat.Text:SetText("")
				end

				self.Threat.StatusBar:SetValue(perc)
				
				self.Threat:Show()
			else
				self.Threat:Hide()
			end
		else
			self.Threat:Hide()
		end
	end
end


-- General Unit Frame Functions
function SyncUI_UnitFrame_OnRegister(self, force)
	local unitID = self.unitID
	
	self:SetAttribute("unit", unitID)
	self:SetAttribute("type1", "target")
	self:SetAttribute("*type2", "togglemenu")
	self:RegisterForClicks("AnyUp")
	self:RegisterForDrag("LeftButton")
	
	if force then RegisterUnitWatch(self) end
	
	SyncUI_UnitFrame_OnRegisterClickCasting(self)
end

function SyncUI_UnitFrame_OnRegisterClickCasting(self)		
	if not ClickCastFrames then ClickCastFrames = {} end

	ClickCastFrames[self] = true;
end

function SyncUI_UnitFrame_OnUpdate(self, elapsed)
	local modUnit = SecureButton_GetModifiedUnit(self)
	local unitID = self.unitID
	
	if self.unitID ~= modUnit then
		self.unitID = modUnit
		unitID = modUnit
	end

	if UnitExists(unitID) then
		UpdateBar(self, unitID)
		UpdateBarText(self, unitID)
		UpdateLabel(self, unitID)
		UpdatePvPState(self, elapsed, unitID)
		UpdateRaidMarks(self, unitID)
		UpdateStatusIcons(self, unitID)		
		UpdateRange(self, unitID)
		--UpdateSelection(self, unitID)
		--UpdateDispel(self, unitID)
		--UpdateThreat(self, unitID)
	end
end

function SyncUI_UnitFrame_OnEnter(self)
	local unitID = self.unitID or SecureButton_GetModifiedUnit(self)

	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetUnit(unitID)
	GameTooltip:Show()
end

function SyncUI_UnitFrame_OnReset(self)
	if self.CastingBar then
		self.CastingBar:Hide()
		self.CastingBar:SetAlpha(0)
	end
end


-- Specific Unit Frame Load Functions
function SyncUI_PlayerFrame_OnLoad(self)
	self:RegisterForDrag("")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:RegisterEvent("PLAYER_ENTER_COMBAT")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	
	self.unitID = "player"
	self.Group = self.ArtFrame.Group
	self.Health = self.ArtFrame.Health
	self.Mana = self.ArtFrame.Mana
	self.RaidMark = self.ArtFrame.RaidMark
	self.PvPTimer = self.ArtFrame.PvPTimer
	self:SetAttribute('toggleForVehicle', true)

	SyncUI_CreateSecureAuraHeader(self, "TOPRIGHT", SyncUI_UIParent, "TOPRIGHT", -195, -10, self.unitID, "Buff", 10, 2, -44, -44, 152, 38, "SyncUI_SecureAuraTemplate", SYNCUI_STRING_PLACEMENT_TOOL_LABEL_BUFFS)
	SyncUI_CreateAuraHeader(self, "RIGHT", self, "LEFT", 0, 0, self.unitID, "Debuff", 10, 1, -38, -38, 152, 38, "SyncUI_AuraTemplate", SYNCUI_STRING_PLACEMENT_TOOL_LABEL_DEBUFFS)

	SyncUI_RegisterDragFrame(self, PLAYER)
	SyncUI_UnitFrame_OnRegister(self)
	SyncUI_DisableFrame("PlayerFrame")
	SyncUI_DisableFrame("BuffFrame")
	SyncUI_DisableFrame("TemporaryEnchantFrame")
	RegisterStateDriver(self, "visibility", "[petbattle] hide; show")
end

function SyncUI_PlayerFrame_OnEvent(self,event,...)
	if event == "PLAYER_LOGIN" then
		local castBarAddOns = {"Quartz", "Gnosis", "AdiCastBars"}
		for _, addOn in pairs(castBarAddOns) do
			if IsAddOnLoaded(addOn) then 
				SyncUI_PlayerCastingBar:UnregisterAllEvents()
				SyncUI_PlayerCastingBar:Hide()
				return
			end
		end
	end

	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_UPDATE_RESTING" then
		if InCombatLockdown() then
			return
		end
		
		if IsResting() then
			self.Resting_FadeIn:Play()
		else
			self.Resting_FadeOut:Play()
		end
	end
	
	if event == "PLAYER_ENTER_COMBAT" then
		--self.ThreatGlow:Show()
	end
	
	if event == "PLAYER_LEAVE_COMBAT" then
		--self.ThreatGlow:Hide()
	end
	
	if event == "PLAYER_REGEN_ENABLED" then
		self.Combat_FadeOut:Play()
		
		if IsResting() then
			self.Resting_FadeIn:Play()
		end
	end
	
	if event == "PLAYER_REGEN_DISABLED" then
		self.Combat_FadeIn:Play()
		
		if IsResting() then
			self.Resting_FadeOut:Play()
		end	
	end

	if event == "PLAYER_FLAGS_CHANGED" or "PLAYER_ENTERING_WORLD" then
		if IsPVPTimerRunning() then
			self.timeLeftPvP = GetPVPTimer()
		else
			self.timeLeftPvP = nil
		end	
	end
end

function SyncUI_TargetFrame_OnLoad(self)
	self.unitID = "target"
	self.Health = self.ArtFrame.Health
	self.Mana = self.ArtFrame.Mana
	self.Name = self.ArtFrame.Name
	self.PvPTimer = self.ArtFrame.PvPTimer
	self.Death = self.ArtFrame.Death
	self.Disconnect = self.ArtFrame.Disconnect
	self.RaidMark = self.ArtFrame.RaidMark
	
	SyncUI_CreateAuraHeader(self, "BOTTOMLEFT", self, "TOPLEFT", 8, 5, self.unitID, "Debuff", 8, 2, 27, 27, 214, 25, "SyncUI_SmallAuraTemplate")
	SyncUI_CreateAuraHeader(self, "TOPRIGHT", self, "BOTTOMRIGHT", -8, 0, self.unitID, "Buff", 8, 1, -27, -27, 214, 25, "SyncUI_SmallAuraTemplate")
	SyncUI_RegisterDragFrame(self,TARGET)
	SyncUI_UnitFrame_OnRegister(self)
	SyncUI_DisableFrame("TargetFrame")
	RegisterStateDriver(self, "visibility", "[petbattle] hide; [@target,exists] show; hide")
end

function SyncUI_FocusFrame_OnLoad(self)
	self.unitID = "focus"
	self.Health = self.ArtFrame.Health
	self.Mana = self.ArtFrame.Mana
	self.Name = self.ArtFrame.Name
	self.PvPTimer = self.ArtFrame.PvPTimer
	self.Death = self.ArtFrame.Death
	self.Disconnect = self.ArtFrame.Disconnect
	self.RaidMark = self.ArtFrame.RaidMark

	SyncUI_CreateAuraHeader(self, "BOTTOMLEFT", self, "TOPLEFT", 8, 5, self.unitID, "Debuff", 8, 2, 27, 27, 214, 25, "SyncUI_SmallAuraTemplate")
	SyncUI_CreateAuraHeader(self, "TOPLEFT", self, "BOTTOMLEFT", 8, 0, self.unitID, "Buff", 8, 1, 27, -27, 214, 25, "SyncUI_SmallAuraTemplate")
	SyncUI_RegisterDragFrame(self, FOCUS)
	SyncUI_UnitFrame_OnRegister(self,true)
	SyncUI_DisableFrame("FocusFrame")
end

function SyncUI_PetFrame_OnLoad(self)
	self.unitID = "pet"
	self.Name = self.ArtFrame.Name
	self.Health = self.ArtFrame.Health
	self:SetAttribute('toggleForVehicle', true)
	
	SyncUI_RegisterDragFrame(self, PET)
	SyncUI_UnitFrame_OnRegister(self)
	--RegisterStateDriver(self, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; [@pet,exists] show; hide")
	RegisterStateDriver(self, "visibility", "[@pet,exists] show; hide")
end

function SyncUI_ToTFrame_OnLoad(self)
	self.unitID = "targettarget"
	self.Name = self.ArtFrame.Name
	self.Health = self.ArtFrame.Health

	SyncUI_CreateAuraHeader(self, "TOPLEFT", self, "BOTTOMLEFT", 13, 0, self.unitID, "Debuff", 3, 1, 27, -27, 108, 27, "SyncUI_SmallAuraTemplate")
	SyncUI_RegisterDragFrame(self,SHOW_TARGET_OF_TARGET_TEXT)
	SyncUI_UnitFrame_OnRegister(self,true)
end

function SyncUI_ToFFrame_OnLoad(self)
	self.unitID = "focustarget"
	self.Name = self.ArtFrame.Name
	self.Health = self.ArtFrame.Health
	
	SyncUI_RegisterDragFrame(self, MINIMAP_TRACKING_FOCUS)
	SyncUI_UnitFrame_OnRegister(self,true)
end

function SyncUI_PartyFrame_OnLoad(self)
	self.Name = self.ArtFrame.Name
	self.Role = self.ArtFrame.Role
	self.StatusIcon = self.ArtFrame.StatusIcon
	
	if self:GetName():find("Heal") then
		self.isHeal = true
		self.Dispel = self.ArtFrame.Dispel
	else
		self.Health = self.ArtFrame.Health
		SyncUI_CreateSecureAuraHeader(self, "LEFT", self, "RIGHT", 2, 0, nil, "Debuff", 3, 1, 27, -27, 79, 25, "SyncUI_SmallAuraTemplate")
	end	

	SyncUI_UnitFrame_OnRegister(self,true)
end

function SyncUI_RaidMember_OnLoad(self)
	self.Name = self.ArtFrame.Name
	self.Role = self.ArtFrame.Role
	self.StatusIcon = self.ArtFrame.StatusIcon
	self.isRaid = true
	
	if self:GetName():find("Heal") then
		self.isHeal = true
		self.Dispel = self.ArtFrame.Dispel
	else
		self.Selection = self.ArtFrame.Selection
	end
	
	SyncUI_UnitFrame_OnRegister(self,true)
end

function SyncUI_BossFrame_OnLoad(self)
	self.unitID = "boss"..self:GetID()
	self.Name = self.ArtFrame.Name
	self.Health = self.ArtFrame.Health
	self.RaidMark = self.ArtFrame.RaidMark
	
	SyncUI_CreateAuraHeader(self, "RIGHT", self, "LEFT", -2, 0, self.unitID, "Debuff", 4, 1, -27, -27, 106, 25, "SyncUI_SmallAuraTemplate")
	SyncUI_UnitFrame_OnRegister(self, true)
	SyncUI_DisableFrame("Boss"..self:GetID().."TargetFrame")
end


-- Group Frame Setup
local function HideDefaultRaid()
	if not InCombatLockdown() then
		local isShown = CompactRaidFrameManager_GetSetting("IsShown")
			
		SyncUI_DisableFrame("CompactRaidFrameManager")

		if isShown and isShown ~= "0" then
			CompactRaidFrameManager_SetSetting("IsShown", "0")
		end
	end
end

local function UpdateHeaderSorting(header, method)
	if method == "class" then
		header:SetAttribute("groupingOrder", "DEATHKNIGHT,DRUID,HUNTER,MAGE,MONK,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", "CLASS")			
	elseif method == "role" then
		header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", "ASSIGNEDROLE")
	elseif method == "group" then
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "INDEX")
		header:SetAttribute("groupBy", "GROUP")
	end
end

local function PreCreateChildren(header)
	local index = header:GetAttribute("startingIndex")
	local maxColumns = header:GetAttribute("maxColumns") or 1
	local perColumn = header:GetAttribute("unitsPerColumn") or 5
	local maxFrames = maxColumns * perColumn
	local count = header.FrameCount
	
	if maxFrames > 40 then
		maxFrames = 40
	end
	
	if not count or count < maxFrames then
		header:Show()
		header:SetAttribute("startingIndex", 1-maxFrames)
		header:SetAttribute("startingIndex", index)
		header.FrameCount = maxFrames
	end
end


function SyncUI_UnitGroupContainer_OnLoad(self, type)
	self:RegisterEvent("PLAYER_LOGIN")
	
	if type == "party" then
		do	-- Create Normal Header
			local header = CreateFrame("frame", self:GetName().."_Normal", self, "SecurePartyHeaderTemplate")
			header:SetSize(158, 223)
			header:SetAttribute("template", "SyncUI_PartyFrameTemplate")
			header:SetAttribute("point", "TOP")
			header:SetAttribute("xOffset", 0)
			header:SetAttribute("yOffset", -5)
			--header:SetAttribute("maxColumns", 1)
			--header:SetAttribute("unitsPerColumn", 4)
			header:SetAttribute("sortDir", "ASC")
			header:SetAttribute("minWidth", 158)
			header:SetAttribute("minHeight", 223)		
			self.Normal = header
			
			PreCreateChildren(header)
			SyncUI_RegisterDragFrame(header, PARTY.." ("..SYNCUI_STRING_GROUP_CONTROL_LAYOUT_NORMAL..")")
		end
		do	-- Create Heal Header
			local header = CreateFrame("frame", self:GetName().."_Heal", self, "SecurePartyHeaderTemplate")
			header:SetSize(327,38)
			header:SetAttribute("template", "SyncUI_PartyFrameTemplate2")
			header:SetAttribute("point", "LEFT")
			header:SetAttribute("xOffset", 5)
			header:SetAttribute("yOffset", 0)
			--header:SetAttribute("maxColumns", 1)
			--header:SetAttribute("unitsPerColumn", 5)
			header:SetAttribute("sortDir", "ASC")
			header:SetAttribute("minWidth", 327)
			header:SetAttribute("minHeight", 38)
			header:SetAttribute("showPlayer", true)	
			self.Heal = header
			
			PreCreateChildren(header)
			SyncUI_RegisterDragFrame(header, PARTY.." ("..SYNCUI_STRING_GROUP_CONTROL_LAYOUT_HEAL..")")
		end
	end

	if type == "raid" then
		do	-- Create Normal Header
			local header = CreateFrame("frame", self:GetName().."_Normal", self, "SecureRaidGroupHeaderTemplate")
			header:SetPoint("TOPLEFT", SyncUI_UIParent, 5, -25)
			header:SetAttribute("template", "SyncUI_RaidMemberTemplate")
			header:SetAttribute("point", "TOP")
			header:SetAttribute("xOffset", 0)
			header:SetAttribute("yOffset", 3)
			header:SetAttribute("maxColumns", 2)
			header:SetAttribute("unitsPerColumn", 20)
			header:SetAttribute("columnSpacing", 5)
			header:SetAttribute("columnAnchorPoint", "LEFT")
			header:SetAttribute("showRaid", true)
			header:SetAttribute("sortDir", "ASC")
			self.Normal = header
			
			PreCreateChildren(header)
		end
		do	-- Create Heal Header
			local header = CreateFrame("frame", self:GetName().."_Heal", self, "SecureRaidGroupHeaderTemplate")
			header:SetAttribute("template","SyncUI_RaidMemberTemplate2")
			header:SetAttribute("point","LEFT")
			header:SetAttribute("xOffset",-5)
			header:SetAttribute("yOffset",0)
			header:SetAttribute("maxColumns",8)
			header:SetAttribute("unitsPerColumn",5)
			header:SetAttribute("columnSpacing",-5)
			header:SetAttribute("columnAnchorPoint", "BOTTOM")
			header:SetAttribute("showRaid",true)
			header:SetAttribute("sortDir","ASC")
			header:SetAttribute("minWidth", 400)
			header:SetAttribute("minHeight", 161)
			self.Heal = header
			
			PreCreateChildren(header)
			header:Hide()
			
			SyncUI_RegisterDragFrame(header, RAID.." ("..SYNCUI_STRING_GROUP_CONTROL_LAYOUT_HEAL..")")
		end
	end
end

function SyncUI_UnitGroupContainer_OnEvent(self, event,...)
	if event == "PLAYER_LOGIN" then
		if not CompactRaidFrameManager_UpdateShown then
			StaticPopup_Show("SYNCUI_FORCE_RELOAD")
		else
			local profile = SyncUI_GetProfile()
		
			if profile.Options.UnitFrames.DefaultRaid then
				UnregisterStateDriver(self, "visibility")
				self:Hide()
				
				UnregisterStateDriver(SyncUI_GroupControl.Toggle, "visibility")
				SyncUI_GroupControl.Toggle:Hide()
				SyncUI_GroupControl.GroupLayout:Disable()
			else
				CompactRaidFrameManager:HookScript('OnShow', HideDefaultRaid)
				CompactRaidFrameContainer:UnregisterAllEvents()
				
				hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideDefaultRaid)
				
				for i = 1, 4 do
					SyncUI_DisableFrame("PartyMemberFrame"..i)
				end
			end
		end
	end
	if event == "PLAYER_REGEN_ENABLED" then		
		SyncUI_UnitGroupContainer_UpdateSorting(self, self.method)
		
		self.method = nil
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end

function SyncUI_UnitGroupContainer_UpdateSorting(self, method)
	if self then
		if InCombatLockdown() then
			self.method = method
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			UpdateHeaderSorting(self.Normal, method)
			UpdateHeaderSorting(self.Heal, method)
		end
	end
end

StaticPopupDialogs["SYNCUI_FORCE_RELOAD"] = {
	text = SYNCUI_STRING_UI_LABEL..": "..REQUIRES_RELOAD,
	button1 = OKAY,
	whileDead = true,
	preferredIndex = 3,
	OnAccept = function()
		EnableAddOn("Blizzard_CompactRaidFrames");
		EnableAddOn("Blizzard_CUFProfiles");
		ReloadUI();
	end,
}
