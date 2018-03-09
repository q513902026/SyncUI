
local numDiminish, diminishReset = 4, 18

local CrowdControl = {
	["IMMUNE"] = {
		[   642] = "Divine Shield",
		[ 19263] = "Deterrence",
		[ 31224] = "Cloak of Shadows",
		[ 45438] = "Ice Block",
		[ 46924] = "Bladestorm",
		[ 47585] = "Dispersion",
		[ 48792] = "Icebound Fortitude",
		[ 49039] = "Lichborne",
		[110617] = "Deterrence (Symbiosis)",
		[110696] = "Ice Block (Symbiosis)",
		[110700] = "Divine Shield (Symbiosis)",
		[110715] = "Dispersion (Symbiosis)",
		[115018] = "Desecrated Ground",
		[122465] = "Dematerialize",
	},
	["CROWD"] = {
	--Stuns
		[108194] = "Asphyxiate",
		[ 91800] = "Gnaw",
		[ 91797] = "Monstrous Blow",
		[115001] = "Remorseless Winter",
		[ 22570] = "Maim",
		[  9005] = "Pounce",
		[  5211] = "Mighty Bash",
		[102795] = "Bear Hug",
		[113801] = "Bash",
		[110698] = "Hammer of Justice (Symbiosis)",
		-- Bash (Force of Nature)
		[ 24394] = "Intimidation",
		[ 50519] = "Sonic Blast",
		[ 90337] = "Bad Manner",
		--[ 96201] = "Web Wrap",
		[117526] = "Binding Shot",
		[ 44572] = "Deep Freeze",
		[118271] = "Combustion Impact",
		[119392] = "Charging Ox Wave",
		[119381] = "Leg Sweep",
		[122242] = "Clash",
		[120086] = "Fists of Fury",
		[   853] = "Hammer of Justice",
		[119072] = "Holy Wrath",
		[105593] = "Fist of Justice",
		-- Blinding Light (Glyphed)
		[  1833] = "Cheap Shot",
		[   408] = "Kidney Shot",
		[118905] = "Capacitor Totem",
		-- Pulverize (Earth Elemental)	
		[ 30283] = "Shadowfury",
		[ 89766] = "Axe Toss",
		[132168] = "Shockwave",
		[105771] = "Warbringer",
		[132169] = "Storm Bolt", 
		[ 20549] = "War Stomp",
	--Disorient
		[  2637] = "Hibernate",
		[    99] = "Disorienting Roar",
		[  3355] = "Freezing Trap",
		[ 19386] = "Wyvern Sting",
		[   118] = "Polymorph",
		[ 28272] = "Polymorph (pig)",
		[ 28271] = "Polymorph (turtle)",
		[ 61305] = "Polymorph (black cat)",
		[ 61025] = "Polymorph (serpent)",
		[ 61721] = "Polymorph (rabbit)",
		[ 61780] = "Polymorph (turkey)",
		[ 82691] = "Ring of Frost",
		[115078] = "Paralysis",
		[105421] = "Blinding Light",
		[ 20066] = "Repentance",
		[  9484] = "Shackle Undead",
		[ 88625] = "Holy Word: Chastise",
		[  1776] = "Gouge",
		[  6770] = "Sap",
		[ 51514] = "Hex",
		[107079] = "Quaking Palm",
	--Fear
		[  1513] = "Scare Beast",
		-- Intimidating Shout (Symbiosis)
		[ 10326] = "Turn Evil",
		[  8122] = "Psychic Scream",
		[113792] = "Psychic Terror",
		[  2094] = "Blind",
		[118699] = "Fear",
		[130616] = "Fear (glyphed)",
		[  5484] = "Howl of Terror",
		[  6358] = "Seduction (Succubus)",
		[115268] = "Mesmerize (Shivarra)",
		[104045] = "Sleep (Metamorphosis)",
		[  5246] = "Intimidating Shout (Aoe)",
		[ 20511] = "Intimidating Shout (Single)",
	--Horror 
		[ 64044] = "Psychic Horror",
		[ 87204] = "Sin and Punishment",
		[  6789] = "Mortal Coil",
		[137143] = "Blood Horror",
	--Others
		[33786] = "Cyclone",
		--Cyclone (Symbiosis)
		[605] = "Dominate Mind",
	},
	["SILENCE"] = {
		[ 47476] = "Strangulate",
		[ 81261] = "Solar Beam",
		[114238] = "Fae Silence",	
		[ 34490] = "Silencing Shot",
		[ 55021] = "Improved Counterspell",
		[102051] = "Frostjaw",
		[116709] = "Spear Hand Strike",
		[137460] = "Ring of Peace",
		[ 31935] = "Avenger's Shield",
		[ 15487] = "Silence",
		[  1330] = "Garrote",		
		[113287] = "Solar Beam (Symbiosis)",
		[ 24259] = "Spell Lock",
		[ 31117] = "Unstable Affliction",
		[115782] = "Optical Blast",
		[132409] = "Spell Lock (Grimoire of Sacrifice)",		
		[ 25046] = "Arcane Torrent (Energy)", 
		[ 28730] = "Arcane Torrent (Mana)",
		[ 50613] = "Arcane Torrent (Runic Power)",
		[ 69179] = "Arcane Torrent (Rage)",
		[ 80483] = "Arcane Torrent (Focus)",
		[129597] = "Arcane Torrent (Chi)",
	},
	["RANDOM"] = {
	--Stun
		[113953] = "Paralytic Poison",	
		[ 77505] = "Earthquake",	
		[118895] = "Dragon Roar",		
		[  7922] = "Charge",
	--Confuse
		[ 19503] = "Scatter Shot",
		[ 31661] = "Dragon's Breath",
	},
};

