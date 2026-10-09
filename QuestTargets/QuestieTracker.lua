local _, NS = ...
local Core, UI = NS.Core, NS.UI
local COMPASS_UP = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassUp"
local COMPASS_DOWN = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassDown"
local Integration = {buttons = {}}
NS.QuestieTracker = Integration

local function createButton(index)
    local button = CreateFrame("Button", "QuestTargetsQuestieTarget" .. index,
        UIParent, "SecureActionButtonTemplate")
    button:SetSize(22, 22)
    button:SetFrameLevel(101) -- Questie's expand/collapse button uses level 100.
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetAttribute("type1", "macro")
    button:SetAttribute("useOnKeyDown", false)
    button:SetNormalTexture(COMPASS_UP)
    button:SetPushedTexture(COMPASS_DOWN)
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    button.focusMark = UI.CreateFocusMark(button, button, 22)
    button:SetScript("PreClick", function(self, mouseButton, down)
        if down or InCombatLockdown() or not self.entry then return end
        local line = self.questieLine
        if not line or line.mode ~= "quest" or not line.Quest
            or line.Quest.Id ~= self.questID or not line:IsVisible() then
            self.entry = nil
            self:SetAttribute("macrotext1", nil)
            self:Hide()
            return
        end
        if mouseButton == "LeftButton" then
            self:SetAttribute("macrotext1", Core.ClickMacro(self.entry, {self.entry}, NS.app.db, self))
        end
    end)
    button:SetScript("PostClick", function(self, mouseButton, down)
        if down or InCombatLockdown() or not self.entry then return end
        if mouseButton == "RightButton" then
            UI.ToggleFocus(NS.app, self.entry)
            return
        end
        if mouseButton ~= "LeftButton" then return end
        Core.RecordClickResult()
        self:SetAttribute("macrotext1", Core.EntryMacro(self.entry, NS.app.db))
    end)
    button:SetScript("OnEnter", function(self) UI.Tooltip(self) end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:Hide()
    return button
end

local function hideFrom(index)
    for i = index, #Integration.buttons do
        local button = Integration.buttons[i]
        button.entry = nil
        button.questID = nil
        button.questieLine = nil
        button.fallbackIndex, button.fallbackFinisherIndex = nil, nil
        button:SetAttribute("macrotext1", nil)
        button.focusMark:Hide()
        button:Hide()
    end
end

local function trackerPool()
    if not Questie or not Questie.db or not Questie.db.profile
        or not Questie.db.profile.trackerEnabled or not QuestieLoader then return end
    local ok, pool = pcall(QuestieLoader.ImportModule, QuestieLoader, "TrackerLinePool")
    if ok and type(pool) == "table" and type(pool.GetHighestIndex) == "function"
        and type(pool.GetLine) == "function" then return pool end
end

function Integration.UpdateFocusMarks(app)
    for _, button in ipairs(Integration.buttons) do
        button.focusMark:SetShown(button:IsShown()
            and button.questID == app.db.focusQuestID)
    end
end

function Integration.Sync(app)
    if not app.db or InCombatLockdown() then return end
    local pool = trackerPool()
    if not pool then hideFrom(1); return end
    local byID = {}
    for _, entry in ipairs(Core.QuestEntriesFor(app, true)) do
        byID[entry.questID] = entry
    end
    local used = 0
    for i = 1, math.min(pool.GetHighestIndex() or 0, 250) do
        local line = pool.GetLine(i)
        if line and line.mode == "quest" and line.Quest and line.expandQuest
            and line:IsVisible() then
            local entry = byID[line.Quest.Id]
            local anchorX = line.expandQuest:GetLeft()
            local _, anchorY = line.expandQuest:GetCenter()
            if entry and entry.name and anchorX and anchorY then
                used = used + 1
                local button = Integration.buttons[used]
                if not button then
                    button = createButton(used)
                    Integration.buttons[used] = button
                end
                -- Keep the secure button's parent and anchor independent of
                -- Questie's frames. A secure anchor can protect its relative
                -- frame and taint Questie's later action-bar updates.
                local strata = line:GetFrameStrata()
                if button:GetFrameStrata() ~= strata then button:SetFrameStrata(strata) end
                local level = math.max(line:GetFrameLevel(), line.expandQuest:GetFrameLevel()) + 1
                if button:GetFrameLevel() ~= level then button:SetFrameLevel(level) end
                local scale = line.expandQuest:GetEffectiveScale() / UIParent:GetEffectiveScale()
                local x, y = (anchorX - 1) * scale, anchorY * scale
                if button.positionX ~= x or button.positionY ~= y then
                    button:ClearAllPoints()
                    button:SetPoint("RIGHT", UIParent, "BOTTOMLEFT", x, y)
                    button.positionX, button.positionY = x, y
                end
                button.questieLine = line
                if button.questID ~= entry.questID then
                    button.fallbackIndex, button.fallbackFinisherIndex = nil, nil
                    button.questID = entry.questID
                end
                button.entry = entry
                button:SetAttribute("macrotext1", Core.EntryMacro(entry, app.db))
                button:Show()
                button.focusMark:SetShown(entry.questID == app.db.focusQuestID)
            end
        end
    end
    hideFrom(used + 1)
end
