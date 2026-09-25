local _, NS = ...
local P = {revision = 0, movementYards = 10}
NS.Proximity = P

local function number(value)
    return NS.Core.Readable(value) and type(value) == "number"
        and value == value and math.abs(value) < math.huge
end

local function reset(db)
    local flavor = db.flavor and db.flavor.name
    if P.provider == db and P.flavor == flavor and P.support == db.Support
        and P.converter == db.EraToForever then return end
    P.provider, P.flavor, P.support, P.converter = db, flavor, db.Support, db.EraToForever
    P.spawns, P.names, P.points, P.distances, P.maps = {}, {}, {}, {}, nil
    P.revision = P.revision + 1
end

function P.Spawns(db, npcID)
    reset(db)
    if P.spawns[npcID] == nil then
        local ok, value = pcall(db.Npc.Get, npcID, "spawns")
        P.spawns[npcID] = ok and type(value) == "table" and value or false
    end
    return P.spawns[npcID] or nil
end

function P.Register(db, npcID, name)
    reset(db)
    if not P.names[name] then P.names[name] = {} end
    if P.names[name][npcID] then return end
    P.names[name][npcID] = true
    P.Spawns(db, npcID)
    P.distances[name] = nil
    P.revision = P.revision + 1
end

local function mapTable(value)
    if type(value) == "table" then return value end
    -- QuestieDB's documented support contract publishes these maps as Lua strings.
    if type(value) ~= "string" or not loadstring then return {} end
    local chunk = loadstring(value)
    if not chunk then return {} end
    if setfenv then setfenv(chunk, {}) end
    local ok, result = pcall(chunk)
    return ok and type(result) == "table" and result or {}
end

local function maps()
    if P.maps then return P.maps end
    P.maps = {}
    local support = P.support
    if not support or type(support.Get) ~= "function" then return P.maps end
    local ok, zone = pcall(support.Get, "ZoneDB")
    local data = ok and type(zone) == "table" and zone.private
    if type(data) ~= "table" then return P.maps end
    for area, uiMap in pairs(mapTable(data.areaIdToUiMapId)) do P.maps[area] = uiMap end
    for area, uiMap in pairs(mapTable(data.areaIdToUiMapIdOverride)) do P.maps[area] = uiMap end
    return P.maps
end

local function world(mapID, position)
    if not C_Map or type(C_Map.GetWorldPosFromMapPos) ~= "function" then return end
    local continent, point = C_Map.GetWorldPosFromMapPos(mapID, position)
    if number(continent) and point and number(point.x) and number(point.y) then
        return {continent = continent, x = point.x, y = point.y, mapID = mapID}
    end
end

local function playerPosition()
    if not C_Map or type(C_Map.GetBestMapForUnit) ~= "function"
        or type(C_Map.GetPlayerMapPosition) ~= "function" then return end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not number(mapID) then return end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if pos and number(pos.x) and number(pos.y) then return world(mapID, pos) end
end

-- Sample from the existing one-second poll, never from the click handler.
-- Distance calculations are invalidated only after cumulative movement or a map change.
function P.Sample()
    local ok, position = pcall(playerPosition)
    if not ok then position = nil end
    local previous = P.position
    if not position and not previous then return false end
    if position and previous and position.continent == previous.continent
        and position.mapID == previous.mapID
        and (position.x - previous.x)^2 + (position.y - previous.y)^2 < P.movementYards^2 then
        return false
    end
    if position and (not previous or position.mapID ~= previous.mapID
        or position.continent ~= previous.continent) then
        -- Retry unavailable map projections when the client enters a new map.
        P.points = {}
    end
    P.position, P.distances = position, {}
    P.revision = P.revision + 1
    return true
end

-- These four Era zone frames differ in Forever. Older providers cannot safely
-- rank their coordinates here without the additive conversion helper.
local changedFrames = {[215]=true, [139]=true, [44]=true, [1519]=true}
local function npcPoints(npcID)
    if P.points[npcID] then return P.points[npcID] end
    local result = {}
    local mapping = maps()
    local interface = GetBuildInfo and select(4, GetBuildInfo())
    local classicEra = type(interface) == "number" and interface >= 11500 and interface < 11600
    for areaID, coords in pairs(P.Spawns(P.provider, npcID) or {}) do
        local mapID = mapping[areaID]
        if number(mapID) and mapID > 0 and type(coords) == "table" and CreateVector2D then
            for _, coord in ipairs(coords) do
                local x, y = type(coord) == "table" and coord[1], type(coord) == "table" and coord[2]
                if number(x) and number(y) and x >= 0 and y >= 0 and x <= 100 and y <= 100 then
                    local ok, point = pcall(function()
                        if P.flavor == "Vanilla" and not classicEra then
                            if type(P.converter) == "function" then x, y = P.converter(areaID, x, y)
                            elseif changedFrames[areaID] then return end
                        end
                        if number(x) and number(y) then
                            return world(mapID, CreateVector2D(x / 100, y / 100))
                        end
                    end)
                    if ok and point then result[#result + 1] = point end
                end
            end
        end
    end
    P.points[npcID] = result
    return result
end

-- Squared world-yard distance; no sqrt and no assumed universal targeting radius.
function P.Distance(name)
    if not P.position or not P.names or not P.names[name] then return end
    if P.distances[name] ~= nil then return P.distances[name] or nil end
    local best, pos = nil, P.position
    for npcID in pairs(P.names[name]) do
        for _, point in ipairs(npcPoints(npcID)) do
            if point.continent == pos.continent then
                local distance = (point.x - pos.x)^2 + (point.y - pos.y)^2
                if not best or distance < best then best = distance end
            end
        end
    end
    P.distances[name] = best or false
    return best
end

function P.Order(entry)
    if not entry or not entry.nameList or entry.proximityRevision == P.revision then return end
    local distances = {}
    for _, name in ipairs(entry.nameList) do distances[name] = P.Distance(name) or math.huge end
    table.sort(entry.nameList, function(a, b)
        local af = entry.finisherNames and entry.finisherNames[a] == true or false
        local bf = entry.finisherNames and entry.finisherNames[b] == true or false
        if af ~= bf then return not af end
        if distances[a] ~= distances[b] then return distances[a] < distances[b] end
        return a < b
    end)
    entry.proximityRevision = P.revision
    entry.proximityKey = table.concat(entry.nameList, "\n")
end
