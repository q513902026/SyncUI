
local tinsert, tremove, profileQuery = table.insert, table.remove, nil
local charKey = UnitName("player").." - "..GetRealmName()
local newProfile = {
	["Options"] = {
		["Appearance"] = {
			["ColorMode"] = "classcolor",
			["DisplayMode"] = "pulse",
			["Custom"] = {1,1,1},
			["UsedFont"] = 4,
		},
		["Auras"] = {},
		["UnitFrames"] = {
			["GroupSortMethod"] = "group",
		},
		["Quests"] = {},
		["Misc"] = {},
	},
	["GroupControl"] = {
		["Layout"] = "Normal",
	},
	["FramePos"] = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	},
	["ReactiveAuras"] = {},
}

-------------
-- General --
-------------
local function GetStringByMethod(method)
	local string
	
	-- color modes
	if method == "classcolor" then
		string = CLASS_COLORS
	end
	if method == "rainbow" then
		string = SYNCUI_STRING_APPEARANCE_RAINBOW
	end
	if method == "custom" then
		string = CUSTOM
	end
	
	-- display modes
	if method == "pulse" then
		string = SYNCUI_STRING_APPEARANCE_PULSE
	end
	if method == "solid" then
		string = SYNCUI_STRING_APPEARANCE_SOLID
	end

	-- unitframe sort methods
	if method == "group" then
		string = GROUP
	end
	if method == "class" then
		string = CLASS
	end
	if method == "role" then
		string = ROLE
	end

	return string
end

local function LoadDefaultOptions()
	SyncUI_Data = {
		["Profiles"] = {
			["Default"] = newProfile,
		},
		["Keys"] = {
			[charKey] = "Default",
		},
		["Broker"] = {
			["CharInfo"] = {},
		},
		["Bags"] = {
			["ItemList"] = {},
			["ContainerList"] = {},
		},
		["UIScale"] = 1,
	}
end

local function LoadPerCharOptions()
	if not SyncUI_CharData then
		SyncUI_CharData = {}
	end
	
	local dataBase = SyncUI_CharData
	if dataBase.MultiBarToggle then
		SyncUI_MultiBar:Show()
		SyncUI_MultiBarToggle:SetNormalTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Down]])
		SyncUI_MultiBarToggle:SetPushedTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Down]])
		SyncUI_MultiBarToggle:SetPoint("BOTTOM", SyncUI_MultiBar, "TOP", 0, -6)
	end
	if dataBase.SideBarToggle then
		SyncUI_SideBar:Hide()
		SyncUI_SideBarToggle:SetNormalTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Up]])
		SyncUI_SideBarToggle:SetPushedTexture(SYNCUI_MEDIA_PATH..[[ActionBars\MicroMenu-HoverButton-Up]])
	end
	if dataBase.ChatToggle then
		SyncUI_ChatToggle:Click()
	end
	if dataBase.MinimapButtonToggle then
		SyncUI_Minimap.Cluster.Switch:Click()
	end
end

