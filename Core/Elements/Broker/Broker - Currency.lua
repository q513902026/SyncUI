
local function Currency_OnClick(self)
	ToggleCharacter("TokenFrame");
end

local function Currency_OnEnter(self)
	local numEntries, spacer = 0
	
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	
	for index = 1, C_CurrencyInfo.GetCurrencyListSize() do
		local info = C_CurrencyInfo.GetCurrencyListInfo(index)
		if not info.isHeader and not info.isTypeUnused then
			if not spacer then
				spacer = true
			end
			
			numEntries = numEntries + 1
			
			GameTooltip:AddDoubleLine(info.name, info.quantity.." |T"..info.iconFileID..":14:14:0:0:64:64:5:59:5:59|t",1,1,1,1,1,1)
		end
	end

	GameTooltip:Show()
end

do	-- Initialize
	local info = {}

	info.title = CURRENCY
	info.icon = "Interface\\Icons\\garrison_building_tradingpost"
	info.clickFunc = Currency_OnClick
	info.tooltipFunc = Currency_OnEnter
	
	SyncUI_RegisterBrokerType("Currency", info)
end

-- pre load currency tab
ToggleCharacter("TokenFrame", true);