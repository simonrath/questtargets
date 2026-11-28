local _, NS = ...
local Core, UI = NS.Core, NS.UI
local Tracker = {buttons = {}}
NS.FlareUITracker = Tracker

function Tracker.Available()
    local api = _G.FlareUI_QuestTrackerAPI
    return type(api) == "table" and api.version == 1
        and type(api.RegisterCallback) == "function" and type(api.UnregisterCallback) == "function"
        and type(api.GetRows) == "function" and type(api.IsActive) == "function"
        and type(RegisterStateDriver) == "function"
end

local function createButton(index)
    -- API coordinates are already in UIParent's scale. Keep the secure
    -- button independent of FlareUI's recycled quest rows.
    local button = CreateFrame("Button", "QuestTargetsFlareUITarget" .. index,
        UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate")
    button:SetFrameStrata("MEDIUM")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetAttribute("type1", "macro")
    button:SetAttribute("useOnKeyDown", false)
    button:SetAttribute("_onstate-combat", "if newstate == 'combat' then self:Hide() end")
    RegisterStateDriver(button, "combat", "[combat] combat; peace")
    button:SetNormalTexture("Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassUp")
    button:SetPushedTexture("Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassDown")
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    button.focusMark = UI.CreateFocusMark(button, button, 22)
    button:SetScript("PreClick", function(self, mouseButton, down)
        if down or InCombatLockdown() or mouseButton ~= "LeftButton" or not self.entry then return end
        Core.PrepareQuestRowClick(self, NS.app, "questList")
    end)
    button:SetScript("PostClick", function(self, mouseButton, down)
        if down or InCombatLockdown() or not self.entry then return end
        local app = NS.app
        if mouseButton == "RightButton" then
            UI.ToggleFocus(app, self.entry)
        elseif mouseButton == "LeftButton" then
            Core.RecordClickResult()
            self:SetAttribute("macrotext1", Core.EntryMacro(self.entry, Core.TargetFeedbackSettings(app.db, "questList")))
        end
    end)
    button:SetScript("OnEnter", UI.Tooltip)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:Hide()
    Tracker.buttons[index] = button
    return button
end

function Tracker.UpdateFocusMarks(app)
    for _, button in ipairs(Tracker.buttons) do
        local focused = button:IsShown() and button.entry and button.entry.questID == app.db.focusQuestID
        button.focusMark:SetShown(focused == true)
    end
end

local function render(app, rows)
    if InCombatLockdown() then return end
    local used = 0
    if rows and #rows > 0 then
        local entries = Core.QuestEntriesFor(app, true)
        if entries ~= Tracker.entries then
            Tracker.entries, Tracker.byID = entries, {}
            for _, entry in ipairs(entries) do Tracker.byID[entry.questID] = entry end
        end
        local settings = Core.TargetFeedbackSettings(app.db, "questList")
        for _, row in ipairs(rows) do
            local entry = Tracker.byID[row.questID]
            if entry and entry.name then
                used = used + 1
                local button = Tracker.buttons[used] or createButton(used)
                if button.size ~= row.size then
                    button:SetSize(row.size, row.size)
                    button.size = row.size
                end
                if button.anchor ~= row.point or button.x ~= row.x or button.y ~= row.y then
                    button:ClearAllPoints()
                    button:SetPoint(row.point, UIParent, "BOTTOMLEFT", row.x, row.y)
                    button.anchor, button.x, button.y = row.point, row.x, row.y
                end
                if not button.entry or button.entry.questID ~= entry.questID then
                    if GameTooltip:IsOwned(button) then GameTooltip:Hide() end
                    button.fallbackIndex, button.fallbackFinisherIndex = nil, nil
                end
                button.entry = entry
                local macro = Core.EntryMacro(entry, settings)
                if button:GetAttribute("macrotext1") ~= macro then button:SetAttribute("macrotext1", macro) end
                if not button:IsShown() then button:Show() end
            end
        end
    end
    for i = used + 1, #Tracker.buttons do
        local button = Tracker.buttons[i]
        if button.entry then
            if GameTooltip:IsOwned(button) then GameTooltip:Hide() end
            button.entry = nil
            button:SetAttribute("macrotext1", nil)
        end
        if button:IsShown() then button:Hide() end
    end
    Tracker.UpdateFocusMarks(app)
end

function Tracker.Sync(app, idle)
    if not app.db or InCombatLockdown() then return end
    local api = not app.db.hotkeysOnly and app.db.flareUITrackerButtons ~= false
        and Tracker.Available() and _G.FlareUI_QuestTrackerAPI or nil
    if Tracker.api and Tracker.api ~= api then
        Tracker.api:UnregisterCallback(Tracker)
        Tracker.api = nil
        render(app)
    end
    if not api then return end
    if Tracker.api ~= api then
        api:RegisterCallback(Tracker, function(rows) render(app, rows) end)
        Tracker.api = api
    elseif idle then
        return
    end
    render(app, api:IsActive() and api:GetRows() or nil)
end
