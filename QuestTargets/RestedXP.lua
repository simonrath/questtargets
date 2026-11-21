local _, NS = ...
local Core, UI = NS.Core, NS.UI
local Integration = {targets = {}, cursor = 1, guideCursor = 1}
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
    local names, friendly, seen = {}, {}, {}
    for i, goal in ipairs(view.goals) do
        if type(goal) == "table" and (goal.status == "active" or goal.status == "pending") then
            local source = type(raw[i]) == "table" and raw[i] or {}
            local kind = goal.t
            if kind == "kill" or kind == "collect" or friendlyTypes[kind] then
                local chosen = goal.npc ~= nil or goal.npcName ~= nil
                local id, name
                if chosen then id, name = goal.npc, goal.npcName
                else id, name = source.npc, source.npcName end
                if id and ps.Names and type(ps.Names.Npc) == "function" then
                    local found, localized = pcall(ps.Names.Npc, id)
                    if found and localized then name = localized end
                end
                if not name and kind == "kill" then name = goal.subject or source.target end
                if not name and kind == "collect" and type(goal.source) == "table"
                    and goal.source.kind == "npc" then name = goal.source.name end
                name = Core.SafeName(name)
                if name and not seen[name] then
                    seen[name] = true
                    names[#names + 1] = name
                end
                if name and friendlyTypes[kind] and not validNames[name] then friendly[name] = true end
            end
        end
    end
    return names, friendly
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
        elseif Integration.active and self.entry then
            local macro = Core.ClickMacro(self.entry, {}, app.db, nil, Integration.guideTargets)
            Core.SetClickMacro(self, macro, app.db)
        end
    end)
    button:SetScript("PostClick", function(self, mouseButton, down)
        if mouseButton ~= "LeftButton" or down or InCombatLockdown() or not Integration.active
            or not self.entry then return end
        Core.RecordClickResult()
        Integration.guideCursor = Integration.guideCursor % #Integration.targets + 1
        Integration.Sync(NS.app)
    end)
    button:SetScript("OnEnter", function(self)
        if not NS.app.db.showTooltips then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(NS.L("restedXPButton"))
        if self.entry then GameTooltip:AddLine(self.entry.name, 1, 1, 1, true) end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:Hide()
    return button
end

local function setMacro(button, entry, settings, preserveEntry)
    if not button then return end
    button.entry = entry
    local macro = entry and Core.EntryMacro(entry, settings) or nil
    if entry and preserveEntry and Core.ValidCurrentTarget(preserveEntry) then
        local name = Core.SafeName(UnitName("target"))
        local friendly = preserveEntry.finisherNames[name]
        macro = Core.MarkerMacro(settings, true, friendly)
    end
    button:SetAttribute("macrotext1", macro)
end

local function guideEntry(name, friendlyNames, provider)
    if not name then return end
    local friendly = friendlyNames[name]
    return {name=name, title=NS.L(provider == "polestar" and "polestarButton" or "restedXPButton"), questID=0,
        nameList={name}, names={[name]=true}, refs={},
        finisherNames=friendly and {[name]=true} or {},
        mobCount=friendly and 0 or 1, turnInCount=friendly and 1 or 0}
end

local function appendNativeFallback(macro, base, settings)
    if not macro or not macro:find("/cleartarget", 1, true)
        or not base or not base.nameList or #base.nameList == 0 then return macro end
    local proximity = NS.Proximity
    if proximity then
        proximity.Order(base)
        if proximity.MovedFrom(Integration.nativePosition)
            or (Integration.nativeProximityKey and Integration.nativeProximityKey ~= base.proximityKey) then
            Integration.nativeCursor = 1
        end
        Integration.nativePosition = proximity.position
        Integration.nativeProximityKey = base.proximityKey
    end
    local marker = Core.MarkerMacro(settings, true)
    -- Native targets can shrink while the active guide step stays unchanged.
    local index = ((Integration.nativeCursor or 1) - 1) % #base.nameList + 1
    for _ = 1, #base.nameList do
        local name = base.nameList[index]
        local line = "\n/targetexact [noexists] " .. name .. "\n/cleartarget [dead]"
        if #macro + #line + #marker > Core.MACRO_BYTES then break end
        macro = macro .. line
        index = index % #base.nameList + 1
    end
    Integration.nativeCursor = index
    if #macro + #marker <= Core.MACRO_BYTES then macro = macro .. marker end
    return macro
end

function Integration.Sync(app)
    if InCombatLockdown() or not app.db or not UI.master then return end
    local rxp = app.db.restedXPIntegration and restedXP()
    local polestar = not rxp and app.db.polestarIntegration and _G.Polestar
        and type(_G.Polestar.Engine) == "table" and _G.Polestar.Engine
    local wasActive = Integration.active
    Integration.provider = rxp and "restedxp" or polestar and "polestar" or nil
    Integration.active = Integration.provider ~= nil
    if not Integration.active then
        Integration.targets = {}
        Integration.allEntry = nil
        Integration.guideTargets = nil
        Integration.signature = nil
        Integration.cursor = 1
        Integration.guideCursor = 1
        Integration.nativeCursor = 1
        Integration.fallbackOnce = false
        if wasActive then setMacro(UI.master, UI.master.defaultEntry, app.db) end
        if Integration.button then
            setMacro(Integration.button, nil, app.db)
            Integration.button:Hide()
        end
        UI.LayoutTargetButtons(app)
        return
    end

    local base = UI.master.defaultEntry or {}
    local names, guideFriendlyNames
    if rxp then names, guideFriendlyNames = currentNames(rxp, base.names or {})
    else names, guideFriendlyNames = polestarNames(base.names or {}) end
    names, guideFriendlyNames = names or {}, guideFriendlyNames or {}
    local signatureParts = {}
    for i, target in ipairs(names) do
        signatureParts[i] = target .. (guideFriendlyNames[target] and ":friendly" or "")
    end
    local signature = Integration.provider .. "\n" .. table.concat(signatureParts, "\n")
    if signature ~= Integration.signature then
        Integration.cursor = 1
        Integration.guideCursor = 1
        Integration.nativeCursor = 1
        Integration.fallbackOnce = false
    end
    Integration.signature = signature
    Integration.targets = names
    local allNames, allFriendly, guideNames = {}, {}, {}
    for target in pairs(base.names or {}) do allNames[target] = true end
    for target in pairs(base.finisherNames or {}) do allFriendly[target] = true end
    for _, target in ipairs(names) do
        allNames[target] = true
        guideNames[target] = true
        if guideFriendlyNames[target]
            or (base.finisherNames and base.finisherNames[target]) then
            allFriendly[target] = true
            guideFriendlyNames[target] = true
        end
    end
    Integration.allEntry = {names=allNames, finisherNames=allFriendly}
    Integration.guideTargets = {names=guideNames, finisherNames=guideFriendlyNames}
    local name = names[Integration.cursor]
    local entry = (not name or Integration.fallbackOnce) and base.name and base
        or guideEntry(name, guideFriendlyNames, Integration.provider)
    setMacro(UI.master, entry, app.db, Integration.allEntry)

    if rxp then
        if not Integration.button then Integration.button = createButton() end
        setMacro(Integration.button, guideEntry(names[Integration.guideCursor], guideFriendlyNames),
            app.db, Integration.guideTargets)
        Integration.button:Show()
    elseif Integration.button then
        setMacro(Integration.button, nil, app.db)
        Integration.button:Hide()
    end
    UI.LayoutTargetButtons(app)
end

function Integration.PreClick(app, button)
    if not Integration.active then return false end
    if InCombatLockdown() then
        Core.PrepareDeadTargetSound(button:GetAttribute("macrotext1"), app.db)
        return true
    end
    local entry = button.entry
    local native = entry and entry == UI.master.defaultEntry
    Integration.attemptSerial = (Integration.attemptSerial or 0) + 1
    Integration.lastAttempt = {serial=Integration.attemptSerial,
        signature=Integration.signature, native=native}
    local macro
    if native then
        button.nativeState = button.nativeState or {}
        button.nativeState.entry = entry
        macro = Core.ClickMacro(entry, {}, app.db,
            button.nativeState, Integration.allEntry)
    else
        button.rxpState = {entry=entry}
        macro = entry and Core.ClickMacro(entry, {entry}, app.db,
            button.rxpState, Integration.allEntry) or nil
        if entry and not Core.ValidCurrentTarget(Integration.allEntry) then
            macro = appendNativeFallback(macro, UI.master.defaultEntry, app.db)
        end
    end
    Core.SetClickMacro(button, macro, app.db)
    return true
end

function Integration.PostClick(app)
    if not Integration.active then return false end
    if InCombatLockdown() then return true end
    local attempt = Integration.lastAttempt
    Integration.lastAttempt = nil
    if attempt and attempt.native then
        Integration.fallbackOnce = false
    elseif attempt then
        local serial, signature = attempt.serial, attempt.signature
        C_Timer.After(0, function()
            if not Integration.active or serial ~= Integration.attemptSerial
                or signature ~= Integration.signature or InCombatLockdown() then return end
            if not Core.ValidCurrentTarget(Integration.allEntry)
                and not Core.ValidCurrentTarget(UI.master.defaultEntry or {}) then
                Integration.fallbackOnce = true
            end
            Integration.Sync(app)
        end)
        if #Integration.targets > 0 then
            Integration.cursor = Integration.cursor % #Integration.targets + 1
        end
    end
    Integration.Sync(app)
    return true
end
