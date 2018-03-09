
local _G = _G
local index, update, interval = 1, 0, 1/30
local framesToAnimate = {}
local texCoords = {
--	 index	 left	right	top		bottom
	[ 1] = { 0.00,	0.25,	0.00,	0.0625 },
	[ 2] = { 0.25,	0.50,	0.00,	0.0625 },
	[ 3] = { 0.50,	0.75,	0.00,	0.0625 },
	[ 4] = { 0.75,	1.00,	0.00,	0.0625 },
	[ 5] = { 0.00,	0.25,	0.0625,	0.1250 },
	[ 6] = { 0.25,	0.50,	0.0625,	0.1250 },
	[ 7] = { 0.50,	0.75,	0.0625,	0.1250 },
	[ 8] = { 0.75,	1.00,	0.0625,	0.1250 },
	[ 9] = { 0.00,	0.25,	0.125,	0.1875 },
	[10] = { 0.25,	0.50,	0.125,	0.1875 },
	[11] = { 0.50,	0.75,	0.125,	0.1875 },
	[12] = { 0.75,	1.00,	0.125,	0.1875 },
	[13] = { 0.00,	0.25,	0.1875,	0.2500 },
	[14] = { 0.25,	0.50,	0.1875,	0.2500 },
	[15] = { 0.50,	0.75,	0.1875,	0.2500 },
	[16] = { 0.75,	1.00,	0.1875,	0.2500 },
	[17] = { 0.00,	0.25,	0.250,	0.3125 },
	[18] = { 0.25,	0.50,	0.250,	0.3125 },
	[19] = { 0.50,	0.75,	0.250,	0.3125 },
	[20] = { 0.75,	1.00,	0.250,	0.3125 },
	[21] = { 0.00,	0.25,	0.3125,	0.3750 },
	[22] = { 0.25,	0.50,	0.3125,	0.3750 },
	[23] = { 0.50,	0.75,	0.3125,	0.3750 },
	[24] = { 0.75,	1.00,	0.3125,	0.3750 },
	[25] = { 0.00,	0.25,	0.375,	0.4375 },
	[26] = { 0.25,	0.50,	0.375,	0.4375 },
	[27] = { 0.50,	0.75,	0.375,	0.4375 },
	[28] = { 0.75,	1.00,	0.375,	0.4375 },
	[29] = { 0.00,	0.25,	0.4375,	0.5000 },
	[30] = { 0.25,	0.50,	0.4375,	0.5000 },
	[31] = { 0.50,	0.75,	0.4375,	0.5000 },
	[32] = { 0.75,	1.00,	0.4375,	0.5000 },
	[33] = { 0.00,	0.25,	0.500,	0.5625 },
	[34] = { 0.25,	0.50,	0.500,	0.5625 },
	[35] = { 0.50,	0.75,	0.500,	0.5625 },
	[36] = { 0.75,	1.00,	0.500,	0.5625 },
	[37] = { 0.00,	0.25,	0.5625,	0.6250 },
	[38] = { 0.25,	0.50,	0.5625,	0.6250 },
	[39] = { 0.50,	0.75,	0.5625,	0.6250 },
	[40] = { 0.75,	1.00,	0.5625,	0.6250 },
	[41] = { 0.00,	0.25,	0.625,	0.6875 },
	[42] = { 0.25,	0.50,	0.625,	0.6875 },
	[43] = { 0.50,	0.75,	0.625,	0.6875 },
	[44] = { 0.75,	1.00,	0.625,	0.6875 },
	[45] = { 0.00,	0.25,	0.6875,	0.7500 },
	[46] = { 0.25,	0.50,	0.6875,	0.7500 },
	[47] = { 0.50,	0.75,	0.6875,	0.7500 },
	[48] = { 0.75,	1.00,	0.6875,	0.7500 },
	[49] = { 0.00,	0.25,	0.75,	0.8125 },
	[50] = { 0.25,	0.50,	0.75,	0.8125 },
	[51] = { 0.50,	0.75,	0.75,	0.8125 },
	[52] = { 0.75,	1.00,	0.75,	0.8125 },
	[53] = { 0.00,	0.25,	0.8125,	0.8750 },
	[54] = { 0.25,	0.50,	0.8125,	0.8750 },
	[55] = { 0.50,	0.75,	0.8125,	0.8750 },
	[56] = { 0.75,	1.00,	0.8125,	0.8750 },
	[57] = { 0.00,	0.25,	0.875,	0.9375 },
	[58] = { 0.25,	0.50,	0.875,	0.9375 },
	[59] = { 0.50,	0.75,	0.875,	0.9375 },
	[60] = { 0.75,	1.00,	0.875,	0.9375 },
}

local function AnimateStatusBar(self,index)
	local r,g,b = self:GetStatusBarColor()
	local left, right, top, bottom = unpack(texCoords[index])

	self.Fill:SetTexCoord(left, right, top, bottom)
	self.Fill:SetVertexColor(r,g,b,0.75)
end


function SmoothBar(statusBar,value)
	local limit = 30/GetFramerate()
	local old = statusBar:GetValue()
	local new = old + math.min((value-old)/6, math.max(value-old, limit))
	if new ~= new then
		new = value
	end
	if old == value or abs(new - value) < 0 then
		statusBar:SetValue(value)
	else
		statusBar:SetValue(new)
	end
end

function SyncUI_AnimatedStatusBar_OnLoad(self)
	table.insert(framesToAnimate,self)
	self.Fill:SetAllPoints(self:GetStatusBarTexture())
end

function SyncUI_AnimatedStatusBarFrame_OnUpdate(self,elapsed)
	update = update + elapsed
	
	while update >= interval do
		if index >= 60 then
			index = 1
		else
			index = index + 1
		end

		for _, frame in pairs(framesToAnimate) do
			if frame:IsShown() and frame:IsVisible() then
				AnimateStatusBar(frame,index)
			end
		end
		
		update = update - interval
	end
end

