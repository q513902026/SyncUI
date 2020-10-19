
local baseWidth, baseHeight = 110, 40

-- Update Functions
local function UpdateHealth(self)
	local unitID = self.unitID
	local health, maxHealth = UnitHealth(unitID), UnitHealthMax(unitID)
	-- local text;

	-- if health >= 10000000 then
		-- text = string.format("%.0f",(health)/1000000).."m".." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%"
	-- elseif health >= 10000 then
		-- text = string.format("%.0f",(health)/1000).."k".." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%"
	-- elseif health > 0 then
		-- text = health.." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%"
	-- end
			
	self.HealthBar.Label:SetText(string.format("%.0f",(health * 100 / maxHealth)).."%")
	self.HealthBar:SetMinMaxValues(0, maxHealth)
	SmoothBar(self.HealthBar,health)
end

local function UpdatePower(self)
	local unitID = self.unitID
	local power, maxPower = UnitPower(unitID), UnitPowerMax(unitID)
	
	self.PowerBar:SetMinMaxValues(0, maxPower)
	SmoothBar(self.PowerBar, power)
	
	if power > 0 then
		local powerType = select(2, UnitPowerType(unitID))
		local color = SYNCUI_POWER_COLORS[powerType]

		if color then
			local r,g,b = unpack(color)
			self.PowerBar:SetStatusBarColor(r,g,b)
		else
			self.PowerBar:SetStatusBarColor(0.5,0.5,0.5)
		end
	end
end

local function UpdateName(self)
	local unitID = self.unitID
	local text = UnitName(unitID)
	local isTarget = UnitIsUnit("target",unitID) and not UnitIsUnit("player",unitID)
	
	self.Name:SetText(text)
	
	if self.showName or isTarget then
		self.Name:Show()
	else
		self.Name:Hide()
	end
end

local function UpdateBarColor(self)
	local unitID = self.unitID
	local r,g,b = UnitSelectionColor(unitID)
	local isTapped = UnitIsTapDenied(unitID)
	local hasThreat = select(2, UnitDetailedThreatSituation("player", unitID))
	
	if UnitIsPlayer(unitID) then
		if self.useClassColor then
			local class = select(2, UnitClass(unitID))
			r,g,b = unpack(SYNCUI_CLASS_COLORS[class])
		elseif UnitIsFriend("player",unitID) then
			r,g,b = 0,0.5,1		
		end
	elseif isTapped then
		r,g,b = 0.5,0.5,0.5
	elseif hasThreat then
		r,g,b = 1,0,0
	end
	
	self.HealthBar:SetStatusBarColor(r,g,b)
end

local function UpdateSelection(self)
	local unitID = self.unitID
	local isTarget = UnitIsUnit("target", unitID) and not UnitIsUnit("player", unitID)
	
	if isTarget then
		self.Selection:Show()
		self.HealthBar.BarTex:SetAlpha(1)
		self.CastBar.BarTex:SetAlpha(1)
	else
		self.Selection:Hide()
		self.HealthBar.BarTex:SetAlpha(0.5)
		self.CastBar.BarTex:SetAlpha(0.5)
	end
end

local function UpdateRaidMark(self)
	local unitID = self.unitID
	local raidMark = self.RaidMark
	local index = GetRaidTargetIndex(unitID)
	
	if index then
		SetRaidTargetIconTexture(raidMark.Icon, index)
		raidMark:Show()
	else
		raidMark:Hide()
	end
end

local function UpdateThreat(self)
	local unitID = self.unitID
	local status = UnitThreatSituation(unitID)
	local isTarget = UnitIsUnit("target", unitID) and not UnitIsUnit("player", unitID)
	
	if status and status > 0 and not isTarget then
		self.Threat.Left:SetVertexColor(GetThreatStatusColor(status))
		self.Threat.Right:SetVertexColor(GetThreatStatusColor(status))
		self.Threat:Show()
	else
		self.Threat:Hide()
	end
end

