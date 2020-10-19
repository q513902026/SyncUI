
local function Social_OnClick(self)
	ToggleFriendsFrame(1)
end

local function Social_OnUpdate(self)
	local numBNetOnline = select(2, BNGetNumFriends())
	local numWoWOnline = C_FriendList.GetNumFriends()
	
	self:SetText(FRIENDS..": "..numBNetOnline + numWoWOnline)
end

local function Social_OnEnter(self)
	local found, bnetFound

	C_FriendList.ShowFriends()
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	--GameTooltip:SetPadding(-3)
	
	-- BNet-Friend-List
	if BNConnected() then
		for i = 1, BNGetNumFriends() do
			local bnFriendInfo = C_BattleNet.GetFriendAccountInfo(i);
			local isOnline = bnFriendInfo.gameAccountInfo.isOnline

			if isOnline then
				local battleTag = bnFriendInfo.battleTag
				local client = bnFriendInfo.gameAccountInfo.clientProgram ~= "" and bnFriendInfo.gameAccountInfo.clientProgram or nil
				local isAFK = bnFriendInfo.battleTag.isAFK
				local isDND = bnFriendInfo.battleTag.isDND
				local BNetName = battleTag
				local info, status
				local clientIcon = " |T"..BNet_GetClientTexture(client)..":14:14:0:0:64:64:10:54:10:54|t "
				local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(i)

				-- Add Header

				if not bnetFound then
					GameTooltip:AddLine(BATTLENET_OPTIONS_LABEL, 1,1,1)
					GameTooltip:SetPrevLineJustify("CENTER")
					GameTooltip:AddDivider()
					
					bnetFound = true
				end

				-- Get Status Type
				if isAFK then
					status = FRIENDS_TEXTURE_AFK
				elseif isDND then
					status = FRIENDS_TEXTURE_DND
				else
					status = FRIENDS_TEXTURE_ONLINE
				end
				
				-- Set Status Icon
				if status then
					status = "|T"..status..":14:14:|t "
				end

				-- Set Info
				if numGameAccounts > 0 then
					for index = 1, numGameAccounts do
						local bnInfo = C_BattleNet.GetFriendGameAccountInfo(i,index)
						local name = bnInfo.characterName or ""
						local zone = bnInfo.areaName or "";
						local gameText = bnInfo.richPresence or "";
						local class = bnInfo.className or "";
						
						if class and class ~= "" then
							class = SYNCUI_CLASS_STRINGS[class]
							name = SyncUI_GetColorizedText(name,unpack(SYNCUI_CLASS_COLORS[class]))
							BNetName = battleTag.." ("..name..")"
						end
						if client == "WoW" then
							if not info and zone and zone ~= "" then
								info = zone or ""
							end
						elseif client == "App" then
							info = "Battle.net"
						else
							info = gameText or ""
						end
					end

					if not info then
						info = ""
					end
				end

				GameTooltip:AddDoubleLine(status..BNetName,info..clientIcon,1,1,1,1,1,1)
			end
		end
	end
	
	-- Realm-Friend-List
	for i = 1, C_FriendList.GetNumFriends() do
		local name = C_FriendList.GetFriendInfo(i)
		local class, area, isOnline, status = select(3, C_FriendList.GetFriendInfo(i))

		if isOnline then
			local clientIcon = " |T"..BNet_GetClientTexture("WoW")..":14:14:0:0:64:64:10:54:10:54|t "

			-- Add Header
			if not found then
				if bnetFound then
					GameTooltip:AddLine(" ")
				end
				
				GameTooltip:AddLine(GetRealmName(), 1,1,1)
				GameTooltip:SetPrevLineJustify("CENTER")
				GameTooltip:AddDivider()
				found = true
			end

			-- Get Status Type
			if status == "" then
				status = FRIENDS_TEXTURE_ONLINE
			elseif status == CHAT_FLAG_AFK then
				status = FRIENDS_TEXTURE_AFK
			elseif status == CHAT_FLAG_DND then
				status = FRIENDS_TEXTURE_DND
			end
			
			-- Colorize Char Name
			if class and class ~= "" then
				class = SYNCUI_CLASS_STRINGS[class]
				name = SyncUI_GetColorizedText(name,unpack(SYNCUI_CLASS_COLORS[class]))
			end
			
			GameTooltip:AddDoubleLine("|T"..status..":14:14|t "..name,area..clientIcon,1,1,1,1,1,1)
		end
	end

	-- No Friends Found
	if not found and not bnetFound then
		GameTooltip:AddLine(SYNCUI_STRING_NOT_ONLINE, 1,1,1, true)
	end
	
	GameTooltip:Show()
end

do	-- Initialize
	local info = {}
	
	info.title = FRIENDS
	info.icon = "Interface\\Icons\\achievement_guildperk_everybodysfriend"
	info.clickFunc = Social_OnClick
	info.updateFunc = Social_OnUpdate
	info.tooltipFunc = Social_OnEnter
	
	SyncUI_RegisterBrokerType("Friends", info)
end