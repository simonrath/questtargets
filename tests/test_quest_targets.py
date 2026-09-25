"""Behavior tests for the real Lua addon. Requires lupa; no running WoW client."""
from pathlib import Path
import unittest
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]


class QuestTargetsTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute((ROOT / 'tests/quest_targets_mock.lua').read_text(encoding='utf-8'))
        for name in ('Core.lua', 'Locale.lua', 'Database.lua', 'Proximity.lua', 'Resolvers.lua', 'Scanner.lua', 'UI.lua', 'Master.lua', 'Main.lua'):
            self.lua.execute('assert(loadstring(...))("QuestTargets", NS)',
                             (ROOT / 'QuestTargets' / name).read_text(encoding='utf-8'))

    def test_compact_window_keeps_position_on_refresh_filter_and_page(self):
        self.lua.execute('''boot()
            local frame = NS.UI.frame
            assert(frame.width == 282 and frame.height == 386)
            frame:ClearAllPoints()
            frame:SetPoint('CENTER', UIParent, 'CENTER', 137, -42)
            NS.app.db.position = {x=137,y=-42}
            for i=3,9 do quests[i]={questID=i,title='Quest '..i,objectives={{type='monster',text='Wolf getötet: 0/1',numRequired=1,numFulfilled=0,finished=false}}} end
            NS.app:Refresh()
            assert(frame.point[4] == 137 and frame.point[5] == -42)
            NS.app:Page(1)
            assert(frame.point[4] == 137 and frame.point[5] == -42)
            NS.app:ToggleFilter()
            assert(frame.point[4] == 137 and frame.point[5] == -42)
        ''')

    def test_right_click_opens_exact_quest_in_native_log_without_targeting(self):
        self.lua.execute('''boot()
            local row = QuestTargetsTarget1
            local macro = row.attributes.macrotext1
            row.scripts.PreClick(row, 'RightButton', false)
            row.scripts.PostClick(row, 'RightButton', true)
            assert(#openedQuestIDs == 0)
            row.scripts.PostClick(row, 'RightButton', false)
            assert(#openedQuestIDs == 1 and openedQuestIDs[1] == row.entry.questID)
            assert(row.attributes.macrotext1 == macro)
            assert(NS.Core.lastClick == nil)
            NS.UI.OpenQuest({questID=0})
            assert(#openedQuestIDs == 1)
        ''')

    def test_native_settings_tooltips_minimap_and_hotkey(self):
        self.lua.execute('''boot()
            assert(NS.UI.minimap and NS.UI.minimap.shown)
            assert(not NS.app.db.showTooltips)
            NS.UI.Tooltip(QuestTargetsTarget1)
            assert(GameTooltip.text == nil)
            NS.UI.Settings(NS.app)
            assert(openCategory == 42 and NS.UI.settingsCategoryID == 42)
            assert(NS.UI.settings.template == nil)
            for _, control in ipairs({NS.UI.settings.toggle, NS.UI.settings.masterToggle,
                    NS.UI.settings.menuToggle, NS.UI.settings.tooltipToggle, NS.UI.settings.minimapToggle}) do
                assert(control.template == 'UICheckButtonTemplate')
            end
            assert(NS.UI.settings.toggle:GetChecked())
            assert(NS.UI.settings.masterToggle:GetChecked())
            assert(NS.UI.settings.menuToggle:GetChecked())
            assert(not NS.UI.settings.tooltipToggle:GetChecked())
            assert(NS.UI.settings.minimapToggle:GetChecked())
            NS.UI.settings.tooltipToggle.scripts.OnClick()
            assert(NS.UI.settings.tooltipToggle:GetChecked())
            NS.UI.Tooltip(QuestTargetsTarget1)
            assert(GameTooltip.text == 'Wölfe im Wald')
            NS.UI.settings.minimapToggle.scripts.OnClick()
            assert(not NS.UI.minimap.shown)
            assert(not NS.UI.settings.minimapToggle:GetChecked())
            NS.UI.settings.hotkey.scripts.OnClick(NS.UI.settings.hotkey)
            NS.UI.settings.hotkey.scripts.OnKeyDown(NS.UI.settings.hotkey, 'G')
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == 'G')
            NS.UI.settings.hotkeyClear.scripts.OnClick()
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == nil)
        ''')

    def test_minimap_button_follows_map_edge_and_uses_compass_states(self):
        self.lua.execute('''boot()
            local button=NS.UI.minimap
            assert(button.parent == Minimap)
            assert(button.point[1] == 'CENTER' and button.point[2] == Minimap and button.point[3] == 'CENTER')
            assert(math.abs(button.point[4]) <= 72 and math.abs(button.point[5]) <= 72)
            assert(button.normalTexture.texture:find('QuestCompassUp', 1, true))
            assert(button.pushedTexture.texture:find('QuestCompassDown', 1, true))
            cursorX, cursorY=1000, 500
            button.scripts.OnDragStart(button)
            button.scripts.OnUpdate(button)
            assert(math.abs(button.point[4]-72) < 0.01 and math.abs(button.point[5]) < 0.01)
            button.scripts.OnDragStop(button)
            assert(math.abs(NS.app.db.minimapAngle) < 0.01)
            local shown=NS.UI.frame.shown
            button.scripts.OnClick(button, 'LeftButton')
            assert(NS.UI.frame.shown == shown)
            flush()
            button.scripts.OnClick(button, 'LeftButton')
            assert(NS.UI.frame.shown ~= shown)
        ''')

    def test_modern_master_uses_two_compass_states_and_uniform_scale(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local controls, master = NS.UI.masterSettings, NS.UI.master
            local originalNormal, originalPushed = master.normalTexture, master.pushedTexture
            assert(master.Left:GetAlpha() == 1 and master.Middle:GetAlpha() == 1 and master.Right:GetAlpha() == 1)
            assert(master.normalTexture:GetAlpha() == 0 and master.pushedTexture:GetAlpha() == 0)
            controls.modernButton.scripts.OnClick(); flush()
            assert(NS.app.db.masterAppearance == 'modern')
            assert(master.width == 40 and master.height == 40 and master.text == '')
            assert(master.normalTexture.texture:find('QuestCompassUp', 1, true))
            assert(master.pushedTexture.texture:find('QuestCompassDown', 1, true))
            assert(master.normalTexture:GetAlpha() == 1 and master.pushedTexture:GetAlpha() == 1)
            assert(master.Left:GetAlpha() == 0 and master.Middle:GetAlpha() == 0 and master.Right:GetAlpha() == 0)
            assert(not controls.textEdit.shown and not controls.widthControl.smaller.shown)
            controls.modernScaleControl.larger.scripts.OnClick(); flush()
            assert(master.width == 44 and master.height == 44)
            controls.classicButton.scripts.OnClick(); flush()
            assert(master.width == 140 and master.height == 22 and master.text == 'Target quest objective')
            assert(master.normalTexture == originalNormal and master.pushedTexture == originalPushed)
            assert(master.normalTexture:GetAlpha() == 0 and master.pushedTexture:GetAlpha() == 0)
            assert(master.Left:GetAlpha() == 1 and master.Middle:GetAlpha() == 1 and master.Right:GetAlpha() == 1)
            assert(controls.textEdit.shown and controls.widthControl.smaller.shown)
        ''')

    def test_saved_modern_style_loads_with_native_segmented_template(self):
        self.lua.execute('''QuestTargetsDB={masterAppearance='modern'}; boot()
            local master = NS.UI.master
            assert(master.text == '' and master.width == master.height)
            assert(master.normalTexture:GetAlpha() == 1 and master.pushedTexture:GetAlpha() == 1)
            assert(master.Left:GetAlpha() == 0 and master.Middle:GetAlpha() == 0 and master.Right:GetAlpha() == 0)
            assert(master.classicHighlight:GetAlpha() == 0)
            assert(master.attributes.type1 == 'macro' and master.attributes.macrotext1)
        ''')

    def test_master_stays_freely_positioned_and_keeps_hotkey_target(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local master = NS.UI.master
            assert(master.point[2] == UIParent and master.width == 140)
            assert(NS.UI.settings.actionBarToggle == nil)
            assert(NS.app.db.actionBarMode == nil)
            local macro = master.attributes.macrotext1
            assert(macro and macro:find('Waldwolf',1,true))
            master.scripts.OnDragStart(master)
            assert(master.moving)
            master.scripts.OnDragStop(master)
            assert(master.point[2] == UIParent and master.width == 140)
            assert(master.text == 'Target quest objective')
        ''')

    def test_master_settings_change_independent_size_and_label(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            assert(NS.UI.masterSettingsCategoryID == 43)
            NS.UI.settings.masterConfigButton.scripts.OnClick()
            assert(openCategory == 43)
            local controls, master = NS.UI.masterSettings, NS.UI.master
            controls.widthControl.larger.scripts.OnClick(); flush()
            controls.heightControl.smaller.scripts.OnClick(); flush()
            assert(NS.app.db.masterScaleX == 1.1 and NS.app.db.masterScaleY == 0.9)
            assert(master.width == 154 and master.height == 20)
            assert(controls.textureDropdown == nil)
            assert(NS.app.db.masterTexture == nil)
            controls.textEdit:SetText('Quest-Mobs')
            controls.textEdit.scripts.OnEnterPressed(controls.textEdit); flush()
            assert(NS.app.db.masterText == 'Quest-Mobs' and master.text == 'Quest-Mobs')
            controls.textEdit:SetText('')
            controls.textEdit.scripts.OnEnterPressed(controls.textEdit); flush()
            assert(NS.app.db.masterText == '' and master.text == '')
            NS.app:Refresh()
            assert(NS.app.db.masterText == '')
            assert(master.attributes.macrotext1:find('Waldwolf',1,true))
        ''')

    def test_all_six_languages_and_persistent_settings_choice(self):
        self.lua.execute('''QuestTargetsDB={language='deDE'}; boot(); NS.UI.Settings(NS.app)
            local labels={'English','Deutsch','Español','Français','Türkçe','简体中文'}
            local codes={'enUS','deDE','esES','frFR','trTR','zhCN'}
            for index, code in ipairs(codes) do
                NS.app.db.language=code
                assert(NS.Language()==index)
                assert(NS.L('refresh') ~= '' and NS.L('masterTip1') ~= '')
            end
            NS.app.db.language='deDE'
            dropdownChoices={}
            NS.UI.settings.languageDropdown.initialize()
            for index, info in ipairs(dropdownChoices) do assert(info.text==labels[index]) end
            dropdownChoices[5].func()
            assert(NS.app.db.language=='trTR' and not reloaded)
            assert(NS.UI.frame.TitleContainer.TitleText.text==NS.L('title'))
            assert(NS.UI.settings.languageDropdown.selectedID==5)
            assert(NS.UI.settings.languageDropdown.text=='Türkçe')
            assert(NS.UI.settings.refreshButton == nil)
            assert(NS.UI.refreshButton.text==NS.L('refresh'))
            assert(NS.UI.settings.toggle.caption.text==NS.L('autoMark'))
            assert(NS.UI.settings.masterConfigButton.text==NS.L('editMaster'))
            assert(NS.UI.master.text==NS.L('masterDefault'))
            NS.app:Refresh()
            assert(NS.UI.filter.text==NS.L('all'))
            dropdownChoices[1].func()
            assert(NS.app.db.language=='enUS' and not reloaded)
            assert(NS.UI.settings.toggle.caption.text=='Automatically mark targets')
            assert(NS.UI.refreshButton.text=='Refresh')
            NS.app.db.masterText='Mein Button'
            dropdownChoices[4].func()
            assert(NS.app.db.language=='frFR' and NS.UI.master.text=='Mein Button')
            assert(NS.UI.settings.languageDropdown.selectedID==4)
            dropdownChoices[2].func()
            assert(NS.app.db.language=='deDE' and not reloaded)
        ''')

    def test_hotkey_capture_waits_through_modifier_and_binds_combination(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local hotkey=NS.UI.settings.hotkey
            hotkey.scripts.OnClick(hotkey)
            ctrlDown=true
            hotkey.scripts.OnKeyDown(hotkey, 'LCTRL')
            assert(hotkey.listening)
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == nil)
            hotkey.scripts.OnKeyDown(hotkey, 'F')
            assert(not hotkey.listening)
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == 'CTRL-F')
            hotkey.scripts.OnClick(hotkey)
            shiftDown=true
            hotkey.scripts.OnKeyDown(hotkey, 'LSHIFT')
            assert(hotkey.listening)
            hotkey.scripts.OnKeyDown(hotkey, 'G')
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == 'CTRL-SHIFT-G')
        ''')

    def test_boot_automatically_creates_only_named_mob_macro(self):
        self.lua.execute('''boot()
            assert(#NS.app.entries == 2)
            assert(NS.app.entries[1].name == 'Waldwolf')
            assert(NS.app.metadata.unresolved == 1)
            assert(QuestTargetsTarget1.attributes.macrotext1 == '/stopmacro [combat,exists,harm,nodead]\\n/cleartarget\\n/targetexact [noexists] Waldwolf\\n/cleartarget [dead]\\n/tm [exists,harm,nodead] !8')
            assert(QuestTargetsTarget2.attributes.macrotext1 == nil)
            assert(QuestTargetsTarget1.attributes.type1 == 'macro')
            assert(QuestTargetsTarget1.attributes.useOnKeyDown == false)
            assert(QuestTargetsTarget1.scripts.OnClick == nil)
        ''')

    def test_one_button_per_quest_all_objectives_no_duplicate_progress(self):
        self.lua.execute('''
            quests[1].objectives[2] = {type='monster',text='Bär getötet: 1/3',numFulfilled=1,numRequired=3,finished=false}
            boot()
            NS.app.learned['1:1'] = {signature=NS.Core.Signature(quests[1].objectives[1]),names={Waldwolf=true, Jungwolf=true}}
            NS.app:Refresh()
            assert(#NS.app.questEntries == 2)
            local entry = QuestTargetsTarget1.entry
            assert(entry.title == 'Wölfe im Wald' and #entry.nameList == 3)
            assert(#entry.refs == 2 and entry.done == 3 and entry.total == 11)
            assert(QuestTargetsTarget1.nameText.text == 'Wölfe im Wald')
            plate('Waldwolf','','').guid = 'A'
            plate('Bär','','').guid = 'B'
            currentGUID = 'A'
            assert(NS.Core.NextUnit(entry,NS.app.entries) == 'nameplate2')
            quests[1].objectives[2].finished = true
            event('QUEST_WATCH_UPDATE',1); flush()
            assert(not QuestTargetsTarget1.entry.names['Bär'])
            assert(QuestTargetsTarget1.entry.total == 8)
        ''')

    def test_shared_mob_keeps_separate_quest_buttons_and_unknown_objectives(self):
        self.lua.execute('''
            quests[2].objectives[2] = {type='monster',text='Waldwolf getötet: 0/2',numFulfilled=0,numRequired=2,finished=false}
            boot()
            assert(#NS.app.questEntries == 2)
            assert(QuestTargetsTarget1.entry.questID ~= QuestTargetsTarget2.entry.questID)
            assert(QuestTargetsTarget2.entry.names.Waldwolf)
            assert(#QuestTargetsTarget2.entry.refs == 2)
            assert(QuestTargetsTarget2.entry.total == 6)
        ''')

    def test_tracking_and_manual_refresh_update_quest_buttons(self):
        self.lua.execute('''boot(); NS.app:ToggleFilter()
            assert(#NS.app.questEntries == 1)
            quests[2].watched = true
            event('QUEST_WATCH_LIST_CHANGED',2,true); flush()
            assert(#NS.app.questEntries == 2)
            quests[1].watched = false
            event('QUEST_WATCH_LIST_CHANGED',1,false); flush()
            assert(#NS.app.questEntries == 1 and QuestTargetsTarget1.entry.questID == 2)
            quests[1].watched = true
            NS.UI.refreshButton.scripts.OnClick()
            assert(#NS.app.questEntries == 2)
            combat = true
            quests[2].watched = false
            NS.UI.refreshButton.scripts.OnClick()
            assert(#NS.app.questEntries == 2 and NS.app.dirty)
            combat = false; event('PLAYER_REGEN_ENABLED')
            assert(#NS.app.questEntries == 1)
        ''')

    def test_accepted_removed_and_turned_in_events_refresh(self):
        self.lua.execute('''boot()
            quests[3] = {questID=3,title='Neue Quest',objectives={{type='monster',text='Spinne getötet: 0/2',numFulfilled=0,numRequired=2,finished=false}}}
            event('QUEST_ACCEPTED',3); flush()
            assert(#NS.app.questEntries == 3)
            table.remove(quests,3)
            event('QUEST_REMOVED',3); flush()
            assert(#NS.app.questEntries == 2)
            quests[1].objectives[1].finished = true
            event('QUEST_TURNED_IN',1); flush()
            assert(#NS.app.questEntries == 1)
        ''')

    def test_master_includes_untracked_quests_with_hidden_menu(self):
        self.lua.execute('''
            quests[2].objectives = {{type='monster',text='Bär getötet: 0/3',numFulfilled=0,numRequired=3,finished=false}}
            boot(); NS.app:ToggleFilter(); NS.app:Toggle()
            assert(not NS.UI.frame.shown and NS.UI.master.shown)
            assert(#NS.app.questEntries == 1)
            assert(NS.UI.master.entry.names['Bär'] and NS.UI.master.entry.names.Waldwolf)
            plate('Bär','','').guid = 'A'
            local master = NS.UI.master
            master.scripts.PreClick(master,'LeftButton',false)
            assert(master.attributes.macrotext1:find('/targetexact [nocombat] Bär',1,true))
            master.scripts.PostClick(master)
            quests[2].objectives[1].finished = true
            event('QUEST_LOG_UPDATE'); flush()
            assert(not master.entry.names['Bär'])
        ''')

    def test_master_settings_scale_position_and_combat_deferred(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local settings, master = NS.UI.settings, NS.UI.master
            master.scripts.OnDragStart(master)
            assert(master.moving)
            NS.app:Refresh()
            assert(master.moving)
            master.scripts.OnDragStop(master)
            assert(not master.moving and NS.app.db.masterPosition)
            settings.larger.scripts.OnClick(); flush()
            assert(NS.UI.frame.scale > 1 and master.scale == nil)
            combat = true; event('PLAYER_REGEN_DISABLED')
            local scale = NS.UI.frame.scale
            settings.masterToggle.scripts.OnClick()
            settings.menuToggle.scripts.OnClick()
            settings.smaller.scripts.OnClick(); flush()
            assert(master.shown and NS.UI.frame.shown and NS.UI.frame.scale == scale)
            combat = false; event('PLAYER_REGEN_ENABLED')
            assert(not master.shown and not NS.UI.frame.shown)
            assert(NS.UI.frame.scale < scale)
            event('ADDON_LOADED','QuestTargets')
            assert(NS.app.db.masterHidden and NS.app.db.hidden)
        ''')

    def test_forever_nameplates_scanner_and_name_targeting(self):
        self.lua.execute('''
            plate('Waldwolf','Wölfe im Wald','Waldwolf getötet: 2/8').guid = 'A'
            plate('Waldwolf','Wölfe im Wald','Waldwolf getötet: 2/8').guid = 'B'
            for _, frame in ipairs(nameplates) do
                frame.unitToken = frame.namePlateUnitToken
                frame.namePlateUnitToken = nil
                frame.GetUnit = function(self) return self.unitToken end
            end
            boot()
            assert(NS.app.learned['1:1'].names.Waldwolf)
            for _, row in ipairs({QuestTargetsTarget1, NS.UI.master}) do
                currentGUID = nil
                row.scripts.PreClick(row,'LeftButton',false)
                assert(row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true))
                currentGUID = 'A'
                row.scripts.PostClick(row)
                for _, expected in ipairs({'nameplate2','nameplate1','nameplate2'}) do
                    row.scripts.PreClick(row,'LeftButton',false)
                    assert(row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true))
                    -- Name targeting may keep the same instance; do not model a token switch.
                    currentGUID = 'A'
                    row.scripts.PostClick(row)
                end
            end
            nameplates[1].unitToken = nil
            nameplates[1].namePlateUnitToken = 'nameplate1'
            assert(NS.Core.NameplateUnit(nameplates[1]) == nil)
            assert(NS.Core.NameplateUnit({unitToken='nameplate2'}) == 'nameplate2')
            assert(NS.Core.NameplateUnit({GetUnit=function() return SECRET end}) == nil)
        ''')

    def test_repeated_click_uses_visible_name_without_claiming_same_name_cycle(self):
        self.lua.execute('''boot()
            plate('Waldwolf','','').guid='A'
            plate('Waldwolf','','').guid='B'
            for _, row in ipairs({QuestTargetsTarget1, NS.UI.master}) do
                assert(#row.clicks==1 and row.clicks[1]=='AnyUp')
                assert(row.attributes.useOnKeyDown==false)
                currentGUID=nil
                row.scripts.PreClick(row,'LeftButton',false)
                local first=row.attributes.macrotext1
                assert(first:find('/targetexact [nocombat] Waldwolf',1,true))
                assert(not first:find('/click',1,true))
                currentGUID='A'
                row.scripts.PostClick(row,'LeftButton',false)
                row.scripts.PreClick(row,'LeftButton',false)
                local second=row.attributes.macrotext1
                assert(second:find('/targetexact [nocombat] Waldwolf',1,true))
                currentGUID='B'
                row.scripts.PostClick(row,'LeftButton',false)
            end
        ''')

    def test_hybrid_far_target_then_nearby_cycle_for_both_buttons(self):
        self.lua.execute('''boot()
            for _, row in ipairs({QuestTargetsTarget1, NS.UI.master}) do
                nameplates = {}; units = {}; currentGUID = nil
                row.scripts.PreClick(row,'LeftButton',false)
                assert(row.attributes.macrotext1:find('/targetexact [noexists] Waldwolf',1,true))
                assert(not row.attributes.macrotext1:find('@nameplate',1,true))
                row.scripts.PostClick(row)
                units.target = {name='Waldwolf',guid='Far'}
                currentGUID = 'Far'
                plate('Waldwolf','','').guid = 'Near'
                row.scripts.PreClick(row,'LeftButton',false)
                assert(row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true))
                row.scripts.PostClick(row)
                units.target = {name='Unrelated',guid='Other'}; currentGUID = 'Other'
                row.scripts.PreClick(row,'LeftButton',false)
                assert(row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true))
                units.target = {name='Waldwolf',dead=true,guid='Dead'}; currentGUID = 'Dead'
                row.scripts.PreClick(row,'LeftButton',false)
                assert(row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true))
                row.scripts.PostClick(row)
            end
        ''')

    def test_valid_target_preserved_without_alternative_for_both_buttons(self):
        self.lua.execute('''boot()
            for _, row in ipairs({QuestTargetsTarget1, NS.UI.master}) do
                units = {target={name='Waldwolf',guid='Far'}}
                nameplates = {}; currentGUID = 'Far'
                for _, autoMark in ipairs({true,false}) do
                    NS.app.db.autoMark = autoMark
                    row.scripts.PreClick(row,'LeftButton',false)
                    local macro = row.attributes.macrotext1
                    assert(not macro:find('/cleartarget',1,true))
                    assert(not macro:find('/target',1,true))
                    assert(currentGUID == 'Far')
                    row.scripts.PostClick(row)
                end
                units = {}; nameplates = {}
                plate('Waldwolf','','').guid = 'Only'
                currentGUID = 'Only'
                row.scripts.PreClick(row,'LeftButton',false)
                assert(not row.attributes.macrotext1:find('/target',1,true))
                assert(not row.attributes.macrotext1:find('/cleartarget',1,true))
                row.scripts.PostClick(row)
                combat = true
                row.scripts.PreClick(row,'LeftButton',false)
                assert(row.attributes.macrotext1:match('^/stopmacro %[combat,exists,harm,nodead%]'))
                row.scripts.PostClick(row)
                combat = false
            end
        ''')

    def test_master_long_fallback_eventually_covers_every_name(self):
        self.lua.execute('''boot()
            local entry = {name='Mob',names={},nameList={},refs={}}
            for i=1,100 do
                local name = 'Creature ' .. i .. string.rep('x',50)
                entry.names[name] = true; entry.nameList[i] = name
            end
            local state, seen = {}, {}
            for click=1,100 do
                local macro = NS.Core.ClickMacro(entry, {}, NS.app.db, state)
                assert(#macro <= 255)
                for name in macro:gmatch('/targetexact %[noexists%] ([^\\n]+)') do seen[name] = true end
            end
            for name in pairs(entry.names) do assert(seen[name], name) end
        ''')

    def test_rapid_empty_master_clicks_never_split_macro_conditions(self):
        self.lua.execute('''boot()
            local entry = {name='Mob',names={},nameList={},refs={}}
            for i=1,36 do
                local name = 'Wüstenjäger ' .. i .. string.rep('x', i*3)
                entry.nameList[i] = name; entry.names[name] = true
            end
            local row = NS.UI.master
            row.entry = entry
            local seen = {}
            local function validate(text)
                assert(#text <= 255)
                local _, opens = text:gsub('%[','')
                local _, closes = text:gsub('%]','')
                assert(opens == closes)
                for condition in text:gmatch('%[([^%]]+)%]') do
                    for token in condition:gmatch('[^,]+') do
                        assert(({combat=true,exists=true,noexists=true,harm=true,nodead=true,dead=true})[token],token)
                    end
                end
            end
            for click=1,180 do
                row.scripts.PreClick(row,'LeftButton',false)
                local text = row.attributes.macrotext1
                validate(text)
                for line in text:gmatch('[^\\n]+') do
                    local name = line:match('^/targetexact %[noexists%] (.+)$') or line:match('^/targetexact ([^%[].+)$')
                    if name then assert(entry.names[name]); seen[name] = true end
                end
                row.scripts.PostClick(row)
                validate(row.attributes.macrotext1)
            end
            for name in pairs(entry.names) do assert(seen[name],name) end
            validate(NS.Core.Macro(string.rep('x',180),NS.app.db))
        ''')

    def test_cycle_without_readable_guids_and_sparse_nameplate_table(self):
        self.lua.execute('''boot()
            plate('Waldwolf','',''); plate('Waldwolf','','')
            nameplates = {[2]=nameplates[1], [9]=nameplates[2]}
            UnitGUID = function() return SECRET end
            local selected = 'nameplate1'
            UnitIsUnit = function(unit) return unit == selected end
            local entry = QuestTargetsTarget1.entry
            assert(NS.Core.NextUnit(entry,NS.app.entries) == 'nameplate2')
            selected = 'nameplate2'
            assert(NS.Core.NextUnit(entry,NS.app.entries) == 'nameplate1')
            assert(NS.Core.lastCycle.plates == 2 and NS.Core.lastCycle.candidates == 2)
            UnitGUID = nil
            assert(NS.Core.NextUnit(entry,NS.app.entries) == 'nameplate1')
        ''')

    def test_visible_name_macro_and_marker_for_both_buttons(self):
        self.lua.execute('''boot()
            plate('Waldwolf','','').guid = 'A'
            plate('Waldwolf','','').guid = 'B'
            UnitIsUnit = function(a,b) return UnitGUID(a) == UnitGUID(b) end
            for _, row in ipairs({QuestTargetsTarget1,NS.UI.master}) do
                currentGUID = 'A'
                for _, expected in ipairs({'nameplate2','nameplate1','nameplate2'}) do
                    local before = row.attributes.macrotext1
                    row.scripts.PreClick(row,'LeftButton',true)
                    assert(row.attributes.macrotext1 == before)
                    row.scripts.PreClick(row,'LeftButton',false)
                    local macro = row.attributes.macrotext1
                    assert(macro:find('/targetexact [nocombat] '..UnitName(expected),1,true))
                    assert(not macro:find('/click',1,true))
                    assert(macro:find('/tm [nocombat,exists,harm,nodead] !8',1,true))
                    -- Supply a matching name result; this does not prove same-name instance cycling.
                    currentGUID = UnitGUID(expected)
                    row.scripts.PostClick(row)
                    assert(NS.Core.lastClick.selected == 'true')
                    assert(not row.attributes.macrotext1:find('@nameplate',1,true))
                end
            end
        ''')

    def test_cycle_instances_and_wrap_from_existing_target(self):
        self.lua.execute('''boot()
            plate('Waldwolf', 'Wölfe im Wald', 'Waldwolf getötet: 2/8').guid = 'Creature-A'
            plate('Waldwolf', 'Wölfe im Wald', 'Waldwolf getötet: 2/8').guid = 'Creature-B'
            local entry = NS.app.entries[1]
            assert(NS.Core.NextUnit(entry, NS.app.entries) == 'nameplate1')
            currentGUID = 'Creature-A'
            assert(NS.Core.NextUnit(entry, NS.app.entries) == 'nameplate2')
            currentGUID = 'Creature-B'
            assert(NS.Core.NextUnit(entry, NS.app.entries) == 'nameplate1')
            units.nameplate1.dead = true
            assert(NS.Core.NextUnit(entry, NS.app.entries) == nil)
            units.nameplate2.friendly = true
            assert(NS.Core.NextUnit(entry, NS.app.entries) == nil)
        ''')

    def test_cycle_includes_alternative_sources_but_not_unrelated_objectives(self):
        self.lua.execute('''boot()
            local entries = {
                {name='Wolf',refs={{key='1:1'}}},
                {name='Bär',refs={{key='1:1'}}},
                {name='Spinne',refs={{key='1:2'}}},
            }
            plate('Wolf', '', '').guid = 'A'
            plate('Bär', '', '').guid = 'B'
            plate('Spinne', '', '').guid = 'C'
            currentGUID = 'A'
            assert(NS.Core.NextUnit(entries[1],entries) == 'nameplate2')
            currentGUID = 'B'
            assert(NS.Core.NextUnit(entries[1],entries) == 'nameplate1')
            units.nameplate1.name = 'Unrelated token reuse'
            assert(NS.Core.NextUnit(entries[1],entries) == nil)
            units.nameplate2.guid = SECRET
            assert(NS.Core.NextUnit(entries[1],entries) == 'nameplate2')
        ''')

    def test_click_prepares_fresh_unit_and_restores_combat_fallback(self):
        self.lua.execute('''boot()
            plate('Waldwolf', '', '').guid = 'A'
            plate('Waldwolf', '', '').guid = 'B'
            currentGUID = 'A'
            local row = QuestTargetsTarget1
            local fallback = row.attributes.macrotext1
            row.scripts.PreClick(row, 'LeftButton', true)
            assert(row.attributes.macrotext1 == fallback)
            row.scripts.PreClick(row, 'LeftButton', false)
            assert(row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true))
            assert(row.attributes.macrotext1:find('/tm [nocombat,exists,harm,nodead] !8',1,true))
            row.scripts.PostClick(row)
            assert(row.attributes.macrotext1 == fallback)
            combat = true
            C_NamePlate.GetNamePlates = function() error('combat scan') end
            row.scripts.PreClick(row, 'LeftButton', false)
            row.scripts.PostClick(row)
            assert(row.attributes.macrotext1 == fallback)
            assert(NS.Core.NextUnit(row.entry, NS.app.entries) == nil)
        ''')

    def test_marker_settings_defaults_selection_disable_and_reload(self):
        self.lua.execute('''boot()
            assert(NS.app.db.autoMark and NS.app.db.markerIcon == 8)
            SlashCmdList.QUESTTARGETS('settings')
            local panel = NS.UI.settings
            assert(panel.shown and not panel.icons[8].enabled)
            panel.icons[3].scripts.OnClick(); flush()
            assert(NS.app.db.markerIcon == 3)
            assert(QuestTargetsTarget1.attributes.macrotext1:find('!3',1,true))
            panel.toggle.scripts.OnClick(); flush()
            assert(not NS.app.db.autoMark)
            assert(not QuestTargetsTarget1.attributes.macrotext1:find('/tm',1,true))
            event('ADDON_LOADED','QuestTargets')
            assert(not NS.app.db.autoMark and NS.app.db.markerIcon == 3)
            NS.app.db.markerIcon = 99
            event('ADDON_LOADED','QuestTargets')
            assert(NS.app.db.markerIcon == 8)
        ''')

    def test_marker_setting_changes_deferred_during_combat(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local old = QuestTargetsTarget1.attributes.macrotext1
            combat = true; event('PLAYER_REGEN_DISABLED')
            NS.UI.settings.icons[2].scripts.OnClick(); flush()
            assert(NS.app.db.markerIcon == 2)
            assert(QuestTargetsTarget1.attributes.macrotext1 == old)
            combat = false; event('PLAYER_REGEN_ENABLED')
            assert(QuestTargetsTarget1.attributes.macrotext1:find('!2',1,true))
        ''')

    def test_localized_formats_and_punctuation(self):
        self.lua.execute('''
            local c = NS.Core
            assert(c.MobName({type='monster',text='Waldwolf getötet: 2/8'}) == 'Waldwolf')
            QUEST_MONSTERS_KILLED = '%s slain: %d/%d'
            assert(c.MobName({type='monster',text="Zal'jin (Elite) slain: 0/1"}) == "Zal'jin (Elite)")
            assert(c.NameFromFormat('2/8 — Waldwolf', '%2$d/%3$d — %1$s') == 'Waldwolf')
            assert(c.NameFromFormat('Loup tué : 1/4', '%s tué : %d/%d') == 'Loup')
            assert(c.MobName({type='monster',text='Wolf: 0/4'}) == 'Wolf')
            assert(c.MobName({type='item',text='Wolf: 0/4'}) == nil)
            assert(c.MobName({type='event',text='Portal geöffnet'}) == nil)
            assert(c.MobName({type='monster',text='Unbekanntes Sonderziel'}) == nil)
        ''')

    def test_untrusted_macro_content_and_secret_values_rejected(self):
        self.lua.execute('''
            for _, name in ipairs({'Wolf\\n/startattack','Wolf\\r/run x','[harm] Wolf','Wolf; Bear','|Hunit:x|hWolf|h',string.rep('x',181)}) do
                assert(NS.Core.Macro(name) == nil, name)
            end
            assert(NS.Core.SafeName(SECRET) == nil)
            assert(NS.Core.SafeName('|cffffffffWolf|r') == 'Wolf')
            quests[1].objectives[1].text = SECRET
            boot(); assert(#NS.app.entries == 1 and NS.app.metadata.unresolved == 1)
        ''')

    def test_completed_accepted_abandoned_and_shared_mob_objectives(self):
        self.lua.execute('''boot()
            quests[3] = {questID=3,title='Mehr Wölfe', objectives={
                {type='monster',text='Waldwolf getötet: 0/2',numFulfilled=0,numRequired=2,finished=false}}}
            event('QUEST_LOG_UPDATE'); flush()
            assert(#NS.app.entries == 2 and #NS.app.entries[1].refs == 2)
            assert(NS.app.entries[1].done == 2 and NS.app.entries[1].total == 10)
            quests[1].objectives[1].finished = true
            event('QUEST_LOG_UPDATE'); flush()
            assert(#NS.app.entries[1].refs == 1 and NS.app.entries[1].refs[1].questID == 3)
            table.remove(quests,3); event('QUEST_LOG_UPDATE'); flush()
            assert(#NS.app.entries == 1 and NS.app.entries[1].name == nil)
            assert(QuestTargetsTarget1.attributes.macrotext1 == nil)
            assert(not QuestTargetsTarget2.shown)
        ''')

    def test_zero_watch_type_is_watched_and_headers_ignored(self):
        self.lua.execute('''
            table.insert(quests,1,{isHeader=true,title='Wald'})
            boot(); NS.app:ToggleFilter()
            assert(#NS.app.entries == 1 and NS.app.entries[1].name == 'Waldwolf')
            quests[2].watched = false
            event('QUEST_WATCH_LIST_CHANGED'); flush()
            assert(#NS.app.entries == 0 and NS.UI.empty.shown)
        ''')

    def test_combat_freezes_actions_and_defers_visibility(self):
        self.lua.execute('''boot()
            local old = QuestTargetsTarget1.attributes.macrotext1
            combat = true; event('PLAYER_REGEN_DISABLED')
            quests[1].objectives[1].finished = true
            event('QUEST_LOG_UPDATE'); flush()
            NS.app:Page(1); NS.app:ToggleFilter()
            SlashCmdList.QUESTTARGETS('reset'); SlashCmdList.QUESTTARGETS('clear')
            NS.app:Toggle()
            assert(QuestTargetsFrame.shown and NS.app.pendingVisibility == false)
            assert(QuestTargetsTarget1.attributes.macrotext1 == old)
            assert(NS.app.dirty and NS.app.page == 1)
            combat = false; event('PLAYER_REGEN_ENABLED')
            assert(not QuestTargetsFrame.shown)
            assert(QuestTargetsTarget1.attributes.macrotext1 == nil)
            assert(not NS.app.dirty)
        ''')

    def test_reload_in_combat_defers_all_ui_creation(self):
        self.lua.execute('''combat = true; boot()
            assert(NS.UI.frame == nil)
            NS.app:Toggle(); NS.app:Toggle()
            combat = false; event('PLAYER_REGEN_ENABLED')
            assert(NS.UI.frame and QuestTargetsFrame.shown)
        ''')

    def test_paging_clears_stale_macros_and_clamps_after_completion(self):
        self.lua.execute('''
            quests = {}
            for i=1,15 do quests[i]={questID=i,title='Quest '..i,objectives={
                {type='monster',text='Mob '..i..' getötet: 0/1',numFulfilled=0,numRequired=1,finished=false}}} end
            boot(); NS.app:Page(1); NS.app:Page(1)
            assert(NS.app.page == 3 and QuestTargetsTarget1.entry.name == 'Mob 13')
            assert(not QuestTargetsTarget4.shown and QuestTargetsTarget4.attributes.macrotext1 == nil)
            for i=15,2,-1 do quests[i]=nil end
            event('QUEST_LOG_UPDATE'); flush()
            assert(NS.app.page == 1 and QuestTargetsTarget1.entry.name == 'Mob 1')
            assert(not QuestTargetsTarget2.shown)
        ''')

    def test_api_missing_empty_loading_and_corrupt_saved_data(self):
        self.lua.execute('''QuestTargetsDB = {autoTargets='bad'}; boot()
            assert(type(QuestTargetsDB.autoTargets.entries) == 'table')
            C_QuestLog.GetQuestObjectives = nil
            NS.app:Refresh(); assert(NS.app.error and #NS.app.entries == 0)
            assert(QuestTargetsTarget1.attributes.macrotext1 == nil)
            C_QuestLog.GetQuestObjectives = function() return nil end
            NS.app:Refresh(); assert(not NS.app.error and #NS.app.entries == 0)
            C_QuestLog.GetQuestObjectives = function() return {} end
            NS.app:Refresh(); assert(#NS.app.entries == 0)
        ''')

    def test_quest_update_bursts_are_coalesced(self):
        self.lua.execute('''boot()
            for i=1,100 do event('QUEST_LOG_UPDATE') end
            assert(#timers == 1); flush(); assert(#timers == 0)
        ''')

    def test_saved_visibility_and_filter_restored(self):
        self.lua.execute('''QuestTargetsDB = {hidden=true,watchedOnly=true,overrides={}}
            boot(); assert(not QuestTargetsFrame.shown and #NS.app.entries == 1)
            SlashCmdList.QUESTTARGETS(''); assert(QuestTargetsFrame.shown)
        ''')

    def test_item_mob_appears_without_target_mouseover_or_assignment(self):
        self.lua.execute('''
            plate('Junger Waldwolf', 'Warme Felle', '1/4 Wolfsfell')
            boot()
            assert(NS.app.Assign == nil and QuestTargetsTarget1.assign == nil)
            assert(NS.app.metadata.unresolved == 0)
            assert(NS.app.entries[2].name == 'Junger Waldwolf')
            assert(QuestTargetsTarget2.attributes.macrotext1:find('Junger Waldwolf',1,true))
            assert(NS.app.entries[2].refs[1].detected)
            assert(QuestTargetsDB.autoTargets.entries['2:1'].names['Junger Waldwolf'])
        ''')

    def test_modern_kill_count_prefix_and_missing_count(self):
        self.lua.execute('''
            assert(NS.Core.MobName({type='monster', text='0/8 Waldwolf getötet'}) == 'Waldwolf')
            assert(NS.Core.MobName({type='monster', text='Waldwolf getötet'}) == 'Waldwolf')
            assert(NS.Core.MobName({type='monster', text='0/8 Forest Wolf slain'}) == 'Forest Wolf')
        ''')

    def test_multiple_drop_sources_and_group_kill_names(self):
        self.lua.execute('''
            plate('Junger Waldwolf','Warme Felle','1/4 Wolfsfell')
            plate('Alter Waldwolf','Warme Felle','Wolfsfell: 1/4')
            plate('Junger Waldwolf','Wölfe im Wald','2/8 Waldwolf getötet')
            boot()
            assert(#NS.app.entries == 2 and NS.app.metadata.unresolved == 0)
            assert(NS.app.entries[1].name == 'Junger Waldwolf' and #NS.app.entries[1].refs == 2)
            assert(NS.app.entries[2].name == 'Alter Waldwolf')
            for _, entry in ipairs(NS.app.entries) do assert(entry.name ~= 'Waldwolf') end
        ''')

    def test_unknown_unrelated_completed_and_ambiguous_tooltips_ignored(self):
        self.lua.execute('''
            plate('Falscher Mob','Andere Quest','1/4 Wolfsfell')
            plate('Falscher Mob','Warme Felle','1/4 Bärenfell')
            local p=plate('Falscher Mob','Warme Felle','1/4 Wolfsfell')
            p.data.lines[3].completed = true
            p=plate('Falscher Mob','Warme Felle','1/4 Wolfsfell')
            p.data.lines[3].type = 0
            p=plate('Falscher Mob','Warme Felle','1/4 Wolfsfell')
            p.data.lines[2].leftText = SECRET
            boot(); assert(NS.app.metadata.unresolved == 1)
            quests[3]={questID=3,title='Warme Felle',objectives=quests[2].objectives}
            plate('Mehrdeutig','Warme Felle','1/4 Wolfsfell')
            event('QUEST_LOG_UPDATE'); flush()
            assert(QuestTargetsDB.autoTargets.entries['2:1'] == nil)
            assert(QuestTargetsDB.autoTargets.entries['3:1'] == nil)
        ''')

    def test_nameplate_events_and_delayed_tooltip_data(self):
        self.lua.execute('''boot()
            local p=plate('Waldwolf','Warme Felle','1/4 Wolfsfell')
            local saved=p.data; p.data=nil
            event('NAME_PLATE_UNIT_ADDED','nameplate1'); flush()
            assert(NS.app.metadata.unresolved == 1)
            p.data=saved; tick()
            assert(NS.app.metadata.unresolved == 0 and #NS.app.entries == 1)
            assert(#NS.app.entries[1].refs == 2)
        ''')

    def test_scans_wait_until_combat_ends(self):
        self.lua.execute('''boot()
            combat=true; event('PLAYER_REGEN_DISABLED')
            plate('Waldwolf','Warme Felle','1/4 Wolfsfell')
            event('NAME_PLATE_UNIT_ADDED','nameplate1'); flush(); tick()
            assert(tooltipCalls == 0 and NS.app.metadata.unresolved == 1)
            combat=false; event('PLAYER_REGEN_ENABLED')
            assert(tooltipCalls > 0 and NS.app.metadata.unresolved == 0)
        ''')

    def test_detected_names_survive_progress_but_not_changed_objective(self):
        self.lua.execute('''plate('Junger Waldwolf','Warme Felle','1/4 Wolfsfell'); boot()
            nameplates={}; units={}
            quests[2].objectives[1].text='2/4 Wolfsfell'
            quests[2].objectives[1].numFulfilled=2
            event('QUEST_LOG_UPDATE'); flush()
            assert(NS.app.entries[2].name == 'Junger Waldwolf' and NS.app.entries[2].done == 2)
            quests[2].objectives[1].text='2/4 Bärenfell'
            event('QUEST_LOG_UPDATE'); flush()
            assert(NS.app.metadata.unresolved == 1)
        ''')

    def test_previous_manual_overrides_are_not_used(self):
        self.lua.execute('''QuestTargetsDB={overrides={['2:1']={name='Falsch',signature='item:Wolfsfell'}}}
            boot(); assert(NS.app.metadata.unresolved == 1)
            assert(QuestTargetsDB.overrides['2:1'].name == 'Falsch')
        ''')

    def test_detected_names_restored_only_for_same_locale(self):
        self.lua.execute('''QuestTargetsDB={autoTargets={locale='deDE',entries={
            ['2:1']={signature='item:Wolfsfell',names={Waldwolf=true}}
        }}}
            boot(); assert(#NS.app.entries == 1 and NS.app.metadata.unresolved == 0)
        ''')

    def test_locale_change_invalidates_cached_names(self):
        self.lua.execute('''QuestTargetsDB={autoTargets={locale='enUS',entries={
            ['2:1']={signature='item:Wolfsfell',names={Wolf=true}}
        }}}
            boot(); assert(NS.app.metadata.unresolved == 1)
        ''')

    def test_missing_nameplate_api_is_explicit_not_manual_fallback(self):
        self.lua.execute('''QuestTargetsDB={language='deDE'}; C_TooltipInfo=nil; boot()
            assert(NS.Scanner.status:find('nicht verfügbar',1,true))
            assert(NS.UI.status.text:find('nicht verfügbar',1,true))
            assert(NS.app.Assign == nil)
            assert(NS.app.entries[1].name == 'Waldwolf')
        ''')

    def test_scan_budget_eventually_visits_all_nameplates(self):
        self.lua.execute('''
            for i=1,40 do plate('Wolf '..i,'Warme Felle','1/4 Wolfsfell') end
            boot(); assert(tooltipCalls == 12)
            tick(); assert(tooltipCalls == 24)
            tick(); tick()
            assert(#NS.app.entries == 41 and NS.app.metadata.unresolved == 0)
        ''')

    def test_delayed_quest_api_retried_without_event(self):
        self.lua.execute('''local get=C_QuestLog.GetQuestObjectives
            C_QuestLog.GetQuestObjectives=function() return nil end
            boot(); assert(#NS.app.entries == 0)
            C_QuestLog.GetQuestObjectives=get
            tick(); assert(#NS.app.entries == 2)
        ''')

    def test_player_dead_friendly_and_restricted_mobs_not_learned(self):
        self.lua.execute('''QuestTargetsDB={language='deDE'};
            local p=plate('Player','Warme Felle','1/4 Wolfsfell'); p.player=true
            p=plate('Leiche','Warme Felle','1/4 Wolfsfell'); p.dead=true
            p=plate('Freund','Warme Felle','1/4 Wolfsfell'); p.friendly=true
            p=plate('Gesperrt','Warme Felle','1/4 Wolfsfell'); p.throws=true
            p=plate('Secret','Warme Felle','1/4 Wolfsfell'); p.data.lines[3].completed=SECRET
            boot(); assert(NS.app.metadata.unresolved == 1)
            assert(NS.Scanner.status:find('nicht alle',1,true))
        ''')

    def database(self):
        self.lua.execute('''
            records = {Quest={
                [1]={name='Wölfe im Wald',objectives={{{10}}}},
                [2]={name='Warme Felle',objectives={[3]={{100}}}},
            },Npc={
                [10]={name='Waldwolf'}, [11]={name='Junger Waldwolf'},
                [12]={name='Alter Waldwolf'}, [999]={name='Unsichtbarer Killcredit'},
            },Item={
                [100]={name='Wolfsfell',npcDrops={11,12,11},itemDrops={101}},
                [101]={name='Beutel',npcDrops={10},itemDrops={100}},
            }}
            LibQuestieDB={RequireContract=function(v) return v==1 end,
                l10n={currentLocale='deDE'},flavor={name='Vanilla'},readMode='baked'}
            for kind, rows in pairs(records) do
                local data=rows
                LibQuestieDB[kind]={Get=function(id,key) return data[id] and data[id][key] end}
            end
        ''')

    def test_resolver_reuses_quest_results_for_both_views_and_plate_updates(self):
        self.database()
        self.lua.execute('''
            QuestTargetsDB={watchedOnly=true}
            local calls={}
            local original=LibQuestieDB.Quest.Get
            LibQuestieDB.Quest.Get=function(id, key)
                calls[id]=(calls[id] or 0)+1
                return original(id, key)
            end
            local single=NS.Core.ReadQuests(false)[1]
            NS.Resolvers.Resolve(single)
            local expected=calls[1]
            calls={}
            boot()
            assert(calls[1]==expected)
            local before=calls[1]
            local plate=plate('Waldwolf','Wölfe im Wald','0/4 Waldwolf')
            NS.app:Poll()
            assert(calls[1]==before)
            -- A full refresh deliberately drops the cache, including after DB data changes.
            NS.app:Refresh()
            assert(calls[1]==before+expected)
        ''')

    def test_generic_source_item_resolver_has_no_quest_id_rules(self):
        self.database()
        self.lua.execute('''
            records.Quest[31415]={name='Werkzeugprobe',objectives={[3]={{200}}},requiredSourceItems={201}}
            records.Item[200]={name='Repariertes Werkzeug'}
            records.Item[201]={name='Rohes Werkzeug',npcDrops={10,11}}
            local q={id=31415,title='Werkzeugprobe',typeCounts={item=1},objectives={
                {index=1,type='item',text='Repariertes Werkzeug: 0/3',done=0,total=3}}}
            assert(next(NS.Database.Resolve(q)[1]) == nil)
            local names=NS.Resolvers.Resolve(q)[1]
            assert(names.Waldwolf and names['Junger Waldwolf'])
            assert(NS.Core.QuestEntries(NS.Core.BuildEntries({q},{}))[1].total == 3)
            -- Multiple unresolved objectives cannot be assigned one quest-level source safely.
            q.objectives[2]={index=2,type='item',text='Anderes Teil: 0/2',done=0,total=2}
            q.typeCounts.item=2
            local ambiguous=NS.Resolvers.Resolve(q)
            assert(next(ambiguous[1] or {}) == nil and next(ambiguous[2] or {}) == nil)
            q.objectives[2]=nil
            q.typeCounts.item=1
            records.Quest[31415].objectives[3][2]={202}
            assert(next(NS.Resolvers.Resolve(q)[1] or {}) == nil)
        ''')

    def test_master_targets_ready_quest_npc_after_open_mobs(self):
        self.database()
        self.lua.execute('''
            records.Quest[2].finishedBy={{42}}
            records.Npc[42]={name='Försterin Mira'}
            quests[2].ready=true
            quests[2].objectives[1].finished=true
            boot()
            local master=NS.UI.master
            assert(master.entry.nameList[1]=='Waldwolf')
            assert(master.entry.nameList[2]=='Försterin Mira')
            assert(master.entry.names['Försterin Mira'])
            local macro=master.attributes.macrotext1
            assert(macro:find('Waldwolf',1,true) < macro:find('Försterin Mira',1,true))
            assert(macro:find('/tm [exists,harm,nodead] !8',1,true))
            assert(not QuestTargetsTarget1.attributes.macrotext1:find('/tm [exists,nodead]',1,true))
            quests[1].ready=true
            quests[1].objectives[1].finished=true
            records.Quest[1].finishedBy={{43}}
            records.Npc[43]={name='Wachhauptmann Tor'}
            event('QUEST_LOG_UPDATE'); flush()
            assert(master.entry.nameList[1]=='Försterin Mira')
            assert(master.entry.names['Wachhauptmann Tor'])
            assert(not master.entry.names.Waldwolf)
        ''')

    def test_master_first_click_keeps_ready_npc_inside_full_macro(self):
        self.database()
        self.lua.execute('''
            records.Quest[2].finishedBy={{42}}
            records.Npc[42]={name='Försterin Mira'}
            quests[2].ready=true
            quests[2].objectives[1].finished=true
            for id=3,14 do
                quests[id]={questID=id,title='Jagd '..id,objectives={{type='monster',
                    text='Waldwolf '..id..' getötet: 0/1',numRequired=1,numFulfilled=0,finished=false}}}
            end
            boot()
            local master=NS.UI.master
            assert(master.entry.mobCount>10 and master.entry.turnInCount==1)
            local macro=NS.Core.ClickMacro(master.entry, NS.app.allEntries, NS.app.db, master)
            assert(#macro<=NS.Core.MACRO_BYTES)
            assert(macro:find('Waldwolf',1,true))
            assert(macro:find('Försterin Mira',1,true))
            assert(macro:find('Waldwolf',1,true)<macro:find('Försterin Mira',1,true))
            assert(macro:find('/tm [exists,harm,nodead] !8',1,true))
        ''')

    def test_zone_filter_keeps_only_known_local_mobs_and_turnin_npcs(self):
        self.database()
        self.lua.execute('''
            local zone='Elwynn'
            GetRealZoneText=function() return zone end
            C_Map={GetAreaInfo=function(id) return ({[1]='Elwynn',[2]='Durotar'})[id] end}
            records.Npc[10].spawns={[2]={{40,50}}}
            records.Quest[2].finishedBy={{42}}
            records.Npc[42]={name='Försterin Mira',spawns={[1]={{20,30}}}}
            quests[2].ready=true
            quests[2].objectives[1].finished=true
            boot()
            assert(not NS.UI.master.entry.names.Waldwolf)
            assert(NS.UI.master.entry.finisherNames['Försterin Mira'])
            assert(NS.UI.master.attributes.macrotext1:find('Försterin Mira',1,true))
            zone='Durotar'; event('ZONE_CHANGED_NEW_AREA'); flush()
            assert(NS.UI.master.entry.names.Waldwolf)
            assert(not NS.UI.master.entry.names['Försterin Mira'])
            records.Npc[10].spawns=nil
            NS.app:Refresh()
            assert(NS.UI.master.entry.names.Waldwolf)
        ''')

    def test_master_keeps_selected_ready_quest_npc_on_second_click(self):
        self.database()
        self.lua.execute('''
            records.Quest[2].finishedBy={{42}}
            records.Npc[42]={name='Försterin Mira'}
            quests[2].ready=true
            quests[2].objectives[1].finished=true
            boot()
            local master=NS.UI.master
            assert(master.entry.finisherNames['Försterin Mira'])
            units.questgiver={name='Försterin Mira', guid='ready-npc', friendly=true}
            currentGUID='ready-npc'
            assert(NS.Core.ValidCurrentTarget(master.entry))
            local macro=NS.Core.ClickMacro(master.entry, NS.app.allEntries, NS.app.db, master)
            assert(not macro:find('/cleartarget', 1, true))
            assert(not macro:find('/targetexact', 1, true))
            assert(not macro:find('/click', 1, true))
            assert(macro == '\\n/tm [nocombat,exists,nodead] !8')
            assert(NS.Core.lastClick.path == 'Ziel behalten')
            master.scripts.PostClick(master,'LeftButton')
            assert(markedTarget == nil)
            NS.app.db.markerIcon=3
            macro=NS.Core.ClickMacro(master.entry, NS.app.allEntries, NS.app.db, master)
            assert(macro == '\\n/tm [nocombat,exists,nodead] !3')
            master.scripts.PostClick(master,'LeftButton')
            assert(markedTarget == nil)
            NS.app.db.autoMark=false
            macro=NS.Core.ClickMacro(master.entry, NS.app.allEntries, NS.app.db, master)
            assert(not macro:find('/tm',1,true))
            NS.app.db.autoMark=true
            -- A visible hostile quest mob still takes precedence over the NPC.
            plate('Waldwolf','','').guid='quest-mob'
            macro=NS.Core.ClickMacro(master.entry, NS.app.allEntries, NS.app.db, master)
            assert(NS.Core.lastClick.path == 'Namenssuche aus Namensplakette')
            assert(macro:find('/targetexact [nocombat] Waldwolf', 1, true))
        ''')

    def test_friendly_player_before_master_click_targets_npc_without_marking_player(self):
        self.database()
        self.lua.execute('''
            records.Quest[2].finishedBy={{42}}
            records.Npc[42]={name='Försterin Mira'}
            quests[2].ready=true
            quests[2].objectives[1].finished=true
            boot()
            local master=NS.UI.master
            units.friend={name='Anderer Spieler',guid='friendly-player',friendly=true,player=true}
            currentGUID='friendly-player'
            local npc=plate('Försterin Mira','','')
            npc.guid='ready-npc'; npc.friendly=true
            local macro=NS.Core.ClickMacro(master.entry,NS.app.allEntries,NS.app.db,master)
            assert(macro:find('/targetexact [nocombat] Försterin Mira',1,true))
            assert(not macro:find('/tm',1,true))
            master.scripts.PostClick(master,'LeftButton')
            assert(markedTarget==nil)
            currentGUID='ready-npc'
            master.scripts.PostClick(master,'LeftButton')
            assert(markedTarget==nil)
            macro=NS.Core.ClickMacro(master.entry,NS.app.allEntries,NS.app.db,master)
            assert(macro=='\\n/tm [nocombat,exists,nodead] !8')
            -- A previous player target does not change the role priority:
            -- mob names precede ready NPCs, with safe hostile-only marking.
            nameplates={}; currentGUID='friendly-player'; markedTarget=nil
            macro=NS.Core.ClickMacro(master.entry,NS.app.allEntries,NS.app.db,master)
            assert(macro:find('/cleartarget',1,true))
            assert(macro:find('Waldwolf',1,true)<macro:find('Försterin Mira',1,true))
            assert(not macro:find('/tm [exists,nodead]',1,true))
        ''')

    def test_turnin_npcs_require_ready_matching_quest_and_npc_source(self):
        self.database()
        self.lua.execute('''
            records.Quest[2].finishedBy={{42},{444}}
            records.Npc[42]={name='Försterin Mira'}
            quests[2].ready=false
            boot(); assert(not NS.UI.master.entry.names['Försterin Mira'])
            quests[2].ready=true
            records.Quest[2].name='Andere Quest'
            NS.app:Refresh(); assert(not NS.UI.master.entry.names['Försterin Mira'])
            records.Quest[2].name='Warme Felle'
            NS.app:Refresh(); assert(NS.UI.master.entry.names['Försterin Mira'])
            assert(not NS.UI.master.entry.names['444'])
            records.Quest[2].finishedBy={{43}}
            records.Npc[43]={name='Ungültig;/run x'}
            NS.app:Refresh(); assert(not NS.UI.master.entry.names['Ungültig;/run x'])
        ''')

    def test_database_all_drop_sources_exist_before_encounter(self):
        self.database()
        self.lua.execute('''boot()
            assert(#nameplates==0 and tooltipCalls==0)
            assert(NS.app.metadata.unresolved==0 and #NS.app.entries==3)
            local names={}
            for _, e in ipairs(NS.app.entries) do names[e.name]=true end
            assert(names.Waldwolf and names['Junger Waldwolf'] and names['Alter Waldwolf'])
            assert(#NS.app.entries[1].refs==2)
            assert(NS.app.entries[1].refs[1].database)
            assert(NS.UI.database.text=='QuestieDB · Classic')
        ''')

    def test_database_union_with_new_observed_mob_preserves_alternatives(self):
        self.database()
        self.lua.execute('''plate('Forever-Wolf','Warme Felle','1/4 Wolfsfell'); boot()
            assert(#NS.app.entries==4)
            local names={}
            for _, e in ipairs(NS.app.entries) do names[e.name]=true end
            assert(names['Forever-Wolf'] and names['Junger Waldwolf'] and names['Alter Waldwolf'])
        ''')

    def test_database_group_credit_uses_every_real_npc_not_proxy(self):
        self.database()
        self.lua.execute('''records.Quest[1].objectives={[5]={{{10,11,12},999,'Waldwolf getötet',1}}}
            quests[2]=nil
            boot(); assert(#NS.app.entries==3)
            for _, entry in ipairs(NS.app.entries) do
                assert(entry.name~='Unsichtbarer Killcredit' and entry.done==2 and entry.total==8)
            end
        ''')

    def test_database_finished_first_objective_does_not_shift_mapping(self):
        self.database()
        self.lua.execute('''
            records.Quest[2].objectives={[3]={{101},{100}}}
            quests[2].objectives={
                {type='item',text='Beutel: 1/1',numFulfilled=1,numRequired=1,finished=true},
                {type='item',text='Wolfsfell: 1/4',numFulfilled=1,numRequired=4,finished=false},
            }
            boot(); assert(NS.app.metadata.unresolved==0)
            for _, entry in ipairs(NS.app.entries) do
                for _, ref in ipairs(entry.refs) do
                    if ref.questID==2 then assert(ref.key=='2:2') end
                end
            end
        ''')

    def test_database_title_mismatch_and_wrong_provider_rejected(self):
        self.database()
        self.lua.execute('''QuestTargetsDB={language='deDE'}; records.Quest[2].name='Geänderte Quest'
            boot(); assert(NS.app.metadata.unresolved==1)
            LibQuestieDB.flavor.name='Mists'; NS.app:Refresh()
            assert(NS.Database.status:find('Classic benötigt',1,true))
            LibQuestieDB.flavor.name='Vanilla'
            LibQuestieDB.RequireContract=function() return false end
            NS.app:Refresh(); assert(NS.Database.status=='QuestieDB inkompatibel')
        ''')

    def test_database_uncertain_objective_mapping_not_guessed(self):
        self.database()
        self.lua.execute('''
            records.Quest[2].objectives={[3]={{101},{100}}}
            quests[2].objectives[1].text='Unbekanntes Fell: 1/4'
            boot(); assert(NS.app.metadata.unresolved==1)
        ''')

    def test_database_alternatives_disappear_together_on_completion(self):
        self.database()
        self.lua.execute('''boot(); assert(#NS.app.entries==3)
            quests[2].objectives[1].finished=true
            event('QUEST_LOG_UPDATE'); flush()
            assert(#NS.app.entries==1 and NS.app.entries[1].name=='Waldwolf')
            assert(#NS.app.entries[1].refs==1)
        ''')


if __name__ == '__main__':
    unittest.main()