local function LoadSavedOptions()
	local dataBase = SyncUI_Data
	local key = dataBase["Keys"][charKey] or "Default"
	local profile = dataBase["Profiles"][key]
	
	if profile.Options.Appearance then
		if profile.Options.Appearance.ColorMode then
			local type = profile.Options.Appearance.ColorMode
			local method = profile.Options.Appearance.DisplayMode or "pulse"
			local text = GetStringByMethod(type)
			
			if type == "classcolor" then
				SyncUI_FrameGlow_SetColor()
			end
			if type == "rainbow" then
				SyncUI_FrameGlow_SetMode(method, true)
			end
			if type == "custom" then
				local r,g,b = unpack(profile.Options.Appearance.Custom)
				SyncUI_FrameGlow_SetColor(r,g,b)
			end

			SyncUI_OptionPanel_Appearance.ColorMode.DropDown:SetText(text)
		end
		if profile.Options.Appearance.DisplayMode then
			local method = profile.Options.Appearance.DisplayMode
			local useRainbow = profile.Options.Appearance.ColorMode == "rainbow"
			local text = GetStringByMethod(method)
			
			SyncUI_FrameGlow_SetMode(method, useRainbow)
			SyncUI_OptionPanel_Appearance.DisplayMode.DropDown:SetText(text)
		end
		if profile.Options.Appearance.UsedFont then
			SyncUI_SetUIFont()
		end
	end
	if profile.Options.Auras then
		if profile.Options.Auras.DurationTimer then
			SyncUI_OptionPanel_Aura.General.DurationTimer:SetChecked(true)
		else
			SyncUI_OptionPanel_Aura.General.DurationTimer:SetChecked(false)
			SyncUI_OptionPanel_Aura.General.DurationColor:SetEnabled(false)
			SyncUI_OptionPanel_Aura.General.DurationSpiral:SetEnabled(false)
		end
		if profile.Options.Auras.DurationColor then
			SyncUI_OptionPanel_Aura.General.DurationColor:SetChecked(true)
		else
			SyncUI_OptionPanel_Aura.General.DurationColor:SetChecked(false)
		end
		if profile.Options.Auras.DurationSpiral then
			SyncUI_OptionPanel_Aura.General.DurationSpiral:SetChecked(true)
		else
			SyncUI_OptionPanel_Aura.General.DurationSpiral:SetChecked(false)
		end
		if profile.Options.Auras.DebuffFilter then
			SyncUI_OptionPanel_Aura.General.DebuffFilter:SetChecked(true)
		else
			SyncUI_OptionPanel_Aura.General.DebuffFilter:SetChecked(false)
		end
	else
		profile.Options.Auras = {}
	end
	if profile.Options.UnitFrames then
		if profile.Options.UnitFrames.DefaultRaid then
			SyncUI_OptionPanel_UnitFrames.DefaultRaid:SetChecked(true)
		else
			SyncUI_OptionPanel_UnitFrames.DefaultRaid:SetChecked(false)
		end
		if profile.Options.UnitFrames.GroupSortMethod then
			SyncUI_OptionPanel_UnitFrames_SelectSortMethod(profile.Options.UnitFrames.GroupSortMethod)
		else
			SyncUI_OptionPanel_UnitFrames_SelectSortMethod("group")
		end	
	end
	if profile.Options.Quests then
		if profile.Options.Quests.Accept then
			SyncUI_OptionPanel_Quest.Accept:SetChecked(true)
		else
			SyncUI_OptionPanel_Quest.Accept:SetChecked(false)
			SyncUI_OptionPanel_Quest.Daily:SetEnabled(false)
		end
		if profile.Options.Quests.Daily then
			SyncUI_OptionPanel_Quest.Daily:SetChecked(true)
		else
			SyncUI_OptionPanel_Quest.Daily:SetChecked(false)
		end
		if profile.Options.Quests.TurnIn then
			SyncUI_OptionPanel_Quest.TurnIn:SetChecked(true)
		else
			SyncUI_OptionPanel_Quest.TurnIn:SetChecked(false)
		end
		if profile.Options.Quests.Share then
			SyncUI_OptionPanel_Quest.Share:SetChecked(true)
		else
			SyncUI_OptionPanel_Quest.Share:SetChecked(false)
		end
		if profile.Options.Quests.DisableTracker then
			SyncUI_OptionPanel_Quest.DisableTracker:SetChecked(true)
		else
			SyncUI_OptionPanel_Quest.DisableTracker:SetChecked(false)
		end
	else
		profile.Options.Quests = {}
	end
	if profile.Options.Misc then
		if profile.Options.Misc.SkipCinematics then
			SyncUI_OptionPanel_Misc.SkipCinematics:SetChecked(true)
		else
			SyncUI_OptionPanel_Misc.SkipCinematics:SetChecked(false)
		end
		if profile.Options.Misc.DisableAFK then
			SyncUI_OptionPanel_Misc.DisableAFK:SetChecked(true)
		else
			SyncUI_OptionPanel_Misc.DisableAFK:SetChecked(false)
		end
		if profile.Options.Misc.AutoSellJunk then
			SyncUI_OptionPanel_Misc.AutoSellJunk:SetChecked(true)
		else
			SyncUI_OptionPanel_Misc.AutoSellJunk:SetChecked(false)
		end
		if profile.Options.Misc.AutoRepair then
			SyncUI_OptionPanel_Misc.AutoRepair:SetChecked(true)
		else
			SyncUI_OptionPanel_Misc.AutoRepair:SetChecked(false)
			SyncUI_OptionPanel_Misc.UseGuildRepair:SetEnabled(false)
		end
		if profile.Options.Misc.UseGuildRepair then
			SyncUI_OptionPanel_Misc.UseGuildRepair:SetChecked(true)
		else
			SyncUI_OptionPanel_Misc.UseGuildRepair:SetChecked(false)
		end
	else
		profile.Options.Misc = {}
	end

	if profile.GroupControl then
		if profile.GroupControl.Layout then
			if profile.GroupControl.Layout == "Heal" then
				SyncUI_PartyFrameContainer.Heal:Show()
				SyncUI_RaidFrameContainer.Heal:Show()
				SyncUI_PartyFrameContainer.Normal:Hide()
				SyncUI_RaidFrameContainer.Normal:Hide()
				SyncUI_GroupControl.GroupLayout:SetText(SYNCUI_STRING_GROUP_CONTROL_LAYOUT_HEAL)
			end
			if profile.GroupControl.Layout == "Normal" then
				SyncUI_PartyFrameContainer.Normal:Show()
				SyncUI_RaidFrameContainer.Normal:Show()
				SyncUI_PartyFrameContainer.Heal:Hide()
				SyncUI_RaidFrameContainer.Heal:Hide()
				SyncUI_GroupControl.GroupLayout:SetText(SYNCUI_STRING_GROUP_CONTROL_LAYOUT_NORMAL)
			end
		end
		if profile.GroupControl.Toggle then
			SyncUI_RaidFrameContainer:Hide()
			SyncUI_GroupControl.Toggle:SetChecked(true)
		end
	end
	if profile.SideBarToggle then
		SyncUI_SideBar:Hide()
		SyncUI_ActionBar.SideBarToggle:SetButtonState("Normal")
	end
	
	if dataBase.UIScale then
		local value = SYNCUI_UISCALES[dataBase.UIScale]

		SyncUI_SetFrameScale(SyncUI_UIParent, tonumber(value))
		SyncUI_OptionPanel_Appearance.UIScale.DropDown:SetText(value)
	end

	LoadPerCharOptions()
	
	SyncUI_OptionPanel_Profiles.Selection.DropDown:SetText(key)
