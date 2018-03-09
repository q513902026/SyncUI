
local function Social_OnClick(self)
	ToggleFriendsFrame(1)
end

local function Social_OnUpdate(self)
	local numBNetOnline = select(2, BNGetNumFriends())
	local numWoWOnline = select(2, GetNumFriends())
	
	self:SetText(FRIENDS..": "..numBNetOnline + numWoWOnline)
end

local function Social_OnEnter(self)
	local found, bnetFound

	ShowFriends()
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	--GameTooltip:SetPadding(-3)
	
	-- BNet-Friend-List
	if BNConnected() then
		for i = 1, BNGetNumFriends() do
			local isOnline = select(8, BNGetFriendInfo(i))

			if isOnline then
				local battleTag = select(2, BNGetFriendInfo(i))
				local client = select(7, BNGetFriendInfo(i))
				local isAFK = select(10, BNGetFriendInfo(i))
				local isDND = select(11, BNGetFriendInfo(i))
				local BNetName = battleTag
				local info, status
				local clientIcon = " |T"..BNet_GetClientTexture(client)..":14:14:0:0:64:64:10:54:10:54|t "
				local numGameAccounts = BNGetNumFriendGameAccounts(i)

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
						local name = select(2, BNGetFriendGameAccountInfo(i,index))
						local zone = select(10, BNGetFriendGameAccountInfo(i,index))
						local gameText = select(12, BNGetFriendGameAccountInfo(i,index))
						local class = select(8, BNGetFriendGameAccountInfo(i,index))

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
	for i = 1, GetNumFriends() do
		local name = GetFriendInfo(i)
		local class, area, isOnline, status = select(3, GetFriendInfo(i))

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