local addonName, NS = ...
local UI, L = NS.UI, NS.L
local Tutorial = {}
NS.Tutorial = Tutorial

local TEXTURE = "Interface\\AddOns\\" .. addonName .. "\\Textures\\TutorialMrrml"
local WIDTH, HEIGHT = 414, 244
local panel, app, step, steps, afterIntro, previousScroll

local function movePointer(self, elapsed)
    local target = self.target
    if not target or not target:IsVisible() then self:SetAlpha(0); return end
    local x, y = target:GetCenter()
    if not x or not y then return end
    self:SetAlpha(1)
    local scale = self.targetFrame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    x, y = x * scale, y * scale
    local side = x + 60 < UIParent:GetWidth() and 1 or -1
    local vertical = y > 60 and -1 or 1
    if self.side ~= side or self.vertical ~= vertical then
        local left, top = side == 1 and 0 or 1, vertical == -1 and 0 or 1
        self.hand:SetTexCoord(left, 1 - left, top, 1 - top)
        self.side, self.vertical = side, vertical
    end
    self.bounce = (self.bounce + elapsed * 3.4) % math.pi
    local jump = math.sin(self.bounce) * 12
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
        x + side * (target:GetWidth() * scale * 0.42 + 12 + jump * 0.45),
        y + vertical * (target:GetHeight() * scale * 0.42 + 9 + jump))
end

function Tutorial.Initialize(existingCharacter)
    if type(QuestTargetsNewsDB) ~= "table" then QuestTargetsNewsDB = {} end
    local news = QuestTargetsNewsDB
    if not news.onboarding then
        news.onboarding = (existingCharacter or news.seenVersion) and "done" or "pending"
    end
end

local function setButton(button, label, action)
    button:SetShown(label ~= nil)
    if label then
        button:SetText(L(label))
        button:SetScript("OnClick", action)
    end
end

local function render()
    local actions = steps[step]
    panel.text:SetText(L(actions.text))
    panel.title:SetShown(step == "welcome")
    panel.close:SetShown(step ~= "farewell")
    setButton(panel.primary, actions.primary, actions.advance)
    setButton(panel.secondary, actions.secondary, actions.alternate)
    if actions.primary then
        panel.primary:ClearAllPoints()
        panel.primary:SetPoint("CENTER", panel.bubble, "CENTER", actions.secondary and -72 or 0, -46)
    end
    if actions.secondary then
        panel.secondary:ClearAllPoints()
        panel.secondary:SetPoint("CENTER", panel.bubble, "CENTER", actions.primary and 72 or 0, -46)
    end
    local pointer = panel.pointer
    local row = step == "practice" and UI.rows and UI.rows[1]
    if row and row.entry and row.entry.tutorial then
        pointer.target, pointer.targetFrame = row.icon, row
    elseif step == "optional" and UI.master and UI.master:IsShown() then
        pointer.target, pointer.targetFrame = UI.master, UI.master
    else
        pointer.target, pointer.targetFrame = nil, nil
    end
    pointer:SetShown(pointer.target ~= nil)
    local bindingStep = step == "optional" or step == "bind"
    panel.key:SetShown(bindingStep)
    panel.keyGlow:SetShown(bindingStep)
    panel.keyGlow:SetBackdropBorderColor(1, 0.78, 0.24, panel.key.listening and 1 or 0.74)
    if bindingStep then
        local text, bound = UI.MasterBindingText()
        if not panel.key.listening then panel.key:SetText(text) end
        panel.primary:SetEnabled(bound and not panel.key.listening)
    else
        panel.primary:SetEnabled(true)
    end
end

local function showStep(nextStep)
    step = nextStep
    render()
end

local function clearPracticeQuest()
    app.tutorialQuest = nil
    app.scrollOffset = previousScroll
    UI.Render(app)
end

local function finish(keepOpen)
    if InCombatLockdown() then return end
    UI.CancelBindingAssignment()
    if step == "practice" or step == "celebrate" then
        if app.tutorialQuest then clearPracticeQuest() end
        if type(keepOpen) == "boolean" then app.db.hidden = not keepOpen end
        UI.RestorePosition(app.db)
        UI.frame:SetShown(not app.db.hidden)
        if type(keepOpen) == "boolean" then showStep("farewell"); return end
    end
    QuestTargetsNewsDB.onboarding = "done"
    step = nil
    panel.pointer:Hide()
    panel:Hide()
    local callback = afterIntro
    afterIntro = nil
    if callback then callback() end
end

local function showMasterButton()
    if InCombatLockdown() then return end
    app.db.hotkeysOnly, app.db.masterHidden = false, false
    app:Refresh(false)
    showStep("optional")
end

local function practice(hotkeysOnly)
    if InCombatLockdown() then return end
    UI.CancelBindingAssignment()
    if not UI.frame then app:Refresh() end
    if not UI.frame then return end
    if hotkeysOnly then
        local _, bound = UI.MasterBindingText()
        if not bound then return end
    end
    app.db.hotkeysOnly = hotkeysOnly
    app.db.masterHidden = hotkeysOnly
    previousScroll = app.scrollOffset
    app.scrollOffset = 0
    app.tutorialQuest = true
    UI.frame:ClearAllPoints()
    UI.frame:SetPoint("CENTER", UIParent, "CENTER", 365, 54)
    app:Refresh(false)
    UI.frame:Show()
    showStep("practice")