end

function SyncUI_GetProfile()
	local profile = SyncUI_Data["Keys"][charKey] or "Default"
	
	return SyncUI_Data["Profiles"][profile]
end

function SyncUI_CreateProfile()
	local input = SyncUI_OptionPanel_Profiles.Creation.EnterName
	local name = input:GetText()
										
	if name and name ~= "" and not SyncUI_Data["Profiles"][name] then
		SyncUI_Data["Profiles"][name] = newProfile
		SyncUI_Data.Keys[charKey] = name
		LoadSavedOptions()
		input:ClearFocus()
	end	
end

function SyncUI_OptionsMenu_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	GameMenuFrame:SetAlpha(0)
	GameMenuFrame:EnableMouse(false)
	GameMenuFrame:SetFrameStrata("BACKGROUND")
	GameMenuFrame:HookScript("OnShow",function()
		self.SlideIn:Play()
	end)
	GameMenuFrame:HookScript("OnHide",function()
		self.SlideOut:Play()
	end)

	for _, child in pairs({GameMenuFrame:GetChildren()}) do
		local btn = _G[child:GetName()];
		
		btn:EnableMouse(false)
		btn.Left:Hide();
		btn.Right:Hide();
		btn.Middle:Hide();
	end
	
	local backdrop = {
		bgFile = [[Interface\AddOns\SyncUI\Media\Textures\Backdrops\Backdrop-BgFile]],
		edgeFile = [[Interface\AddOns\SyncUI\Media\Textures\Backdrops\Backdrop-EdgeFile]],
		edgeSize = 16,
		insets = { left = 7, right = 7, top = 7, bottom = 7},
		tile = false,
		tileSize = 0,		
	}
	
	-- post 7.3.1 hotfix
	GameMenuButtonLogout:SetSize(150,35);
	GameMenuButtonLogout:SetParent(self.BlizzMenu);
	GameMenuButtonLogout:ClearAllPoints();
	GameMenuButtonLogout:SetPoint("TOP", self.BlizzMenu.Addons, "BOTTOM");
	GameMenuButtonLogout.SetPoint = function() end;
	GameMenuButtonLogout:SetBackdrop(backdrop);
	GameMenuButtonLogout:SetHitRectInsets(5,5,5,5);
	GameMenuButtonLogout:EnableMouse(true);
	
	GameMenuButtonQuit:SetSize(150,35);
	GameMenuButtonQuit:SetParent(self.BlizzMenu);
	GameMenuButtonQuit:ClearAllPoints();
	GameMenuButtonQuit:SetPoint("TOP", GameMenuButtonLogout, "BOTTOM", 0, 10);
	GameMenuButtonQuit:SetBackdrop(backdrop);
	GameMenuButtonQuit:SetHitRectInsets(5,5,5,5);
	GameMenuButtonQuit:EnableMouse(true);
	
	
	
	tinsert(UISpecialFrames, "AddonList")
