
local questList, mapList = {}, {
	[862] = "Zul'Dazar",
	[863] = "Nazmir",
	[864] = "Vol'Dun",
	[942] = "Stormsong Valley",
	[895] = "Tiragarde Sound",
	[896] = "Drustvar",
}

local function GetCurrentMapID()
	local mapID = C_Map.GetBestMapForUnit("player");
	
	-- Horde Fix for Dazar'Alor
	if mapID == 1163 or mapID == 1165 then
		mapID = 862;
	end
	
	-- Alliance fix for Boralus
	if mapID == 1161 then
		mapID = 895;
	end	
	
	return mapID;
end

local function GetHeaderText(mapID)
	local name = C_Map.GetMapInfo(mapID).name;
	local count = #(C_TaskQuest.GetQuestsForPlayerByMapID(mapID))
	return name .. " (" .. count .. ")";
end

local function SortQuest(a, b)
	local an = C_TaskQuest.GetQuestInfoByQuestID(a.questId)
	local at = C_TaskQuest.GetQuestTimeLeftMinutes(a.questId)
	local bn = C_TaskQuest.GetQuestInfoByQuestID(b.questId)
	local bt = C_TaskQuest.GetQuestTimeLeftMinutes(b.questId)

	if at ~= bt then
		return at < bt
	else
		return an < bn
	end
end

local function GetTimerString(value)
	local string;
	
	if value > 60*24 then
		string = format(DAYS_ABBR, math.floor (value / (60*24)))
	elseif value > 60 then
		string = format(HOURS_ABBR, math.floor(value / 60))
	else
		string = format(MINUTES_ABBR, value)
	end
	
	return string
end

local function WorldQuests_OnEnter(self)
	local mapID = GetCurrentMapID();
	
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	
	-- Available at lvl 10 tempfix
	if C_QuestLog.IsQuestFlaggedCompleted(51722)  then
		GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 50), 1,1,1)
		GameTooltip:Show()
		return
	end

	do	-- current zone (default)
		if mapList[mapID] then
			questList = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)

			table.sort(questList, SortQuest)
			
			GameTooltip:AddLine(GetHeaderText(mapID), 1,1,1)
			GameTooltip:SetPrevLineJustify("CENTER")
			GameTooltip:AddDivider()
				
			for i, info in ipairs(questList) do
				local questID = info.questId
				local timeOut = C_TaskQuest.GetQuestTimeLeftMinutes(questID)

				if timeOut and timeOut > 0 then
					local title, faction = C_TaskQuest.GetQuestInfoByQuestID(questID)
					local rarity = select(4, GetQuestTagInfo(questID))
					local color = WORLD_QUEST_QUALITY_COLORS[rarity]
					
					if faction then
						faction = GetFactionInfoByID(faction)
					else
						faction = ""
					end
					
					if color then
						title = SyncUI_GetColorizedText(title,color.r,color.g,color.b)
					end
					
					timeOut = GetTimerString(timeOut)
					
					GameTooltip:AddDoubleLine(title, timeOut, 1,1,1, 1,1,1)
				end
			end
		else
			--GameTooltip:AddLine("Unable to retrieve world quests for this zone.",1,0,0)
			GameTooltip:AddLine(SPELL_FAILED_INCORRECT_AREA, 1,0,0)
		end
	end

	GameTooltip:Show()
end

local function WorldQuests_OnClick(self)
	ToggleWorldMap();
end

local function WorldQuests_OnUpdate(self)
	local mapID = GetCurrentMapID();

	if mapList[mapID] then
		self:SetText(GetHeaderText(mapID));
	else
		self:SetText(TRACKER_HEADER_WORLD_QUESTS);
	end
end

do	-- Initialize
	local info = {}

	info.title = TRACKER_HEADER_WORLD_QUESTS
	info.icon = "Interface\\Icons\\inv_artifact_tome01"
	info.tooltipFunc = WorldQuests_OnEnter
	info.clickFunc = WorldQuests_OnClick
	info.updateFunc = WorldQuests_OnUpdate
	
	SyncUI_RegisterBrokerType("WorldQuests", info)
end