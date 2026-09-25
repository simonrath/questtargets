local _, NS = ...
local Core = {}
NS.Core = Core
-- Conservative client-compatible byte budget. Never let the client truncate
-- a condition or a localized NPC name in the middle of a command.
Core.MACRO_BYTES = 255
local function readable(value)
    return not (issecretvalue and issecretvalue(value))
end
Core.Readable = readable

function Core.NameplateUnit(plate)
    local function valid(unit)
        return readable(unit) and type(unit) == "string" and unit:match("^nameplate%d+$") and unit or nil
    end
    -- Forever's NamePlateBaseMixin exposes GetUnit()/unitToken; older clients
    -- used namePlateUnitToken. A released modern frame must not reuse old fields.
    if type(plate.GetUnit) == "function" then
        local ok, unit = pcall(plate.GetUnit, plate)
        return ok and valid(unit) or nil
    end
    return valid(plate.unitToken) or valid(plate.namePlateUnitToken)
end

function Core.Clean(text)
    if not readable(text) or type(text) ~= "string" then return "" end
    return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):match("^%s*(.-)%s*$"))
end

function Core.SafeName(name)
    if not readable(name) or type(name) ~= "string" then return end
    name = Core.Clean(name)
    -- Never allow objective text or saved variables to inject macro commands/options.
    if name == "" or #name > 180 or name:find("[%c%[%];/|]") then return end
    return name
end

