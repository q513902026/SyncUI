
local LOOT_SOURCE_GARRISON_CACHE = 10
local MAX_QUEUE_THRESHOLD = 5
local QUEUE_LIST = {}

local function GetQuestName(questID)
	SyncUI_ScanTooltip:SetHyperlink("quest:"..questID)
	return SyncUI_ScanTooltipTextLeft1:GetText()
end

local function SetupAchievement(self, type, achievementID, alreadyEarned)
	local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

	if isGuildAch then
		self.Title:SetText(GUILD_ACHIEVEMENT_UNLOCKED)
	else
		self.Title:SetText(ACHIEVEMENT_UNLOCKED)
	end
	
	self.Display.Icon:SetTexture(icon)
	self.Text:SetText(name)	
	self.type = type
	self.value = achievementID
end

local function SetupCriteria(self, type, achievementID, criteriaString)
	local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch = GetAchievementInfo(achievementID)
 
	self.Display.Icon:SetTexture(icon)
	self.Title:SetText(ACHIEVEMENT_PROGRESSED)
	self.Text:SetText(criteriaString)
	self.type = type
	self.value = achievementID
end

local function SetupScenario(self, type)
	local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward()
	local _, _, _, _, hasBonusStep, isBonusStepComplete = C_Scenario.GetInfo()
	
	self.Text:SetText(name)
	self.Display.Icon:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename)
	self.type = type
end

local function SetupDungeonComplete(self, type)
	local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward()

	if subtypeID == LFG_SUBTYPEID_HEROIC then
		name = name.." ("..PLAYER_DIFFICULTY2..")"
		--self.Skull:Show()
	else
		--self.Skull:Hide()
	end
	
	self.Title:SetText(DUNGEON_COMPLETED)
	self.Text:SetText(name)
	self.Display.Icon:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename)
	self.type = type
end

local function SetupLoot(self, type, itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, isPersonal)
	local itemName, itemHyperLink, itemRarity, itemTexture, title
	
	if isCurrency then
		itemName, _, itemTexture, _, _, _, _, itemRarity = GetCurrencyInfo(itemLink)
		
		if lootSource == LOOT_SOURCE_GARRISON_CACHE then
			itemName = format(GARRISON_RESOURCES_LOOT, quantity)
		else
			itemName = format(CURRENCY_QUANTITY_TEMPLATE, quantity, itemName)
		end
		
		itemHyperLink = itemLink 
	else
		itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
	end
	
	local info = (isPersonal or isCurrency) and LOOTWONALERTFRAME_VALUES.DefaultPersonal or LOOTWONALERTFRAME_VALUES.Default;
	local color = ITEM_QUALITY_COLORS[itemRarity]
	
	if showFactionBG then
		local factionGroup = UnitFactionGroup("player")
		info = LOOTWONALERTFRAME_VALUES[factionGroup]
	else
		if lootSource == LOOT_SOURCE_GARRISON_CACHE then
			info = LOOTWONALERTFRAME_VALUES["GarrisonCache"]
		elseif lessAwesome then
			info = LOOTWONALERTFRAME_VALUES["LessAwesome"]
		elseif isUpgraded then
			info = LOOTWONALERTFRAME_VALUES["Upgraded"]
		end
	end
	

	if rollType == LOOT_ROLL_TYPE_NEED then
		title = info.labelText.." "..roll.."|T".."Interface\\Buttons\\UI-GroupLoot-Dice-Up"..":12:12:0:0:64:64:10:54:10:54|t "
	elseif rollType == LOOT_ROLL_TYPE_GREED then
		title = info.labelText.." "..roll.."|T".."Interface\\Buttons\\UI-GroupLoot-Coin-Up"..":12:12:0:0:64:64:10:54:10:54|t "
	else
		title = info.labelText
	end
	
	if quantity > 1 and lootSource ~= LOOT_SOURCE_GARRISON_CACHE then
		self.Display.Count:SetText(quantity)
	end
	
	self.Display.Icon:SetTexture(itemTexture)
	self.Title:SetText(title)
	self.Text:SetText(itemName)
	self.Text:SetVertexColor(color.r, color.g, color.b)
	self.type = type
	
	if not isCurrency then
		self.value = itemHyperLink
	end
	
	if lessAwesome then
		PlaySound(51402)	-- Sound: UI_Raid_Loot_Toast_Lesser_Item_Won
	elseif isUpgraded then
		PlaySound(51561) 	-- Sound: UI_Warforged_Item_Loot_Toast
	else
		PlaySound(31578)	-- Sound: UI_EpicLoot_Toast
	end
