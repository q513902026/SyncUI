local MAX_TOKENS = 10

local function UpdateExpBar(self, useBonusExp)
	if IsXPUserDisabled() or UnitLevel("player") >= MAX_PLAYER_LEVEL then
		self:Hide();
		return;		
	end

	local xp, maxXP = UnitXP("player"), UnitXPMax("player")
	local value = xp

	if useBonusExp then
		value = xp + (GetXPExhaustion() or 0)
	end
	
	for i = 1, MAX_TOKENS do
		local token = self["Token"..i]
		local perToken = maxXP / MAX_TOKENS;
		local minValue = (i - 1) * perToken;
		local maxValue = i * perToken;
		
		if not useBonusExp then
			token.BgFrame:Hide()
		end

		token:SetMinMaxValues(minValue, maxValue)
		token:SetValue(value)
	end

	self:Show()
end

local function UpdateRepBar(self)
	if GetWatchedFactionInfo() then
		local _, _, minRep, maxRep, curRep = GetWatchedFactionInfo()
		local tokenDistanceValue = (maxRep - minRep) / MAX_TOKENS
		
		for i = 1, MAX_TOKENS do
			local token = self["Token"..i]
			local minValue = minRep+((i*tokenDistanceValue)-tokenDistanceValue)
			local maxValue = minRep+((i*tokenDistanceValue))
			local perc = (curRep-minRep)*100/(maxRep-minRep)
			
			token:SetMinMaxValues(minValue,maxValue)
			token:SetValue(curRep)

			if maxRep <= -3000 then
				token:SetStatusBarColor(0.8,0.3,0.2)
			elseif maxRep <= 0 then
				token:SetStatusBarColor(0.8,0.3,0.2)
			elseif maxRep <= 3000 then
				token:SetStatusBarColor(0.9,0.7,0)
			else
				token:SetStatusBarColor(0,0.6,0.1)
			end
		end
		
		self:SetAlpha(1)
	elseif GetMouseFocus() ~= self then
		self:SetAlpha(0)
	end
end

local function UpdateHonorBar(self)
	local honor, max = UnitHonor("player"), UnitHonorMax("player")
	local value = honor*100/max
	
	for i = 1, MAX_TOKENS do
		local token = self["Token"..i]
			
		token:SetValue(value)
	end
end


function SyncUI_InfoBar_OnLoad(self)
	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		--self.HonorBar:Show()
		self.ExpBar:Hide()
		self.BonusExpBar:Hide()
	else
		self:RegisterEvent("PLAYER_LEVEL_UP")
	end
	
	self.update = 0
	self.interval = 1
end

function SyncUI_InfoBar_OnEvent(self, event, ...)
	if event == "PLAYER_LEVEL_UP" then
		if UnitLevel("player") == MAX_PLAYER_LEVEL then
			self.HonorBar:Show()
			self.ExpBar:Hide()
			self.BonusExpBar:Hide()
		end
	end
end

function SyncUI_InfoBar_OnUpdate(self, elapsed)
	self.update = self.update + elapsed
	
	while self.update > self.interval do
		UpdateExpBar(self.ExpBar)
		UpdateExpBar(self.BonusExpBar, true)
		UpdateRepBar(self.RepBar)
		UpdateHonorBar(self.HonorBar)
		
		self.update = self.update - self.interval
	end
end

function SyncUI_ExpBar_OnEnter(self)
	local xp, maxXP = UnitXP("player"), UnitXPMax("player")
	local _, name, multiply = GetRestState()
	local state = format(EXHAUST_TOOLTIP1, name, multiply * 100)
	local bonusXP = GetXPExhaustion()
	local perc = format("%0.f", xp * 100 / maxXP)
	
	GameTooltip:SetOwner(self, "ANCHOR_TOP",0,5)
	GameTooltip:AddDoubleLine(SYNCUI_STRING_EXP, xp.." / "..maxXP.." ("..perc.."%)",1,1,1,1,1,1)
	
	if bonusXP then
		GameTooltip:AddDoubleLine(SCENARIO_BONUS_LABEL, bonusXP,1,1,1,1,1,1)
	end

	GameTooltip:AddDivider()
	GameTooltip:AddLine(state)
	GameTooltip:Show()
end

function SyncUI_RepBar_OnEnter(self)
	local faction, level, minRep, maxRep, value = GetWatchedFactionInfo()

	 if faction then
		local repLvL = GetText("FACTION_STANDING_LABEL"..level)
		local curRep, realMaxRep = value - minRep, maxRep - minRep
		local perc =  format("%0.f", curRep * 100 / realMaxRep)
		local color = FACTION_BAR_COLORS[level]
		local r,g,b = color.r, color.g, color.b or 1,1,1
		
		GameTooltip:SetOwner(self, "ANCHOR_TOP",0,5)
		GameTooltip:AddLine(faction,1,1,1)
		GameTooltip:SetPrevLineJustify("CENTER")
		GameTooltip:AddDivider()
		GameTooltip:AddDoubleLine(repLvL, curRep.." / "..realMaxRep.." ("..perc.."%)",r,g,b,1,1,1)
		GameTooltip:Show()
	else
		for i = 1, MAX_TOKENS do
			local token = self["Token"..i]
			
			token:SetMinMaxValues(0, 100)
			token:SetValue(0)
		end
		
		self:SetAlpha(0.75)
	end
end

