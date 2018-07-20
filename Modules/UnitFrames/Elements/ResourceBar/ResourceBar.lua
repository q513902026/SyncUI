
local maxTokens = 6
local class = select(2, UnitClass("player"))
local prevComboPoints = 0

local SPELL_POWER_ARCANE_CHARGES = SPELL_POWER_ARCANE_CHARGES or Enum.PowerType.ArcaneCharges
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER or Enum.PowerType.HolyPower
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS or Enum.PowerType.SoulShards
local SPELL_POWER_CHI = SPELL_POWER_CHI or Enum.PowerType.Chi
local SPELL_POWER_COMBO_POINTS = SPELL_POWER_COMBO_POINTS or Enum.PowerType.ComboPoints

local BorderTable = {
	[4] = {
		["Size"] = {42,10},
		["Coords"] = {0, 0.75, 0.25, 0.4375},
	},
	[5] = {
		["Size"] = {33,10},
		["Coords"] = {0, 0.75, 0.5, 0.6875},
	},
	[6] = {
		["Size"] = {27,10},
		["Coords"] = {0, 0.75, 0.75, 0.9375},
	},
}

local BarTypeTable = {
	["Arcane"] = {
		["PowerMax"] = 4,
		["PowerType"] = SPELL_POWER_ARCANE_CHARGES,
		["PowerColor"] = {0.2,0.6,1.0},
	},
	["Holy"] = {
		["PowerMax"] = 5,
		["PowerType"] = SPELL_POWER_HOLY_POWER,
		["PowerColor"] = {1.0,0.9,0.3},
	},
	["Shard"] = {
		["PowerMax"] = 5,
		["PowerType"] = SPELL_POWER_SOUL_SHARDS,
		["PowerColor"] = {0.8,0.0,1.0},
	},
	["Chi"] = {
		["PowerType"] = SPELL_POWER_CHI,
		["PowerColor"] = {0.6,1.0,0.8},
	},
}

local function SetupGenericBar(self, barType)
	local powerType = BarTypeTable[barType]["PowerType"]
	local powerMax = BarTypeTable[barType]["PowerMax"] or ( barType == "Chi" and UnitPowerMax("player", powerType) )
	local left, right, top, bottom = unpack(BorderTable[powerMax]["Coords"])

	for i = 1, maxTokens do
		local token = self["Token"..i]

		if i <= powerMax then
			local r,g,b = unpack(BarTypeTable[barType]["PowerColor"])
			local x,y = unpack(BorderTable[powerMax]["Size"])
			
			token:Show()
			token:SetStatusBarColor(r,g,b)
			token:SetSize(x,y)
		else
			token:Hide()
		end
	end
	
	self.powerMax = powerMax
	self.powerType = powerType
	self.Border.Tex:SetTexCoord(left,right,top,bottom)
end


-- Update Functions
local function UpdateAlternateBar(self)
	local power, maxPower = UnitPower("player"), UnitPowerMax("player")
	local statusBar = self.StatusBar
	
	statusBar:SetMinMaxValues(0, maxPower)
	SmoothBar(statusBar, power)
	
	if power > 0 then
		self.ArtFrame.Value:SetText(power)
	else
		self.ArtFrame.Value:SetText("")
	end
	
	if not self.init then
		local powerType = select(2, UnitPowerType("player"))
		local color = SYNCUI_POWER_COLORS[powerType]
		local r,g,b = unpack(color)

		self.StatusBar:SetStatusBarColor(r,g,b)	
	end
end

local function UpdateGenericBar(self)
	if self.powerMax and self.powerType then
		local powerType = UnitPower("player", self.powerType)
		
		for i = 1, self.powerMax do
			local token = self["Token"..i]

			if i <= powerType then
				token:SetValue(1)
			else
				token:SetValue(0)
			end
		end
	end
end

local function UpdateStatueButton(self)
	if GetTotemInfo(1) then
		local haveTotem, name, start, duration, icon = GetTotemInfo(1)
		local statusBar = self.StatusBar
		local timer = self.Timer
		local timeLeft = math.ceil(start + duration - GetTime())
		
		self:SetAlpha(1)
		self.Icon:SetTexture(icon)

		statusBar:SetMinMaxValues(0,duration)
		statusBar:SetValue(GetTime()-start)
		statusBar:SetStatusBarColor(0,0,0,0.75)
		
		if timeLeft then
			if timeLeft >= 60 then
				timer:SetText(gsub(format(MINUTE_ONELETTER_ABBR, string.format("%.0f",timeLeft/60))," ",""))
			elseif timeLeft > 0 then
				timer:SetText(string.format("%.0f",timeLeft))
			else
				timer:SetText("")
			end
		end
	else
		self:SetAlpha(0)
	end
end

local function UpdateStaggerBar(self)
	local stagger, maxStagger = UnitStagger("player"), UnitHealthMax("player")
	local perc = math.ceil(stagger*100/maxStagger)
	local statusBar = self.StatusBar
	
	--Update value + maxValue
	statusBar:SetMinMaxValues(0, maxStagger)
	SmoothBar(statusBar,stagger)
	
	--Update Color
	if perc > 60 then
		statusBar:SetStatusBarColor(1,0,0)
	elseif perc > 30 then
		statusBar:SetStatusBarColor(1,1,0)
	else
		statusBar:SetStatusBarColor(0,1,0)
	end
