
BINDING_HEADER_QUESTHUB = OBJECTIVES_TRACKER_LABEL

SYNCUI_MEDIA_PATH = [[Interface\AddOns\SyncUI\Media\Textures\]]
SYNCUI_UISCALES = {ADDON_DISABLED,"0.5","0.6","0.7","0.8","0.9","1.0"}
SYNCUI_CLASS_STRINGS = {}
SYNCUI_CLASS_COLORS = {
	["DEATHKNIGHT"] = {0.9, 0.0, 0.2},
	["DEMONHUNTER"] = {0.6, 0.0, 1.0},
	["DRUID"] 		= {1.0, 0.3, 0.0},
    ["HUNTER"] 		= {0.5, 0.7, 0.2},
	["MAGE"] 		= {0.0, 0.8, 1.0},
	["MONK"] 		= {0.0, 1.0, 0.6},
    ["PALADIN"] 	= {1.0, 0.2, 0.8},
    ["PRIEST"] 		= {1.0, 1.0, 1.0},
    ["ROGUE"]		= {1.0, 1.0, 0.0},
    ["SHAMAN"] 		= {0.0, 0.4, 1.0},
	["WARLOCK"] 	= {0.5, 0.3, 1.0},
    ["WARRIOR"] 	= {0.8, 0.6, 0.4},
}
SYNCUI_POWER_COLORS = {
	["MANA"] 		= {0.0, 0.4, 8.0},
	["RAGE"] 		= {1.0, 0.2, 0.2},
	["FOCUS"] 		= {0.8, 0.4, 0.0},
	["ENERGY"] 		= {0.8, 0.8, 0.0},
	["RUNIC_POWER"] = {0.0, 0.8, 1.0},
	["MAELSTROM"]	= {0.3, 0.7, 1.0},
	["LUNAR_POWER"] = {0.3, 0.5, 1.0},
	["INSANITY"] 	= {0.7, 0.0, 1.0},
	["FURY"] 		= {0.8, 0.3, 0.9},
	["PAIN"] 		= {1.0, 0.6, 0.0},
	
}
SYNCUI_RACE_ICON_TCOORDS = {
	-- ALLIANCE
	["HUMAN_MALE"]		= {0, 0.125, 0, 0.25},
	["HUMAN_FEMALE"]	= {0, 0.125, 0.5, 0.75},	
	["DWARF_MALE"]		= {0.125, 0.25, 0, 0.25},
	["DWARF_FEMALE"]	= {0.125, 0.25, 0.5, 0.75},
	["GNOME_MALE"]		= {0.25, 0.375, 0, 0.25},
	["GNOME_FEMALE"]	= {0.25, 0.375, 0.5, 0.75},
	["NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.25},
	["NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},
	["DRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
	["DRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75},
	["WORGEN_MALE"]		= {0.629, 0.750, 0, 0.25},
	["WORGEN_FEMALE"]	= {0.629, 0.750, 0.5, 0.75},
	
	-- HORDE 
	["TAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
	["TAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},
	["SCOURGE_MALE"]	= {0.125, 0.25, 0.25, 0.5},
	["SCOURGE_FEMALE"]	= {0.125, 0.25, 0.75, 1.0},
	["TROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
	["TROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0},
	["ORC_MALE"]		= {0.375, 0.5, 0.25, 0.5},
	["ORC_FEMALE"]		= {0.375, 0.5, 0.75, 1.0},
	["BLOODELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
	["BLOODELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0},
	["GOBLIN_MALE"]		= {0.629, 0.750, 0.25, 0.5},
	["GOBLIN_FEMALE"]	= {0.629, 0.750, 0.75, 1.0},

	-- NEUTRAL
	["PANDAREN_MALE"]	= {0.756, 0.881, 0, 0.25},
	["PANDAREN_FEMALE"]	= {0.756, 0.881, 0.5, 0.75},

	-- ALLIED RACES
	["NIGHTBORNE_MALE"]	= {0.375, 0.5, 0, 0.25},
	["NIGHTBORNE_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},
	["HIGHMOUNTAINTAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
	["HIGHMOUNTAINTAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},
	["VOIDELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
	["VOIDELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0},
	["LIGHTFORGEDDRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
	["LIGHTFORGEDDRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75},
	["ZANDALARITROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
	["ZANDALARITROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0},
}
SYNCUI_FONTLIST = {
	{"Nexa.otf",8,10,12,14,16},
	{"Haas.ttf",8,10,12,14,16},
	{"Prototype.ttf",8,10,12,14,16},
	{"Vibro.ttf",7,8,10,12,14},
	{"Zero.ttf",7,8,10,12,14},
	{"Chivo.otf",8,10,12,14,16},
	{"Days.otf",7,8,10,12,14},
	-- Cyrillic
	{"Exo.otf",8,10,12,14,16,"Cyrillic"},
	{"Roboto.ttf",8,10,12,14,16,"Cyrillic"},
	{"Gothic.ttf",8,10,12,14,16,"Cyrillic"},
}

local bindingTabAction;

local function SetupFrameStack()
	local timeCheck = 0
	local altKeyDown = false
	
	LoadAddOn("Blizzard_DebugTools")

	FrameStackTooltip:SetScript("OnUpdate", function(self, elapsed)
		local index = 0
		
		timeCheck = timeCheck - elapsed
		
		if altKeyDown ~= IsAltKeyDown() then
			altKeyDown = not altKeyDown
			if altKeyDown then
				if IsRightAltKeyDown() then
					index = -1
				else
					index = 1
				end
			end
		end

		if timeCheck <= 0 or index ~= 0 then
			local highlightFrame = self:SetFrameStack(self.showHidden, self.showRegions, index)

			if not highlightFrame or highlightFrame == SyncUI_UIParent then
				FrameStackHighlight:Hide()
			else
				FrameStackHighlight:ClearAllPoints()
				FrameStackHighlight:SetPoint("BOTTOMLEFT", highlightFrame)
				FrameStackHighlight:SetPoint("TOPRIGHT", highlightFrame)
				FrameStackHighlight:Show()
			end
			
			timeCheck = FRAMESTACK_UPDATE_TIME
		end
	end)
end

local function SetupCinematicSkip()
	MovieFrame:SetScript("OnEvent", function(self, event, ...)
		local profile = SyncUI_GetProfile()
		
		if profile.Options.Misc.SkipCinematics then
			GameMovieFinished()
		elseif event == "PLAY_MOVIE" then
			local movieID = ...
			if movieID then
				MovieFrame_PlayMovie(self, movieID)
			end
		end
	end)
	hooksecurefunc(CinematicFrame,"Show", function()
		local profile = SyncUI_GetProfile()
		
		if profile.Options.Misc.SkipCinematics then
			CinematicFrame.closeDialog:Hide()
			CinematicFrame_CancelCinematic()
		end
	end)
end

local function SetupSwitchTab()
	local SwitchTab = CreateFrame("Frame");

	SwitchTab:RegisterEvent("PLAYER_ENTERING_WORLD");
	SwitchTab:SetScript("OnEvent", function(self, event, ...)
		local action, tag;
		
		if event == "PLAYER_ENTERING_WORLD" then
			local instanceType = select(2, GetInstanceInfo());
			
			if instanceType == "arena" or instanceType == "pvp" then
				action = "TARGETNEARESTENEMYPLAYER";
				tag = "PvP";
			else
				action = "TARGETNEARESTENEMY";
				tag = "PvE";
			end
		end
		
		if bindingTabAction == action then
			return
		end
		
		print("<TAB> has been changed to "..tag)
		bindingTabAction = action;
		SetBinding("TAB", action);		
	end)
end


function SyncUI_UIParent_OnLoad(self)
	SetupFrameStack()
	SetupCinematicSkip()
	SetupSwitchTab()
	
	UIParent:HookScript("OnShow", function() self:SetAlpha(1) end)
	UIParent:HookScript("OnHide", function() self:SetAlpha(0) end)

	for token, localized in next, FillLocalizedClassList({}) do
		SYNCUI_CLASS_STRINGS[localized] = token
	end
	for token, localized in next, FillLocalizedClassList({},true) do
		SYNCUI_CLASS_STRINGS[localized] = token
	end
end

function SyncUI_DisableFrame(frame, ignore)
	if type(frame) == "string" then
		frame = _G[frame]
	end
	
	if frame then
		frame:SetParent(SyncUI_DisableDriver)
		
		if not ignore then
			frame:UnregisterAllEvents()
		end
	end
end

function SyncUI_Cooldown_OnRegister(self)
	local numRegions = self:GetNumRegions()

	for i = 1, numRegions do
		local region = select(i, self:GetRegions())
		local height = self:GetHeight()
		
		if region.GetText then
			if height > 37 then
				region:SetFontObject(SyncUI_GameFontNormal_Huge)
			elseif height > 25 then
				region:SetFontObject(SyncUI_GameFontNormal_Large)
			else
				region:SetFontObject(SyncUI_GameFontNormal_Medium)
			end
			
			region:SetPoint("CENTER",1,0)
		end 
	end

	self:SetBlingTexture("")
end

function SyncUI_GetColorizedText(string,r,g,b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	
	return "|cFF"..string.format("%02x%02x%02x", r*255, g*255, b*255)..string.."|r"
end

function SyncUI_SetFrameScale(frame, scale)
	if not scale then
		local dataBase = {GetScreenResolutions()}
		local resolution = dataBase[GetCurrentResolution()]

		if resolution then
			scale = 768/string.match(resolution, "%d+x(%d+)")
		else
			scale = 768/1080
		end
	end
	
	frame:SetScale(scale)
end

function SyncUI_SetUIFont()
	local profile = SyncUI_GetProfile()
	local index = profile.Options.Appearance.UsedFont
	local name, tiny, small, medium, large, huge, lang = unpack(SYNCUI_FONTLIST[index])
	local path = [[Interface\AddOns\SyncUI\Media\Fonts\]]..name
	
	SyncUI_FontPath = path
	
	do	-- SyncUI Fonts
		SyncUI_GameFontNormal_Tiny:SetFont(path,tiny,"OUTLINE")
		SyncUI_GameFontNormal_Small:SetFont(path,small,"OUTLINE")
		SyncUI_GameFontNormal_Medium:SetFont(path,medium,"OUTLINE")
		SyncUI_GameFontNormal_Large:SetFont(path,large,"OUTLINE")
		SyncUI_GameFontNormal_Huge:SetFont(path,huge,"OUTLINE")

		SyncUI_GameFontNormal_Small:SetShadowColor(0,0,0)
		SyncUI_GameFontNormal_Small:SetShadowOffset(0,0)
		SyncUI_GameFontNormal_Medium:SetShadowColor(0,0,0)
		SyncUI_GameFontNormal_Medium:SetShadowOffset(0,0)
		SyncUI_GameFontNormal_Large:SetShadowColor(0,0,0)
		SyncUI_GameFontNormal_Large:SetShadowOffset(0,0)
		SyncUI_GameFontNormal_Huge:SetShadowColor(0,0,0)
		SyncUI_GameFontNormal_Huge:SetShadowOffset(0,0)
		
		SyncUI_GameFontOutline_Small:SetFont(path,small,"NONE")
		SyncUI_GameFontOutline_Medium:SetFont(path,medium,"NONE")
		SyncUI_GameFontOutline_Large:SetFont(path,large,"NONE")
		SyncUI_GameFontOutline_Huge:SetFont(path,huge,"NONE")
		
		SyncUI_GameFontShadow_Small:SetFont(path,small,"NONE")
		SyncUI_GameFontShadow_Medium:SetFont(path,medium,"NONE")
		SyncUI_GameFontShadow_Large:SetFont(path,large,"NONE")
		SyncUI_GameFontShadow_Huge:SetFont(path,huge,"NONE")
		
		SyncUI_GameFontShadow_Small:SetShadowColor(0,0,0)
		SyncUI_GameFontShadow_Small:SetShadowOffset(1,-1)
		SyncUI_GameFontShadow_Medium:SetShadowColor(0,0,0)
		SyncUI_GameFontShadow_Medium:SetShadowOffset(1,-1)
		SyncUI_GameFontShadow_Large:SetShadowColor(0,0,0)
		SyncUI_GameFontShadow_Large:SetShadowOffset(1,-1)
		SyncUI_GameFontShadow_Huge:SetShadowColor(0,0,0)
		SyncUI_GameFontShadow_Huge:SetShadowOffset(1,-1)
	end
	
	do	-- Blizzard Fonts
		for i = 1, NUM_CHAT_WINDOWS do
			local chatWindow = _G["ChatFrame"..i]
			
			if chatWindow then
				local height = select(2, chatWindow:GetFont())
				
				chatWindow:SetFont(path,height,"NONE")
				chatWindow:SetShadowColor(0,0,0)
				chatWindow:SetShadowOffset(1,-1)
			end
		end
	end

	do	-- Set DropDownText
		if name then
			name = gsub(name,".otf","")
			name = gsub(name,".ttf","")
		end
		
		SyncUI_OptionPanel_Appearance.Fonts.DropDown:SetText(name)
	end
end

function SyncUI_ToggleFrame(self)
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

function SyncUI_ShowColorPicker(r,g,b,callback)
	ColorPickerFrame:SetColorRGB(r,g,b)
	ColorPickerFrame.hasOpacity = nil
	ColorPickerFrame.previousValues = {r,g,b}
	ColorPickerFrame.func, ColorPickerFrame.cancelFunc = callback, callback
	ColorPickerFrame:Hide()
	ColorPickerFrame:Show()
end

----------------
-- Frame Glow --
----------------
local GlowTex = {}

local function GetRainbowColor(r,g,b, elapsed)
	local perStep = elapsed * 0.25
	local step = 1
	
	if r >= 1 and b >= 0 and g < 1 then
		step = 1
	end
	if r >= 0 and g >= 1 and b <= 0 then
		step = 2
	end
	if r <= 0 and g >= 1 and b < 1 then
		step = 3
	end
	if r <= 0 and g >= 0 and b >= 1 then
		step = 4
	end
	if r < 1 and g <= 0 and b >= 1 then
		step = 5
	end
	if r >= 1 and g <= 0 and b >= 0 then
		step = 6
	end

	if step == 1 then	-- Red -> Yellow
		g = g + perStep
	end
	if step == 2 then	-- Yellow -> Green
		r = r - perStep
	end
	if step == 3 then	-- Green -> Türkis
		b = b + perStep
	end
	if step == 4 then	-- Türkis -> Blue
		g = g - perStep
	end
	if step == 5 then	-- Blue -> Violet
		r = r + perStep
	end
	if step == 6 then	-- Violet -> Red
		b = b - perStep
	end

	return r,g,b
end

function SyncUI_FrameGlow_SetMode(mode, useRainbow)
	if (mode ~= "solid") and (mode ~= "pulse") and (mode ~= "none") then
		return
	end
	
	for _, tex in pairs(GlowTex) do
		if mode == "solid" then
			tex:SetAlpha(1)
		end
		if mode == "none" then
			tex:SetAlpha(0)
		end
	end
	
	SyncUI_FrameGlowUpdater.useRainbow = useRainbow
	SyncUI_FrameGlowUpdater.mode = mode
end

function SyncUI_FrameGlow_SetColor(r,g,b)
	if (not r) or (not g) or (not b) then
		local class = select(2, UnitClass("player"))
		
		r,g,b = unpack(SYNCUI_CLASS_COLORS[class])
	end
	
	for _, tex in pairs(GlowTex) do
		tex:SetVertexColor(r,g,b)
	end
end

function SyncUI_FrameGlow_OnRegister(self)
	local regions = {self:GetRegions()}
	
	for _, tex in pairs(regions) do
		tinsert(GlowTex,tex)
	end

	if SyncUI_Data then	-- ChatFrame fixes
		local profile = SyncUI_GetProfile()
		local method = profile.Options.Appearance.ColorMode
			
		if method == "classcolor" then
			SyncUI_FrameGlow_SetColor()
		elseif method == "custom" then
			local r,g,b = unpack(profile.Options.Appearance.Custom)
			SyncUI_FrameGlow_SetColor(r,g,b)
		end
	end
end

function SyncUI_FrameGlow_OnUpdate(self, elapsed)
	if self.mode == "none" then
		return
	end

	if self.mode == "pulse" then
		if not self.flashTimer then
			self.flashTimer = 0
		end
		if not self.flashDuration then
			self.flashDuration = -1
		end
		
		self.flashTimer = self.flashTimer + elapsed

		if self.flashTimer > self.flashDuration and self.flashDuration ~= -1 then
			-- do nothing
		else
			local flashTime = self.flashTimer
			local alpha

			flashTime = flashTime%(self.fadeInTime + self.fadeOutTime)
			
			if flashTime < self.fadeInTime then
				alpha = flashTime/self.fadeInTime
			elseif flashTime < self.fadeInTime then
				alpha = 1
			elseif flashTime < self.fadeInTime + self.fadeOutTime then
				alpha = 1 - ((flashTime - self.fadeInTime) / self.fadeOutTime)
			else
				alpha = 0
			end

			for _, tex in pairs(GlowTex) do
				tex:SetAlpha(alpha)
			end
		end
	end

	if self.useRainbow then
		self.r, self.g, self.b = GetRainbowColor(self.r,self.g,self.b,elapsed)
		
		SyncUI_FrameGlow_SetColor(self.r,self.g,self.b)
	end
end

----------------------------
-- Effective Level Colors --
----------------------------
local EffectiveLevelColors = {
	["Impossible"]	= {1.0,0.0,0.0},
	["Hard"]		= {1.0,0.3,0.0},
	["Normal"]		= {1.0,0.8,0.0},
	["Easy"]		= {0.0,1.0,0.0},
	["Trivial"]		= {0.5,0.5,0.5},
}

function SyncUI_GetEffectiveLevelColor(level)
	local compareLevel = UnitLevel("player")
	local stage = level - compareLevel
	local color
	
	if stage >= 5 then
		color = EffectiveLevelColors["Impossible"]
	elseif stage >= 3 then
		color = EffectiveLevelColors["Hard"]
	elseif stage >= -4 then
		color = EffectiveLevelColors["Normal"]
	elseif -stage <= GetQuestGreenRange() then
		color = EffectiveLevelColors["Easy"]
	else
		color = EffectiveLevelColors["Trivial"]
	end
	
	return unpack(color)
end

-------------------
-- Dev Functions --
-------------------
local function Decrypt(text)
	local counter = 1
	local len = string.len(text)
	
	for i = 1, len, 3 do 
		counter = math.fmod(counter*8161, 4294967279) + (string.byte(text,i)*16776193) + ((string.byte(text,i+1) or (len-i+256))*8372226) +	((string.byte(text,i+2) or (len-i+256))*3932164)
	end
	
	return math.fmod(counter, 4294967291)
end

function SyncUI_IsDev()
	local battleTag = select(2, BNGetInfo())
	
	if Decrypt(battleTag) == 549956557 then
		return true
	end
	
	return false
end
