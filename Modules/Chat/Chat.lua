
local _G = _G
local chatTexPack = {
	"TabLeft","TabMiddle","TabRight",
	"TabSelectedLeft","TabSelectedMiddle","TabSelectedRight",
	"TabHighlightLeft","TabHighlightMiddle","TabHighlightRight",
	"EditBoxLeft","EditBoxMid","EditBoxRight",
	"EditBoxFocusLeft","EditBoxFocusMid","EditBoxFocusRight",
	"TopLeftTexture","BottomLeftTexture","TopRightTexture","BottomRightTexture",
	"LeftTexture","RightTexture","BottomTexture","TopTexture",
}
local bgTexPack = {
	"TopLeft", "TopCenter", "TopRight",
	"CenterLeft", "Center", "CenterRight",
	"BottomLeft", "BottomCenter", "BottomRight",
}

table.insert(CHAT_FONT_HEIGHTS, 1, 10)
table.remove(CHAT_FONT_HEIGHTS, 5)

local function OpenChat()
	if not SyncUI_ChatFrame:IsShown() then
		SyncUI_ChatToggle:Click()
		
		ChatFrame1EditBox:Show()
		ChatFrame1EditBox:SetFocus(true)
	end
end

local function CleanUp(window)
	for _, texture in pairs(chatTexPack) do
		_G[window:GetName()..texture]:SetTexture(nil)
	end
end

local function SetupChatWindow(window)
	if not window.setup then
		local index = window:GetID()
		
		window.setup = true
		window.tab = _G[window:GetName().."Tab"]
		window.btnFrame = _G[window:GetName().."ButtonFrame"]
		window.Background = _G[window:GetName().."Background"]

		window:SetParent(SyncUI_ChatFrame)
		window:SetFrameLevel(2)
		window:SetHitRectInsets(-10,-10,-8,-8)
		window:SetClampedToScreen(false)
		window:SetClampRectInsets(-9,9,25,-66)
		window:SetClampedToScreen(true)
		window.tab:SetParent(SyncUI_ChatFrame)
		window.tab:SetNormalFontObject(SyncUI_GameFontShadow_Medium)
		window.tab:GetFontString():SetTextColor(1,1,1)
		window.btnFrame:Hide()
		window.Background:Hide()
		window.resizeButton:ClearAllPoints()
		window.resizeButton:SetPoint("BOTTOMRIGHT",31,-10)
		window.resizeButton:SetNormalTexture(SYNCUI_MEDIA_PATH.."Backdrops\\FrameBackdrop-Resize")
		window.resizeButton:SetPushedTexture(SYNCUI_MEDIA_PATH.."Backdrops\\FrameBackdrop-Resize")
		window.resizeButton:SetHighlightTexture(SYNCUI_MEDIA_PATH.."Backdrops\\FrameBackdrop-Resize")
		
		-- Fix undocked frames after login/reload
		if not window.isDocked then
			window:SetParent(SyncUI_UIParent)
			window.tab:SetParent(SyncUI_UIParent)
			
			if index == 2 then
				window.tab:ClearAllPoints()
				window.tab:SetPoint("BOTTOMLEFT", window:GetName().."Background", "TOPLEFT", 40,-1)
			end
		end
		
		-- Create Backdrop
		if not window.backdrop then
			window.backdrop = CreateFrame("Frame", nil, window, "SyncUI_BorderGlowFrameTemplate")
			window.backdrop:SetFrameLevel(window:GetFrameLevel()-1)
			if index == 2 then
				window.backdrop:SetPoint("TOPLEFT", 0, 14)
			else
				window.backdrop:SetPoint("TOPLEFT",0,3)
			end
			
			window.backdrop:SetPoint("BOTTOMRIGHT",25,-3)
			
			for _, name in pairs(bgTexPack) do
				local bgFile = window.backdrop[name]
				local alpha = window.oldAlpha or 1
				
				if alpha < 0.25 then
					alpha = 0.25
				end
				
				if bgFile then
					bgFile:SetAlpha(alpha)
				end
			end
		end
		
		-- Create Scroll Button
		if not window.menubar then
			window.menubar = CreateFrame("Button", nil, window, "SyncUI_ChatFrameBarTemplate")
			window.menubar:SetPoint("TOPRIGHT", window.backdrop, 8, 5)
		end
		
		-- Setup EditBox
		if index == 1 then
			window.editBox.header:SetFontObject(SyncUI_GameFontShadow_Medium)
			window.editBox.headerSuffix:SetFontObject(SyncUI_GameFontShadow_Medium)
			window.editBox:SetFontObject(SyncUI_GameFontShadow_Medium)
			window.editBox:SetParent(SyncUI_UIParent)
			window.editBox:ClearAllPoints()
			window.editBox:SetPoint("TOPLEFT", window, "BOTTOMLEFT", -14, -5)
			window.editBox:SetPoint("RIGHT", window, -45, 0)
			window.editBox.backdrop = CreateFrame("Frame", nil, window.editBox, "SyncUI_LayerWithNoEdgeTemplate")
			window.editBox.backdrop:SetFrameLevel(window.editBox:GetFrameLevel() - 1)
			window.editBox.backdrop:SetPoint("TOPLEFT", 0, 3)
			window.editBox.backdrop:SetPoint("BOTTOMRIGHT", 0, -3)
			window.editBox:SetAltArrowKeyMode(false)
		end

		-- Setup CombatLog
		if index == 2 then
			local frame = CombatLogQuickButtonFrame_Custom
			local texture = CombatLogQuickButtonFrame_CustomTexture
			local progress = CombatLogQuickButtonFrame_CustomProgressBar
			
			frame:SetToplevel(true)
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", window.backdrop, 10, 0)
			frame:SetPoint("TOPRIGHT", window.backdrop, -28, -15)
			
			CombatLogQuickButtonFrame:SetFrameStrata("MEDIUM")
			CombatLogQuickButtonFrame:SetFrameLevel(3)
			
			progress:ClearAllPoints()
			progress:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
			progress:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -4)
			texture:SetAlpha(0)
			
			window:SetHitRectInsets(-10,-10,-33,-8)
		end

		CleanUp(window)
		
		hooksecurefunc(window.btnFrame, "Show", function(self)
			self:Hide()
		end)
	end