end

local function UpdateTotemBar(self)
	for i = 1, 4 do
		local totem = self["Totem"..i]

		if GetTotemInfo(i) then
			local haveTotem, name, start, duration, icon = GetTotemInfo(i)
			local timeLeft = math.ceil(start + duration - GetTime())
			
			totem.Icon:SetTexture(icon)
			totem.StatusBar:SetMinMaxValues(0,duration)
			totem.StatusBar:SetValue(GetTime()-start)
			totem.StatusBar:SetStatusBarColor(0,0,0,0.75)
			
			if timeLeft then
				if timeLeft >= 60 then
					totem.Timer:SetText(gsub(format(MINUTE_ONELETTER_ABBR,string.format("%.0f",timeLeft/60))," ",""))
				elseif timeLeft > 0 then
					totem.Timer:SetText(string.format("%.0f",timeLeft))
				else
					totem.Timer:SetText("")
				end
			end
		else
			totem.Icon:SetTexture("")
			totem.StatusBar:SetStatusBarColor(0,0,0,0)
			totem.Timer:SetText("")
		end		
	end
end

local function UpdateComboBar(self, event, ...)
	local comboPoints = UnitPower("player", SPELL_POWER_COMBO_POINTS)
	local maxComboPoints = UnitPowerMax("player", SPELL_POWER_COMBO_POINTS)
	local maxShown = 5
	
	for i = 1, maxShown do
		local token = self["Token"..i]

		if comboPoints > maxShown then
			local extra = comboPoints > maxShown and comboPoints - maxShown
			
			if i <= extra then
				token:SetStatusBarColor(0,1,0)
			else
				token:SetStatusBarColor(1,0,0)
			end
		else
			token:SetStatusBarColor(1,0,0)
		end

		if i <= comboPoints then
			token:SetValue(1)
		else
			token:SetValue(0)
		end
	end
end


function SyncUI_ResourceBar_OnLoad(self)
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	
	if class == "DRUID" then 
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	end
	
	self.GenericBar:SetScript("OnUpdate", UpdateGenericBar)
	self.GenericBar.Setup = SetupGenericBar
	self.AlternateBar:SetScript("OnUpdate", UpdateAlternateBar)
	self.ComboBar:SetScript("OnEvent", UpdateComboBar)
	self.StaggerBar:SetScript("OnUpdate", UpdateStaggerBar)
	self.StatueButton:SetScript("OnUpdate", UpdateStatueButton)
	self.TotemBar:SetScript("OnUpdate", UpdateTotemBar)
	
	SyncUI_RegisterDragFrame(self, "Resource Bar")
	RegisterStateDriver(self, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")
end

function SyncUI_ResourceBar_OnEvent(self, event, ...)
	local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization()) or nil
	
	-- Spec hasn't changed
	if event == "PLAYER_TALENT_UPDATE" and specID == self.specID then
		return
	end

	-- Spec has changed
	if event == "PLAYER_TALENT_UPDATE" then
		if class == "DEATHKNIGHT" then
			self.RuneBar:Show()
		end
		if class == "DRUID" then
			self.StatueButton:SetShown(specID == 105)
		end
		if class == "MAGE" then
			self.StatueButton:Show()
			self.GenericBar:SetShown(specID == 62)
			self.GenericBar:Setup("Arcane")
		end
		if class == "MONK" then
			self.StaggerBar:SetShown(specID == 268)
			self.StatueButton:SetShown(specID == 268 or specID == 270)
			self.GenericBar:SetShown(specID == 269)
			self.GenericBar:Setup("Chi")
			
			if specID == 269 then
				self:RegisterEvent("UNIT_MAXPOWER")
			else
				self:UnregisterEvent("UNIT_MAXPOWER")
			end
		end
		if class == "PALADIN" then
			self.StatueButton:Show()
			self.GenericBar:SetShown(specID == 70)
			self.GenericBar:Setup("Holy")
		end
		if class == "PRIEST" then
			self.AlternateBar:SetShown(specID == 258)
		end
		if class == "ROGUE" then
			self.ComboBar:Show()
		end
		if class == "SHAMAN" then
			self.TotemBar:Show()
			self.AlternateBar:SetShown(specID == 262 or specID == 263)
			
			if specID == 264 then
				self.TotemBar:SetPoint("TOP")
			else
				self.TotemBar:SetPoint("TOP", self.AlternateBar, "BOTTOM", 0, 5)
			end
		end
		if class == "WARLOCK" then
			self.GenericBar:Show()
			self.GenericBar:Setup("Shard")
			self.TotemBar:SetShown(specID == 266)
			self.TotemBar:SetPoint("TOP", self.AlternateBar, "BOTTOM", 0, 5)
		end
		
		self.specID = specID
	end
	
	-- Windwalker Max Chi Update
	if event == "UNIT_MAXPOWER" then
		self.GenericBar:Setup("Chi")
		return
	end
	
	-- Druid Shapeshifting
	if event == "UPDATE_SHAPESHIFT_FORM" then
		local form = GetShapeshiftForm()

		self.ComboBar:SetShown(form == 2)
		self.AlternateBar:SetShown(form == 4 and specID == 102)
	end
end