end

function SyncUI_OptionsMenu_OnEvent(self, event, addOn)
	if event == "ADDON_LOADED" and addOn == "SyncUI" then 
		if SyncUI_Data and SyncUI_Data.Profiles then
			LoadSavedOptions()
		else
			LoadDefaultOptions()
			LoadSavedOptions()
		end
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self.SyncMenu.PlacementTool:Enable()
		self.SyncMenu.Profiles:Enable()
	end
	
	if event == "PLAYER_REGEN_DISABLED" then
		self.SyncMenu.PlacementTool:Disable()
		self.SyncMenu.Profiles:Disable()
	end
end

function SyncUI_OptionPanelFrame_HidePanels()
	local children = {SyncUI_OptionPanelFrame:GetChildren()}
	
	for _, child in pairs(children) do
		child:Hide()
	end
end

function SyncUI_Installer_UpdateProgress(self,elapsed)
	if self.StartProgress then
		local barValue = self.LoadingBar.Progress:GetValue()
		
		self.update = self.update + elapsed

		while self.update > 0.3 do
			self.progress = self.progress + math.random(1,10)
			self.update = self.update - 0.3
		end

		SmoothBar(self.LoadingBar.Progress,self.progress)

		self.LoadingBar.Progress.Text:SetText(math.ceil(barValue).."%")

		if barValue >= 100 then
			self.StartProgress = false
			self.FinProgress = true
			self.LoadingBar.Despawn:Play()
			self:SetScript("OnUpdate",nil)
		end
	end
end

----------------
-- Appearance --
----------------
local colorModes, displayModes = {"classcolor", "rainbow", "custom"}, {"pulse", "solid"}

local function SetCustomColor(restore)
	local profile = SyncUI_GetProfile()
	local r,g,b
	
	if restore then
		r,g,b = unpack(restore)
	else
		r,g,b = ColorPickerFrame:GetColorRGB()
	end
	
	SyncUI_FrameGlow_SetColor(r,g,b)
	profile.Options.Appearance.Custom = {r,g,b}
end

