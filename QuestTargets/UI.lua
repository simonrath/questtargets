local _, NS = ...
local UI = {}
NS.UI = UI
local L = NS.L
local FEEDBACK_URL = "https://feedback.jacknine.org/"
UI.PAGE_SIZE = 6

function UI.OptionsTitle()
    local get = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local version = get and get("QuestTargets", "Version")
    return L("title") .. (type(version) == "string" and version ~= "" and (" " .. version) or "")
end

local function addonLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name) == true
    end
    return true -- Older clients without the query API retain their existing settings behavior.
end

local MASTER_BINDING = "CLICK QuestTargetsMaster:LeftButton"
local FOCUS_BINDING = "CLICK QuestTargetsFocused:LeftButton"
local ITEMTREE_BINDING = "CLICK QuestTargetsItemTree:LeftButton"
local RARESCANNER_BINDING = "CLICK QuestTargetsRareScannerMark:LeftButton"
local function bindingAction(focused)
    if focused == "itemTree" then return ITEMTREE_BINDING, "QuestTargetsItemTree" end
    if focused == "rareScanner" then return RARESCANNER_BINDING, "QuestTargetsRareScannerMark" end
    if focused then return FOCUS_BINDING, "QuestTargetsFocused" end
    return MASTER_BINDING, "QuestTargetsMaster"
end

local function bindingAvailable(action)
    if action == "itemTree" then return addonLoaded("ItemTree") end
    if action == "rareScanner" then return NS.RareScanner.MarkingAvailable() end
    return true
end

local function bindingText(key)
    if not key then return L("unbound") end
    return GetBindingText and GetBindingText(key) or key
end
local function setGamePadCapture(button, enabled)
    -- Older clients do not expose gamepad frame input. Keep their keyboard path.
    if not button.EnableGamePadButton then return end
    button:EnableGamePadButton(enabled)
    button:SetScript("OnGamePadButtonDown", enabled and button:GetScript("OnKeyDown") or nil)
end

local function replaceBindingPair(command, target, first, second)
    local oldFirst, oldSecond = GetBindingKey(command)
    local displaced = {}
    for _, key in pairs({first, second}) do
        local owner = GetBindingAction and GetBindingAction(key)
        if owner and owner ~= "" and owner ~= command then
            displaced[owner] = {GetBindingKey(owner)}
        end
    end
    if oldFirst then SetBinding(oldFirst) end
    if oldSecond and oldSecond ~= oldFirst then SetBinding(oldSecond) end
    local keys = {first, second}
    for slot = 1, 2 do
        local key = keys[slot]
        if key and not SetBindingClick(key, target, "LeftButton") then
            if first then SetBinding(first) end
            if second then SetBinding(second) end
            if oldFirst then SetBindingClick(oldFirst, target, "LeftButton") end
            if oldSecond then SetBindingClick(oldSecond, target, "LeftButton") end
            for owner, original in pairs(displaced) do
                local currentFirst, currentSecond = GetBindingKey(owner)
                if currentFirst then SetBinding(currentFirst) end
                if currentSecond then SetBinding(currentSecond) end
                for index = 1, 2 do
                    if original[index] then SetBinding(original[index], owner) end
                end
            end
            return false
        end
    end
    return true
end

local function setBindingSlot(app, focused, binding, slot)
    if InCombatLockdown() then return false end
    local command, target = bindingAction(focused)
    local first, second = GetBindingKey(command)
    if slot == 2 then
        second = binding
        if binding and first == binding then first = nil end
    else
        first = binding
        if binding and second == binding then second = nil end
    end
    if not replaceBindingPair(command, target, first, second) then return false end
    -- A master binding can take a key from Focus. Keep its saved pair in sync
    -- so the next refresh does not steal that key back.
    app.db.focusHotkeyKey, app.db.focusHotkeyKey2 = GetBindingKey(FOCUS_BINDING)
    SaveBindings(GetCurrentBindingSet())
    return true
end

function UI.SyncFocusBinding(app)
    if InCombatLockdown() then return end
    local first, second = GetBindingKey(FOCUS_BINDING)
    if not app.focusBindingsInitialized then
        app.focusBindingsInitialized = true
        -- Migrate legacy saved bindings once. Afterwards WoW's binding set is
        -- authoritative, including an intentionally cleared native assignment.
        if not app.db.focusBindingsNative and not first and not second then
            replaceBindingPair(FOCUS_BINDING, "QuestTargetsFocused",
                app.db.focusHotkeyKey, app.db.focusHotkeyKey2)
        end
        app.db.focusBindingsNative = true
    end
    app.db.focusHotkeyKey, app.db.focusHotkeyKey2 = GetBindingKey(FOCUS_BINDING)
end

local BINDING_CONFIRMATION = "QUESTTARGETS_BINDING_CONFLICT"

local function cancelBindingConfirmation()
    if not UI.bindingConfirmation then return end
    UI.bindingConfirmation = nil
    if StaticPopup_Hide then StaticPopup_Hide(BINDING_CONFIRMATION) end
end

local function stopBindingCapture()
    cancelBindingConfirmation()
    local capture = UI.bindingCapture
    if not capture then return end
    UI.bindingCapture = nil
    if capture.overlay then
        capture.overlay:Hide()
        capture.overlay:SetScript("OnClick", nil)
        capture.overlay:SetScript("OnMouseWheel", nil)
    end
    capture.button.listening = false
    capture.button:EnableKeyboard(false)
    setGamePadCapture(capture.button, false)
    capture.button:SetScript("OnKeyDown", nil)
    capture.button:SetScript("OnClick", capture.onClick)
    capture.button:RegisterForClicks("LeftButtonUp")
    capture.button:SetScript("OnMouseWheel", capture.onMouseWheel)
    capture.button:EnableMouseWheel(capture.mouseWheelEnabled)
    capture.refresh()
end

UI.CancelBindingAssignment = stopBindingCapture

local function bindingActionName(command)
    if command == MASTER_BINDING then return L("masterDefault") end
    if command == FOCUS_BINDING then return L("focusHotkey") end
    if command == ITEMTREE_BINDING then return L("itemTreeBinding") end
    if command == RARESCANNER_BINDING then return L("rareScannerBinding") end
    return GetBindingName and GetBindingName(command) or command
end

local function requestBindingSlot(button, app, focused, binding, slot, refresh)
    local command = bindingAction(focused)
    local oldAction = binding and GetBindingAction and GetBindingAction(binding)
    if not oldAction or oldAction == "" or oldAction == command then
        setBindingSlot(app, focused, binding, slot)
        refresh()
        return
    end
    -- Fail closed if a client cannot display its native confirmation dialog.
    if not StaticPopupDialogs or not StaticPopup_Show then return end
    local first, second = GetBindingKey(command)
    local pending = {button=button, app=app, focused=focused, slot=slot,
        binding=binding, oldAction=oldAction, command=command,
        first=first, second=second, refresh=refresh}
    UI.bindingConfirmation = pending
    local message = string.format(L("bindingConflict"), bindingText(binding),
        bindingActionName(oldAction), bindingActionName(command))
    StaticPopupDialogs[BINDING_CONFIRMATION] = {
        text="%s",
        button1=L("bindingReplace"), button2=CANCEL or L("masterMoveCancel"),
        timeout=0, whileDead=true, hideOnEscape=true,
        OnAccept=function(self, data)
            data = data or self.data
            if not data or UI.bindingConfirmation ~= data then return end
            UI.bindingConfirmation = nil
            local currentFirst, currentSecond = GetBindingKey(data.command)
            if InCombatLockdown() or GetBindingAction(data.binding) ~= data.oldAction
                or currentFirst ~= data.first or currentSecond ~= data.second then
                print("|cffffd100" .. L("title") .. ":|r " .. L("bindingConflictChanged"))
            else
                setBindingSlot(data.app, data.focused, data.binding, data.slot)
            end
            data.refresh()
        end,
        OnCancel=function()
            if UI.bindingConfirmation == pending then UI.bindingConfirmation = nil end
        end,
        OnHide=function()
            if UI.bindingConfirmation == pending then UI.bindingConfirmation = nil end
        end,
    }
    if not StaticPopup_Show(BINDING_CONFIRMATION, message, nil, pending) then
        UI.bindingConfirmation = nil
    end
end

