
--------------------------
-- Auto Quest Functions --
--------------------------
local function QuestSelect(event)
	if IsShiftKeyDown() then
		return
	end
	
	local profile = SyncUI_GetProfile()
	
	-- Turn Quests In
	if profile.Options.Quests.TurnIn then
		if event == "GOSSIP_SHOW" then
			for i = 1, GetNumGossipActiveQuests() do
				local name, level, isTrivial, isComplete, isLegendary = select(i*5-4, GetGossipActiveQuests())

				if isComplete then
					SelectGossipActiveQuest(i)
				end
			end
		end
		if event == "QUEST_GREETING" then
			for i = 1, GetNumActiveQuests() do
				local isComplete = select(2, GetActiveTitle(i))
				
				if isComplete then
					SelectActiveQuest(i)
				end
			end
		end
	end
	
	-- Accept Quests
	if profile.Options.Quests.Accept then
		if event == "GOSSIP_SHOW" then
			local numAvailableQuests = GetNumGossipAvailableQuests()
			local numActiveQuests = GetNumGossipActiveQuests()
			local numOptions = GetNumGossipOptions()
			
			if (numAvailableQuests == 0 and numActiveQuests == 0 and numOptions == 1) or UnitName("target") == "Lucian Trias" then
				local text, type = GetGossipOptions()
				
				if type == "gossip" then
					SelectGossipOption(1,text,true)
				end
			end
			
			for i = 1, numAvailableQuests do
				--local name, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = select(i*7-6, GetGossipAvailableQuests())	--legion
				local name, level, isTrivial, frequency, isRepeatable, isLegendary = select(i*6-5, GetGossipAvailableQuests())
				
				if not isRepeatable and not isTrivial and ( frequency == 1 or (frequency ~= 1 and profile.Options.Quests.Daily) ) then
					SelectGossipAvailableQuest(i)
				end
			end
		end
		if event == "QUEST_GREETING" then
			for i = 1, GetNumAvailableQuests() do
				local name, level, isTrivial, frequency, isRepeatable, isLegendary = select(i*6-5, GetGossipAvailableQuests())

				if not isRepeatable and not isTrivial and ( frequency == 1 or (frequency ~= 1 and profile.Options.Quests.Daily) ) then
					SelectAvailableQuest(i)
				end
			end
		end
	end
end

local function QuestAccept()
	local profile = SyncUI_GetProfile()
	
	if profile.Options.Quests.Accept then
		if not QuestGetAutoAccept() then
			local isRepeatable
			
			if QuestIsDaily() or QuestIsWeekly() then
				isRepeatable = true
			end

			if not isRepeatable or (isRepeatable and profile.Options.Quests.Daily) then
				AcceptQuest()	
			end		
		end
	end
end

local function QuestShare(questID)
	local profile = SyncUI_GetProfile()
	
	if profile.Options.Quests.Share then
		if GetNumGroupMembers() > 0 then
			SelectQuestLogEntry(questID)
			if GetQuestLogPushable() then
				QuestLogPushQuest()
			end
		end
	end
end

local function QuestTurnIn()
	local profile = SyncUI_GetProfile()
	
	if profile.Options.Quests.TurnIn then
		if IsQuestCompletable() then
			CompleteQuest()
		end
	end
end

local function QuestReward()
	local profile = SyncUI_GetProfile()
	
	if profile.Options.Quests.TurnIn then
		if GetNumQuestChoices() <= 1 then
			QuestFrameCompleteQuestButton:Click()
		end
	end
end

------------------------------
-- Modify Objective Tracker --
------------------------------
local AchievementList, QuestList = {}, {}
local AchievementFilter, QuestFilter

local function UntrackQuests()
	QuestList, QuestFilter = {}, true

	for i = 1, GetNumQuestWatches() do
		local questID = GetQuestWatchInfo(i)

		if questID then
			QuestList[questID] = true
		end
	end
	
	for questID in pairs(QuestList) do
		RemoveQuestWatch(GetQuestLogIndexByID(questID))
	end
end

local function RestoreQuests()
	QuestFilter = false
	
	for questID in pairs(QuestList) do
		AddQuestWatch(GetQuestLogIndexByID(questID))
	end
end