end

local function UpdateChatWindows()
	for i = 1, NUM_CHAT_WINDOWS do
		local window = _G["ChatFrame"..i]
		
		SetupChatWindow(window)
	end
end

local function UpdateTempChatWindows()
	for _, name in pairs(CHAT_FRAMES) do
		local window = _G[name]
		
		if window.isTemporary then
			SetupChatWindow(window)
		end
	end
end


function SyncUI_ChatFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	hooksecurefunc("ChatFrame_OpenChat", OpenChat)	
	hooksecurefunc("FCF_OpenTemporaryWindow", UpdateTempChatWindows)
	hooksecurefunc("FCF_DockFrame", function(window, index, selected)
		window:SetParent(SyncUI_ChatFrame)
		_G[window:GetName().."Tab"]:SetParent(SyncUI_ChatFrame)
	end)
	hooksecurefunc("FCF_UnDockFrame", function(window)
		window:SetParent(SyncUI_UIParent)
		_G[window:GetName().."Tab"]:SetParent(SyncUI_UIParent)
		
		if window:GetID() == 2 and window.backdrop then
			window.backdrop:ClearAllPoints()
			window.backdrop:SetPoint("TOPLEFT",0,27)
			window.backdrop:SetPoint("BOTTOMRIGHT",0,-3)
		else
			return
		end
	end)
	hooksecurefunc("FCF_SetWindowAlpha", function(window, alpha, doNotSave)
		if not window.backdrop then
			return
		end
		
		for _, name in pairs(bgTexPack) do
			local bgFile = window.backdrop[name]
			
			if alpha < 0.25 then
				alpha = 0.25
			end
			
			if bgFile then
				bgFile:SetAlpha(alpha)
			end
		end		
	end)
	hooksecurefunc("FCF_SetTabPosition", function(window)
		local name = window:GetName()
		local tab = _G[name.."Tab"]
		local index = window:GetID()

		tab:ClearAllPoints()
		
		if index == 2 then
			tab:SetPoint("BOTTOMLEFT", name.."Background", "TOPLEFT", 40,-1)
		else
			tab:SetPoint("BOTTOMLEFT", name.."Background", "TOPLEFT", 40,0)
		end
	end)
	hooksecurefunc("FCFTab_UpdateColors", function(self, selected)
		if selected then
			self:GetFontString():SetTextColor(0.4,1,0)
		else
			self:GetFontString():SetTextColor(1,1,1)
		end
	end)
	hooksecurefunc("FCFDock_SelectWindow", function(dock, window)
		if window:GetID() == 2 and window.backdrop then
			window.backdrop:ClearAllPoints()
			window.backdrop:SetPoint("TOPLEFT",0,27)
			window.backdrop:SetPoint("BOTTOMRIGHT",0,-3)
		end
	end)

	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetClampRectInsets(5,15,15,-15)
	GeneralDockManager:SetParent(SyncUI_ChatFrame)
	GeneralDockManager:SetPoint("BOTTOMLEFT",ChatFrame1,"TOPLEFT",38,6)
	
	SyncUI_DisableFrame(QuickJoinToastButton)
	SyncUI_DisableFrame(ChatFrameMenuButton)
end

function SyncUI_ChatFrame_OnEvent(self,event,...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		UpdateChatWindows()
		
		if not ChatFrame2.isDocked then
			FCF_UnDockFrame(ChatFrame2)
		end
	end
end