end

local function SetupLootUpgrade(self, type, itemLink)
	local itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
	local upgradeQualityColor = ITEM_QUALITY_COLORS[itemRarity]

	self.Display.Icon:SetTexture(itemTexture)
	self.Title:SetText(format(LOOTUPGRADEFRAME_TITLE, _G["ITEM_QUALITY"..itemRarity.."_DESC"]))
	self.Title:SetTextColor(upgradeQualityColor.r, upgradeQualityColor.g, upgradeQualityColor.b)
	self.Text:SetText(itemName)
	self.type = type
	self.value = itemHyperLink
	
	PlaySound(31578)	-- Sound: UI_EpicLoot_Toast
end

local function SetupMoneyWon(self, type, amount)
	self.Display.Icon:SetTexture("Interface\\Icons\\inv_misc_coin_02")
	self.Title:SetText(YOU_WON_LABEL)
	self.Text:SetText(GetMoneyString(amount))
	self.type = type
	
	PlaySound(31578)	-- Sound: UI_EpicLoot_Toast
end

local function SetupStorePurchase(self, type, category, icon, name, payloadID)
	self.Display.Icon:SetTexture(icon)
	self.Title:SetText(YOU_RECEIVED)
	self.Text:SetText(name)
	self.type = type
	self.value = payloadID
end

local function SetupGarrisonBuilding(self, type, name)
	self.Display.Icon:SetTexture("Interface\\Icons\\Garrison_Build")
	self.Title:SetText(GARRISON_UPDATE)
	self.Text:SetFormattedText(GARRISON_BUILDING_COMPLETE_TOAST, name)
	self.type = type
end

local function SetupGarrisonTalent(self, type, garrisonType)
	local talentID = C_Garrison.GetCompleteTalent(garrisonType)
    local talent = C_Garrison.GetTalent(talentID)
	
	self.Display.Icon:SetTexture(talent.icon)
	self.Title:SetText(GARRISON_UPDATE)
	self.Text:SetFormattedText(GARRISON_BUILDING_COMPLETE_TOAST, garrisonType)
	self.type = type
end

local function SetupGarrisonMission(self, type, missionID)
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID)

	self.Display.Icon:SetAtlas(missionInfo.typeAtlas)
	self.Title:SetText(GARRISON_MISSION_COMPLETE)
	self.Text:SetText(missionInfo.name)
	self.type = type
end

local function SetupGarrisonRandomMission(self, type, missionID)
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID)

	self.Display.Icon:SetAtlas(missionInfo.typeAtlas)
	self.Title:SetText(GARRISON_MISSION_COMPLETE)
	self.Text:SetText(missionInfo.name)
	self.type = type
end

local function SetupGarrisonFollower(self, type, followerID, name, level, quality, isUpgraded)
	local followerInfo = C_Garrison.GetFollowerInfo(followerID)

	if followerInfo.isTroop then
		if isUpgraded then
			self.Title:SetText(GarrisonFollowerOptions[followerInfo.followerTypeID].strings.TROOP_ADDED_UPGRADED_TOAST);
		else
			self.Title:SetText(GarrisonFollowerOptions[followerInfo.followerTypeID].strings.TROOP_ADDED_TOAST);
		end	
	else
		if isUpgraded then
			self.Title:SetText(GarrisonFollowerOptions[followerInfo.followerTypeID].strings.FOLLOWER_ADDED_UPGRADED_TOAST);
		else
			self.Title:SetText(GarrisonFollowerOptions[followerInfo.followerTypeID].strings.FOLLOWER_ADDED_TOAST);
		end
	end
	
	--self.Display.Icon:SetTexture(followerInfo)
	self.Text:SetText(name)
	self.type = type
