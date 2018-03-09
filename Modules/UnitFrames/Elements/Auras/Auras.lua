
local function GetColor(timer, point)
	local perc = timer/point
	local r,g,b

	if math.floor(timer) > point then
		return 0,1,0
	else
		if perc > 0.5 then
			return 0+(1-perc)*2,1,0
		else
			return 1,0+perc*2,0
		end
	end
end

local function UpdateAura(self, icon, charge, duration, expire, spellID, secure)
	local timeLeft = duration - expire + GetTime()
	
	self.spellID = spellID
	self.timer = GetTime() - timeLeft
	self.Cooldown:SetCooldown(GetTime() - timeLeft, duration)
	self.Icon:SetTexture(icon)
	
	if charge > 1 then
		self.Charge:SetText(charge)
	else
		self.Charge:SetText("")
	end
	
	if not secure then
		self:Show()
	end
end

local function UpdateAuraIndex(self, auraType, unitID)
	for index = 1, 40 do
		local spellID

		if auraType == "Buff" then
			spellID = select(11, UnitBuff(unitID,index))
		elseif auraType == "Debuff" then
			spellID = select(11, UnitDebuff(unitID,index))
		end
		
		if self.spellID == spellID then
			self:SetID(index)
			return
		end
	end
end

local function UpdateSecureHeader(self)
	local unitID = SecureButton_GetUnit(self)
	local filter = self:GetAttribute("filter")
	local maxAuras = self:GetAttribute("wrapAfter") * self:GetAttribute("maxWraps")

	if self:IsShown() and unitID then
		for index = 1, maxAuras do
			local aura = self:GetAttribute("child" .. index)
			
			if aura then
				local index = aura:GetID()
				local name,_,icon,charge,_,duration,expire,_,_,_,spellID = UnitAura(unitID, index, filter)
				
				if name then
					UpdateAura(aura, icon, charge, duration, expire, spellID, true)
				end
			end
		end
	end
end

local function SetUnitAura(self)
	local unitID = self.unitID
	local maxAuras = self.maxAuras
	local auraType = self.auraType
	local filter

	if self.isNamePlate then
		filter = "PLAYER"
	end
	
	for index = 1, self.maxAuras do
		local aura = self["AuraButton"..index]

		if aura then
			local icon, charge, duration, expire, caster, spellID
			
			aura:Hide()
			
			if auraType == "Buff" then
				icon, charge, _, duration, expire, caster, _, _, spellID = select(3, UnitBuff(unitID, index, filter))
			end
			
			if auraType == "Debuff" then
				local profile = SyncUI_GetProfile()
				
				if profile and profile.Options.Auras.DebuffFilter then
					local reaction = UnitReaction("player", unitID)
					
					if reaction and reaction <= 4 and unitID ~= "player" then
						filter = "PLAYER"
					end
					
					--[[
					if unitID == "targettarget" or unitID == "focustarget" or (reaction and reaction >= 5) then
						filter = "NONE"
					elseif unitID ~= "player" then
						filter = "PLAYER"
					end
					--]]
				end
				
				icon, charge, _, duration, expire, caster, _, _, spellID = select(3, UnitDebuff(unitID, index, filter))
			end

			if spellID then
				UpdateAura(aura, icon, charge, duration, expire, spellID)
				
				if auraType == "Debuff" then
					if caster == "player" or caster == "pet" or UnitIsFriend("player", unitID) then
						aura.Icon:SetDesaturated(false)
					else
						aura.Icon:SetDesaturated(true)
					end
				end
				
				--[[if auraType == "Debuff" then
					if caster == "player" or caster == "pet" then
						aura.Icon:SetDesaturated(false)
					elseif unitID ~= "player" and
						if UnitIsEnemy("player", unitID) then
							aura.Icon:SetDesaturated(true)
						else
							aura.Icon:SetDesaturated(false)
						end
					end
				end
				--]]
			end
		end
	end
end

local function SetReactiveAura(self, index, max)
	local profile = SyncUI_GetProfile()

	if not profile or not profile.ReactiveAuras then
		return
	end

	local unitID = "player"
	local icon, charge = select(3, UnitBuff(unitID,index))
	local duration, expire, caster = select(6, UnitBuff(unitID,index))
	local spellID = select(11, UnitBuff(unitID,index))
		
	if spellID then
		for _, AuraFilterID in pairs(profile.ReactiveAuras) do
			if spellID == tonumber(AuraFilterID) then
				for i = 1, self.maxAuras do
					local aura = self["Aura"..i]
					
					if aura and aura.spellID == nil then
						UpdateAura(aura,icon,charge,duration,expire,spellID)
						UpdateAuraIndex(aura, self.auraType, unitID)
	
						return max + 1
					end
				end
			end
		end
	end

	return max
