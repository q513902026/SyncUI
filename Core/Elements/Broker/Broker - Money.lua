
local session, init

local function GetBrokerDataBase(serverName)
	if not SyncUI_Data["Broker"] then
		SyncUI_Data["Broker"] = {}
	end
	if not SyncUI_Data["Broker"]["CharInfo"] then
		SyncUI_Data["Broker"]["CharInfo"] = {}
	end
	if not SyncUI_Data["Broker"]["CharInfo"][serverName] then
		SyncUI_Data["Broker"]["CharInfo"][serverName] = {}
	end
	
	return SyncUI_Data["Broker"]["CharInfo"][serverName]
end

local function GetMoneyString(money)
	local gold = floor(money/10000)
	local silver = floor((money-gold*10000)/100)
	local copper = mod(money,100)
	local goldText, silverText, copperText = format(GOLD_AMOUNT_TEXTURE, gold)
	local string
	
	if copper > 0 then
		copperText = " "..format(COPPER_AMOUNT_TEXTURE, copper)
	else
		copperText = ""
	end
	
	if silver > 0 then
		silverText = " "..format(SILVER_AMOUNT_TEXTURE, silver)
	else
		silverText = ""
	end
	
	if gold >= 1000000 then
		string = format("%.2f", gold/1000000)..SECOND_NUMBER_CAP.."|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:2:0|t"
	elseif gold >= 10000 then
		string = format(GOLD_AMOUNT_TEXTURE_STRING, BreakUpLargeNumbers(gold))
	elseif gold >= 100 then
		string = goldText..silverText
	elseif gold > 0 then
		string = goldText..silverText..copperText
	elseif silver > 0 then
		string = silverText..copperText
	else
		string = copperText
	end
	
	if money == 0 then
		string = format(COPPER_AMOUNT_TEXTURE, 0)
	end
	
	return string
end

local function SortMoney(a,b)
	if a["Gold"] and b["Gold"] then
		return a["Gold"] > b["Gold"] 
	else
		return false
	end
end

local function Money_ForceUpdate(update)
	if not init or update then
		local server = GetRealmName()
		local dataBase = GetBrokerDataBase(server)
		local name = UnitName( "player")
		local class = select(2, UnitClass( "player"))
		local guid = UnitGUID( "player")
		local entry;
		
		-- first login
		if not update then
			session = GetMoney()
			init = true
		end	
		
		-- set entry
		for index, info in pairs(dataBase) do
			if info and info["GUID"] == guid then
				entry = index
				break
			end
		end
		
		-- save money value
		if entry then
			dataBase[entry]["Gold"] = GetMoney()
		else
			local info = {}
			info.Name = name
			info.Server = server
			info.Class = class
			info.Gold = GetMoney()
			info.GUID = guid
			tinsert(dataBase, info)
		end
	end
end