function SyncUI_OptionPanel_Appearance_SetColorMode(method)
	local profile = SyncUI_GetProfile()
	local text = GetStringByMethod(method)
	
	if method == "rainbow" then
		SyncUI_FrameGlowUpdater.useRainbow = true
	else
		SyncUI_FrameGlowUpdater.useRainbow = false
		
		if method == "classcolor" then
			SyncUI_FrameGlow_SetColor()
		end
		if method == "custom" then
			local r,g,b = unpack(profile.Options.Appearance.Custom)
			
			SyncUI_ShowColorPicker(r,g,b, SetCustomColor)
		end
	end

	profile.Options.Appearance.ColorMode = method
	SyncUI_OptionPanel_Appearance.ColorMode.DropDown:SetText(text)
end

function SyncUI_OptionPanel_Appearance_ColorMode_InitDropDown(self)
	local profile = SyncUI_GetProfile()

	for i, method in ipairs(colorModes) do
		local info = {}
		info.text = GetStringByMethod(method)
		info.height = 20
		info.isList = true
		info.clickFunc = function()
			SyncUI_OptionPanel_Appearance_SetColorMode(method)
		end
		
		if method == profile.Options.Appearance.ColorMode then
			info.isChecked = true
		end
		
		SyncUI_DropDownMenu_AddButton(info)
	end
end

function SyncUI_OptionPanel_Appearance_SetDisplayMode(method)
	local profile = SyncUI_GetProfile()
	local text = GetStringByMethod(method)
	local isRainbow = profile.Options.Appearance.ColorMode == "rainbow"
	
	profile.Options.Appearance.DisplayMode = method
	SyncUI_OptionPanel_Appearance.DisplayMode.DropDown:SetText(text)
	SyncUI_FrameGlow_SetMode(method, isRainbow)
end

function SyncUI_OptionPanel_Appearance_DisplayMode_InitDropDown(self)
	local profile = SyncUI_GetProfile()
	
	for i, method in ipairs(displayModes) do
		local info = {}
		info.text = GetStringByMethod(method)
		info.height = 20
		info.isList = true
		info.clickFunc = function()
			SyncUI_OptionPanel_Appearance_SetDisplayMode(method)
		end
		
		if method == profile.Options.Appearance.DisplayMode then
			info.isChecked = true
		end
		
		SyncUI_DropDownMenu_AddButton(info)
	end
end

function SyncUI_OptionPanel_Appearance_Fonts_InitDropDown(self)
	local profile = SyncUI_GetProfile()
	
	for i, data in ipairs(SYNCUI_FONTLIST) do
		local font = select(1, unpack(data))
		local lang = select(7, unpack(data))
		
		if font then
			font = gsub(font,".otf","")
			font = gsub(font,".ttf","")
			
			if lang then
				font = font.." ("..lang..")"
			end
		end	
		
		local info = {}
		info.text = font
		info.height = 20
		info.isList = true
		info.clickFunc = function()
			profile.Options.Appearance.UsedFont = i
			SyncUI_SetUIFont()
		end
		
		if i == profile.Options.Appearance.UsedFont then
			info.isChecked = true
		end
		
		SyncUI_DropDownMenu_AddButton(info)
	end
end

function SyncUI_OptionPanel_Appearance_UIScale_InitDropDown(self)
	local dataBase = SyncUI_Data
	
	for i, value in ipairs(SYNCUI_UISCALES) do
		local info = {}
		info.text = (tonumber(value) and format("%.1f", value)) or value
		info.height = 20
		info.isList = true
		info.clickFunc = function()
			dataBase.UIScale = i
			SyncUI_SetFrameScale(SyncUI_UIParent, tonumber(value))
			SyncUI_UpdateBrokerVisibility()
			SyncUI_OptionPanel_Appearance.UIScale.DropDown:SetText(value)
		end
		
		if i == dataBase.UIScale then
			info.isChecked = true
		end
		
		SyncUI_DropDownMenu_AddButton(info)
	end
end