local function UpdateAuras(self)
	local unitID = self.unitID
	local reaction = UnitReaction("player", unitID)
	local header = _G[self:GetName().."AuraHeader"]
	local auraType
	
	if reaction and not UnitIsUnit("player", unitID) then
		if reaction <= 4 then
			auraType = "Debuff"
		else
			auraType = "Buff"
		end
	end
	
	header.isNamePlate = true	
	header.unitID = unitID
	header.auraType = auraType
end

local function UpdateCastBar(self)
	self.CastBar:UnregisterAllEvents()
	self.CastBar:Hide()
	
	if not self.hideCastBar then
		SyncUI_CastingBar_OnLoad(self.CastBar)
		SyncUI_CastingBar_OnEvent(self.CastBar,"PLAYER_TARGET_CHANGED")
	end	
end

local function UpdateUnit(self)
	--UpdateHealth(self)
	UpdateName(self)
	UpdateBarColor(self)
	UpdateSelection(self)
	UpdateRaidMark(self)
	UpdateThreat(self)
	UpdateAuras(self)
	UpdateCastBar(self)
end

local function UpdateSize()
	local xScale = tonumber(GetCVar("NamePlateHorizontalScale"))
	
	--C_NamePlate.SetNamePlateOtherSize(baseWidth * xScale, baseHeight)
	C_NamePlate.SetNamePlateSelfSize(baseWidth, baseHeight)
end


-- ClassBar
local function SetupClassBar()
	local showSelf = GetCVar("nameplateShowSelf")

	if showSelf == "1" then
		local playerNameplate = C_NamePlate.GetNamePlateForUnit("player")
		local classBar = NamePlateDriverFrame.nameplateBar
		
		if playerNameplate then
			playerNameplate.UnitFrame.PowerBar:Show()
		end
		
		if classBar then
			local targetMode = GetCVarBool("nameplateResourceOnTarget")
			
			classBar:Hide()
				
			if targetMode and NamePlateTargetResourceFrame then
				local targetNameplate = C_NamePlate.GetNamePlateForUnit("target")
				
				if targetNameplate then
					classBar:SetParent(NamePlateTargetResourceFrame)
					NamePlateTargetResourceFrame:SetParent(targetNameplate.UnitFrame)
					NamePlateTargetResourceFrame:ClearAllPoints()
					NamePlateTargetResourceFrame:SetPoint("BOTTOM",targetNameplate.UnitFrame.Name,"TOP")
					classBar:Show()
					NamePlateTargetResourceFrame:Layout()
				end
			end
			if not targetMode and NamePlatePlayerResourceFrame then
				if playerNameplate then
					classBar:SetParent(NamePlatePlayerResourceFrame)
					NamePlatePlayerResourceFrame:SetParent(playerNameplate.UnitFrame)
					NamePlatePlayerResourceFrame:ClearAllPoints()
					NamePlatePlayerResourceFrame:SetPoint("TOP",playerNameplate.UnitFrame.PowerBar,"BOTTOM",0,-5)
					classBar:Show()
					NamePlatePlayerResourceFrame:Layout()
				end
				
				NamePlatePlayerResourceFrame:SetShown(playerNameplate ~= nil)
			end
		end
	end
end


-- Handling Functions
local function RegisterUnit(self, unitID)
	local reaction = UnitReaction("player", unitID)
	
	if UnitIsUnit("player", unitID) then	-- Player
		self.showName = false
		self.useClassColor = true
		self.hideCastBar = true
	elseif reaction and reaction > 4 then	-- Friendly
		self.showName = false
		self.useClassColor = false
		self.hideCastBar = true
	elseif reaction and reaction <= 4 then	-- Hostile + Neutral
		self.showName = true
		self.useClassColor  = true
		self.hideCastBar = false
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterUnitEvent("UNIT_NAME_UPDATE", unitID)	
	self:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unitID)
	self:RegisterUnitEvent("UNIT_AURA", unitID)
	
	UpdateUnit(self)
	SetupClassBar()
end

local function UnregisterUnit(self)
	self.Name:Hide()
	self.RaidMark:Hide()
	self.Selection:Hide()
	self.PowerBar:Hide()
	
	self.showName = nil
	self.useClassColor = nil
	self.hideCastBar = nil
	
	self:UnregisterAllEvents()
	--self.CastBar:UnregisterAllEvents()
