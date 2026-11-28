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

local function layoutBarDividers(border, count, vertical, spacing, size)
    local pixel = PixelUtil and PixelUtil.GetPixelToUIUnitFactor
        and PixelUtil.GetPixelToUIUnitFactor() / border:GetEffectiveScale() or 1
    if pixel <= 0 or pixel == math.huge then pixel = 1 end
    if border.dividerCount == count and border.dividerVertical == vertical
        and border.dividerSpacing == spacing and border.dividerSize == size
        and border.dividerPixel == pixel then return end
    border.dividerCount, border.dividerVertical = count, vertical
    border.dividerSpacing, border.dividerSize, border.dividerPixel = spacing, size, pixel
    local function snap(value)
        local rounded = math.floor(math.abs(value) / pixel + 0.5) * pixel
        return value < 0 and -rounded or rounded
    end
    local center = (count * size + (count - 1) * spacing) / 2
    local length = snap(math.max(8, size - 8))
    local width = snap(math.max(3, math.min(6, spacing)))
    for index = 1, count - 1 do
        local divider = border.dividers[index]
        if not divider then
            divider = border:CreateTexture(nil, "OVERLAY")
            divider:SetTexture("Interface\\AddOns\\QuestTargets\\Textures\\TargetBarDivider")
            if divider.SetSnapToPixelGrid then divider:SetSnapToPixelGrid(false) end
            if divider.SetTexelSnappingBias then divider:SetTexelSnappingBias(0) end
            border.dividers[index] = divider
        end
        local position = snap(index * (size + spacing) - spacing / 2 - center)
        divider:ClearAllPoints()
        if vertical then
            divider:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
            divider:SetSize(length, width)
            divider:SetPoint("CENTER", border, "CENTER", 0, -position)
        else
            divider:SetTexCoord(0, 1, 0, 1)
            divider:SetSize(width, length)
            divider:SetPoint("CENTER", border, "CENTER", position, 0)
        end
        divider:Show()
    end
    for index = count, #border.dividers do border.dividers[index]:Hide() end
end

local function updateBarDecoration(app, master, first, count, vertical, spacing)
    local border = master.barBorder
    local showBorder, showDividers = app.db.masterBorder, app.db.masterDividers and count > 1
    local showBackground = app.db.masterBackground == true
    if not first or not (showBorder or showDividers or showBackground) then
        if border and border:IsShown() then border:Hide() end
        return
    end
    if not border then
        border = CreateFrame("Frame", nil, first, "BackdropTemplate")
        border:EnableMouse(false)
        border:SetBackdrop({
            edgeFile = "Interface\\AddOns\\QuestTargets\\Textures\\TargetBarBorder",
            edgeSize = 7,
        })
        border.dividers = {}
        master.barBorder = border
    end
    if showBackground and not border.background then
        local background = CreateFrame("Frame", nil, border, "BackdropTemplate")
        background:SetFrameStrata("LOW")
        background:EnableMouse(false)
        background:SetAllPoints(border)
        background:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            tile = true,
            tileSize = 32,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        background:SetBackdropColor(1, 1, 1, 0.85)
        border.background = background
    end
    if border.background and border.background:IsShown() ~= showBackground then
        border.background:SetShown(showBackground)
    end
    if border.borderVisible ~= showBorder then
        border:SetBackdropBorderColor(1, 1, 1, showBorder and 1 or 0)
        border.borderVisible = showBorder
    end
    local x, y = master.barOffsetX, master.barOffsetY
    if border.barAnchor ~= first or border.barOffsetX ~= x or border.barOffsetY ~= y then
        if border.barAnchor ~= first then border:SetParent(first) end
        border:ClearAllPoints()
        border:SetPoint("CENTER", first, "CENTER", x, y)
        border.barAnchor, border.barOffsetX, border.barOffsetY = first, x, y
    end
    local padding = showBorder and 12 or 6
    local width = master.barWidth + padding
    local height = master.barHeight + padding
    if showBorder or showBackground then
        width, height = width + 5, height + 4
    end
    if border:GetWidth() ~= width or border:GetHeight() ~= height then border:SetSize(width, height) end
    layoutBarDividers(border, showDividers and count or 1, vertical, spacing, master:GetHeight())
    if not border:IsShown() then border:Show() end
end

local function applyBarInput(button, locked)
    if button.barInputLocked == locked then return end
    button.barInputLocked = locked
    if locked then button:RegisterForDrag() else button:RegisterForDrag("RightButton") end
    if button.SetPassThroughButtons then
        if locked then pcall(button.SetPassThroughButtons, button, "RightButton")
        else pcall(button.SetPassThroughButtons, button) end
    end
end