-----------
-- Auras --
-----------
local function SortAuras(a,b)
	local aName = GetSpellInfo(a)
	local bName = GetSpellInfo(b)
	
	if aName and bName then
		return aName < bName
	end
end

function SyncUI_OptionPanel_Aura_OnShow(self)
	local profile = SyncUI_GetProfile()
	local scrollFrame = self.ReactiveAuras.ScrollFrame
	local scrollBar = scrollFrame.ScrollBar
	
	table.sort(profile["ReactiveAuras"], SortAuras)
	
	scrollBar:SetValue(0)
	SyncUI_OptionPanel_ReactiveAura_UpdateScrollFrame(scrollFrame)
end

function SyncUI_OptionPanel_ReactiveAuraLine_OnDelete(self,button)
	local profile = SyncUI_GetProfile()
	local line = self:GetParent()
	local spellID = profile["ReactiveAuras"][line:GetID()]
	local scrollFrame = line:GetParent().ScrollFrame

	tremove(profile["ReactiveAuras"], line:GetID())
	scrollFrame.ScrollBar:SetValue(0)
	SyncUI_OptionPanel_ReactiveAura_UpdateScrollFrame(scrollFrame)
end

function SyncUI_OptionPanel_ReactiveAuraLine_Update(self)
	local profile = SyncUI_GetProfile()
	if not profile["ReactiveAuras"][self:GetID()] then self:Hide() return end

	local spellID = profile["ReactiveAuras"][self:GetID()]
	local name = select(1, GetSpellInfo(spellID))
	local icon = select(3, GetSpellInfo(spellID))

	if name then
		self.Icon:SetTexture(icon)
		self.Name:SetText(name)
	end
	
	if not self:IsShown() then self:Show() end
end

function SyncUI_OptionPanel_ReactiveAura_UpdateScrollFrame(self)
	local profile = SyncUI_GetProfile()
	local frame = SyncUI_OptionPanel_Aura.ReactiveAuras
	local offset = FauxScrollFrame_GetOffset(self)
	local maxLines = 7
	local size = #profile["ReactiveAuras"]
	
	SyncUI_ScrollFrame_Update(self, size, maxLines, 20)
	
	for i = 1, maxLines do
		local line = frame["Line"..i]
		local idx = offset + i

		line:SetID(idx)
		
		SyncUI_OptionPanel_ReactiveAuraLine_Update(line)
	end
end

function SyncUI_OptionPanel_ApplyReactiveAura(self)
	local profile = SyncUI_GetProfile()
	local editBox = self:GetParent().EnterID
	local text = editBox:GetText()
	local spellID = gsub(text,"%a+","")
	
	if spellID then
		local name, _, icon = GetSpellInfo(spellID)
		
		for _, spell in pairs(profile["ReactiveAuras"]) do
			if spell == spellID then
				editBox:SetText("")
			end
		end

		if name then
			local scrollFrame = self:GetParent().ScrollFrame

			tinsert(profile["ReactiveAuras"], spellID)

			table.sort(profile["ReactiveAuras"], SortAuras)

			scrollFrame.ScrollBar:SetValue(0)
			SyncUI_OptionPanel_ReactiveAura_UpdateScrollFrame(scrollFrame)

			editBox:SetText("")
		end
	end
end

-----------------
-- Unit Frames --
-----------------
local sortMethods = {"group", "class", "role"}

function SyncUI_OptionPanel_UnitFrames_SelectSortMethod(method)
	local profile = SyncUI_GetProfile()
	local text = GetStringByMethod(method)
	
	SyncUI_UnitGroupContainer_UpdateSorting(SyncUI_PartyFrameContainer, method)
	SyncUI_UnitGroupContainer_UpdateSorting(SyncUI_RaidFrameContainer, method)
	SyncUI_OptionPanel_UnitFrames.Sorting.DropDown:SetText(text)
	
	profile.Options.UnitFrames.GroupSortMethod = method
end