end

local function SetupGarrisonShipFollower(self, type, followerID, name, class, texPrefix, level, quality, isUpgraded)
	local mapAtlas = texPrefix .. "-List"
	local color = ITEM_QUALITY_COLORS[quality]
	local followerInfo = C_Garrison.GetFollowerInfo(followerID)
	
	self.Display.Icon:SetAtlas(mapAtlas, false)
	
	if isUpgraded then
		self.Title:SetText(GARRISON_SHIPYARD_FOLLOWER_ADDED_UPGRADED_TOAST)
	else
		self.Title:SetText(GARRISON_SHIPYARD_FOLLOWER_ADDED_TOAST)
	end
	
	self.Text:SetText(name)
	self.Text:SetTextColor(color.r, color.g, color.b)
	self.type = type
end

local function SetupNewRecipeLearned(self, type, recipeID)
	local tradeSkillID, skillLineName = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID)
	
	if tradeSkillID then
		local recipeName = GetSpellInfo(recipeID)
		
		if recipeName then
			local icon = C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID)
			local rank = GetSpellRank(recipeID)
			local rankTexture = NewRecipeLearnedAlertFrame_GetStarTextureFromRank(rank)
			
			self.Display.Icon:SetTexture(icon)
			self.Title:SetText(rank and rank > 1 and UPGRADED_RECIPE_LEARNED_TITLE or NEW_RECIPE_LEARNED_TITLE)

			if rankTexture then
				self.Text:SetFormattedText("%s %s", recipeName, rankTexture)
			else
				self.Text:SetText(recipeName)
			end
			
			self.value = recipeID
			self.type = type

			return true
		end
	end
	
	return false
end

local function SetupLegendaryItem(self, type, itemLink)
	local itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
	local color = ITEM_QUALITY_COLORS[itemRarity]
	
	self.Display.Icon:SetTexture(itemTexture)
	self.Title:SetText(LEGENDARY_ITEM_LOOT_LABEL)
	self.Text:SetText(itemName)
	self.Text:SetVertexColor(color.r, color.g, color.b)
	self.type = type
	self.value = itemHyperLink
end

local function SetupWorldQuestComplete(self, type, questID, rewardItemLink)
	local name = select(4, GetTaskInfo(questID)), GetQuestName(questID)
	local icon = WorldQuestCompleteAlertFrame_GetIconForQuestID(questID)
	local money = GetQuestLogRewardMoney(questID)
	
	self.Title:SetText(WORLD_QUEST_COMPLETE)
	self.Display.Icon:SetTexture(icon)
	self.Text:SetText(name)
	self.type = type
	self.value = questID
end

local function SetupInvasion(self, type, rewardQuestID, rewardItemLink)
	if rewardItemLink then
		-- If we're seeing this with a reward the scenario hasn't been completed yet, no toast until scenario complete is triggered
		return false
	end
	
	local scenarioName, currentStage, numStages, flags, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = C_Scenario.GetInfo()
	
	self.Display.Icon:SetTexture("Interface\\Icons\\Ability_Warlock_DemonicPower")
	self.Title:SetText(SCENARIO_INVASION_COMPLETE)
	self.Text:SetText(areaName or scenarioName)
	self.type = type
	self.value = rewardQuestID
	
	return true
end


-- Handler
local function Clear(self)
	self.Display.Icon:SetMask(nil)
	self.Display.Icon:SetTexture("")
	self.Display.Icon:SetTexCoord(0.1,0.9,0.1,0.9)
	self.Display.Count:SetText("")
	--self.Skull:Hide()
	self.Title:SetText("")
	self.Title:SetVertexColor(0.6,1,0)
	self.Text:SetText("")
	self.Text:SetVertexColor(1,1,1)
	self.type = nil
	self.value = nil
