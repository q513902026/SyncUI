
local Unlocks = {
	["DEFAULT"] = {15,30,45,60,75,90,100},
	["DEATHKNIGHT"] = {56,57,58,60,75,90,100},
	["DEMONHUNTER"] = {99,100,102,104,106,108,110}
}

local function GetUnlockLevel(talentRow)
	local class = select(2, UnitClass("player"))
	local info = Unlocks[class] or Unlocks["DEFAULT"]

	return info[talentRow]
end

local function OverrideTalentKeyBind()
	local key = GetBindingKey("TOGGLETALENTS")

	if key then
		SetOverrideBindingClick(TalentMicroButton, true, key, "SyncUI_TalentMicroButton", "LeftButton")
	else
		ClearOverrideBindings(TalentMicroButton)
	end
end

local function HandleChatLink(talentName, talentLink)
	if MacroFrameText and MacroFrameText:HasFocus() then
		if UnitAffectingCombat("player") then
			UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1,0,0)
			return
		end
		
		local spellName, subSpellName = GetSpellInfo(talentName)
		if spellName and not IsPassiveSpell(spellName) then
			if subSpellName and (strlen(subSpellName) > 0) then
				ChatEdit_InsertLink(spellName.."("..subSpellName..")")
			else
				ChatEdit_InsertLink(spellName)
			end
		end
	elseif talentLink then
		ChatEdit_InsertLink(talentLink)
	end
end


function SyncUI_ToggleTalentUI()
	if SyncUI_TalentUI:IsShown() then
		HideUIPanel(SyncUI_TalentUI)
	else
		ShowUIPanel(SyncUI_TalentUI)
	end
end

function SyncUI_TalentUI_OnLoad(self)
	LoadAddOn("Blizzard_TalentUI")
	SyncUI_DisableFrame("PlayerTalentFrame")

	self:RegisterEvent("UPDATE_BINDINGS")
	
	UIPanelWindows[self:GetName()] = { area = "left", pushable = 1, whileDead = 1, width = 270, height = 353 }
	ShowUIPanel(self)
	
	OverrideTalentKeyBind()
end

function SyncUI_TalentUI_OnEvent(self,event,...)
	if InCombatLockdown() then return end
	
	if event == "UPDATE_BINDINGS" then
		OverrideTalentKeyBind()
	end
end

function SyncUI_TalentTabButton_OnLoad(self)
	local buttonID = self:GetID()
	local icon, text, refFrame

	if buttonID == 1 then
		self.text = TALENTS
		self.Icon:SetTexture([[Interface\Icons\ability_marksmanship]])
		self.Select:Show()
	end
	if buttonID == 2 then
		self.text = PVP_TALENTS
		self.Icon:SetTexture([[Interface\Icons\achievement_featsofstrength_gladiator_08]])
		self.Icon:SetDesaturated(true)
	end
	
	self:RegisterForClicks('LeftButtonUp')
	self:SetFrameRef("frame1", SyncUI_TalentUI.Talents)
	self:SetFrameRef("frame2", SyncUI_TalentUI.PvPTalents)
	self:SetAttribute("_onclick", [[
		local frame1 = self:GetFrameRef("frame1")
		local frame2 = self:GetFrameRef("frame2")
		local buttonID = self:GetID()
		
		
		if buttonID == 1 then
			frame1:Show()
			frame2:Hide()
		end
		if buttonID == 2 then
			frame1:Hide()
			frame2:Show()
		end
	]])
	self:HookScript("OnClick", function()
		for i = 1, 2 do
			local tab = self:GetParent()["Tab"..i]
			
			tab.Icon:SetDesaturated(true)
			tab.Select:Hide()
		end
		
		self.Icon:SetDesaturated(false)
		self.Select:Show()	
	end)
end

function SyncUI_TalentSpecFrame_OnLoad(self)
	local class = select(2, UnitClass("player"))
	local numSpecs = 3

	if class == "DRUID" then
		numSpecs = 4
	elseif class == "DEMONHUNTER" then
		numSpecs = 2
	end
	
	for i = 3, 4 do
		local button = self["Spec"..i]
		if i <= numSpecs then
			button:Show()
		end
	end
	
	self:SetSize(68, 38 * numSpecs + 30)
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
end