local function layoutBarLock(app, first, last)
    local hover = UI.barLockHover
    if not first then
        if hover then hover:Hide(); UI.barLock:Hide() end
        return
    end
    if not hover then
        hover = CreateFrame("Frame", nil, UIParent)
        UI.barLockHover = hover
        local lock = CreateFrame("Button", nil, hover)
        UI.barLock = lock
        lock:SetSize(22, 26)
        lock:SetFrameStrata("HIGH")
        lock:SetPoint("CENTER", hover, "TOPLEFT", -3, 3)
        lock:SetNormalAtlas("QuestSharing-Padlock")
        lock:Hide()
        lock:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetText(L(app.db.masterLocked and "masterUnlock" or "masterLock"))
            GameTooltip:Show()
        end)
        lock:SetScript("OnLeave", function() GameTooltip:Hide() end)
        lock:SetScript("OnHide", function() GameTooltip:Hide() end)
        lock:SetScript("OnClick", function(self)
            if not IsShiftKeyDown() or InCombatLockdown() then return end
            UI.SetTargetBarLocked(app, not app.db.masterLocked)
            self:GetScript("OnEnter")(self)
        end)
        hover:SetScript("OnUpdate", function(self)
            local shown = not InCombatLockdown() and not UI.masterMoveActive
                and not UI.master.moving and IsShiftKeyDown()
                and (self:IsMouseOver() or (lock:IsShown() and lock:IsMouseOver()))
            if lock:IsShown() ~= shown then lock:SetShown(shown) end
        end)
    end
    if hover.first ~= first or hover.last ~= last then
        hover:ClearAllPoints()
        hover:SetPoint("TOPLEFT", first, "TOPLEFT")
        hover:SetPoint("BOTTOMRIGHT", last, "BOTTOMRIGHT")
        hover.first, hover.last = first, last
    end
    if hover.locked ~= app.db.masterLocked then
        hover.locked = app.db.masterLocked
        local icon = UI.barLock:GetNormalTexture()
        icon:SetDesaturated(not hover.locked)
        icon:SetAlpha(hover.locked and 1 or 0.65)
    end
    hover:Show()
end

function UI.SetTargetBarLocked(app, locked)
    if InCombatLockdown() then return end
    app.db.masterLocked = locked
    if UI.master and UI.master.moving then
        UI.master.pendingStop = true
        UI.StopMaster(app)
    end
    UI.LayoutTargetButtons(app)
    UI.UpdateMasterSettings(app)
end

function UI.LayoutTargetButtons(app)
    local master = UI.master
    if not master or InCombatLockdown() then return end
    local width, height = master:GetWidth(), master:GetHeight()
    local vertical = app.db.masterOrientation == "vertical"
    local spacing = app.db.masterSpacing
    local visible = not app.db.hotkeysOnly
    local masterShown = visible and master:IsShown()
    local previous = masterShown and master or nil
    local first = previous
    local count = masterShown and 1 or 0
    local barWidth, barHeight = 0, 0
    local locked = app.db.masterLocked == true
    applyBarInput(master, locked)
    if masterShown then barWidth, barHeight = width, height end
    local function place(button)
        if not button then return end
        applyBarInput(button, locked)
        count = count + 1
        first = first or button
        local anchor = previous or master
        local point, edge, x, y = "CENTER", "CENTER", 0, 0
        if previous then
            if vertical then point, edge, y = "TOP", "BOTTOM", -spacing
            else point, edge, x = "LEFT", "RIGHT", spacing end
        end
        if button.barAnchor ~= anchor or button.barEdge ~= edge or button.barGap ~= spacing then
            button:ClearAllPoints()
            button:SetPoint(point, anchor, edge, x, y)
            button.barAnchor, button.barEdge, button.barGap = anchor, edge, spacing
        end
        if button:GetWidth() ~= width or button:GetHeight() ~= height then button:SetSize(width, height) end
        local gap = previous and spacing or 0
        if vertical then
            barWidth = width
            barHeight = barHeight + gap + height
        else
            barWidth = barWidth + gap + width
            barHeight = height
        end
        previous = button
    end
    local rested = NS.RestedXP.button
    place(visible and rested and rested:IsShown() and rested)
    local item = NS.ItemTree.target
    place(visible and item and item.inBar and item)
    local rare = NS.RareScanner.markButton
    place(visible and rare and rare:IsShown() and rare)
    local offsetX = vertical and 0 or math.max(0, barWidth - width) / 2
    local offsetY = vertical and -math.max(0, barHeight - height) / 2 or 0
    local changed = master.barWidth ~= barWidth or master.barHeight ~= barHeight
        or master.barOffsetX ~= offsetX or master.barOffsetY ~= offsetY
    master.barWidth, master.barHeight = barWidth, barHeight
    master.barOffsetX, master.barOffsetY = offsetX, offsetY
    updateBarDecoration(app, master, first, count, vertical, spacing)
    layoutBarLock(app, first, previous)
    if changed and UI.masterMoveActive then
        if barWidth == 0 then UI.EndMasterMove(app, false)
        else UI.UpdateMasterMove(app) end
    end
