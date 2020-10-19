
if GetLocale() ~= "deDE" then
	return
end





---------------
-- Installer --
---------------
	SYNCUI_STRING_INSTALL_BTN_FINISH = "Fertigstellen"
	SYNCUI_STRING_INSTALL_BTN_INSTALL = "Installieren"
	SYNCUI_STRING_INSTALL_COMPLETE = "Klicke auf 'Fertigstellen' um die Installation abzuschließen"
	SYNCUI_STRING_INSTALL_CONTINUE = "Klicke auf 'Installieren' um fortzufahren"
	SYNCUI_STRING_INSTALL_IN_PROGRESS = "Installation wird ausgeführt"
	SYNCUI_STRING_INSTALL_WELCOME = "Willkommen bei "..SYNCUI_STRING_UI_LABEL
-------------
-- Options --
-------------
	SYNCUI_STRING_APPEARANCE_COLOR_MODE = "Farbmodus"
	SYNCUI_STRING_APPEARANCE_RAINBOW = "Farbspektrum"
	SYNCUI_STRING_APPEARANCE_PULSE = "Pulsieren"
	SYNCUI_STRING_APPEARANCE_SOLID = "Konstant"
	SYNCUI_STRING_APPEARANCE_FONTS = "Schriftarten"
	SYNCUI_STRING_AURAS = "Auren"
	SYNCUI_STRING_AURAS_COLORIZE_TIMER = "Laufzeiten einfärben"
	SYNCUI_STRING_AURAS_DISABLE_SPIRAL = "Laufzeit-Spirale deaktivieren"
	SYNCUI_STRING_AURAS_FILTER_DEBUFFS = "Gegnerische Schwächungszauber filtern"
	SYNCUI_STRING_AURAS_NUMERIC_TIMERS = "Laufzeiten nummerisch darstellen"
	SYNCUI_STRING_AURAS_REACTIVE_AURAS = "Reaktive Auren"
	SYNCUI_STRING_AURAS_ENTER_SPELL_ID = "ZauberID eingeben"
	SYNCUI_STRING_UNITFRAMES = "Einheiten Fenster"
	SYNCUI_STRING_UNITFRAMES_DISABLE_DEFAULT = "Möchtest du blizzards Raid-Anzeige deaktivieren?"
	SYNCUI_STRING_UNITFRAMES_ENABLE_DEFAULT = "Möchtest du blizzards Raid-Anzeige aktivieren?"
	SYNCUI_STRING_UNITFRAMES_SORTBY = "Sortiere Einheiten-Gruppen nach:"
	SYNCUI_STRING_UNITFRAMES_USEDEFAULT = "Nutze die Standard-Gruppen-Anzeige (Gruppe / Schlachtzug)"
	SYNCUI_STRING_QUESTS_AUTO_ACCEPT = "Quests automatisch akzeptieren"
	SYNCUI_STRING_QUESTS_AUTO_SHARE = "Quests automatisch teilen"
	SYNCUI_STRING_QUESTS_AUTO_TURN_IN = "Quests automatisch abgeben"
	SYNCUI_STRING_QUESTS_INCLUDE_DAILY = "Einschließlich täglicher Quests"
	SYNCUI_STRING_QUESTS_DISABLE_TRACKER = "Deaktiviere die Standard-Questanzeige"
	SYNCUI_STRING_QUESTS_IGNORE = "Halte |cFF66FF00Shift|r um Einstellungen zu umgehen"
	SYNCUI_STRING_MISC = "Verschiedenes"
	SYNCUI_STRING_MISC_AUTO_REPAIR = "Ausrüstung automatisch reparieren"
	SYNCUI_STRING_MISC_AUTO_SELL = "Schrott automatisch verkaufen"
	SYNCUI_STRING_MISC_AUTO_WORK_ORDER = "Arbeitsaufträge automatisieren"
	SYNCUI_STRING_MISC_DISABLE_AFK = "AFK/Flug-Modus deaktivieren"
	SYNCUI_STRING_MISC_GUILD_REPAIR = "Gilden-Reparieren bevorzugen"
	SYNCUI_STRING_MISC_SKIP_CINEMATIC = "Filmsequenzen überspringen"
	SYNCUI_STRING_PROFILES = "Profile"
	SYNCUI_STRING_PROFILES_CREATE = "Neues Profil erstellen:"
	SYNCUI_STRING_PROFILES_SELECT = "Profil auswählen:"
	SYNCUI_STRING_PROFILES_DELETE = "Profil löschen:"
	SYNCUI_STRING_PROFILES_DELETE_QUERY = "Möchtest du das ausgewählte Profil: |cFF66FF00%s|r löschen?"
	SYNCUI_STRING_PROFILES_COPY = "Profil kopieren:"
	SYNCUI_STRING_PROFILES_COPY_QUERY = "Möchtest du das aktuelle Profil: |cFF66FF00%s|r überschreiben?"
	SYNCUI_STRING_BROKER = "Broker"
	SYNCUI_STRING_PLACEMENT_TOOL = "Placement-Tool"
	SYNCUI_STRING_PLACEMENT_TOOL_CLICK_TO_RESET = "|cFF66FF00Shift-Rechtsklick|r zum Zurücksetzen der Position"
	SYNCUI_STRING_PLACEMENT_TOOL_RESET_POSITION = "Möchtest du die Position aller Anzeigen zurücksetzen?"
	SYNCUI_STRING_PLACEMENT_TOOL_SELECT = "Wähle Spec:"
	SYNCUI_STRING_PLACEMENT_TOOL_COPY = "Spec kopieren:"
	SYNCUI_STRING_PLACEMENT_TOOL_COPY_QUERY = "Möchtest du die Spezialisierung überschreiben:\n\n |T%s:14:14:0:0:64:64:5:59:5:59|t |cFF66FF00%s|r?"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_ALERTS = "Benachrichtigungen"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_BUFFS = "Spieler Buffs"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_DEBUFFS = "Spieler Debuffs"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_CASTBAR = "Zauberleiste"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_ZONE_ABILITY = "Gebiets-Fähigkeit"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_ENVIRONMENT_BAR = "Umweltleiste"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_TOOLTIP = "Tooltip"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_VEHICLE = "Fahrzeug"
	SYNCUI_STRING_PLACEMENT_TOOL_LABEL_WORLD_MARK_BAR = "Weltmarkierungsleiste"