function SyncUI_AbilityFrame_Show(anchor)
	local frame = SyncUI_AbilityFrame

	for index = 1, 6 do
		local numSpells = #frame.spells
		local button = frame["Slot"..index]

		if index <= numSpells then
			local spellID = frame.spells[index]
			
			local icon = select(3, GetSpellInfo(spellID))
			
			button.Icon:SetTexture(icon)
			button:Show()
			button.spellID = spellID
		else
			button:Hide()
		end
	end
	
	frame:Hide()
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 15, 15)
	frame:Show()
end

function SyncUI_AbilityFrame_OnEvent(self, event, key, state)
	if not SyncUI_TalentUI:IsShown() then
		return
	end
	
	if key == "LSHIFT" or key == "RSHIFT" then
		if state == 1 then
			for i = 1, 3 do
				local button = SyncUI_TalentUI.PetSpecs["Slot"..i]
				
				if button and GetMouseFocus() == button then
					SyncUI_AbilityFrame_Show(button)
				end
			end
			for i = 1, 4 do
				local button = SyncUI_TalentUI.Specs["Spec"..i]
				
				if button and GetMouseFocus() == button then
					SyncUI_AbilityFrame_Show(button)
				end
			end
		else
			self:Hide()
		end
	end
end

function SyncUI_AbilityFrame_UpdateSize(self)
	if self.spells then
		local num = #self.spells
		local width, height = 38 * num + 30, 69
		
		self:SetSize(width, height)
	end
end


function SyncUI_SpecButton_OnClick(self)
	if UnitAffectingCombat("player") then
		UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
		return
	end
	
	local buttonID, isPet = self:GetID(), self.isPet
	local active = GetSpecializationInfo(GetSpecialization(nil, isPet), nil, isPet, nil, UnitSex("player"))
	local spec = GetSpecializationInfo(buttonID, nil, isPet, nil, UnitSex("player"))	
	
	if spec == active then
		return
	else
		SetSpecialization(buttonID, isPet)
	end
end

function SyncUI_SpecButton_Update(self)
	local buttonID, isPet = self:GetID(), self.isPet
	local active = GetSpecialization(nil, isPet)
	local icon = select(4, GetSpecializationInfo(buttonID, false, isPet, nil, UnitSex("player")))

	self.Icon:SetTexture(icon)

	if buttonID == active then
		self.Icon:SetDesaturated(false)
		self.Select:Show()
	else
		self.Icon:SetDesaturated(true)
		self.Select:Hide()
	end
end

function SyncUI_SpecButton_OnEnter(self)
	local buttonID, isPet = self:GetID(), self.isPet
	local specID, name, text = GetSpecializationInfo(buttonID, false, isPet, nil, UnitSex("player"))
	local frame = SyncUI_AbilityFrame
	
	frame.spells = {}

	if isPet then
		for index, info in pairs({GetSpecializationSpells(buttonID, nil, isPet, true)}) do
			local isOdd = index % 2 ~= 0
			
			if isOdd then
				tinsert(frame.spells, info)
			end
		end
	else
		for index, info in pairs(SPEC_SPELLS_DISPLAY[specID]) do
			local isOdd = index % 2 ~= 0
			
			if isOdd then
				tinsert(frame.spells, info)
			end
		end
	end

	if IsShiftKeyDown() and not ChatFrame1EditBox:HasFocus() then
		SyncUI_AbilityFrame_Show(self)
	end

	-- Set Tooltip
	GameTooltip:SetOwner(SyncUI_TalentUI.Talents, "ANCHOR_RIGHT", 10, -19)
	GameTooltip:AddLine(name)
	GameTooltip:AddLine(text, 1 , 1, 1, true)
	GameTooltip:AddLine(SYNCUI_STRING_TALENT_SHOW_ABILITIES, 0.5, 0.5, 0.5)
	GameTooltip:Show()
end