local function escape(text)
    return (text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

-- Compile Blizzard's localized printf format, including positional placeholders.
-- Captures only the name; progress numbers deliberately are not captures.
function Core.NameFromFormat(text, formatText)
    if type(formatText) ~= "string" or formatText == "" then return end
    local pattern, position, names = "^", 1, 0
    while position <= #formatText do
        local first, last, token = formatText:find("(%%[sd])", position)
        local pf, pl, pt = formatText:find("(%%%d+%$[sd])", position)
        if pf and (not first or pf < first) then first, last, token = pf, pl, pt end
        if not first then pattern = pattern .. escape(formatText:sub(position)); break end
        pattern = pattern .. escape(formatText:sub(position, first - 1))
        if token:sub(-1) == "s" then
            names = names + 1
            pattern = pattern .. "(.-)"
        else
            pattern = pattern .. "%d+"
        end
        position = last + 1
    end
    if names ~= 1 then return end
    return Core.SafeName(text:match(pattern .. "$"))
end

function Core.MobName(objective)
    if objective.type ~= "monster" then return end
    local text = Core.Clean(objective.text)
    local name = Core.NameFromFormat(text, QUEST_MONSTERS_KILLED)
    if name then return name end
    -- Some clients expose raw objective labels rather than the formatted leaderboard.
    -- Restrict fallbacks to known kill formats; never use an item/event as an NPC name.
    name = Core.NameFromFormat(text, "%s getötet: %d/%d")
        or Core.NameFromFormat(text, "%s slain: %d/%d")
    if name then return name end
    -- Modern quest/tooltip formats also put the count first or omit it entirely.
    local label = Core.ObjectiveLabel(text)
    name = Core.NameFromFormat(label, "%s getötet")
        or Core.NameFromFormat(label, "%s slain")
        or Core.NameFromFormat(text, "%s: %d/%d")
    return name
end

function Core.ObjectiveLabel(text)
    text = Core.Clean(text):gsub("\194\160", " ")
    text = text:gsub("^%s*%d+%s*/%s*%d+%s*[:%-]?%s*", "")
        :gsub("%s*:?%s*%d+%s*/%s*%d+%s*$", "")
    return (Core.Clean(text):gsub("%s+", " "))
end

function Core.Macro(name, settings, allowFriendly)
    name = Core.SafeName(name)
    if not name then return end
    -- Let the client's targeting rules choose the match. No scan, attack, or cast.
    -- Discard a dead match; this cannot search past a corpse or cycle same-name mobs.
    local text = "/stopmacro [combat,exists,harm,nodead]\n/cleartarget\n/targetexact " .. name .. "\n/cleartarget [dead]"
    if #text > Core.MACRO_BYTES then
        -- An unusually long name gets a complete command of its own. Preserve
        -- the previous target on a miss instead of clearing it beforehand.
        text = "/stopmacro [combat,harm,nodead]\n/targetexact " .. name .. "\n/cleartarget [dead]"
    end
    local marker = allowFriendly and "" or Core.MarkerMacro(settings)
    if #text + #marker <= Core.MACRO_BYTES then text = text .. marker end
    return text
end

function Core.MarkerMacro(settings, outsideCombat, allowFriendly)
    if not settings or not settings.autoMark then return "" end
    local icon = settings.markerIcon
    if type(icon) ~= "number" or icon < 1 or icon > 8 or icon % 1 ~= 0 then return "" end
    -- Native ! syntax sets the marker without toggling an existing identical mark.
    return "\n/tm [" .. (outsideCombat and "nocombat," or "")
        .. "exists," .. (allowFriendly and "" or "harm,") .. "nodead] !" .. icon
end

-- Rebuild on each hardware click: nameplate tokens can disappear or be reused.
-- Never retain a token for combat targeting or estimate distance from list order.
function Core.NextUnit(entry, entries)
    if InCombatLockdown() or not entry or not entry.name or not C_NamePlate
        or not C_NamePlate.GetNamePlates then return end
    local keys, names, candidates, seen = {}, {}, {}, {}
    for _, ref in ipairs(entry.refs) do keys[ref.key] = true end
    for name in pairs(entry.names or {}) do names[name] = true end
    for _, candidate in ipairs(entry.names and {} or entries) do
        if candidate.name then
            for _, ref in ipairs(candidate.refs) do
                if keys[ref.key] then names[candidate.name] = true end
            end
        end
    end
    local plateCount = 0
    for _, plate in pairs(C_NamePlate.GetNamePlates() or {}) do
        plateCount = plateCount + 1
        local unit = Core.NameplateUnit(plate)
        if readable(unit) and type(unit) == "string" and unit:match("^nameplate%d+$") then
            local exists, dead = UnitExists(unit), UnitIsDeadOrGhost(unit)
            local player, hostile = UnitIsPlayer(unit), UnitCanAttack("player", unit)
            if readable(exists) and exists and readable(dead) and not dead
                and readable(player) and not player and readable(hostile) then
                local name, guid = Core.SafeName(UnitName(unit)), UnitGUID and UnitGUID(unit)
                local identity = readable(guid) and type(guid) == "string" and guid or unit
                local questNPC = not hostile and entry.finisherNames and entry.finisherNames[name]
                if name and names[name] and (hostile or questNPC) and not seen[identity] then
                    seen[identity] = true
                    candidates[#candidates + 1] = {unit = unit, guid = readable(guid) and guid or nil,
                        friendly = not hostile}
                end
            end
        end
    end
    table.sort(candidates, function(a, b)
        if a.friendly ~= b.friendly then return not a.friendly end
        return tonumber(a.unit:match('%d+$')) < tonumber(b.unit:match('%d+$'))
    end)
    Core.lastCycle = {plates = plateCount, candidates = #candidates}
    local current = UnitGUID and UnitGUID("target")
    for index, candidate in ipairs(candidates) do
        local same = UnitIsUnit and UnitIsUnit(candidate.unit, "target")
        if (readable(same) and same) or (readable(current) and current and candidate.guid == current) then
            if #candidates == 1 then return end
            local nextCandidate = candidates[index % #candidates + 1]
            return nextCandidate.unit, nextCandidate.friendly
        end
    end
    return candidates[1] and candidates[1].unit, candidates[1] and candidates[1].friendly
end

function Core.ClickMacro(entry, entries, settings, state)
    Core.ConfirmSearchResult()
    Core.pendingSearch = nil -- a new hardware click supersedes the previous attempt
    Core.lastCycle = nil
    Core.lastClick = {path = "Keine Mobnamen", combat = InCombatLockdown()}
    if not entry or not entry.name then return end
    -- Prefer a concrete visible quest unit on the first click. If no valid
    -- nameplate token exists, fall back to name search for distant targets.
    local validCurrent = Core.ValidCurrentTarget(entry)
    local unit, friendly = Core.NextUnit(entry, entries)
    Core.lastClick.validCurrent = validCurrent
    Core.lastClick.unit = unit
    Core.lastClick.path = unit and "Namensplaketten-Wechsel" or (validCurrent and "Ziel behalten" or "Namenssuche")
    if validCurrent and not unit then
        -- A distant valid target may have no nameplate. Never clear it merely
        -- because there are no visible alternatives to cycle to.
        if entry.finisherNames and entry.finisherNames[Core.SafeName(UnitName("target"))] then
            -- Mark only a target already verified as a ready quest NPC. A secure
            -- macro must perform this action; a direct call from PostClick
            -- taints the protected Blizzard UI action.
            return Core.MarkerMacro(settings, true, true)
        end
        return Core.MarkerMacro(settings, true, false)
    end
    if not validCurrent and not unit then
        if NS.Proximity then
            NS.Proximity.Order(entry)
            if state and state.proximityKey ~= entry.proximityKey then
                state.fallbackIndex, state.fallbackFinisherIndex = nil, nil
                state.proximityKey = entry.proximityKey
            end
        end
        local startIndex = state and state.fallbackIndex
        local finisherIndex = state and state.fallbackFinisherIndex
        local macro, nextIndex, nextFinisher = Core.EntryMacro(entry, settings, startIndex, finisherIndex)
        if state then
            state.fallbackIndex = nextIndex
            state.fallbackFinisherIndex = nextFinisher
            -- Advance on failure, but remember the attempted page until the
            -- secure action's result is visible. PostClick can be too early.
            Core.pendingSearch = {state = state, entry = entry, macro = macro,
                startIndex = startIndex, finisherIndex = finisherIndex,
                proximityKey = entry.proximityKey, click = Core.lastClick}
        end
        return macro
    end
    if state then state.fallbackIndex = nil; state.fallbackFinisherIndex = nil end
    -- A readable nameplate token is useful for detection, but direct secure
    -- targeting of that token fails on the tested client. Use its verified name.
    -- This is a name search, NOT selection of a particular same-name instance.
    local name = Core.SafeName(UnitName(unit))
    if not name then return Core.EntryMacro(entry, settings) end
    Core.lastClick.path = "Namenssuche aus Namensplakette"
    Core.lastClick.name = name
    -- Do not clear an existing valid target if the visible unit disappears.
    return "/targetexact [nocombat] " .. name
        .. (friendly and "" or Core.MarkerMacro(settings, true))
end

function Core.ValidCurrentTarget(entry)
    if InCombatLockdown() then return false end
    local exists, dead = UnitExists("target"), UnitIsDeadOrGhost("target")
    local player, hostile = UnitIsPlayer("target"), UnitCanAttack("player", "target")
    if not readable(exists) or not exists or not readable(dead) or dead
        or not readable(player) or player or not readable(hostile) then return false end
    local name = Core.SafeName(UnitName("target"))
    if not name then return false end
    -- Quest turn-in NPCs are friendly. Only the masterbutton's verified ready
    -- finishers qualify; a friendly NPC with an unrelated mob name does not.
    if entry.finisherNames and entry.finisherNames[name] then return true end
    if not hostile then return false end
    return entry.names and entry.names[name] == true or (not entry.names and entry.name == name)
end

function Core.ConfirmSearchResult()
    local attempt = Core.pendingSearch
    if not attempt or not attempt.macro or InCombatLockdown() then return end
    local entry = attempt.state.entry or attempt.entry
    if entry.questID ~= attempt.entry.questID
        or entry.proximityKey ~= attempt.proximityKey
        or not Core.ValidCurrentTarget(entry) then return end
    local name = Core.SafeName(UnitName("target"))
    if not name then return end
    -- Only credit a living, valid target actually included in this attempt.
    -- Also covers the single-name fallback for unusually long NPC names.
    local text = attempt.macro .. "\n"
    if not text:find("/targetexact [noexists] " .. name .. "\n", 1, true)
        and not text:find("/targetexact " .. name .. "\n", 1, true) then return end
    attempt.state.fallbackIndex = attempt.startIndex
    attempt.state.fallbackFinisherIndex = attempt.finisherIndex
    attempt.click.selected = "true"
    Core.pendingSearch = nil
end

function Core.RecordClickResult()
    Core.ConfirmSearchResult()
    local click = Core.lastClick
    if click and click.name and not InCombatLockdown() then
        local name = Core.SafeName(UnitName("target"))
        local dead, player = UnitIsDeadOrGhost("target"), UnitIsPlayer("target")
        click.selected = tostring(name == click.name and readable(dead) and not dead
            and readable(player) and not player)
        return
    end
    if not click or not click.unit or not UnitIsUnit or InCombatLockdown() then return end
    local same = UnitIsUnit(click.unit, "target")
    click.selected = readable(same) and tostring(same) or "nicht lesbar"
end

function Core.EntryMacro(entry, settings, startIndex, finisherIndex)
    if not entry or not entry.name then return end
    if not entry.names then return Core.Macro(entry.name, settings) end
    -- Combat does not permit validating arbitrary current target names. Preserve
    -- any living hostile target rather than risk losing an already valid one.
    local commands = "/stopmacro [combat,exists,harm,nodead]\n/cleartarget"
    local allowFriendly = entry.finisherNames and next(entry.finisherNames) ~= nil
    local tail = Core.MarkerMacro(settings)
    -- Leave no dead match blocking subsequent alternatives. Keep within the
    -- secure macro text budget; the visible-unit cycle still includes all names.
    if NS.Proximity then NS.Proximity.Order(entry) end
    local count = #entry.nameList
    if count == 0 then return end
    if allowFriendly then
        local mobCount = entry.mobCount or 0
        local finisherCount = count - mobCount
        local firstFinisher = type(finisherIndex) == "number"
            and ((math.abs(finisherIndex) - 1) % finisherCount + 1) or 1
        local function targetLine(name)
            return "\n/targetexact [noexists] " .. name .. "\n/cleartarget [dead]"
        end
        local reserved = targetLine(entry.nameList[mobCount + firstFinisher])
        local mobIndex = mobCount > 0 and
            (type(startIndex) == "number" and ((startIndex - 1) % mobCount + 1) or 1) or 1
        -- If both roles cannot fit in one macro, try the mob first and the NPC
        -- on the next unsuccessful click. A negative cursor records that debt.
        -- Never let the reserved NPC line permanently starve a long mob name.
        if type(finisherIndex) == "number" and finisherIndex < 0 then
            return Core.Macro(entry.nameList[mobCount + firstFinisher], settings, true),
                mobIndex, firstFinisher % finisherCount + 1
        end
        if mobCount > 0 and #commands + #targetLine(entry.nameList[mobIndex])
            + #reserved + #tail > Core.MACRO_BYTES then
            return Core.Macro(entry.nameList[mobIndex], settings),
                mobIndex % mobCount + 1, -firstFinisher
        end
        -- Always leave room for a ready quest NPC. Otherwise many mob names
        -- push every finisher past the 255-byte secure macro limit.
        for _ = 1, mobCount do
            local line = targetLine(entry.nameList[mobIndex])
            if #commands + #line + #reserved + #tail > Core.MACRO_BYTES then break end
            commands = commands .. line
            mobIndex = mobIndex % mobCount + 1
        end
        if #commands + #reserved + #tail > Core.MACRO_BYTES then
            return Core.Macro(entry.nameList[mobCount + firstFinisher], settings, true),
                mobIndex, firstFinisher % finisherCount + 1
        end
        commands = commands .. reserved
        local nextFinisher = firstFinisher % finisherCount + 1
        for _ = 2, finisherCount do
            local line = targetLine(entry.nameList[mobCount + nextFinisher])
            if #commands + #line + #tail > Core.MACRO_BYTES then break end
            commands = commands .. line
            nextFinisher = nextFinisher % finisherCount + 1
        end
        return commands .. tail, mobIndex, nextFinisher
    end
    local index = type(startIndex) == "number" and ((startIndex - 1) % count + 1) or 1
    for offset = 1, count do
        local name = entry.nameList[index]
        local line = "\n/targetexact [noexists] " .. name .. "\n/cleartarget [dead]"
        if #commands + #line + #tail > Core.MACRO_BYTES then
            if offset == 1 then return Core.Macro(name, settings,
                entry.finisherNames and entry.finisherNames[name] == true), index % count + 1 end
            break
        end
        commands = commands .. line
        index = index % count + 1
    end
    return commands .. tail, index
end

-- Preserve objective-level source data, but display each quest exactly once.
function Core.QuestEntries(entries)
    local result, byID = {}, {}
    for _, source in ipairs(entries) do
        for _, ref in ipairs(source.refs) do
            local quest = byID[ref.questID]
            if not quest then
                quest = {questID = ref.questID, title = ref.title, refs = {}, names = {},
                    nameList = {}, keys = {}, done = 0, total = 0}
                byID[ref.questID] = quest
                result[#result + 1] = quest
            end
            if not quest.keys[ref.key] then
                quest.keys[ref.key] = true
                quest.refs[#quest.refs + 1] = ref
                quest.done = quest.done + ref.done
                quest.total = quest.total + ref.total
            end
            if source.name and not quest.names[source.name] then
                quest.names[source.name] = true
                quest.nameList[#quest.nameList + 1] = source.name
            end
        end
    end
    for _, quest in ipairs(result) do
        table.sort(quest.nameList)
        table.sort(quest.refs, function(a, b) return a.key < b.key end)
        quest.name = quest.nameList[1]
    end
    return result
end

function Core.ObjectiveKey(questID, index)
    return tostring(questID) .. ":" .. tostring(index)
end

function Core.Signature(objective)
    return tostring(objective.type) .. ":" .. Core.ObjectiveLabel(objective.text)
end

function Core.ReadQuests(watchedOnly)
    local api = C_QuestLog
    if not api or type(api.GetNumQuestLogEntries) ~= "function"
        or type(api.GetInfo) ~= "function" or type(api.GetQuestObjectives) ~= "function" then
        return {}, NS.L("apiMissing")
    end
    if watchedOnly and type(api.GetQuestWatchType) ~= "function" then
        return {}, NS.L("filterMissing")
    end
    local result, seen, pending = {}, {}, false
    local count = api.GetNumQuestLogEntries()
    if not readable(count) or type(count) ~= "number" then return {}, NS.L("logPending") end
    for index = 1, count do
        local info = api.GetInfo(index)
        if info and readable(info.questID) and readable(info.isHeader) and not info.isHeader
            and type(info.questID) == "number" and info.questID > 0 and not seen[info.questID] then
            seen[info.questID] = true
            local included = true
            if watchedOnly then
                local watch = api.GetQuestWatchType(info.questID)
                included = readable(watch) and watch ~= nil
            end
            if included then
                local objectives = api.GetQuestObjectives(info.questID)
                local ready = false
                if type(api.ReadyForTurnIn) == "function" then
                    local ok, value = pcall(api.ReadyForTurnIn, info.questID)
                    ready = ok and readable(value) and value == true
                elseif type(api.IsComplete) == "function" then
                    local ok, value = pcall(api.IsComplete, info.questID)
                    ready = ok and readable(value) and value == true
                end
                local quest = {id = info.questID, title = Core.Clean(info.title), objectives = {}, typeCounts = {}, ready = ready}
                if quest.title == "" then quest.title = "Quest " .. info.questID end
                if type(objectives) == "table" then
                    for objectiveIndex, source in ipairs(objectives) do
                        if readable(source.type) and type(source.type) == "string" then
                            quest.typeCounts[source.type] = (quest.typeCounts[source.type] or 0) + 1
                        end
                        if readable(source.text) and source.text == nil then pending = true end
                        if readable(source.finished) and readable(source.type) and readable(source.text)
                            and readable(source.numFulfilled) and readable(source.numRequired)
                            and not ready and not source.finished and type(source.type) == "string"
                            and type(source.text) == "string" then
                            local done = type(source.numFulfilled) == "number" and source.numFulfilled or 0
                            local total = type(source.numRequired) == "number" and source.numRequired or 0
                            if total <= 0 or done < total then
                                quest.objectives[#quest.objectives + 1] = {
                                    index = objectiveIndex, text = source.text, type = source.type,
                                    done = done, total = total,
                                }
                            end
                        end
                    end
                else
                    pending = true
                end
                result[#result + 1] = quest
            end
        end
    end
    return result, nil, pending
end

local function sameResolutionInput(snapshot, quest)
    if not snapshot or snapshot.title ~= quest.title or snapshot.id ~= quest.id
        or #snapshot.objectives ~= #quest.objectives then return false end
    for index, objective in ipairs(quest.objectives) do
        local previous = snapshot.objectives[index]
        if previous.index ~= objective.index or previous.type ~= objective.type
            or previous.text ~= objective.text then return false end
    end
    for kind, count in pairs(quest.typeCounts or {}) do
        if snapshot.typeCounts[kind] ~= count then return false end
    end
    for kind, count in pairs(snapshot.typeCounts) do
        if (quest.typeCounts or {})[kind] ~= count then return false end
    end
    return true
end

local function resolutionSnapshot(quest, names)
    local snapshot = {id = quest.id, title = quest.title, objectives = {}, typeCounts = {}, names = names}
    for index, objective in ipairs(quest.objectives) do
        snapshot.objectives[index] = {index = objective.index, type = objective.type, text = objective.text}
    end
    for kind, count in pairs(quest.typeCounts or {}) do snapshot.typeCounts[kind] = count end
    return snapshot
end

function Core.BuildEntries(quests, learned, resolutionCache)
    local entries, byName, activeKeys = {}, {}, {}
    local unresolved, objectives = 0, 0
    for _, quest in ipairs(quests) do
        local cached = resolutionCache and resolutionCache[quest.id]
        local databaseNames
        if sameResolutionInput(cached, quest) then
            databaseNames = cached.names
        else
            databaseNames = NS.Resolvers and NS.Resolvers.Resolve(quest)
                or (NS.Database and NS.Database.Resolve(quest) or {})
            if resolutionCache then
                resolutionCache[quest.id] = resolutionSnapshot(quest, databaseNames)
            end
        end
        for _, objective in ipairs(quest.objectives) do
            objectives = objectives + 1
            local key = Core.ObjectiveKey(quest.id, objective.index)
            local signature = Core.Signature(objective)
            local saved = learned[key]
            local names, unique, observed = {}, {}, {}
            local dbNames = databaseNames[objective.index] or {}
            for name in pairs(dbNames) do
                if Core.SafeName(name) == name then unique[name] = true end
            end
            if type(saved) == "table" and saved.signature == signature and type(saved.names) == "table" then
                for name, confirmed in pairs(saved.names) do
                    if confirmed == true and Core.SafeName(name) == name then unique[name] = true; observed[name] = true end
                end
            end
            for name in pairs(unique) do names[#names + 1] = name end
            table.sort(names)
            if #names == 0 and not (NS.Database and NS.Database.BlockedByZone(quest.id, objective.index)) then
                local parsed = Core.MobName(objective)
                if parsed then names[1] = parsed end
            end
            local ref = {key = key, signature = signature, questID = quest.id, title = quest.title,
                text = Core.Clean(objective.text), done = objective.done, total = objective.total,
            }
            activeKeys[key] = ref
            if #names == 0 then
                unresolved = unresolved + 1
                entries[#entries + 1] = {refs = {ref}, done = ref.done, total = ref.total}
            end
            for _, name in ipairs(names) do
                local entry = byName[name]
                if not entry then
                    entry = {name = name, refs = {}, done = 0, total = 0}
                    entries[#entries + 1] = entry
                    byName[name] = entry
                end
                local displayRef = {}
                for field, value in pairs(ref) do displayRef[field] = value end
                displayRef.detected = observed[name] == true
                displayRef.database = dbNames[name] == true
                entry.refs[#entry.refs + 1] = displayRef
                entry.done = entry.done + ref.done
                entry.total = entry.total + ref.total
            end
        end
    end
    -- Keep questlog order within each group, but put usable target buttons first.
    local sorted = {}
    for _, entry in ipairs(entries) do if entry.name then sorted[#sorted + 1] = entry end end
    for _, entry in ipairs(entries) do if not entry.name then sorted[#sorted + 1] = entry end end
    return sorted, {unresolved = unresolved, objectives = objectives, activeKeys = activeKeys}
end
