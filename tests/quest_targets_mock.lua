-- Strict behavioral mock: checks combat protection, not Blizzard rendering/target choice.
NS = {}; combat = false; timers = {}; frames = {}; messages = {}; SlashCmdList = {}
QUEST_MONSTERS_KILLED = "%s getötet: %d/%d"
local function object(parent)
    return {parent = parent, scripts = {}, events = {}, shown = true, attributes = {}}
end
local methods = {}
local mt = {__index = methods}
local function create(parent) return setmetatable(object(parent), mt) end
local function guard(self)
    assert(not (combat and self.protected), "protected mutation in combat")
end
function methods:SetScript(event, callback)
    assert(not (self.secure and event == "OnClick"), "replaced secure click handler")
    self.scripts[event] = callback
end
function methods:RegisterEvent(event) self.events[event] = true end
function methods:SetAttribute(key, value) guard(self); self.attributes[key] = value end
function methods:SetPoint(...) guard(self); self.point = {...} end
function methods:ClearAllPoints() guard(self); self.point = nil end
function methods:SetSize(w, h) guard(self); self.width = w; self.height = h end
function methods:SetHeight(h) guard(self); self.height = h end
function methods:SetWidth(w) guard(self); self.width = w end
function methods:SetScale(scale) guard(self); self.scale = scale end
function methods:SetEnabled(value) guard(self); assert(type(value) == "boolean"); self.enabled = value end
function methods:SetShown(value) guard(self); assert(type(value) == "boolean"); self.shown = value end
function methods:Show() self:SetShown(true) end
function methods:Hide() self:SetShown(false) end
function methods:IsShown() return self.shown end
function methods:GetHeight() return self.height or 1080 end
function methods:GetWidth() return self.width or 140 end
function methods:GetCenter() return 900, 500 end
function methods:GetScale() return self.scale or 1 end
function methods:GetEffectiveScale() return self.scale or 1 end
function methods:StartMoving() guard(self); self.moving = true end
function methods:StopMovingOrSizing() guard(self); self.moving = false end
function methods:SetText(value) self.text = value end
function methods:GetText() return self.text end
function methods:SetAutoFocus() end
function methods:SetMaxLetters(value) self.maxLetters = value end
function methods:HasFocus() return self.focused == true end
function methods:ClearFocus() self.focused = false end
function methods:SetChecked(value) self.checked = value end
function methods:GetChecked() return self.checked end
function methods:CreateFontString() return create(self) end
function methods:CreateTexture()
    self.textures = self.textures or {}
    local texture = create(self)
    self.textures[#self.textures + 1] = texture
    return texture
end
function methods:SetAllPoints() end
function methods:SetAlpha(value) self.alpha = value end
function methods:GetAlpha() return self.alpha or 1 end
function methods:SetNormalTexture(asset)
    assert(type(asset) == 'string', 'SetNormalTexture requires an asset')
    self.normalTexture = self.normalTexture or create(self)
    self.normalTexture.texture = asset
end
function methods:SetPushedTexture(asset)
    assert(type(asset) == 'string', 'SetPushedTexture requires an asset')
    self.pushedTexture = self.pushedTexture or create(self)
    self.pushedTexture.texture = asset
end
function methods:SetHighlightTexture(asset)
    assert(type(asset) == 'string', 'SetHighlightTexture requires an asset')
    self.highlight = self.highlight or create(self)
    self.highlight.texture = asset
end
function methods:GetNormalTexture() return self.normalTexture end
function methods:GetPushedTexture() return self.pushedTexture end
function methods:GetTexture() return self.texture end
function methods:GetAtlas() return self.atlas end
function methods:SetTexCoord(...) self.texCoords = {...} end
function methods:GetTexCoord() return unpack(self.texCoords or {0, 0.625, 0, 0.6875}) end
function methods:EnableKeyboard() end
function methods:SetPropagateKeyboardInput() end
function methods:SetTexture(texture)
    assert(texture and (texture:match('^Interface\\TargetingFrame\\UI%-RaidTargetingIcon_[1-8]$')
        or texture:match('^Interface\\Buttons\\UI%-Panel%-Button%-')
        or texture:match('^Interface\\Common\\dark%-goldframe%-button')))
    self.texture = texture
end
function methods:SetAtlas(atlas)
    assert(atlas == "UI-QuestPoi-QuestNumber-SuperTracked" or atlas == "UI-QuestPoi-QuestNumber"
        or atlas == "UI-QuestPoi-InnerGlow" or atlas == "UI-QuestPoiImportant-QuestBang", atlas)
    self.atlas = atlas
end
function methods:SetHighlightAtlas(atlas)
    assert(atlas == "UI-QuestPoi-InnerGlow")
    self.highlight = create(self)
end
function methods:GetHighlightTexture() return self.highlight end
function methods:RegisterForClicks(...) self.clicks = {...} end
function methods:SetFrameStrata() guard(self) end
function methods:SetFrameLevel() guard(self) end
function methods:SetClampedToScreen() guard(self) end
function methods:SetMovable() guard(self) end
function methods:EnableMouse() guard(self) end
function methods:RegisterForDrag() guard(self) end
function methods:SetJustifyH() end
function methods:SetTextColor() end
function methods:SetOwner() end
function methods:AddLine() end
UIParent = create()
Minimap = create(UIParent)
Minimap:SetSize(140, 140)
ActionButton12 = create(UIParent)
ActionButton12:SetSize(36, 36)
cursorX, cursorY = 830, 430
function GetCursorPosition() return cursorX, cursorY end
GameTooltip = create()
Settings = {RegisterCanvasLayoutCategory = function(panel, name) return {ID=42, panel=panel, name=name, GetID=function(self) return self.ID end} end,
    RegisterCanvasLayoutSubcategory = function(parent, panel, name)
        assert(parent.ID == 42)
        return {ID=43, panel=panel, name=name, GetID=function(self) return self.ID end}
    end,
    RegisterAddOnCategory = function() end, OpenToCategory = function(category)
        assert(type(category) == 'number', 'Settings.OpenToCategory requires a numeric category ID')
        _G.openCategory = category
    end}
function GetBindingKey(action) return _G.bindings and _G.bindings[action] end
function SetBinding(key) for action, bound in pairs(_G.bindings or {}) do if bound == key then _G.bindings[action] = nil end end; return true end
function SetBindingClick(key, button, mouse) _G.bindings = _G.bindings or {}; _G.bindings['CLICK '..button..':'..mouse] = key; return true end
function SaveBindings() return true end
function GetCurrentBindingSet() return 1 end
ctrlDown, altDown, shiftDown = false, false, false
function IsControlKeyDown() return ctrlDown end
function IsAltKeyDown() return altDown end
NineSliceUtil = {ApplyLayoutByName = function(frame, name) assert(frame and name == "ButtonFrameTemplateNoPortrait") end}
function CreateFrame(kind, name, parent, template)
    assert(not combat, "created frame during combat")
    local f = create(parent)
    f.template = template
    if template == "SecureActionButtonTemplate" or template == "UIPanelButtonTemplate,SecureActionButtonTemplate" then
        f.secure = true
        if template == "UIPanelButtonTemplate,SecureActionButtonTemplate" then
            f.Left, f.Middle, f.Right = create(f), create(f), create(f)
            f.highlight = create(f)
        end
        local p = f
        while p and p ~= UIParent do p.protected = true; p = p.parent end
    elseif template == "DefaultPanelFlatTemplate" then
        f.TitleContainer = {TitleText = create()}; f.NineSlice = create()
    else
        assert(template == nil or template == "UIPanelButtonTemplate" or template == "UIPanelCloseButtonNoScripts" or template == "UICheckButtonTemplate" or template == "InputBoxTemplate" or template == "UIDropDownMenuTemplate", template)
    end
    if name then _G[name] = f end
    frames[#frames + 1] = f
    return f
end
function InCombatLockdown() return combat end
function issecretvalue(value) return value == SECRET end
SECRET = {}
function print(text) messages[#messages + 1] = text end
function IsShiftKeyDown() return shiftDown end
targetName = "Waldwolf"; targetDead = false; targetPlayer = false; targetAttackable = true
function UnitName() return targetName end
function UnitIsPlayer() return targetPlayer end
function UnitIsDeadOrGhost() return targetDead end
function UnitCanAttack() return targetAttackable end
local tickers = {}
C_Timer = {
    After = function(_, callback) timers[#timers + 1] = callback end,
    NewTicker = function(_, callback) tickers[#tickers + 1] = callback; return {} end,
}
function tick() for _, callback in ipairs(tickers) do callback() end end
function flush()
    local pending = timers; timers = {}
    for _, callback in ipairs(pending) do callback() end
end
function event(name, ...)
    for _, frame in ipairs(frames) do
        if frame.events[name] and frame.scripts.OnEvent then frame.scripts.OnEvent(frame, name, ...) end
    end
end
quests = {
    {questID = 1, title = "Wölfe im Wald", watched = true,
        objectives = {{type = "monster", text = "Waldwolf getötet: 2/8", numFulfilled = 2, numRequired = 8, finished = false}}},
    {questID = 2, title = "Warme Felle", watched = false,
        objectives = {{type = "item", text = "Wolfsfell: 1/4", numFulfilled = 1, numRequired = 4, finished = false}}},
}
C_QuestLog = {
    ReadyForTurnIn = function(id)
        for _, quest in ipairs(quests) do if quest.questID == id then return quest.ready == true end end
    end,
    GetNumQuestLogEntries = function() return #quests end,
    GetInfo = function(index) return quests[index] end,
    GetQuestObjectives = function(id)
        for _, quest in ipairs(quests) do if quest.questID == id then return quest.objectives end end
    end,
    GetQuestWatchType = function(id)
        for _, quest in ipairs(quests) do if quest.questID == id and quest.watched then return 0 end end
    end,
}
function boot()
    event("ADDON_LOADED", "QuestTargets"); event("PLAYER_LOGIN"); flush()
end

function GetLocale() return 'deDE' end
function strsplit(separator, value)
    local parts = {}
    for part in (value .. separator):gmatch('(.-)' .. separator) do parts[#parts + 1] = part end
    return unpack(parts)
end
function ReloadUI() reloaded = true end
openedQuestIDs = {}
function QuestMapFrame_OpenToQuestDetails(questID)
    openedQuestIDs[#openedQuestIDs + 1] = questID
end
function UIDropDownMenu_SetWidth(dropdown, width) dropdown.width = width end
function UIDropDownMenu_Initialize(dropdown, callback) dropdown.initialize = callback end
function UIDropDownMenu_CreateInfo() return {} end
function UIDropDownMenu_AddButton(info)
    _G.dropdownChoices = _G.dropdownChoices or {}
    _G.dropdownChoices[#_G.dropdownChoices + 1] = info
end
function UIDropDownMenu_SetSelectedID(dropdown, id) dropdown.selectedID = id end
function UIDropDownMenu_SetText(dropdown, value) dropdown.text = value end
Enum = {TooltipDataLineType = {QuestTitle=17, QuestPlayer=18, QuestObjective=8}}
nameplates = {}; units = {}; tooltipCalls = 0
C_NamePlate = {GetNamePlates = function() return nameplates end}
C_TooltipInfo = {GetUnit = function(unit)
    assert(not combat, 'tooltip scan during combat')
    assert(unit ~= 'target' and unit ~= 'mouseover', 'requires preselecting/hovering a mob')
    tooltipCalls = tooltipCalls + 1
    if units[unit] and units[unit].throws then error('restricted by client') end
    return units[unit] and units[unit].data
end}
local function unitData(unit)
    if unit == 'target' and currentGUID then
        for token, data in pairs(units) do
            if (data.guid or token) == currentGUID then return data end
        end
    end
    return units[unit]
end
function methods:SetColorTexture(...) self.color = {...} end
function UnitExists(unit) return unitData(unit) ~= nil end
function UnitGUID(unit) return unit == 'target' and currentGUID or (units[unit] and (units[unit].guid or unit)) end
function UnitName(unit) local data = unitData(unit); return data and data.name end
function UnitIsPlayer(unit) local data = unitData(unit); return data and data.player or false end
function UnitIsDeadOrGhost(unit) local data = unitData(unit); return data and data.dead or false end
function UnitCanAttack(_, unit) local data = unitData(unit); return data and not data.friendly or false end
function SetRaidTarget(unit, icon)
    assert(unit == 'target' and UnitExists(unit) and not UnitIsPlayer(unit))
    markedTarget = {guid = UnitGUID(unit), icon = icon}
end
function GetRaidTargetIndex(unit)
    return markedTarget and markedTarget.guid == UnitGUID(unit) and markedTarget.icon or nil
end
function plate(name, title, objective)
    local unit = 'nameplate' .. tostring(#nameplates + 1)
    nameplates[#nameplates + 1] = {namePlateUnitToken=unit}
    units[unit] = {name=name, data={lines={
        {type=2,leftText=name}, {type=17,leftText=title},
        {type=8,leftText=objective,completed=false},
    }}}
    return units[unit]
end