end


function SyncUI_AuraButton_OnEnter(self)
	local header = self:GetParent()
	local unitID = header.unitID or header:GetParent():GetAttribute("unit")
	local filter = (header.auraType == "Buff") and "HELPFUL" or "HARMFUL";
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",-25,0)
	GameTooltip:SetUnitAura(unitID, self:GetID(), filter)
	GameTooltip:Show()
end

function SyncUI_AuraButton_OnUpdate(self)
	local frame = SyncUI_OptionPanel_Aura.General
	local optTimer = frame.DurationTimer:GetChecked()
	local optColor = frame.DurationColor:GetChecked()
	local optSpiral = frame.DurationSpiral:GetChecked() and frame.DurationSpiral:IsEnabled()

	if optSpiral then
		self.Cooldown:SetAlpha(0)
	else
		self.Cooldown:SetAlpha(1)
	end

	if not optTimer then
		self.Time:SetText("")
		return
	end

	if not self.timer then
		return
	end

	local duration = self.Cooldown:GetCooldownDuration() / 1000
	local timer = self.timer + duration - GetTime()

	if timer then
		if self.Icon:IsDesaturated() or not optColor then
			self.Time:SetVertexColor(1,1,1)
		else
			self.Time:SetVertexColor(GetColor(timer, 10))
		end

		if timer >= 3600 then
			self.Time:SetText(gsub(format(HOUR_ONELETTER_ABBR,math.floor(timer/60/60))," ",""))
		elseif  timer >= 60 then 
			self.Time:SetText(gsub(format(MINUTE_ONELETTER_ABBR,math.floor(timer/60))," ",""))
		elseif timer >= 5 then
			self.Time:SetText(math.floor(timer))
		elseif timer >= 0.1 then
			self.Time:SetText(string.format("%.1f",timer))
		else
			self.timer = 0
			self.Time:SetText("")
		end
	else
		self.timer = 0
		self.Time:SetText("")
	end
end

function SyncUI_ReactiveAuraBar_OnEvent(self)
	local max = 0

	for i = 1, self.maxAuras do
		local aura = self["Aura"..i]
		
		if aura then
			aura.spellID = nil
			aura:Hide()
		end
	end

	for index = 1, 40 do
		max = SetReactiveAura(self, index, max)
	end
end


-- Aura Header
function SyncUI_AuraHeader_OnEvent(self, event, ...)
	local unit = ...;
	local unitID = self.unitID
	
	SetUnitAura(self)
end

function SyncUI_AuraHeader_OnUpdate(self)
	if self.unit then
		local unit = UnitGUID(self.unitID)
		
		if unit ~= self.unit then
			SetUnitAura(self)
			self.unit = unit
		end
	end
end

function SyncUI_CreateAuraHeader(self, point, relativeTo, relativePoint, xPos, yPos, unitID, auraType, perRow, numRows, xOffset, yOffset, minWidth, minHeight, template, usePlacementTool)
	local header = CreateFrame("Frame", self:GetName()..auraType.."Header", self, "SyncUI_AuraHeaderTemplate")
	local maxAuras = perRow*numRows
	
	header:SetSize(minWidth, minHeight)
	header:SetPoint(point,relativeTo,relativePoint,xPos,yPos)
	header.unitID = unitID
	header.auraType = auraType
	header.maxAuras = maxAuras
	header:RegisterUnitEvent("UNIT_AURA", unitID)
	
	if unitID == "target" then
		header:RegisterEvent("PLAYER_TARGET_CHANGED")
	elseif unitID == "focus" then
		header:RegisterEvent("PLAYER_FOCUS_CHANGED")
	elseif unitID == "targettarget" or unitID == "focustarget" then
		header.unit = true
	end
	
	for i = 1, maxAuras do
		local pos = i % perRow ~= 0 and i % perRow or perRow
		local row = math.ceil(i / perRow)
		
		header["AuraButton"..i] = CreateFrame("Frame",header:GetName().."AuraButton"..i, header, template)
		header["AuraButton"..i]:SetID(i)
		header["AuraButton"..i]:SetPoint(point, xOffset*(pos-1), yOffset*(row-1))
	end
	
	self[auraType.."Header"] = header
	
	if usePlacementTool then
		SyncUI_RegisterDragFrame(header, usePlacementTool)	
	end
