
local MAX_RCW_LINES = 5
local ReadyCheckInfo, ReadyCheckStatus = {}, {}
local ReadyCheckFinished, ReadyCheckFading, ReadyCheckTimer
local _G, gsub, tinsert, tremove = _G, gsub, table.insert, table.remove

local function GetInfo(index)
	local name, status
	
	for k, v in pairs(ReadyCheckInfo) do
		if k == index then
			name = v
			break
		end
	end
	
	for k, v in pairs(ReadyCheckStatus) do
		if k == index then
			status = v
			break
		end
	end
	
	return name, status
end

local function GetInfoIndex(name)
	for k, v in pairs(ReadyCheckInfo) do
		if v == name then
			return k
		end
	end
end

local function GetTexture(status)
	local path, left, right, top, bottom
	
	if status == "offline" then
		path = "Interface\\CHARACTERFRAME\\Disconnect-Icon"
		left, right, top, bottom = 0.2,0.8,0.2,0.8
	else
		if status == "ready" then
			path = READY_CHECK_READY_TEXTURE
		elseif status == "notready" then
			path = READY_CHECK_NOT_READY_TEXTURE
		elseif status == "waiting" then
			path = READY_CHECK_WAITING_TEXTURE
		end
		
		left, right, top, bottom = 0,1,0,1
	end
	
	return path, left, right, top, bottom
end

local function ReadyCheck_OnReset()
	ReadyCheckFinished = nil
	ReadyCheckFading = nil
	ReadyCheckInfo = {}
	ReadyCheckStatus = {}
end

local function ReadyCheck_OnInit(...)
	ReadyCheck_OnReset()
	
	ReadyCheckTimer = select(2, ...)
	
	local user, duration = ...
	user = user:gsub("%-.+", "")
	
	for i = 1, GetNumGroupMembers() do
		local unitID
		
		if IsInRaid() then
			unitID = "raid"..i
		elseif i == GetNumGroupMembers() then
			unitID = "player"
		else
			unitID = "party"..i
		end
		
		local name = select(1, UnitName(unitID))
		
		if not tContains(ReadyCheckInfo,name) and name ~= user then
			tinsert(ReadyCheckInfo,name)
			
			if UnitIsConnected(name) then
				tinsert(ReadyCheckStatus,"waiting")
			else
				tinsert(ReadyCheckStatus,"offline")
			end
		end
	end
end

local function ReadyCheck_OnUpdate(...)
	local unitID, status = ...
	local name = select(1, UnitName(unitID))
	local index = GetInfoIndex(name)
	
	if index then
		if status then
			ReadyCheckStatus[index] = "ready"
			tremove(ReadyCheckStatus,index)
			tremove(ReadyCheckInfo,index)
		elseif ReadyCheckStatus[index] == "offline" then
			return		
		else
			ReadyCheckStatus[index] = "notready"			
		end
	end
end

local function ReadyCheck_OnFinished()
	if #ReadyCheckStatus > 0 then
		for k, v in pairs(ReadyCheckStatus) do
			if v == "waiting" then
				ReadyCheckStatus[k] = "notready"
			end
		end
	end

	ReadyCheckTimer = nil
	ReadyCheckFinished = true
	ReadyCheckFading = 7
end


function SyncUI_ReadyCheckQuery_OnEvent(self,event,...)
	if event == "READY_CHECK" then
		local init = ...
		
		if not UnitIsUnit("player", init) then
			self.Text:SetFormattedText(READY_CHECK_MESSAGE,"|cFF7FFE00"..init.."|r")
			self:Show()
		end
	end
	
	if event == "READY_CHECK_FINISHED" then
		local preempted = ...
		
		if not preempted and self.initiator and not UnitIsUnit("player", self.initiator) then
			local info = ChatTypeInfo["SYSTEM"]
			DEFAULT_CHAT_FRAME:AddMessage(READY_CHECK_YOU_WERE_AFK, info.r, info.g, info.b, info.id)
		end
		
		self:Hide()
	end
end

function SyncUI_ReadyCheckWindow_OnLoad(self)
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
	
	ReadyCheck_OnReset()
	SyncUI_DisableFrame(ReadyCheckFrame)
	SyncUI_RegisterDragFrame(self,READY_CHECK,nil,true)
end

function SyncUI_ReadyCheckWindow_OnEvent(self,event,...)
	if event == "READY_CHECK" then
		self:Show()
		ReadyCheck_OnInit(...)
	end
	if event == "READY_CHECK_CONFIRM" then
		ReadyCheck_OnUpdate(...)
	end
	if event == "READY_CHECK_FINISHED" then
		ReadyCheck_OnFinished()
	end
	
	SyncUI_ReadyCheckQuery_OnEvent(SyncUI_ReadyCheckQuery,event,...)
	SyncUI_ReadyCheckWindow_UpdateScrollFrame()
end

function SyncUI_ReadyCheckWindow_OnUpdate(self,elapsed)
	if ReadyCheckFinished then
		if ReadyCheckFading and ReadyCheckFading > 0 then
			ReadyCheckFading = ReadyCheckFading - elapsed
		else
			ReadyCheck_OnReset()
			self:Hide()
		end
	end
	
	if ReadyCheckTimer and ReadyCheckTimer > 0 then
		ReadyCheckTimer = ReadyCheckTimer - elapsed
		
		self.Timer:SetText(math.ceil(ReadyCheckTimer).."s")
	elseif not ReadyCheckTimer and ReadyCheckFinished then
		self.Timer:SetText("Fin")
	else
		self.Timer:SetText("")
	end
end

function SyncUI_ReadyCheckWindow_UpdateScrollFrame()
	local frame = SyncUI_ReadyCheckWindow
	SyncUI_ScrollFrame_Update(frame.ScrollFrame, #ReadyCheckInfo, MAX_RCW_LINES, 20)
	
	local offset = FauxScrollFrame_GetOffset(frame.ScrollFrame)
	
	for i = 1, MAX_RCW_LINES do
		local line = frame["Line"..i]
		local index = offset + i
		
		if index <= #ReadyCheckInfo then
			local name, status = GetInfo(index)
			local texture, left, right, top, bottom = GetTexture(status)
			
			line.Name:SetText(name)
			line.Icon:SetTexture(texture)
			line.Icon:SetTexCoord(left, right, top, bottom)
			line:Show()
		else
			line:Hide()
		end
	end
end
