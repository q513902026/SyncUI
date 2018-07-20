
local function GetUnitID(self)
	if strfind(self:GetName(),"Player") then
		return "player"
	elseif strfind(self:GetName(),"Target") then
		return "target"
	elseif strfind(self:GetName(),"Focus") then
		return "focus"
	elseif strfind(self:GetName(),"Party") then
		return "party"..self:GetID()		
	elseif strfind(self:GetName(),"Raid") then
		return "raid"..self:GetID()
	elseif strfind(self:GetName(),"Boss") then
		return "boss"..self:GetID()
	elseif strfind(self:GetName(),"Arena") then
		return "arena"..self:GetID()
	end
end

local function SetCastStart(self,spell,icon,r,g,b)
	if not self.showCastbar then
		return
	end

	self:SetStatusBarColor(r,g,b)			
	self.Icon:SetTexture(icon)
	self.Spell:SetText(spell)
	self.interrupted = nil
	self.FadeOut:Stop()
	self.Spark:Show()
	self:Show()
	self:SetAlpha(1)
end

local function SetCastStop(self)
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self.Timer:SetText("")
	self.Spark:Hide()

	if self.interrupted and not self.succeeded then
		self.Spell:SetText(SPELL_FAILED_INTERRUPTED)
		self:SetStatusBarColor(1,0,0)
	else
		self:SetStatusBarColor(0,1,0)
	end
	
	self.succeeded = nil
	self.interrupted = nil
	
	self.FadeOut:Play()
end


function SyncUI_CastingBar_OnLoad(self,isPet)
	local unitID = self:GetParent().unitID or GetUnitID(self:GetParent())

	self.showCastbar = true
	self.Icon = self.IconFrame.Icon
	self.Timer = self.IconFrame.Timer
	self.Spell = self.ArtFrame.Spell	
	self.Spark = self.ArtFrame.Spark
	self.Spark:ClearAllPoints()
	self.Spark:SetPoint("TOPRIGHT",self:GetStatusBarTexture(),4,0)
	self.Spark:SetPoint("BOTTOMRIGHT",self:GetStatusBarTexture(),4,0)

	if isPet then
		unitID = "pet"
		self.showCastbar = UnitIsPossessed("pet")
	end	

	self.unitID = unitID
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", unitID)
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unitID)
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unitID)
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unitID)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unitID)
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unitID)
	self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unitID)
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unitID)
	
	if unitID == "target" then
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
	end
	if unitID == "focus" then
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")	
	end
end

function SyncUI_CastingBar_OnEvent(self,event,...)
	local unitID = self.unitID

	if not unitID then return end
	
	if event == "PLAYER_ENTERING_WORLD" then
		SetCastStop(self)
	end
	
	if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
		if UnitCastingInfo(unitID) or UnitChannelInfo(unitID) then
			local spell,icon,noInterrupt,r,g,b

			if UnitCastingInfo(unitID) then
				spell = select(1, UnitCastingInfo(unitID))
				icon = select(3, UnitCastingInfo(unitID))
				noInterrupt = select(7, UnitCastingInfo(unitID))
				
				if noInterrupt then
					r,g,b = 1,0,0
				else
					r,g,b = 1,0.7,0
				end
			end
			
			if UnitChannelInfo(unitID) then
				spell = select(1, UnitChannelInfo(unitID))
				icon = select(3, UnitChannelInfo(unitID))	
				r,g,b = 0,1,0		
			end
			
			SetCastStart(self,spell,icon,r,g,b)
		else
			self:Hide()
		end
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if select(2, ...) == "SPELL_INTERRUPT" then
			if select(4, ...) == UnitGUID(unitID) then
				self.Spell:SetText(BATTLE_PET_MESSAGE_SPELL_LOCK)
				self.interrupted = true
			end
		end
		
		if select(2, ...) == "UNIT_DIED" then
			if select(4, ...) == UnitGUID(unitID) then
				SetCastStop(self)
			end
		end
	end


	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		self.succeeded = true
	end

	if event == "UNIT_SPELLCAST_INTERRUPTED" then
		self.interrupted = true
	end	

	if event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		self:SetStatusBarColor(1,0,0)
	end
	
	if event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
		if UnitCastingInfo(unitID) then
			self:SetStatusBarColor(1,0.7,0)
		end
		if UnitChannelInfo(unitID) then
			self:SetStatusBarColor(0,1,0)
		end
	end

	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
		local name, text, texture, startTime, endTime, isTradeSkill, noInterrupt, spellID;
		local r,g,b

		if event == "UNIT_SPELLCAST_START" then
			name, text, texture, startTime, endTime, isTradeSkill, noInterrupt, spellID = UnitCastingInfo(unitID);
			
			if noInterrupt then
				r,g,b = 1,0,0
			else
				r,g,b = 1,0.7,0
			end
		end
		
		if event == "UNIT_SPELLCAST_CHANNEL_START" then
			name, text, texture, startTime, endTime, isTradeSkill, noInterrupt, spellID = UnitChannelInfo(unitID);
			
			if noInterrupt then
				r,g,b = 1,0,0
			else
				r,g,b = 0,1,0
			end
		end
		
		SetCastStart(self,spell,icon,r,g,b)
	end

	if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		SetCastStop(self)
	end

	if event == "UNIT_PET" then
		local arg1 = ...
		
		if arg1 == "player" then
			self.showCastbar = UnitIsPossessed("pet")
		end
	end
end

function SyncUI_CastingBar_OnUpdate(self)
	local unitID = self.unitID
	local value, maxValue
	local timer
	
	if UnitCastingInfo(unitID) then
		local spell, _, icon, startTime, endTime = UnitCastingInfo(unitID)
		
		if spell then
			value = GetTime() - (startTime / 1000)
			maxValue = (endTime - startTime) / 1000
			timer = tonumber(format("%.1f",maxValue - value))
		end
	end

	if UnitChannelInfo(unitID) then
		local spell, _, icon, startTime, endTime = UnitChannelInfo(unitID)
		
		if spell then
			value = (endTime / 1000) - GetTime()
			maxValue = (endTime - startTime) / 1000
			timer = tonumber(format("%.1f",value))
		end
	end
	
	if UnitCastingInfo(unitID) or UnitChannelInfo(unitID) then
		self:SetMinMaxValues(0, maxValue)
		self:SetValue(value)

		if timer >= 0.1 then
			self.Timer:SetText(timer)
		else
			self.Timer:SetText("")
		end
	end
end