end

local function CreateNamePlate(baseFrame)
	CreateFrame("Button", "$parentUnitFrame", baseFrame, "SyncUI_NamePlateUnitTemplate")
	baseFrame.UnitFrame:EnableMouse(false)
	baseFrame.UnitFrame.optionTable = {}
end

local function AddNamePlate(unitID)
	local baseFrame = C_NamePlate.GetNamePlateForUnit(unitID)
	local unitFrame = baseFrame.UnitFrame

	baseFrame.namePlateUnitToken = unitID
	unitFrame.unitID = unitID
		
	RegisterUnit(unitFrame, unitID)
end

local function RemoveNamePlate(unitID)
	local baseFrame = C_NamePlate.GetNamePlateForUnit(unitID)
	local unitFrame = baseFrame.UnitFrame
	
	baseFrame.namePlateUnitToken = nil
	unitFrame.unitID = nil
	
	UnregisterUnit(unitFrame)
end

function SyncUI_PlateFrame_OnLoad(self)
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame:SetBaseNamePlateSize(baseWidth, baseHeight)

	InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc = function(value)
		if InCombatLockdown() then
			return
		end
		
		if value == "1" then
			SetCVar("NamePlateHorizontalScale", 1.2)
			SetCVar("NamePlateVerticalScale", 1)
		else
			SetCVar("NamePlateHorizontalScale", 1)
			SetCVar("NamePlateVerticalScale", 1)
		end
		
		UpdateSize()
	end
	
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("NAME_PLATE_CREATED")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	self:RegisterEvent("RAID_TARGET_UPDATE")
	self:RegisterEvent("UNIT_FACTION")
	
	if SyncUI_IsDev() then
		SetCVar("nameplateMotion", 1)
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end
end

function SyncUI_PlateFrame_OnEvent(self,event,...)
	if event == "VARIABLES_LOADED" then
		UpdateSize()
	end
	
	if event == "NAME_PLATE_CREATED" then
		local baseFrame = ...
		CreateNamePlate(baseFrame)
	end
	
	if event == "NAME_PLATE_UNIT_ADDED" then
		local unitID = ...
		AddNamePlate(unitID)
	end
	
	if event == "NAME_PLATE_UNIT_REMOVED" then
		local unitID = ...
		RemoveNamePlate(unitID)
	end
	
	if event == "RAID_TARGET_UPDATE" then
		for _, baseFrame in pairs(C_NamePlate.GetNamePlates()) do
			UpdateRaidMark(baseFrame.UnitFrame)
		end
	end

	if event == "UNIT_FACTION" then
		local unitID = ...
		local baseFrame = C_NamePlate.GetNamePlateForUnit(unitID)
		
		if baseFrame then
			local unitFrame = baseFrame.UnitFrame
		
			UpdateName(unitFrame)
			UpdateBarColor(unitFrame)
		end
	end
end


-- Nameplate Unit Functions
function SyncUI_NamePlateUnitFrame_OnLoad(self)
	SyncUI_CreateAuraHeader(self, "BOTTOMLEFT", self.HealthBar, "TOPLEFT", 1, 15, self.unitID, "Aura", 4, 1, 22, -22, 86, 22, "SyncUI_NameplateAuraTemplate")
end

function SyncUI_NamePlateUnitFrame_OnUpdate(self, elapsed)
	if self.unitID then
		UpdateHealth(self)
		UpdatePower(self)
	end	
end

function SyncUI_NamePlateUnitFrame_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		UpdateUnit(self)
	end

	if event == "PLAYER_TARGET_CHANGED" then
		UpdateName(self)
		UpdateSelection(self)
	end

	if event == "UNIT_THREAT_LIST_UPDATE" or event == "UNIT_NAME_UPDATE" then
		UpdateName(self)
		UpdateBarColor(self)
		UpdateThreat(self)
	end	

	if event == "UNIT_AURA" then
		UpdateAuras(self)
	end
end
