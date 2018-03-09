
local edgeSize, padding = 12, 6
local bgFile = SYNCUI_MEDIA_PATH.."Backdrops\\Backdrop-BgFile"
local edgeFile = SYNCUI_MEDIA_PATH.."Backdrops\\Backdrop-EdgeFile"
local font = SyncUI_GameFontOutline_Small
local lastUpdate = -2;

local function SkinBubble(frame)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions());
		
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end
	
	if not frame.topLeft then
		frame.topLeft = frame:CreateTexture(nil, "BACKGROUND")
		frame.topLeft:SetDrawLayer("BACKGROUND", 1)
		frame.topLeft:SetSize(edgeSize, edgeSize)
		frame.topLeft:SetPoint("TOPLEFT", padding, -padding)
		frame.topLeft:SetTexture(edgeFile)
		frame.topLeft:SetTexCoord(0.5,0.625,0,1)
	end
	if not frame.topRight then
		frame.topRight = frame:CreateTexture(nil, "BACKGROUND")
		frame.topRight:SetDrawLayer("BACKGROUND", 1)
		frame.topRight:SetSize(edgeSize, edgeSize)
		frame.topRight:SetPoint("TOPRIGHT", -padding, -padding)
		frame.topRight:SetTexture(edgeFile)
		frame.topRight:SetTexCoord(0.625,0.75,0,1)
	end
	if not frame.botLeft then
		frame.botLeft = frame:CreateTexture(nil, "BACKGROUND")
		frame.botLeft:SetDrawLayer("BACKGROUND", 1)
		frame.botLeft:SetSize(edgeSize, edgeSize)
		frame.botLeft:SetPoint("BOTTOMLEFT", padding, padding)
		frame.botLeft:SetTexture(edgeFile)
		frame.botLeft:SetTexCoord(0.75,0.875,0,1)
	end
	if not frame.botRight then
		frame.botRight = frame:CreateTexture(nil, "BACKGROUND")
		frame.botRight:SetDrawLayer("BACKGROUND", 1)
		frame.botRight:SetSize(edgeSize, edgeSize)
		frame.botRight:SetPoint("BOTTOMRIGHT", -padding, padding)
		frame.botRight:SetTexture(edgeFile)
		frame.botRight:SetTexCoord(0.875,1,0,1)
	end
	if not frame.top then
		frame.top = frame:CreateTexture(nil, "BACKGROUND")
		frame.top:SetDrawLayer("BACKGROUND", 1)
		frame.top:SetPoint("TOPLEFT", frame.topLeft, "TOPRIGHT")
		frame.top:SetPoint("BOTTOMRIGHT", frame.topRight, "BOTTOMLEFT")
		frame.top:SetTexture(edgeFile)
		frame.top:SetTexCoord(0.6,0.65,0,1)
	end
	if not frame.bottom then
		frame.bottom = frame:CreateTexture(nil, "BACKGROUND")
		frame.bottom:SetDrawLayer("BACKGROUND", 1)
		frame.bottom:SetPoint("TOPLEFT", frame.botLeft, "TOPRIGHT")
		frame.bottom:SetPoint("BOTTOMRIGHT", frame.botRight, "BOTTOMLEFT")
		frame.bottom:SetTexture(edgeFile)
		frame.bottom:SetTexCoord(0.85,0.9,0,1)
	end
	if not frame.left then
		frame.left = frame:CreateTexture(nil, "BACKGROUND")
		frame.left:SetDrawLayer("BACKGROUND", 1)
		frame.left:SetPoint("TOPLEFT", frame.topLeft, "BOTTOMLEFT")
		frame.left:SetPoint("BOTTOMRIGHT", frame.botLeft, "TOPRIGHT")
		frame.left:SetTexture(edgeFile)
		frame.left:SetTexCoord(0,0.125,0,1)
	end
	if not frame.right then
		frame.right = frame:CreateTexture(nil,"BACKGROUND")
		frame.right:SetDrawLayer("BACKGROUND", 1)
		frame.right:SetPoint("TOPLEFT", frame.topRight, "BOTTOMLEFT")
		frame.right:SetPoint("BOTTOMRIGHT", frame.botRight, "TOPRIGHT")
		frame.right:SetTexture(edgeFile)
		frame.right:SetTexCoord(0.125,0.25,0,1)
	end

	if not frame.bg then
		frame.bg = frame:CreateTexture(nil,"BACKGROUND")
		frame.bg:SetPoint("TOPLEFT", frame.topLeft, padding, -padding)
		frame.bg:SetPoint("BOTTOMRIGHT", frame.botRight, -padding, padding)
		frame.bg:SetTexture(bgFile)
		frame.bg:SetAlpha(0.75)
	end
	if not frame.arrow then
		frame.arrow = frame:CreateTexture(nil,"BACKGROUND")
		frame.arrow:SetDrawLayer("BACKGROUND", 2)
		frame.arrow:SetSize(edgeSize*1.5, edgeSize)
		frame.arrow:SetPoint("TOP", frame.bottom, "BOTTOM", 0, 7)
		frame.arrow:SetTexture(SYNCUI_MEDIA_PATH.."Elements\\Arrows")
		frame.arrow:SetTexCoord(0,0.375,0,0.46875)
	end

	frame.text:SetFontObject(font)
	frame:SetClampedToScreen(false)
	frame.isSkinnedSyncUI = true
end

local function ToggleChatBubble(self)
	local instanceType = select(2, IsInInstance());
	
	if (instanceType == "none") then
		self:SetScript("OnUpdate", SyncUI_ChatBubble_OnUpdate);
	else
		self:SetScript("OnUpdate", nil);
	end
end

function SyncUI_ChatBubble_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function SyncUI_ChatBubble_OnUpdate(self, elapsed)
	lastUpdate = lastUpdate + elapsed;
	
	if lastUpdate < 0.1 then
		return;
	end
	
	self.lastupdate = 0;
	
	for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
		if not chatBubble.isSkinnedSyncUI then
			SkinBubble(chatBubble);
		end
	end
end

function SyncUI_ChatBubble_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		ToggleChatBubble(self);
	end
end