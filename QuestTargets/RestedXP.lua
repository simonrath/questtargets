local _, NS = ...
local Core, UI = NS.Core, NS.UI
local Integration = {targets = {}, cursor = 1}
NS.RestedXP = Integration

local UP = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassUp"
local DOWN = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassDown"

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

local function createButton(frame)
    -- A secure child or anchor would protect RestedXP's scroll frame and make
    -- its ordinary scroll updates fail after a guide step changes.
    local button = CreateFrame("Button", "QuestTargetsRestedXPTarget", UIParent, "SecureActionButtonTemplate")
    button.rxpFrame = frame
    button:SetSize(25, 25)
    button:RegisterForClicks("LeftButtonUp")
    button:SetAttribute("type1", "macro")
    button:SetAttribute("useOnKeyDown", false)
    button:SetNormalTexture(UP)
    button:SetPushedTexture(DOWN)
    button:SetHighlightAtlas("UI-QuestPoi-InnerGlow")
    button:SetScript("PreClick", function(self, mouseButton, down)
        if mouseButton == "LeftButton" and not down then Integration.PreClick(NS.app, self) end
    end)
    button:SetScript("PostClick", function(self, mouseButton, down)
        if mouseButton ~= "LeftButton" or down then return end
        Core.RecordClickResult()
        Integration.PostClick(NS.app)
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

local function positionButton(button, frame)
    local cx, cy = frame:GetCenter()
    if not cx or not cy then return false end
    local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local x = (cx + frame:GetWidth() / 2 + 4) * scale
    local y = (cy + frame:GetHeight() / 2 - 15) * scale
    if button.positionX ~= x or button.positionY ~= y then
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
        button.positionX, button.positionY = x, y
    end
    button.rxpFrame = frame
    local strata = frame:GetFrameStrata()
    if button:GetFrameStrata() ~= strata then button:SetFrameStrata(strata) end
    local level = frame:GetFrameLevel() + 1
    if button:GetFrameLevel() ~= level then button:SetFrameLevel(level) end
    return true
end

local function setMacro(button, entry, settings)
    if not button then return end
    button.entry = entry
    local macro = entry and Core.EntryMacro(entry, settings) or nil
    if entry and Integration.active and Integration.allEntry
        and Core.ValidCurrentTarget(Integration.allEntry) then
        local name = Core.SafeName(UnitName("target"))
        local friendly = Integration.allEntry.finisherNames[name]
        macro = Core.MarkerMacro(settings, true, friendly)
    end
    button:SetAttribute("macrotext1", macro)
end

local function appendNativeFallback(macro, base, settings)
    if not macro or not macro:find("/cleartarget", 1, true)
        or not base or not base.nameList or #base.nameList == 0 then return macro end
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
    local wasActive = Integration.active
    Integration.active = rxp and true or false
    if not rxp then
        Integration.targets = {}
        Integration.allEntry = nil
        Integration.signature = nil
        Integration.cursor = 1
        Integration.nativeCursor = 1
        Integration.fallbackOnce = false
        if wasActive then setMacro(UI.master, UI.master.defaultEntry, app.db) end
        if Integration.button then
            setMacro(Integration.button, nil, app.db)
            Integration.button:Hide()
        end
        return
    end

    local base = UI.master.defaultEntry or {}
    local names, guideFriendlyNames = currentNames(rxp, base.names or {})
    local signatureParts = {}
    for i, target in ipairs(names) do
        signatureParts[i] = target .. (guideFriendlyNames[target] and ":friendly" or "")
    end
    local signature = table.concat(signatureParts, "\n")
    if signature ~= Integration.signature then
        Integration.cursor = 1
        Integration.nativeCursor = 1
        Integration.fallbackOnce = false
    end
    Integration.signature = signature
    Integration.targets = names
    local allNames, allFriendly = {}, {}
    for target in pairs(base.names or {}) do allNames[target] = true end
    for target in pairs(base.finisherNames or {}) do allFriendly[target] = true end
    for _, target in ipairs(names) do
        allNames[target] = true
        if guideFriendlyNames[target]
            or (base.finisherNames and base.finisherNames[target]) then
            allFriendly[target] = true
        end
    end
    Integration.allEntry = {names=allNames, finisherNames=allFriendly}
    local name = names[Integration.cursor]
    local finisher = name and (guideFriendlyNames[name]
        or (base.finisherNames and base.finisherNames[name] == true))
    local guideEntry = name and {name=name, title=NS.L("restedXPButton"), questID=0,
        nameList={name}, names={[name]=true}, refs=base.refs or {},
        finisherNames=finisher and {[name]=true} or {},
        mobCount=finisher and 0 or 1, turnInCount=finisher and 1 or 0} or nil
    local entry = (not name or Integration.fallbackOnce) and base.name and base or guideEntry
    setMacro(UI.master, entry, app.db)

    local frame = rxp.targeting and rxp.targeting.activeTargetFrame
    if not frame or not frame:IsVisible() or not entry or not rxp.settings or not rxp.settings.profile
        or not rxp.settings.profile.enableTargetFrame then
        if Integration.button then
            setMacro(Integration.button, nil, app.db)
            Integration.button:Hide()
        end
        return
    end
    local button = Integration.button
    if not button then
        button = createButton(frame)
        Integration.button = button
    end
    if not positionButton(button, frame) then
        setMacro(button, nil, app.db)
        button:Hide()
        return
    end
    setMacro(button, entry, app.db)
    button:Show()
end

function Integration.PreClick(app, button)
    if not Integration.active then return false end
    if InCombatLockdown() then return true end
    local entry = button.entry
    local native = entry and entry == UI.master.defaultEntry
    Integration.attemptSerial = (Integration.attemptSerial or 0) + 1
    Integration.lastAttempt = {serial=Integration.attemptSerial,
        signature=Integration.signature, native=native}
    local macro
    if native then
        button.nativeState = button.nativeState or {}
        button.nativeState.entry = entry
        macro = Core.ClickMacro(entry, app.allEntries or {}, app.db,
            button.nativeState, Integration.allEntry)
    else
        button.rxpState = {entry=entry}
        macro = entry and Core.ClickMacro(entry, {entry}, app.db,
            button.rxpState, Integration.allEntry) or nil
        if entry and not Core.ValidCurrentTarget(Integration.allEntry) then
            macro = appendNativeFallback(macro, UI.master.defaultEntry, app.db)
        end
    end
    button:SetAttribute("macrotext1", macro)
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