local function GetPriority(type)
	if type == "IMMUNE" then
		return 5
	end
	if type == "CROWD" then
		return 4
	end
	if type == "SILENCE" then
		return 3
	end
	if type == "RANDOM" then
		return 2
	end

	return
end

local function UpdateTrinket(self)
	if not self.start then return end
	local start, duration = self.start, self.duration
	local timer = math.ceil(start + duration - GetTime())
	local text = ""
	
	if timer > 60 then
		text = gsub(format(MINUTE_ONELETTER_ABBR,math.ceil(timer/60))," ","")
	elseif timer == 60 then
		text = gsub(format(MINUTE_ONELETTER_ABBR,2)," ","")
	elseif timer >= 1 then
		text = timer
	end
	
	self.Text:SetText(text)
end

local function UpdatePrepFrames(self)
	local numOpps = GetNumArenaOpponentSpecs()
	
	for index = 1, MAX_ARENA_ENEMIES do
		local prepFrame = _G["SyncUI_ArenaPrepFrame"..index]
		local unitID = "arena"..index
		
		if index <= numOpps then
			local specID, gender = GetArenaOpponentSpec(index)
			
			if specID > 0 then
				local icon = select(4, GetSpecializationInfoByID(specID))
				local class = select(7, GetSpecializationInfoByID(specID))
				
				if class then
					local classColor = RAID_CLASS_COLORS[class]
					local r,g,b = classColor.r, classColor.g, classColor.b

					prepFrame.HealthBar:SetStatusBarColor(r,g,b)
				end
				
				prepFrame.Spec:SetTexture(icon)
				prepFrame:Show()
			else
				prepFrame:Hide()
			end
		else
			prepFrame:Hide()
		end
	end
end


function SyncUI_ArenaFrame_OnLoad(self)
	LoadAddOn("Blizzard_ArenaUI")
	SyncUI_DisableFrame("ArenaEnemyFrame"..self:GetID())
	SyncUI_DisableFrame("ArenaPrepFrame"..self:GetID())
	
	self.unitID = "arena"..self:GetID()
	self:SetAttribute("unit", self.unitID)
	self:SetAttribute("type1", "target")
	self:SetAttribute("type2", "focus")
	self:RegisterForClicks("AnyUp")
	
	self.Spec = self.ArtFrame.Spec
	self.Name = self.ArtFrame.Name
	self.Health = self.ArtFrame.Health
	self.StatusIcon = self.ArtFrame.StatusIcon
	self.Faction = self.ArtFrame.Faction

	RegisterUnitWatch(self)
	SyncUI_UnitFrame_OnRegisterClickCasting(self)