local function UntrackAchievements()
	AchievementList, AchievementFilter = {}, true

	for i, achieveID in pairs({GetTrackedAchievements()}) do
		AchievementList[achieveID] = true
	end
	
	for achieveID in pairs(AchievementList) do
		AchievementObjectiveTracker_UntrackAchievement(_, achieveID)
	end	
end

local function RestoreAchievements()
	AchievementFilter = false
	
	for achieveID in pairs(AchievementList) do
		AddTrackedAchievement(achieveID)
	end	
end

local function UpdateHeader()
	local tracker = SyncUI_ObjTracker
	local header = tracker.Header
	local shownModules = 0

	for i, module in pairs(ObjectiveTrackerFrame.MODULES) do
		if module.Header.added then
			shownModules = shownModules + 1
		end
	end
	
	if shownModules > 0 or tracker.minimized then
		header:Hide()
	else
		header:Show()
	end
	
	if shownModules == 0 then
		if AchievementFilter or QuestFilter then
			SyncUI_ObjTracker:Show()
		else
			SyncUI_ObjTracker:Hide()
		end
	else
		SyncUI_ObjTracker:Show()
	end
	
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetText(TRACKER_HEADER_ACHIEVEMENTS.." ("..GetNumTrackedAchievements().."/".. 10 ..")")
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(TRACKER_HEADER_QUESTS.." ("..GetNumQuestWatches().."/"..MAX_WATCHABLE_QUESTS..")")
end

local function UpdateQuickItem(self, i)
	local questLogID = select(3, GetQuestWatchInfo(i)) or 0
	local isComplete = select(6, GetQuestWatchInfo(i)) and 1 or false
	local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogID)
					
	if item and (not isQuestComplete or showItemWhenComplete) and not self.minimized then
		self.QuickItem:SetID(questLogID)
		self.QuickItem.charges = charges
		self.QuickItem.rangeTimer = -1
		self.QuickItem:Show()
		
		SetItemButtonTexture(self.QuickItem, item)
		SetItemButtonCount(self.QuickItem, charges)
	else
		self.QuickItem:SetID(0)
		self.QuickItem:Hide()
	end
end

local function SetupObjTracker(self)
	local tracker = ObjectiveTrackerFrame

	tracker:SetMovable(true);
	tracker:SetUserPlaced(true);
	tracker:SetParent(self)
	tracker:SetHeight(600)
	tracker:ClearAllPoints()
	tracker:SetPoint("TOPRIGHT",self,"TOPRIGHT",-8,-8)

	--tracker.HeaderMenu.MinimizeButton:Hide()

	hooksecurefunc(tracker, "SetPoint", function(_, ...)
		if not InCombatLockdown() then
			local point, relativeTo = ...
			
			if point and relativeTo == "MinimapCluster" then
				tracker:SetPoint("TOPRIGHT", self, "TOPRIGHT", -8, -8);
			end
		end		
	end)

	--[[
	hooksecurefunc("ObjectiveTracker_Update", function(reason, id)
		if tracker.MODULES and #tracker.MODULES > 0 then
			for i = 1, #tracker.MODULES do
				local module = tracker.MODULES[i]

				module.Header.Text:SetFontObject(SyncUI_GameFontShadow_Medium)
				module.Header.Text:SetVertexColor(1,1,1)
				module.Header.Background:SetDesaturated(true)

				for _, block in pairs(module.usedBlocks) do
					if block.HeaderText then
						block.HeaderText:SetFontObject(SyncUI_GameFontShadow_Medium)
					end
				
					for _, line in pairs(block.lines) do
						if line.Dash then
							line.Dash:SetText("• ")
						end					
						if line.ProgressBar then
							line.ProgressBar.Bar.Label:SetFontObject(SyncUI_GameFontShadow_Medium)
						end
						if line.TimerBar then
							line.TimerBar.Label:SetFontObject(SyncUI_GameFontShadow_Medium)
						end
						
						line.Text:SetFontObject(SyncUI_GameFontShadow_Medium)
					end
				end
			end
	
			UpdateHeader()
		end
	end)
	hooksecurefunc("AddQuestWatch", function(questLogID)
		if QuestFilter then
			RemoveQuestWatch(questLogID)
		end
	end)
	hooksecurefunc("AddTrackedAchievement", function(achieveID)
		if AchievementFilter then
			AchievementObjectiveTracker_UntrackAchievement(_, achieveID)
		end
	end)

	--]]

	QUEST_DASH = "• "