end

local function Spawn(self)
	self:Show()
	
	if self:IsMouseOver() then
		self.Despawn.alpha:SetStartDelay(1)
		self.Despawn.trans:SetStartDelay(1)
	else
		self.Despawn.alpha:SetStartDelay(3.5)
		self.Despawn.trans:SetStartDelay(3.5)
		self.Despawn:Play()
	end
end

local function AddToQueue(self, type, ...)
	if #QUEUE_LIST >= MAX_QUEUE_THRESHOLD then
		table.remove(QUEUE_LIST, 1)
	end
	
	tinsert(QUEUE_LIST, {type, ...})
end

local function AddAlert(...)
	local frame, type = ...

	if frame.active or frame.forceQueue then
		AddToQueue(...)
		return
	end
	
	frame:Clear()
	
	if type == "Achievement" then
		SetupAchievement(...)
	end
	if type == "Criteria" then
		SetupCriteria(...)
	end
	if type == "Scenario" then
		SetupScenario(...)
	end
	if type == "DungeonComplete" then
		SetupDungeonComplete(...)
	end
	if type == "Loot" then
		SetupLoot(...)
	end
	if type == "LootUpgrade" then
		SetupLootUpgrade(...)
	end
	if type == "MoneyWon" then
		SetupMoneyWon(...)
	end
	if type == "StorePurchase" then
		SetupStorePurchase(...)
	end
	if type == "GarrisonBuilding" then
		SetupGarrisonBuilding(...)
	end
	if type == "GarrisonTalent" then
		SetupGarrisonTalent(...)
	end
	if type == "GarrisonMission" then
		SetupGarrisonMission(...)
	end
	if type == "GarrisonRandomMission" then
		SetupGarrisonRandomMission(...)
	end
	if type == "GarrisonFollower" then
		SetupGarrisonFollower(...)
	end
	if type == "GarrisonShipFollower" then
		SetupGarrisonShipFollower(...)
	end
	if type == "NewRecipeLearned" then
		if not SetupNewRecipeLearned(...) then
			return
		end
	end
	if type == "LegendaryItem" then
		SetupLegendaryItem(...)
	end	
	if type == "WorldQuestComplete" then
		SetupWorldQuestComplete(...)
	end
	if type == "Invasion" then
		if not SetupInvasion(...) then
			return
		end
	end

	Spawn(...)	
end

local function CheckForQueues(self)
	if not QUEUE_LIST[1] then
		return
	end
	
	C_Timer.After(0.5, function()
		self:AddAlert(unpack(QUEUE_LIST[1]))
		table.remove(QUEUE_LIST, 1)
	end)
end

local function RunTest(self)
	--self:AddAlert("NewRecipeLearned", 201684)
	--self:AddAlert("Loot", select(2, GetItemInfo(117491)), 225)
	--self:AddAlert("MoneyWon", 35121646)
	self:AddAlert("GarrisonBuilding", "Gear Works!")
	--self:AddAlert("LegendaryItem", select(2, GetItemInfo(132452)))
	self:AddAlert("WorldQuestComplete", 41950)
end


