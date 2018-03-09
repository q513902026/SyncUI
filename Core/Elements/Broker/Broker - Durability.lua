
local slots = {
	[ 1] = HEADSLOT,
	[ 3] = SHOULDERSLOT,
	[ 5] = CHESTSLOT,
	[ 6] = WAISTSLOT,
	[ 7] = LEGSSLOT,
	[ 8] = FEETSLOT,
	[ 9] = WRISTSLOT,
	[10] = HANDSSLOT,
	[16] = MAINHANDSLOT,
	[17] = SECONDARYHANDSLOT,
}

local function Durability_OnUpdate(self)
	local durability, maxDurability, perc = 0, 0, 0
	
	for slot, type in pairs(slots) do
		local dur, maxDur = GetInventoryItemDurability(slot)
		
		if dur and maxDur then
			durability = durability + dur
			maxDurability = maxDurability + maxDur
		end
	end
	
	if durability > 0 and maxDurability > 0 then
		perc = math.floor(durability * 100 / maxDurability)
	end
	
	if perc >= 70 then
		perc = tostring("|cFF00FF00"..perc.."%|r")
	elseif perc >= 25 then
		perc = tostring("|cFFFFFF00"..perc.."%|r")
	else
		perc = tostring("|cFFFF0000"..perc.."%|r")
	end
	
	self:SetText(perc.." "..DURABILITY_ABBR)
end

local function Durability_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP",0,0)
	GameTooltip:AddLine(DURABILITY,1,1,1)
	GameTooltip:SetPrevLineJustify("CENTER")
	GameTooltip:AddDivider()
	
	local numEq = 0
	
	for slot, type in pairs(slots) do
		local dur, maxDur = GetInventoryItemDurability(slot)
		local perc;
		
		if dur then
			perc = math.floor(dur*100/maxDur)
			numEq = numEq + 1
		end
		
		if perc then
			if perc >= 70 then
				perc = tostring("|cFF00FF00"..perc.."|r %")
			elseif perc >= 25 then
				perc = tostring("|cFFFFFF00"..perc.."|r %")
			elseif perc > 0 then
				perc = tostring("|cFFFF0000"..perc.."|r %")
			else
				perc = SYNCUI_STRING_BROKEN
			end
			
			GameTooltip:AddDoubleLine(type, perc, 1,1,1, 1,1,1)
		end
	end
	
	if numEq == 0 then
		GameTooltip:ClearLines()
	end
	
	GameTooltip:Show()
end

do	-- Initialize
	local info = {}

	info.title = DURABILITY
	info.icon = "Interface\\Icons\\trade_blacksmithing"
	info.updateFunc = Durability_OnUpdate
	info.tooltipFunc = Durability_OnEnter
	
	SyncUI_RegisterBrokerType("Durability", info)
end