end


function SyncUI_ObjTracker_OnLoad(self)
	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_PROGRESS")
	self:RegisterEvent("QUEST_COMPLETE")
	
	self:RegisterEvent("PLAYER_LOGIN")
	--self:RegisterEvent("PLAYER_LOGOUT")
	--self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED")
	--self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
	--self:RegisterEvent("UPDATE_BINDINGS")
	
	SyncUI_RegisterDragFrame(self, SYNCUI_STRING_OBJ_TRACKER)
	
	
	--[[
	setglobal("BINDING_NAME_CLICK SyncUI_ObjQuickItem:LeftButton", SYNCUI_STRING_BINDING_USE_ACTIVE_QUEST_ITEM)
	
	-- Dungeons + normal Scenarios
	ScenarioStageBlock.Stage:SetFontObject(SyncUI_GameFontShadow_Huge)
	ScenarioStageBlock.Name:SetFontObject(SyncUI_GameFontShadow_Medium)
	ScenarioStageBlock.CompleteLabel:SetFontObject(SyncUI_GameFontShadow_Huge)
	-- Proving Grounds
	ScenarioProvingGroundsBlock.Score:SetFontObject(SyncUI_GameFontShadow_Medium)
	ScenarioProvingGroundsBlock.Wave:SetFontObject(SyncUI_GameFontShadow_Medium)
	-- Challenge Mode
	ScenarioChallengeModeBlock.Level:SetFontObject(SyncUI_GameFontShadow_Medium)
	ScenarioChallengeModeBlock.TimeLeft:SetFontObject(SyncUI_GameFontShadow_Medium)
	--]]
end

function SyncUI_ObjTracker_OnEvent(self,event,...)
	if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then
		QuestSelect(event)
	end
	if event == "QUEST_DETAIL" then
		QuestAccept()
	end
	if event == "QUEST_ACCEPTED" then
		QuestShare(...)
	end
	if event == "QUEST_PROGRESS" then
		QuestTurnIn()
	end
	if event == "QUEST_COMPLETE" then
		QuestReward()
	end

	if event == "PLAYER_LOGIN" then
		SetupObjTracker(self)
	end
	--[[
	if event == "PLAYER_LOGOUT" then
		RestoreQuests()
		RestoreAchievements()
	end
	if event == "SUPER_TRACKED_QUEST_CHANGED" then
		local tracked = ...
		local found

		for i = 1, GetNumQuestWatches() do
			local questID = GetQuestWatchInfo(i)
			
			if questID == tracked then
				UpdateQuickItem(self, i)
				found = true
				break
			end
		end
		
		if not found then
			UpdateQuickItem(self, 0)
		end
	end
	if event == "QUEST_WATCH_LIST_CHANGED" then
		local questID, added = ...
		
		if questID and not added then
			UpdateQuickItem(self, GetQuestLogIndexByID(questID))
		end
	end
	if event == "PLAYER_LOGIN" or event == "UPDATE_BINDINGS" then
		local key1, key2 = GetBindingKey("CLICK SyncUI_ObjQuickItem:LeftButton")
		local text = GetBindingText(key1, 1) or ""

		self.QuickItem.Hotkey:SetText(text)
	end
	--]]
end

function SyncUI_ObjTracker_FilterButton_OnClick(self)
	if self.module == "Achievements" then
		if self:GetChecked() then
			UntrackAchievements()
		else
			RestoreAchievements()
		end
	end
	
	if self.module == "Quests" then
		if self:GetChecked() then
			UntrackQuests()
		else
			RestoreQuests()
		end
	end

	if self.module == "All" then
		local tracker = SyncUI_ObjTracker
		
		if self:GetChecked() then
			tracker.minimized = true
			tracker.QuestToggle:Hide()
			tracker.AchieveToggle:Hide()
			UpdateQuickItem(tracker, 0)
			ObjectiveTrackerFrame.BlocksFrame:Hide()
			ObjectiveTrackerFrame.collapsed	= true
		else
			tracker.minimized = false
			tracker.QuestToggle:Show()
			tracker.AchieveToggle:Show()
			SetSuperTrackedQuestID(GetSuperTrackedQuestID())
			ObjectiveTrackerFrame.BlocksFrame:Show()
			ObjectiveTrackerFrame.collapsed	= false
		end

		UpdateHeader()
	end
end