function SyncUI_AlertFrame_OnLoad(self)
	self:RegisterEvent("ACHIEVEMENT_EARNED")
	self:RegisterEvent("CRITERIA_EARNED")
	self:RegisterEvent("LFG_COMPLETION_REWARD")
	self:RegisterEvent("SCENARIO_COMPLETED")
	self:RegisterEvent("LOOT_ITEM_ROLL_WON")
	self:RegisterEvent("SHOW_LOOT_TOAST")
	self:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE")
	self:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
	self:RegisterEvent("PET_BATTLE_CLOSE")
	self:RegisterEvent("STORE_PRODUCT_DELIVERED")
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE")
	self:RegisterEvent("GARRISON_TALENT_COMPLETE")
	self:RegisterEvent("GARRISON_MISSION_FINISHED")
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED")
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED")
	self:RegisterEvent("NEW_RECIPE_LEARNED")
	self:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
	self:RegisterEvent("QUEST_TURNED_IN")
	--self:RegisterEvent("QUEST_LOOT_RECEIVED")
	--self:RegisterEvent("PLAYER_REGEN_DISABLED")
	--self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterForClicks("AnyUp")
	
	-- add widgets
	self.AddAlert = AddAlert
	self.Clear = Clear
	self.RunTest = RunTest
	
	AlertFrame:UnregisterAllEvents()
	
	SyncUI_RegisterDragFrame(self, SYNCUI_STRING_PLACEMENT_TOOL_LABEL_ALERTS)
end

function SyncUI_AlertFrame_OnEvent(self, event, ...)
	if event == "ACHIEVEMENT_EARNED" then
		if IsKioskModeEnabled() then
			return
		end

		if not AchievementFrame then
			AchievementFrame_LoadUI()
		end

		self:AddAlert("Achievement", ...)
	end
	if event == "CRITERIA_EARNED" then
		if IsKioskModeEnabled() then
			return
		end

		if not AchievementFrame then
			AchievementFrame_LoadUI()
		end

		self:AddAlert("Criteria", ...)
	end
	if event == "LFG_COMPLETION_REWARD" then
		if C_Scenario.IsInScenario() and not C_Scenario.TreatScenarioAsDungeon() then
			local scenarioType = select(10, C_Scenario.GetInfo())
			
			if scenarioType ~= LE_SCENARIO_TYPE_LEGION_INVASION then
				self:AddAlert("Scenario")
			end
		else
			self:AddAlert("DungeonComplete")
		end
	end
	if event == "SCENARIO_COMPLETED" then
		local scenarioType = select(10, C_Scenario.GetInfo())
		
		if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
			local rewardQuestID = ...
			
			if rewardQuestID then
				self:AddAlert("Invasion", rewardQuestID)
			end
		end
	end
	if event == "LOOT_ITEM_ROLL_WON" then
		local itemLink, quantity, rollType, roll, isUpgraded = ...
		
		self:AddAlert("Loot", itemLink, quantity, rollType, roll, nil, nil, nil, nil, nil, isUpgraded)
	end
	if event == "SHOW_LOOT_TOAST" then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded = ...
		
		if typeIdentifier == "item" then
			self:AddAlert("Loot", itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded, isPersonal)
		elseif typeIdentifier == "money" then
			self:AddAlert("MoneyWon", quantity)
		elseif isPersonal and (typeIdentifier == "currency") then
			self:AddAlert("Loot", itemLink, quantity, nil, nil, specID, true, false, lootSource)
		end
	end
	if event == "SHOW_PVP_FACTION_LOOT_TOAST"  then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...
		
		if typeIdentifier == "item" then
			self:AddAlert("Loot", itemLink, quantity, nil, nil, specID, false, true, nil, lessAwesome)
		elseif typeIdentifier == "money" then
			self:AddAlert("MoneyWon", quantity)
		elseif typeIdentifier == "currency" then
			self:AddAlert("Loot", itemLink, quantity, nil, nil, specID, true, true)
		end
	end
	if event == "SHOW_LOOT_TOAST_UPGRADE" then
		local itemLink, quantity, specID, sex, baseQuality, isPersonal, lessAwesome = ...
		
		self:AddAlert("LootUpgrade", itemLink, quantity, specID, baseQuality, nil, nil, lessAwesome)
		--LootUpgradeAlertSystem:AddAlert(itemLink, quantity, specID, baseQuality, nil, nil, lessAwesome)
	end
	if event == "STORE_PRODUCT_DELIVERED" then
		self:AddAlert("StorePurchase", ...)
		--StorePurchaseAlertSystem:AddAlert(...)
	end
	if event == "GARRISON_BUILDING_ACTIVATABLE" then
		self:AddAlert("GarrisonBuilding", ...)
		GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play()
	end
	if event == "GARRISON_TALENT_COMPLETE" then
		self:AddAlert("GarrisonTalent", ...)
	end
	if event == "GARRISON_MISSION_FINISHED" then
		local validInstance = false
		local _, instanceType = GetInstanceInfo()
		
		if instanceType == "none" or C_Garrison.IsOnGarrisonMap() then
			validInstance = true
		end

		if validInstance and not UnitAffectingCombat("player") then
			local followerTypeID, missionID = ...
			local missionFrame = _G[GarrisonFollowerOptions[followerTypeID].missionFrame]
			
			if not missionFrame or not missionFrame:IsShown() then
				self:AddAlert("GarrisonMission", missionID)
				GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play()
			end
		end
	end
	if event == "GARRISON_FOLLOWER_ADDED" then
		local followerID, name, class, level, quality, isUpgraded, texPrefix, followerType = ...
		
		if followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
			self:AddAlert("GarrisonShipFollower", followerID, name, class, texPrefix, level, quality, isUpgraded)
		else
			self:AddAlert("GarrisonFollower", followerID, name, level, quality, isUpgraded)
		end
	end
	if event == "GARRISON_RANDOM_MISSION_ADDED" then
		self:AddAlert("GarrisonRandomMission", select(2, ...))
	end
	if event == "NEW_RECIPE_LEARNED" then
		self:AddAlert("NewRecipeLearned", ...)
	end
	if event == "SHOW_LOOT_TOAST_LEGENDARY_LOOTED" then
		local itemLink = ...
		
		self:AddAlert("LegendaryItem", itemLink)
	end
	if event == "QUEST_TURNED_IN" then
		local questID = ...
		
		--if QuestMapFrame_IsQuestWorldQuest(questID) then
			--self:AddAlert("WorldQuestComplete", questID)
		--end
	end
	if event == "QUEST_LOOT_RECEIVED" then
		local questID, rewardItemLink = ...
		
		if QuestMapFrame_IsQuestWorldQuest(questID) then
			self:AddAlert("WorldQuestComplete", questID, rewardItemLink)
		else	-- May be invasion reward
			self:AddAlert("Invasion", questID, rewardItemLink)
		end
	end

	if event == "PLAYER_REGEN_DISABLED" then
		self.forceQueue = true
	end
	if event == "PLAYER_REGEN_ENABLED" then
		self.forceQueue = false
		CheckForQueues(self)
	end