function SyncUI_OptionPanel_UnitFrames_Sorting_InitDropDown(self)
	local profile = SyncUI_GetProfile()
	
	for i, method in ipairs(sortMethods) do
		local info = {}
		info.text = GetStringByMethod(method)
		info.height = 20
		info.isList = true
		info.clickFunc = function()
			SyncUI_OptionPanel_UnitFrames_SelectSortMethod(method)
		end
		
		if method == profile.Options.UnitFrames.GroupSortMethod then
			info.isChecked = true
		end
		
		SyncUI_DropDownMenu_AddButton(info)
	end
end

--------------
-- Profiles --
--------------
function SyncUI_OptionPanel_Profiles_Selection_InitDropDown(self)
	local dataBase = SyncUI_Data["Profiles"]
	local activeProfile = SyncUI_Data.Keys[charKey] or "Default"
	
	for profile, data in pairs(dataBase) do
		local info = {}
		info.text = profile
		info.height = 20
		info.isList = true
		info.clickFunc = function()
			SyncUI_Data.Keys[charKey] = profile
			LoadSavedOptions()
			SyncUI_LoadFramePositions()
		end

		if profile == activeProfile then
			info.isChecked = true
		end

		SyncUI_DropDownMenu_AddButton(info)
	end
end

function SyncUI_OptionPanel_Profiles_Deletion_InitDropDown(self)
	local dataBase = SyncUI_Data["Profiles"]
	
	for profile, data in pairs(dataBase) do
		if profile ~= "Default" then
			local info = {}
			info.text = profile
			info.height = 20
			info.isList = true
			info.clickFunc = function()
				profileQuery = profile
				
				self:GetParent():SetText(profile)
				StaticPopup_Show("SYNCUI_DELETEPROFILE", profile)
			end
			
			SyncUI_DropDownMenu_AddButton(info)
		end
	end
end

function SyncUI_OptionPanel_Profiles_Copy_InitDropDown(self)
	local dataBase = SyncUI_Data["Profiles"]
	local activeProfile = SyncUI_Data.Keys[charKey] or "Default"
	
	for profile, data in pairs(dataBase) do
		if profile ~= activeProfile then
			local info = {}
			info.text = profile
			info.height = 20
			info.isList = true
			info.clickFunc = function()
				profileQuery = profile
				self:GetParent():SetText(profile)
				StaticPopup_Show("SYNCUI_COPYPROFILE", activeProfile)
			end
			SyncUI_DropDownMenu_AddButton(info)
		end
	end
end

------------
-- Broker --
------------
local brokerData = {}

local function SortPerServer(a,b)
	local s1, n1 = unpack(a)
	local s2, n2 = unpack(b)
	
	if s1 ~= s2 then
		return s1 < s2
	elseif n1 ~= n2 then
		return n1 < n2
	end
end

local function TransferCharInfo()
	local dataBase = SyncUI_Data["Broker"]["CharInfo"]
	
	for server, data in pairs(dataBase) do
		for _, info in pairs(data) do
			local name, class, guid = info["Name"], info["Class"], info["GUID"]
			
			if name then
				tinsert(brokerData,{server, name, class, guid})
			end
		end
	end
	
	table.sort(brokerData, SortPerServer)
end

function SyncUI_OptionPanel_Broker_OnShow(self)
	if not self.init then
		TransferCharInfo()
		self.init = true
	end
	
	self.ScrollFrame.ScrollBar:SetValue(0)
	SyncUI_OptionPanel_Broker_UpdateScrollFrame(self.ScrollFrame)
end

function SyncUI_OptionPanel_Broker_UpdateScrollFrame(self)
	local offset = FauxScrollFrame_GetOffset(self)
	local maxLines = 7
	local size = #brokerData
	
	SyncUI_ScrollFrame_Update(self, size, maxLines, 20)
	
	for i = 1, maxLines do
		local button = SyncUI_OptionPanel_Broker["Button"..i]
		local idx = offset + i

		button:SetID(idx)
		
		SyncUI_OptionPanel_BrokerButton_Update(button)
	end
end

