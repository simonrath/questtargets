local _, NS = ...
local Core = NS.Core
local Database = {status = NS.L("dbMissing")}
NS.Database = Database
Database.zoneBlocked = {}

local function zoneNames()
    if not C_Map or type(C_Map.GetAreaInfo) ~= "function" then return end
    local names = {}
    local function add(name)
        if type(name) == "string" and name ~= "" then names[name] = true end
    end
    if type(GetRealZoneText) == "function" then add(GetRealZoneText()) end
    if type(GetZoneText) == "function" then add(GetZoneText()) end
    if type(C_Map.GetBestMapForUnit) == "function" and type(C_Map.GetMapInfo) == "function" then
        local mapID = C_Map.GetBestMapForUnit("player")
        for _ = 1, 12 do
            if type(mapID) ~= "number" or mapID <= 0 then break end
            local info = C_Map.GetMapInfo(mapID)
            if type(info) ~= "table" then break end
            add(info.name)
            if info.parentMapID == mapID then break end
            mapID = info.parentMapID
        end
    end
    return next(names) and names or nil
end

function Database.RefreshZone()
    Database.currentZoneNames = zoneNames()
    Database.zoneBlocked = {}
    Database.zoneEligibility = {}
end

function Database.InZone(db, npcID)
    local current = Database.currentZoneNames
    if current == nil then return true end
    local cached = Database.zoneEligibility and Database.zoneEligibility[npcID]
    if cached ~= nil then return cached end
    local spawns
    if NS.Proximity then spawns = NS.Proximity.Spawns(db, npcID)
    else spawns = db.Npc.Get(npcID, "spawns") end
    if type(spawns) ~= "table" or not next(spawns) then
        Database.zoneEligibility[npcID] = true
        return true
    end
    local known = false
    for areaID in pairs(spawns) do
        local areaName = C_Map.GetAreaInfo(areaID)
        if type(areaName) == "string" and areaName ~= "" then
            known = true
            if current[areaName] then
                Database.zoneEligibility[npcID] = true
                return true
            end
        end
    end
    Database.zoneEligibility[npcID] = not known
    return not known
end

function Database.BlockedByZone(questID, objectiveIndex)
    return Database.zoneBlocked[questID] and Database.zoneBlocked[questID][objectiveIndex]
end

local function id(value)
    return type(value) == "number" and value > 0 and value % 1 == 0
end

local function label(text, kind)
    local clean = Core.ObjectiveLabel(text)
    if kind == "monster" then
        clean = Core.MobName({type = kind, text = clean}) or clean
    end
    return clean
end

function Database.Provider()
    local db = LibQuestieDB
    if type(db) ~= "table" then Database.status = NS.L("dbMissing"); return end
    if type(db.RequireContract) ~= "function" then Database.status = NS.L("dbUpdate"); return end
    local ok, compatible = pcall(db.RequireContract, 1)
    if not ok or not compatible then Database.status = NS.L("dbIncompatible"); return end
    for _, entity in ipairs({"Quest", "Npc", "Item"}) do
        if type(db[entity]) ~= "table" or type(db[entity].Get) ~= "function" then
            Database.status = NS.L("dbIncomplete"); return
        end
    end
    local locale = GetLocale()
    if locale == "enGB" then locale = "enUS" end
    if not db.l10n or db.l10n.currentLocale ~= locale then
        Database.status = NS.L("dbLocale"); return
    end
    -- Native Forever data and the legacy Vanilla baseline are supported.
    -- Proximity handles their different coordinate frames independently.
    if not db.flavor or (db.flavor.name ~= "Vanilla" and db.flavor.name ~= "Forever") then
        Database.status = NS.L("dbClassic"); return
    end
    Database.status = db.readMode == "source" and NS.L("dbSource") or (db.flavor.name == "Forever" and "QuestieDB · Forever" or "QuestieDB · Classic")
    return db
end

