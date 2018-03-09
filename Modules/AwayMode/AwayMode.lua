
local awayTime, fadeTime, camSpeed = 0, 0.5, 0.05
local prevAFKState
local framesToFade = {}
local CommandList = {"MOVEFORWARD", "MOVEBACKWARD", "STRAFELEFT", "STRAFERIGHT"}

local function FadeIn(frame)
	if not InCombatLockdown() then frame:Show() end
	frame:SetAlpha(0)
	frame.duration = fadeTime
	frame.fadeMode = "fadeIn"
	tinsert(framesToFade, frame)
end

local function FadeOut(frame)
	frame:SetAlpha(1)
	frame.duration = fadeTime
	frame.fadeMode = "fadeOut"
	tinsert(framesToFade, frame)
end

local function SetAwayMode(status, isFlightMode)
	local frame = SyncUI_AwayStatusFrame
	local isPlaying = frame.SlideIn:IsPlaying() or frame.SlideOut:IsPlaying()
	
	if isPlaying then
		return
	end
	
	-- Start Mode
	if status then
		FadeOut(UIParent)
		frame.SlideIn:Play()
		SyncUI_UIParent.FadeOut:Play()

		SetView(4)
		MoveViewLeftStart(camSpeed)
		awayTime = 0
		
		if isFlightMode then
			CameraZoomOut(15)
			frame.FX:Hide()
		else
			frame.FX:Show()
		end
	end
	
	-- Finish Mode
	if not status and frame:IsVisible() then
		FadeIn(UIParent)
		SyncUI_UIParent.FadeIn:Play()
		frame.SlideOut:Play()
		
		MoveViewLeftStop()
		
		SendChatMessage("" ,"AFK", nil, UnitName("player"))
	end
	
	SetCVar("AutoClearAFK", 1)
end


function SyncUI_AwayMode_OnLoad(self)
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:RegisterEvent("LFG_PROPOSAL_SHOW")
	self:RegisterEvent("TAXIMAP_OPENED")
	self:RegisterEvent("TAXIMAP_CLOSED")

	SetCVar("AutoClearAFK", 1)
end

function SyncUI_AwayMode_OnEvent(self,event,...)
	local profile = SyncUI_GetProfile()
	if InCombatLockdown() or profile.Options.Misc.DisableAFK then
		return
	end

	-- Auto-Cancel
	if event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" then
		SetAwayMode()
	end
	if event == "UPDATE_BATTLEFIELD_STATUS" then
		local status = GetBattlefieldStatus(...)
		if status == "confirm" then
			SetAwayMode()
		end
	end
	
	-- AFK-Mode
	if event == "PLAYER_FLAGS_CHANGED" then
		local isAFK = UnitIsAFK("player")
		if not prevAFKState and isAFK then
			prevAFKState = true
			SetAwayMode(true)
		elseif prevAFKState and not isAFK then
			prevAFKState = false
			SetAwayMode()
		end
	end

	-- Flight-Mode
	if event == "TAXIMAP_OPENED" then
		self:RegisterEvent("PLAYER_CONTROL_LOST")
	end
	if event == "TAXIMAP_CLOSED" then
		C_Timer.After(1, function()
			self:UnregisterEvent("PLAYER_CONTROL_LOST")
		end)		
	end
	if event == "PLAYER_CONTROL_LOST" then
		self:RegisterEvent("PLAYER_CONTROL_GAINED")
		isFlightMode = true
		SetAwayMode(true,true)
	end
	if event == "PLAYER_CONTROL_GAINED" then
		self:UnregisterEvent("PLAYER_CONTROL_GAINED")
		isFlightMode = false
		SetAwayMode()
	end
end

function SyncUI_AwayMode_OnUpdate(self,elapsed)
	local index = 1
	
	while framesToFade[index] do
		local frame = framesToFade[index]
		local mode = frame.fadeMode
		local duration = frame.duration
		local alpha = frame:GetAlpha()
		
		if mode == "fadeIn" then
			if alpha < 1 then
				alpha = alpha + (elapsed / duration)
				frame:SetAlpha(alpha)
			else
				tremove(framesToFade, index)
			end
		elseif mode == "fadeOut" then
			if alpha > 0 then
				alpha = alpha - (elapsed / duration)
				frame:SetAlpha(alpha)
			else
				if not InCombatLockdown() then frame:Hide() end
				tremove(framesToFade, index)
			end
		end
		
		index = index + 1
	end
end

function SyncUI_AwayStatusFrame_OnUpdate(self,elapsed)
	awayTime = awayTime + elapsed
	
	local minutes = math.floor(awayTime / 60)
	local seconds = math.floor(awayTime) - (minutes * 60)
	
	if minutes < 10 then
		if seconds >= 10 then
			self.Time:SetText("0"..minutes..":"..seconds)
		else
			self.Time:SetText("0"..minutes..":0"..seconds)
		end
	else
		if seconds >= 10 then
			self.Time:SetText(minutes..":"..seconds)
		else
			self.Time:SetText(minutes..":0"..seconds)
		end
	end
end

function SyncUI_AwayStatusFrame_OnKeyDown(self,key)
	for i, command in pairs(CommandList) do
		local a, b = GetBindingKey(command)
		
		if key == a or key == b then
			return SetAwayMode()
		end
	end
	
	if key == "ESCAPE" or key == "SPACE" then
		return SetAwayMode()
	end
end