function SyncUI_OptionPanel_BrokerButton_Update(self)
	local dataBase = brokerData[self:GetID()]
	
	if dataBase then
		local server, name, class = unpack(dataBase)
		local left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[class])
		local color = SYNCUI_CLASS_COLORS[class]
		local r,g,b = color.r, color.g, color.b
		
		if left and right and top and bottom then
			left = left + 0.02
			right = right - 0.02
			top = top + 0.02
			bottom = bottom - 0.02
		end
		
		if r and g and b then
			name = SyncUI_GetColorizedText(name,r,g,b)
		end
				
		if name then
			self.Icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			self.Icon:SetTexCoord(left,right,top,bottom)
			self.Name:SetText(name)
			self.Server:SetText(server)
		end
		
		self:Show()
	else
		self:Hide()
	end
end

function SyncUI_OptionPanel_BrokerButton_DeleteInfo(self)
	local dataBase = brokerData[self:GetParent():GetID()]
	
	if dataBase then
		local server, name, class, guid = unpack(dataBase)
		
		if server and guid then
			local serverBase = SyncUI_Data["Broker"]["CharInfo"][server]
			
			for index, data in pairs(serverBase) do
				if data["GUID"] == guid then
					tremove(serverBase,index)
					brokerData = {}
					
					TransferCharInfo()
					
					SyncUI_OptionPanel_Broker.transfered = nil
					SyncUI_OptionPanel_Broker_OnShow(SyncUI_OptionPanel_Broker)
					
					return
				end
			end
		end
	end
end

-------------------
-- Static Popups --
-------------------
StaticPopupDialogs["SYNCUI_USEDEFAULTRAID"] = {
	text = SYNCUI_STRING_UNITFRAMES_ENABLE_DEFAULT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		SyncUI_GetProfile().Options.UnitFrames.DefaultRaid = true
		ReloadUI()
	end,
	OnCancel = function()
		SyncUI_OptionPanel_UnitFrames.DefaultRaid:SetChecked(false)
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["SYNCUI_NOTUSEDEFAULTRAID"] = {
	text = SYNCUI_STRING_UNITFRAMES_DISABLE_DEFAULT,
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		SyncUI_GetProfile().Options.UnitFrames.DefaultRaid = false
		ReloadUI()
	end,
	OnCancel = function()
		SyncUI_OptionPanel_UnitFrames.DefaultRaid:SetChecked(true)
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["SYNCUI_DELETEPROFILE"] = {
	text = SYNCUI_STRING_PROFILES_DELETE_QUERY,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local profile = SyncUI_Data["Profiles"][profileQuery]
		local activeProfile = SyncUI_GetProfile()
		
		SyncUI_Data["Profiles"][profileQuery] = nil
		
		-- reset to default
		for charKey, usedProfile in pairs(SyncUI_Data.Keys) do
			if usedProfile == profileQuery then
				SyncUI_Data.Keys[charKey] = nil
			end
		end	
		
		-- reload profile if reset
		if profile == activeProfile then	
			LoadSavedOptions()
		end

		SyncUI_OptionPanel_Profiles.Deletion.DropDown:SetText("")
		profileQuery = nil
	end,
	OnCancel = function()
		SyncUI_OptionPanel_Profiles.Deletion.DropDown:SetText("")
		profileQuery = nil
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["SYNCUI_COPYPROFILE"] = {
	text = SYNCUI_STRING_PROFILES_COPY_QUERY,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local profile = SyncUI_Data["Keys"][charKey]
		local overwrite = CopyTable(SyncUI_Data["Profiles"][profileQuery])
		
		SyncUI_Data["Profiles"][profile] = overwrite

		LoadSavedOptions()

		SyncUI_OptionPanel_Profiles.Copy.DropDown:SetText("")
		profileQuery = nil
	end,
	OnCancel = function()
		SyncUI_OptionPanel_Profiles.Copy.DropDown:SetText("")
		profileQuery = nil
	end,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

