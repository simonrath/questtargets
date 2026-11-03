local _, NS = ...
local UI = NS.UI

function UI.WindowDimension(value, fallback, minimum, maximum)
    if type(value) ~= "number" or value ~= value then return fallback end
    return math.max(minimum, math.min(maximum, value))
end

function UI.LayoutWindow(app)
    if InCombatLockdown() then return end
    local width, height = UI.frame:GetWidth(), UI.frame:GetHeight()
    UI.PAGE_SIZE = math.max(2, math.min(20, math.floor((height - 120) / 39)))
    for _, row in ipairs(UI.rows) do
        row:SetWidth(width - 44)
        row.nameText:SetWidth(width - 77)
        row.detail:SetWidth(width - 77)
    end
    UI.database:SetWidth(width - 169)
    UI.empty:SetWidth(width - 48)
    UI.scrollbar:SetHeight(UI.PAGE_SIZE * 39 - 28)
    UI.settingsButton:SetWidth((width - 48) / 2)
    UI.feedbackButton:SetWidth((width - 48) / 2)
end

function UI.StopResizing(app)
    if not UI.resizing and not UI.resizePending then return end
    if InCombatLockdown() then
        UI.resizing, UI.resizePending = false, true
        return
    end
    UI.frame:StopMovingOrSizing()
    UI.resizing, UI.resizePending = false, false
    app.db.menuWidth, app.db.menuHeight = UI.frame:GetWidth(), UI.frame:GetHeight()
    -- StartSizing can change the frame's anchor; save the final screen position.
    UI.moving = true
    UI.StopMoving(app.db)
    UI.RestorePosition(app.db)
    UI.LayoutWindow(app)
    app:Schedule()
end

function UI.CreateResizeGrip(app)
    local frame = UI.frame
    frame:SetResizable(true)
    if frame.SetResizeBounds then frame:SetResizeBounds(282, 198, 700, 900)
    else frame:SetMinResize(282, 198); frame:SetMaxResize(700, 900) end
    local grip = CreateFrame("Button", nil, frame)
    UI.resizeGrip = grip
    grip:SetSize(18, 18)
    grip:SetPoint("BOTTOMRIGHT", -1, 1)
    grip:SetNormalTexture(386864)
    grip:SetPushedTexture(386862)
    grip:SetHighlightTexture(386863)
    grip:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or InCombatLockdown() or UI.moving then return end
        UI.resizing = true
        frame:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then UI.StopResizing(app) end
    end)
    frame:HookScript("OnHide", function() UI.StopResizing(app) end)
    frame:SetScript("OnSizeChanged", function()
        if InCombatLockdown() then return end
        UI.LayoutWindow(app)
        UI.Render(app)
    end)
    UI.LayoutWindow(app)
end
