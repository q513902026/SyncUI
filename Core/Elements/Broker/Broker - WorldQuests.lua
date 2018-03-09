
local currentZone;

local questList, mapList = {}, {
	[GetMapNameByID(1015)] = 1015,  -- Aszuna
	[GetMapNameByID(1024)] = 1024,  -- Highmountain
	[GetMapNameByID(1017)] = 1017,  -- Stormheim
	[GetMapNameByID(1033)] = 1033,  -- Suramar
	[GetMapNameByID(1018)] = 1018,  -- Val'sharah
	[GetMapNameByID(1096)] = 1096,	-- Eye of Aszara
}

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
	local preMapID = GetCurrentMapAreaID()

	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	
	-- Available at lvl 110
	if UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT] then
		GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 110), 1,1,1)
		GameTooltip:Show()
		return
	end

	do	-- current zone (default)
		--if not WorldMapFrame:IsShown() then
			SetMapToCurrentZone()
		--end

		local mapID = (GetCurrentMapAreaID() == 1080 and 1024) or GetCurrentMapAreaID()
		local name = GetMapNameByID(mapID)
		
		if mapList[name] then
			questList = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)

			table.sort(questList, SortQuest)
			
			GameTooltip:AddLine(name, 1,1,1)
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
	
	SetMapByID(preMapID)
	GameTooltip:Show()
end

local function WorldQuests_OnClick(self)
	local mapID = GetCurrentMapAreaID()
	ToggleWorldMap()
end

local function WorldQuests_OnUpdate(self)
	local mapID = GetCurrentMapAreaID()
	
	if mapID == 1080 then
		mapID = 1024
	end
	
	currentZone = mapID
	local name = GetMapNameByID(mapID)
	
	if mapList[name] then
		self:SetText(name)
	else
		self:SetText(TRACKER_HEADER_WORLD_QUESTS)
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