end

function UI.RenderMaster(app)
    assert(not InCombatLockdown())
    if not UI.master then
        local frame = CreateFrame("Button", "QuestTargetsMaster", UIParent, "SecureActionButtonTemplate")
        UI.master = frame
        frame:SetFrameStrata("MEDIUM")
        frame:SetClampedToScreen(true)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("RightButton")
        frame:RegisterForClicks("AnyUp")
        frame:SetAttribute("useOnKeyDown", false)
        frame:SetAttribute("type1", "macro")
        frame:SetNormalTexture(COMPASS_UP)
        frame:SetPushedTexture(COMPASS_DOWN)
        frame:GetNormalTexture():SetAllPoints(frame)
        frame:GetPushedTexture():SetAllPoints(frame)
        local pos = app.db.masterPosition
        if type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" then
            frame:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
        end
        frame:SetScript("OnDragStart", function(self)
            if app.db.masterLocked then return end
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
            NS.RestedXP.PreClick(app, self)
        end)
        frame:SetScript("PostClick", function(self, _, down)
            if down then return end
            Core.RecordClickResult()
            if not InCombatLockdown() then
                self:SetAttribute("macrotext1", (Core.EntryMacro(self.entry, Core.TargetFeedbackSettings(app.db, "master"))))
            end
        end)
        frame:SetScript("OnEnter", function(self)
            if not app.db.showTooltips then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("masterTooltipTitle"))
            GameTooltip:AddLine(L(app.db.masterAllModules == false and "masterQuestOnlyTip" or "masterTip1"), 1, 1, 1, true)
            GameTooltip:AddLine(L(app.db.masterLocked and "masterLockTip" or "masterTip2"), 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    UI.ApplyPendingMasterMove(app)
    UI.StopMaster(app)
    local size = math.floor(60 * app.db.masterModernScale + 0.5)
    if UI.master:GetWidth() ~= size then UI.master:SetSize(size, size) end
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
    UI.master:SetAttribute("macrotext1", (Core.EntryMacro(entry, Core.TargetFeedbackSettings(app.db, "master"))))
    local hotkeysOnly = app.db.hotkeysOnly == true
    UI.master:SetShown(hotkeysOnly or not app.db.masterHidden)
    UI.master:SetAlpha(hotkeysOnly and 0 or 1)
    UI.master:EnableMouse(not hotkeysOnly)
    UI.LayoutTargetButtons(app)
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
            Core.SetClickMacro(self, Core.ClickMacro(self.entry, app.allEntries or {}, Core.TargetFeedbackSettings(app.db, "focus"), self), app.db)
        end)
        frame:SetScript("PostClick", function(self, _, down)
            if down then return end
            Core.RecordClickResult()
            if not InCombatLockdown() then self:SetAttribute("macrotext1", (Core.EntryMacro(self.entry, Core.TargetFeedbackSettings(app.db, "focus")))) end
        end)
    end
    local selected
    for _, quest in ipairs(Core.QuestEntriesFor(app, true)) do
        if quest.questID == app.db.focusQuestID then selected = quest; break end
    end
    UI.focusButton.entry = selected
    UI.focusButton:SetAttribute("macrotext1", (selected and Core.EntryMacro(selected, Core.TargetFeedbackSettings(app.db, "focus")) or ""))
end

function UI.CreateMinimap(app)
    if UI.minimap or not Minimap then return end
    local icon = LibStub("LibDBIcon-1.0")
    local broker = LibStub("LibDataBroker-1.1"):NewDataObject("QuestTargets", {
        type = "launcher", label = L("title"), icon = COMPASS_UP,
        OnClick = function(_, mouseButton)
            if mouseButton == "RightButton" then UI.Settings(app) else app:Toggle() end
        end,
        OnTooltipShow = function(tooltip)
            if not app.db.showTooltips then return end
            tooltip:SetText(L("title"))
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
    local height = master.barHeight or master:GetHeight()
    local offsetX, offsetY = master.barOffsetX or 0, master.barOffsetY or 0
    edit:SetSize(math.max(380, math.max(360, width) + 2 * math.abs(offsetX) + 12),
        height + 2 * math.abs(offsetY) + 112)
    edit.outline:ClearAllPoints()
    edit.outline:SetPoint("CENTER", edit, "CENTER", offsetX, offsetY)
    edit.outline:SetSize(math.max(28, width + 8), math.max(28, height + 8))
    edit.grip:ClearAllPoints()
    edit.grip:SetPoint("BOTTOM", edit, "CENTER", offsetX, offsetY + height / 2 + 8)
    edit.toolbar:ClearAllPoints()
    edit.toolbar:SetPoint("TOP", edit, "CENTER", offsetX, offsetY - height / 2 - 8)
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

function UI.CloseSettings()
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
    if UI.masterMoveActive then UI.CloseSettings(); return true end
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
    UI.CloseSettings()
    return true
end
