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
    local names, seen = {}, {}
    for _, step in ipairs(rxp.RXPFrame.activeSteps) do
        if step.active == true then
            for _, element in ipairs(step.elements or {}) do
                for _, key in ipairs({"unitscan", "mobs", "targets"}) do
                    for _, id in ipairs(element[key] or {}) do
                        local ok, raw = pcall(rxp.GetCreatureName, id)
                        if ok and type(raw) == "string" then
                            local name = Core.SafeName(raw:gsub("^%*", ""))
                            if name and validNames[name] and not seen[name] then
                                seen[name] = true
                                names[#names + 1] = name
                            end
                        end
                    end
                end
            end
        end
    end
    return names
end

local function createButton(frame)
    local button = CreateFrame("Button", "QuestTargetsRestedXPTarget", frame, "SecureActionButtonTemplate")
    button.rxpFrame = frame
    button:SetSize(25, 25)
    button:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -15)
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

local function setMacro(button, entry, settings)
    if not button then return end
    button.entry = entry
    button:SetAttribute("macrotext1", entry and Core.EntryMacro(entry, settings) or nil)
end

function Integration.Sync(app)
    if InCombatLockdown() or not app.db or not UI.master then return end
    local rxp = app.db.restedXPIntegration and restedXP()
    local wasActive = Integration.active
    Integration.active = rxp and true or false
    if not rxp then
        Integration.targets = {}
        Integration.signature = nil
        Integration.cursor = 1
        if wasActive then setMacro(UI.master, UI.master.defaultEntry, app.db) end
        if Integration.button then
            setMacro(Integration.button, nil, app.db)
            Integration.button:Hide()
        end
        return
    end

    local base = UI.master.defaultEntry or {}
    local names = currentNames(rxp, base.names or {})
    local signature = table.concat(names, "\n")
    if signature ~= Integration.signature then Integration.cursor = 1 end
    Integration.signature = signature
    Integration.targets = names
    local name = names[Integration.cursor]
    local finisher = name and base.finisherNames and base.finisherNames[name] == true
    local entry = name and {name=name, title=NS.L("restedXPButton"), questID=0,
        nameList={name}, names={[name]=true}, refs=base.refs or {},
        finisherNames=finisher and {[name]=true} or {},
        mobCount=finisher and 0 or 1, turnInCount=finisher and 1 or 0} or nil
    setMacro(UI.master, entry, app.db)

    local frame = rxp.targeting and rxp.targeting.activeTargetFrame
    if not frame or not name or not rxp.settings or not rxp.settings.profile
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
    elseif button.rxpFrame ~= frame then
        button:SetParent(frame)
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -15)
        button.rxpFrame = frame
    end
    setMacro(button, entry, app.db)
    button:Show()
end

function Integration.PreClick(app, button)
    if not Integration.active then return false end
    if InCombatLockdown() then return true end
    local entry = button.entry
    button.rxpState = {entry=entry}
    button:SetAttribute("macrotext1", entry and Core.ClickMacro(entry, {entry}, app.db, button.rxpState) or nil)
    return true
end

function Integration.PostClick(app)
    if not Integration.active then return false end
    if not InCombatLockdown() and #Integration.targets > 0 then
        Integration.cursor = Integration.cursor % #Integration.targets + 1
        Integration.Sync(app)
    end
    return true
end
