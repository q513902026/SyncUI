local classIcon = 645226
 
local function HoA_OnClick(self)
	if not C_AzeriteEssence.CanOpenUI() then
		return;
	end
	
	LoadAddOn("Blizzard_AzeriteEssenceUI");

	if AzeriteEssenceUI:IsShown() then
		HideUIPanel(AzeriteEssenceUI);
	elseif not AzeriteEssenceUI:IsShown() and not InCombatLockdown() then
		ShowUIPanel(AzeriteEssenceUI);
	end
	
	if InCombatLockdown() then
		UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_IN_COMBAT);
	end
end
 
local function HoA_OnUpdate(self)
    if C_AzeriteEssence.CanOpenUI() then
        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
        local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local perc = math.ceil(xp*100/totalLevelXP)

        self:SetText(perc.."%".." ("..totalLevelXP-xp..")")
    else
        self:SetText(ITEM_QUALITY6_DESC)
    end
end
 
local function HoA_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")

    if C_AzeriteEssence.CanOpenUI() then
        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
        local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
        local name = 'Hearth of Azeroth'
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local tier = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
 
		GameTooltip:AddLine(name, r,g,b, false)
		GameTooltip:AddDivider()
		GameTooltip:AddLine(AZERITE_POWER_TOOLTIP_TITLE:format(tier, totalLevelXP-xp), HIGHLIGHT_FONT_COLOR:GetRGB());
    else
		GameTooltip:SetText(HEART_OF_AZEROTH_MISSING_ERROR, 1,1,1);
	end
	
    GameTooltip:Show()
end
 
do  -- Initialize
    local info = {}
 
    info.title = ITEM_QUALITY6_DESC
    info.icon = "Interface\\Icons\\Inv_heartofazeroth"
    info.clickFunc = HoA_OnClick
    info.updateFunc = HoA_OnUpdate
    info.tooltipFunc = HoA_OnEnter
    
    SyncUI_RegisterBrokerType("Hearth of Azeroth", info)
end