local function resolveQuest(db, quest)
    local result = {}
    -- IDs may be reused or changed in Forever. A mismatching localized quest title
    -- is evidence against applying the Classic record to the running quest.
    if Core.Clean(db.Quest.Get(quest.id, "name")) ~= Core.Clean(quest.title) then return result end
    local objectives = db.Quest.Get(quest.id, "objectives")
    if type(objectives) ~= "table" then return result end
    local candidates = {monster = {}, item = {}}
    local function candidate(kind, entityID, description, npcIDs, explicitIndex)
        local entry = {labels = {}, ids = {}, explicitIndex = explicitIndex}
        local function alias(value)
            local text = label(value, kind)
            if text ~= "" then entry.labels[text] = true end
        end
        alias(description)
        if id(entityID) then alias(db[kind == "item" and "Item" or "Npc"].Get(entityID, "name")) end
        for _, npcID in ipairs(npcIDs or {}) do if id(npcID) then entry.ids[npcID] = true end end
        candidates[kind][#candidates[kind] + 1] = entry
    end
    for _, row in ipairs(objectives[1] or {}) do
        candidate("monster", row[1], row[2], {row[1]})
    end
    -- [1] contains every real NPC granting the shared credit. [2] may be a
    -- synthetic kill-credit NPC and must not itself become a target.
    for _, row in ipairs(objectives[5] or {}) do
        candidate("monster", row[2], row[3], row[1], id(row[4]) and row[4] or nil)
    end
    for _, row in ipairs(objectives[3] or {}) do
        local drops, queue, visited = {}, {row[1]}, {}
        local cursor = 1
        -- Also follow items that contain the required item. This is an iterative
        -- traversal so cycles cannot loop and every known source is retained.
        while cursor <= #queue do
            local itemID = queue[cursor]
            cursor = cursor + 1
            if id(itemID) and not visited[itemID] then
                visited[itemID] = true
                for _, npcID in ipairs(db.Item.Get(itemID, "npcDrops") or {}) do drops[#drops + 1] = npcID end
                for _, parentID in ipairs(db.Item.Get(itemID, "itemDrops") or {}) do queue[#queue + 1] = parentID end
            end
        end
        -- Vendors, quest givers, and objectDrops are deliberately not kill targets.
        candidate("item", row[1], row[2], drops)
    end
    local counts = quest.typeCounts or {}
    if not quest.typeCounts then
        for _, objective in ipairs(quest.objectives) do counts[objective.type] = (counts[objective.type] or 0) + 1 end
    end
    for _, objective in ipairs(quest.objectives) do
        local available = candidates[objective.type]
        if available then
            local wanted, match, matches = label(objective.text, objective.type), nil, 0
            for _, entry in ipairs(available) do
                if (entry.explicitIndex and entry.explicitIndex == objective.index)
                    or (not entry.explicitIndex and entry.labels[wanted]) then
                    match, matches = entry, matches + 1
                end
            end
            -- One objective of this type in BOTH the full live quest and DB is
            -- unambiguous even if its narrative label differs from NPC/item names.
            -- Never use the index of a filtered (unfinished-only) list to map goals.
            if matches == 0 and counts[objective.type] == 1 and #available == 1
                and (not available[1].explicitIndex or available[1].explicitIndex == objective.index) then
                match, matches = available[1], 1
            end
            if matches == 1 then
                local names = {}
                local outsideZone = false
                for npcID in pairs(match.ids) do
                    local name = Core.SafeName(db.Npc.Get(npcID, "name"))
                    if name then
                        if NS.Proximity then NS.Proximity.Register(db, npcID, name) end
                        if Database.InZone(db, npcID) then names[name] = true
                        else outsideZone = true end
                    end
                end
                if outsideZone and not next(names) then
                    Database.zoneBlocked[quest.id][objective.index] = true
                end
                result[objective.index] = names
            end
        end
    end
    return result
end

function Database.Resolve(quest)
    Database.zoneBlocked[quest.id] = {}
    local db = Database.Provider()
    if not db then return {} end
    -- A broken/new provider must not break the rest of the UI. Expose the failure
    -- instead of silently claiming that the database answered an empty query.
    local ok, result = pcall(resolveQuest, db, quest)
    if not ok then Database.status = NS.L("dbRead"); return {} end
    return result
end

function Database.ResolveTurnIns(quest)
    if not quest.ready then return {} end
    local db = Database.Provider()
    if not db then return {} end
    local ok, names = pcall(function()
        if Core.Clean(db.Quest.Get(quest.id, "name")) ~= Core.Clean(quest.title) then return {} end
        local finishers = db.Quest.Get(quest.id, "finishedBy")
        local result = {}
        if type(finishers) == "table" then
            -- [1] holds NPC IDs; [2] holds objects, which cannot be targeted.
            for _, npcID in ipairs(finishers[1] or {}) do
                if id(npcID) then
                    local name = Core.SafeName(db.Npc.Get(npcID, "name"))
                    if name then
                        if NS.Proximity then NS.Proximity.Register(db, npcID, name) end
                        if Database.InZone(db, npcID) then result[name] = true end
                    end
                end
            end
        end
        return result
    end)
    if not ok then Database.status = NS.L("dbRead"); return {} end
    return names
end
