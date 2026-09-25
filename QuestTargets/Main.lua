local addonName, NS = ...
local Core, UI, Scanner = NS.Core, NS.UI, NS.Scanner
local app = {page = 1, entries = {}, metadata = {unresolved = 0, objectives = 0}, dirty = true}
NS.app = app

local function message(text)
    print("|cffffd100Quest Targets:|r " .. text)
end

local QUESTIEDB_URL = "https://github.com/Questie/QuestieDB/releases/"
local function selectDatabaseLink(self)
    local box = self.GetEditBox and self:GetEditBox() or self.editBox or self.EditBox
    if box then
        box:SetText(QUESTIEDB_URL)
        box:HighlightText()
        box:SetFocus()
    end
    return true -- Keep the popup open for the native copy shortcut.
end
local function showMissingDatabase()
    if LibQuestieDB or not StaticPopupDialogs or not StaticPopup_Show then return end
    local key = "QUESTTARGETS_MISSING_QUESTIEDB"
    local interface = GetBuildInfo and select(4, GetBuildInfo())
    local forever = type(interface) == "number" and interface >= 160000 and interface < 170000
    StaticPopupDialogs[key] = {
        text = NS.L(forever and "dbInstallForeverTitle" or "dbInstallTitle") .. "\n\n"
            .. NS.L(forever and "dbInstallForeverText" or "dbInstallText"),
        button1 = NS.L("selectLink"),
        button2 = OKAY or "OK",
        hasEditBox = true,
        editBoxWidth = 320,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = selectDatabaseLink,
        OnAccept = selectDatabaseLink,
    }
    StaticPopup_Show(key)
end

function app:Refresh()
    if not self.db then return end
    if InCombatLockdown() then self.dirty = true; UI.UpdateStatus(self); return end
    if not UI.frame then UI.Create(self) end
    UI.StopMoving(self.db)
    local quests, err, pending = Core.ReadQuests(self.db.watchedOnly)
    local allQuests, allError, allPending = quests, err, pending
    if self.db.watchedOnly then allQuests, allError, allPending = Core.ReadQuests(false) end
    self.allQuests = allQuests
    self.pendingData = pending or allPending
    self.quests = quests
    if NS.Database then NS.Database.RefreshZone() end
    if NS.Proximity then NS.Proximity.Sample() end
    Scanner.Scan(allQuests, self.learned)
    self.resolutionCache = {}
    self.entries, self.metadata = Core.BuildEntries(quests, self.learned, self.resolutionCache)
    self.allEntries = self.db.watchedOnly and Core.BuildEntries(allQuests, self.learned, self.resolutionCache) or self.entries
    self.error = err
    self.dirty = false
    UI.Render(self)
    UI.RenderMaster(self)
    if self.pendingVisibility ~= nil then
        UI.frame:SetShown(self.pendingVisibility)
        self.db.hidden = not self.pendingVisibility
        self.pendingVisibility = nil
    end
end

function app:Schedule()
    self.dirty = true
    if self.scheduled then return end
    self.scheduled = true
    C_Timer.After(0.15, function()
        self.scheduled = false
        if self.dirty then self:Refresh() end
    end)
end

function app:Toggle()
    if not self.db then return end
    if InCombatLockdown() or not UI.frame then
        local currentlyShown = self.pendingVisibility
        if currentlyShown == nil then currentlyShown = not self.db.hidden end
        self.pendingVisibility = not currentlyShown
        self.dirty = true
        message(NS.L("windowDeferred"))
        return
    end
    self.db.hidden = UI.frame:IsShown()
    UI.frame:SetShown(not self.db.hidden)
end

function app:ToggleFilter()
    if InCombatLockdown() then message(NS.L("filterCombat")); return end
    self.db.watchedOnly = not self.db.watchedOnly
    self.page = 1
    self:Refresh()
end

function app:Page(delta)
    if InCombatLockdown() then message(NS.L("pageCombat")); return end
    self.page = self.page + delta
    self:Refresh()
end

function app:Poll()
    if not self.db or not UI.frame or InCombatLockdown() then return end
    if self.dirty or self.pendingData then self:Refresh(); return end
    local moved = NS.Proximity and NS.Proximity.Sample()
    if Scanner.Scan(self.allQuests or {}, self.learned) then
        self.entries, self.metadata = Core.BuildEntries(self.quests or {}, self.learned, self.resolutionCache)
        self.allEntries = self.db.watchedOnly and Core.BuildEntries(self.allQuests or {}, self.learned, self.resolutionCache) or self.entries
        UI.Render(self)
        UI.RenderMaster(self)
    elseif moved then
        UI.Render(self)
        UI.RenderMaster(self)
    else
        UI.UpdateStatus(self)
    end
end

function app:Help()
    for index = 1, 6 do message(NS.L("help" .. index)) end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("QUEST_LOG_UPDATE")
events:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
events:RegisterEvent("QUEST_ACCEPTED")
events:RegisterEvent("QUEST_REMOVED")
events:RegisterEvent("QUEST_TURNED_IN")
events:RegisterEvent("QUEST_WATCH_UPDATE")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
events:RegisterEvent("ZONE_CHANGED")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("ZONE_CHANGED_INDOORS")
events:SetScript("OnEvent", function(_, event, loadedName)
    if event == "ADDON_LOADED" then
        if loadedName ~= addonName then return end
        if type(QuestTargetsDB) ~= "table" then QuestTargetsDB = {} end
        app.db = QuestTargetsDB
        -- Manual overrides from 0.1 remain untouched but are never used for detection.
        local locale = GetLocale()
        if type(app.db.autoTargets) ~= "table" or app.db.autoTargets.locale ~= locale
            or type(app.db.autoTargets.entries) ~= "table" then
            app.db.autoTargets = {locale = locale, entries = {}}
        end
        app.learned = app.db.autoTargets.entries
        if not app.ticker then app.ticker = C_Timer.NewTicker(1, function() app:Poll() end) end
        app.db.hidden = app.db.hidden == true
        app.db.watchedOnly = app.db.watchedOnly == true
        app.db.masterHidden = app.db.masterHidden == true
        app.db.actionBarMode = nil -- obsolete setting from the former docking mode
        for _, key in ipairs({"masterScaleX", "masterScaleY"}) do
            local value = app.db[key]
            app.db[key] = type(value) == "number" and value == value
                and math.max(0.5, math.min(2, value)) or 1
        end
        app.db.masterTexture = nil
        local title = app.db.masterText
        if not app.db.language then
            for _, oldDefault in ipairs({"Questziel anvisieren", "Apuntar a objetivo",
                "Cibler l’objectif", "Görev hedefini seç", "选定任务目标"}) do
                if title == oldDefault then title = nil; break end
            end
        end
        app.db.masterAppearance = app.db.masterAppearance == "modern" and "modern" or "classic"
        local modernScale = app.db.masterModernScale
        app.db.masterModernScale = type(modernScale) == "number" and modernScale == modernScale
            and math.max(0.5, math.min(2, modernScale)) or 1
        app.db.masterText = type(title) == "string" and Core.Clean(title) or NS.L("masterDefault")
        app.db.minimapHidden = app.db.minimapHidden == true
        app.db.minimapStyle = nil -- remove the premature design-selection setting
        app.db.showTooltips = app.db.showTooltips == true
        local scale = app.db.menuScale
        app.db.menuScale = type(scale) == "number" and scale == scale and math.max(0.5, math.min(1.5, scale)) or 1
        app.db.autoMark = app.db.autoMark ~= false
        local icon = app.db.markerIcon
        if type(icon) ~= "number" or icon < 1 or icon > 8 or icon % 1 ~= 0 then app.db.markerIcon = 8 end
    elseif event == "PLAYER_LOGIN" then
        showMissingDatabase()
        app:Schedule()
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Observe delayed secure target results without rescanning quests or
        -- writing any protected attributes from the event handler.
        Core.ConfirmSearchResult()
    elseif event == "PLAYER_REGEN_DISABLED" then
        app.dirty = true
        UI.UpdateStatus(app)
    elseif event == "PLAYER_REGEN_ENABLED" then
        app:Refresh()
    else
        app:Schedule()
    end
end)

SLASH_QUESTTARGETS1 = "/qt"
SLASH_QUESTTARGETS2 = "/questtargets"
SlashCmdList.QUESTTARGETS = function(input)
    -- Lua 5.1 string.lower can corrupt UTF-8 command aliases under the host
    -- locale. Lowercase ASCII letters only; keep accented and CJK bytes intact.
    local command = NS.Command((Core.Clean(input):gsub("[A-Z]", string.lower)))
    if command == "" then app:Toggle()
    elseif command == "debug" then
        local click, cycle = Core.lastClick or {}, Core.lastCycle or {}
        local function boolText(value)
            if value == nil then return NS.L("debugUnchecked") end
            return NS.L((value == true or value == "true") and "debugYes" or "debugNo")
        end
        local paths = {
            ["Keine Mobnamen"]="debugPathNone", ["Ziel behalten"]="debugPathKeep",
            ["Namenssuche"]="debugPathSearch", ["Namenssuche aus Namensplakette"]="debugPathPlate",
        }
        message(NS.L("debugState"):format(boolText(InCombatLockdown()),
            NS.L(paths[click.path] or "debugPathNone")))
        message(NS.L("debugCounts"):format(boolText(click.validCurrent), cycle.plates or 0,
            cycle.candidates or 0, click.unit or NS.L("debugNone")))
        message(NS.L("debugResult"):format(boolText(click.selected)))
        if click.name then message(NS.L("debugName"):format(click.name)) end
    elseif command == "refresh" or command == "aktualisieren" then app:Refresh()
    elseif command == "settings" or command == "einstellungen" then
        if InCombatLockdown() then message(NS.L("settingsCombat")); return end
        UI.Settings(app)
    elseif command == "help" or command == "hilfe" then app:Help()
    elseif command == "reset" or command == "clear" or command == "rescan" then
        if InCombatLockdown() then message(NS.L("commandCombat")); return end
        if not app.db then return end
        if command == "reset" then
            app.db.position = nil
            if UI.frame then UI.RestorePosition(app.db) end
        else
            app.db.autoTargets.entries = {}
            app.learned = app.db.autoTargets.entries
            message(NS.L("rescanDone"))
        end
        app:Refresh()
    else app:Help() end
end
