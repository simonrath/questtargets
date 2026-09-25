local _, NS = ...
local Core = NS.Core
local Scanner = {cursor = 1}
NS.Scanner = Scanner

-- Match typed Blizzard quest lines to the player's actual open objectives.
-- A title alone is never enough to associate an NPC with a specific objective.
function Scanner.Match(quests, data)
    local result, seen = {}, {}
    local enums = Enum and Enum.TooltipDataLineType
    if not enums or not Core.Readable(data) or type(data) ~= "table"
        or not Core.Readable(data.lines) or type(data.lines) ~= "table" then return result end
    local titles = {}
    for _, quest in ipairs(quests) do
        if titles[quest.title] ~= nil then titles[quest.title] = false
        else titles[quest.title] = quest end
    end
    local current
    for _, line in ipairs(data.lines) do
        if not Core.Readable(line) or type(line) ~= "table" or not Core.Readable(line.type)
            or not Core.Readable(line.leftText) then
            current = nil
        elseif line.type == enums.QuestTitle then
            current = titles[Core.Clean(line.leftText)] or nil
        elseif line.type == enums.QuestObjective then
            if current and Core.Readable(line.completed) and not line.completed then
                local label = Core.ObjectiveLabel(line.leftText)
                local match
                for _, objective in ipairs(current.objectives) do
                    -- Only mob kills and item drops. An attackable unit can also offer
                    -- interaction/event objectives; these must not become kill targets.
                    if (objective.type == "monster" or objective.type == "item")
                        and label ~= "" and label == Core.ObjectiveLabel(objective.text) then
                        if match then match = nil; break end -- ambiguous duplicate label
                        match = objective
                    end
                end
                if match then
                    local key = Core.ObjectiveKey(current.id, match.index)
                    if not seen[key] then
                        result[#result + 1] = {key = key, signature = Core.Signature(match)}
                        seen[key] = true
                    end
                end
            end
        elseif line.type ~= enums.QuestPlayer then
            current = nil
        end
    end
    return result
end

function Scanner.Available()
    return C_TooltipInfo and type(C_TooltipInfo.GetUnit) == "function"
        and C_NamePlate and type(C_NamePlate.GetNamePlates) == "function"
        and Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.QuestTitle ~= nil
        and Enum.TooltipDataLineType.QuestObjective ~= nil
end

function Scanner.Unit(unit, quests, learned)
    if InCombatLockdown() or not Scanner.Available() or type(unit) ~= "string" then return false end
    local exists = UnitExists(unit)
    local player, attackable, dead = UnitIsPlayer(unit), UnitCanAttack("player", unit), UnitIsDeadOrGhost(unit)
    if not Core.Readable(exists) or not Core.Readable(player) or not Core.Readable(attackable)
        or not Core.Readable(dead) or not exists or player or not attackable or dead then return false end
    local name = Core.SafeName(UnitName(unit))
    if not name then return false end
    -- This reads tooltip data directly from a nameplate token. No target change,
    -- mouseover, visible tooltip, synthetic click, or CVar change is involved.
    local ok, data = pcall(C_TooltipInfo.GetUnit, unit)
    if not ok then Scanner.lastError = true; return false end
    if name ~= Core.SafeName(UnitName(unit)) then return false end
    local changed = false
    for _, ref in ipairs(Scanner.Match(quests, data)) do
        local saved = learned[ref.key]
        if type(saved) ~= "table" or saved.signature ~= ref.signature or type(saved.names) ~= "table" then
            saved = {signature = ref.signature, names = {}}
            learned[ref.key] = saved
        end
        if not saved.names[name] then saved.names[name] = true; changed = true end
    end
    return changed
end

function Scanner.Scan(quests, learned)
    if InCombatLockdown() then return false end
    if #quests == 0 then Scanner.status = nil; return false end
    if not Scanner.Available() then
        Scanner.status = NS.L("scannerUnavailable")
        return false
    end
    Scanner.status = nil
    Scanner.lastError = nil
    local units, seen = {}, {}
    for _, plate in pairs(C_NamePlate.GetNamePlates() or {}) do
        local unit = Core.NameplateUnit(plate)
        if Core.Readable(unit) and type(unit) == "string" and not seen[unit] then
            units[#units + 1] = unit
            seen[unit] = true
        end
    end
    -- Stable order makes bounded periodic retries reach every visible nameplate.
    table.sort(units)
    if #units == 0 then
        Scanner.status = NS.L("scannerPlates")
        return false
    end
    local changed = false
    Scanner.cursor = math.min(Scanner.cursor, #units)
    for offset = 0, math.min(#units, 12) - 1 do
        local index = (Scanner.cursor + offset - 1) % #units + 1
        if Scanner.Unit(units[index], quests, learned) then changed = true end
    end
    Scanner.cursor = (Scanner.cursor + math.min(#units, 12) - 1) % #units + 1
    if Scanner.lastError then Scanner.status = NS.L("scannerLimited") end
    return changed
end