end

function SyncUI_ArenaFrame_OnShow(self)
	local name, class = select(1, UnitName(self.unitID)), select(2, UnitClass(self.unitID))
	local instanceType = select(2, GetInstanceInfo())

	if class then
		local color = SYNCUI_CLASS_COLORS[class]
		local r,g,b = color.r, color.g, color.b
		
		self.HealthBar:SetStatusBarColor(r,g,b,0)
	end
	
	if instanceType == "arena" then
		local specID = GetArenaOpponentSpec(self:GetID()) or 0
		local texture = select(4, GetSpecializationInfoByID(specID)) or "Interface\\Icons\\INV_MISC_QUESTIONMARK"
		
		self.Spec:SetTexture(texture)
		self.Spec:SetTexCoord(0.05,0.95,0.05,0.95)
		self.Trinket:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED",self.unitID)
	else
		local left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[strupper(class)])
		local faction = UnitFactionGroup(self.unitID)
		
		self.Spec:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
		self.Spec:SetTexCoord(left+0.02, right-0.02, top+0.02, bottom-0.02)
		
		if faction and faction ~= "Neutral" then
			self.Faction:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..faction)
			self.Faction:Show()
		end
	end

	self.Name:SetText(name)
	--self.CastingBar:Hide()
	self.Crowd:RegisterUnitEvent("UNIT_AURA",self.unitID)
end

function SyncUI_ArenaFrame_OnHide(self)
	self.StatusIcon:Hide()
	self.Faction:Hide()
	--self.CastingBar:Hide()
	
	self.Crowd:UnregisterAllEvents()
	self.Trinket.start = nil
	self.Trinket.Text:SetText("")
	self.Trinket:UnregisterAllEvents()
end

function SyncUI_ArenaFrame_OnUpdate(self, elapsed)
	local unitID = "arena"..self:GetID()

	if UnitExists(unitID) then
		local name, class = select(1, UnitName(unitID)), select(2, UnitClass(unitID))
		local health, maxHealth = UnitHealth(unitID), UnitHealthMax(unitID)
		local mana, maxMana = UnitMana(unitID), UnitManaMax(unitID)
		local absorb = UnitGetTotalAbsorbs(unitID) or 0
		local barWidth, barHeight = self.HealthBar:GetSize()
		
		-- Values
		self.HealthBar:SetMinMaxValues(0, maxHealth)
		self.ManaBar:SetMinMaxValues(0, maxMana)
		SmoothBar(self.HealthBar,health)		
		SmoothBar(self.ManaBar,mana)
		
		-- Set Name
		self.Name:SetText(name)

		-- Health Bar Text
		if UnitIsDeadOrGhost(unitID) then
			self.Health:SetText("")
			self.HealthBar:SetValue(0)
		else
			if health >= 10000000 then
				self.Health:SetText(string.format("%.0f",(health)/1000000).."m".." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%")
			elseif health >= 10000 then
				self.Health:SetText(string.format("%.0f",(health)/1000).."k".." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%")
			elseif health > 0 then
				self.Health:SetText(health.." | "..string.format("%.0f",math.ceil((health)*100/maxHealth)).."%")
			end
		end

		-- AbsorbBar		
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

		-- Update Status
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

	-- Update Trinket
	UpdateTrinket(self.Trinket)
end

function SyncUI_ArenaFrame_OnTrinketUse(self,event, ...)
	local unitID, spell, rank, lineID, spellID = ...
	if spellID == 59752 or spellID == 42292 then
		--PlaySound("AlarmClockWarning3", "Master")
		self.start = GetTime()
		self.duration = 120
	elseif spellID == 7744 then
		if not self.start or (self.start and GetTime() - self.start > 90) then
			self.start = GetTime()
			self.duration = 30
		end
	end
	
	if self.start and self.duration then
		self.cooldown:SetCooldown(self.start,self.duration)
	end
