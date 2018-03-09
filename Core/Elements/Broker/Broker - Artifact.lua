
LoadAddOn("Blizzard_ArtifactUI")

local classIcon = 645226

local function Artifact_OnClick(self)
	if HasArtifactEquipped() then
		local frame = ArtifactFrame
		local activeID = C_ArtifactUI.GetArtifactInfo()
		local equippedID = C_ArtifactUI.GetEquippedArtifactInfo()
		
		if frame:IsShown() and activeID == equippedID then
			HideUIPanel(frame)
		else
			SocketInventoryItem(16)
		end
	end
end

local function Artifact_OnUpdate(self)
	if HasArtifactEquipped() then
		local name, icon, totalExp, spent = select(3, C_ArtifactUI.GetEquippedArtifactInfo())
		local tier = select(13, C_ArtifactUI.GetEquippedArtifactInfo())
		local points, xp, xpMax = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(spent, totalExp, tier)
		local perc = math.ceil(xp*100/xpMax)
		
		self.Icon:SetTexture(icon)
		self:SetText(perc.."%")
	else
		self.Icon:SetTexture(classIcon)
		self:SetText(ITEM_QUALITY6_DESC)
	end
end

local function Artifact_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	
	if HasArtifactEquipped() then
		local name, icon, totalExp, spent = select(3, C_ArtifactUI.GetEquippedArtifactInfo())
		local tier = select(13, C_ArtifactUI.GetEquippedArtifactInfo())
		local points, xp, xpMax = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(spent, totalExp, tier)

		GameTooltip:AddLine(name, r,g,b, false)
		GameTooltip:AddDivider()
		if points > 0 then
			GameTooltip:AddDoubleLine("Available Trait Points:", points, 1,1,1, 1,1,1)
		end
		
		GameTooltip:AddDoubleLine("Next Trait Point in:", xpMax-xp, 1,1,1, 1,1,1)
	else
		GameTooltip:AddLine(SPELL_FAILED_NO_ARTIFACT_EQUIPPED, 1,1,1)
	end
	
	GameTooltip:Show()
end

do	-- Initialize
	local info = {}

	info.title = ITEM_QUALITY6_DESC
	info.icon = classIcon
	info.clickFunc = Artifact_OnClick
	info.updateFunc = Artifact_OnUpdate
	info.tooltipFunc = Artifact_OnEnter
	
	SyncUI_RegisterBrokerType("Artifact", info)
end
