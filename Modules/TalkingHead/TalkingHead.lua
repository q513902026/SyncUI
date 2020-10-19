
local TEXT_PACING = 25

local function Reset(self)
	self.Name:SetText("")
	self.Text:SetText("")
	self.start = nil
	self.voHandle = nil
end

local function PlayCurrent(self)
	if self.voHandle then
		StopSound(self.voHandle)
		self.voHandle = nil
	end
 
	local currentDisplayInfo = self.Model:GetDisplayInfo()
	local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead = C_TalkingHead.GetCurrentLineInfo()
	local textFormatted = string.format(text)
	
	if displayInfo and displayInfo ~= 0 then
		self.FadeOut:Stop()
		self.FadeIn:Stop()
		
		if not self:IsShown() then
			self.FadeIn:Play()
		end
		
		self:Show()
		
		if currentDisplayInfo ~= displayInfo then
			self.Model.uiCameraID = cameraID
			self.Model:SetDisplayInfo(displayInfo)
		else
			if self.Model.uiCameraID ~= cameraID then
				self.Model.uiCameraID = cameraID
				Model_ApplyUICamera(self.Model, self.Model.uiCameraID)
			end
		end
		
		if name ~= self.Name:GetText() then
			self.Name:SetText(name)
		end

		if textFormatted ~= self.Text:GetText() then
			C_Timer.After(1, function()
				self.start = 0
				self.Text:SetText(textFormatted)
			end)
		end

		local success, voHandle = PlaySound(vo, "Talking Head", true, true);
		
		if success then
			self.voHandle = voHandle;
		end
	end
end

local function Close(self)
	self.shouldLoop = false
	self.FadeOut:Play()
	
	if self.voHandle then
		StopSound(self.voHandle, 2000)
	end
	
	Reset(self)
end

local function CloseImmediately(self)
	C_TalkingHead.IgnoreCurrentTalkingHead()
	self:Hide()
	
	if self.voHandle then
		StopSound(self.voHandle)
	end
	
	Reset(self)
end


function SyncUI_TalkingHead_OnLoad(self)
	LoadAddOn("Blizzard_TalkingHeadUI")
	SyncUI_DisableFrame(TalkingHeadFrame)
	
	self:RegisterForClicks("RightButton")
	self:RegisterEvent("TALKINGHEAD_REQUESTED")
	self:RegisterEvent("TALKINGHEAD_CLOSE")
	self:RegisterEvent("SOUNDKIT_FINISHED")
	self:RegisterEvent("LOADING_SCREEN_ENABLED")
	
	self.Model:SetScript("OnModelLoaded", TalkingHeadFrame_OnModelLoaded);
	
	SyncUI_RegisterDragFrame(self, "Cinema dialogue")
end

function SyncUI_TalkingHead_OnEvent(self,event,...)
	if event == "TALKINGHEAD_REQUESTED" then
		PlayCurrent(self)
	end
	
	if event == "TALKINGHEAD_CLOSE" then
		Close(self)
	end
	
	if event == "SOUNDKIT_FINISHED" then
		local voHandle = ...;
		if self.voHandle == voHandle then
			self.Model.shouldLoop = false
			self.voHandle = nil
		end
	end
	
	if event == "LOADING_SCREEN_ENABLED" then
		CloseImmediately(self)
	end
end

function SyncUI_TalkingHead_OnClick(self, button)
	if button == "RightButton" then
		CloseImmediately(self)
		return true
	end
	
	return false
end

function SyncUI_TalkingHead_OnUpdate(self, elapsed)
	if self.start then
		local text = self.Text:GetText()
		local length = text:len()
		
		if not self.start then
			self.start = length
		end
		
		self.start = self.start + (elapsed * TEXT_PACING)
		
		if self.start >= length then
			self.start = nil
			self.Text:SetAlphaGradient(length, 1)
		else
			self.Text:SetAlphaGradient(self.start, 10)
		end
	end
end

function SyncUI_TalkingHead_Close(self)
	CloseImmediately(self:GetParent())
end


function SyncUI_TalkingHead_OnModelLoaded(self)
	self:RefreshCamera();
	
	if self.uiCameraID then
		Model_ApplyUICamera(self, self.uiCameraID);
	end
	
	TalkingHeadFrame_SetupAnimations(self);
end