end

function SyncUI_ArenaFrame_SetCrowdControl(self)
	local parent = self:GetParent()
	local unitID = "arena"..parent:GetID()
	
	local maxPriority = 1
	local getExpire = 0
	local Icon, Duration

	do	--Buffs
		for i = 1, 40 do
			local name, _, icon, _, _, duration, expire, _, _, _, spellID = UnitBuff(unitID, i)
			if not spellID then break end
			
			for type in pairs(CrowdControl) do
				if CrowdControl[type][spellID] then
					local Priority = GetPriority(type)
					if Priority then
						if Priority == maxPriority and expire > getExpire then
							getExpire = expire
							Duration = duration
							Icon = icon
						elseif Priority > maxPriority then
							maxPriority = Priority
							getExpire = expire
							Duration = duration
							Icon = icon
						end
					end
				end
			end
		end
	end
	
	do	--Debuffs
		for i = 1, 40 do
			local name, _, icon, _, _, duration, expire, _, _, _, spellID = UnitDebuff(unitID, i)
			if not spellID then break end

			--Exception
			if spellID == 81261 then
				expire = GetTime() + 1 
			end
			
			for type in pairs(CrowdControl) do
				if CrowdControl[type][spellID] then
					local Priority = GetPriority(type)
					if Priority then
						if Priority > maxPriority then maxPriority = Priority end
						
						getExpire = expire
						Duration = duration
						Icon = icon
					end
				end
			end
		end
	end

	if getExpire == 0 then
		self:Hide()
		self.cooldown:Hide()
	elseif getExpire ~= self.getExpire then
		self:Show()
		self.Icon:SetTexture(Icon)
		
		if Duration and Duration > 0 then
			self.cooldown:Show()
			self.cooldown:SetCooldown(getExpire - Duration, Duration)
		end
	end
end


function SyncUI_ArenaPetFrame_OnLoad(self)
	self.unitID = "arenapet"..self:GetParent():GetID()
	self:SetAttribute("unit", self.unitID)
	self:SetAttribute("type1", "target")
	self:SetAttribute("type2", "focus")
	self:RegisterForClicks("AnyUp")
	
	self.Icon = self.ArtFrame.Icon
	
	RegisterUnitWatch(self)
	SyncUI_UnitFrame_OnRegisterClickCasting(self)
end

function SyncUI_ArenaPetFrame_OnShow(self)
	local unitID = self.unitID
	local texture = SYNCUI_PETICONS[UnitCreatureFamily(unitID)] or "Interface\\Icons\\INV_MISC_QUESTIONMARK"
	local index = self:GetParent():GetID()
	local specID = GetArenaOpponentSpec(index)
	
	if specID == 64 then
		texture = SYNCUI_PETICONS["Water Elemental"]
	end
	
	self.Icon:SetTexture(texture)
end


function SyncUI_ArenaPrepFrame_OnLoad(self)
	self:SetScale(0.85)
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("ARENA_OPPONENT_UPDATE")
	
	local numOpps = GetNumArenaOpponentSpecs()
	if numOpps and numOpps > 0 then
		SyncUI_ArenaPrepFrame_OnEvent(self, "ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	end
end

function SyncUI_ArenaPrepFrame_OnEvent(self,event,...)
	if event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
		UpdatePrepFrames(self)
		self:Show()
	end
	
	if event == "ARENA_OPPONENT_UPDATE" then
		local unitID, type = ...
		local index = unitID:find("%w")
		local instance = select(2, IsInInstance())
		local prepFrame = _G["SyncUI_ArenaPrepFrame"..index]

		if type == "unseen" then
			prepFrame:Show()
		elseif type == "seen" or type == "destroyed" then
			prepFrame:Hide()
		elseif type == "cleared" and instance ~= "arena" then
			self:Hide()
		end
	end
end
