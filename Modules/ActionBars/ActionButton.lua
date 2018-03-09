
local function GetHotKeyString(key)
	if key then
		key = key:upper()
		key = key:gsub(" ", "")
		key = key:gsub("ALT%-", "a-")
		key = key:gsub("CTRL%-", "c-")
		key = key:gsub("SHIFT%-", "s-")
		key = key:gsub("NUMPAD", "n-")

		for i = 1, 31 do
			key = key:gsub("BUTTON"..i, "m-"..i)
		end
		
		key = key:gsub("MOUSEWHEELDOWN", "mw-")
		key = key:gsub("MOUSEWHEELUP", "mw+")
		
		key = key:gsub("PLUS", "%+")
		key = key:gsub("MINUS", "%-")
		key = key:gsub("MULTIPLY", "%*")
		key = key:gsub("DIVIDE", "%/")
		key = key:gsub("NUMLOCK", "Num")
		key = key:gsub("TAB", "Tab")
		
		--[[
		key = key:gsub("BACKSPACE", "Backspace")
		key = key:gsub("CAPSLOCK", "Caps")
		key = key:gsub("CLEAR", "Cl")
		key = key:gsub("DELETE", "Del")
		key = key:gsub("END", "End")
		key = key:gsub("HOME", "Home")
		key = key:gsub("INSERT", "Ins")

		key = key:gsub("PAGEDOWN", "")
		key = key:gsub("PAGEUP", "")
		key = key:gsub("SCROLLLOCK", "")
		key = key:gsub("DOWNARROW", "Down")
		key = key:gsub("LEFTARROW", "Up")
		key = key:gsub("RIGHTARROW", "Left")
		key = key:gsub("UPARROW", "Right")
		--]]
		
		return key
	end
end

local function ClearButton(self)
	self.Icon:Hide()
	self.Checked:Hide()
	self.FlyoutArrow:Hide()
	self.cooldown:Clear()
	self.Count:SetText("")
	self.Name:SetText("")
	
	ActionButton_HideOverlayGlow(self)
end


local function UpdateIcon(self, action)
	local texture = GetActionTexture(action)

	self.Icon:SetTexture(texture)
	self.Icon:SetShown(texture)
end

local function UpdateUsable(self, action)
	local isUsable, notEnoughMana = IsUsableAction(action)
	local inRange = IsActionInRange(action)
	
	if isUsable then
		if inRange == false then
			self.Icon:SetVertexColor(1,0,0)
		else
			self.Icon:SetVertexColor(1,1,1)
		end		
	elseif notEnoughMana then
		self.Icon:SetVertexColor(0.5,0.5,1.0)
	else
		self.Icon:SetVertexColor(0.4,0.4,0.4)
	end	
end

local function UpdateState(self, action)
	self.Checked:SetShown(IsCurrentAction(action))
end

local function UpdateHotKey(self, action)
	local bar = self:GetParent()
	local barID = bar:GetAttribute("barID")
	local buttonType = bar:GetAttribute("buttonType")
	
	if not buttonType then
		if self.isStance then
			buttonType = "SHAPESHIFTBUTTON"
		else
			buttonType = "ACTIONBUTTON"
		end
	else
		if buttonType:find("MULTIACTIONBAR") then	-- Side Bar
			action = action - ((barID - 1) * NUM_ACTIONBAR_BUTTONS)
		end
		if buttonType == "VEHICLEACTIONBAR" then	-- Vehicle Bar
			buttonType = "ACTIONBUTTON"
			action = action - ((barID - 1) * NUM_ACTIONBAR_BUTTONS)
		end
	end

	local key = GetBindingKey(buttonType .. action)
	local text = GetHotKeyString(key)

	self.binding = buttonType .. action
	
	if text == "" then
		self.HotKey:Hide()
	else
		self.HotKey:SetText(text)
		self.HotKey:Show()
	end
end

local function UpdateCount(self, action)
	if IsConsumableAction(action) or IsStackableAction(action) or (not IsItemAction(action) and GetActionCount(action) > 0) then
		local count = GetActionCount(action)
		
		if count > 9999 then
			self.Count:SetText("*")
		else
			self.Count:SetText(count)
		end
	else
		local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(action)
		
		if maxCharges > 1 then
			self.Count:SetText(charges)
		else
			self.Count:SetText("")
		end
	end
end

local function UpdateMacroName(self, action)
	if not IsConsumableAction(action) and not IsStackableAction(action) and (IsItemAction(action) or GetActionCount(action) == 0) then
		self.Name:SetText(GetActionText(action))
	else
		self.Name:SetText("")
	end
end

local function UpdateRangeIndicator(self, action)
	local inRange = IsActionInRange(action)
	
	if inRange == false then
		self.HotKey:SetVertexColor(1.0, 0.1, 0.1)
	else
		self.HotKey:SetVertexColor(0.6, 0.6, 0.6)
	end
end

