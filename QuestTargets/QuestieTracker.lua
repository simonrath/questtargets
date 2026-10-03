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
    button:RegisterForClicks("LeftButtonUp")
    button:SetAttribute("type1", "macro")
    button:SetAttribute("useOnKeyDown", false)
    button:SetNormalTexture(COMPASS_UP)
    button:SetPushedTexture(COMPASS_DOWN)
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    button:SetScript("PreClick", function(self, mouseButton, down)
        if mouseButton ~= "LeftButton" or down or InCombatLockdown() or not self.entry then return end
        self:SetAttribute("macrotext1", Core.ClickMacro(self.entry, {self.entry}, NS.app.db, self))
    end)
    button:SetScript("PostClick", function(self, mouseButton, down)
        if mouseButton ~= "LeftButton" or down or InCombatLockdown() or not self.entry then return end
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
        button:SetAttribute("macrotext1", nil)
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

function Integration.Sync(app)
    if not app.db or InCombatLockdown() then return end
    local pool = app.db.questieTrackerButtons and trackerPool()
    if not pool then hideFrom(1); return end

    local byID = {}
    for _, entry in ipairs(Core.QuestEntries(app.allEntries or app.entries or {})) do
        byID[entry.questID] = entry
    end
    local used = 0
    for i = 1, math.min(pool.GetHighestIndex() or 0, 250) do
        local line = pool.GetLine(i)
        if line and line.mode == "quest" and line.Quest and line.expandQuest
            and line:IsVisible() then
            local entry = byID[line.Quest.Id]
            if entry and entry.name then
                used = used + 1
                local button = Integration.buttons[used]
                if not button then
                    button = createButton(used)
                    Integration.buttons[used] = button
                end
                if button.questieLine ~= line then
                    button:SetParent(line)
                    button:ClearAllPoints()
                    button:SetPoint("RIGHT", line.expandQuest, "LEFT", -1, 0)
                    button.questieLine = line
                end
                if button.questID ~= entry.questID then
                    button.fallbackIndex, button.fallbackFinisherIndex = nil, nil
                    button.questID = entry.questID
                end
                button.entry = entry
                button:SetAttribute("macrotext1", Core.EntryMacro(entry, app.db))
                button:Show()
            end
        end
    end
    hideFrom(used + 1)
end