end

function SyncUI_CreateSecureAuraHeader(self, point, relativeTo, relativePoint, xPos, yPos, unitID, auraType, perRow, numRows, xOffset, yOffset, minWidth, minHeight, template, usePlacementTool)
	local header = CreateFrame("Frame", self:GetName()..auraType.."Header", self, "SecureAuraHeaderTemplate")
	local filter

	self[auraType.."Header"] = header
	
	if auraType == "Buff" then
		filter = "HELPFUL"
		
		if unitID == "player" then
			header:SetAttribute("separateOwn", 1)
		end
	elseif auraType == "Debuff" then
		filter = "HARMFUL"
	end

	header:SetPoint(point, relativeTo, relativePoint, xPos, yPos)
	header:SetAttribute("template", template)
	if not unitID then
		header:SetAttribute("useparent-unit", true)
	else
		header:SetAttribute("unit", unitID)
	end
	header:SetAttribute("filter", filter)
	header:SetAttribute("point", point)
	header:SetAttribute("minWidth", minWidth)
	header:SetAttribute("minHeight", minHeight)
	header:SetAttribute("xOffset", xOffset)
	header:SetAttribute("wrapYOffset", yOffset)
	header:SetAttribute("wrapAfter", perRow)
	header:SetAttribute("maxWraps", numRows)
	header:HookScript("OnEvent", UpdateSecureHeader)
	header:HookScript("OnShow", UpdateSecureHeader)
	header.auraType = auraType
	header:Show()
	
	if usePlacementTool then
		SyncUI_RegisterDragFrame(header, usePlacementTool)	
	end
	
	UpdateSecureHeader(header)
end

--[[	Secure Aura Header Template - Attribute List
	filter = [STRING] -- a pipe-separated list of aura filter options ("RAID" will be ignored)
	separateOwn = [NUMBER] -- indicate whether buffs you cast yourself should be separated before (1) or after (-1) others. If 0 or nil, no separation is done.
	sortMethod = ["INDEX", "NAME", "TIME"] -- defines how the group is sorted (Default: "INDEX")
	sortDirection = ["+", "-"] -- defines the sort order (Default: "+")
	groupBy = [nil, auraFilter] -- if present, a series of comma-separated filters, appended to the base filter to separate auras into groups within a single stream
	includeWeapons = [nil, NUMBER] -- The aura sub-stream before which to include temporary weapon enchants. If nil or 0, they are ignored.
	consolidateTo = [nil, NUMBER] -- The aura sub-stream before which to place a proxy for the consolidated header. If nil or 0, consolidation is ignored.
	consolidateDuration = [nil, NUMBER] -- the minimum total duration an aura should have to be considered for consolidation (Default: 30)
	consolidateThreshold = [nil, NUMBER] -- buffs with less remaining duration than this many seconds should not be consolidated (Default: 10)
	consolidateFraction = [nil, NUMBER] -- The fraction of remaining duration a buff should still have to be eligible for consolidation (Default: .10)
 
	template = [STRING] -- the XML template to use for the unit buttons. If the created widgets should be something other than Buttons, append the Widget name after a comma.
	weaponTemplate = [STRING] -- the XML template to use for temporary enchant buttons. Can be nil if you preset the tempEnchant1 and tempEnchant2 attributes, or if you don"t include temporary enchants.
	consolidateProxy = [STRING|Frame] -- Either the button which represents consolidated buffs, or the name of the template used to construct one.
	consolidateHeader = [STRING|Frame] -- Either the aura header which contains consolidated buffs, or the name of the template used to construct one.
 
	point = [STRING] -- a valid XML anchoring point (Default: "TOPRIGHT")
	minWidth = [nil, NUMBER] -- the minimum width of the container frame
	minHeight = [nil, NUMBER] -- the minimum height of the container frame
	xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: width)
	yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: height)
	wrapAfter = [NUMBER] -- begin a new row or column after this many auras
	wrapXOffset = [NUMBER] -- the x-offset from one row or column to the next
	wrapYOffset = [NUMBER] -- the y-offset from one row or column to the next
	maxWraps = [NUMBER] -- limit the number of rows or columns
--]]