end

function Tutorial.PracticeClicked()
    if step ~= "practice" or InCombatLockdown() or not UnitIsUnit then return end
    local isPlayer = UnitIsUnit("target", "player")
    if not NS.Core.Readable(isPlayer) or not isPlayer then return end
    clearPracticeQuest()
    showStep("celebrate")
end

function Tutorial.SkipPractice()
    if step == "practice" then
        finish()
    elseif step == "celebrate" then
        finish(false)
    else
        return false
    end
    return true
end

steps = {
    welcome = {text="tutorialWelcome", primary="tutorialYes", advance=function() showStep("choose") end,
        secondary="tutorialSkip", alternate=finish},
    choose = {text="tutorialChoose", primary="tutorialButton", advance=showMasterButton,
        secondary="tutorialKeyOnly", alternate=function() showStep("bind") end},
    optional = {text="tutorialOptional", primary="tutorialContinue", advance=function() practice(false) end,
        secondary="tutorialWithoutKey", alternate=function() practice(false) end},
    bind = {text="tutorialBind", primary="tutorialContinue", advance=function() practice(true) end,
        secondary="tutorialBack", alternate=function() showStep("choose") end},
    practice = {text="tutorialPractice", secondary="tutorialSkip", alternate=finish},
    celebrate = {text="tutorialCelebrate", primary="tutorialKeepOpen", advance=function() finish(true) end,
        secondary="tutorialCloseList", alternate=function() finish(false) end},
    farewell = {text="tutorialFarewell", primary="tutorialFinish", advance=finish},
}

local function button(parent, width)
    local control = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    control:SetSize(width, 24)
    return control
end

local function createPanel()
    local window = CreateFrame("Frame", "QuestTargetsTutorial", UIParent)
    window:SetSize(WIDTH, HEIGHT)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    local bubble = window:CreateTexture(nil, "ARTWORK")
    bubble:SetTexture(TEXTURE)
    bubble:SetTexCoord(0.5, 1, 0, 1)
    bubble:SetPoint("CENTER")
    bubble:SetSize(WIDTH, HEIGHT)
    local mrrml = window:CreateTexture(nil, "ARTWORK")
    mrrml:SetTexture(TEXTURE)
    mrrml:SetTexCoord(0.5, 0, 0, 1)
    mrrml:SetSize(112, 138)
    mrrml:SetPoint("RIGHT", bubble, "BOTTOMLEFT", 3, -16)
    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("BOTTOM", bubble, "TOP", 0, 9)
    title:SetText("Next! Intro")
    local text = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("CENTER", bubble, "CENTER", 0, 37)
    text:SetWidth(272)
    text:SetJustifyH("CENTER")
    text:SetTextColor(0.22, 0.10, 0.04)
    text:SetShadowColor(0, 0, 0, 0)
    window.text, window.bubble, window.mrrml, window.title = text, bubble, mrrml, title
    window.primary = button(window, 140)
    window.secondary = button(window, 140)
    window.key = button(window, 166)
    window.key:SetPoint("CENTER", bubble, "CENTER", 0, -13)
    window.key:SetScript("OnClick", function(self)
        UI.BeginMasterBinding(self, app, render)
        render()
    end)
    local glow = CreateFrame("Frame", nil, window.key, "BackdropTemplate")
    glow:SetPoint("TOPLEFT", -3, 3)
    glow:SetPoint("BOTTOMRIGHT", 3, -3)
    glow:EnableMouse(false)
    glow:SetBackdrop({edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=10})
    window.keyGlow = glow
    local close = CreateFrame("Button", nil, window, "UIPanelCloseButtonNoScripts")
    close:SetSize(20, 20)
    close:SetPoint("LEFT", bubble, "TOPRIGHT", -10, -14)
    close:SetScript("OnClick", finish)
    window.close = close
    local pointer = CreateFrame("Frame", nil, UIParent)
    pointer:SetSize(36, 36)
    pointer:SetFrameStrata("TOOLTIP")
    pointer:EnableMouse(false)
    pointer.bounce = 0
    local hand = pointer:CreateTexture(nil, "ARTWORK")
    hand:SetAllPoints(pointer)
    hand:SetTexture("Interface\\Cursor\\Point")
    pointer.hand = hand
    pointer:SetScript("OnUpdate", movePointer)
    pointer:Hide()
    window.pointer = pointer
    return window
end

function Tutorial.Open(activeApp)
    if InCombatLockdown() or step or not activeApp.db then return end
    app = activeApp
    if not panel then panel = createPanel() end
    panel:SetScale(math.min(1, UIParent:GetWidth() / 900, UIParent:GetHeight() / 500))
    showStep("welcome")
    panel:Show()
end

function Tutorial.OnLogin(activeApp, callback)
    if QuestTargetsNewsDB.onboarding == "done" then callback(); return end
    afterIntro = callback
    C_Timer.After(0.35, function()
        if afterIntro then Tutorial.Open(activeApp) end
    end)
end

function Tutorial.OnCombat()
    if step then
        panel.pointer:Hide()
        panel:Hide()
    end
end

function Tutorial.OnRegen(activeApp)
    if step then
        render()
        panel:Show()
    elseif afterIntro then
        Tutorial.Open(activeApp)
    end
end

function Tutorial.RefreshLanguage()
    if step then render() end
end
