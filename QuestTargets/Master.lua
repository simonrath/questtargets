local _, NS = ...
local UI, Core = NS.UI, NS.Core
local L = NS.L
local COMPASS_UP = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassUp"
local COMPASS_DOWN = "Interface\\AddOns\\QuestTargets\\Textures\\QuestCompassDown"

function UI.StyleTargetButton(button, red, green, blue)
    button:SetNormalTexture(COMPASS_UP)
    button:SetPushedTexture(COMPASS_DOWN)
    for _, texture in ipairs({button:GetNormalTexture(), button:GetPushedTexture()}) do
        texture:SetAllPoints(button)
        texture:SetDesaturated(true)
        texture:SetVertexColor(red, green, blue)
    end
    button:SetFrameStrata("MEDIUM")
    button:RegisterForDrag("RightButton")
    button:SetScript("OnDragStart", function()
        UI.master:GetScript("OnDragStart")(UI.master)
    end)
    button:SetScript("OnDragStop", function()
        UI.master:GetScript("OnDragStop")(UI.master)
    end)
end

function UI.LayoutTargetButtons(app)
    local master = UI.master
    if not master or InCombatLockdown() then return end
    local width, height = master:GetWidth(), master:GetHeight()
    local iconWidth = master.modernAppearance and height or math.floor(33 * app.db.masterScaleX + 0.5)
    local previous = master:IsShown() and master or nil
    local barWidth = previous and width or 0
    local function place(button)
        if not button then return end
        local anchor, edge = previous or master, previous and "RIGHT" or "CENTER"
        if button.barAnchor ~= anchor or button.barEdge ~= edge then
            button:ClearAllPoints()
            button:SetPoint(previous and "LEFT" or "CENTER", anchor, edge, previous and 4 or 0, 0)
            button.barAnchor, button.barEdge = anchor, edge
        end
        if button:GetWidth() ~= iconWidth or button:GetHeight() ~= height then button:SetSize(iconWidth, height) end
        barWidth = barWidth + (previous and 4 or 0) + iconWidth
        previous = button
    end
    local rested = NS.RestedXP.button
    place(rested and rested:IsShown() and rested)
    local item = NS.ItemTree.target
    place(item and item.inBar and item)
    master.barWidth = barWidth
    master.barOffset = math.max(0, barWidth - (master:IsShown() and width or iconWidth)) / 2