function SyncUI_HonorBar_OnEnter(self)
	local honor, max = UnitHonor("player"), UnitHonorMax("player")
	local lvl = UnitHonorLevel("player");
	local perc = format("%0.f", honor * 100 / max)
	
	GameTooltip:SetOwner(self, "ANCHOR_TOP",0,5)
	GameTooltip:AddLine(format(HONOR_LEVEL_LABEL, lvl), 1,1,1)
	GameTooltip:SetPrevLineJustify("CENTER")
	GameTooltip:AddDivider()
	GameTooltip:AddDoubleLine(HONOR_POINTS,honor.." / "..max.." ("..perc.."%)", 1,1,1, 1,1,1)
	GameTooltip:Show()
end

function SyncUI_HonorBar_OnClick(self)

end


-- Clock
function SyncUI_ClockFrame_OnClick(self,button)
	if button == "LeftButton" then
		
		if IsShiftKeyDown() then
			TimeManager_ToggleLocalTime()
			SyncUI_ClockFrame_OnEnter(self)
		else
			TimeManager_ToggleTimeFormat()
		end
	end
	if button == "RightButton" then
		Stopwatch_Toggle()
	end
end

function SyncUI_ClockFrame_OnEnter(self)
	local string;
	
	if GetCVarBool("timeMgrUseLocalTime") then
		string = TIMEMANAGER_TOOLTIP_LOCALTIME:gsub(":","")
	else
		string = TIMEMANAGER_TOOLTIP_REALMTIME:gsub(":","")
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
	GameTooltip:AddLine(SYNCUI_STRING_CLOCK_TOGGLE_HOUR_MODE,1,1,1)
	GameTooltip:AddLine(SYNCUI_STRING_CLOCK_TOGGLE_STOPWATCH,1,1,1)
	GameTooltip:AddLine(SYNCUI_STRING_CLOCK_TOGGLE_DISPLAY,1,1,1)
	GameTooltip:AddDivider()
	GameTooltip:AddDoubleLine("|cFF64FF00"..DISPLAY..":|r",string,1,1,1,1,1,1)								
	GameTooltip:Show()
end


-- Micro Menu
local MicroIcons = {
	[ 1] = "Interface\\Glues\\CharacterCreate\\Ui-CharacterCreate-Races",	-- CHARACTER
	[ 2] = "Interface\\Icons\\inv_misc_book_09",							-- SPELLBOOK
	[ 3] = "Interface\\Icons\\ability_marksmanship",						-- TALENTS
	[ 4] = "Interface\\Icons\\achievement_guildperk_honorablemention",		-- ACHIEVEMENTS
	[ 5] = "Interface\\Icons\\ability_priest_angelicfeather",				-- QUESTS
	[ 6] = "Interface\\Icons\\levelupicon-lfd",								-- GROUP FINDER
	[ 7] = "Interface\\Icons\\warrior_skullbanner",							-- ADVENTURE GUIDE
	[ 8] = "Interface\\Icons\\ability_mount_ridinghorse",					-- COLLECTION
	[ 9] = "Interface\\Icons\\inv_misc_note_05",							-- CHANGELOG
}

local MicroFrameRef = {
	[2] = SpellbookMicroButton,
	[3] = TalentMicroButton,
	[4] = AchievementMicroButton,
	[5] = QuestLogMicroButton,
	[6] = LFDMicroButton,
	[7] = EJMicroButton,
	[8] = CollectionsMicroButton,
}

function SyncUI_MicroMenu_OnLoad(self)
	local hover = SyncUI_MicroMenuHover
	hover:SetFrameRef("menu", self)
	hover:SetAttribute("_onenter", [[
		local menu = self:GetFrameRef("menu")
		
		menu:Show()
		menu:RegisterAutoHide(1)
		menu:AddToAutoHide(self)
	]])

	self:SetAttribute("_onenter", [[
		self:RegisterAutoHide(1)
	]])
	self:SetAttribute("_onattributechanged", [[
		if name == "statehidden" and value then
			self:Show()
		end
	]])

	for _, name in pairs(MICRO_BUTTONS) do 	
		_G[name]:UnregisterAllEvents();
	end
end

function SyncUI_MicroMenuButton_OnLoad(self)
	local index = self:GetID()

	self:SetNormalTexture(MicroIcons[index])
	
	-- Set Attributes
	if index == 1 then
		local race = string.upper(select(2, UnitRace("player")));
		local sex = (UnitSex("player") == 3) and "FEMALE" or "MALE"
		local isHorde = UnitFactionGroup("player") == "Horde" and race ~= "Pandaren"
		local left, right, top, bottom = unpack(SYNCUI_RACE_ICON_TCOORDS[race.."_"..sex])
		local adj = 0.01

		if isHorde then
			self:GetNormalTexture():SetTexCoord(right-adj, left+adj, top+adj, bottom-adj)
		else
			self:GetNormalTexture():SetTexCoord(left+adj, right-adj, top+adj, bottom-adj)
		end
		
		self:SetAttribute("type", "macro")
		self:SetAttribute("macrotext", "/run ToggleCharacter('PaperDollFrame')")
	-- elseif index == 3 then
		-- self:SetAttribute("type", "macro")
		-- self:SetAttribute("macrotext", "/run SyncUI_ToggleTalentUI()")
	else
		self:SetAttribute("type", "click")
		self:SetAttribute("clickbutton", MicroFrameRef[index])
	end
end