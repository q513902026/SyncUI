
local function FPS_OnUpdate(self)
	self:SetText(format(FPS_FORMAT, math.floor(GetFramerate())))
end

do	-- Initialize
	local info = {}
	
	info.title = MOVIE_RECORDING_FRAMERATE
	info.icon = "Interface\\Icons\\SPELL_MAGIC_MANAGAIN"
	info.updateFunc = FPS_OnUpdate
	
	SyncUI_RegisterBrokerType("Framerate", info)
end