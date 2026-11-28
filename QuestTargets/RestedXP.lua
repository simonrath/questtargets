local _, NS = ...
local Core, UI, Proximity = NS.Core, NS.UI, NS.Proximity
local Integration = {}
NS.RestedXP = Integration

local function restedXP()
    if not LibStub then return end
    local ok, ace = pcall(LibStub, "AceAddon-3.0", true)
    if not ok or not ace or type(ace.GetAddon) ~= "function" then return end
    local found, addon = pcall(ace.GetAddon, ace, "RXPGuides", true)
    if found and type(addon) == "table" and addon.RXPFrame
        and type(addon.RXPFrame.activeSteps) == "table"
        and type(addon.GetCreatureName) == "function" then return addon end
end

local function currentNames(rxp, validNames)
    local names, seen, guideFriendlyNames = {}, {}, {}
    local targeting = rxp.targeting
    if targeting and type(targeting.GetCurrentTargets) == "function" then
        local ok, targets, mobs, unitscan = pcall(targeting.GetCurrentTargets)
        if ok and type(targets) == "table" and type(mobs) == "table"
            and type(unitscan) == "table" then
            -- These are the effective lists after RestedXP filters completed or
            -- inactive guide elements. They already contain localized names.
            for _, list in ipairs({unitscan, mobs, targets}) do
                for _, raw in ipairs(list) do
                    local name = Core.SafeName(raw)
                    if name and not seen[name] then
                        seen[name] = true
                        names[#names + 1] = name
                    end
                    if list == targets and name and not validNames[name] then
                        guideFriendlyNames[name] = true
                    end
                end
            end
            return names, guideFriendlyNames
        end
    end
    -- Older RestedXP builds have no public target-list accessor.
    for _, step in ipairs(rxp.RXPFrame.activeSteps) do
        if step.active == true then
            for _, element in ipairs(step.elements or {}) do
                for _, key in ipairs({"unitscan", "mobs", "targets"}) do
                    for _, id in ipairs(element[key] or {}) do
                        local ok, raw = pcall(rxp.GetCreatureName, id)
                        if ok and type(raw) == "string" then
                            local name = Core.SafeName(raw:gsub("^%*", ""))
                            if name then
                                if key == "targets" and not validNames[name] then
                                    guideFriendlyNames[name] = true
                                end
                                if not seen[name] then
                                    seen[name] = true
                                    names[#names + 1] = name
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return names, guideFriendlyNames
end

-- Polestar's view includes applicability, completion and its chosen NPC.
local function polestarNames(validNames)
    local ps = _G.Polestar
    local engine = ps and ps.Engine
    if type(engine) ~= "table" or type(engine.GetStepIndex) ~= "function"
        or type(engine.GetStepView) ~= "function" then return end
    local ok, index = pcall(engine.GetStepIndex)
    if not ok or type(index) ~= "number" then return {}, {} end
    local got, view = pcall(engine.GetStepView, index, true)
    if not got or type(view) ~= "table" or type(view.goals) ~= "table" then return {}, {} end
    local raw = {}
    if type(engine.GetGuide) == "function" then
        local success, guide = pcall(engine.GetGuide)
        local step = success and type(guide) == "table" and type(guide.steps) == "table" and guide.steps[index]
        if type(step) == "table" and type(step.goals) == "table" then raw = step.goals end
    end
    local friendlyTypes = {accept=true, turnin=true, talk=true, train=true, vendor=true,
        buy=true, auction=true, sethome=true, getfp=true, learn=true}
    local names, friendly, seen, npcIDs, points = {}, {}, {}, {}, {}
    local function npcName(id, name)
        if id and ps.Names and type(ps.Names.Npc) == "function" then
            local found, localized = pcall(ps.Names.Npc, id)
            if found and localized then return localized end
        end
        return name
    end
    local function addName(name, isFriendly, explicitFriendly, id)
        if not name then return end
        if not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
        if isFriendly and (explicitFriendly or not validNames[name]) then friendly[name] = true end
        if type(id) == "number" and id > 0 then npcIDs[name] = id end
    end
    local preferredName
    for i, goal in ipairs(view.goals) do
        if type(goal) == "table" and (goal.status == "active" or goal.status == "pending") then
            local source = type(raw[i]) == "table" and raw[i] or {}
            local kind = goal.t
            local npcSources = (kind == "kill" or kind == "collect" or kind == "use") and source.fromNpcs
            if kind == "kill" or kind == "collect" or friendlyTypes[kind] or type(npcSources) == "table" then
                local id, name
                if kind ~= "use" then
                    if goal.npc ~= nil or goal.npcName ~= nil then id, name = goal.npc, goal.npcName
                    else id, name = source.npc, source.npcName end
                    name = npcName(id, name)
                end
                if not name and kind == "kill" then name = goal.subject or source.target end
                local collectSource = kind == "collect" and type(goal.source) == "table"
                    and goal.source.kind == "npc" and goal.source or nil
                if not name and collectSource then name = collectSource.name end
                local sourceFriendly = collectSource and collectSource.enemy == false
                local safe = Core.SafeName(name)
                local isSource = sourceFriendly and safe and safe == Core.SafeName(collectSource.name)
                addName(safe, friendlyTypes[kind] or isSource, isSource, id)
                if safe and friendlyTypes[kind] and goal.f ~= "e"
                    and type(goal.x) == "number" and type(goal.y) == "number"
                    and (goal.x ~= 0 or goal.y ~= 0) then
                    local point = Proximity.MapPoint(goal.map, goal.x / 100, goal.y / 100)
                    if point then
                        local locations = points[safe] or {}
                        locations[#locations + 1] = point
                        points[safe] = locations
                    end
                end
                if collectSource then
                    local alternative = Core.SafeName(collectSource.also)
                    addName(alternative, sourceFriendly, sourceFriendly)
                    safe = safe or alternative
                end
                if type(npcSources) == "table" then
                    for _, candidate in ipairs(npcSources) do
                        if type(candidate) == "table" then
                            local candidateName = Core.SafeName(npcName(candidate.npc, candidate.npcName))
                            addName(candidateName, nil, nil, candidate.npc)
                            safe = safe or candidateName
                        end
                    end
                end
                if i == view.current then preferredName = safe end
            end
        end
    end
    return names, friendly, npcIDs, points, preferredName
end

function Integration.FollowTheArrowAvailable()
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    return not Core.IsRetail() and type(isLoaded) == "function" and isLoaded("FollowTheArrow") == true
        and type(GetMacroIndexByName) == "function" and type(GetMacroBody) == "function"
end

local function followTheArrowNames(validNames)
    if not Integration.FollowTheArrowAvailable() then return end
    local progress = FTACharDB and FTACharDB.progress
    if not progress or type(progress.activeModuleId) ~= "string" or progress.activeModuleId == "" then return end
    local profile = FTADB and FTADB.profile
    if profile and profile.general and profile.general.enableTargetingMacro == false then return end
    local index = GetMacroIndexByName("FTA Target")
    if type(index) ~= "number" or index <= 0 then return end
    local body = GetMacroBody(index)
    if not Core.Readable(body) or type(body) ~= "string" or #body > Core.MACRO_BYTES then return end

    -- Harldan's guide publishes localized targets in its own macro. Read just
    -- the generated target block, never its optional marker or guide commands.
    local lines = (body .. "\n"):gmatch("([^\r\n]*)\r?\n")
    if lines() ~= "/cleartarget" then return end
    local names, friendly = {}, {}
    for slot = 1, 5 do
        local line = lines()
        if not line then break end
        local pattern = slot == 1 and "^/targetexact (.+)$" or "^/targetexact %[noexists%] (.+)$"
        local name = Core.SafeName(line:match(pattern))
        if not name or lines() ~= "/cleartarget [dead]" then break end
        names[#names + 1] = name
        if not validNames[name] then friendly[name] = true end
    end
    return names, friendly
end

local function readRestedTargets(rxp, base)
    if not rxp then return end
    local names, friendly = currentNames(rxp, base.names)
    for _, name in ipairs(names) do
        if base.finisherNames[name] then friendly[name] = true end
    end
    return {names=names, friendly=friendly}
end

local function sameRanking(entry, previous)
    if not previous or previous.proximityRevision ~= Proximity.revision
        or previous.sourceOrder ~= entry.sourceOrder or previous.preferredName ~= entry.preferredName
        or previous.title ~= entry.title then return false end
    for _, name in ipairs(entry.nameList) do
        if entry.finisherNames[name] ~= previous.finisherNames[name] then return false end
        local points, old = entry.mapPoints[name], previous.mapPoints[name]
        if points ~= old then
            if not points or not old or #points ~= #old then return false end
            for index, point in ipairs(points) do
                local prior = old[index]
                if point.continent ~= prior.continent or point.x ~= prior.x or point.y ~= prior.y then
                    return false
                end
            end
        end
    end
    return true
end

local function rankedEntry(app, base, rxpTargets, rareEntry, previous)
    local db = NS.Database.Provider()
    local entry = {nameList={}, names={}, finisherNames={}, refs={}, mapPoints={}, distanceOrder=true,
        title=NS.L(base and "active" or "restedXPButton"), questID=0}
    local hasSources = false
    local function add(names, friendly, ids, points)
        if not names or #names == 0 then return end
        hasSources = true
        for _, name in ipairs(names) do
            if db and ids then
                if ids[name] then Proximity.Register(db, ids[name], name)
                else Proximity.RegisterName(db, name) end
            end
            if not entry.names[name] then
                entry.nameList[#entry.nameList + 1] = name
                entry.names[name] = true
            end
            if friendly and friendly[name] then entry.finisherNames[name] = true end
            if points and points[name] then
                local combined = entry.mapPoints[name] or {}
                for _, point in ipairs(points[name]) do combined[#combined + 1] = point end
                entry.mapPoints[name] = combined
            end
        end
    end
    local questEntry = UI.master.defaultEntry
    local baseNames = questEntry.names or {}
    local useModules = app.db.masterAllModules ~= false
    if rxpTargets and (not base or useModules) then
        add(rxpTargets.names, rxpTargets.friendly, {})
    end
    if base and useModules then
        if app.db.polestarIntegration ~= false then
            local names, friendly, ids, points, preferred = polestarNames(baseNames)
            -- Without QuestieDB or active RestedXP targets, Polestar supplies the
            -- first choice even if other names have better coordinate data.
            if not db and not hasSources then entry.preferredName = preferred end
            add(names, friendly, ids, points)
        end
        if app.db.followTheArrowIntegration ~= false then
            local names, friendly = followTheArrowNames(baseNames)
            if names then
                if not db and not hasSources then entry.preferredName = names[1] end
                add(names, friendly, {})
            end
        end
        local itemTree = NS.ItemTree.SearchEntry(app)
        if rareEntry == nil then rareEntry = NS.RareScanner.SearchEntry(app) end
        if itemTree then add(itemTree.nameList, itemTree.finisherNames, {}, itemTree.mapPoints) end
        if rareEntry then add(rareEntry.nameList, rareEntry.finisherNames, nil, rareEntry.mapPoints) end
    end
    local hasModules = hasSources
    if base then
        if not hasModules and (not Proximity.position or base.noDistanceRevision == Proximity.revision) then return base end
        add(base.nameList, base.finisherNames)
    end
    if #entry.nameList == 0 then return base end
    entry.sourceOrder = table.concat(entry.nameList, "\n")
    if sameRanking(entry, previous) then return previous end
    Proximity.Order(entry)
    if base and not hasModules and not Proximity.EntryDistance(entry, entry.name) then
        base.noDistanceRevision = Proximity.revision
        return base
    end
    return entry
end

local function prepareClick(app, button, base, setting)
    Proximity.Sample()
    local rxp = app.db.restedXPIntegration ~= false and (not base or app.db.masterAllModules ~= false) and restedXP()
    local rxpTargets = readRestedTargets(rxp, UI.master.defaultEntry)
    local entry = rankedEntry(app, base, rxpTargets, nil, button.entry)
    button.entry = entry
    local settings = Core.TargetFeedbackSettings(app.db, setting)
    Core.SetClickMacro(button, Core.ClickMacro(entry, {}, settings, button, nil, true), app.db)
end

local function prepareCombatMacro(app, button, setting)
    local settings = Core.TargetFeedbackSettings(app.db, setting)
    local entry = button.entry
    local macro
    if entry and Core.ValidCurrentTarget(entry) then
        macro = Core.MarkerMacro(settings, true, entry.finisherNames[Core.SafeName(UnitName("target"))])
    else
        macro = Core.EntryMacro(entry, settings)
    end
    if button:GetAttribute("macrotext1") ~= macro then button:SetAttribute("macrotext1", macro) end
end

local function createButton()
    local button = CreateFrame("Button", "QuestTargetsRestedXPTarget", UIParent, "SecureActionButtonTemplate")
    button:RegisterForClicks("LeftButtonUp")
    button:SetAttribute("type1", "macro")
    button:SetAttribute("useOnKeyDown", false)
    UI.StyleTargetButton(button, 0.28, 0.65, 1)
    button:SetScript("PreClick", function(self, mouseButton, down)
        if mouseButton ~= "LeftButton" or down then return end
        local app = NS.app
        if InCombatLockdown() then
            Core.PrepareDeadTargetSound(self:GetAttribute("macrotext1"), app.db)
        else
            prepareClick(app, self, nil, "restedXP")
        end
    end)
    button:SetScript("PostClick", function(self, mouseButton, down)
        if mouseButton ~= "LeftButton" or down or InCombatLockdown() then return end
        Core.RecordClickResult()
        prepareCombatMacro(NS.app, self, "restedXP")
    end)
    button:SetScript("OnEnter", function(self)
        if not NS.app.db.showTooltips then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(NS.L("restedXPTooltipTitle"))
        GameTooltip:AddLine(NS.L("restedXPSourceTip"), 1, 1, 1, true)
        if not self.entry then GameTooltip:AddLine(NS.L("restedXPNoTarget"), 1, 0.82, 0, true) end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:Hide()
    return button
end

function Integration.Sync(app, rareEntry)
    if InCombatLockdown() or not app.db or not UI.master then return end
    local rxp = app.db.restedXPIntegration ~= false and restedXP()
    Integration.active = rxp and true or false
    local polestar = app.db.polestarIntegration ~= false and _G.Polestar and type(_G.Polestar.Engine) == "table"
    local itemTree = app.db.itemTreeButton ~= false and _G.ItemTree and _G.ItemTree.UI
    if rxp or polestar or itemTree then Proximity.PrepareNameIndex(NS.Database.Provider()) end
    local rxpTargets = readRestedTargets(rxp, UI.master.defaultEntry)
    UI.master.entry = rankedEntry(app, UI.master.defaultEntry, rxpTargets, rareEntry, UI.master.entry)
    prepareCombatMacro(app, UI.master, "master")
    if rxp and not Integration.button then Integration.button = createButton() end
    local button = Integration.button
    if button then
        button.entry = rxpTargets and rankedEntry(app, nil, rxpTargets, nil, button.entry) or nil
        prepareCombatMacro(app, button, "restedXP")
        local show = Integration.active and not app.db.hotkeysOnly
        if button:IsShown() ~= show then
            button:SetShown(show)
            UI.LayoutTargetButtons(app)
        end
    end
end

function Integration.PreClick(app, button)
    prepareClick(app, button, button.defaultEntry, "master")
end
