local _, NS = ...
local Core, Database = NS.Core, NS.Database
local Resolvers = {providers = {}}
NS.Resolvers = Resolvers

function Resolvers.Register(name, resolve)
    Resolvers.providers[#Resolvers.providers + 1] = {name = name, resolve = resolve}
end

-- Every provider returns { [liveObjectiveIndex] = { [npcName] = true } }.
-- Merge the sets so one quest button accepts every source, including sources
-- learned from visible nameplates by Core.BuildEntries.
function Resolvers.Resolve(quest)
    local result = {}
    for _, provider in ipairs(Resolvers.providers) do
        local ok, resolved = pcall(provider.resolve, quest, result)
        if ok and type(resolved) == "table" then
            for index, names in pairs(resolved) do
                if type(index) == "number" and type(names) == "table" then
                    local merged = result[index] or {}
                    for name, valid in pairs(names) do
                        if valid == true and Core.SafeName(name) == name then merged[name] = true end
                    end
                    result[index] = merged
                end
            end
        end
    end
    return result
end

Resolvers.Register("QuestieDB direct", Database.Resolve)

-- QuestieDB stores quest-level required source items but no explicit edge from
-- each source to a finished objective item. Infer that edge only for a single
-- DB item objective with one matching, still-open live item objective that has
-- no direct NPC source. This applies to every quest with that unambiguous shape.
local function conversionSources(quest, resolved)
    if not quest.objectives or #quest.objectives == 0 then return {} end
    local db = Database.Provider()
    if not db or Core.Clean(db.Quest.Get(quest.id, "name")) ~= Core.Clean(quest.title) then return {} end
    local dbObjectives = db.Quest.Get(quest.id, "objectives")
    local required = db.Quest.Get(quest.id, "requiredSourceItems")
    if type(dbObjectives) ~= "table" or type(required) ~= "table" then return {} end
    local itemRows = dbObjectives[3] or {}
    if #itemRows ~= 1 then return {} end
    local objectiveItem = itemRows[1][1]
    local objectiveName = Core.Clean(db.Item.Get(objectiveItem, "name"))
    if objectiveName == "" then return {} end
    local openItem, openCount = nil, 0
    for _, objective in ipairs(quest.objectives) do
        if objective.type == "item" and not next((resolved or {})[objective.index] or {}) then
            openCount = openCount + 1
            if Core.ObjectiveLabel(objective.text) == objectiveName then openItem = objective end
        end
    end
    if openCount ~= 1 or not openItem then return {} end
    local names = {}
    local outsideZone = false
    for _, sourceItem in ipairs(required) do
        if type(sourceItem) == "number" and sourceItem ~= objectiveItem then
            for _, npcID in ipairs(db.Item.Get(sourceItem, "npcDrops") or {}) do
                if type(npcID) == "number" and npcID > 0 then
                    local name = Core.SafeName(db.Npc.Get(npcID, "name"))
                    if name then
                        if NS.Proximity then NS.Proximity.Register(db, npcID, name) end
                        if Database.InZone(db, npcID) then names[name] = true
                        else outsideZone = true end
                    end
                end
            end
        end
    end
    if outsideZone and not next(names) then
        Database.zoneBlocked[quest.id] = Database.zoneBlocked[quest.id] or {}
        Database.zoneBlocked[quest.id][openItem.index] = true
    end
    return next(names) and {[openItem.index] = names} or {}
end

Resolvers.Register("QuestieDB source items", conversionSources)
