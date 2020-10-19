
--------------------------
-- Auto Quest Functions --
--------------------------
local exceptions = {
	["Lucian Trias"] = 1,
}

local function GetIndex(index, num, ignore)
	local decrement = num - (ignore or 0 + 1);
	local id = index * num - decrement;
	
	return id;
end

local function Gossip()
	local exception = exceptions[UnitName("target")];
	
	if exception then
		C_GossipInfo.SelectOption(exception);
	else
		if C_GossipInfo.GetNumAvailableQuests() > 0 then
			return;
		end
		
		if C_GossipInfo.GetNumAvailableQuests() > 0 then
			return;
		end
		
		if C_GossipInfo.GetNumOptions() > 1 then
			return;
		end
		
		if select(2, C_GossipInfo.GetNumOptions()) ~= "gossip" then
			return;
		end
		
		C_GossipInfo.SelectOption(1);
	end	
end

local function SelectAvailable(event)
	local profile = SyncUI_GetProfile();

	if not profile.Options.Quests.Accept then
		return;
	end

	if event == "GOSSIP_SHOW" then
		for i = 1, C_GossipInfo.GetNumAvailableQuests() do
			local gossipInfo = C_GossipInfo.GetAvailableQuests()
			local name, level, trivial, frequency, repeatable, legendary = gossipInfo.title,gossipInfo.questLevel,gossipInfo.isTrivial,gossipInfo.frequency,gossipInfo.repeatable,gossipInfo.isLegendary
			
			if not repeatable and not trivial and frequency == 1 then
				C_GossipInfo.SelectAvailableQuest(i);
				break;
			end
		end
	end
	
	if event == "QUEST_GREETING" then	
		for i = 1, GetNumAvailableQuests() do
			local trivial, frequency, repeatable = GetAvailableQuestInfo(i);
			
			if not repeatable and not trivial and frequency == 1 then
				SelectAvailableQuest(i);
				break;
			end
		end
	end
end

local function SelectActive(event)
	local profile = SyncUI_GetProfile();
	
	if not profile.Options.Quests.TurnIn then
		return;
	end
	
	if event == "GOSSIP_SHOW" then
		for i = 1, C_GossipInfo.GetNumAvailableQuests() do
			local gossipInfo = C_GossipInfo.GetAvailableQuests()
			local name, level, trivial, complete = gossipInfo.title,gossipInfo.questLevel,gossipInfo.isTrivial,gossipInfo.isComplete
			
			if complete then
				C_GossipInfo.SelectActiveQuest(i)
				break;
			end
		end
	end
	
	if event == "QUEST_GREETING" then
		for i = 1, GetNumActiveQuests() do
			local isComplete = select(2, GetActiveTitle(i));
			
			if isComplete then
				SelectActiveQuest(i);
				break;
			end
		end
	end
end

local function SelectReward()
	local profile = SyncUI_GetProfile()
	
	if not profile.Options.Quests.TurnIn then
		return;
	end
	
	if GetNumQuestChoices() > 1 then
		return;
	end
	
	QuestRewardCompleteButton_OnClick();
end

local function Accept()
	local profile = SyncUI_GetProfile();

	if not profile.Options.Quests.Accept then
		return;
	end
	
	local isRepeatable = QuestIsDaily() or QuestIsWeekly();

	if not isRepeatable or (isRepeatable and profile.Options.Quests.Daily) then
		AcceptQuest();
	end
	
	if QuestGetAutoAccept() then
		CloseQuest();
	else
		AcceptQuest();
	end
end

local function TurnIn()
	local profile = SyncUI_GetProfile();
	
	if not profile.Options.Quests.TurnIn then
		return;
	end
	
	if IsQuestCompletable() then
		CompleteQuest();
	end
	
	-- TODO: check if this stops interaction completely...
	CloseQuest();
end

local function Share(questID)
	local profile = SyncUI_GetProfile();
	
	if not profile.Options.Quests.Share then
		return;
	end
	
	if GetNumGroupMembers() <= 0 then
		return;
	end
	
	C_QuestLog.SetSelectedQuest(questID);
		
	if not C_QuestLog.IsPushableQuest() then
		return;
	end
	
	QuestLogPushQuest();
end

------------------------------
-- Modify Objective Tracker --
------------------------------
local AchievementList, QuestList = {}, {}
local AchievementFilter, QuestFilter

local function UntrackQuests()
	QuestList, QuestFilter = {}, true

	for i = 1, C_QuestLog.GetNumQuestWatches() do
		local questInfo = C_QuestLog.GetInfo(i)

		if questInfo.questID then
			QuestList[questInfo.questID] = true
		end
	end
	
	for questID in pairs(QuestList) do
		C_QuestLog.RemoveQuestWatch(questID)
	end
end

