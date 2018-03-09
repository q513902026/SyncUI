
local function Guild_OnClick(self)
	if IsInGuild() then
		GuildFrame_LoadUI()
		
		if GuildFrame_Toggle then
			GuildFrame_Toggle()
		end
	else
		ToggleGuildFinder()
	end
end

local function Guild_OnUpdate(self)
	if IsInGuild() then
		self:SetText(GUILD..": "..select(3, GetNumGuildMembers()))
	else
		self:SetText(LOOKINGFORGUILD)
	end
end

local function Guild_OnEnter(self)
	if not IsInGuild() then
		return
	end
	
	local guildName = GetGuildInfo("player")
	local numMembers,_,numOnline = GetNumGuildMembers()
	local MotD = GetGuildRosterMOTD()

	GuildRoster()

	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(GUILD_MOTD_LABEL..":",0,0.6,1)
	GameTooltip:AddLine(MotD,1,1,1,true)
	GameTooltip:AddDivider()
	
	for index = 1, numMembers do
		local member = select(1, GetGuildRosterInfo(index))
		local zone = select(6, GetGuildRosterInfo(index))
		local isOnline,status,class = select(9, GetGuildRosterInfo(index))
		local isMobile = select(14, GetGuildRosterInfo(index))

		if member and (isOnline or isMobile) then
			member = gsub(member,"-"..GetRealmName(),"")

			if class and class ~= "" then
				class = gsub(class," ","")
				class = string.upper(class)

				member = SyncUI_GetColorizedText(member,unpack(SYNCUI_CLASS_COLORS[class]))
			end
			
			if member:find(UnitName("player")) then
				isMobile = false
			end
			
			if isMobile then
				zone = "Remote Chat" 
				member = member.." |TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:14:14:0:0:64:64:0:64:0:58|t"
			end
			
			if status == 1 then
				status = FRIENDS_TEXTURE_AFK
			elseif status == 2 then
				status = FRIENDS_TEXTURE_DND
			else
				status = FRIENDS_TEXTURE_ONLINE
			end

			GameTooltip:AddDoubleLine("|T"..status..":14:14|t "..member,zone,1,1,1,1,1,1)
		end
	end

	GameTooltip:Show()
end

do	-- Initialize
	local info = {}

	info.title = GUILD
	info.icon = "Interface\\Icons\\inv_shirt_guildtabard_01"
	info.clickFunc = Guild_OnClick
	info.updateFunc = Guild_OnUpdate
	info.tooltipFunc = Guild_OnEnter
	
	SyncUI_RegisterBrokerType("Guild", info)
end