local addonName, NS = ...
local Core, UI, Scanner = NS.Core, NS.UI, NS.Scanner
local app = {scrollOffset = 0, entries = {}, metadata = {unresolved = 0, objectives = 0}, dirty = true,
    zoneDirty = true}
NS.app = app

local function message(text)
    print("|cffffd100" .. NS.L("title") .. ":|r " .. text)
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
    if Core.IsRetail() or LibQuestieDB or not StaticPopupDialogs or not StaticPopup_Show then return end
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    if isLoaded and not isLoaded("RXPGuides")
        and (isLoaded("Polestar") or NS.RestedXP.FollowTheArrowAvailable()) then return end
    local key = "QUESTTARGETS_MISSING_QUESTIEDB"
    local interface = GetBuildInfo and select(4, GetBuildInfo())
    local forever = type(interface) == "number" and interface >= 16000 and interface < 17000
    local expansion = type(interface) == "number" and
        ((interface >= 20500 and interface < 20600 and "TBC")
            or (interface >= 50500 and interface < 50600 and "Mists"))
    local title = expansion and (NS.L("dbMissing") .. " (" .. expansion .. ")")
        or NS.L(forever and "dbInstallForeverTitle" or "dbInstallTitle")
    local detail = expansion and NS.L("dbInstallExpansionText"):format("QuestieDB-" .. expansion .. ".zip")
        or NS.L(forever and "dbInstallForeverText" or "dbInstallText")
    StaticPopupDialogs[key] = {
        text = title .. "\n\n" .. detail,
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

local function rebuildEntries(app)
    app.entries, app.metadata = Core.BuildEntries(app.quests, app.learned, app.resolutionCache)
    app.allEntries = app.quests == app.allQuests and app.entries
        or Core.BuildEntries(app.allQuests, app.learned, app.resolutionCache)
end

local function renderEntries(app)
    UI.Render(app)
    UI.RenderMaster(app)
    app.renderedProximityRevision = NS.Proximity and NS.Proximity.revision
end

local function syncIntegrations(app, idle)
    NS.QuestieTracker.Sync(app, idle)
    NS.EllesmereTracker.Sync(app, idle)
    NS.FlareUITracker.Sync(app, idle)
    NS.ItemTree.Sync(app)
    local rareEntry = NS.RareScanner.SyncMark(app)
    NS.RestedXP.Sync(app, rareEntry)
end

function app:Refresh(forceResolution)
    if not self.db then return end
    if InCombatLockdown() then self.dirty = true; UI.UpdateStatus(self); return end
    if UI.moving or UI.resizing then self.dirty = true; return end
    if not UI.frame then UI.Create(self) end
    local quests, err, pending, allQuests = Core.ReadQuests(self.db.watchedOnly, true)
    allQuests = allQuests or quests
    self.allQuests = allQuests
    self.pendingData = pending
    self.quests = quests
    local provider = NS.Database and NS.Database.Provider()
    if forceResolution ~= false or self.zoneDirty or provider ~= self.resolutionProvider then
        if NS.Database then NS.Database.RefreshZone() end
        self.resolutionCache = {}
        self.zoneDirty = false
    end
    self.resolutionProvider = provider
    if not (err or pending) and #allQuests > 0 then
        Scanner.Prune(allQuests, self.learned)
    end
    self.scanPending = false
    Scanner.Scan(allQuests, self.learned)
    self.resolutionCache = self.resolutionCache or {}
    rebuildEntries(self)
    if not (err or pending) then
        local active = {}
        for _, quest in ipairs(allQuests) do active[quest.id] = true end
        if self.db.focusQuestID and not active[self.db.focusQuestID] then self.db.focusQuestID = nil end
        for questID in pairs(self.resolutionCache) do
            if not active[questID] then self.resolutionCache[questID] = nil end
        end
    end
    self.error = err
    self.dirty = false
    renderEntries(self)
    UI.SyncFocusBinding(self)
    syncIntegrations(self)
    if self.pendingVisibility ~= nil then
        UI.frame:SetShown(self.pendingVisibility)
        self.db.hidden = not self.pendingVisibility
        self.pendingVisibility = nil
    end
end

function app:Schedule(scanOnly)
    if scanOnly then self.scanPending = true else self.dirty = true end
    if self.scheduled then return end
    self.scheduled = true
    C_Timer.After(0.15, function()
        self.scheduled = false
        if self.dirty then
            self:Refresh(false)
        elseif self.scanPending and self:Scan() then
            syncIntegrations(self)
        end
    end)
end

function app:Toggle()
    if not self.db then return end
    if NS.Tutorial.SkipPractice() then return end
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
    if self.tutorialQuest then return end
    self.db.watchedOnly = not self.db.watchedOnly
    self.scrollOffset = 0
    self:Refresh()
end

function app:Scan()
    if not self.allQuests or InCombatLockdown() or UI.moving or UI.resizing then return end
    self.scanPending = false
    local revision = NS.Proximity and NS.Proximity.revision
    local changed = Scanner.Scan(self.allQuests, self.learned)
    if changed then rebuildEntries(self) end
    if changed or self.renderedProximityRevision ~= revision then
        renderEntries(self)
        return true
    end
    UI.UpdateStatus(self)
    return false
end

function app:Poll()
    if not self.db or not UI.frame or InCombatLockdown() then return end
    if self.dirty or self.pendingData then self:Refresh(false); return end
    local rendered = self:Scan()
    if rendered ~= nil then syncIntegrations(self, not rendered) end
end

function app:Help()
    for index = 1, 6 do message(NS.L("help" .. index)) end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("UPDATE_BINDINGS")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("PLAYER_LOGOUT")
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
        if loadedName ~= addonName then
            if app.loggedIn then UI.RegisterSettings(app) end
            if app.db and (loadedName == "QuestieDB" or loadedName == "SilverDragon" or loadedName == "RareScanner"
                or loadedName == "Questie" or loadedName == "RXPGuides" or loadedName == "ItemTree"
                or loadedName == "Polestar" or loadedName == "FollowTheArrow"
                or loadedName == "EllesmereUIQuestTracker" or loadedName == "FlareUI") then
                app:Schedule()
            end
            return
        end
        NS.Tutorial.Initialize(type(QuestTargetsDB) == "table" and next(QuestTargetsDB) ~= nil)
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
        app.db.hidden = app.db.hidden ~= false
        app.db.transparencyMode = app.db.transparencyMode == true
        app.db.watchedOnly = app.db.watchedOnly == true
        app.db.masterHidden = app.db.masterHidden == true
        app.db.masterOrientation = app.db.masterOrientation == "vertical" and "vertical" or "horizontal"
        local spacing = app.db.masterSpacing
        app.db.masterSpacing = type(spacing) == "number" and spacing == spacing
            and math.max(0, math.min(32, math.floor(spacing + 0.5))) or 0
        app.db.masterBackground = app.db.masterBackground == true
        app.db.masterBorder = app.db.masterBorder == true
        app.db.masterLocked = app.db.masterLocked == true
        if type(app.db.collapsedQuestZones) ~= "table" then app.db.collapsedQuestZones = {} end
        app.db.masterDividers = app.db.masterDividers ~= false
        app.db.rareScannerZone = app.db.rareScannerZone ~= false
        app.db.actionBarMode = nil -- obsolete setting from the former docking mode
        local scale = app.db.masterModernScale
        if type(scale) == "number" and scale == scale and scale < math.huge then
            if app.db.masterScaleBaseline ~= 2 then scale = math.floor(scale / 1.5 * 100 + 0.5) / 100 end
            app.db.masterModernScale = math.max(0.3, math.min(2, scale))
        else
            app.db.masterModernScale = 1
        end
        app.db.masterScaleBaseline = 2
        app.db.masterAppearance, app.db.masterTexture, app.db.masterText = nil, nil, nil
        app.db.masterScaleX, app.db.masterScaleY = nil, nil
        app.db.minimapHidden = app.db.minimapHidden == true
        if type(app.db.minimap) ~= "table" then
            local angle = app.db.minimapAngle
            app.db.minimap = {hide=app.db.minimapHidden,
                minimapPos=type(angle) == "number" and angle == angle
                    and angle * 180 / math.pi or 225}
        end
        app.db.minimapHidden = app.db.minimap.hide == true
        local ellesmereOffset = app.db.ellesmereTrackerOffset
        app.db.ellesmereTrackerOffset = type(ellesmereOffset) == "number" and ellesmereOffset == ellesmereOffset
            and math.max(-240, math.min(240, math.floor(ellesmereOffset + 0.5))) or 0
        local offset = app.db.questieTrackerOffset
        app.db.questieTrackerOffset = type(offset) == "number" and offset == offset
            and math.max(-240, math.min(240, math.floor(offset + 0.5))) or 35
        app.db.minimapStyle = nil -- remove the premature design-selection setting
        app.db.showTooltips = app.db.showTooltips ~= false
        app.db.muteDeadTargetSound = app.db.muteDeadTargetSound ~= false
        app.db.focusMarkEnabled = nil -- focused quests are always highlighted
        app.db.focusHotkeyEnabled = nil -- removed setting; an assigned key always works
        if type(app.db.focusQuestID) ~= "number" then app.db.focusQuestID = nil end
        if type(app.db.focusHotkeyKey) ~= "string" then app.db.focusHotkeyKey = nil end
        if type(app.db.focusHotkeyKey2) ~= "string" then app.db.focusHotkeyKey2 = nil end
        local scale = app.db.menuScale
        app.db.menuScale = type(scale) == "number" and scale == scale and math.max(0.5, math.min(1.5, scale)) or 1
        app.db.autoMark = app.db.autoMark ~= false
        app.db.autoPing = NS.Core.PingAvailable() and app.db.autoPing == true or false
        if app.db.autoPing then app.db.autoMark = false end
        if type(app.db.targetFeedback) ~= "table" then app.db.targetFeedback = {} end
        local icon = app.db.markerIcon
        if type(icon) ~= "number" or icon < 1 or icon > 8 or icon % 1 ~= 0 then app.db.markerIcon = 8 end
        NS.UpdateBindingLabels()
    elseif event == "UPDATE_BINDINGS" then
        if app.db and app.focusBindingsInitialized then
            app.db.focusHotkeyKey, app.db.focusHotkeyKey2 = GetBindingKey("CLICK QuestTargetsFocused:LeftButton")
            app:Schedule()
        end
    elseif event == "PLAYER_LOGIN" then
        app.loggedIn = true
        UI.RegisterSettings(app)
        NS.Tutorial.OnLogin(app, showMissingDatabase)
        NS.PatchNotes.OnLogin()
        app:Schedule()
    elseif event == "PLAYER_LOGOUT" then
        Core.ReleaseDeadTargetSound()
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Observe delayed secure target results without rescanning quests or
        -- writing any protected attributes from the event handler.
        Core.ConfirmSearchResult()
        if app.db and app.db.itemTreeMacroBody and not InCombatLockdown() then
            -- Let the targeting macro finish before rewriting its stored body.
            C_Timer.After(0, function() NS.ItemTree.SyncMacro(app) end)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        UI.CancelBindingAssignment()
        NS.Tutorial.OnCombat()
        UI.EndMasterMove(app, true)
        UI.StopResizing(app)
        UI.StopMoving(app.db)
        app.dirty = true
        UI.UpdateStatus(app)
    elseif event == "PLAYER_REGEN_ENABLED" then
        UI.RegisterSettings(app)
        NS.PatchNotes.TryPending()
        UI.StopResizing(app)
        UI.StopMoving(app.db)
        app:Refresh(false)
        NS.Tutorial.OnRegen(app)
    elseif event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED" then
        Scanner.Invalidate(loadedName)
        if app.db and Scanner.Available() and not InCombatLockdown() then app:Schedule(true) end
    else
        if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED"
            or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
            app.zoneDirty = true
        end
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
        NS.Diagnostics.Print(app)
    elseif command == "refresh" or command == "aktualisieren" then app:Refresh()
    elseif command == "intro" then
        if InCombatLockdown() then message(NS.L("commandCombat")); return end
        NS.Tutorial.Open(app)
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