local function Money_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	
	Money_ForceUpdate(true)
	
	-- All Servers
	if self.isShift then
		local dataBase = SyncUI_Data["Broker"]["CharInfo"]
		local total = 0
		
		GameTooltip:AddLine(SYNCUI_STRING_ALL_REALMS,1,1,1)
		GameTooltip:SetPrevLineJustify("CENTER")
		GameTooltip:AddDivider()
		
		for serverName, serverInfo in pairs(dataBase) do
			local totalPerServer = 0
			
			for _, charInfo in pairs(serverInfo) do
				totalPerServer = totalPerServer + charInfo["Gold"]
			end
			
			if totalPerServer > 0 then
				total = total + totalPerServer
				
				GameTooltip:AddDoubleLine(serverName, GetMoneyString(totalPerServer),1,1,1,1,1,1)
			end
		end
		
		GameTooltip:AddDivider()
		GameTooltip:AddDoubleLine(TOTAL..":", GetMoneyString(total),1,1,1,1,1,1)
	end
	
	-- Actual Server + Connected
	if not self.isShift then
		local serverName, realmlist = GetRealmName(), GetAutoCompleteRealms()
		local difference = GetMoney() - session
		local total, numInfo = 0, 0
		local waitForInfo

		table.sort(GetBrokerDataBase(serverName), SortMoney)

		-- Display all connected realms
		if realmlist then	
			local header
			
			for _, realm in pairs(realmlist) do
				local dataBase = GetBrokerDataBase(realm)

				if dataBase then
					if not header then
						GameTooltip:AddLine(serverName,1,1,1)
						GameTooltip:SetPrevLineJustify("CENTER")
						GameTooltip:AddDivider()
						header = true
					end
				
					for _, info in pairs(dataBase) do
						local name, class, gold = info.Name, info.Class, info.Gold
						
						if gold > 0 then
							if name then
								local color = SYNCUI_CLASS_COLORS[class]
								local r,g,b = color.r, color.g, color.b
								local path = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
								local left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[class])
								local classIcon
								
								if left and right and top and bottom then
									local inset = 5
									
									left, right, top, bottom = (left*256+inset),(right*256-inset),(top*256+inset),(bottom*256-inset)
									classIcon = "|T"..path..":14:14:0:0:256:256:"..left..":"..right..":"..top..":"..bottom.."|t"
								end		
								
								if r and g and b then
									name = SyncUI_GetColorizedText(name,r,g,b)
								end
									
								if realm == serverName then
									-- display update fix
									if name == UnitName("player") then
										gold = GetMoney()
									end
									
									GameTooltip:AddDoubleLine(classIcon.." "..name, GetMoneyString(gold),1,1,1,1,1,1)
								else
									GameTooltip:AddDoubleLine(classIcon.." "..name.." - "..realm, GetMoneyString(gold),1,1,1,1,1,1)
								end
							else
								GameTooltip:AddDoubleLine(RETRIEVING_TRADESKILL_INFO.."...", GetMoneyString(gold),1,1,1,1,1,1)
								
								waitForInfo = true
							end

							numInfo = numInfo + 1
							total = total + gold
						end
					end
				end
			end
		end
		
		-- Display only the actual realm
		if not realmlist then	
			local dataBase = GetBrokerDataBase(serverName)
			
			GameTooltip:AddLine(serverName,1,1,1)
			GameTooltip:SetPrevLineJustify("CENTER")
			GameTooltip:AddDivider()
			
			for _, info in pairs(dataBase) do
				local name, class, gold = info.Name, info.Class, info.Gold

				if gold > 0 then
					if name then
						local color = SYNCUI_CLASS_COLORS[class]
						local r,g,b = color.r, color.g, color.b
						local path = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
						local left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[class])
						local classIcon
						
						if left and right and top and bottom then
							local inset = 5
							
							left, right, top, bottom = (left*256+inset),(right*256-inset),(top*256+inset),(bottom*256-inset)
							classIcon = "|T"..path..":14:14:0:0:256:256:"..left..":"..right..":"..top..":"..bottom.."|t"
						end		
						
						if r and g and b then
							name = SyncUI_GetColorizedText(name,r,g,b)
						end
						
						-- display update fix
						if name == UnitName("player") then
							gold = GetMoney()
						end
						
						GameTooltip:AddDoubleLine(classIcon.." "..name, GetMoneyString(gold),1,1,1,1,1,1)
					else
						GameTooltip:AddDoubleLine(RETRIEVING_TRADESKILL_INFO.."...", GetMoneyString(gold),1,1,1,1,1,1)
						
						waitForInfo = true
					end
				
					numInfo = numInfo + 1
					total = total + gold
				end
			end
		end
		
		-- Total money
		if numInfo > 1 and total > 0 then
			GameTooltip:AddDivider()
			GameTooltip:AddDoubleLine(TOTAL..":", GetMoneyString(total),1,1,1,1,1,1)
		end
		
		-- Money per session
		if difference ~= 0 then
			local pre,r,g,b
			
			if difference < 0 then
				difference = difference - difference * 2
				
				pre,r,g,b = "- ", 1,0,0
			elseif difference > 0 then
				pre,r,g,b = "+ ", 0,1,0
			end
			
			GameTooltip:AddDivider()
			GameTooltip:AddDoubleLine(SYNCUI_STRING_SESSION,pre..GetMoneyString(difference),1,1,1,r,g,b)
		end

		if waitForInfo then
			C_Timer.After(0.1, function()
				if GetMouseFocus() == self then
					Money_OnEnter(self)
				end
			end)
		end
	end

	GameTooltip:AddDivider()
	GameTooltip:AddLine(SYNCUI_STRING_SWITCH_DISPLAY,1,1,1)	
	GameTooltip:Show()
end

local function Money_OnClick(self)
	if self.isShift then
		self.isShift = false
	else
		self.isShift = true
	end
	
	GameTooltip_Hide()
	Money_OnEnter(self)
end

local function Money_OnUpdate(self)
	self:SetText(GetMoneyString(GetMoney()))
end

do	-- Initialize
	local info = {}

	info.title = MONEY
	info.icon = "Interface\\Icons\\inv_misc_coin_01"
	info.clickFunc = Money_OnClick
	info.initFunc = Money_ForceUpdate
	info.updateFunc = Money_OnUpdate
	info.tooltipFunc = Money_OnEnter
	
	SyncUI_RegisterBrokerType("Money", info)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGOUT")
f:SetScript("OnEvent", function(self, event, ...)
	Money_ForceUpdate(true)
end)