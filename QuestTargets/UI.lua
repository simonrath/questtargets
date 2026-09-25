local _, NS = ...
local UI = {}
NS.UI = UI
local L = NS.L
UI.PAGE_SIZE = 6

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
    close:SetPoint("TOPRIGHT", 0, 0)
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

    UI.filter = button(frame, L("all"), 116, function() app:ToggleFilter() end)
    UI.filter:SetPoint("TOPLEFT", 10, -30)
    UI.database = label(frame, 132, -35, 113)
    local help = button(frame, "?", 24, function() app:Help() end)
    help:SetPoint("TOPRIGHT", -10, -30)
    UI.summary = label(frame, 10, -56, 260)
    UI.rows = {}
    for index = 1, UI.PAGE_SIZE do
        local row = CreateFrame("Button", "QuestTargetsTarget" .. index, frame, "SecureActionButtonTemplate")
        row:SetPoint("TOPLEFT", 10, -76 - (index - 1) * 39)
        row:SetSize(262, 36)
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
        -- Native ModernUI quest icon and highlight, no bundled or generated textures.
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(22, 22)
        row.icon:SetPoint("LEFT", 1, 0)
        row.icon:SetAtlas("UI-QuestPoi-QuestNumber-SuperTracked")
        row.number = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.number:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
        row.number:SetText(index)
        row:SetHighlightAtlas("UI-QuestPoi-InnerGlow")
        local highlight = row:GetHighlightTexture()
        highlight:ClearAllPoints()
        highlight:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
        highlight:SetSize(28, 28)
        row.nameText = label(row, 29, -1, 228, "GameFontNormal")
        row.nameText:SetHeight(16)
        row.detail = label(row, 29, -19, 228)
        row.detail:SetHeight(13)
        row:SetScript("OnEnter", function(self) UI.Tooltip(self) end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:Hide()
        UI.rows[index] = row
    end
    UI.empty = label(frame, 14, -112, 254, "GameFontHighlight")
    UI.empty:SetJustifyH("CENTER")
    UI.empty:SetHeight(100)
    UI.previous = button(frame, "<", 28, function() app:Page(-1) end)
    UI.previous:SetPoint("BOTTOMLEFT", 10, 61)
    UI.next = button(frame, ">", 28, function() app:Page(1) end)
    UI.next:SetPoint("BOTTOMRIGHT", -10, 61)
    UI.page = label(frame, 110, -331, 62)
    UI.page:SetJustifyH("CENTER")
    UI.settingsButton = button(frame, L("settings"), 94, function() UI.Settings(app) end)
    UI.settingsButton:SetPoint("BOTTOMLEFT", 42, 61)
    UI.refreshButton = button(frame, L("refresh"), 94, function() app:Refresh() end)
    UI.refreshButton:SetPoint("BOTTOMRIGHT", -42, 61)
    UI.status = label(frame, 10, -350, 262)
    UI.status:SetHeight(28)
    frame:SetShown(not app.db.hidden)
end

function UI.Settings(app)
    if not app.db or InCombatLockdown() then return end
    if not UI.settings then
        local panel = CreateFrame("Frame", "QuestTargetsSettings")
        UI.settings = panel
        panel:SetSize(600, 640)
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
        panel.markerNote = label(panel, 20, -221, 500)
        panel.markerNote:SetHeight(48)
        panel.markerNote:SetText(L("markerNote"))
        panel.displayText = label(panel, 20, -262, 330, "GameFontNormal")
        panel.displayText:SetText(L("display"))
        panel.masterToggle = checkbox(panel, L("showMaster"), function()
            app.db.masterHidden = not app.db.masterHidden
            app:Schedule(); UI.UpdateSettings(app)
        end)
        panel.masterToggle:SetPoint("TOPLEFT", 20, -282)
        panel.menuToggle = checkbox(panel, L("showMenu"), function()
            app:Toggle(); UI.UpdateSettings(app)
        end)
        panel.menuToggle:SetPoint("TOPLEFT", 20, -312)
        panel.scaleLabel = label(panel, 65, -430, 240)
        panel.scaleLabel:SetJustifyH("CENTER")
        panel.smaller = button(panel, "–", 35, function()
            app.db.menuScale = math.max(0.5, app.db.menuScale - 0.1)
            app:Schedule(); UI.UpdateSettings(app)
        end)
        panel.smaller:SetPoint("TOPLEFT", 20, -424)
        panel.larger = button(panel, "+", 35, function()
            app.db.menuScale = math.min(1.5, app.db.menuScale + 0.1)
            app:Schedule(); UI.UpdateSettings(app)
        end)
        panel.larger:SetPoint("TOPLEFT", 320, -424)
        panel.tooltipToggle = checkbox(panel, L("showTooltips"), function()
            app.db.showTooltips = not app.db.showTooltips
            UI.UpdateSettings(app)
        end)
        panel.tooltipToggle:SetPoint("TOPLEFT", 20, -342)
        panel.minimapToggle = checkbox(panel, L("showMinimap"), function()
            app.db.minimapHidden = not app.db.minimapHidden
            if UI.minimap then UI.minimap:SetShown(not app.db.minimapHidden) end
            UI.UpdateSettings(app)
        end)
        panel.minimapToggle:SetPoint("TOPLEFT", 20, -372)
        panel.hotkey = button(panel, "", 200, function(self)
            if InCombatLockdown() then return end
            self.listening = true
            self:SetText(L("pressKey"))
            self:EnableKeyboard(true)
            self:SetPropagateKeyboardInput(false)
        end)
        panel.hotkey:SetPoint("TOPLEFT", 20, -467)
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
        panel.hotkeyClear:SetPoint("TOPLEFT", 225, -467)
        panel.masterConfigButton = button(panel, L("editMaster"), 200, function()
            if UI.masterSettingsCategoryID then Settings.OpenToCategory(UI.masterSettingsCategoryID) end
        end)
        panel.masterConfigButton:SetPoint("TOPLEFT", 20, -531)
        panel:SetScript("OnHide", function()
            panel.hotkey.listening = false
            panel.hotkey:EnableKeyboard(false)
        end)
        panel.hotkeyNote = label(panel, 20, -500, 520)
        panel.hotkeyNote:SetText(L("hotkeyNote"))
        panel.languageText = label(panel, 20, -560, 330, "GameFontNormal")
        panel.languageText:SetText(L("language"))
        panel.languageDropdown = CreateFrame("Frame", "QuestTargetsLanguageDropdown", panel, "UIDropDownMenuTemplate")
        panel.languageDropdown:SetPoint("TOPLEFT", 0, -580)
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
        if Settings and Settings.RegisterCanvasLayoutCategory then
            local category = Settings.RegisterCanvasLayoutCategory(panel, "Quest Targets")
            Settings.RegisterAddOnCategory(category)
            UI.settingsCategoryID = category:GetID()
            UI.CreateMasterSettings(app, category)
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
    if not Settings.RegisterCanvasLayoutSubcategory then return end
    local panel = CreateFrame("Frame", "QuestTargetsMasterSettings")
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

    local function sizeControl(axis, y)
        local key = axis == "X" and "masterScaleX" or "masterScaleY"
        local field = {caption = label(panel, 20, y, 240, "GameFontNormal")}
        field.smaller = button(panel, "–", 35, function()
            app.db[key] = math.max(0.5, math.floor((app.db[key] - 0.1) * 10 + 0.5) / 10)
            app:Schedule(); UI.UpdateMasterSettings(app)
        end)
        field.smaller:SetPoint("TOPLEFT", 265, y + 4)
        field.larger = button(panel, "+", 35, function()
            app.db[key] = math.min(2, math.floor((app.db[key] + 0.1) * 10 + 0.5) / 10)
            app:Schedule(); UI.UpdateMasterSettings(app)
        end)
        field.larger:SetPoint("TOPLEFT", 335, y + 4)
        return field
    end
    panel.widthControl = sizeControl("X", -150)
    panel.heightControl = sizeControl("Y", -189)
    panel.modernScaleControl = {caption = label(panel, 20, -150, 240, "GameFontNormal")}
    panel.modernScaleControl.smaller = button(panel, "–", 35, function()
        app.db.masterModernScale = math.max(0.5, math.floor((app.db.masterModernScale - 0.1) * 10 + 0.5) / 10)
        UI.UpdateMasterSettings(app); app:Schedule()
    end)
    panel.modernScaleControl.smaller:SetPoint("TOPLEFT", 265, -146)
    panel.modernScaleControl.larger = button(panel, "+", 35, function()
        app.db.masterModernScale = math.min(2, math.floor((app.db.masterModernScale + 0.1) * 10 + 0.5) / 10)
        UI.UpdateMasterSettings(app); app:Schedule()
    end)
    panel.modernScaleControl.larger:SetPoint("TOPLEFT", 335, -146)

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
    local subcategory = Settings.RegisterCanvasLayoutSubcategory(category, panel, L("master"))
    UI.masterSettingsCategoryID = subcategory:GetID()
    UI.UpdateMasterSettings(app)
end

function UI.UpdateMasterSettings(app)
    local panel = UI.masterSettings
    if not panel then return end
    local modern = app.db.masterAppearance == "modern"
    panel.appearanceText:SetText(L("masterAppearance"))
    panel.classicButton:SetEnabled(modern)
    panel.modernButton:SetEnabled(not modern)
    panel.sizeNote:SetShown(not modern)
    for _, field in ipairs({panel.widthControl, panel.heightControl}) do
        field.caption:SetShown(not modern)
        field.smaller:SetShown(not modern)
        field.larger:SetShown(not modern)
    end
    panel.modernScaleControl.caption:SetShown(modern)
    panel.modernScaleControl.smaller:SetShown(modern)
    panel.modernScaleControl.larger:SetShown(modern)
    panel.modernScaleControl.caption:SetText(string.format(L("masterModernScale"), app.db.masterModernScale * 100))
    panel.captionText:SetShown(not modern)
    panel.textEdit:SetShown(not modern)
    panel.emptyCaption:SetShown(not modern)
    panel.widthControl.caption:SetText(string.format(L("width"), app.db.masterScaleX * 100))
    panel.heightControl.caption:SetText(string.format(L("height"), app.db.masterScaleY * 100))
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
    UI.settings.scaleLabel:SetText(string.format(L("menuScale"), app.db.menuScale * 100))
    UI.settings.tooltipToggle:SetChecked(app.db.showTooltips)
    UI.settings.minimapToggle:SetChecked(not app.db.minimapHidden)
    local key = GetBindingKey and GetBindingKey("CLICK QuestTargetsMaster:LeftButton")
    UI.settings.hotkey:SetText(string.format(L("hotkey"), key or L("unbound")))
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
    end
    local panel = UI.settings
    if panel then
        panel.titleText:SetText(L("title"))
        panel.toggle.caption:SetText(L("autoMark"))
        panel.markerNote:SetText(L("markerNote"))
        panel.displayText:SetText(L("display"))
        panel.masterToggle.caption:SetText(L("showMaster"))
        panel.menuToggle.caption:SetText(L("showMenu"))
        panel.tooltipToggle.caption:SetText(L("showTooltips"))
        panel.minimapToggle.caption:SetText(L("showMinimap"))
        panel.hotkeyNote:SetText(L("hotkeyNote"))
        panel.hotkeyClear:SetText(L("clear"))
        panel.masterConfigButton:SetText(L("editMaster"))
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
    GameTooltip:SetText(entry.title or entry.name or L("tooltipUnknown"))
    for _, ref in ipairs(entry.refs) do
        GameTooltip:AddLine(ref.title, 1, 0.82, 0, true)
        GameTooltip:AddLine(ref.text, 1, 1, 1, true)
        if ref.database then GameTooltip:AddLine(L("tooltipDb"), 0.6, 0.8, 1, true) end
        if ref.detected then GameTooltip:AddLine(L("tooltipDetected"), 0.6, 0.8, 1, true) end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L("tooltipRight"), 1, 0.82, 0, true)
    if entry.nameList then
        GameTooltip:AddLine(L("tooltipNames"), 1, 0.82, 0, true)
        for _, name in ipairs(entry.nameList) do GameTooltip:AddLine(name, 1, 1, 1, true) end
    end
    if entry.name then
        GameTooltip:AddLine(L("tooltipClick"), 1, 1, 1, true)
        GameTooltip:AddLine(L("tooltipCycle"), 0.75, 0.75, 0.75, true)
    else
        GameTooltip:AddLine(L("tooltipUnresolved"), 1, 1, 1, true)
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
    end