local function RestoreQuests()
	QuestFilter = false
	
	for questID in pairs(QuestList) do
		C_QuestLog.AddQuestWatch(questID)
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
	
	--ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetFontObject(SyncUI_GameFontShadow_Medium)
	--ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetText(TRACKER_HEADER_ACHIEVEMENTS.." ("..GetNumTrackedAchievements().."/".. 10 ..")")
	--ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetFontObject(SyncUI_GameFontShadow_Medium)
	--ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(TRACKER_HEADER_QUESTS.." ("..GetNumQuestWatches().."/"..MAX_WATCHABLE_QUESTS..")")
end

local function UpdateQuickItem(self, i)
	local questInfo = C_QuestLog.GetInfo(i)
	if not questInfo then return end
	local questLogIndex = questInfo.questLogIndex or 0
	local isQuestComplete = questInfo.isAutoComplete
	local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex);

	if item and (not isQuestComplete or showItemWhenComplete) and not self.minimized then
		self.QuickItem:SetID(questLogIndex)
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
	tracker:SetPoint("TOPRIGHT", self, "TOPRIGHT", -8, -8)

	tracker.HeaderMenu.MinimizeButton:Hide()

	hooksecurefunc(tracker, "SetPoint", function(_, ...)
		if not InCombatLockdown() then
			local point, relativeTo = ...
			
			if point and relativeTo == "MinimapCluster" then
				tracker:SetPoint("TOPRIGHT", self, "TOPRIGHT", -8, -8);
				print("changed");
			end
		end		
	end)
	local function skinHeader(_,block)
		block.HeaderText:SetFontObject(SyncUI_GameFontShadow_Medium)
	end
	hooksecurefunc("ObjectiveTracker_Update", function(reason, id)
		if tracker.MODULES and #tracker.MODULES > 0 then
			for i = 1, #tracker.MODULES do
				local module = tracker.MODULES[i]

				module.Header.Text:SetFontObject(SyncUI_GameFontShadow_Medium)
				module.Header.Text:SetVertexColor(1,1,1)
				module.Header.Background:SetDesaturated(true)
				
				if not module.hook then 
					hooksecurefunc(module,"SetBlockHeader",skinHeader) 
					module.hook = true 
				end
				--[[
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
				]]--
			end
	
			UpdateHeader();
		end
	end)


	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(self, block, objectiveKey, _, lineType)
		local line = self:GetLine(block, objectiveKey, lineType)
			
		if line.Dash and line.Dash:IsShown() then
			line.Dash:SetText("• ")
		end					
		if line.ProgressBar then
			line.ProgressBar.Bar.Label:SetFontObject(SyncUI_GameFontShadow_Medium)
		end
		if line.TimerBar then
			line.TimerBar.Label:SetFontObject(SyncUI_GameFontShadow_Medium)
		end
		
		line.Text:SetFontObject(SyncUI_GameFontShadow_Medium)
	end)
	hooksecurefunc(C_QuestLog,"AddQuestWatch", function(questLogID,watchType)
		if QuestFilter then
			C_QuestLog.RemoveQuestWatch(questID)
		end
	end)
	hooksecurefunc("AddTrackedAchievement", function(achieveID)
		if AchievementFilter then
			AchievementObjectiveTracker_UntrackAchievement(_, achieveID)
		end
	end)

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
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("SUPER_TRACKING_CHANGED")
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
	self:RegisterEvent("UPDATE_BINDINGS")
	
	SyncUI_RegisterDragFrame(self, SYNCUI_STRING_OBJ_TRACKER)

	--[[
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

function SyncUI_ObjTracker_OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		SetupObjTracker(self)
	end
	if event == "PLAYER_LOGOUT" then
		RestoreQuests()
		RestoreAchievements()
	end
	if event == "SUPER_TRACKING_CHANGED" or event == "PLAYER_LOGIN" then
		local tracked = C_SuperTrack.GetSuperTrackedQuestID();

		for i = 1, C_QuestLog.GetNumQuestWatches() do
			if C_QuestLog.GetQuestIDForQuestWatchIndex(i)  == tracked then
				UpdateQuickItem(self, i)
				return;
			end
		end

		UpdateQuickItem(self, 0)
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

	
	
	if IsShiftKeyDown() then
		return;
	end

	if event == "GOSSIP_SHOW" then
		Gossip();
		SelectAvailable(event);
		SelectActive(event);
	end
	
	if event == "QUEST_GREETING" then
		SelectAvailable(event);
		SelectActive(event);
	end
	
	if event == "QUEST_DETAIL" then
		Accept();
	end
	
	if event == "QUEST_ACCEPTED" then
		Share(...);
	end
	
	if event == "QUEST_PROGRESS" then
		TurnIn();
	end
	
	if event == "QUEST_COMPLETE" then
		SelectReward();
	end
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
			C_SuperTrack.SetSuperTrackedQuestID(C_SuperTrack.GetSuperTrackedQuestID())
			ObjectiveTrackerFrame.BlocksFrame:Show()
			ObjectiveTrackerFrame.collapsed	= false
		end

		UpdateHeader()
	end
end

setglobal("BINDING_NAME_CLICK SyncUI_ObjQuickItem:LeftButton", SYNCUI_STRING_BINDING_USE_ACTIVE_QUEST_ITEM);