local _, NS = ...
local Integration = {}
NS.RareScanner = Integration

local hooked = setmetatable({}, {__mode = "k"})
local installed, button, activePin, activePOI
local feedback
local PULSE_DURATION, PULSE_ALPHA = 0.42, 0.62
local markHooked = false
local observedMarks = {}
local zoneCache
local spawnCache, spawnCacheExpires = {}, 0
local SPAWN_BATCH_SIZE = 8

local function ignoreMenuItem() end

local function canReadSpawns(mapID)
    return type(mapID) == "number" and mapID > 0 and mapID < 100000
        and C_Map and C_Map.GetMapArtID and RSExplorerRareList
        and type(RSExplorerRareList.OnElementSelectionChanged) == "function"
end

local function cachedSpawns(mapID)
    local now = GetTime()
    if now >= spawnCacheExpires then spawnCache, spawnCacheExpires = {}, now + 60 end
    return spawnCache[mapID]
end

local function spawnPoints(npcID, mapID)
    if not canReadSpawns(mapID) then return end
    local pointsByNpc = cachedSpawns(mapID)
    if not pointsByNpc then pointsByNpc = {}; spawnCache[mapID] = pointsByNpc end
    if pointsByNpc[npcID] then return pointsByNpc[npcID] end

    local points = {}
    pointsByNpc[npcID] = points
    -- The Explorer draws every known spawn in its detail map. Use a local
    -- drawing surface of size 1 so its icon offsets are normalized map coordinates.
    local function unitSize() return 1 end
    local map = {mapID=mapID, GetWidth=unitSize, GetHeight=unitSize}
    local iconTexture = {
        SetTexture=ignoreMenuItem, SetVertexColor=ignoreMenuItem, SetDrawLayer=ignoreMenuItem,
    }
    local icon = {
        Texture=iconTexture, Show=ignoreMenuItem, GetParent=function() return map end,
        SetPoint=function(_, _, _, _, x, y)
            if type(x) ~= "number" or type(y) ~= "number" or (x == 0 and y == 0) then return end
            local point = NS.Proximity.MapPoint(map.mapID, x, -y)
            if point then points[#points+1] = point end
        end,
    }
    local pool = {ReleaseAll=ignoreMenuItem, Acquire=function() return icon end}
    map.overlayIconsPool, map.iconsPool = pool, pool
    local detail = {SetAllPoints=ignoreMenuItem, SetMapAndLayer=ignoreMenuItem, Show=ignoreMenuItem}
    map.detailLayerPool = {ReleaseAll=ignoreMenuItem, Acquire=function() return detail end}
    local info = {Map=map, Name={SetText=ignoreMenuItem}, Custom={},
        AchievementIcon={Show=ignoreMenuItem, Hide=ignoreMenuItem}}
    local host = {RareInfo=info, RareLoot={Refresh=ignoreMenuItem}, lootItemsPool=pool}
    local row = {Selected={Show=ignoreMenuItem}}
    local explorer = {mapID=mapID, GetParent=function() return host end, AddItems=ignoreMenuItem,
        scrollView={FindFrame=function() return row end}}
    pcall(function()
        map.mapArtID = C_Map.GetMapArtID(mapID)
        RSExplorerRareList.OnElementSelectionChanged(explorer, {isNpc=true, entityID=npcID, name=""}, true)
    end)
    return points
end

local function addPoint(entry, name, point)
    if not point then return end
    local list = entry.mapPoints[name]
    if not list then list = {}; entry.mapPoints[name] = list end
    list[#list+1] = point
end

local function addSpawnPoints(entry, name, id, mapID)
    for _, point in ipairs(spawnPoints(id, mapID) or {}) do addPoint(entry, name, point) end
end

local function sightingPoint(found)
    if type(found) ~= "table" then return end
    local x, y = tonumber(found.coordX), tonumber(found.coordY)
    if not x or not y or (x == 0 and y == 0) then return end
    if x > 1 then x = x / 10000 end
    if y > 1 then y = y / 10000 end
    if type(found.mapID) ~= "number" or found.mapID >= 100000 then return end
    return NS.Proximity.MapPoint(found.mapID, x, y)
end

local function isForever()
    local interface = GetBuildInfo and select(4, GetBuildInfo())
    return type(interface) == "number" and interface >= 16000 and interface < 17000
end

local function scannerDB()
    if not isForever() or not LibStub then return end
    local ace = LibStub("AceAddon-3.0", true)
    local addon = ace and ace:GetAddon("RareScanner", true)
    return addon and addon.db
end

local function rareScannerAvailable()
    return RSOverlayMixin ~= nil and type(RSOverlayMixin.OnAcquired) == "function"
        and type(RegisterStateDriver) == "function" and scannerDB() ~= nil
end

local function silverDragon()
    local addon = _G.SilverDragon
    if type(addon) == "table" and addon.db and type(RegisterStateDriver) == "function"
        and type(addon.NameForMob) == "function" and type(addon.GetData) == "function"
        and type(addon.GetXY) == "function" and type(addon.GetModule) == "function"
        and type(addon.IterateRelevantMobs) == "function" and type(addon.ShouldIgnoreMob) == "function" then
        return addon
    end
end

local function provider()
    if rareScannerAvailable() then return "RareScanner" end
    if silverDragon() then return "SilverDragon" end
end

function Integration.MarkingAvailable()
    return provider() ~= nil
end

function Integration.ButtonEnabled(app)
    return app.db.rareScannerButton ~= false and Integration.MarkingAvailable()
end

function Integration.ZoneAvailable()
    if provider() == "SilverDragon" then
        return C_Map ~= nil and type(C_Map.GetBestMapForUnit) == "function"
    end
    return rareScannerAvailable() and C_Map and type(C_Map.GetBestMapForUnit) == "function"
        and RSWorldMapButtonMixin and type(RSWorldMapButtonMixin.SetupMenu) == "function"
        and DropdownButtonMixin and type(DropdownButtonMixin.SetupMenu) == "function"
end

local silverZoneCache
local function addSilverDragonMob(entry, addon, id, zone, onlyZone)
    if addon:ShouldIgnoreMob(id, zone) or (onlyZone and addon.IsMobInPhase
        and not addon:IsMobInPhase(id, zone)) then return end
    local name = NS.Core.SafeName(addon:NameForMob(id))
    if not name or (UNKNOWN and name == UNKNOWN) or (UNKNOWNOBJECT and name == UNKNOWNOBJECT) then return end
    if not entry.names[name] then
        entry.names[name] = true
        entry.nameList[#entry.nameList + 1] = name
    end
    local data = addon:GetData(id)
    for mapID, coords in pairs(data and data.locations or {}) do
        if not onlyZone or mapID == zone then
            for _, coord in ipairs(coords) do
                if not addon.CoordGateMet or addon:CoordGateMet(data, mapID, coord) then
                    local x, y = addon:GetXY(coord)
                    if x ~= 0 or y ~= 0 then addPoint(entry, name, NS.Proximity.MapPoint(mapID, x, y)) end
                end
            end
        end
    end
end

local function silverDragonEntry(zoneSearch)
    local addon = silverDragon()
    if not addon then return end
    local zone = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local entry = {nameList={}, names={}, refs={}, mapPoints={}}
    if zoneSearch then
        if not zone then return end
        local now = GetTime()
        if silverZoneCache and silverZoneCache.addon == addon and silverZoneCache.zone == zone
            and now < silverZoneCache.expires then return silverZoneCache.entry end
        entry.scope = "SilverDragon:zone:" .. zone
        for id in addon:IterateRelevantMobs(zone, true) do addSilverDragonMob(entry, addon, id, zone, true) end
        table.sort(entry.nameList)
        entry.name = entry.nameList[1]
        entry = entry.name and entry or nil
        -- The catalogue can change as the provider learns names or applies filters.
        silverZoneCache = {addon=addon, zone=zone, expires=now + 10, entry=entry}
        return entry
    end

    silverZoneCache = nil
    local overlay = addon:GetModule("Overlay", true)
    local id = overlay and overlay.focus_id
    if type(id) ~= "number" or type(overlay.IsFocused) ~= "function" or not overlay:IsFocused(id, false) then return end
    entry.scope = "SilverDragon:focus:" .. id
    addSilverDragonMob(entry, addon, id, zone, false)
    entry.name = entry.nameList[1]
    if entry.name then return entry end
end

local function observeMark(_, x, y, _, _, _, source, groupPin)
    local poi = source and (groupPin and source or source.POI)
    local db = scannerDB()
    local overlays = db and db.char and db.char.overlayActive
    local id = poi and poi.entityID
    local record = id and overlays and overlays[id]
    if not record then return end
    local mark = observedMarks[id]
    if not mark or mark.record ~= record then
        mark = {record = record, points = {}}
        observedMarks[id] = mark
    end
    mark.npc = poi.isNpc == true
    mark.name = mark.npc and (NS.Core.SafeName(poi.name) or mark.name) or nil
    if mark.npc and type(poi.mapID) == "number" and poi.mapID < 100000 then
        mark.mapID = poi.mapID
        local point = (x ~= 0 or y ~= 0) and NS.Proximity.MapPoint(poi.mapID, x, y)
        if point then mark.points[point.mapID .. ":" .. point.x .. ":" .. point.y] = point end
    end
end

local function observeOverlays()
    if markHooked or not rareScannerAvailable() then return end
    hooksecurefunc(RSOverlayMixin, "OnAcquired", observeMark)
    markHooked = true
end

local function markedEntry(app)
    local db = scannerDB()
    local overlays = db and db.char and db.char.overlayActive
    local global = db and db.global
    if not global then return end
    local locale = GetLocale()
    local saved = app.db.rareScannerMarks
    if type(saved) ~= "table" or saved.locale ~= locale or type(saved.names) ~= "table" then
        saved = {locale=locale, names={}, maps={}}
        app.db.rareScannerMarks = saved
    end
    if type(saved.maps) ~= "table" then saved.maps = {} end
    local cachedNames = global.rare_names and global.rare_names[locale]
    local entry = {nameList = {}, names = {}, refs = {}, mapPoints = {}}
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    for id in pairs(saved.names) do
        if not overlays or not overlays[id] then saved.names[id], saved.maps[id] = nil, nil end
    end
    for id, mark in pairs(observedMarks) do
        if not overlays or overlays[id] ~= mark.record then observedMarks[id] = nil end
    end
    for id, overlay in pairs(overlays or {}) do
        if type(id) == "number" and type(overlay) == "table" then
            local seen = observedMarks[id]
            if seen then
                saved.names[id] = seen.npc and (seen.name or saved.names[id] or true) or nil
                saved.maps[id] = seen.npc and (seen.mapID or saved.maps[id]) or nil
            end
            local found = global.rares_found and global.rares_found[id]
            local knownRare = saved.names[id] or found
            if knownRare and (not seen or seen.npc) then
                local candidate = NS.Core.SafeName(cachedNames and cachedNames[id])
                    or NS.Core.SafeName(saved.names[id])
                if candidate then
                    if not entry.names[candidate] then
                        entry.names[candidate] = true
                        entry.nameList[#entry.nameList + 1] = candidate
                    end
                    local knownMap = saved.maps[id] or (type(found) == "table" and found.mapID)
                    for _, point in pairs(seen and seen.points or {}) do addPoint(entry, candidate, point) end
                    addSpawnPoints(entry, candidate, id, mapID)
                    if knownMap ~= mapID then addSpawnPoints(entry, candidate, id, knownMap) end
                    if not entry.mapPoints[candidate] then addPoint(entry, candidate, sightingPoint(found)) end
                end
            end
        end
    end
    table.sort(entry.nameList)
    entry.name = entry.nameList[1]
    if entry.name then return entry end
end

-- WoW instance map IDs to RareScanner's synthetic dungeon maps.
-- Some wings share an instance map ID and have separate RareScanner entries.
local dungeonMaps = {
    [33] = {100003}, -- Shadowfang Keep
    [36] = {100001}, -- Deadmines
    [43] = {100002}, -- Wailing Caverns
    [47] = {100004}, -- Razorfen Kraul
    [90] = {100006}, -- Gnomeregan
    [109] = {100005, 100022}, -- Temple of Atal'Hakkar / Sunken Temple
    [189] = {100007, 100033, 100034, 100035}, -- Scarlet Monastery
    [209] = {100010}, -- Zul'Farrak
    [229] = {100009, 100012}, -- Blackrock Spire
    [230] = {100008}, -- Blackrock Depths
    [329] = {100011, 100036}, -- Stratholme
    [349] = {100015}, -- Maraudon
    [429] = {100013, 100014, 100032}, -- Dire Maul
    [2970] = {100027}, -- The Drowned City
    [2974] = {100030, 100042}, -- Blackmaw Hold
    [2999] = {100023}, -- Ruins of Lordaeron
    [3039] = {100028}, -- Krol'dok Stronghold
}

local ignoredMenu = {
    SetEnabled = ignoreMenuItem, SetResponder = ignoreMenuItem, SetScrollMode = ignoreMenuItem,
    CreateTitle = ignoreMenuItem, CreateDivider = ignoreMenuItem, SetTag = ignoreMenuItem,
}
function ignoredMenu:CreateButton() return ignoredMenu end
ignoredMenu.CreateCheckbox = ignoredMenu.CreateButton

local function addZoneSpawns(entry, name, points)
    if not points or #points == 0 then return end
    if entry.fallbackPoints[name] then
        entry.mapPoints[name] = nil
        entry.fallbackPoints[name] = nil
    end
    for _, point in ipairs(points) do addPoint(entry, name, point) end
    entry.proximityRevision = nil
end

local function readZoneRares(mapID, entry)
    -- RareScanner builds the NPC filter from its zone catalogue, independently of visible pins.
    -- Collect the submenu labels without opening a menu or invoking any of its actions.
    local map = {GetMapID = function() return mapID end}
    local dropdown = {GetParent = function() return map end, IsShown = function() return false end}
    if RSWorldMapButtonMixin.OnLoad then RSWorldMapButtonMixin.OnLoad(dropdown) end
    RSWorldMapButtonMixin.SetupMenu(dropdown)
    if type(dropdown.menuGenerator) ~= "function" then return end

    local filter = setmetatable({}, {__index = ignoredMenu})
    function filter:CreateCheckbox(text)
        local label = text:gsub("|T.-|t", ""):gsub("|A.-|a", "")
        local rawName, id = label:match("^%s*(.-)%s+%((%d+)%)$")
        local name = NS.Core.SafeName(rawName)
        if name then
            id = tonumber(id)
            if not entry.names[name] then
                entry.names[name] = true
                entry.nameList[#entry.nameList + 1] = name
            end
            if canReadSpawns(mapID) then
                local cached = cachedSpawns(mapID)
                local points = cached and cached[id]
                if points then
                    addZoneSpawns(entry, name, points)
                else
                    local pending = entry.pendingSpawns
                    pending[#pending + 1] = {id=id, name=name, mapID=mapID}
                end
            end
            if not entry.mapPoints[name] then
                local point = sightingPoint(entry.sightings[id])
                if point then
                    addPoint(entry, name, point)
                    entry.fallbackPoints[name] = true
                end
            end
        end
        return ignoredMenu
    end
    local npcs = setmetatable({CreateButton = function() return filter end}, {__index = ignoredMenu})
    local root = setmetatable({}, {__index = ignoredMenu})
    function root:CreateButton()
        self.CreateButton = ignoredMenu.CreateButton
        return npcs
    end
    dropdown.menuGenerator(dropdown, root)
end

local function collectZoneRares(mapID, instanceID)
    local db = scannerDB()
    local sightings = db and db.global and db.global.rares_found
    local entry = {nameList = {}, names = {}, refs = {}, mapPoints = {}, sightings = sightings or {},
        fallbackPoints = {}, pendingSpawns = {}, scope = instanceID and ("dungeon:" .. instanceID) or mapID}
    local seen = {}
    local function read(id)
        if not id or seen[id] then return end
        seen[id] = true
        pcall(readZoneRares, id, entry)
    end
    local mapInfo = instanceID and mapID and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    local dungeonType = Enum and Enum.UIMapType and Enum.UIMapType.Dungeon
    -- In an instance, some clients may report the outdoor zone at the entrance.
    if not mapInfo or not dungeonType or mapInfo.mapType >= dungeonType then
        read(mapID)
        if instanceID and mapID and C_Map.GetMapGroupID and C_Map.GetMapGroupMembersInfo then
            local groupID = C_Map.GetMapGroupID(mapID)
            if groupID and groupID > 0 then
                for _, member in ipairs(C_Map.GetMapGroupMembersInfo(groupID) or {}) do read(member.mapID) end
            end
        end
    end
    for _, id in ipairs(instanceID and dungeonMaps[instanceID] or {}) do read(id) end
    table.sort(entry.nameList)
    entry.name = entry.nameList[1]
    return entry
end

local function zoneLocation()
    local mapID = C_Map.GetBestMapForUnit("player")
    local instanceID
    if GetInstanceInfo then
        local _, kind, _, _, _, _, _, id = GetInstanceInfo()
        if kind == "party" and type(id) == "number" and id > 0 then instanceID = id end
    end
    return mapID, instanceID
end

local function loadZoneSpawnBatch(app, cache)
    local entry = cache.entry
    local pending = entry.pendingSpawns
    if not pending or cache.scheduled or InCombatLockdown() then return end
    local last = math.min(cache.cursor + SPAWN_BATCH_SIZE - 1, #pending)
    for i = cache.cursor, last do
        local row = pending[i]
        addZoneSpawns(entry, row.name, spawnPoints(row.id, row.mapID))
    end
    cache.cursor = last + 1
    if cache.cursor > #pending then
        entry.pendingSpawns, entry.fallbackPoints, entry.sightings = nil, nil, nil
        return
    end
    cache.scheduled = true
    C_Timer.After(0, function()
        cache.scheduled = false
        if zoneCache ~= cache or InCombatLockdown() or app.db.rareScannerZone ~= true
            or app.db.rareScannerButton == false or not rareScannerAvailable() or not Integration.ZoneAvailable() then return end
        local mapID, instanceID = zoneLocation()
        if mapID == cache.mapID and instanceID == cache.instanceID then loadZoneSpawnBatch(app, cache) end
    end)
end

local function searchEntry(app)
    local source = provider()
    if source == "SilverDragon" then
        zoneCache = nil
        return silverDragonEntry(app.db.rareScannerZone == true and Integration.ZoneAvailable())
    end
    silverZoneCache = nil
    if source ~= "RareScanner" then return end
    if app.db.rareScannerZone ~= true or not Integration.ZoneAvailable() then
        zoneCache = nil
        return markedEntry(app)
    end
    local mapID, instanceID = zoneLocation()
    if not mapID and not instanceID then
        zoneCache = nil
        return
    end
    local now = GetTime()
    if not zoneCache or zoneCache.mapID ~= mapID or zoneCache.instanceID ~= instanceID
        or now >= zoneCache.refreshAt then
        zoneCache = {
            mapID = mapID, instanceID = instanceID, refreshAt = now + 15,
            entry = collectZoneRares(mapID, instanceID), cursor = 1,
        }
    end
    loadZoneSpawnBatch(app, zoneCache)
    local entry = zoneCache.entry
    if entry and entry.name then return entry end
end

function Integration.SearchEntry(app)
    if Integration.ButtonEnabled(app) then
        return searchEntry(app)
    end
end

local function prepareMarkMacro(target, entry, clicked, db)
    if InCombatLockdown() then return end
    local settings = NS.Core.TargetFeedbackSettings(db, "rare")
    local macro, nextIndex
    local proximity, core = NS.Proximity, NS.Core
    if entry then
        entry.distanceOrder = true
        proximity.Order(entry, clicked)
        entry.retryClosest = proximity.EntryDistance(entry, entry.name) ~= nil
    end
    local keepTarget = clicked and entry and core.ValidCurrentTarget(entry, true)
    local visible = clicked and entry and not keepTarget and core.NextUnit(entry, {})
    if visible then
        local name = core.SafeName(UnitName(visible))
        if name then
            local candidate = {name=name, nameList={name}, names={[name]=true}, refs={}}
            macro = core.ClickMacro(candidate, {}, settings, nil, nil, true)
            if macro and #entry.nameList == 1 then
                local clearDead = "\n/cleartarget [dead]"
                if #macro + #clearDead <= core.MACRO_BYTES then macro = macro .. clearDead
                else macro = core.Macro(name, settings) end
            end
            target.markIndex = nil
        end
    end
    -- The closest readable candidate takes precedence over a fallback page.
    if keepTarget then
        local feedback = NS.Core.MarkerMacro(settings, true)
        macro = feedback ~= "" and feedback or nil
    elseif not macro and entry and #entry.nameList > 1 then
        if target.markKey ~= entry.proximityKey or target.markScope ~= entry.scope
            or (target.markIndex and proximity.MovedFrom(target.markPosition)) then
            target.markIndex = nil
        end
        target.markKey, target.markScope = entry.proximityKey, entry.scope
        macro, nextIndex = NS.Core.EntryMacro(entry, settings, target.markIndex)
        if clicked then
            if not target.markIndex then target.markPosition = proximity.position end
            target.markIndex = nextIndex
        end
    elseif not macro then
        target.markKey, target.markScope, target.markIndex, target.markPosition = nil, nil, nil, nil
        if entry then
            macro = (settings.autoMark or settings.autoPing) and NS.Core.Macro(entry.name, settings)
                or "/targetexact " .. entry.name .. "\n/cleartarget [dead]"
        end
    end
    if target:GetAttribute("macrotext1") ~= macro then target:SetAttribute("macrotext1", macro) end
    target.markedNames = entry and entry.nameList or nil
    local active = entry ~= nil
    local alpha = db.hotkeysOnly and 0 or (active and 1 or 0.5)
    if target:GetAlpha() ~= alpha then target:SetAlpha(alpha) end
    if target.markActive ~= active then
        target.markActive = active
        for _, texture in ipairs({target:GetNormalTexture(), target:GetPushedTexture()}) do
            if active then texture:SetVertexColor(0.77, 0.52, 1)
            else texture:SetVertexColor(0.65, 0.65, 0.65) end
        end
    end
end

local function createMarkButton(app)
    local target = CreateFrame("Button", "QuestTargetsRareScannerMark", UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate")
    target:RegisterForClicks("AnyUp")
    target:SetAttribute("useOnKeyDown", false)
    target:SetAttribute("type1", "macro")
    -- Keep its place on the bar and block the action from clicks and bindings during combat.
    target:SetAttribute("_onstate-qtcombat", [[
        if newstate == "combat" then self:SetAttribute("type1", nil)
        else self:SetAttribute("type1", "macro") end
    ]])
    RegisterStateDriver(target, "qtcombat", "[combat] combat; ready")
    NS.UI.StyleTargetButton(target, 0.77, 0.52, 1)
    target:SetScript("PreClick", function(self, mouseButton, down)
        if mouseButton == "LeftButton" and not down and not InCombatLockdown() then
            NS.Proximity.Sample()
            prepareMarkMacro(self, Integration.ButtonEnabled(app) and searchEntry(app) or nil, true, app.db)
        end
    end)
    target:SetScript("OnEnter", function(self)
        if not app.db.showTooltips then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local silver = provider() == "SilverDragon"
        GameTooltip:SetText(NS.L(silver and "silverDragonButton" or "rareScannerButton"))
        GameTooltip:AddLine(NS.L("rareScannerBindingTip"), 1, 1, 1, true)
        local zone = app.db.rareScannerZone == true and Integration.ZoneAvailable()
        if zone then GameTooltip:AddLine(NS.L("rareScannerZone"), 0.82, 0.82, 0.82, true) end
        for _, name in ipairs(self.markedNames or {}) do GameTooltip:AddLine(name, 1, 1, 1, true) end
        if not self.markedNames then
            local empty = zone and "rareScannerNoZoneRares" or (silver and "silverDragonNoFocus" or "rareScannerNoMarks")
            GameTooltip:AddLine(NS.L(empty), 1, 0.82, 0, true)
        end
        GameTooltip:Show()
    end)
    target:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Integration.markButton = target
    return target
end

function Integration.SyncMark(app)
    if InCombatLockdown() or not NS.UI.master then return false end
    observeOverlays()
    local show = Integration.ButtonEnabled(app)
    local target = Integration.markButton
    local created = not target and show
    if created then target = createMarkButton(app) end
    if not target then return false end
    if not show then zoneCache, silverZoneCache = nil, nil end
    local entry = show and searchEntry(app) or nil
    prepareMarkMacro(target, entry, false, app.db)
    local mouseEnabled = not app.db.hotkeysOnly
    if target.mouseEnabled ~= mouseEnabled then
        target:EnableMouse(mouseEnabled)
        target.mouseEnabled = mouseEnabled
    end
    local visibilityChanged = target:IsShown() ~= show
    if visibilityChanged then target:SetShown(show) end
    if created or visibilityChanged then NS.UI.LayoutTargetButtons(app) end
    return entry or false
end

local function createFeedback()
    feedback = CreateFrame("Frame", nil, UIParent)
    Integration.feedback = feedback
    feedback:SetFrameStrata("TOOLTIP")
    feedback:EnableMouse(false)
    local ring = feedback:CreateTexture(nil, "ARTWORK")
    ring:SetAllPoints()
    ring:SetTexture("Interface\\AddOns\\QuestTargets\\Textures\\RarePulse")
    ring:SetVertexColor(0.55, 0.88, 0.86)
    feedback:Hide()
    feedback:SetScript("OnUpdate", function(self, delta)
        self.age = self.age + delta
        local progress = self.age / PULSE_DURATION
        if progress >= 1 then
            self:Hide()
            return
        end
        local size = self.startSize * (1 + progress * 0.95)
        self:SetSize(size, size)
        self:SetAlpha(PULSE_ALPHA * (1 - progress))
    end)
end

local function plainLeftClick(mouseButton)
    return mouseButton == "LeftButton" and not InCombatLockdown()
        and not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown()
end

local function pulseAt(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return end
    local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local size = math.max(frame:GetWidth(), frame:GetHeight()) * scale
    feedback:ClearAllPoints()
    feedback:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x * scale, y * scale)
    feedback.startSize = size * 1.2
    feedback.age = 0
    feedback:SetSize(feedback.startSize, feedback.startSize)
    feedback:SetAlpha(PULSE_ALPHA)
    feedback:Show()
end

local function clicked(self, mouseButton, down)
    if not down and plainLeftClick(mouseButton) and self:GetAttribute("macrotext1") then
        pulseAt(self)
    end
end

local function nameFor(pin)
    local poi = pin and pin.POI
    if type(poi) ~= "table" or not poi.isNpc or poi.worldmap then return end
    return NS.Core.SafeName(poi.name)
end

local function hide()
    if InCombatLockdown() or not button then return end
    button:Hide()
    button:SetAttribute("macrotext1", nil)
    activePin, activePOI = nil, nil
end

local function position(pin)
    if InCombatLockdown() then return false end
    local x, y = pin:GetCenter()
    if not x or not y then return false end
    local scale = pin:GetEffectiveScale() / UIParent:GetEffectiveScale()
    button:ClearAllPoints()
    -- No parent or anchor dependency on a pooled RareScanner frame: making
    -- those frames protected would prevent RareScanner recycling them in combat.
    button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x * scale, y * scale)
    button:SetSize(pin:GetWidth() * scale, pin:GetHeight() * scale)
    button:SetFrameStrata(pin:GetFrameStrata())
    button:SetFrameLevel(pin:GetFrameLevel() + 5)
    return true
end

local function show(pin)
    if InCombatLockdown() then return end
    local name = nameFor(pin)
    if not name or not pin:IsVisible() then hide(); return end
    if not position(pin) then hide(); return end
    activePin, activePOI = pin, pin.POI
    button:SetAttribute("macrotext1", "/targetexact " .. name)
    button:Show()
end

local function attach(pin)
    if not pin or hooked[pin] or not RSMinimapPinMixin
        or pin.OnEnter ~= RSMinimapPinMixin.OnEnter or pin:GetParent() ~= Minimap then return end
    hooked[pin] = true
    pin:HookScript("OnEnter", show)
end

local function minimapClicked(_, mouseButton)
    if not plainLeftClick(mouseButton) then return end
    -- The native Minimap can receive the click if the hover button did not
    -- acquire mouse focus. Check visible RareScanner pins on this input path.
    local hovered
    for pin in pairs(hooked) do
        if pin:IsVisible() and pin:IsMouseOver() and nameFor(pin)
            and (not hovered or pin:GetFrameLevel() > hovered:GetFrameLevel()) then
            hovered = pin
        end
    end
    if hovered then
        pulseAt(hovered)
        show(hovered)
    end
end

function Integration.Initialize()
    if installed or InCombatLockdown() then return end
    if not isForever() or not LibStub or not RSMinimapPinMixin or not RegisterStateDriver then return end
    local pins = LibStub("HereBeDragons-Pins-2.0", true)
    if not pins or type(pins.AddMinimapIconMap) ~= "function" then return end

    local gate = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    RegisterStateDriver(gate, "visibility", "[combat] hide; show")
    button = CreateFrame("Button", "QuestTargetsRareScannerTarget", gate, "SecureActionButtonTemplate")
    Integration.button = button
    button:Hide()
    button:RegisterForClicks("LeftButtonUp")
    button:SetAttribute("useOnKeyDown", false)
    button:SetAttribute("type1", "macro")
    createFeedback()
    button:SetScript("PostClick", clicked)
    for _, modifier in ipairs({"shift-", "ctrl-", "alt-", "ctrl-shift-", "alt-shift-", "alt-ctrl-", "alt-ctrl-shift-"}) do
        button:SetAttribute(modifier .. "type1", "")
    end
    button:SetScript("OnEnter", function()
        if InCombatLockdown() or not activePin then return end
        -- Preserve RareScanner's own tooltip (including deferred name resolution).
        local enter = activePin:GetScript("OnEnter")
        if enter then enter(activePin) end
    end)
    button:SetScript("OnLeave", function()
        if InCombatLockdown() then return end
        local leave = activePin and activePin:GetScript("OnLeave")
        if leave then leave(activePin) end
        hide()
    end)
    local elapsed = 0
    button:SetScript("OnUpdate", function(_, delta)
        if InCombatLockdown() then return end
        elapsed = elapsed + delta
        if elapsed < 0.05 then return end
        elapsed = 0
        if not activePin or not activePin:IsVisible() or activePin.POI ~= activePOI
            or not nameFor(activePin) then hide(); return end
        -- Pins move with the player. Refresh the hit area and any resolved name.
        show(activePin)
    end)
    hooksecurefunc(pins, "AddMinimapIconMap", function(_, _, pin) attach(pin) end)
    for _, pin in ipairs({Minimap:GetChildren()}) do attach(pin) end
    Minimap:HookScript("OnMouseUp", minimapClicked)
    installed = true
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" then hide() end
    observeOverlays()
    Integration.Initialize()
end)
observeOverlays()