end

function SyncUI_AlertFrame_OnEnter(self)
	self.Despawn:Stop()
	self.Despawn.alpha:SetStartDelay(1)
	self.Despawn.trans:SetStartDelay(1)
	
	if self.value then
		local type = self.type
		
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		
		if type == "Achievement" then
			--GameTooltip:SetAchievementByID(self.value)
		end
		if type == "Loot" or type == "LootUpgrade" or type == "LegendaryItem" then
			local itemID = GetItemInfoFromHyperlink(self.value)
			GameTooltip:SetItemByID(itemID)
		end
		
		GameTooltip:Show()
	end
end

function SyncUI_AlertFrame_OnLeave(self)
	self.Despawn:Play()
	GameTooltip_Hide()
end

function SyncUI_AlertFrame_OnShow(self)
	self.active = true
	self.Despawn:Stop()
	self.Spawn:Play()
end

function SyncUI_AlertFrame_OnHide(self)
	self.active = false
	CheckForQueues(self)
end

function SyncUI_AlertFrame_OnClick(self)
	local type = self.type
	
	if type == "Achievement" then
		if not self.value then
			return
		end
		
		CloseAllWindows()
		AchievementObjectiveTracker_OpenAchievement(nil, self.value)
	end
	
	if type == "Loot" or type == "LootUpgrade" or type == "LegendaryItem" then
		local bag = SearchBagsForItemLink(self.value)
		
		if bag >= 0 then
			OpenBag(bag)
		end
	end
end
