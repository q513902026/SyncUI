
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
	if self.action then
		self.Icon:Hide()
		self.Checked:Hide()
		self.Count:SetText("")
		self.Name:SetText("")
		self.cooldown:Hide()
		self.action = nil
		AutoCastShine_AutoCastStop(self.Shine)
	end
end

local function UpdateIcon(self, action)
	local name, icon, isToken = GetPetActionInfo(action)
	
	if isToken then
		texture = _G[icon]
	else
		texture = icon
	end
	
	self.Icon:SetTexture(texture)
	self.Icon:SetShown(texture)
end

local function UpdateUsable(self, action)
	if GetPetActionSlotUsable(action) then
		if self:IsEnabled() then
			self.Icon:SetVertexColor(1, 1, 1)
		else
			self.Icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	else
		self.Icon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

local function UpdateState(self, action)
	local isActive, autoCastAllowed, autoCastEnabled = select(4, GetPetActionInfo(action))
	
	self.Checked:SetShown(isActive or autoCastAllowed)

	if autoCastAllowed then
		self.Checked:SetVertexColor(1, 0.8, 0)
	else
		self.Checked:SetVertexColor(1,1,1)
	end

	if autoCastEnabled then
		AutoCastShine_AutoCastStart(self.Shine)
    else
		AutoCastShine_AutoCastStop(self.Shine)
    end
end

local function UpdateHotKey(self, action)
	local buttonType = "BONUSACTIONBUTTON"
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

local function UpdateCooldown(self, action)
	local start, duration, enable = GetPetActionCooldown(action)

	CooldownFrame_Set(self.cooldown, start, duration, enable)
end


function SyncUI_PetActionBarButton_OnLoad(self)
	self:RegisterForClicks("AnyUp")
	self:RegisterForDrag("LeftButton")
	
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("UPDATE_BINDINGS")
	
	self:SetAttribute("type1", "pet")
	self:SetAttribute("action", self:GetID())
	self:SetAttribute("type2", "click")
	self:SetAttribute("clickbutton2", _G["PetActionButton"..self:GetID()])
	self:SetAttribute("_ondragstart", [[
		if IsModifiedClick("PICKUPACTION") then
			return "petaction", self:GetAttribute("action")
        end
	]])
	self:SetAttribute("_onreceivedrag", [[
		return "petaction", self:GetAttribute("action")
	]])
	self:SetAttribute("_onstate-mount", [[
		if newstate == 1 then
			self:Disable()
		else
			self:Enable()
		end
	]])

	RegisterStateDriver(self, "mount", "[mounted] 1; 0")
	SyncUI_Cooldown_OnRegister(self.cooldown)
end

function SyncUI_PetActionBarButton_OnEvent(self, event, ...)
	local arg1 = ...
	local action = self:GetAttribute("action")
	
	if event == "UPDATE_BINDINGS" or event == "PLAYER_LOGIN" then
		UpdateHotKey(self, action)
	end
end

function SyncUI_PetActionBarButton_OnUpdate(self, elapsed)
	local action = self:GetAttribute("action")
	local name = GetPetActionInfo(action)
	
	if name then
		self.action = true
		UpdateIcon(self, action)
		UpdateUsable(self, action)
		UpdateState(self, action)
		UpdateCooldown(self, action)
	else
		ClearButton(self)
	end
end

function SyncUI_PetActionBarButton_OnEnter(self)
	local action = self:GetAttribute("action")
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	if GameTooltip:SetPetAction(action) then
		self.UpdateTooltip = SyncUI_SecureActionButton_OnEnter
	else
		self.UpdateTooltip = nil
	end
end

function SyncUI_PetActionBarButton_OnLeave(self)
	GameTooltip_Hide()
end