function SyncUI_TalentButton_OnLoad(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local name = select(2, GetTalentInfo(tier, column, GetActiveSpecGroup()))
	local spellID = select(7, GetSpellInfo(name))
	
	self:RegisterForDrag("LeftButton")
	self:SetAttribute("spell", spellID)
	self:SetAttribute("_ondragstart", [[
		return "spell", self:GetAttribute("spell")
	]])
end

function SyncUI_TalentButton_OnClick(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local talent, name = GetTalentInfo(tier, column, GetActiveSpecGroup())
		
	if IsModifiedClick("CHATLINK") then
		local link = GetTalentLink(talent)
		
		HandleChatLink(name, link)
	else
		if UnitAffectingCombat("player") then
			UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1,0,0)
			return
		end		

		LearnTalents(talent)
	end
end

function SyncUI_TalentButton_OnUpdate(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local _, name, icon, selected = GetTalentInfo(tier, column, GetActiveSpecGroup())
	local level, unlock = UnitLevel("player"), GetUnlockLevel(tier)
	
	self.Icon:SetTexture(icon)

	if selected or level < unlock then
		self.Icon:SetDesaturated(false)
		self.Select:Show()
	else
		self.Icon:SetDesaturated(true)
		self.Select:Hide()
	end

	if level < unlock then
		self.Icon:SetDesaturated(true)
		self.Lock:Show()
		self.Select:Hide()
	else
		self.Lock:Hide()
	end
	
	-- Update Talent Spell Attribute
	if not InCombatLockdown() then
		local spellID = select(7, GetSpellInfo(name))
		local attribute = self:GetAttribute("spell")
		
		if attribute ~= spellID then
			self:SetAttribute("spell", spellID)
		end
	end
end

function SyncUI_TalentButton_OnEnter(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local talent = GetTalentInfo(tier, column, GetActiveSpecGroup())
	local level, unlockLvL = UnitLevel("player"), GetUnlockLevel(tier)
	
	GameTooltip:SetOwner(SyncUI_TalentUI.Talents, "ANCHOR_RIGHT",10,-19)
	GameTooltip:SetTalent(talent)

	if level < unlockLvL then
		local lastLine = _G["GameTooltipTextLeft"..GameTooltip:NumLines()]
		local text = format(SYNCUI_STRING_TALENT_AVAILABE, unlockLvL)
		
		lastLine:SetText(gsub(lastLine:GetText(), TALENT_TOOLTIP_ADDPREVIEWPOINT, text))
		lastLine:SetVertexColor(0.5,0.5,0.5)
	end
	
	GameTooltip:Show()
end


function SyncUI_PvPTalentButton_OnLoad(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local name = select(2, GetPvpTalentInfo(tier, column, GetActiveSpecGroup()))
	local spellID = select(7, GetSpellInfo(name))
	
	self:RegisterForDrag("LeftButton")
	self:SetAttribute("spell", spellID)
	self:SetAttribute("_ondragstart", [[
		return "spell", self:GetAttribute("spell");
	]])
	self:HookScript("OnDragStart", function()
		if not InCombatLockdown() then
			local talent = GetPvpTalentInfo(tier, column, GetActiveSpecGroup())
			PickupPvpTalent(talent);
		end
	end)
end

function SyncUI_PvPTalentButton_OnClick(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local talent, name = GetPvpTalentInfo(tier, column, GetActiveSpecGroup())
	
	if IsModifiedClick("CHATLINK") then
		local link = GetPvpTalentLink(talent)
		
		HandleChatLink(name, link)
	else
		if UnitAffectingCombat("player") then
			UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1,0,0)
			return
		end		

		LearnPvpTalent(talent)
	end	
end

function SyncUI_PvPTalentButton_OnUpdate(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local _, name, icon, selected, _, _, unlocked = GetPvpTalentInfo(tier, column, GetActiveSpecGroup())

	self.Icon:SetTexture(icon)

	if selected then
		self.Icon:SetDesaturated(false)
		self.Select:Show()
	else
		self.Icon:SetDesaturated(true)
		self.Select:Hide()
	end

	if not unlocked then
		self.Lock:Show()
		self.Select:Hide()
	else
		self.Lock:Hide()
	end

	-- Update Talent Spell Attribute
	if not InCombatLockdown() then
		local spellID = select(7, GetSpellInfo(name))
		local attribute = self:GetAttribute("spell")
		
		if attribute ~= spellID then
			self:SetAttribute("spell", spellID)
		end
	end	
end

function SyncUI_PvPTalentButton_OnEnter(self)
	local buttonID = self:GetID()
	local tier, column = math.ceil(buttonID/3), ((buttonID-1)%3+1)
	local talent = GetPvpTalentInfo(tier, column, GetActiveSpecGroup())
	
	GameTooltip:SetOwner(SyncUI_TalentUI.Talents, "ANCHOR_RIGHT", 10, -19)
	GameTooltip:SetPvpTalent(talent, nil, GetActiveSpecGroup())
	GameTooltip:Show()
end
