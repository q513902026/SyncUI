
local eventList = {
	"CHAT_MSG_BN_CONVERSATION",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_DUNGEON_GUIDE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_GUIDE",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL"
}
local patterns = {
	"^(%a[%w%.+-]+://%S+)",
	"%f[%S](%a[%w%.+-]+://%S+)",
	"^(www%.[-%w_%%]+%.%S+)",
	"%f[%S](www%.[-%w_%%]+%.%S+)",
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)",
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+))",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+))",
	"(%S+@[-%w_%%%.]+%.(%a%a+))",
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)",
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]",
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]",
}
local tlds = {
	AC = true, AD = true, AE = true, AERO = true, AF = true, AG = true, AI = true, AL = true, AM = true, AN = true, AO = true, AQ = true, AR = true, ARPA = true, AS = true, ASIA = true, AT = true, AU = true, AW = true, AX = true, AZ = true, 
	BA = true, BB = true, BD = true, BE = true, BF = true, BG = true, BH = true, BI = true, BIZ = true, BJ = true, BM = true, BN = true, BO = true, BR = true, BS = true, BT = true, BV = true, BW = true, BY = true, BZ = true, 
	CA = true, CAT = true, CC = true, CD = true, CF = true, CG = true, CH = true, CI = true, CK = true, CL = true, CM = true, CN = true, CO = true, COM = true, COOP = true, CR = true, CU = true, CV = true, CX = true, CY = true, CZ = true, 
	DE = true, DJ = true, DK = true, DM = true, DO = true, DZ = true, 
	EC = true, EDU = true, EE = true, EG = true, ER = true, ES = true, ET = true, EU = true, 
	FI = true, FJ = true, FK = true, FM = true, FO = true, FR = true, 
	GA = true, GB = true, GD = true, GE = true, GF = true, GG = true, GH = true, GI = true, GL = true, GM = true, GN = true, GOV = true, GP = true, GQ = true, GR = true, GS = true, GT = true, GU = true, GW = true, GY = true, 
	HK = true, HM = true, HN = true, HR = true, HT = true, HU = true, 
	ID = true, IE = true, IL = true, IM = true, IN = true, INFO = true, INT = true, IO = true, IQ = true, IR = true, IS = true, IT = true, 
	JE = true, JM = true, JO = true, JOBS = true, JP = true, 
	KE = true, KG = true, KH = true, KI = true, KM = true, KN = true, KP = true, KR = true, KW = true, KY = true, KZ = true, 
	LA = true, LB = true, LC = true, LI = true, LK = true, LR = true, LS = true, LT = true, LU = true, LV = true, LY = true, 
	MA = true, MC = true, MD = true, ME = true, MG = true, MH = true, MIL = true, MK = true, ML = true, MM = true, MN = true, MO = true, MOBI = true, MP = true, MQ = true, MR = true, MS = true, MT = true, MU = true, MUSEUM = true, MV = true, MW = true, MX = true, MY = true, MZ = true, 
	NA = true, NAME = true, NC = true, NE = true, NET = true, NF = true, NG = true, NI = true, NL = true, NO = true, NP = true, NR = true, NU = true, NZ = true, 
	OM = true, ORG = true, 
	PA = true, PE = true, PF = true, PG = true, PH = true, PK = true, PL = true, PM = true, PN = true, PR = true, PRO = true, PS = true, PT = true, PW = true, PY = true, 
	QA = true, 
	RE = true, RO = true, RS = true, RU = true, RW = true, 
	SA = true, SB = true, SC = true, SD = true, SE = true, SG = true, SH = true, SI = true, SJ = true, SK = true, SL = true, SM = true, SN = true, SO = true, SR = true, ST = true, SU = true, SV = true, SY = true, SZ = true, 
	TC = true, TD = true, TEL = true, TF = true, TG = true, TH = true, TJ = true, TK = true, TL = true, TM = true, TN = true, TO = true, TP = true, TR = true, TRAVEL = true, TT = true, TV = true, TW = true, TZ = true, 
	UA = true, UG = true, UK = true, UM = true, US = true, UY = true, UZ = true, 
	VA = true, VC = true, VE = true, VG = true, VI = true, VN = true, VU = true, 
	WF = true, WS = true, 
	YE = true, YT = true, YU = true, 
	ZA = true, ZM = true, ZW = true,
}
local urlstring, hookfunc
local hyperlink = "|Hurl:%s|h".."|cFF66FF00[%s]|r".."|h"

local function SetHyperlink(self, link, ...)
	if string.sub(link, 1, 4) == "url:" then -- ignore Blizzard urlIndex links
		urlstring = string.sub(link, 5)
		return StaticPopup_Show("COPY_URL")
	end
	
	return hookfunc(self, link, ...)
end

local function SetOverwrite()
	hookfunc = ItemRefTooltip.SetHyperlink
	ItemRefTooltip.SetHyperlink = SetHyperlink
end

local function ClearOverwrite()
	ItemRefTooltip.SetHyperlink = hookfunc
	hookfunc = nil
end

local function GetURL(url, tld)
	if string.lower(url) == "battle.net" then
		return url
	elseif tld then
		return tlds[strupper(tld)] and format(hyperlink, url, url) or url
	else
		return format(hyperlink, url, url)
	end
end

local function Filter(frame, event, msg, ...)
	if type(msg) == "string" then
		for i = 1, #patterns do
			local new = gsub(msg, patterns[i], GetURL)
			if msg ~= new then
				msg = new
				break
			end
		end
	end
	
	return false, msg, ...
end

function SyncUI_ModifyHyperLinks(enabled)
	if enabled then
		for i = 1, #eventList do
			ChatFrame_AddMessageEventFilter(eventList[i], Filter)
		end

		SetOverwrite()
	else
		for i = 1, #eventList do
			ChatFrame_RemoveMessageEventFilter(eventList[i], Filter)
		end
		
		ClearOverwrite()
	end
end

StaticPopupDialogs["COPY_URL"] = {
	text = "URL",
	button2 = CLOSE,
	hasEditBox = true,
	maxLetters = 1024,
	editBoxWidth = 350,
	hideOnEscape = true,
	whileDead = true,
	preferredIndex = 3,
	OnShow = function(self)
		local editBox = self.editBox
		
		editBox:SetText(urlstring)
		editBox:SetFocus()
		editBox:HighlightText()

		urlstring = nil
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
}