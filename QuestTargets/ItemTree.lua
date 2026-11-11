local _, NS = ...
local Integration = {}
NS.ItemTree = Integration

local MACRO = "ItemTree Mobs"
local KEEP_TARGET = "/stopmacro [harm,nodead]"
local SEARCH = "/stopmacro [combat,harm,nodead]\n/cleartarget [harm,nodead]"
local TARGET_LINE = "\n/targetexact [noexists][dead][help] "
local CLEAR_INVALID = "\n/cleartarget [dead][help]"
local MARKER_BYTES = #NS.Core.MarkerMacro({autoMark=true, markerIcon=8})

local function normalizeMacro(body)
    if type(body) ~= "string" then return end
    return (body:gsub("\r\n", "\n"):gsub("\n+$", ""))
end

local function isGeneratedMacro(index, body)
    local macroConsts = Constants and Constants.MacroConsts
    local accountSlots = macroConsts and macroConsts.MAX_ACCOUNT_MACROS or MAX_ACCOUNT_MACROS
    if not body or (accountSlots and index <= accountSlots) then return false end
    -- A character macro can survive the loss of its saved ownership record.
    -- Accept only complete bodies produced by one of our previous layouts.
    local marker = body:match("\n/tm %[exists,harm,nodead%] ![1-8]$") or ""
    local suffix = CLEAR_INVALID .. marker
    if body:sub(-#suffix) ~= suffix then return false end

    for _, prefix in ipairs({ SEARCH, KEEP_TARGET, "/cleartarget" }) do
        if body:sub(1, #prefix + #TARGET_LINE) == prefix .. TARGET_LINE then
            local targetLines = body:sub(#prefix + 1, -#suffix - 1)
            local command = TARGET_LINE:sub(2)
            for line in targetLines:gmatch("\n([^\n]*)") do
                local name = line:sub(#command + 1)
                if line:sub(1, #command) ~= command or NS.Core.SafeName(name) ~= name then return false end
            end
            return true
        end
    end
    return false
end

local function buildMacro(names, settings)
    local lines = ""
    local entry = { names = {} }
    for _, name in ipairs(names) do
        local line = TARGET_LINE .. name
        if #SEARCH + #lines + #line + #CLEAR_INVALID + MARKER_BYTES > NS.Core.MACRO_BYTES then break end
        lines = lines .. line
        entry.names[name] = true
    end
    if lines == "" then return end
    local prefix = NS.Core.ValidCurrentTarget(entry) and KEEP_TARGET or SEARCH
    return prefix .. lines .. CLEAR_INVALID .. NS.Core.MarkerMacro(settings)
end

local function sourceRows()
    local ui = ItemTree and ItemTree.UI
    local view = ui and ui.Frame
    local tree = ui and ui.Tree
    if not view or not view.frame or not view.frame:IsVisible() or not tree or not tree.pane
        or not tree.pane:IsVisible() or type(view.View) ~= "function"
        or type(view.rootKey) ~= "string" or not view.rootKey:match("^item:%d+$") then return end
    local ok, current = pcall(view.View)
    if ok and current == "sources" and type(tree.rows) == "table" then return tree.rows end
end

local function saveActionBarMacro(app, names)
    local body = buildMacro(names, app.db)
    if not body then return end

    if not GetMacroIndexByName or not GetMacroBody or not CreateMacro or not EditMacro then
        return print(NS.L("itemTreeMacroFailed"))
    end
    local index = GetMacroIndexByName(MACRO)
    if index > 0 then
        local previous = normalizeMacro(GetMacroBody(index))
        if not previous or (previous ~= body and previous ~= normalizeMacro(app.db.itemTreeMacroBody)
            and not isGeneratedMacro(index, previous)) then
            return print(NS.L("itemTreeMacroConflict"))
        end
        if previous ~= body then pcall(EditMacro, index, MACRO, nil, body) end
    else
        pcall(CreateMacro, MACRO, 134400, body, true)
    end
    index = GetMacroIndexByName(MACRO)
    if index == 0 or normalizeMacro(GetMacroBody(index)) ~= body then return print(NS.L("itemTreeMacroFailed")) end
    app.db.itemTreeMacroBody = body
end

local function creatureID(node)
    local era = ItemTree.EraSources
    if type(node.key) == "string" and era then
        if era.PageCreatureId then
            local ok, id = pcall(era.PageCreatureId, node.key)
            if ok and id then return id end
        end
        if era.CreatureIdAt then
            local ok, id = pcall(era.CreatureIdAt, era, node.key)
            if ok and id then return id end
        end
    end
    return type(node.id) == "number" and node.id > 0 and node.id or nil
end

function Integration.Import(app)
    if InCombatLockdown() then return end
    local names, targets, seen = {}, {}, {}
    for _, row in ipairs(sourceRows() or {}) do
        local node = type(row) == "table" and row.node
        if node and row.kind == "row" and row.depth == 1 and node.kind == "npc"
            and row.source and row.source.type == "Drop" then
            local name = NS.Core.SafeName(node.name)
            if name then
                local key = name:lower()
                local mob = seen[key]
                if not mob then
                    mob = {name=name, ids={}, zones={}}
                    seen[key] = mob
                    names[#names + 1] = name
                    targets[#targets + 1] = mob
                end
                local id = creatureID(node)
                if id then mob.ids[id] = true end
                local zone = row.source.zone
                if type(zone) == "string" and zone ~= "" then mob.zones[zone:lower()] = true end
            end
        end
    end
    if #targets == 0 then return print(NS.L("itemTreeEmpty")) end
    app.db.itemTreeTargets = targets
    Integration.Sync(app)
    print(NS.L("itemTreeTargetsImported"):format(#targets))
    saveActionBarMacro(app, names)
end

local function createTarget(app)
    local target = CreateFrame("Button", "QuestTargetsItemTree", UIParent, "SecureActionButtonTemplate")
    target:RegisterForClicks("LeftButtonUp")
    target:SetAttribute("useOnKeyDown", false)
    target:SetAttribute("type1", "macro")
    target:SetSize(1, 1)
    target:SetPoint("CENTER", UIParent, "CENTER")
    target:SetAlpha(0)
    target:EnableMouse(false)
    NS.UI.StyleTargetButton(target, 1, 0.86, 0.18)
    target:SetScript("PreClick", function(self, mouseButton, down)
        if InCombatLockdown() and mouseButton == "LeftButton" and not down then
            NS.Core.PrepareDeadTargetSound(self:GetAttribute("macrotext1"), app.db)
        end
        if mouseButton ~= "LeftButton" or down or InCombatLockdown() or not self.entry then return end
        NS.Core.SetClickMacro(self, NS.Core.ClickMacro(self.entry, {}, app.db, self), app.db)
    end)
    target:SetScript("PostClick", function(self, mouseButton, down)
        if mouseButton ~= "LeftButton" or down or InCombatLockdown() or not self.entry then return end
        NS.Core.RecordClickResult()
        self:SetAttribute("macrotext1", self.restingMacro)
    end)
    target:SetScript("OnEnter", function(self)
        if not app.db.showTooltips then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(NS.L("itemTreeBinding"))
        if not self.entry and not self:GetAttribute("macro1") then
            GameTooltip:AddLine(NS.L("itemTreeImport"), 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    target:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Integration.target = target
    return target
end

function Integration.SyncMacro(app)
    if InCombatLockdown() then return end
    local body = normalizeMacro(app.db.itemTreeMacroBody)
    if body and GetMacroIndexByName and GetMacroBody then
        local index = GetMacroIndexByName(MACRO)
        if index > 0 and normalizeMacro(GetMacroBody(index)) == body then
            if EditMacro then
                local names = {}
                for line in body:gmatch("[^\n]+") do
                    if line:sub(1, #TARGET_LINE - 1) == TARGET_LINE:sub(2) then
                        local name = NS.Core.SafeName(line:sub(#TARGET_LINE))
                        if name then names[#names + 1] = name end
                    end
                end
                local updated = buildMacro(names, app.db)
                if updated and updated ~= body then
                    pcall(EditMacro, index, MACRO, nil, updated)
                    if normalizeMacro(GetMacroBody(index)) == updated then
                        app.db.itemTreeMacroBody = updated
                    end
                end
            end
            if not app.db.itemTreeTargets then
                local target = Integration.target or createTarget(app)
                if target:GetAttribute("macro1") ~= MACRO then target:SetAttribute("macro1", MACRO) end
            end
        elseif Integration.target then
            Integration.target:SetAttribute("macro1", nil)
        end
    end
end

local function syncTarget(app)
    local targets = app.db.itemTreeTargets
    if type(targets) ~= "table" or #targets == 0 then return end
    local target = Integration.target or createTarget(app)
    local db, zones = app.resolutionProvider, NS.Database.currentZoneNames
    if target.sources ~= targets or target.provider ~= db or target.zones ~= zones then
        local entry = {nameList={}, names={}, refs={}, localNames={}}
        local zoneNames = {}
        for zone in pairs(zones or {}) do zoneNames[zone:lower()] = true end
        for _, mob in ipairs(targets) do
            local name = type(mob) == "table" and NS.Core.SafeName(mob.name)
            if name then
                if db then
                    for id in pairs(mob.ids or {}) do
                        local ok, localized = pcall(db.Npc.Get, id, "name")
                        localized = ok and NS.Core.SafeName(localized)
                        if localized then name = localized; break end
                    end
                end
                if not entry.names[name] then
                    entry.nameList[#entry.nameList + 1] = name
                    entry.names[name] = true
                end
                for zone in pairs(mob.zones or {}) do
                    if zoneNames[zone] then entry.localNames[name] = true; break end
                end
                if db then
                    for id in pairs(mob.ids or {}) do
                        NS.Proximity.Register(db, id, name)
                        if C_Map and C_Map.GetAreaInfo then
                            for area in pairs(NS.Proximity.Spawns(db, id) or {}) do
                                local ok, zone = pcall(C_Map.GetAreaInfo, area)
                                if ok and type(zone) == "string" and zoneNames[zone:lower()] then
                                    entry.localNames[name] = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        entry.name = entry.nameList[1]
        target.entry = entry.name and entry or nil
        target.sources, target.provider, target.zones = targets, db, zones
        target.fallbackIndex, target.fallbackFinisherIndex, target.proximityKey = nil, nil, nil
        target:SetAttribute("macro1", nil)
    end
    local macro = NS.Core.EntryMacro(target.entry, app.db)
    target.restingMacro = macro
    if target:GetAttribute("macrotext1") ~= macro then target:SetAttribute("macrotext1", macro) end
end

function Integration.Sync(app)
    if InCombatLockdown() then return end
    Integration.SyncMacro(app)
    syncTarget(app)
    local ui = ItemTree and ItemTree.UI
    local inBar = ui ~= nil and app.db.itemTreeButton == true
    local target = Integration.target or (inBar and createTarget(app))
    if target and target.inBar ~= inBar then
        target.inBar = inBar
        target:SetAlpha(inBar and 1 or 0)
        target:EnableMouse(inBar)
    end
    if inBar and not target:IsShown() then target:Show() end
    NS.UI.LayoutTargetButtons(app)
    local frame = ui and ui.Frame and ui.Frame.frame
    if not frame then return end
    if not Integration.button then
        local button = CreateFrame("Button", nil, frame)
        button:SetSize(42, 42)
        button:SetPoint("TOPLEFT", frame, "TOPRIGHT", 2, -68)
        button:SetClampedToScreen(true)
        button:SetNormalTexture("Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassUp")
        button:SetPushedTexture("Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassDown")
        button:SetScript("OnClick", function() Integration.Import(app) end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(NS.L("itemTreeImport"))
            GameTooltip:AddLine(MACRO, 1, 1, 1)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        Integration.button = button
    end
    Integration.button:SetShown(sourceRows() ~= nil)
end