--------------
-- Bindings --
--------------
	SYNCUI_STRING_BINDING_USE_ACTIVE_QUEST_ITEM = "Aktives Quest-Item benutzen"
	SYNCUI_STRING_BINDING_TOGGLE_SIDEBAR = "Seitenleiste Ein-/Ausblenden"
	SYNCUI_STRING_BINDING_TOGGLE_TALENTUI = "Talente Ein-/Ausblenden"
-------------------
-- Group Control --
-------------------
	SYNCUI_STRING_GROUP_CONTROL_LAYOUT = "Wähle Layout:"
	SYNCUI_STRING_GROUP_CONTROL_LAYOUT_HEAL = "Heilung"
	SYNCUI_STRING_GROUP_CONTROL_LAYOUT_NORMAL = "Normal"
	SYNCUI_STRING_GROUP_CONTROL_MAXIMIZE_RAID = "Schlachtzug maximieren"
	SYNCUI_STRING_GROUP_CONTROL_MINIMIZE_RAID = "Schlachtzug minimieren"
	SYNCUI_STRING_LOOTMETHOD_CURRENT_SPEC = "Aktueller Spec"
---------------
-- Raid Tool --
---------------
	SYNCUI_STRING_RAID_TOOL = "Raid Werkzeug"
	SYNCUI_STRING_RAID_TOOL_COMPILATION = "Raid Kader"
	SYNCUI_STRING_RAID_TOOL_LOCKOUTS = "Raid Sperrung"
	SYNCUI_STRING_RAID_TOOL_WORLD_MARKS = "Welt-Marker"
	SYNCUI_STRING_RAID_TOOL_CLEAR_WORLD_MARKS = "|cFF66FF00Shift-Linksklick|r zum Entfernen der Markierung"
