local _, NS = ...
local UI = {}
NS.UI = UI
local L = NS.L
local FEEDBACK_URL = "https://feedback.jacknine.org"
UI.PAGE_SIZE = 6

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
            and UI.transparencyButton and not UI.transparencyButton:IsMouseOver() then
            UI.transparencyButton:SetAlpha(0)
        end
    end)
end

function UI.UpdateTransparency(app)
    if not UI.frame then return end
    local alpha = app.db.transparencyMode and 0 or 1
    if UI.chromeAlpha ~= alpha then setChromeAlpha(alpha) end
    if UI.transparencyButton then
        UI.transparencyButton:GetNormalTexture():SetDesaturated(not app.db.transparencyMode)
        UI.transparencyButton:SetAlpha(1)
        scheduleTransparencyIconHide(app)
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

function UI.Create(app)
    local frame = CreateFrame("Frame", "QuestTargetsFrame", UIParent, "DefaultPanelFlatTemplate")
    UI.frame = frame
    frame:SetSize(282, 386)
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
    drag:SetPoint("TOPLEFT", 8, 0)
    drag:SetPoint("TOPRIGHT", -30, 0)
    drag:SetHeight(23)
    drag:SetFrameLevel(511)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function()
        if not InCombatLockdown() then frame:StartMoving(); UI.moving = true end
    end)
    drag:SetScript("OnDragStop", function() UI.StopMoving(app.db) end)

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
        scheduleTransparencyIconHide(app)
    end)

    UI.filter = button(frame, L("all"), 116, function() app:ToggleFilter() end)
    UI.filter:SetPoint("TOPLEFT", 10, -30)
    UI.database = label(frame, 132, -35, 113)
    local help = button(frame, "?", 24, function() app:Help() end)
    help:SetPoint("TOPRIGHT", -10, -30)
    UI.rows = {}
    for index = 1, UI.PAGE_SIZE do
        local row = CreateFrame("Button", "QuestTargetsTarget" .. index, frame, "SecureActionButtonTemplate")
        row:SetPoint("TOPLEFT", 10, -62 - (index - 1) * 39)
        row:SetSize(238, 36)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function(_, delta) UI.ScrollQuests(app, -delta) end)
        row:RegisterForClicks("AnyUp")
        row:SetAttribute("useOnKeyDown", false)
        row:SetAttribute("type1", "macro")
        row:SetScript("PreClick", function(self, mouseButton, down)
            if mouseButton ~= "LeftButton" or down or InCombatLockdown() then return end
            self:SetAttribute("macrotext1", NS.Core.ClickMacro(self.entry, app.entries, app.db, self))
        end)
        row:SetScript("PostClick", function(self, mouseButton, down)
            if down then return end
            if mouseButton == "RightButton" then
                UI.OpenQuest(self.entry)
                return
            end
            if mouseButton and mouseButton ~= "LeftButton" then return end
            if InCombatLockdown() then return end
            NS.Core.RecordClickResult()
            self:SetAttribute("macrotext1", (NS.Core.EntryMacro(self.entry, app.db)))
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
    UI.settingsButton = button(frame, L("settings"), 94, function() UI.Settings(app) end)
    UI.settingsButton:SetPoint("BOTTOMLEFT", 10, 40)
    UI.refreshButton = button(frame, L("refresh"), 94, function() app:Refresh() end)
    UI.refreshButton:SetPoint("BOTTOMRIGHT", -10, 40)
    UI.feedbackButton = button(frame, L("feedback"), 260, function() UI.FeedbackLink() end)
    UI.feedbackButton:SetPoint("BOTTOM", 0, 8)
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
    addChrome(UI.refreshButton)
    addChrome(UI.feedbackButton)
    UI.chromeAlpha = 1
    UI.UpdateTransparency(app)
    frame:SetShown(not app.db.hidden)
end

function UI.FeedbackLink()
    if not StaticPopupDialogs or not StaticPopup_Show then return end
    local key = "QUESTTARGETS_FEEDBACK_LINK"
    local function selectLink(self)
        local box = self.GetEditBox and self:GetEditBox() or self.editBox or self.EditBox
        if box then box:SetText(FEEDBACK_URL); box:HighlightText(); box:SetFocus() end
        return true
    end
    StaticPopupDialogs[key] = {
        text = L("feedbackLink"),
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
    StaticPopup_Show(key)
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

function UI.SelectSettingsTab(index)
    local panel = UI.settings
    if not panel or not panel.pages[index] then return end
    panel.hotkey.listening = false
    panel.hotkey:EnableKeyboard(false)
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
    local keys = {"general", "targetMarkers", "master", "hotkeys"}
    local heights = {550, 310, 538, 216}
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
    local display = settingsBox(general, "display", -32, 196)
    local window = settingsBox(general, "window", -262, 125)
    local language = settingsBox(general, "language", -421, 102)
    local marking = settingsBox(markers, "targetMarkers", -32, 260)
    local appearance = settingsBox(master, "masterAppearance", -32, 84)
    local dimensions = settingsBox(master, "buttonSize", -150, 220)
    local caption = settingsBox(master, "caption", -404, 112)
    local bindings = settingsBox(hotkeys, "hotkeys", -32, 164)
    panel.groups = {display, window, language, marking, appearance, dimensions, caption, bindings}
    panel.displayText:Hide()
    panel.languageText:Hide()
    panel.hotkeysText:Hide()
    for i, control in ipairs({panel.masterToggle, panel.menuToggle, panel.transparencyToggle,
        panel.tooltipToggle, panel.minimapToggle}) do
        place(control, display, 18, -32 - (i-1)*30)
    end
    place(panel.scaleControl, window, 22, -31)
    panel.scaleControl:SetPoint("TOPRIGHT", window, "TOPRIGHT", -22, -31)
    place(panel.languageDropdown, language, 2, -42)
    place(panel.toggle, marking, 18, -35)
    place(panel.selection, marking, 18, -72)
    for index, choice in ipairs(panel.icons) do
        place(choice, marking, 20 + ((index - 1) % 4)*85, -103 - math.floor((index-1)/4)* 60)
    end
    master.titleText:Hide()
    master.appearanceText:Hide()
    master.sizeNote:Hide()
    master.captionText:Hide()
    place(master.classicButton, appearance, 20, -42)
    place(master.modernButton, appearance, 155, -42)
    for i, field in ipairs({master.widthControl, master.heightControl, master.modernScaleControl}) do
        local y = i == 2 and -125 or -34
        place(field, dimensions, 22, y)
        field:SetPoint("TOPRIGHT", dimensions, "TOPRIGHT", -22, y)
    end
    master.captionGroup = caption
    master.dimensionsGroup = dimensions
    place(master.textEdit, caption, 22, -41)
    master.textEdit:SetPoint("TOPRIGHT", caption, "TOPRIGHT", -22, -41)
    place(master.emptyCaption, caption, 18, -78)
    panel.hotkeyAction = label(bindings, 18, -43, 210, "GameFontHighlight")
    panel.hotkeyAction:SetText(L("masterDefault"))
    place(panel.hotkey, bindings, 235, -38)
    panel.hotkey:SetWidth(150)
    panel.hotkey:SetNormalFontObject("GameFontNormalSmall")
    place(panel.hotkeyClear, bindings, 395, -38)
    panel.hotkeyClear:SetWidth(80)
    panel.hotkeyClear:ClearAllPoints()
    panel.hotkeyClear:SetPoint("TOPRIGHT", -18, -38)
    panel.hotkey:ClearAllPoints()
    panel.hotkey:SetPoint("RIGHT", panel.hotkeyClear, "LEFT", -10, 0)
    panel.hotkeyAction:SetPoint("TOPRIGHT", panel.hotkey, "TOPLEFT", -12, -5)
    place(panel.hotkeyNote, bindings, 18, -90)
    panel.hotkeyNote:SetWidth(450)
    panel.hotkeyNote:SetPoint("TOPRIGHT", bindings, "TOPRIGHT", -18, -90)
    panel.pages[4].scroll:SetScript("OnHide", function()
        panel.hotkey.listening = false
        panel.hotkey:EnableKeyboard(false)
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

function UI.Settings(app)
    if not app.db or InCombatLockdown() then return end
    if not UI.settings then
        local panel = CreateFrame("Frame", "QuestTargetsSettings")
        UI.settings = panel
        panel:SetSize(600, 690)
        panel.titleText = label(panel, 20, -18, 540, "GameFontNormalLarge")
        panel.titleText:SetText(L("title"))
        panel.toggle = checkbox(panel, L("autoMark"), function()
            app.db.autoMark = not app.db.autoMark
            UI.UpdateSettings(app)
            app:Schedule()
        end)
        panel.toggle:SetPoint("TOPLEFT", 20, -48)
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
            app:Schedule(); UI.UpdateSettings(app)
        end)
        panel.masterToggle:SetPoint("TOPLEFT", 20, -248)
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
            if UI.minimap then UI.minimap:SetShown(not app.db.minimapHidden) end
            UI.UpdateSettings(app)
        end)
        panel.minimapToggle:SetPoint("TOPLEFT", 20, -338)
        panel.hotkeysText = label(panel, 20, -472, 330, "GameFontNormal")
        panel.hotkeysText:SetText(L("hotkeys"))
        panel.hotkey = button(panel, "", 200, function(self)
            if InCombatLockdown() then return end
            self.listening = true
            self:SetText(L("pressKey"))
            self:EnableKeyboard(true)
            self:SetPropagateKeyboardInput(false)
        end)
        panel.hotkey:SetPoint("TOPLEFT", 20, -498)
        panel.hotkey:SetScript("OnKeyDown", function(self, key)
            if not self.listening then return end
            -- Modifier keys arrive as separate key-down events. Keep listening
            -- until a non-modifier key completes the combination.
            if key == "LSHIFT" or key == "RSHIFT" or key == "SHIFT"
                or key == "LCTRL" or key == "RCTRL" or key == "CTRL"
                or key == "LALT" or key == "RALT" or key == "ALT" then return end
            self.listening = false
            self:EnableKeyboard(false)
            if key == "ESCAPE" or key == "UNKNOWN" or InCombatLockdown() then UI.UpdateSettings(app); return end
            local modifier = (IsControlKeyDown() and "CTRL-" or "") .. (IsAltKeyDown() and "ALT-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "")
            local binding = modifier .. key
            local old = GetBindingKey("CLICK QuestTargetsMaster:LeftButton")
            if SetBindingClick(binding, "QuestTargetsMaster", "LeftButton") then
                if old and old ~= binding then SetBinding(old) end
                SaveBindings(GetCurrentBindingSet())
            end
            UI.UpdateSettings(app)
        end)
        panel.hotkeyClear = button(panel, L("clear"), 90, function()
            if InCombatLockdown() then return end
            local old = GetBindingKey("CLICK QuestTargetsMaster:LeftButton")
            if old then SetBinding(old); SaveBindings(GetCurrentBindingSet()) end
            UI.UpdateSettings(app)
        end)
        panel.hotkeyClear:SetPoint("TOPLEFT", 225, -498)
        panel:SetScript("OnHide", function()
            panel.hotkey.listening = false
            panel.hotkey:EnableKeyboard(false)
        end)
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
                    local oldDefault = L("masterDefault")
                    app.db.language = language
                    if app.db.masterText == oldDefault then app.db.masterText = L("masterDefault") end
                    UI.ApplyLanguage(app)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UI.CreateMasterSettings(app, panel)
        UI.LayoutSettings(app)
        if Settings and Settings.RegisterCanvasLayoutCategory then
            local category = Settings.RegisterCanvasLayoutCategory(panel, "Quest Targets")
            Settings.RegisterAddOnCategory(category)
            UI.settingsCategoryID = category:GetID()
        elseif InterfaceOptions_AddCategory then
            panel.name = "Quest Targets"
            InterfaceOptions_AddCategory(panel)
        end
    end
    UI.UpdateSettings(app)
    if Settings and Settings.OpenToCategory and UI.settingsCategoryID then Settings.OpenToCategory(UI.settingsCategoryID)
    elseif InterfaceOptionsFrame_OpenToCategory then InterfaceOptionsFrame_OpenToCategory(UI.settings) end
end

function UI.CreateMasterSettings(app, category)
    local panel = CreateFrame("Frame", "QuestTargetsMasterSettings", category)
    UI.masterSettings = panel
    panel:SetSize(600, 470)
    panel.titleText = label(panel, 20, -18, 540, "GameFontNormalLarge")
    panel.titleText:SetText(L("master"))
    panel.appearanceText = label(panel, 20, -50, 540, "GameFontNormal")
    panel.classicButton = button(panel, L("masterClassic"), 120, function()
        app.db.masterAppearance = "classic"
        UI.UpdateMasterSettings(app)
        app:Schedule()
    end)
    panel.classicButton:SetPoint("TOPLEFT", 20, -74)
    panel.modernButton = button(panel, L("masterModern"), 120, function()
        app.db.masterAppearance = "modern"
        UI.UpdateMasterSettings(app)
        app:Schedule()
    end)
    panel.modernButton:SetPoint("TOPLEFT", 150, -74)
    panel.sizeNote = label(panel, 20, -111, 540)
    panel.sizeNote:SetText(L("sizeNote"))

    panel.widthControl = settingsSlider(panel, "QuestTargetsMasterWidthSlider", "masterScaleX", 0.5, 2, 0.05, app)
    panel.heightControl = settingsSlider(panel, "QuestTargetsMasterHeightSlider", "masterScaleY", 0.5, 2, 0.05, app)
    panel.modernScaleControl = settingsSlider(panel, "QuestTargetsMasterScaleSlider", "masterModernScale", 0.5, 2, 0.05, app)

    panel.captionText = label(panel, 20, -246, 540, "GameFontNormal")
    panel.captionText:SetText(L("caption"))
    panel.textEdit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    panel.textEdit:SetSize(335, 24)
    panel.textEdit:SetPoint("TOPLEFT", 20, -274)
    panel.textEdit:SetAutoFocus(false)
    panel.textEdit:SetMaxLetters(48)
    local function saveText(self)
        local value = NS.Core.Clean(self:GetText())
        app.db.masterText = value
        self:ClearFocus()
        UI.UpdateMasterSettings(app)
        app:Schedule()
    end
    panel.textEdit:SetScript("OnEnterPressed", saveText)
    panel.textEdit:SetScript("OnEditFocusLost", saveText)
    panel.textEdit:SetScript("OnEscapePressed", function(self)
        self:SetText(app.db.masterText)
        self:ClearFocus()
    end)
    panel.emptyCaption = label(panel, 20, -314, 540)
    panel.emptyCaption:SetText(L("emptyCaption"))
    UI.UpdateMasterSettings(app)
end

function UI.UpdateMasterSettings(app)
    local panel = UI.masterSettings
    if not panel then return end
    local modern = app.db.masterAppearance == "modern"
    panel.appearanceText:SetText(L("masterAppearance"))
    panel.classicButton:SetEnabled(modern)
    panel.modernButton:SetEnabled(not modern)
    panel.widthControl:SetShown(not modern)
    panel.heightControl:SetShown(not modern)
    panel.modernScaleControl:SetShown(modern)
    if panel.captionGroup then panel.captionGroup:SetShown(not modern) end
    if panel.dimensionsGroup then
        panel.dimensionsGroup:SetHeight(modern and 130 or 220)
        panel:SetHeight(modern and 300 or 538)
    end
    panel.textEdit:SetShown(not modern)
    panel.emptyCaption:SetShown(not modern)
    panel.widthControl.caption:SetText(L("widthLabel"))
    panel.heightControl.caption:SetText(L("heightLabel"))
    panel.modernScaleControl.caption:SetText(L("scaleFactor"))
    panel.widthControl:Refresh()
    panel.heightControl:Refresh()
    panel.modernScaleControl:Refresh()
    if not panel.textEdit:HasFocus() then panel.textEdit:SetText(app.db.masterText) end
end

function UI.UpdateSettings(app)
    if not UI.settings then return end
    UI.settings.toggle:SetChecked(app.db.autoMark)
    UI.settings.selection:SetText(string.format(L("marker"), UI.settings.names[app.db.markerIcon]))
    UI.settings.masterToggle:SetChecked(not app.db.masterHidden)
    local menuShown = app.pendingVisibility
    if menuShown == nil then menuShown = not app.db.hidden end
    UI.settings.menuToggle:SetChecked(menuShown)
    UI.settings.transparencyToggle:SetChecked(app.db.transparencyMode)
    UI.settings.scaleLabel:SetText(L("windowSize"))
    UI.settings.scaleControl:Refresh()
    UI.settings.tooltipToggle:SetChecked(app.db.showTooltips)
    UI.settings.minimapToggle:SetChecked(not app.db.minimapHidden)
    local key = GetBindingKey and GetBindingKey("CLICK QuestTargetsMaster:LeftButton")
    if not UI.settings.hotkey.listening then UI.settings.hotkey:SetText(key or L("unbound")) end
    UIDropDownMenu_SetSelectedID(UI.settings.languageDropdown, NS.Language())
    UIDropDownMenu_SetText(UI.settings.languageDropdown, NS.LANGUAGE_NAMES[NS.Language()])
    for index, choice in ipairs(UI.settings.icons) do choice:SetEnabled(index ~= app.db.markerIcon) end
end

function UI.ApplyLanguage(app)
    -- Forever may not preserve newly written SavedVariables across /reload.
    -- Refresh existing native controls immediately instead of reloading the UI.
    if InCombatLockdown() then return end
    if UI.frame then
        UI.frame.TitleContainer.TitleText:SetText(L("title"))
        UI.settingsButton:SetText(L("settings"))
        UI.refreshButton:SetText(L("refresh"))
        UI.feedbackButton:SetText(L("feedback"))
    end
    local panel = UI.settings
    if panel then
        panel.titleText:SetText(L("title"))
        if panel.tabs then
            for _, tab in ipairs(panel.tabs) do tab:SetText(L(tab.localeKey)) end
            for _, group in ipairs(panel.groups) do group.heading:SetText(L(group.localeKey)) end
            panel.hotkeyAction:SetText(L("masterDefault"))
            panel:ResizeTabs()
        end
        panel.toggle.caption:SetText(L("autoMark"))
        panel.displayText:SetText(L("display"))
        panel.masterToggle.caption:SetText(L("showMaster"))
        panel.menuToggle.caption:SetText(L("showMenu"))
        panel.transparencyToggle.caption:SetText(L("transparencyMode"))
        panel.tooltipToggle.caption:SetText(L("showTooltips"))
        panel.minimapToggle.caption:SetText(L("showMinimap"))
        panel.hotkeyNote:SetText(L("hotkeyNote"))
        panel.hotkeyClear:SetText(L("clear"))
        panel.hotkeysText:SetText(L("hotkeys"))
        panel.languageText:SetText(L("language"))
        panel.names = {strsplit(",", L("markers"))}
        for index, choice in ipairs(panel.icons) do
            choice.caption:SetText(panel.names[index])
        end
        UI.UpdateSettings(app)
    end
    if UI.masterSettings then
        UI.masterSettings.titleText:SetText(L("master"))
        UI.masterSettings.classicButton:SetText(L("masterClassic"))
        UI.masterSettings.modernButton:SetText(L("masterModern"))
        UI.masterSettings.sizeNote:SetText(L("sizeNote"))
        UI.masterSettings.captionText:SetText(L("caption"))
        UI.masterSettings.emptyCaption:SetText(L("emptyCaption"))
        UI.UpdateMasterSettings(app)
    end
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
    if not UI.moving then return end
    -- Normally drag-stop runs out of combat; on combat entry do not mutate the panel.
    if InCombatLockdown() then return end
    UI.frame:StopMovingOrSizing()
    UI.moving = false
    local x, y = UI.frame:GetCenter()
    local px, py = UIParent:GetCenter()
    local scale = UI.frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    db.position = {x = x * scale - px, y = y * scale - py}
end

function UI.Tooltip(row)
    if not row.entry or not NS.app.db.showTooltips then return end
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
    GameTooltip:Show()
end

function UI.OpenQuest(entry)
    local questID = entry and entry.questID
    if type(questID) ~= "number" or questID <= 0 then return end
    if type(QuestMapFrame_OpenToQuestDetails) == "function" then
        QuestMapFrame_OpenToQuestDetails(questID)
    elseif QuestUtil and type(QuestUtil.OpenQuestDetails) == "function" then
        QuestUtil.OpenQuestDetails(questID)
    elseif OpenQuestLog and C_QuestLog and C_QuestLog.SetSelectedQuest then
        OpenQuestLog()
        C_QuestLog.SetSelectedQuest(questID)
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

function UI.Render(app)
    assert(not InCombatLockdown(), "Quest Targets: protected update during combat")
    local scale = math.min(1, UIParent:GetHeight() / 410) * app.db.menuScale
    if UI.frame:GetScale() ~= scale then UI.frame:SetScale(scale) end
    local entries = NS.Core.QuestEntries(app.entries)
    app.questEntries = entries
    local maxOffset = math.max(0, #entries - UI.PAGE_SIZE)
    app.scrollOffset = math.max(0, math.min(maxOffset, app.scrollOffset or 0))
    UI.filter:SetText(app.db.watchedOnly and L("tracked") or L("all"))
    UI.scrollbar:SetMinMaxValues(0, maxOffset)
    UI.scrollbar:SetValue(app.scrollOffset)
    UI.scrollbar:SetShown(maxOffset > 0)
    UI.empty:SetText(app.error or (app.db.watchedOnly and L("emptyTracked") or L("emptyAll")))
    UI.empty:SetShown(#entries == 0)
    UI.RenderRows(app)
    UI.UpdateStatus(app)
end

function UI.ScrollQuests(app, delta)
    if InCombatLockdown() or not UI.scrollbar then return end
    local maxOffset = math.max(0, #(app.questEntries or {}) - UI.PAGE_SIZE)
    local nextOffset = math.max(0, math.min(maxOffset, (app.scrollOffset or 0) + delta))
    UI.scrollbar:SetValue(nextOffset)
end

function UI.RenderRows(app)
    assert(not InCombatLockdown(), "Quest Targets: protected scroll during combat")
    local entries = app.questEntries or {}
    for index, row in ipairs(UI.rows) do
        local entry = entries[(app.scrollOffset or 0) + index]
        row:SetAttribute("macrotext1", nil)
        row.entry = entry
        if row.fallbackQuestID ~= (entry and entry.questID) then row.fallbackIndex = nil end
        row.fallbackQuestID = entry and entry.questID
        if entry then
            row:SetAttribute("macrotext1", (NS.Core.EntryMacro(entry, app.db)))
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
            row.number:SetText((app.scrollOffset or 0) + index)
            local progress = entry.total > 0 and (entry.done .. "/" .. entry.total) or L("open")
            row.detail:SetText(string.format(L("detail"), progress, #entry.refs, #entry.nameList))
            row:Show()
        else
            row:Hide()
        end
    end
end

function UI.UpdateStatus(app)
    if UI.database then UI.database:SetText(NS.Database.status) end
end