end

function UI.Render(app)
    assert(not InCombatLockdown(), "Quest Targets: protected update during combat")
    local scale = math.min(1, UIParent:GetHeight() / 410) * app.db.menuScale
    if UI.frame:GetScale() ~= scale then UI.frame:SetScale(scale) end
    local entries, metadata = NS.Core.QuestEntries(app.entries), app.metadata
    app.questEntries = entries
    local pages = math.max(1, math.ceil(#entries / UI.PAGE_SIZE))
    app.page = math.max(1, math.min(pages, app.page))
    UI.filter:SetText(app.db.watchedOnly and L("tracked") or L("all"))
    UI.summary:SetText(string.format(L("summary"), #entries, metadata.objectives))
    UI.page:SetText(string.format("%d / %d", app.page, pages))
    UI.previous:SetEnabled(app.page > 1)
    UI.next:SetEnabled(app.page < pages)
    UI.empty:SetText(app.error or (app.db.watchedOnly and L("emptyTracked") or L("emptyAll")))
    UI.empty:SetShown(#entries == 0)
    for index, row in ipairs(UI.rows) do
        local entry = entries[(app.page - 1) * UI.PAGE_SIZE + index]
        row:SetAttribute("macrotext1", nil)
        row.entry = entry
        if row.fallbackQuestID ~= (entry and entry.questID) then row.fallbackIndex = nil end
        row.fallbackQuestID = entry and entry.questID
        if entry then
            row:SetAttribute("macrotext1", (NS.Core.EntryMacro(entry, app.db)))
            row.nameText:SetText(entry.title)
            row.nameText:SetTextColor(entry.name and 1 or 0.7, entry.name and 0.82 or 0.7, entry.name and 0 or 0.7)
            row.icon:SetAtlas(entry.name and "UI-QuestPoi-QuestNumber-SuperTracked" or "UI-QuestPoi-QuestNumber")
            row.number:SetText((app.page - 1) * UI.PAGE_SIZE + index)
            local progress = entry.total > 0 and (entry.done .. "/" .. entry.total) or L("open")
            row.detail:SetText(string.format(L("detail"), progress, #entry.refs, #entry.nameList))
            row:Show()
        else
            row:Hide()
        end
    end
    UI.UpdateStatus(app)
end

function UI.UpdateStatus(app)
    if not UI.status then return end
    UI.database:SetText(NS.Database.status)
    UI.status:SetText(InCombatLockdown() and L("combat")
        or app.error or (app.metadata.unresolved > 0 and (NS.Scanner.status or L("search"))
        or L("click")))
end
