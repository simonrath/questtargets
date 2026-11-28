local _, NS = ...
local Core, UI = NS.Core, NS.UI
local Integration = {slots = {}, buttons = {}}
NS.EllesmereTracker = Integration

function Integration.Available()
    return type(EllesmereUI) == "table"
        and type(EllesmereUI.RegisterQuestTrackerRow) == "function"
        and type(RegisterStateDriver) == "function"
end

local function clear(button)
    button.entry, button.questID = nil, nil
    button.fallbackIndex, button.fallbackFinisherIndex = nil, nil
    button:SetAttribute("macrotext1", nil)
    button.focusMark:Hide()
    button:Hide()
end

local function valid(button, app)
    return not app.db.hotkeysOnly and app.db.ellesmereTrackerButtons ~= false and Integration.Available()
        and button.slot:IsVisible() and button.questID == Integration.slots[button.slot]
end

local function createButton(slot)
    -- The public row API explicitly forbids protected children. Copy positions
    -- onto UIParent, and hide securely in combat while EUI recycles its slots.
    local button = CreateFrame("Button", "QuestTargetsEllesmereTarget" .. (#Integration.buttons + 1),
        UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate")
    button.slot = slot
    button:SetSize(22, 22)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetAttribute("type1", "macro")
    button:SetAttribute("useOnKeyDown", false)
    button:SetNormalTexture("Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassUp")
    button:SetPushedTexture("Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassDown")
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    button.focusMark = UI.CreateFocusMark(button, button, 22)
    button:SetAttribute("_onstate-combat", "if newstate == 'combat' then self:Hide() end")
    RegisterStateDriver(button, "combat", "[combat] combat; peace")
    button:SetScript("PreClick", function(self, mouseButton, down)
        if down or InCombatLockdown() or not self.entry then return end
        if not valid(self, NS.app) then clear(self); return end
        if mouseButton == "LeftButton" then
            Core.PrepareQuestRowClick(self, NS.app, "ellesmere")
        end
    end)
    button:SetScript("PostClick", function(self, mouseButton, down)
        if down or InCombatLockdown() or not self.entry or not valid(self, NS.app) then return end
        if mouseButton == "RightButton" then UI.ToggleFocus(NS.app, self.entry); return end
        if mouseButton ~= "LeftButton" then return end
        Core.RecordClickResult()
        self:SetAttribute("macrotext1", Core.EntryMacro(self.entry, Core.TargetFeedbackSettings(NS.app.db, "ellesmere")))
    end)
    button:SetScript("OnEnter", function(self) UI.Tooltip(self) end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:Hide()
    Integration.buttons[#Integration.buttons + 1] = button
    Integration.bySlot[slot] = button
    return button
end

function Integration.UpdateFocusMarks(app)
    for _, button in ipairs(Integration.buttons) do
        button.focusMark:SetShown(button:IsShown() and button.questID == app.db.focusQuestID)
    end
end

function Integration.Sync(app, periodic)
    if not app.db or InCombatLockdown() then return end
    local now = GetTime and GetTime()
    if periodic and now and Integration.nextSync and now < Integration.nextSync then return end
    Integration.nextSync = now and now + 3
    if Integration.Available() and not Integration.registered then
        Integration.bySlot = {}
        Integration.registered = EllesmereUI.RegisterQuestTrackerRow("QuestTargets", function(slot, questID)
            Integration.slots[slot] = questID
            if not InCombatLockdown() and not Integration.queued then
                Integration.queued = true
                C_Timer.After(0, function()
                    Integration.queued = false
                    Integration.Sync(app)
                end)
            end
        end, 26) == true
    end
    local byID = {}
    if Integration.registered and Integration.Available() and not app.db.hotkeysOnly
        and app.db.ellesmereTrackerButtons ~= false then
        for _, entry in ipairs(Core.QuestEntriesFor(app, true)) do byID[entry.questID] = entry end
    end
    local settings = Core.TargetFeedbackSettings(app.db, "ellesmere")
    for slot, questID in pairs(Integration.slots) do
        local entry = slot:IsVisible() and byID[questID]
        local button = Integration.bySlot and Integration.bySlot[slot]
        local x, y = slot:GetCenter()
        if entry and entry.name and x and y then
            button = button or createButton(slot)
            local scale = slot:GetEffectiveScale() / UIParent:GetEffectiveScale()
            x, y = (x + (app.db.ellesmereTrackerOffset or 0)) * scale, y * scale
            if button.positionX ~= x or button.positionY ~= y then
                button:ClearAllPoints()
                button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
                button.positionX, button.positionY = x, y
            end
            local strata, level = slot:GetFrameStrata(), slot:GetFrameLevel() + 1
            if button:GetFrameStrata() ~= strata then button:SetFrameStrata(strata) end
            if button:GetFrameLevel() ~= level then button:SetFrameLevel(level) end
            if button.questID ~= questID then
                button.fallbackIndex, button.fallbackFinisherIndex = nil, nil
            end
            button.entry, button.questID = entry, questID
            local macro = Core.EntryMacro(entry, settings)
            if button:GetAttribute("macrotext1") ~= macro then button:SetAttribute("macrotext1", macro) end
            if not button:IsShown() then button:Show() end
            local focused = questID == app.db.focusQuestID
            if button.focusMark:IsShown() ~= focused then button.focusMark:SetShown(focused) end
        elseif button and button.entry then
            clear(button)
        end
    end
end