end

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
            if UI.masterMoveActive then UI.StartMasterMoveDrag(app); return end
            if not InCombatLockdown() then
                self.pendingStop = false
                self:StartMoving(); self.moving = true
            end
        end)
        frame:SetScript("OnDragStop", function(self)
            if UI.masterMoveActive then UI.StopMasterMoveDrag(app); return end
            if self.moving then self.pendingStop = true; UI.StopMaster(app) end
        end)
        frame:SetScript("PreClick", function(self, mouseButton, down)
            if InCombatLockdown() and mouseButton == "LeftButton" and not down then
                Core.PrepareDeadTargetSound(self:GetAttribute("macrotext1"), app.db)
            end
            if mouseButton ~= "LeftButton" or down or InCombatLockdown() then return end
            if NS.RestedXP.PreClick(app, self) then return end
            Core.SetClickMacro(self, Core.ClickMacro(self.entry, app.allEntries or {}, app.db, self), app.db)
        end)
        frame:SetScript("PostClick", function(self, _, down)
            if down then return end
            Core.RecordClickResult()
            if NS.RestedXP.PostClick(app) then return end
            if not InCombatLockdown() then self:SetAttribute("macrotext1", (Core.EntryMacro(self.entry, app.db))) end
        end)
        frame:SetScript("OnEnter", function(self)
            if not app.db.showTooltips then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("active"))
            if NS.RestedXP.active then
                GameTooltip:AddLine(L("restedXPButton"), 1, 0.82, 0, true)
                GameTooltip:AddLine(self.entry and self.entry.name or L("restedXPNoTarget"), 1, 1, 1, true)
            else
                GameTooltip:AddLine(L("masterTip1"), 1, 1, 1, true)
                GameTooltip:AddLine(L("masterTip3"), 0.75, 0.75, 0.75, true)
            end
            GameTooltip:AddLine(L("masterTip2"), 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    UI.ApplyPendingMasterMove(app)
    UI.StopMaster(app)
    UI.PositionMaster(app)
    UI.CreateMinimap(app)
    local entry = {title = L("active"), refs = {}, names = {}, nameList = {}, finisherNames = {}}
    for _, quest in ipairs(Core.QuestEntriesFor(app, true)) do
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
    UI.master.defaultEntry = entry
    UI.master.entry = entry
    UI.master:SetAttribute("macrotext1", (Core.EntryMacro(entry, app.db)))
    UI.master:SetShown(not app.db.masterHidden)
    UI.LayoutTargetButtons(app)
    if UI.masterMoveActive then
        if UI.master.barWidth == 0 then UI.EndMasterMove(app, false)
        else UI.UpdateMasterMove(app) end
    end
    UI.RenderFocus(app)
end

function UI.RenderFocus(app)
    if InCombatLockdown() then return end
    if not UI.focusButton then
        local frame = CreateFrame("Button", "QuestTargetsFocused", UIParent, "SecureActionButtonTemplate")
        UI.focusButton = frame
        frame:SetSize(1, 1)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetAlpha(0)
        frame:EnableMouse(false)
        frame:RegisterForClicks("AnyUp")
        frame:SetAttribute("useOnKeyDown", false)
        frame:SetAttribute("type1", "macro")
        frame:SetScript("PreClick", function(self, mouseButton, down)
            if InCombatLockdown() and mouseButton == "LeftButton" and not down then
                Core.PrepareDeadTargetSound(self:GetAttribute("macrotext1"), app.db)
            end
            if mouseButton ~= "LeftButton" or down or InCombatLockdown() then return end
            Core.SetClickMacro(self, Core.ClickMacro(self.entry, app.allEntries or {}, app.db, self), app.db)
        end)
        frame:SetScript("PostClick", function(self, _, down)
            if down then return end
            Core.RecordClickResult()
            if not InCombatLockdown() then self:SetAttribute("macrotext1", (Core.EntryMacro(self.entry, app.db))) end
        end)
    end
    local selected
    for _, quest in ipairs(Core.QuestEntriesFor(app, true)) do
        if quest.questID == app.db.focusQuestID then selected = quest; break end
    end
    UI.focusButton.entry = selected
    UI.focusButton:SetAttribute("macrotext1", (selected and Core.EntryMacro(selected, app.db) or ""))
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
        local size = math.floor(60 * app.db.masterModernScale + 0.5)
        frame:SetSize(size, size)
        frame:SetText("")
    else
        frame:SetSize(math.floor(210 * app.db.masterScaleX + 0.5),
            math.floor(33 * app.db.masterScaleY + 0.5))
        frame:SetText(app.db.masterText)
    end
end

function UI.CreateMinimap(app)
    if UI.minimap or not Minimap then return end
    local icon = LibStub("LibDBIcon-1.0")
    local broker = LibStub("LibDataBroker-1.1"):NewDataObject("QuestTargets", {
        type = "launcher", icon = COMPASS_UP,
        OnClick = function(_, mouseButton)
            if mouseButton == "RightButton" then UI.Settings(app) else app:Toggle() end
        end,
        OnTooltipShow = function(tooltip)
            if not app.db.showTooltips then return end
            tooltip:SetText("Quest Targets")
            tooltip:AddLine(L("minimapTip"), 1, 1, 1)
        end,
    })
    icon:Register("QuestTargets", broker, app.db.minimap)
    UI.minimap = icon:GetMinimapButton("QuestTargets")
end

function UI.SetMinimapShown(app, shown)
    app.db.minimapHidden = not shown
    app.db.minimap.hide = not shown
    local icon = LibStub("LibDBIcon-1.0")
    if shown then icon:Show("QuestTargets") else icon:Hide("QuestTargets") end
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

-- Editor controls have no protected children or anchors to the secure button.
-- Only this ordinary frame is StartMoving'd in edit mode. Its position is
-- mirrored to the real button out of combat, leaving secure clicks untouched.
local function moveCursor(show)
    local edit = UI.masterMove
    if not edit or not SetCursor then return end
    if show then
        SetCursor("UI_MOVE_CURSOR")
        edit.ownsCursor = true
    elseif edit.ownsCursor then
        SetCursor(nil)
        edit.ownsCursor = false
    end
end

local function placeMaster(position)
    UI.master:ClearAllPoints()
    UI.master:SetPoint("CENTER", UIParent, "CENTER", position.x, position.y)
end

local function placeEditor(position)
    UI.masterMove:ClearAllPoints()
    UI.masterMove:SetPoint("CENTER", UIParent, "CENTER", position.x, position.y)
end

local function editorPosition()
    local x, y = UI.masterMove:GetCenter()
    local px, py = UIParent:GetCenter()
    return {x = x - px, y = y - py}
end

function UI.UpdateMasterMove(app)
    if not UI.masterMoveActive or InCombatLockdown() then return end
    local edit, master = UI.masterMove, UI.master
    local width = master.barWidth or master:GetWidth()
    local offset = master.barOffset or 0
    edit:SetSize(math.max(380, width + 2 * offset + 12), master:GetHeight() + 112)
    edit.outline:ClearAllPoints()
    edit.outline:SetPoint("CENTER", edit, "CENTER", offset, 0)
    edit.outline:SetSize(math.max(28, width + 8), math.max(28, master:GetHeight() + 8))
    edit.grip:ClearAllPoints()
    edit.grip:SetPoint("BOTTOM", edit, "CENTER", 0, master:GetHeight() / 2 + 8)
    edit.toolbar:ClearAllPoints()
    edit.toolbar:SetPoint("TOP", edit, "CENTER", 0, -master:GetHeight() / 2 - 8)
    edit.grip:SetText(L("masterMoveDrag"))
    edit.done:SetText(L("masterMoveDone"))
    edit.cancel:SetText(L("masterMoveCancel"))
    edit.reset:SetText(L("masterMoveReset"))
    -- The editor includes its controls in its clamped bounds. Mirror any
    -- clamping to the preview as well, so an edge-positioned button never
    -- becomes detached from its grip. Cancel still restores the original.
    local position = editorPosition()
    placeMaster(position)
    if not edit.dragging then edit.released = position end
end

function UI.StartMasterMoveDrag(app)
    if not UI.masterMoveActive or InCombatLockdown() then return end
    local edit = UI.masterMove
    edit:StartMoving()
    edit.dragging = true
    moveCursor(true)
end

function UI.StopMasterMoveDrag(app)
    local edit = UI.masterMove
    if not edit or not edit.dragging then return end
    edit:StopMovingOrSizing()
    edit.dragging = false
    moveCursor(false)
    if not UI.masterMoveActive or InCombatLockdown() then return end
    edit.released = editorPosition()
    placeMaster(edit.released)
end

function UI.ApplyPendingMasterMove(app)
    if not UI.pendingMasterMove or InCombatLockdown() then return end
    local position = UI.pendingMasterMove
    UI.pendingMasterMove = nil
    placeMaster(position)
    app.db.masterPosition = position
end

function UI.EndMasterMove(app, accept)
    if not UI.masterMoveActive then return end
    local edit = UI.masterMove
    if InCombatLockdown() then
        -- Commit only the last released preview. Never read an unfinished
        -- mouse drag into SavedVariables, or move the secure button in combat.
        UI.pendingMasterMove = edit.released
        edit:StopMovingOrSizing()
        edit.dragging = false
    else
        UI.StopMasterMoveDrag(app)
        if accept then
            app.db.masterPosition = edit.released
            placeMaster(edit.released)
        else
            placeMaster(edit.original)
        end
    end
    UI.masterMoveActive = false
    moveCursor(false)
    edit:Hide()
end

function UI.ResetMasterMove(app)
    if not UI.masterMoveActive or InCombatLockdown() then return end
    UI.StopMasterMoveDrag(app)
    local position = {x = 0, y = -180}
    UI.masterMove.released = position
    placeEditor(position)
    placeMaster(position)
end

local function createMasterMove(app)
    local edit = CreateFrame("Frame", "QuestTargetsMasterMove", UIParent)
    UI.masterMove = edit
    edit:SetFrameStrata("DIALOG")
    edit:SetClampedToScreen(true)
    edit:SetMovable(true)
    edit:Hide()
    edit.outline = CreateFrame("Frame", nil, edit, "BackdropTemplate")
    edit.outline:SetPoint("CENTER", edit, "CENTER")
    edit.outline:SetBackdrop({edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=16})
    local function control(parent, width, callback)
        local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        button:SetSize(width, 28)
        button:SetScript("OnClick", callback)
        return button
    end
    edit.grip = control(edit, 360, function() end)
    edit.grip:RegisterForDrag("LeftButton")
    edit.grip:SetScript("OnDragStart", function() UI.StartMasterMoveDrag(app) end)
    edit.grip:SetScript("OnDragStop", function() UI.StopMasterMoveDrag(app) end)
    edit.grip:SetScript("OnEnter", function()
        if UI.masterMoveActive and not InCombatLockdown() then moveCursor(true) end
    end)
    edit.grip:SetScript("OnLeave", function()
        if not edit.dragging then moveCursor(false) end
    end)
    edit.toolbar = CreateFrame("Frame", nil, edit)
    edit.toolbar:SetSize(360, 28)
    edit.done = control(edit.toolbar, 100, function() UI.EndMasterMove(app, true) end)
    edit.cancel = control(edit.toolbar, 100, function() UI.EndMasterMove(app, false) end)
    edit.reset = control(edit.toolbar, 152, function() UI.ResetMasterMove(app) end)
    edit.done:SetPoint("LEFT", edit.toolbar, "LEFT")
    edit.cancel:SetPoint("LEFT", edit.done, "RIGHT", 4, 0)
    edit.reset:SetPoint("LEFT", edit.cancel, "RIGHT", 4, 0)
    edit:SetScript("OnUpdate", function()
        if UI.masterMoveActive and edit.dragging and not InCombatLockdown() then
            placeMaster(editorPosition())
        end
    end)
    edit:SetScript("OnHide", function() UI.EndMasterMove(app, false); moveCursor(false) end)
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = "QuestTargetsMasterMove" end
end

local function closeMasterMoveSettings()
    if SettingsPanel then
        if HideUIPanel then HideUIPanel(SettingsPanel)
        elseif SettingsPanel.Hide then SettingsPanel:Hide() end
    end
    if InterfaceOptionsFrame and HideUIPanel then HideUIPanel(InterfaceOptionsFrame) end
    if UI.settings then UI.settings:Hide() end
end

function UI.BeginMasterMove(app)
    if InCombatLockdown() then print(L("masterMoveCombat")); return false end
    if not app.db or not UI.master or UI.master.barWidth == 0 then
        print(L("masterMoveHidden")); return false
    end
    if UI.masterMoveActive then closeMasterMoveSettings(); return true end
    if UI.master.moving then UI.master.pendingStop = true; UI.StopMaster(app) end
    if not UI.masterMove then createMasterMove(app) end
    local edit = UI.masterMove
    local saved = app.db.masterPosition
    local valid = type(saved) == "table" and type(saved.x) == "number" and type(saved.y) == "number"
    edit.original = valid and {x=saved.x, y=saved.y} or {x=0, y=-180}
    edit.released = {x=edit.original.x, y=edit.original.y}
    placeEditor(edit.original)
    UI.masterMoveActive = true
    UI.UpdateMasterMove(app)
    edit:Show()
    closeMasterMoveSettings()
    return true
end
