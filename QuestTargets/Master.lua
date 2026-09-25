local _, NS = ...
local UI, Core = NS.UI, NS.Core
local L = NS.L
local COMPASS_UP = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassUp"
local COMPASS_DOWN = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassDown"

function UI.RenderMaster(app)
    assert(not InCombatLockdown())
    if not UI.master then
        local frame = CreateFrame("Button", "QuestTargetsMaster", UIParent, "UIPanelButtonTemplate,SecureActionButtonTemplate")
        UI.master = frame
        frame:SetSize(140, 22)
        frame:SetText(L("masterDefault"))
        frame:SetFrameStrata("MEDIUM")
        frame:SetClampedToScreen(true)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("RightButton")
        frame:RegisterForClicks("AnyUp")
        frame:SetAttribute("useOnKeyDown", false)
        frame:SetAttribute("type1", "macro")
        frame.classicHighlight = frame:GetHighlightTexture()
        -- UIPanelButtonTemplate renders its background with Left/Middle/Right.
        -- Asset setters require paths, not Texture objects or nil in Forever.
        frame:SetNormalTexture(COMPASS_UP)
        frame:SetPushedTexture(COMPASS_DOWN)
        local pos = app.db.masterPosition
        if type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" then
            frame:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
        end
        frame:SetScript("OnDragStart", function(self)
            if not InCombatLockdown() then self:StartMoving(); self.moving = true end
        end)
        frame:SetScript("OnDragStop", function(self) self.pendingStop = true; UI.StopMaster(app) end)
        frame:SetScript("PreClick", function(self, mouseButton, down)
            if mouseButton ~= "LeftButton" or down or InCombatLockdown() then return end
            self:SetAttribute("macrotext1", Core.ClickMacro(self.entry, app.allEntries or {}, app.db, self))
        end)
        frame:SetScript("PostClick", function(self, _, down)
            if down then return end
            Core.RecordClickResult()
            if not InCombatLockdown() then self:SetAttribute("macrotext1", (Core.EntryMacro(self.entry, app.db))) end
        end)
        frame:SetScript("OnEnter", function(self)
            if not app.db.showTooltips then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("active"))
            GameTooltip:AddLine(L("masterTip1"), 1, 1, 1, true)
            GameTooltip:AddLine(L("masterTip2"), 1, 0.82, 0, true)
            GameTooltip:AddLine(L("masterTip3"), 0.75, 0.75, 0.75, true)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    UI.StopMaster(app)
    UI.PositionMaster(app)
    UI.CreateMinimap(app)
    local entry = {title = L("active"), refs = {}, names = {}, nameList = {}, finisherNames = {}}
    for _, quest in ipairs(Core.QuestEntries(app.allEntries or {})) do
        for _, ref in ipairs(quest.refs) do entry.refs[#entry.refs + 1] = ref end
        for name in pairs(quest.names) do
            if not entry.names[name] then
                entry.names[name] = true
                entry.nameList[#entry.nameList + 1] = name
            end
        end
    end
    table.sort(entry.nameList)
    local finishers = {}
    for _, quest in ipairs(app.allQuests or {}) do
        if quest.ready then
            for name in pairs(NS.Database.ResolveTurnIns(quest)) do
                if not entry.names[name] then finishers[name] = true end
            end
        end
    end
    local finisherNames = {}
    for name in pairs(finishers) do finisherNames[#finisherNames + 1] = name end
    table.sort(finisherNames)
    for _, name in ipairs(finisherNames) do
        entry.names[name] = true
        entry.finisherNames[name] = true
        entry.nameList[#entry.nameList + 1] = name
    end
    entry.mobCount = #entry.nameList - #finisherNames
    entry.turnInCount = #finisherNames
    entry.name = entry.nameList[1]
    UI.master.entry = entry
    UI.master:SetAttribute("macrotext1", (Core.EntryMacro(entry, app.db)))
    UI.master:SetShown(not app.db.masterHidden)
end

function UI.PositionMaster(app)
    local frame = UI.master
    if not frame then return end
    local modern = app.db.masterAppearance == "modern"
    if frame.modernAppearance ~= modern then
        frame:GetNormalTexture():SetAlpha(modern and 1 or 0)
        frame:GetPushedTexture():SetAlpha(modern and 1 or 0)
        for _, key in ipairs({"Left", "Middle", "Right"}) do
            if frame[key] then frame[key]:SetAlpha(modern and 0 or 1) end
        end
        if frame.classicHighlight then frame.classicHighlight:SetAlpha(modern and 0 or 1) end
        frame.modernAppearance = modern
    end
    if modern then
        local size = math.floor(40 * app.db.masterModernScale + 0.5)
        frame:SetSize(size, size)
        frame:SetText("")
    else
        frame:SetSize(math.floor(140 * app.db.masterScaleX + 0.5),
            math.floor(22 * app.db.masterScaleY + 0.5))
        frame:SetText(app.db.masterText)
    end
end

function UI.CreateMinimap(app)
    if UI.minimap or not Minimap then return end
    local frame = CreateFrame("Button", "QuestTargetsMinimapButton", Minimap)
    UI.minimap = frame
    frame:SetSize(28, 28)
    frame:SetFrameStrata("HIGH")
    UI.PositionMinimap(app)
    frame:SetNormalTexture(COMPASS_UP)
    frame:SetPushedTexture(COMPASS_DOWN)
    frame:SetHighlightAtlas("UI-QuestPoi-InnerGlow")
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self.dragging = true; self.dragged = true end)
    frame:SetScript("OnDragStop", function(self)
        if self.dragging then
            self.dragging = false
            UI.DragMinimap(app)
            C_Timer.After(0, function() self.dragged = false end)
        end
    end)
    frame:SetScript("OnUpdate", function(self)
        if self.dragging then UI.DragMinimap(app) end
    end)
    frame:SetScript("OnClick", function(_, mouseButton)
        if frame.dragging or frame.dragged then return end
        if mouseButton == "RightButton" then UI.Settings(app) else app:Toggle() end
    end)
    frame:SetScript("OnEnter", function(self)
        if not app.db.showTooltips then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Quest Targets")
        GameTooltip:AddLine(L("minimapTip"), 1, 1, 1)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame:SetShown(not app.db.minimapHidden)
end

function UI.PositionMinimap(app)
    if not UI.minimap then return end
    local angle = app.db.minimapAngle
    if type(angle) ~= "number" or angle ~= angle then angle = math.pi * 1.25 end
    local radiusX = (Minimap:GetWidth() or 140) / 2 + 2
    local radiusY = (Minimap:GetHeight() or 140) / 2 + 2
    UI.minimap:ClearAllPoints()
    UI.minimap:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radiusX, math.sin(angle) * radiusY)
end

function UI.DragMinimap(app)
    local cursorX, cursorY = GetCursorPosition()
    local mapX, mapY = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local x, y = cursorX / scale - mapX, cursorY / scale - mapY
    if x == 0 and y == 0 then return end
    if math.atan2 then
        app.db.minimapAngle = math.atan2(y, x)
    else
        app.db.minimapAngle = math.atan(y / x) + (x < 0 and math.pi or 0)
    end
    UI.PositionMinimap(app)
end

function UI.StopMaster(app)
    local frame = UI.master
    if not frame or not frame.moving or not frame.pendingStop or InCombatLockdown() then return end
    frame:StopMovingOrSizing()
    frame.moving = false
    frame.pendingStop = false
    local x, y = frame:GetCenter()
    local px, py = UIParent:GetCenter()
    app.db.masterPosition = {x = x - px, y = y - py}
end