local function beginBindingCapture(button, app, focused, slot, refresh)
    if InCombatLockdown() then return end
    stopBindingCapture()
    UI.bindingCapture = {button=button, refresh=refresh,
        onClick=button:GetScript("OnClick"), onMouseWheel=button:GetScript("OnMouseWheel"),
        mouseWheelEnabled=button.IsMouseWheelEnabled and button:IsMouseWheelEnabled() or false}
    button.listening = true
    button:SetText(L("pressKey"))
    button:EnableKeyboard(true)
    button:SetPropagateKeyboardInput(false)
    button:SetScript("OnKeyDown", function(self, key)
        if key == "LSHIFT" or key == "RSHIFT" or key == "SHIFT"
            or key == "LCTRL" or key == "RCTRL" or key == "CTRL"
            or key == "LALT" or key == "RALT" or key == "ALT" then return end
        local assign = not InCombatLockdown() and key ~= "ESCAPE" and key ~= "UNKNOWN"
        local binding
        if assign then
            if key ~= "DELETE" and key ~= "BACKSPACE" then
                binding = (IsControlKeyDown() and "CTRL-" or "")
                    .. (IsAltKeyDown() and "ALT-" or "")
                    .. (IsShiftKeyDown() and "SHIFT-" or "") .. key
            end
        end
        stopBindingCapture()
        if assign then requestBindingSlot(self, app, focused, binding, slot, refresh) end
    end)
    -- As in Blizzard's custom binding controls, mouse input needs explicit
    -- click registration and conversion to BUTTONn. Keep LMB/RMB for cancel.
    -- Capture on release so the opening click cannot bind itself or reopen
    -- capture after a mouse assignment has restored the original handler.
    button:RegisterForClicks("AnyUp")
    button:SetScript("OnClick", function(self, mouseButton)
        local key
        if mouseButton == "LeftButton" or mouseButton == "RightButton" then
            key = "ESCAPE"
        elseif mouseButton == "MiddleButton" then
            key = "BUTTON3"
        else
            local index = type(mouseButton) == "string" and mouseButton:match("^Button(%d+)$")
            index = tonumber(index)
            if index and index >= 4 and index <= 31 then key = "BUTTON" .. index end
        end
        if key then self:GetScript("OnKeyDown")(self, key) end
    end)
    button:EnableMouseWheel(true)
    button:SetScript("OnMouseWheel", function(self, delta)
        if delta ~= 0 then
            self:GetScript("OnKeyDown")(self, delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN")
        end
    end)
    setGamePadCapture(button, true)
    -- Mouse events only reach the frame under the cursor. A temporary ordinary
    -- overlay receives them anywhere without modifying Blizzard input handlers.
    if not UI.bindingOverlay then
        local overlay = CreateFrame("Button", nil, UIParent)
        overlay:SetAllPoints(UIParent)
        overlay:SetFrameStrata("TOOLTIP")
        overlay:SetFrameLevel(1000)
        overlay:EnableMouse(true)
        overlay:EnableMouseWheel(true)
        overlay:RegisterForClicks("AnyUp")
        overlay:SetScript("OnHide", function()
            if UI.bindingCapture and UI.bindingCapture.overlay == overlay then stopBindingCapture() end
        end)
        UI.bindingOverlay = overlay
    end
    local overlay = UI.bindingOverlay
    UI.bindingCapture.overlay = overlay
    local mouseClick, mouseWheel = button:GetScript("OnClick"), button:GetScript("OnMouseWheel")
    overlay:SetScript("OnClick", function(_, mouseButton) mouseClick(button, mouseButton) end)
    overlay:SetScript("OnMouseWheel", function(_, delta) mouseWheel(button, delta) end)
    overlay:Show()
    if not button.questTargetsHideHook then
        button.questTargetsHideHook = true
        button:HookScript("OnHide", function(self)
            if UI.bindingCapture and UI.bindingCapture.button == self then stopBindingCapture() end
            if UI.bindingConfirmation and UI.bindingConfirmation.button == self then cancelBindingConfirmation() end
        end)
    end
end

function UI.BeginMasterBinding(button, app, refresh)
    beginBindingCapture(button, app, false, 1, refresh)
end

function UI.MasterBindingText()
    local first, second = GetBindingKey(MASTER_BINDING)
    local binding = first or second
    return binding and bindingText(binding) or L("tutorialAssign"), binding ~= nil
end

function UI.ToggleFocus(app, entry)
    if InCombatLockdown() or not entry or not entry.questID then return end
    if app.db.focusQuestID == entry.questID then
        app.db.focusQuestID = nil
    else
        app.db.focusQuestID = entry.questID
    end
    UI.RenderRows(app)
    UI.RenderFocus(app)
    if NS.EllesmereTracker then NS.EllesmereTracker.UpdateFocusMarks(app) end
    NS.FlareUITracker.UpdateFocusMarks(app)
    if NS.QuestieTracker and NS.QuestieTracker.UpdateFocusMarks then
        NS.QuestieTracker.UpdateFocusMarks(app)
    end
end

function UI.CreateFocusMark(parent, anchor, size)
    local mark = parent:CreateTexture(nil, "OVERLAY")
    local atlas = "UI-QuestPoi-InnerGlow"
    if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
        mark:SetAtlas(atlas)
    else
        -- Same highlight sprite as Blizzard's POIButtonTemplate on older clients.
        mark:SetTexture("Interface\\WorldMap\\UI-QuestPoi-NumberIcons")
        mark:SetTexCoord(0.625, 0.75, 0.375, 0.5)
    end
    mark:SetBlendMode("ADD")
    mark:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    mark:SetSize(size, size)
    mark:Hide()
    return mark
end

local function setChromeAlpha(alpha)
    for _, region in ipairs(UI.chrome or {}) do region:SetAlpha(alpha) end
    UI.chromeAlpha = alpha
end

local function scheduleTransparencyIconHide(app)
    UI.transparencyTimer = (UI.transparencyTimer or 0) + 1
    local timer = UI.transparencyTimer
    if not app.db.transparencyMode then return end
    C_Timer.After(2, function()
        if timer == UI.transparencyTimer and app.db.transparencyMode
            and UI.transparencyButton and not UI.frame:IsMouseOver() then
            UI.transparencyButton:SetAlpha(0)
        end
    end)
end

function UI.UpdateTransparency(app)
    if not UI.frame then return end
    local alpha = app.db.transparencyMode and 0 or 1
    if UI.chromeAlpha ~= alpha then setChromeAlpha(alpha) end
    if UI.dragHint then
        UI.dragHint:SetAlpha(app.db.transparencyMode and UI.frame:IsMouseOver() and 0.1 or 0)
    end
    if UI.resizeGrip then UI.resizeGrip:SetAlpha((not app.db.transparencyMode or UI.frame:IsMouseOver()) and 1 or 0) end
    if UI.transparencyButton then
        UI.transparencyButton:GetNormalTexture():SetDesaturated(not app.db.transparencyMode)
        UI.transparencyButton:SetAlpha(1)
        UI.transparencyOver = app.db.transparencyMode and UI.frame:IsMouseOver() or false
        if not UI.transparencyOver then scheduleTransparencyIconHide(app) end
    end
end

local function label(parent, x, y, width, font)
    local text = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", x, y)
    text:SetWidth(width)
    text:SetJustifyH("LEFT")
    return text
end

local function button(parent, text, width, callback)
    local frame = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    frame:SetSize(width, 22)
    frame:SetText(text)
    frame:SetScript("OnClick", callback)
    return frame
end

local function checkbox(parent, caption, callback)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(26, 26)
    check:SetScript("OnClick", callback)
    local title = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("LEFT", check, "RIGHT", 8, 0)
    title:SetText(caption)
    check.caption = title
    return check
end

local feedbackButtons = {
    {"master", "feedbackMaster"}, {"restedXP", "feedbackRestedXP"},
    {"itemTree", "feedbackItemTree"}, {"rare", "feedbackRareScanner"},
    {"focus", "feedbackFocus"}, {"questList", "window"},
    {"questie", "feedbackQuestie"}, {"ellesmere", "feedbackEllesmere"},
}

local function feedbackChoices()
    local choices = {L("feedbackNone"), L("feedbackRaidMarker")}
    if NS.Core.PingAvailable() then choices[3] = L("feedbackPing") end
    return choices
end

local function feedbackDescription()
    local text = L("targetFeedbackLimitTip")
    if NS.Core.PingAvailable() then text = text .. "\n\n" .. L("targetFeedbackChatTip") end
    return text
end

function UI.Create(app)
    local frame = CreateFrame("Frame", "QuestTargetsFrame", UIParent, "DefaultPanelFlatTemplate")
    UI.frame = frame
    frame:SetSize(UI.WindowDimension(app.db.menuWidth, 282, 282, 700),
        UI.WindowDimension(app.db.menuHeight, 354, 198, 900))
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame.TitleContainer.TitleText:SetText(L("title"))
    NineSliceUtil.ApplyLayoutByName(frame.NineSlice, "ButtonFrameTemplateNoPortrait")
    frame:SetScale(math.min(1, UIParent:GetHeight() / 410) * app.db.menuScale)
    UI.RestorePosition(app.db)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButtonNoScripts")
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", -6, -1)
    UI.closeButton = close
    close:SetScript("OnClick", function() app:Toggle() end)
    -- A guarded drag region: the panel becomes protected through its secure children.
    local drag = CreateFrame("Frame", nil, frame)
    UI.drag = drag
    drag:SetPoint("TOPLEFT", 8, 0)
    drag:SetPoint("TOPRIGHT", -30, 0)
    drag:SetHeight(23)
    drag:SetFrameLevel(511)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    UI.dragHint = drag:CreateTexture(nil, "BACKGROUND")
    UI.dragHint:SetAllPoints()
    UI.dragHint:SetColorTexture(0.9, 0.75, 0.3, 1)
    UI.dragHint:SetAlpha(0)
    drag:SetScript("OnDragStart", function()
        if not InCombatLockdown() and not app.tutorialQuest then frame:StartMoving(); UI.moving = true end
    end)
    drag:SetScript("OnDragStop", function()
        UI.StopMoving(app.db)
        if app.dirty then app:Schedule() end
    end)
    frame:SetScript("OnUpdate", function(self)
        if not app.db.transparencyMode then return end
        local over = self:IsMouseOver()
        if over == UI.transparencyOver then return end
        UI.transparencyOver = over
        if UI.resizeGrip then UI.resizeGrip:SetAlpha(over and 1 or 0) end
        UI.dragHint:SetAlpha(over and 0.1 or 0)
        if over then
            UI.transparencyTimer = (UI.transparencyTimer or 0) + 1
            UI.transparencyButton:SetAlpha(1)
        else
            scheduleTransparencyIconHide(app)
        end
    end)

    UI.transparencyButton = CreateFrame("Button", nil, frame)
    UI.transparencyButton:SetSize(20, 20)
    UI.transparencyButton:SetPoint("TOPLEFT", 10, -1)
    UI.transparencyButton:SetFrameLevel(512) -- above the title drag region
    UI.transparencyButton:SetNormalTexture("Interface\\AddOns\\QuestTargets\\Textures\\TransparencyEye")
    UI.transparencyButton:SetPushedTexture("Interface\\AddOns\\QuestTargets\\Textures\\TransparencyEye")
    UI.transparencyButton:SetScript("OnClick", function()
        app.db.transparencyMode = not app.db.transparencyMode
        UI.UpdateTransparency(app)
        UI.UpdateSettings(app)
    end)
    UI.transparencyButton:SetScript("OnEnter", function(self)
        UI.transparencyTimer = (UI.transparencyTimer or 0) + 1
        self:SetAlpha(1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L("transparencyMode"))
        GameTooltip:AddLine(L("transparencyIconTip"), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    UI.transparencyButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if not frame:IsMouseOver() then scheduleTransparencyIconHide(app) end
    end)

    UI.filter = button(frame, L("all"), 116, function() app:ToggleFilter() end)
    UI.filter:SetPoint("TOPLEFT", 10, -30)
    UI.database = label(frame, 132, -35, 113)
    local help = button(frame, "?", 24, function() app:Help() end)
    help:SetPoint("TOPRIGHT", -10, -30)
    UI.rows, UI.zoneHeaders = {}, {}
    for index = 1, 20 do
        local row = CreateFrame("Button", "QuestTargetsTarget" .. index, frame, "SecureActionButtonTemplate")
        row:SetPoint("TOPLEFT", 10, -62 - (index - 1) * 39)
        row:SetSize(238, 36)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function(_, delta) UI.ScrollQuests(app, -delta) end)
        row:RegisterForClicks("AnyUp")
        row:SetAttribute("useOnKeyDown", false)
        row:SetAttribute("type1", "macro")
        row:SetScript("PreClick", function(self, mouseButton, down)
            if self.entry and self.entry.tutorial then return end
            if InCombatLockdown() and mouseButton == "LeftButton" and not down then
                NS.Core.PrepareDeadTargetSound(self:GetAttribute("macrotext1"), app.db)
            end
            if mouseButton ~= "LeftButton" or down or InCombatLockdown() then return end
            NS.Core.PrepareQuestRowClick(self, app, "questList")
        end)
        row:SetScript("PostClick", function(self, mouseButton, down)
            if down then return end
            if self.entry and self.entry.tutorial then
                if mouseButton == "LeftButton" then NS.Tutorial.PracticeClicked() end
                return
            end
            if mouseButton == "RightButton" then
                if self.icon:IsMouseOver() then
                    UI.ToggleFocus(app, self.entry)
                else
                    UI.OpenQuest(self.entry)
                end
                return
            end
            if mouseButton and mouseButton ~= "LeftButton" then return end
            if InCombatLockdown() then return end
            NS.Core.RecordClickResult()
            self:SetAttribute("macrotext1", (NS.Core.EntryMacro(self.entry, NS.Core.TargetFeedbackSettings(app.db, "questList"))))
        end)
        -- The button owns the quest atlas in both native button states, so
        -- its pushed state also works for a secure click during combat.
        row:SetNormalAtlas("UI-QuestPoi-QuestNumber-SuperTracked")
        row:SetPushedAtlas("UI-QuestPoi-QuestNumber-SuperTracked")
        row.icon = row:GetNormalTexture()
        row.icon:ClearAllPoints()
        row.icon:SetSize(22, 22)
        row.icon:SetPoint("LEFT", 1, 0)
        row.pushedIcon = row:GetPushedTexture()
        row.pushedIcon:ClearAllPoints()
        row.pushedIcon:SetSize(20, 20)
        row.pushedIcon:SetPoint("LEFT", 2, -1)
        row.number = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.number:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
        row.number:SetText(index)
        row.focusMark = UI.CreateFocusMark(row, row.icon, 28)
        row:SetFontString(row.number)
        row:SetPushedTextOffset(1, -1)
        row:SetHighlightAtlas("UI-QuestPoi-InnerGlow")
        local highlight = row:GetHighlightTexture()
        highlight:ClearAllPoints()
        highlight:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
        highlight:SetSize(28, 28)
        row.nameText = label(row, 29, -1, 205, "GameFontNormal")
        row.nameText:SetHeight(16)
        row.detail = label(row, 29, -19, 205)
        row.detail:SetHeight(13)
        row:SetScript("OnEnter", function(self) UI.Tooltip(self) end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:Hide()
        UI.rows[index] = row

        local header = CreateFrame("Button", nil, frame)
        header:SetPoint("TOPLEFT", 10, -62 - (index - 1) * 39)
        header:SetSize(238, 36)
        header.caption = label(header, 3, -10, 235, "GameFontNormal")
        header:EnableMouseWheel(true)
        header:SetScript("OnMouseWheel", function(_, delta) UI.ScrollQuests(app, -delta) end)
        header:SetScript("OnClick", function(self)
            if InCombatLockdown() or self.zoneKey == nil then return end
            local collapsed = app.db.collapsedQuestZones
            collapsed[self.zoneKey] = not collapsed[self.zoneKey] or nil
            UI.Render(app)
        end)
        header:Hide()
        UI.zoneHeaders[index] = header
    end
    UI.empty = label(frame, 14, -112, 234, "GameFontHighlight")
    UI.empty:SetJustifyH("CENTER")
    UI.empty:SetHeight(100)
    UI.scrollbar = CreateFrame("Slider", "QuestTargetsQuestScrollBar", frame, "UIPanelScrollBarTemplate")
    -- The template's inherited handler expects a ScrollFrame parent.
    -- Replace it before SetValue can invoke that handler on our panel.
    UI.scrollbar:SetScript("OnValueChanged", function(_, value)
        if InCombatLockdown() then return end
        local offset = math.floor(value + 0.5)
        if offset ~= (app.scrollOffset or 0) then
            app.scrollOffset = offset
            UI.RenderRows(app)
        end
    end)
    UI.scrollbar:SetPoint("TOPRIGHT", -10, -82)
    UI.scrollbar:SetHeight(UI.PAGE_SIZE * 39 - 28)
    UI.scrollbar:SetMinMaxValues(0, 0)
    UI.scrollbar:SetValueStep(1)
    UI.scrollbar:SetValue(0)
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(_, delta) UI.ScrollQuests(app, -delta) end)
    UI.settingsButton = button(frame, L("settings"), 126, function() UI.Settings(app) end)
    UI.settingsButton:SetPoint("BOTTOMLEFT", 10, 8)
    UI.feedbackButton = button(frame, L("feedback"), 126, function() UI.FeedbackLink() end)
    UI.feedbackButton:SetPoint("BOTTOMRIGHT", -28, 8)
    UI.CreateResizeGrip(app)
    UI.chrome = {}
    for _, region in ipairs({frame:GetRegions()}) do UI.chrome[#UI.chrome + 1] = region end
    local function addChrome(region)
        if region then UI.chrome[#UI.chrome + 1] = region end
    end
    addChrome(frame.Bg)
    addChrome(frame.NineSlice)
    addChrome(frame.TitleContainer)
    addChrome(frame.FrameGlow)
    addChrome(frame.FocusJumpHint)
    addChrome(frame.LeftJumpHint)
    addChrome(frame.RightJumpHint)
    addChrome(close)
    addChrome(UI.filter)
    addChrome(UI.database)
    addChrome(help)
    addChrome(UI.scrollbar)
    addChrome(UI.settingsButton)
    addChrome(UI.feedbackButton)
    addChrome(UI.resizeGrip)
    UI.chromeAlpha = 1
    UI.UpdateTransparency(app)
    frame:SetShown(not app.db.hidden)
end

function UI.FeedbackLink()
    if not StaticPopupDialogs or not StaticPopup_Show then return end
    if not UI.feedbackQR then
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetSize(280, 328)
        frame.code = frame:CreateTexture(nil, "ARTWORK")
        frame.code:SetTexture("Interface\\AddOns\\QuestTargets\\Textures\\FeedbackQR")
        frame.code:SetSize(256, 256)
        frame.code:SetPoint("TOP", frame, "TOP", 0, -4)
        frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.hint:SetPoint("TOP", frame.code, "BOTTOM", 0, -8)
        frame.hint:SetSize(280, 56)
        frame.hint:SetJustifyH("CENTER")
        frame:Hide()
        UI.feedbackQR = frame
    end
    UI.feedbackQR.hint:SetText(L("feedbackLink"))
    local key = "QUESTTARGETS_FEEDBACK_LINK"
    local function selectLink(self)
        local box = self.GetEditBox and self:GetEditBox() or self.editBox or self.EditBox
        if box then box:SetText(FEEDBACK_URL); box:HighlightText(); box:SetFocus() end
        return true
    end
    StaticPopupDialogs[key] = {
        text = L("feedbackQRHint"),
        button1 = L("selectLink"),
        button2 = OKAY or "OK",
        hasEditBox = true,
        editBoxWidth = 320,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = selectLink,
        OnAccept = selectLink,
    }
    -- The native popup lays out the edit box and inserted frame together on
    -- all supported clients, and releases/hides the inserted frame on close.
    StaticPopup_Show(key, nil, nil, nil, UI.feedbackQR)
end

-- Settings controls use ordinary frames; protected targeting stays in Master.lua.
local function settingsSlider(parent, name, key, minimum, maximum, step, app)
    local control = CreateFrame("Frame", nil, parent)
    control:SetSize(330, 82)
    control.caption = label(control, 0, 0, 330, "GameFontNormal")
    control.caption:ClearAllPoints()
    control.caption:SetPoint("BOTTOMLEFT", control, "TOPLEFT", 0, -18)
    control.caption:SetPoint("BOTTOMRIGHT", control, "TOPRIGHT", 0, -18)
    control.caption:SetJustifyH("CENTER")
    local slider = CreateFrame("Slider", name, control, "OptionsSliderTemplate")
    control.slider = slider
    slider:SetPoint("TOPLEFT", 4, -26)
    slider:SetPoint("TOPRIGHT", -4, -26)
    slider:SetHeight(18)
    slider:SetMinMaxValues(minimum, maximum)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    local low, high, title = slider.Low or _G[name .. "Low"], slider.High or _G[name .. "High"], slider.Text or _G[name .. "Text"]
    if low then low:SetText(tostring(minimum)) end
    if high then high:SetText(tostring(maximum)) end
    if title then title:Hide() end
    local edit = CreateFrame("EditBox", nil, control, "InputBoxTemplate")
    control.edit = edit
    edit:SetSize(76, 22)
    edit:SetPoint("TOP", 0, -53)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(8)
    edit:SetJustifyH("CENTER")
    local function display(value)
        if not edit:HasFocus() then edit:SetText(string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")) end
    end
    slider:SetScript("OnValueChanged", function(_, value)
        local rounded = math.max(minimum, math.min(maximum, math.floor(value / step + 0.5) * step))
        display(rounded)
        if control.updating or math.abs(rounded - app.db[key]) < 0.0001 then return end
        app.db[key] = rounded
        app:Schedule()
    end)
    function control:Refresh()
        self.updating = true
        self.slider:SetValue(app.db[key])
        display(app.db[key])
        self.updating = false
    end
    local function save(self)
        if control.saving then return end
        control.saving = true
        local value = tonumber(((self:GetText() or ""):gsub(",", ".")))
        self:ClearFocus()
        if value and value == value and value ~= math.huge and value ~= -math.huge then
            slider:SetValue(math.max(minimum, math.min(maximum, value)))
        end
        control:Refresh()
        control.saving = false
    end
    edit:SetScript("OnEnterPressed", save)
    edit:SetScript("OnEditFocusLost", save)
    edit:SetScript("OnEscapePressed", function(self)
        self:SetText(tostring(app.db[key]))
        self:ClearFocus()
        control:Refresh()
    end)
    return control
end

local function settingsBox(parent, key, y, height)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetPoint("TOPLEFT", 8, y)
    box:SetPoint("TOPRIGHT", -8, y)
    box:SetHeight(height)
    box:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16,
        insets={left=4, right=4, top=4, bottom=4}})
    box:SetBackdropColor(0.08, 0.08, 0.08, 0.65)
    box.heading = label(box, 16, -12, 400, "GameFontNormal")
    box.heading:ClearAllPoints()
    box.heading:SetPoint("BOTTOMLEFT", box, "TOPLEFT", 12, 6)
    box.heading:SetText(L(key))
    box.localeKey = key
    return box
end

local function place(control, parent, x, y)
    control:SetParent(parent)
    control:ClearAllPoints()
    control:SetPoint("TOPLEFT", x, y)
end

local function openIntroFromSettings(app)
    if InCombatLockdown() then return end
    UI.CloseSettings()
    NS.Tutorial.Open(app)
end

function UI.SelectSettingsTab(index)
    local panel = UI.settings
    if not panel or not panel.pages[index] then return end
    stopBindingCapture()
    UI.UpdateSettings(NS.app)
    panel.selectedTab = index
    for i, page in ipairs(panel.pages) do
        page.scroll:SetShown(i == index)
        panel.tabs[i]:SetEnabled(i ~= index)
        panel.tabs[i]:SetBackdropColor(i == index and 0.2 or 0.06, 0.06, 0.02, 0.9)
    end
end

function UI.LayoutSettings(app)
    local panel, master = UI.settings, UI.masterSettings
    panel.pages, panel.tabs, panel.groups = {}, {}, {}
    local keys = {"general", "targetMarkers", "buttons", "hotkeys"}
    local feedbackSpace = #feedbackButtons * 32
    local heights = {530, 308 + feedbackSpace, 1130, 310}
    panel.body = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    panel.body:SetPoint("TOPLEFT", 8, -78)
    panel.body:SetPoint("BOTTOMRIGHT", -8, 8)
    panel.body:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16,
        insets={left=4, right=4, top=4, bottom=4}})
    panel.body:SetBackdropColor(0.06, 0.06, 0.06, 0.75)
    for index, key in ipairs(keys) do
        local tabIndex = index
        local tab = CreateFrame("Button", nil, panel, "BackdropTemplate")
        panel.tabs[index] = tab
        tab.localeKey = key
        tab:SetHeight(24)
        tab:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=12,
            insets={left=3, right=3, top=3, bottom=3}})
        tab:SetNormalFontObject("GameFontNormalSmall")
        tab:SetDisabledFontObject("GameFontHighlightSmall")
        tab:SetScript("OnEnter", function(self)
            if panel.selectedTab ~= tabIndex then self:SetBackdropColor(0.04, 0.22, 0.48, 0.95) end
        end)
        tab:SetScript("OnLeave", function(self)
            self:SetBackdropColor(panel.selectedTab == tabIndex and 0.2 or 0.06, 0.06, 0.02, 0.9)
        end)
        tab:SetText(L(key))
        tab:SetScript("OnClick", function() UI.SelectSettingsTab(tabIndex) end)
        local scroll = CreateFrame("ScrollFrame", "QuestTargetsSettingsScroll" .. index, panel, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", panel.body, "TOPLEFT", 8, -14)
        scroll:SetPoint("BOTTOMRIGHT", panel.body, "BOTTOMRIGHT", -28, 8)
        local content = index == 3 and master or CreateFrame("Frame", nil, scroll)
        content:SetParent(scroll)
        content:SetSize(540, heights[index])
        scroll:SetScrollChild(content)
        scroll:SetScript("OnSizeChanged", function(self, width)
            content:SetWidth(math.max(1, width))
        end)
        content:SetWidth(math.max(1, scroll:GetWidth()))
        panel.pages[index] = {scroll=scroll, content=content}
    end
    local general, markers, hotkeys = panel.pages[1].content, panel.pages[2].content, panel.pages[4].content
    place(panel.patchNotesButton, general, 20, -460)
    place(panel.introButton, general, 20, -489)
    local display = settingsBox(general, "display", -32, 125)
    local window = settingsBox(general, "window", -191, 125)
    local language = settingsBox(general, "language", -350, 102)
    local marking = settingsBox(markers, "targetMarkers", -32, 260 + feedbackSpace)
    local toggles = settingsBox(master, "buttons", -32, 334)
    local bar = settingsBox(master, "targetBar", -390, 715)
    local bindings = settingsBox(hotkeys, "hotkeys", -32, 271)
    panel.groups = {display, window, language, marking, toggles, bar, bindings}
    panel.displayText:Hide()
    panel.languageText:Hide()
    panel.hotkeysText:Hide()
    for i, control in ipairs({panel.menuToggle, panel.transparencyToggle}) do
        place(control, display, 18, -32 - (i-1)*30)
    end
    for i, control in ipairs({panel.tooltipToggle, panel.minimapToggle, panel.questieTrackerToggle}) do
        place(control, toggles, 18, -32 - (i-1)*30)
    end
    place(panel.questieOffsetControl, toggles, 22, -122)
    place(panel.ellesmereToggle, toggles, 18, -210)
    place(panel.ellesmereOffsetControl, toggles, 22, -240)
    place(panel.flareUIToggle, toggles, 18, -298)
    for i, control in ipairs({panel.masterToggle, panel.masterModulesToggle, panel.polestarToggle,
        panel.followTheArrowToggle, panel.restedXPToggle, panel.itemTreeToggle, panel.rareScannerToggle,
        panel.rareScannerZoneToggle}) do
        place(control, bar, i >= 2 and i <= 4 and 38 or 18, -32 - (i-1)*30)
    end
    place(master.orientationLabel, bar, 22, -277)
    place(master.orientationDropdown, bar, 176, -269)
    place(master.spacingControl, bar, 22, -310)
    master.spacingControl:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -22, -310)
    place(master.backgroundToggle, bar, 18, -479)
    place(master.borderToggle, bar, 18, -509)
    place(master.dividersToggle, bar, 18, -539)
    place(master.lockToggle, bar, 18, -569)
    place(panel.scaleControl, window, 22, -31)
    panel.scaleControl:SetPoint("TOPRIGHT", window, "TOPRIGHT", -22, -31)
    place(panel.languageDropdown, language, 2, -42)
    for index, control in ipairs(panel.feedbackControls) do
        place(control, marking, 18, -35 - (index - 1) * 32)
    end
    place(panel.soundToggle, marking, 18, -213 - feedbackSpace)
    place(panel.selection, marking, 18, -40 - feedbackSpace)
    for index, choice in ipairs(panel.icons) do
        place(choice, marking, 20 + ((index - 1) % 4)*85, -71 - feedbackSpace - math.floor((index-1)/4)* 60)
    end
    place(master.modernScaleControl, bar, 22, -395)
    master.modernScaleControl:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -22, -395)
    place(master.moveButton, bar, 18, -614)
    place(master.moveHelp, bar, 18, -650)
    master.moveHelp:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -18, -650)
    panel.bindingHeaders = {}
    for slot = 1, 2 do
        local header = label(bindings, 0, 0, 160, "GameFontNormalSmall")
        header:ClearAllPoints()
        panel.bindingHeaders[slot] = header
    end
    for index, row in ipairs({
        {panel.hotkey, panel.hotkey2}, {panel.focusHotkey, panel.focusHotkey2},
        {panel.itemTreeHotkey, panel.itemTreeHotkey2}, {panel.rareScannerHotkey, panel.rareScannerHotkey2},
    }) do
        local y = -58 - (index - 1) * 38
        for _, control in ipairs(row) do
            control:SetParent(bindings)
            control:ClearAllPoints()
            control:SetWidth(160)
        end
        row[2]:SetPoint("TOPRIGHT", bindings, "TOPRIGHT", -18, y)
        row[1]:SetPoint("TOPRIGHT", row[2], "TOPLEFT", 0, 0)
    end
    for slot, header in ipairs(panel.bindingHeaders) do
        header:SetPoint("BOTTOMLEFT", slot == 1 and panel.hotkey or panel.hotkey2, "TOPLEFT", 4, 5)
        header:SetText(L(slot == 1 and "bindingKey1" or "bindingKey2"))
    end
    panel.hotkeyAction = label(bindings, 18, -63, 210, "GameFontHighlight")
    panel.hotkeyAction:SetText(L("masterDefault"))
    panel.hotkeyAction:SetPoint("TOPRIGHT", panel.hotkey, "TOPLEFT", -12, -5)
    panel.focusHotkeyAction = label(bindings, 18, -101, 210, "GameFontHighlight")
    panel.focusHotkeyAction:SetText(L("focusHotkey"))
    panel.focusHotkeyAction:SetPoint("TOPRIGHT", panel.focusHotkey, "TOPLEFT", -12, -5)
    panel.itemTreeHotkeyAction = label(bindings, 18, -139, 210, "GameFontHighlight")
    panel.itemTreeHotkeyAction:SetText(L("itemTreeBinding"))
    panel.itemTreeHotkeyAction:SetPoint("TOPRIGHT", panel.itemTreeHotkey, "TOPLEFT", -12, -5)
    panel.rareScannerHotkeyAction = label(bindings, 18, -177, 210, "GameFontHighlight")
    panel.rareScannerHotkeyAction:SetText(L("rareScannerBinding"))
    panel.rareScannerHotkeyAction:SetPoint("TOPRIGHT", panel.rareScannerHotkey, "TOPLEFT", -12, -5)
    place(panel.hotkeyNote, bindings, 18, -214)
    panel.hotkeyNote:SetWidth(450)
    panel.hotkeyNote:SetPoint("TOPRIGHT", bindings, "TOPRIGHT", -18, -214)
    panel.pages[4].scroll:SetScript("OnHide", function()
        stopBindingCapture()
        UI.UpdateSettings(app)
    end)
    local function resize(self)
        local maximum = math.max(40, (self:GetWidth() - 48) / 4)
        local x = 10
        for _, tab in ipairs(self.tabs) do
            local text = tab.GetFontString and tab:GetFontString()
            local width = math.min(maximum, math.max(72, text and text:GetStringWidth() + 28 or 112))
            tab:ClearAllPoints()
            tab:SetPoint("BOTTOMLEFT", self.body, "TOPLEFT", x, -3)
            tab:SetWidth(width)
            x = x + width + 4
        end
    end
    panel.ResizeTabs = resize
    panel:SetScript("OnSizeChanged", resize)
    resize(panel)
    UI.UpdateMasterSettings(app)
    UI.SelectSettingsTab(1)
