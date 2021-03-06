
local AddOnMemory = {}

local MemoryColor = {
	[1] = "007FFF",		-- Light Blue (0-100 KB)
	[2] = "00FF00",		-- Green  (0.1-1 MB)
	[3] = "FFFF00",		-- Yellow (1 - 2,5 MB) 
	[4] = "FF7F00",		-- Orange (2.5 - 5 MB)
	[5] = "FF0000",		-- Red (5+ MB)
	[6] = "FFFFFF",		-- White (ignored)
}

local function GetIndex(value,ignore)
	local index;
	
	if ignore then
		index = 6
	elseif value <= 100 then
		index = 1
	elseif value <= 1024 then
		index = 2
	elseif value <= 2560 then
		index = 3
	elseif value <= 5120 then
		index = 4
	elseif value > 5120 then
		index = 5
	end
	
	return index
end

local function GetFormattedMemory(value,ignore)
	local memory, suffix;
	local code = MemoryColor[GetIndex(value,ignore)]
	
	if value < 1024 then
		suffix = "KB"
		memory = string.format("%.0f",value)
	else
		suffix = "MB"
		memory = string.format("%.2f",value / 1024)
	end
	
	return tostring("|cFF"..code..memory.."|r "..suffix)
end

local function Memory_OnClick(self)
	local frame = ACP_AddonList or AddonList

	if frame:IsShown() then
		HideUIPanel(frame)
	else
		ShowUIPanel(frame)
	end
end

local function Memory_OnUpdate(self, elapsed)
	UpdateAddOnMemoryUsage()

	local memory = 0
	local ownMemory = 0;
	
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			local addOnMemory = GetAddOnMemoryUsage(i);
			
			memory = memory + addOnMemory

			if (GetAddOnInfo(i) == "SyncUI") then
				ownMemory = addOnMemory
			end
		end
	end
	
	if (SyncUI_IsDev()) then
		self:SetText(string.format("%.0f", ownMemory) .. " KB");
	else
		self:SetText(GetFormattedMemory(memory,true));
	end	
end

local function Memory_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(SYNCUI_STRING_MEMORY_LABEL,1,1,1)
	GameTooltip:SetPrevLineJustify("CENTER")
	GameTooltip:AddDivider()
	
	UpdateAddOnMemoryUsage()

	AddOnMemory = {}

	local maxMemory = gcinfo()
	local addOnMemory, numDiv = 0, 0

	-- Collect AddOn-Info
	for i = 1, GetNumAddOns(), 1 do
		if IsAddOnLoaded(i) then
			local memory = GetAddOnMemoryUsage(i)
			local addOn, name = GetAddOnInfo(i)

			addOnMemory = addOnMemory + memory
			
			tinsert(AddOnMemory,{name,memory})
		end
	end

	table.sort(AddOnMemory, function(a,b) return a[2] > b[2] end)

	-- Setup AddOn-Info after sorting
	for i = 1, #AddOnMemory do
		local name, memory = AddOnMemory[i][1],AddOnMemory[i][2]
		local divIndex = GetIndex(memory)
		
		if i == 1 then
			numDiv = divIndex
		elseif i > 1 and numDiv > divIndex then
			--GameTooltip:AddDivider()
			numDiv = numDiv - 1
		end
		
		GameTooltip:AddDoubleLine(name,GetFormattedMemory(memory),1,1,1,1,1,1)
	end

	GameTooltip:Show()
end

do	-- Initialize
	local info = {}

	info.title = SYNCUI_STRING_MEMORY
	info.icon = "Interface\\Icons\\inv_gizmo_khoriumpowercore"
	info.clickFunc = Memory_OnClick
	info.updateFunc = Memory_OnUpdate
	info.tooltipFunc = Memory_OnEnter
	
	SyncUI_RegisterBrokerType("Memory", info)
end

