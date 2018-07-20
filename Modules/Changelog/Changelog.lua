 
local version = GetAddOnMetadata("SyncUI", "Version")

local maxLines, ChangeLogData = 5, {
	"Updated for 8.0 prepatch:",
	"Some Modules are currently disabled:",
		"• TalentUI",
}

local function ModifiedString(text)
	local result = text;
	local count = text:find(":");
	
	-- header + subHeader
	if count then
		local prefix = text:sub(0, count);
		local suffix = text:sub(count + 1);
		local subHeader = text:find("•");
		
		if subHeader then
			result = tostring("|cFF66FF00"..prefix.."|r"..suffix)
		else
			result = tostring("|cFFFF6600"..prefix.."|r"..suffix)
		end
	end

	-- highlights
	for pattern in text:gmatch("('.*')") do
		result = result:gsub(pattern, "|cFFFF8800" .. pattern:gsub("'","").."|r")
	end
	
	return result
end

local function GetChangeLogInfo(i)
	for line, info in pairs(ChangeLogData) do
		if line == i then
			return info
		end
	end
end


function SyncUI_ToggleChangeLog()
	local frame = SyncUI_ChangeLog
	local isPlaying = frame.SlideIn:IsPlaying() or frame.SlideOut:IsPlaying()

	if not isPlaying then
		if frame:IsShown() then
			frame.SlideOut:Play()
		elseif not SyncUI_OptionsMenu:IsShown() then
			frame.SlideIn:Play()
		end
	end
end

function SyncUI_ChangeLog_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.Version:SetText("|cFF7FFE00Sync|rUI - "..version)

	tinsert(UISpecialFrames,self:GetName())
end

function SyncUI_ChangeLog_OnCheckVersion(self)
	if not SyncUI_Data["Version"] or ( SyncUI_Data["Version"] and SyncUI_Data["Version"] ~= version) then
		SyncUI_Data["Version"] = version
		SyncUI_ToggleChangeLog()
	end
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function SyncUI_ChangeLog_OnScrollUpdate(self)
	local offset = FauxScrollFrame_GetOffset(self)
	local parent = self:GetParent()
	
	SyncUI_ScrollFrame_Update(self, #ChangeLogData, maxLines, 30)
	
	for i = 1, maxLines do
		local button = parent["Button"..i]
		local idx = offset + i
		
		if (idx <= #ChangeLogData) then
			local string = ModifiedString(GetChangeLogInfo(idx));
			
			button.Text:SetText(string);
			button.tipText = string;
			
			button:Show()
		else
			button:Hide()
		end
	end
end