end

QuestTargetsBindingSettingMixin = {}

function QuestTargetsBindingSettingMixin:OnLoad()
    SettingsListElementMixin.OnLoad(self)
    self.Buttons = {}
    for slot = 1, 2 do
        local index = slot
        local control = CreateFrame("Button", nil, self, "UIMenuButtonStretchTemplate")
        control:SetSize(160, 22)
        control:SetNormalFontObject("GameFontHighlightSmall")
        control:SetDisabledFontObject("GameFontDisableSmall")
        control:SetScript("OnClick", function(button)
            if self.data then self.data.callback(button, index) end
        end)
        control:HookScript("OnEnter", function(button)
            if self.data and self.data.tooltip then
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.data.name)
                GameTooltip:AddLine(self.data.tooltip, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        control:HookScript("OnLeave", function() GameTooltip:Hide() end)
        self.Buttons[slot] = control
    end
    self.Buttons[2]:SetPoint("RIGHT", self, "RIGHT", -12, 0)
    self.Buttons[1]:SetPoint("RIGHT", self.Buttons[2], "LEFT", 0, 0)
end

function QuestTargetsBindingSettingMixin:RefreshBindings()
    if not self.data then return end
    self.Text:SetText(self.data.name)
    local enabled = not self.data.isEnabled or self.data.isEnabled()
    local gray = enabled and 1 or 0.5
    self.Text:SetTextColor(gray, gray, gray)
    for slot, control in ipairs(self.Buttons) do
        control:SetEnabled(enabled)
        if not control.listening then control:SetText(self.data.text(slot)) end
    end
end

function QuestTargetsBindingSettingMixin:Init(initializer)
    SettingsListElementMixin.Init(self, initializer)
    self.Text:ClearAllPoints()
    self.Text:SetPoint("LEFT", self, "LEFT", 37, 0)
    self.Text:SetPoint("RIGHT", self.Buttons[1], "LEFT", -8, 0)
    self.initializer = initializer
    initializer.row = self
    self:RefreshBindings()
end

function QuestTargetsBindingSettingMixin:Release()
    local pending = UI.bindingConfirmation
    if pending and (pending.button == self.Buttons[1] or pending.button == self.Buttons[2]) then
        cancelBindingConfirmation()
    end
    local capture = UI.bindingCapture
    if capture and (capture.button == self.Buttons[1] or capture.button == self.Buttons[2]) then
        stopBindingCapture()
    end
    if self.initializer then self.initializer.row = nil end
    self.initializer = nil
    SettingsListElementMixin.Release(self)
end

local function nativeSettings(app)
    local interface = GetBuildInfo and select(4, GetBuildInfo())
    local forever = type(interface) == "number" and interface >= 16000 and interface < 17000
    local privateList = forever and SettingsListMixin and CreateVerticalLayout
        and Settings.RegisterCanvasLayoutCategory and Settings.RegisterCanvasLayoutSubcategory
        and Settings.CreateCheckboxInitializer and Settings.CreateSliderInitializer and Settings.CreateDropdownInitializer
    if not forever and SettingsPanel and SettingsPanel.DisplayCategory and UI.versionHeaderPanel ~= SettingsPanel then
        UI.versionHeaderPanel = SettingsPanel
        hooksecurefunc(SettingsPanel, "DisplayCategory", function(panel, selected)
            if not UI.nativeCategory or selected ~= UI.nativeCategory then return end
            local list = panel:GetSettingsList()
            if list and list.Header and list.Header.Title then
                list.Header.Title:SetText(UI.OptionsTitle())
            end
        end)
    end
    if UI.nativeCategory then return end

    local resetSettings
    local function privatePage(parent, key)
        -- Use the same template as SettingsPanel. A registered canvas keeps
        -- this private list's initializers out of the shared results layout.
        local page = CreateFrame("Frame", nil, nil, "SettingsListTemplate")
        page:Hide()
        local name = L(key)
        local category
        if parent then category = Settings.RegisterCanvasLayoutSubcategory(parent, page, name)
        else category = Settings.RegisterCanvasLayoutCategory(page, name) end
        local layout = CreateVerticalLayout()
        local function updateTitle()
            page.Header.Title:SetText(parent and L(key) or UI.OptionsTitle())
        end
        page.Header.DefaultsButton.Text:SetText(SETTINGS_DEFAULTS)
        page.Header.DefaultsButton:SetScript("OnClick", function()
            if InCombatLockdown() or not StaticPopupDialogs or not StaticPopup_Show then return end
            local dialog = "NEXT_RESTORE_DEFAULTS"
            StaticPopupDialogs[dialog] = {
                text=L("restoreNextDefaults"), button1=SETTINGS_DEFAULTS, button2=CANCEL,
                timeout=0, whileDead=true, hideOnEscape=true,
                OnAccept=resetSettings,
            }
            StaticPopup_Show(dialog)
        end)
        page:SetScript("OnShow", function()
            updateTitle()
            page:Display(layout:GetInitializers())
        end)
        page:SetScript("OnHide", stopBindingCapture)
        return category, layout, page, updateTitle
    end

    local category, layout, page, updateTitle
    if privateList then category, layout, page, updateTitle = privatePage(nil, "title")
    else category, layout = Settings.RegisterVerticalLayoutCategory(L("title")) end
    local activeCategory, activeLayout = category, layout
    local buttonsPage, buttonsLayout, updateButtonsTitle
    local descriptions, actions, registered = {}, {}, {}
    local automaticOptions = {
        polestarIntegration = "polestarIntegration",
        followTheArrowIntegration = "followTheArrowIntegration",
        restedXPIntegration = "restedXPIntegration",
        showItemTreeButton = "itemTreeButton",
        questieTrackerButtons = "questieTrackerButtons",
        ellesmereTrackerButtons = "ellesmereTrackerButtons",
        flareUITrackerButtons = "flareUITrackerButtons",
        showRareScannerButton = "rareScannerButton",
    }
    UI.nativeHeaders = {}
    UI.nativeButtons = {}
    local function section(key)
        local initializer = CreateSettingsListSectionHeaderInitializer(L(key))
        activeLayout:AddInitializer(initializer)
        UI.nativeHeaders[#UI.nativeHeaders + 1] = {initializer=initializer, key=key}
    end
    local function setting(key, kind, default, get, set)
        -- Forever validates name callbacks outside securecallfunction before
        -- inserting the setting into the registry also read by ActionBar clicks.
        -- Keep registration data plain; localize only our displayed row below.
        local value = Settings.RegisterProxySetting(activeCategory, "QUESTTARGETS_" .. key,
            Settings.VarType[kind], L(key), default, get, set)
        if not automaticOptions[key] then
            registered[#registered + 1] = {get=get, set=set, default=default}
        end
        return value
    end
    local function describe(description)
        if not description then return end
        if type(description) == "function" then return description() end
        return L(description)
    end
    local function child(initializer, parent, predicate)
        initializer:SetParentInitializer(parent)
        -- The private Forever list owns both rows, but Blizzard's shared layout lookup cannot see them.
        if privateList then initializer.IsParentInitializerInLayout = function() return true end end
        initializer:AddModifyPredicate(predicate)
    end
    local function actionRow(key, buttonKey, callback, tipKey)
        local initializer = CreateSettingsButtonInitializer(L(key), L(buttonKey), callback, L(tipKey), false)
        activeLayout:AddInitializer(initializer)
        actions[#actions + 1] = {initializer=initializer, key=key, buttonKey=buttonKey}
        descriptions[initializer] = tipKey
        return initializer
    end
    local function localizedRow(initializer, key, description)
        initializer.GetName = function() return L(key) end
        descriptions[initializer] = description
        return initializer
    end
    local function checkboxSetting(key, default, get, set, descriptionKey)
        local value = setting(key, "Boolean", default, get, set)
        local description = describe(descriptionKey)
        local initializer
        if privateList then
            initializer = Settings.CreateCheckboxInitializer(value, nil, description)
            activeLayout:AddInitializer(initializer)
        else
            initializer = Settings.CreateCheckbox(activeCategory, value, description)
        end
        return localizedRow(initializer, key, descriptionKey)
    end
    local function sliderSetting(key, savedKey, minimum, maximum, step, pixels, defaultValue, descriptionKey)
        local value = setting(key, "Number", defaultValue or (pixels and 35 or 1),
            function() return app.db[savedKey] end,
            function(nextValue)
                app.db[savedKey] = nextValue
                app:Schedule()
            end)
        local options = Settings.CreateSliderOptions(minimum, maximum, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(number) return pixels and string.format("%d px", number)
                or string.format("%d%%", math.floor(number * 100 + 0.5)) end)
        local initializer
        if privateList then
            initializer = Settings.CreateSliderInitializer(value, options, describe(descriptionKey))
            activeLayout:AddInitializer(initializer)
        else
            initializer = Settings.CreateSlider(activeCategory, value, options, describe(descriptionKey))
        end
        return localizedRow(initializer, key, descriptionKey)
    end
    local function dropdownSetting(key, default, get, set, choices, description)
        local value = setting(key, "Number", default, get, set)
        local function menuOptions()
            local options = Settings.CreateControlTextContainer()
            for index, text in ipairs(choices()) do options:Add(index, text) end
            return options:GetData()
        end
        local initializer
        if privateList then
            initializer = Settings.CreateDropdownInitializer(value, menuOptions, describe(description))
            activeLayout:AddInitializer(initializer)
        else
            initializer = Settings.CreateDropdown(activeCategory, value, menuOptions, describe(description))
        end
        localizedRow(initializer, key, description)
        return value, initializer
    end
    local function refresh()
        for _, entry in ipairs(UI.nativeButtons) do
            local row = entry.initializer.row
            if row then row:RefreshBindings() end
        end
        if privateList then
            updateTitle()
            updateButtonsTitle()
            if page:IsVisible() then page:RepairDisplay(layout) end
            if buttonsPage:IsVisible() then buttonsPage:RepairDisplay(buttonsLayout) end
        elseif SettingsInbound and SettingsInbound.RepairDisplay then
            SettingsInbound.RepairDisplay()
        end
    end

    resetSettings = function()
        if InCombatLockdown() then return end
        for _, option in ipairs(registered) do
            if option.get() ~= option.default then
                option.set(option.default, true)
            end
        end
        for _, field in pairs(automaticOptions) do app.db[field] = nil end
        app:Refresh()
        refresh()
    end

    section("general")
    dropdownSetting("language", 1, NS.Language, function(value)
        if InCombatLockdown() or value == NS.Language() then return end
        app.db.language = NS.LANGUAGES[value]
        UI.ApplyLanguage(app)
        category:SetName(L("title"))
        for initializer, description in pairs(descriptions) do
            initializer.data.tooltip = describe(description)
        end
        for _, action in ipairs(actions) do
            action.initializer.data.name = L(action.key)
            action.initializer.data.buttonText = L(action.buttonKey)
        end
        for _, header in ipairs(UI.nativeHeaders) do header.initializer.data.name = L(header.key) end
        for _, button in ipairs(UI.nativeButtons) do
            button.initializer.data.name = L(button.key)
            if button.descriptionKey then
                button.initializer.data.tooltip = L(button.descriptionKey)
            end
        end
        refresh()
    end, function() return NS.LANGUAGE_NAMES end, "languageNote")

    checkboxSetting("showMinimap", true, function() return not app.db.minimapHidden end,
        function(value)
            app.db.minimapHidden = not value
            UI.SetMinimapShown(app, value)
        end, "minimapTip")
    UI.nativePatchNotes = actionRow("patchNotes", "patchNotesOpen", NS.PatchNotes.Open, "patchNotesHelp")
    UI.nativeIntro = actionRow("introSettings", "introStart", function() openIntroFromSettings(app) end, "introHelp")
    UI.nativeFeedback = actionRow("feedback", "feedbackOpen", UI.FeedbackLink, "feedbackTip")

    section("questWindowSection")
    checkboxSetting("showMenu", false, function()
        if app.pendingVisibility ~= nil then return app.pendingVisibility end
        return not app.db.hidden
    end, function(value)
        local current = app.pendingVisibility
        if current == nil then current = not app.db.hidden end
        if current ~= value then app:Toggle() end
    end, "showMenuTip")
    checkboxSetting("transparencyMode", false,
        function() return app.db.transparencyMode end,
        function(value)
            app.db.transparencyMode = value
            UI.UpdateTransparency(app)
        end, "transparentBackgroundTip")
    sliderSetting("windowSize", "menuScale", 0.5, 1.5, 0.05, false, 1, "windowSizeTip")

    section("targetMarkers")
    for _, info in ipairs(feedbackButtons) do
        local key, labelKey = info[1], info[2]
        dropdownSetting(labelKey, key == "rare" and NS.Core.TargetFeedbackMode({}, key) or 2,
            function() return NS.Core.TargetFeedbackMode(app.db, key) end,
            function(value)
                app.db.targetFeedback[key] = value
                app:Schedule()
            end, feedbackChoices, feedbackDescription)
    end
    dropdownSetting("preferredRaidIcon", 8, function() return app.db.markerIcon end,
        function(value) app.db.markerIcon = value; app:Schedule() end,
        function() return {strsplit(",", L("markers"))} end, "preferredRaidIconTip")

    checkboxSetting("muteDeadTargetSound", true, function() return app.db.muteDeadTargetSound end,
        function(value) app.db.muteDeadTargetSound = value end, "muteDeadTargetSoundTip")

    section("hotkeys")
    local function bindingRow(key, focused, descriptionKey)
        local command = bindingAction(focused)
        local initializer
        local function isEnabled()
            return bindingAvailable(focused)
        end
        local function text(slot)
            local first, second = GetBindingKey(command)
            if slot == 2 then return bindingText(second) end
            return bindingText(first)
        end
        initializer = Settings.CreateElementInitializer("QuestTargetsBindingSettingTemplate", {
            name=L(key), text=text, isEnabled=isEnabled,
            tooltip=descriptionKey and L(descriptionKey) or nil,
            callback=function(control, slot)
                if not isEnabled() then return end
                beginBindingCapture(control, app, focused, slot or 1, function()
                    control:SetText(text(slot))
                    refresh()
                end)
            end,
        })
        layout:AddInitializer(initializer)
        UI.nativeButtons[#UI.nativeButtons + 1] = {
            initializer=initializer, key=key, descriptionKey=descriptionKey}
    end
    bindingRow("masterDefault", false, "masterTip3")
    bindingRow("focusHotkey", true, "focusHotkeyTip")
    bindingRow("itemTreeBinding", "itemTree", "itemTreeBindingTip")
    bindingRow("rareScannerBinding", "rareScanner", "rareScannerBindingTip")

    if privateList then
        activeCategory, activeLayout, buttonsPage, updateButtonsTitle = privatePage(category, "buttonsBar")
        buttonsLayout = activeLayout
        UI.nativeButtonsCategory = activeCategory
    elseif Settings.RegisterVerticalLayoutSubcategory then
        activeCategory, activeLayout = Settings.RegisterVerticalLayoutSubcategory(category, L("buttonsBar"))
        UI.nativeButtonsCategory = activeCategory
    end
    section("barModulesSection")
    local masterToggle = checkboxSetting("showMaster", true, function() return not app.db.masterHidden end,
        function(value)
            if value then app.db.hotkeysOnly = nil end
            app.db.masterHidden = not value
            app:Schedule()
        end, "masterMoveTip")
    local masterModulesToggle = checkboxSetting("masterAllModules", true,
        function() return app.db.masterAllModules ~= false end,
        function(value) app.db.masterAllModules = value; app:Schedule() end, "masterAllModulesTip")
    child(masterModulesToggle, masterToggle, function() return not app.db.masterHidden end)
    local polestarToggle = checkboxSetting("polestarIntegration", not not addonLoaded("Polestar"),
        function() return not not addonLoaded("Polestar") and app.db.polestarIntegration ~= false end,
        function(value)
            if InCombatLockdown() or not addonLoaded("Polestar") then return end
            app.db.polestarIntegration = value
            NS.RestedXP.Sync(app)
            UI.UpdateStatus(app)
        end, "polestarIntegrationTip")
    child(polestarToggle, masterToggle, function()
        return not app.db.masterHidden and addonLoaded("Polestar")
    end)

    local followTheArrowToggle = checkboxSetting("followTheArrowIntegration", not not NS.RestedXP.FollowTheArrowAvailable(),
        function() return not not NS.RestedXP.FollowTheArrowAvailable() and app.db.followTheArrowIntegration ~= false end,
        function(value)
            if InCombatLockdown() or not NS.RestedXP.FollowTheArrowAvailable() then return end
            app.db.followTheArrowIntegration = value
            NS.RestedXP.Sync(app)
            UI.UpdateStatus(app)
        end, "followTheArrowIntegrationTip")
    child(followTheArrowToggle, masterToggle, function()
        return not app.db.masterHidden and NS.RestedXP.FollowTheArrowAvailable()
    end)

    local restedXPToggle = checkboxSetting("restedXPIntegration", not not addonLoaded("RXPGuides"),
        function() return not not addonLoaded("RXPGuides") and app.db.restedXPIntegration ~= false end,
        function(value)
            if InCombatLockdown() or not addonLoaded("RXPGuides") then return end
            app.db.restedXPIntegration = value
            NS.RestedXP.Sync(app)
        end, "restedXPIntegrationTip")
    restedXPToggle:AddModifyPredicate(function() return addonLoaded("RXPGuides") end)

    local itemTreeToggle = checkboxSetting("showItemTreeButton", not not addonLoaded("ItemTree"),
        function() return not not addonLoaded("ItemTree") and app.db.itemTreeButton ~= false end,
        function(value)
            if InCombatLockdown() or not addonLoaded("ItemTree") then return end
            app.db.itemTreeButton = value
            NS.ItemTree.Sync(app)
        end, "itemTreeIntegrationTip")
    itemTreeToggle:AddModifyPredicate(function() return addonLoaded("ItemTree") end)
    local rareScannerToggle = checkboxSetting("showRareScannerButton", NS.RareScanner.MarkingAvailable(),
        function() return NS.RareScanner.ButtonEnabled(app) end,
        function(value)
            if InCombatLockdown() or not NS.RareScanner.MarkingAvailable() then return end
            app.db.rareScannerButton = value
            NS.RareScanner.SyncMark(app)
        end, "rareScannerButtonTip")
    rareScannerToggle:AddModifyPredicate(NS.RareScanner.MarkingAvailable)
    local rareScannerZoneToggle = checkboxSetting("rareScannerZone", true,
        function() return app.db.rareScannerZone == true end,
        function(value, restoring)
            if InCombatLockdown() or (not restoring and not NS.RareScanner.ZoneAvailable()) then return end
            app.db.rareScannerZone = value
            NS.RareScanner.SyncMark(app)
        end, "rareScannerZoneTip")
    child(rareScannerZoneToggle, rareScannerToggle, function()
        return NS.RareScanner.ButtonEnabled(app) and NS.RareScanner.ZoneAvailable()
    end)

    section("barAppearanceSection")
    dropdownSetting("masterOrientation", 1,
        function() return app.db.masterOrientation == "vertical" and 2 or 1 end,
        function(value)
            app.db.masterOrientation = value == 2 and "vertical" or "horizontal"
            app:Schedule()
        end,
        function() return {L("masterHorizontal"), L("masterVertical")} end, "masterOrientationTip")
    sliderSetting("buttonSize", "masterModernScale", 0.3, 2, 0.01, false, 1, "buttonSizeTip")
    sliderSetting("masterSpacing", "masterSpacing", 0, 32, 1, true, 0, "masterSpacingTip")
    checkboxSetting("masterBackground", false, function() return app.db.masterBackground end,
        function(value) app.db.masterBackground = value; app:Schedule() end, "masterBackgroundTip")
    checkboxSetting("masterBorder", false, function() return app.db.masterBorder end,
        function(value) app.db.masterBorder = value; app:Schedule() end, "masterBorderTip")
    checkboxSetting("masterDividers", true, function() return app.db.masterDividers end,
        function(value) app.db.masterDividers = value; app:Schedule() end, "masterDividersTip")
    checkboxSetting("masterLocked", false, function() return app.db.masterLocked end,
        function(value) UI.SetTargetBarLocked(app, value) end, "masterLockTip")

    UI.nativeMove = actionRow("masterMove", "masterMoveStart", function()
        UI.BeginMasterMove(app)
    end, "masterMoveHelp")

    section("integrationSection")
    checkboxSetting("showTooltips", true, function() return app.db.showTooltips end,
        function(value) app.db.showTooltips = value end, "showTooltipsTip")
    local questieToggle = checkboxSetting("questieTrackerButtons", not not addonLoaded("Questie"),
        function() return not not addonLoaded("Questie") and app.db.questieTrackerButtons ~= false end,
        function(value)
            if InCombatLockdown() or not addonLoaded("Questie") then return end
            app.db.questieTrackerButtons = value
            NS.QuestieTracker.Sync(app)
        end, "questieTrackerTip")
    questieToggle:AddModifyPredicate(function() return addonLoaded("Questie") end)
    local questieOffset = sliderSetting("questieTrackerOffset", "questieTrackerOffset", -240, 240, 1, true, 35, "trackerSpacingTip")
    child(questieOffset, questieToggle, function()
        return addonLoaded("Questie") and app.db.questieTrackerButtons ~= false
    end)

    local ellesmereToggle = checkboxSetting("ellesmereTrackerButtons", not not NS.EllesmereTracker.Available(),
        function() return not not NS.EllesmereTracker.Available() and app.db.ellesmereTrackerButtons ~= false end,
        function(value)
            if InCombatLockdown() or not NS.EllesmereTracker.Available() then return end
            app.db.ellesmereTrackerButtons = value
            NS.EllesmereTracker.Sync(app)
        end, "ellesmereTrackerTip")
    ellesmereToggle:AddModifyPredicate(NS.EllesmereTracker.Available)

    local ellesmereOffset = sliderSetting("ellesmereTrackerOffset", "ellesmereTrackerOffset", -240, 240, 1, true, 0, "trackerSpacingTip")
    child(ellesmereOffset, ellesmereToggle, function()
        return NS.EllesmereTracker.Available() and app.db.ellesmereTrackerButtons ~= false
    end)

    local flareUIToggle = checkboxSetting("flareUITrackerButtons", not not NS.FlareUITracker.Available(),
        function() return not not NS.FlareUITracker.Available() and app.db.flareUITrackerButtons ~= false end,
        function(value)
            if InCombatLockdown() or not NS.FlareUITracker.Available() then return end
            app.db.flareUITrackerButtons = value
            NS.FlareUITracker.Sync(app)
        end, "flareUITrackerTip")
    flareUIToggle:AddModifyPredicate(NS.FlareUITracker.Available)

    Settings.RegisterAddOnCategory(category)
    UI.nativeCategory = category
end

-- Register at login so Blizzard can list us before our own Options shortcut is used.
-- Registration must never navigate to or show the native Options window.
function UI.RegisterSettings(app)
    if not app.db or InCombatLockdown() then return end
    if Settings and Settings.RegisterVerticalLayoutCategory then
        nativeSettings(app)
        return
    end
    if not (Settings and Settings.RegisterCanvasLayoutCategory) and not InterfaceOptions_AddCategory then return end
    if not UI.settings then
        local panel = CreateFrame("Frame", "QuestTargetsSettings")
        panel:Hide()
        UI.settings = panel
        panel:SetSize(600, 690)
        panel.titleText = label(panel, 20, -18, 540, "GameFontNormalLarge")
        panel.titleText:SetText(UI.OptionsTitle())
        panel.patchNotesButton = button(panel, L("patchNotes"), 142, NS.PatchNotes.Open)
        panel.introButton = button(panel, L("introStartSettings"), 170, function() openIntroFromSettings(app) end)
        panel.feedbackControls = {}
        for _, info in ipairs(feedbackButtons) do
            local key, labelKey = info[1], info[2]
            local control = CreateFrame("Frame", nil, panel)
            control:SetSize(350, 30)
            control.caption = label(control, 0, -4, 184, "GameFontNormal")
            control.selector = button(control, "", 164, function()
                local mode = NS.Core.TargetFeedbackMode(app.db, key)
                app.db.targetFeedback[key] = mode % #feedbackChoices() + 1
                UI.UpdateSettings(app)
                app:Schedule()
            end)
            control.selector:SetPoint("TOPLEFT", 186, 0)
            control.selector:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L(labelKey))
                GameTooltip:AddLine(feedbackDescription(), 1, 1, 1, true)
                GameTooltip:Show()
            end)
            control.selector:SetScript("OnLeave", function() GameTooltip:Hide() end)
            panel.feedbackControls[#panel.feedbackControls + 1] = control
        end
        panel.soundToggle = checkbox(panel, L("muteDeadTargetSound"), function()
            app.db.muteDeadTargetSound = not app.db.muteDeadTargetSound
            UI.UpdateSettings(app)
        end)
        panel.soundToggle:SetPoint("TOPLEFT", 20, -650)
        panel.soundToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("muteDeadTargetSound"))
            GameTooltip:AddLine(L("muteDeadTargetSoundTip"), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        panel.soundToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.selection = label(panel, 20, -84, 330, "GameFontNormal")
        panel.icons = {}
        local names = {strsplit(",", L("markers"))}
        for index, name in ipairs(names) do
            local icon = index
            local choice = button(panel, "", 72, function()
                app.db.markerIcon = icon
                UI.UpdateSettings(app)
                app:Schedule()
            end)
            choice:SetSize(72, 44)
            choice:SetPoint("TOPLEFT", 20 + ((index - 1) % 4) * 85, -108 - math.floor((index - 1) / 4) * 53)
            local texture = choice:CreateTexture(nil, "ARTWORK")
            texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. index)
            texture:SetSize(22, 22)
            texture:SetPoint("TOP", 0, -2)
            local caption = label(choice, 0, -28, 72)
            caption:SetJustifyH("CENTER")
            caption:SetText(name)
            choice.caption = caption
            panel.icons[index] = choice
        end
        panel.names = names
        panel.displayText = label(panel, 20, -225, 330, "GameFontNormal")
        panel.displayText:SetText(L("display"))
        panel.masterToggle = checkbox(panel, L("showMaster"), function()
            app.db.masterHidden = not app.db.masterHidden
            if not app.db.masterHidden then app.db.hotkeysOnly = nil end
            app:Schedule(); UI.UpdateSettings(app)
        end)
        panel.masterToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("showMaster"))
            GameTooltip:AddLine(L("masterMoveTip"), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        panel.masterToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.masterToggle:SetPoint("TOPLEFT", 20, -248)
        panel.masterModulesToggle = checkbox(panel, L("masterAllModules"), function()
            app.db.masterAllModules = app.db.masterAllModules == false
            app:Schedule()
            UI.UpdateSettings(app)
        end)
        panel.masterModulesToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("masterAllModules"))
            GameTooltip:AddLine(L("masterAllModulesTip"), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        panel.masterModulesToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)

        panel.menuToggle = checkbox(panel, L("showMenu"), function()
            app:Toggle(); UI.UpdateSettings(app)
        end)
        panel.menuToggle:SetPoint("TOPLEFT", 20, -278)
        panel.transparencyToggle = checkbox(panel, L("transparencyMode"), function()
            app.db.transparencyMode = not app.db.transparencyMode
            UI.UpdateTransparency(app)
            UI.UpdateSettings(app)
        end)
        panel.scaleControl = settingsSlider(panel, "QuestTargetsWindowScaleSlider", "menuScale", 0.5, 1.5, 0.05, app)
        panel.scaleSlider = panel.scaleControl.slider
        panel.scaleLabel = panel.scaleControl.caption
        panel.tooltipToggle = checkbox(panel, L("showTooltips"), function()
            app.db.showTooltips = not app.db.showTooltips
            UI.UpdateSettings(app)
        end)
        panel.tooltipToggle:SetPoint("TOPLEFT", 20, -308)
        panel.minimapToggle = checkbox(panel, L("showMinimap"), function()
            app.db.minimapHidden = not app.db.minimapHidden
            UI.SetMinimapShown(app, not app.db.minimapHidden)
            UI.UpdateSettings(app)
        end)
        panel.minimapToggle:SetPoint("TOPLEFT", 20, -338)
        panel.questieTrackerToggle = checkbox(panel, L("questieTrackerButtons"), function()
            if InCombatLockdown() or not addonLoaded("Questie") then return end
            app.db.questieTrackerButtons = app.db.questieTrackerButtons == false
            NS.QuestieTracker.Sync(app)
            UI.UpdateSettings(app)
        end)
        panel.ellesmereToggle = checkbox(panel, L("ellesmereTrackerButtons"), function()
            if InCombatLockdown() or not NS.EllesmereTracker.Available() then return end
            app.db.ellesmereTrackerButtons = app.db.ellesmereTrackerButtons == false
            NS.EllesmereTracker.Sync(app)
            UI.UpdateSettings(app)
        end)
        panel.ellesmereToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("ellesmereTrackerButtons"))
            GameTooltip:AddLine(L("ellesmereTrackerTip"), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        panel.ellesmereToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.questieOffsetControl = settingsSlider(panel, "QuestTargetsQuestieOffsetSlider",
            "questieTrackerOffset", -240, 240, 1, app)
        panel.questieOffsetControl.caption:SetText(L("questieTrackerOffset"))
        panel.ellesmereOffsetControl = settingsSlider(panel, "QuestTargetsEllesmereOffsetSlider",
            "ellesmereTrackerOffset", -240, 240, 1, app)
        panel.ellesmereOffsetControl.caption:SetText(L("ellesmereTrackerOffset"))
        panel.flareUIToggle = checkbox(panel, L("flareUITrackerButtons"), function()
            if InCombatLockdown() or not NS.FlareUITracker.Available() then return end
            app.db.flareUITrackerButtons = app.db.flareUITrackerButtons == false
            NS.FlareUITracker.Sync(app)
            UI.UpdateSettings(app)
        end)
        panel.flareUIToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("flareUITrackerButtons"))
            GameTooltip:AddLine(L("flareUITrackerTip"), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        panel.flareUIToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.restedXPToggle = checkbox(panel, L("restedXPIntegration"), function()
            if InCombatLockdown() or not addonLoaded("RXPGuides") then return end
            app.db.restedXPIntegration = app.db.restedXPIntegration == false
            NS.RestedXP.Sync(app)
            UI.UpdateSettings(app)
        end)
        panel.polestarToggle = checkbox(panel, L("polestarIntegration"), function()
            if InCombatLockdown() or not addonLoaded("Polestar") then return end
            app.db.polestarIntegration = app.db.polestarIntegration == false
            NS.RestedXP.Sync(app)
            UI.UpdateStatus(app)
            UI.UpdateSettings(app)
        end)
        panel.followTheArrowToggle = checkbox(panel, L("followTheArrowIntegration"), function()
            if InCombatLockdown() or not NS.RestedXP.FollowTheArrowAvailable() then return end
            app.db.followTheArrowIntegration = app.db.followTheArrowIntegration == false
            NS.RestedXP.Sync(app)
            UI.UpdateStatus(app)
            UI.UpdateSettings(app)
        end)
        panel.followTheArrowToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("followTheArrowIntegrationTip"), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        panel.followTheArrowToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
        panel.itemTreeToggle = checkbox(panel, L("showItemTreeButton"), function()
            if InCombatLockdown() or not addonLoaded("ItemTree") then return end
            app.db.itemTreeButton = app.db.itemTreeButton == false
            NS.ItemTree.Sync(app)
            UI.UpdateSettings(app)
        end)
        panel.rareScannerToggle = checkbox(panel, L("showRareScannerButton"), function()
            if InCombatLockdown() or not NS.RareScanner.MarkingAvailable() then return end
            app.db.rareScannerButton = app.db.rareScannerButton == false
            NS.RareScanner.SyncMark(app)
            UI.UpdateSettings(app)
        end)
        panel.rareScannerZoneToggle = checkbox(panel, L("rareScannerZone"), function()
            if InCombatLockdown() or not NS.RareScanner.ZoneAvailable() then return end
            app.db.rareScannerZone = not app.db.rareScannerZone
            NS.RareScanner.SyncMark(app)
            UI.UpdateSettings(app)
        end)
        panel.hotkeysText = label(panel, 20, -472, 330, "GameFontNormal")
        panel.hotkeysText:SetText(L("hotkeys"))
        local function bindingButton(focused, slot)
            local control = CreateFrame("Button", nil, panel, "UIMenuButtonStretchTemplate")
            control:SetSize(160, 22)
            control:SetNormalFontObject("GameFontHighlightSmall")
            control:SetDisabledFontObject("GameFontDisableSmall")
            control:SetScript("OnClick", function(self)
                if not bindingAvailable(focused) then return end
                beginBindingCapture(self, app, focused, slot, function() UI.UpdateSettings(app) end)
            end)
            if focused == true then
                control:HookScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L("focusHotkey"))
                    GameTooltip:AddLine(L("focusHotkeyTip"), 1, 1, 1, true)
                    GameTooltip:Show()
                end)
                control:HookScript("OnLeave", function() GameTooltip:Hide() end)
            end
            return control
        end
        panel.hotkey = bindingButton(false, 1)
        panel.hotkey2 = bindingButton(false, 2)
        panel.focusHotkey = bindingButton(true, 1)
        panel.focusHotkey2 = bindingButton(true, 2)
        panel.itemTreeHotkey = bindingButton("itemTree", 1)
        panel.itemTreeHotkey2 = bindingButton("itemTree", 2)
        panel.rareScannerHotkey = bindingButton("rareScanner", 1)
        panel.rareScannerHotkey2 = bindingButton("rareScanner", 2)
        panel:SetScript("OnHide", stopBindingCapture)
        panel.hotkeyNote = label(panel, 20, -532, 520)
        panel.hotkeyNote:SetText(L("hotkeyNote"))
        panel.languageText = label(panel, 20, -578, 330, "GameFontNormal")
        panel.languageText:SetText(L("language"))
        panel.languageDropdown = CreateFrame("Frame", "QuestTargetsLanguageDropdown", panel, "UIDropDownMenuTemplate")
        panel.languageDropdown:SetPoint("TOPLEFT", 0, -598)
        UIDropDownMenu_SetWidth(panel.languageDropdown, 230)
        UIDropDownMenu_Initialize(panel.languageDropdown, function()
            for index, code in ipairs(NS.LANGUAGES) do
                local language = code
                local info = UIDropDownMenu_CreateInfo()
                info.text = NS.LANGUAGE_NAMES[index]
                info.value = language
                info.checked = NS.Language() == index
                info.func = function()
                    if InCombatLockdown() or language == app.db.language then return end
                    app.db.language = language
                    UI.ApplyLanguage(app)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UI.CreateMasterSettings(app, panel)
        UI.LayoutSettings(app)
        if Settings and Settings.RegisterCanvasLayoutCategory then
            local category = Settings.RegisterCanvasLayoutCategory(panel, L("title"))
            Settings.RegisterAddOnCategory(category)
            UI.settingsCategoryID = category:GetID()
        elseif InterfaceOptions_AddCategory then
            panel.name = L("title")
            InterfaceOptions_AddCategory(panel)
        end
    end
end

function UI.Settings(app)
    if not app.db or InCombatLockdown() then return end
    UI.RegisterSettings(app)
    if UI.nativeCategory then
        Settings.OpenToCategory(UI.nativeCategory:GetID())
        return
    end
    UI.UpdateSettings(app)
    if Settings and Settings.OpenToCategory and UI.settingsCategoryID then Settings.OpenToCategory(UI.settingsCategoryID)
    elseif InterfaceOptionsFrame_OpenToCategory then InterfaceOptionsFrame_OpenToCategory(UI.settings) end
end

function UI.CreateMasterSettings(app, category)
    local panel = CreateFrame("Frame", "QuestTargetsMasterSettings", category)
    UI.masterSettings = panel
    panel.orientationLabel = label(panel, 0, 0, 160, "GameFontNormal")
    panel.orientationDropdown = CreateFrame("Frame", "QuestTargetsOrientationDropdown", panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(panel.orientationDropdown, 140)
    UIDropDownMenu_Initialize(panel.orientationDropdown, function()
        for index, orientation in ipairs({"horizontal", "vertical"}) do
            local choice = orientation
            local info = UIDropDownMenu_CreateInfo()
            info.text = L(index == 1 and "masterHorizontal" or "masterVertical")
            info.checked = app.db.masterOrientation == choice
            info.func = function()
                app.db.masterOrientation = choice
                UI.UpdateMasterSettings(app)
                app:Schedule()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    panel.spacingControl = settingsSlider(panel, "QuestTargetsButtonSpacingSlider", "masterSpacing", 0, 32, 1, app)
    panel.backgroundToggle = checkbox(panel, L("masterBackground"), function()
        app.db.masterBackground = not app.db.masterBackground
        UI.UpdateMasterSettings(app)
        app:Schedule()
    end)
    panel.borderToggle = checkbox(panel, L("masterBorder"), function()
        app.db.masterBorder = not app.db.masterBorder
        UI.UpdateMasterSettings(app)
        app:Schedule()
    end)
    panel.dividersToggle = checkbox(panel, L("masterDividers"), function()
        app.db.masterDividers = not app.db.masterDividers
        UI.UpdateMasterSettings(app)
        app:Schedule()
    end)

    panel.modernScaleControl = settingsSlider(panel, "QuestTargetsMasterScaleSlider", "masterModernScale", 0.3, 2, 0.01, app)
    panel.lockToggle = checkbox(panel, L("masterLocked"), function()
        UI.SetTargetBarLocked(app, not app.db.masterLocked)
    end)

    panel.moveButton = button(panel, L("masterMove"), 260, function() UI.BeginMasterMove(app) end)
    panel.moveHelp = label(panel, 20, -390, 500)
    panel.moveHelp:SetHeight(54)
    panel.moveHelp:SetText(L("masterMoveHelp"))
    UI.UpdateMasterSettings(app)
end

function UI.UpdateMasterSettings(app)
    local panel = UI.masterSettings
    if not panel then return end
    local vertical = app.db.masterOrientation == "vertical"
    panel.orientationLabel:SetText(L("masterOrientation"))
    UIDropDownMenu_SetText(panel.orientationDropdown, L(vertical and "masterVertical" or "masterHorizontal"))
    panel.spacingControl.caption:SetText(L("masterSpacing") .. " (px)")
    panel.spacingControl:Refresh()
    panel.backgroundToggle.caption:SetText(L("masterBackground"))
    panel.backgroundToggle:SetChecked(app.db.masterBackground)
    panel.borderToggle.caption:SetText(L("masterBorder"))
    panel.borderToggle:SetChecked(app.db.masterBorder)
    panel.dividersToggle.caption:SetText(L("masterDividers"))
    panel.dividersToggle:SetChecked(app.db.masterDividers)
    panel.lockToggle.caption:SetText(L("masterLocked"))
    panel.lockToggle:SetChecked(app.db.masterLocked)
    panel.modernScaleControl.caption:SetText(L("buttonSize"))
    panel.modernScaleControl:Refresh()
end

function UI.UpdateSettings(app)
    if not UI.settings then return end
    local modes = feedbackChoices()
    for index, control in ipairs(UI.settings.feedbackControls) do
        local info = feedbackButtons[index]
        control.caption:SetText(L(info[2]))
        control.selector:SetText(modes[NS.Core.TargetFeedbackMode(app.db, info[1])])
    end
    UI.settings.soundToggle:SetChecked(app.db.muteDeadTargetSound)
    UI.settings.selection:SetText(string.format(L("marker"), UI.settings.names[app.db.markerIcon]))
    UI.settings.masterToggle:SetChecked(not app.db.masterHidden)
    UI.settings.masterModulesToggle:SetChecked(app.db.masterAllModules ~= false)
    UI.settings.masterModulesToggle:SetEnabled(not app.db.masterHidden)
    local menuShown = app.pendingVisibility
    if menuShown == nil then menuShown = not app.db.hidden end
    UI.settings.menuToggle:SetChecked(menuShown)
    UI.settings.transparencyToggle:SetChecked(app.db.transparencyMode)
    UI.settings.scaleLabel:SetText(L("windowSize"))
    UI.settings.scaleControl:Refresh()
    UI.settings.tooltipToggle:SetChecked(app.db.showTooltips)
    UI.settings.minimapToggle:SetChecked(not app.db.minimapHidden)
    local ellesmereAvailable = NS.EllesmereTracker.Available()
    UI.settings.ellesmereToggle:SetChecked(not not ellesmereAvailable and app.db.ellesmereTrackerButtons ~= false)
    UI.settings.ellesmereToggle:SetEnabled(ellesmereAvailable)
    local ellesmereGray = ellesmereAvailable and 1 or 0.5
    UI.settings.ellesmereToggle.caption:SetTextColor(ellesmereGray, ellesmereGray, ellesmereGray)
    UI.settings.ellesmereOffsetControl:Refresh()
    local ellesmereOffsetEnabled = ellesmereAvailable and app.db.ellesmereTrackerButtons ~= false
    UI.settings.ellesmereOffsetControl.slider:SetEnabled(ellesmereOffsetEnabled)
    UI.settings.ellesmereOffsetControl.edit:SetEnabled(ellesmereOffsetEnabled)
    local flareUIAvailable = NS.FlareUITracker.Available()
    UI.settings.flareUIToggle:SetEnabled(flareUIAvailable)
    UI.settings.flareUIToggle:SetChecked(not not flareUIAvailable and app.db.flareUITrackerButtons ~= false)
    local flareUIGray = flareUIAvailable and 1 or 0.5
    UI.settings.flareUIToggle.caption:SetTextColor(flareUIGray, flareUIGray, flareUIGray)
    local questieAvailable = addonLoaded("Questie")
    UI.settings.questieTrackerToggle:SetChecked(not not questieAvailable and app.db.questieTrackerButtons ~= false)
    UI.settings.questieTrackerToggle:SetEnabled(questieAvailable)
    local gray = questieAvailable and 1 or 0.5
    UI.settings.questieTrackerToggle.caption:SetTextColor(gray, gray, gray)
    UI.settings.questieOffsetControl:Refresh()
    local offsetEnabled = questieAvailable and app.db.questieTrackerButtons ~= false
    UI.settings.questieOffsetControl.slider:SetEnabled(offsetEnabled)
    UI.settings.questieOffsetControl.edit:SetEnabled(offsetEnabled)
    local restedXPAvailable = addonLoaded("RXPGuides")
    UI.settings.restedXPToggle:SetChecked(not not restedXPAvailable and app.db.restedXPIntegration ~= false)
    UI.settings.restedXPToggle:SetEnabled(restedXPAvailable)
    UI.settings.restedXPToggle.caption:SetTextColor(restedXPAvailable and 1 or 0.5,
        restedXPAvailable and 1 or 0.5, restedXPAvailable and 1 or 0.5)
    local polestarAvailable = addonLoaded("Polestar")
    UI.settings.polestarToggle:SetChecked(not not polestarAvailable and app.db.polestarIntegration ~= false)
    UI.settings.polestarToggle:SetEnabled(polestarAvailable)
    local polestarGray = polestarAvailable and 1 or 0.5
    UI.settings.polestarToggle.caption:SetTextColor(polestarGray, polestarGray, polestarGray)
    local followTheArrowAvailable = NS.RestedXP.FollowTheArrowAvailable()
    UI.settings.followTheArrowToggle:SetChecked(not not followTheArrowAvailable and app.db.followTheArrowIntegration ~= false)
    local followTheArrowEnabled = not app.db.masterHidden and followTheArrowAvailable
    UI.settings.followTheArrowToggle:SetEnabled(followTheArrowEnabled)
    local followTheArrowGray = followTheArrowEnabled and 1 or 0.5
    UI.settings.followTheArrowToggle.caption:SetTextColor(followTheArrowGray, followTheArrowGray, followTheArrowGray)
    local first, second = GetBindingKey(MASTER_BINDING)
    if not UI.settings.hotkey.listening then UI.settings.hotkey:SetText(bindingText(first)) end
    if not UI.settings.hotkey2.listening then UI.settings.hotkey2:SetText(bindingText(second)) end
    first, second = GetBindingKey(FOCUS_BINDING)
    if not UI.settings.focusHotkey.listening then UI.settings.focusHotkey:SetText(bindingText(first)) end
    if not UI.settings.focusHotkey2.listening then UI.settings.focusHotkey2:SetText(bindingText(second)) end
    local itemTreeAvailable = addonLoaded("ItemTree")
    UI.settings.itemTreeToggle:SetChecked(not not itemTreeAvailable and app.db.itemTreeButton ~= false)
    UI.settings.rareScannerToggle:SetChecked(NS.RareScanner.ButtonEnabled(app))
    local rareScannerAvailable = NS.RareScanner.MarkingAvailable()
    UI.settings.rareScannerToggle:SetEnabled(rareScannerAvailable)
    local rareGray = rareScannerAvailable and 1 or 0.5
    UI.settings.rareScannerToggle.caption:SetTextColor(rareGray, rareGray, rareGray)
    UI.settings.rareScannerZoneToggle:SetChecked(app.db.rareScannerZone == true)
    local zoneAvailable = NS.RareScanner.ZoneAvailable()
    UI.settings.rareScannerZoneToggle:SetEnabled(not not zoneAvailable)
    rareGray = zoneAvailable and 1 or 0.5
    UI.settings.rareScannerZoneToggle.caption:SetTextColor(rareGray, rareGray, rareGray)
    UI.settings.itemTreeToggle:SetEnabled(itemTreeAvailable)
    UI.settings.itemTreeHotkey:SetEnabled(itemTreeAvailable)
    UI.settings.itemTreeHotkey2:SetEnabled(itemTreeAvailable)
    gray = itemTreeAvailable and 1 or 0.5
    UI.settings.itemTreeToggle.caption:SetTextColor(gray, gray, gray)
    UI.settings.itemTreeHotkeyAction:SetTextColor(gray, gray, gray)
    first, second = GetBindingKey(ITEMTREE_BINDING)
    if not UI.settings.itemTreeHotkey.listening then UI.settings.itemTreeHotkey:SetText(bindingText(first)) end
    if not UI.settings.itemTreeHotkey2.listening then UI.settings.itemTreeHotkey2:SetText(bindingText(second)) end
    UI.settings.rareScannerHotkey:SetEnabled(rareScannerAvailable)
    UI.settings.rareScannerHotkey2:SetEnabled(rareScannerAvailable)
    rareGray = rareScannerAvailable and 1 or 0.5
    UI.settings.rareScannerHotkeyAction:SetTextColor(rareGray, rareGray, rareGray)
    first, second = GetBindingKey(RARESCANNER_BINDING)
    if not UI.settings.rareScannerHotkey.listening then UI.settings.rareScannerHotkey:SetText(bindingText(first)) end
    if not UI.settings.rareScannerHotkey2.listening then UI.settings.rareScannerHotkey2:SetText(bindingText(second)) end
    UIDropDownMenu_SetSelectedID(UI.settings.languageDropdown, NS.Language())
    UIDropDownMenu_SetText(UI.settings.languageDropdown, NS.LANGUAGE_NAMES[NS.Language()])
    for index, choice in ipairs(UI.settings.icons) do choice:SetEnabled(index ~= app.db.markerIcon) end
end

function UI.ApplyLanguage(app)
    NS.UpdateBindingLabels()
    if UI.nativeButtonsCategory then UI.nativeButtonsCategory:SetName(L("buttonsBar")) end
    -- Forever may not preserve newly written SavedVariables across /reload.
    -- Refresh existing native controls immediately instead of reloading the UI.
    if InCombatLockdown() then return end
    NS.Tutorial.RefreshLanguage()
    NS.PatchNotes.RefreshLanguage()
    if UI.frame then
        UI.frame.TitleContainer.TitleText:SetText(L("title"))
        UI.settingsButton:SetText(L("settings"))
        UI.feedbackButton:SetText(L("feedback"))
    end
    local panel = UI.settings
    if panel then
        panel.titleText:SetText(UI.OptionsTitle())
        panel.patchNotesButton:SetText(L("patchNotes"))
        panel.introButton:SetText(L("introStartSettings"))
        if panel.tabs then
            for _, tab in ipairs(panel.tabs) do tab:SetText(L(tab.localeKey)) end
            for _, group in ipairs(panel.groups) do group.heading:SetText(L(group.localeKey)) end
            panel.hotkeyAction:SetText(L("masterDefault"))
            panel.focusHotkeyAction:SetText(L("focusHotkey"))
            panel.itemTreeHotkeyAction:SetText(L("itemTreeBinding"))
            panel.rareScannerHotkeyAction:SetText(L("rareScannerBinding"))
            for slot, header in ipairs(panel.bindingHeaders) do
                header:SetText(L(slot == 1 and "bindingKey1" or "bindingKey2"))
            end
            panel:ResizeTabs()
        end
        panel.soundToggle.caption:SetText(L("muteDeadTargetSound"))
        panel.displayText:SetText(L("display"))
        panel.masterToggle.caption:SetText(L("showMaster"))
        panel.masterModulesToggle.caption:SetText(L("masterAllModules"))
        panel.menuToggle.caption:SetText(L("showMenu"))
        panel.transparencyToggle.caption:SetText(L("transparencyMode"))
        panel.tooltipToggle.caption:SetText(L("showTooltips"))
        panel.minimapToggle.caption:SetText(L("showMinimap"))
        panel.ellesmereToggle.caption:SetText(L("ellesmereTrackerButtons"))
        panel.flareUIToggle.caption:SetText(L("flareUITrackerButtons"))
        panel.ellesmereOffsetControl.caption:SetText(L("ellesmereTrackerOffset"))
        panel.questieTrackerToggle.caption:SetText(L("questieTrackerButtons"))
        panel.questieOffsetControl.caption:SetText(L("questieTrackerOffset"))
        panel.restedXPToggle.caption:SetText(L("restedXPIntegration"))
        panel.polestarToggle.caption:SetText(L("polestarIntegration"))
        panel.followTheArrowToggle.caption:SetText(L("followTheArrowIntegration"))
        panel.itemTreeToggle.caption:SetText(L("showItemTreeButton"))
        panel.rareScannerToggle.caption:SetText(L("showRareScannerButton"))
        panel.rareScannerZoneToggle.caption:SetText(L("rareScannerZone"))
        panel.hotkeyNote:SetText(L("hotkeyNote"))
        panel.hotkeysText:SetText(L("hotkeys"))
        panel.languageText:SetText(L("language"))
        panel.names = {strsplit(",", L("markers"))}
        for index, choice in ipairs(panel.icons) do
            choice.caption:SetText(panel.names[index])
        end
        UI.UpdateSettings(app)
    end
    if UI.masterSettings then
        UI.masterSettings.moveButton:SetText(L("masterMove"))
        UI.masterSettings.moveHelp:SetText(L("masterMoveHelp"))
        UI.UpdateMasterSettings(app)
    end
    UI.UpdateMasterMove(app)
    if UI.frame then app:Refresh() end
end

function UI.RestorePosition(db)
    local frame, pos = UI.frame, db.position
    frame:ClearAllPoints()
    if type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" then
        frame:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 320, 40)
    end
end

function UI.StopMoving(db)
    if not UI.moving and not UI.movingPending then return end
    -- Combat can interrupt OnDragStop. Release the refresh gate immediately,
    -- then stop the protected frame and save its position after combat.
    if InCombatLockdown() then
        UI.moving = false
        UI.movingPending = true
        return
    end
    UI.frame:StopMovingOrSizing()
    UI.moving = false
    UI.movingPending = false
    local x, y = UI.frame:GetCenter()
    local px, py = UIParent:GetCenter()
    local scale = UI.frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    db.position = {x = x * scale - px, y = y * scale - py}
end

function UI.Tooltip(row)
    if not row.entry or row.entry.tutorial or not NS.app.db.showTooltips then return end
    local entry = row.entry
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(entry.title or entry.name or L("tooltipUnknown"))
    for _, ref in ipairs(entry.refs) do
        GameTooltip:AddLine(ref.text, 1, 1, 1, true)
    end
    if entry.nameList and #entry.nameList > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L("tooltipNames"), 1, 0.82, 0, true)
        for _, name in ipairs(entry.nameList) do GameTooltip:AddLine(name, 1, 1, 1, true) end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L("focusTip"), 0.75, 0.75, 0.75, true)
    GameTooltip:Show()
end

function UI.OpenQuest(entry)
    -- Native helpers can change quest/map UI before reaching ShowUIPanel's guard.
    if InCombatLockdown() then return end
    local questID = entry and entry.questID
    if type(questID) ~= "number" or questID <= 0 then return end
    local selectQuest = C_QuestLog and C_QuestLog["SetSelectedQuest"]
    if type(QuestMapFrame_OpenToQuestDetails) == "function" then
        QuestMapFrame_OpenToQuestDetails(questID)
    elseif QuestUtil and type(QuestUtil.OpenQuestDetails) == "function" then
        QuestUtil.OpenQuestDetails(questID)
    elseif OpenQuestLog and type(selectQuest) == "function" then
        OpenQuestLog()
        selectQuest(questID)
    elseif GetNumQuestLogEntries and GetQuestLogTitle and QuestLog_SetSelection and ShowUIPanel and QuestLogFrame then
        for index = 1, GetNumQuestLogEntries() do
            if select(8, GetQuestLogTitle(index)) == questID then
                ShowUIPanel(QuestLogFrame)
                QuestLog_SetSelection(index)
                if QuestLog_Update then QuestLog_Update() end
                return
            end
        end
    end
end

local function questListRows(quests, entries, collapsed)
    local zones, groups, headings = {}, {}, {}
    for _, quest in ipairs(quests or {}) do zones[quest.id] = quest.zone end
    for index, entry in ipairs(entries) do
        local zone = zones[entry.questID] or ""
        if not groups[zone] then
            groups[zone] = {}
            headings[#headings + 1] = zone
        end
        local group = groups[zone]
        group[#group + 1] = {entry = entry, number = index}
    end
    if #headings == 1 and headings[1] == "" then return groups[""] end
    table.sort(headings, function(a, b)
        if a == "" then return false end
        if b == "" then return true end
        local lowerA, lowerB = a:lower(), b:lower()
        if lowerA == lowerB then return a < b end
        return lowerA < lowerB
    end)
    local rows, number = {}, 0
    for _, zone in ipairs(headings) do
        local folded = collapsed and collapsed[zone] == true
        local title = zone ~= "" and zone or L("questZoneOther")
        local group = groups[zone]
        rows[#rows + 1] = {zoneKey = zone, title = (folded and "+  " or "−  ") .. title .. " (" .. #group .. ")"}
        if not folded then
            for index, item in ipairs(group) do
                item.number = number + index
                rows[#rows + 1] = item
            end
        end
        number = number + #group
    end
    return rows
end

function UI.Render(app)
    assert(not InCombatLockdown(), "Next: protected update during combat")
    local scale = math.min(1, UIParent:GetHeight() / 410) * app.db.menuScale
    if UI.frame:GetScale() ~= scale then UI.frame:SetScale(scale) end
    local entries = NS.Core.QuestEntriesFor(app, false)
    if app.tutorialQuest then
        app.questListRows = {{number=1, entry={tutorial=true, title="Mrrml’s Quest", name="player",
            nameList={}, refs={}, total=0}}}
    else
        app.questListRows = questListRows(app.quests, entries, app.db.collapsedQuestZones)
    end
    local maxOffset = math.max(0, #app.questListRows - UI.PAGE_SIZE)
    app.scrollOffset = math.max(0, math.min(maxOffset, app.scrollOffset or 0))
    UI.filter:SetText(app.db.watchedOnly and L("tracked") or L("all"))
    UI.scrollbar:SetMinMaxValues(0, maxOffset)
    UI.scrollbar:SetValue(app.scrollOffset)
    UI.scrollbar:SetShown(maxOffset > 0)
    UI.empty:SetText(app.error or (app.db.watchedOnly and L("emptyTracked") or L("emptyAll")))
    UI.empty:SetShown(not app.tutorialQuest and #entries == 0)
    UI.RenderRows(app)
    UI.UpdateStatus(app)
end

function UI.ScrollQuests(app, delta)
    if InCombatLockdown() or not UI.scrollbar then return end
    local maxOffset = math.max(0, #(app.questListRows or {}) - UI.PAGE_SIZE)
    local nextOffset = math.max(0, math.min(maxOffset, (app.scrollOffset or 0) + delta))
    UI.scrollbar:SetValue(nextOffset)
end

function UI.RenderRows(app)
    assert(not InCombatLockdown(), "Next: protected scroll during combat")
    local entries = app.questListRows or {}
    for index, row in ipairs(UI.rows) do
        local item = index <= UI.PAGE_SIZE and entries[(app.scrollOffset or 0) + index] or nil
        local entry = item and item.entry
        local header = UI.zoneHeaders[index]
        header.zoneKey = item and item.zoneKey
        if header.zoneKey ~= nil then header.caption:SetText(item.title) end
        header:SetShown(header.zoneKey ~= nil)
        row:SetAttribute("macrotext1", nil)
        local tutorial = entry and entry.tutorial or false
        if row.tutorial ~= tutorial then
            row:SetAttribute("type1", tutorial and "target" or "macro")
            row:SetAttribute("unit", tutorial and "player" or nil)
            row.tutorial = tutorial
        end
        row.entry = entry
        if row.fallbackQuestID ~= (entry and entry.questID) then row.fallbackIndex = nil end
        row.fallbackQuestID = entry and entry.questID
        if entry then
            if not tutorial then
                row:SetAttribute("macrotext1", (NS.Core.EntryMacro(entry, NS.Core.TargetFeedbackSettings(app.db, "questList"))))
            end
            row.nameText:SetText(entry.title)
            row.nameText:SetTextColor(entry.name and 1 or 0.7, entry.name and 0.82 or 0.7, entry.name and 0 or 0.7)
            local atlas = entry.name and "UI-QuestPoi-QuestNumber-SuperTracked" or "UI-QuestPoi-QuestNumber"
            row:SetNormalAtlas(atlas)
            row:SetPushedAtlas(atlas)
            -- Button atlas setters may restore full-button anchors and atlas size.
            row.icon:ClearAllPoints()
            row.icon:SetSize(22, 22)
            row.icon:SetPoint("LEFT", 1, 0)
            row.pushedIcon:ClearAllPoints()
            row.pushedIcon:SetSize(20, 20)
            row.pushedIcon:SetPoint("LEFT", 2, -1)
            row.number:SetText(item.number)
            row.focusMark:SetShown(tutorial or entry.questID == app.db.focusQuestID)
            local progress = entry.total > 0 and (entry.done .. "/" .. entry.total) or L("open")
            row.detail:SetText(tutorial and L("tutorialPracticeRow")
                or string.format(L("detail"), progress, #entry.refs, #entry.nameList))
            row:Show()
        else
            row.focusMark:Hide()
            row:Hide()
        end
    end
end

function UI.UpdateStatus(app)
    if not UI.database then return end
    local status = NS.Database.status
    if status == L("dbMissing") and app.db.masterAllModules ~= false and not app.db.masterHidden then
        if _G.Polestar and _G.Polestar.Engine and app.db.polestarIntegration == false then
            status = L("dbEnablePolestar")
        elseif NS.RestedXP.FollowTheArrowAvailable() and app.db.followTheArrowIntegration == false then
            status = L("dbEnableFollowTheArrow")
        end
    end
    UI.database:SetText(status)
end