------------
-- Bag UI --
------------
	SYNCUI_STRING_BAGS_MANAGE_CONTAINERS = "Kategorien verwalten"
	SYNCUI_STRING_BAGS_MANAGE_CONTAINERS_HINT = "<|cFF66FF00Strg-Alt-Rechts-Klicke|r einen Gegenstand, um ihn einem Container zuzuweisen>"
	SYNCUI_STRING_BAGS_DROP_SLOT = "Freier Platz"
	SYNCUI_STRING_BAGS_RESTACK = "Umschichten"
	SYNCUI_STRING_BAGS_DELETION = "Zerstöre ausgewählte Gegenstände"
	SYNCUI_STRING_BAGS_DELETION_HINT = "<|cFF66FF00Alt-Klicke|r einen Gegenstand, um ihn für die Zerstörung aus/abzuwählen>"
-------------
-- Minimap --
-------------
	SYNCUI_STRING_CLOCK_TOGGLE_DISPLAY = "|cFF66FF00Shift-Linksklick|r zum Umstellen der Anzeige"
	SYNCUI_STRING_CLOCK_TOGGLE_HOUR_MODE = "|cFF66FF00Linksklick|r zum Ändern des 24 Stunden Modus"
	SYNCUI_STRING_CLOCK_TOGGLE_STOPWATCH = "|cFF66FF00Rechtsklick|r zum Ein-/Ausblenden der Stoppuhr"
--------------
-- TalentUI --
--------------
	SYNCUI_STRING_TALENT_AVAILABE = "<Verfügbar mit level %d>"
	SYNCUI_STRING_TALENT_SHOW_ABILITIES = "<Zum Anzeigen der Fähigkeiten Shift halten>"
-----------------------
-- OBJECTIVE TRACKER --
-----------------------
	SYNCUI_STRING_OBJ_TRACKER = "Objective Tracker"
	SYNCUI_STRING_OBJ_TRACKER_FILTER_QUESTS = "Quests filtern"
	SYNCUI_STRING_OBJ_TRACKER_FILTER_ACHIEVEMENTS = "Erfolge filtern"
	SYNCUI_STRING_OBJ_TRACKER_MINIMIZE = "Tracker minimieren"
----------
-- MISC --
----------
	SYNCUI_STRING_STORE = "Store"
	SYNCUI_STRING_CHANGE_LOG = "Neuerungen"
	SYNCUI_STRING_ENTER_NAME = "Namen eingeben"
	SYNCUI_STRING_SKIP_TURN = "Runde aussetzen"
	SYNCUI_STRING_SPELLID = "|cFF66FF00ZauberID:|r %d"
	SYNCUI_STRING_AURAID = "|cFF66FF00AuraID:|r %d"
	SYNCUI_STRING_ITEMID = "|cFF66FF00GegenstandID:|r %d"
	SYNCUI_STRING_MEMORY = "Auslastung"
	SYNCUI_STRING_MEMORY_LABEL = "Addon-Auslastung"
	SYNCUI_STRING_EXP = "Erfahrung"
	SYNCUI_STRING_LATENCY = "Latenz"
	SYNCUI_STRING_NOT_ONLINE = "Zur Zeit sind keine Freunde online!"
	SYNCUI_STRING_REALM = "Realm"
	SYNCUI_STRING_ALL_REALMS = "Alle Realms"
	SYNCUI_STRING_SESSION = "Sitzung:"
	SYNCUI_STRING_SWITCH_DISPLAY = "Zum Umschalten der Anzeige |cFF66FF00klicken|r"
	SYNCUI_STRING_PRESS_TO_CANCEL = "Drücke |cFF66FF00%s|r, um abzubrechen"
	SYNCUI_STRING_BROKEN = "|cFFFF0000zerstört|r"