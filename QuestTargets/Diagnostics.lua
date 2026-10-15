local addonName, NS = ...
local D = {}
NS.Diagnostics = D
local firstCaptured = false

local globals = {"SpellFlyout", "UseAction", "GetActionInfo", "SecureActionButton_OnClick",
    "SecureButton_GetModifiedAttribute", "pairs", "next", "Settings", "SettingsPanel"}
local fields = {"action", "popup", "CalculateAction", "TriggerSecureClick", "OnClick", "Hide"}
local bars = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
    "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button",
    "MultiBar7Button"}

local function snapshot()
    local result, count = {}, 0
    local probes = {available=type(issecurevariable) == "function", attempted=0, failed=0,
        settingsMapAvailable=false, settingsEntriesScanned=0, settingsScanTruncated=false}
    if not probes.available then return result, probes end
    local function read(object, key)
        if type(object) == "table" then return rawget(object, key) end
        if type(object) ~= "userdata" then return end
        local ok, value = pcall(function() return object[key] end)
        if ok then return value end
    end
    local function inspect(object, key, label)
        if not object or count >= 64 then return end
        probes.attempted = probes.attempted + 1
        local ok, secure, owner = pcall(issecurevariable, object, key)
        if not ok then probes.failed = probes.failed + 1 end
        if ok and secure == false then
            result[label] = type(owner) == "string" and owner:sub(1, 100) or "unknown"
            count = count + 1
        end
    end
    for _, name in ipairs(globals) do inspect(_G, name, name) end
    local settings, panel = read(_G, "Settings"), read(_G, "SettingsPanel")
    for _, key in ipairs({"GetValue", "GetSetting"}) do
        inspect(settings, key, "Settings." .. key)
        inspect(panel, key, "SettingsPanel." .. key)
    end
    inspect(panel, "settings", "SettingsPanel.settings")
    local map = read(panel, "settings")
    if type(map) == "table" then
        probes.settingsMapAvailable = true
        local setting
        -- Do not call Settings.GetSetting or any addon/native setting getter:
        -- the shared registry traversal is the execution path being diagnosed.
        for index = 1, 2048 do
            local ok, nextSetting = pcall(next, map, setting)
            if not ok then probes.failed = probes.failed + 1; break end
            setting = nextSetting
            if setting == nil then break end
            probes.settingsEntriesScanned = index
            local variable = read(setting, "variable")
            local label = type(variable) == "string" and variable:sub(1, 100)
                or ("entry" .. index)
            inspect(map, setting, "SettingsPanel.settings[" .. label .. "]")
            if variable == "lockActionBars" then
                for _, key in ipairs({"variable", "GetVariable", "GetValue", "GetValueDerived",
                    "pendingValue", "locked"}) do
                    inspect(setting, key, "Settings.lockActionBars." .. key)
                end
            end
        end
        if probes.settingsEntriesScanned == 2048 then
            local ok, remaining = pcall(next, map, setting)
            probes.settingsScanTruncated = not ok or remaining ~= nil
        end
    end
    for _, name in ipairs({"SpellFlyout", "ActionBarActionButtonMixin", "ActionBarActionButtonDerivedMixin"}) do
        local object = _G[name]
        for _, key in ipairs(fields) do inspect(object, key, name .. "." .. key) end
    end
    for _, prefix in ipairs(bars) do
        for i = 1, 12 do
            local name = prefix .. i
            local object = _G[name]
            if object then
                for _, key in ipairs(fields) do inspect(object, key, name .. "." .. key) end
            end
        end
    end
    return result, probes
end

local function report(app)
    local saved = app.db.taintDiagnostics
    if type(saved) ~= "table" or type(saved.events) ~= "table" then
        saved = {schema=1, events={}}
        app.db.taintDiagnostics = saved
    end
    return saved
end

function D.Sample(app, phase)
    if not app or not app.db then return end
    if firstCaptured then return end
    local values, probes = snapshot()
    if next(values) then
        report(app).first = {phase=phase, elapsed=GetTime and GetTime() or 0,
            fields=values, probes=probes}
        firstCaptured = true
    end
end

function D.Capture(app, event, func)
    if not app or not app.db then return end
    local stack = "Stack API unavailable"
    if type(debugstack) == "function" then
        local ok, value = pcall(debugstack, 2, 20, 10)
        if ok and type(value) == "string" then stack = value:sub(1, 8000) end
    end
    local saved = report(app)
    local values, probes = snapshot()
    local entry = {event=event, func=type(func) == "string" and func:sub(1, 200) or "unknown",
        elapsed=GetTime and GetTime() or 0, stack=stack, fields=values, probes=probes,
        restedXP=NS.RestedXP and NS.RestedXP.active == true,
        questieButtons=NS.QuestieTracker and #NS.QuestieTracker.buttons or 0,
        clickPath=NS.Core.lastClick and NS.Core.lastClick.path}
    if not firstCaptured and next(entry.fields) then
        saved.first = {phase=event, elapsed=entry.elapsed, fields=entry.fields, probes=probes}
        firstCaptured = true
    end
    saved.events[#saved.events + 1] = entry
    while #saved.events > 5 do table.remove(saved.events, 1) end
end

function D.Print(app)
    local saved = app.db and app.db.taintDiagnostics
    local events = type(saved) == "table" and saved.events
    local latest = type(events) == "table" and events[#events]
    if not latest then return end
    print("Quest Targets taint capture: " .. latest.func)
    if latest then
        local count = 0
        for key, owner in pairs(latest.fields or {}) do
            print("  " .. key .. " <- " .. owner)
            count = count + 1
            if count >= 5 then break end
        end
    end
end

-- Observe only: no hooks, native-frame writes, protected calls or automatic reload.
local frame, elapsed = CreateFrame("Frame"), 0
frame:RegisterEvent("ADDON_ACTION_BLOCKED")
frame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
frame:SetScript("OnEvent", function(_, event, source, func)
    if source == addonName then D.Capture(NS.app, event, func) end
end)
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < 2 then return end
    elapsed = 0
    D.Sample(NS.app, "periodic")
end)