local function UpdateCooldown(self, action)
	if not action then return end
	
	local type, _, _,  spellID = GetActionInfo(action)
	local locStart, locDuration, start, duration, enable, charges, maxCharges, chargeStart, chargeDuration
	
	if type == "spell" and spellID then
		locStart, locDuration = GetSpellLossOfControlCooldown(spellID)
		start, duration, enable = GetSpellCooldown(spellID)
		charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
	elseif action then
		locStart, locDuration = GetActionLossOfControlCooldown(action)
		start, duration, enable = GetActionCooldown(action)
		charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(action)
	end

	if (locStart + locDuration) > (start + duration) then
		if self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_LOSS_OF_CONTROL then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge-LoC")
			self.cooldown:SetSwipeColor(0.17, 0, 0)
			self.cooldown:SetHideCountdownNumbers(true)
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_LOSS_OF_CONTROL
		end

		CooldownFrame_Set(self.cooldown, locStart, locDuration, true, true)
		ClearChargeCooldown(self)
	else
		if self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_NORMAL then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
			self.cooldown:SetSwipeColor(0, 0, 0)
			self.cooldown:SetHideCountdownNumbers(false)
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL
		end

		if locStart > 0 then
			self.cooldown:SetScript("OnCooldownDone", ActionButton_OnCooldownDone)
		end

		if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
			StartChargeCooldown(self, chargeStart, chargeDuration)
		else
			ClearChargeCooldown(self)
		end

		CooldownFrame_Set(self.cooldown, start, duration, enable)
	end
end

local function UpdateFlyout(self, action)
	local actionType = GetActionInfo(action)
	
	if actionType == "flyout" then
		local direction = self:GetAttribute("flyoutDirection")
		local arrowDistance
		
		if (SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self) or GetMouseFocus() == self then
			arrowDistance = 10
		else
			arrowDistance = 5
		end

		-- Update arrow
		self.FlyoutArrow:Show()
		self.FlyoutArrow:ClearAllPoints()
		self.FlyoutArrow:SetPoint("TOP", self, 0, arrowDistance)
	else
		self.FlyoutArrow:Hide()
	end
end

local function UpdateOverlayGlow(self, action)
	local spellType, index, subType  = GetActionInfo(action)
	
	if spellType == "spell" and IsSpellOverlayed(index) then
		ActionButton_ShowOverlayGlow(self)
	elseif spellType == "macro" then
		local _, _, spellID = GetMacroSpell(index)
		
		if spellID and IsSpellOverlayed(spellID) then
			ActionButton_ShowOverlayGlow(self)
		else
			ActionButton_HideOverlayGlow(self)
		end
	else
		ActionButton_HideOverlayGlow(self)
	end
end


function SyncUI_ActionBarButton_OnLoad(self)
	self:RegisterForClicks("AnyUp")
	self:RegisterForDrag("LeftButton")
	
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("UPDATE_BINDINGS")
	--self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	--self:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	
	self:SetAttribute("type", "action")
	self:SetAttribute("action", self:GetID())
	self:SetAttribute("buttonID", self:GetID())
	self:SetAttribute("_ondragstart", [[
		if IsModifiedClick("PICKUPACTION") then
			return "action", self:GetAttribute("action")
        end
	]])
	self:SetAttribute("_onreceivedrag", [[
		if (kind == "item") or (kind == "spell") or (kind == "macro") or (kind == "battlepet") or (kind == "mount")  or (kind == "flyout") then
			return "action", self:GetAttribute("action")
		end
	]])
	self:SetID(0);
	self.action = 0;	-- flyout fix
	
	SyncUI_Cooldown_OnRegister(self.cooldown)
end

function SyncUI_ActionBarButton_OnEvent(self, event, ...)
	local arg1 = ...
	local action = self:GetAttribute("buttonID") or self:GetAttribute("action")
	
	if event == "PLAYER_LOGIN" or event == "UPDATE_BINDINGS" then
		UpdateHotKey(self, action)
	end
	
	if event == "ACTIONBAR_UPDATE_COOLDOWN" or "ACTIONBAR_PAGE_CHANGED" then
		UpdateCooldown(self, self:GetAttribute("action"))
	end
end

function SyncUI_ActionBarButton_OnUpdate(self, elapsed)
	local action = self:GetAttribute("action")
	
	if HasAction(action) then
		UpdateIcon(self, action)
		UpdateUsable(self, action)
		UpdateState(self, action)
		UpdateCount(self, action)
		UpdateMacroName(self, action)
		UpdateRangeIndicator(self, action)
		UpdateFlyout(self, action)
		UpdateOverlayGlow(self, action)
		UpdateCooldown(self, action)
	else
		ClearButton(self)
	end	
end

function SyncUI_ActionBarButton_OnEnter(self)
	local action = self:GetAttribute("action")
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	if GameTooltip:SetAction(action) then
		self.UpdateTooltip = SyncUI_SecureActionButton_OnEnter
	else
		self.UpdateTooltip = nil
	end
	
	UpdateFlyout(self, action)
end

function SyncUI_ActionBarButton_OnLeave(self)
	local action = self:GetAttribute("action")
	
	GameTooltip_Hide()
	UpdateFlyout(self, action)
end
