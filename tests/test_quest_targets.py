"""Behavior tests for the real Lua addon. Requires lupa; no running WoW client."""
from pathlib import Path
import unittest
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]


class QuestTargetsTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute((ROOT / 'tests/quest_targets_mock.lua').read_text(encoding='utf-8'))
        for name in ('Core.lua', 'Locale.lua', 'PatchNotesData.lua', 'PatchNotes.lua', 'Database.lua', 'Proximity.lua', 'Resolvers.lua', 'Scanner.lua', 'UI.lua', 'Resize.lua', 'Master.lua', 'QuestieTracker.lua', 'EllesmereTracker.lua', 'FlareUITracker.lua', 'RestedXP.lua', 'ItemTree.lua', 'RareScanner.lua', 'Diagnostics.lua', 'Tutorial.lua', 'Main.lua'):
            self.lua.execute('assert(loadstring(...))("QuestTargets", NS)',
                             (ROOT / 'QuestTargets' / name).read_text(encoding='utf-8'))

    def test_target_ping_uses_a_guarded_native_macro_and_excludes_raid_markers(self):
        self.lua.execute('''
            C_Ping={SendMacroPing=function() error('Ping must run in the secure macro') end}
            QuestTargetsDB={autoPing=true, autoMark=true}
            boot()
            local app, core, ui = NS.app, NS.Core, NS.UI
            local ping='/ping [@target,exists,harm,nodead]'
            assert(app.db.autoPing and not app.db.autoMark)
            local macro=core.EntryMacro(ui.master.defaultEntry, app.db)
            assert(#macro<=255 and macro:find(ping,1,true) and not macro:find('/tm',1,true))
            assert(core.Macro('Friendly NPC', app.db, true):find('/ping [@target,exists,nodead]',1,true))
            ui.Settings(app)
            local master = ui.settings.feedbackControls[1].selector
            local rested = ui.settings.feedbackControls[2].selector
            local tooltipLine
            GameTooltip.AddLine=function(_, text) tooltipLine=text end
            master.scripts.OnEnter(master)
            assert(tooltipLine:find('255',1,true) and tooltipLine:find('Show Pings in Chat',1,true))
            master.scripts.OnClick()
            assert(core.TargetFeedbackMode(app.db,'master')==1)
            assert(core.TargetFeedbackMode(app.db,'restedXP')==3)
            rested.scripts.OnClick()
            rested.scripts.OnClick()
            assert(core.TargetFeedbackMode(app.db,'restedXP')==2)
            assert(core.TargetFeedbackMode(app.db,'itemTree')==3)
            assert(core.TargetFeedbackMode(app.db,'rare')==3)
            app:Refresh()
            macro=ui.master.attributes.macrotext1
            assert(not macro:find('/ping',1,true) and not macro:find('/tm',1,true))
            assert(ui.rows[1].attributes.macrotext1:find('/ping',1,true))
            app.db.targetFeedback.rare=1
            assert(core.TargetFeedbackMode(app.db,'rare')==1)
            app.db.targetFeedback.rare=nil
            C_Ping=nil
            assert(core.TargetFeedbackMode(app.db,'rare')==1)
            assert(not core.Macro('Wolf', app.db):find('/ping',1,true))
        ''')

    def test_quest_zones_sort_and_collapse_without_removing_targets(self):
        self.lua.execute('''
            table.insert(quests, 2, {title='Ashenvale',isHeader=true})
            table.insert(quests, 1, {title='Westfall',isHeader=true})
            boot()
            local ui, app=NS.UI, NS.app
            assert(ui.zoneHeaders[1].zoneKey=='Ashenvale')
            assert(ui.rows[2].entry.questID==2 and ui.rows[2].number.text==1)
            assert(ui.zoneHeaders[3].zoneKey=='Westfall')
            assert(ui.rows[4].entry.questID==1 and ui.rows[4].number.text==2)
            ui.zoneHeaders[1].scripts.OnClick(ui.zoneHeaders[1])
            assert(app.db.collapsedQuestZones.Ashenvale and #app.questEntries==2)
            assert(ui.zoneHeaders[2].zoneKey=='Westfall' and ui.rows[2].attributes.macrotext1==nil)
            assert(ui.rows[3].entry.questID==1 and not ui.rows[4]:IsShown())
            event('ADDON_LOADED','QuestTargets'); app:Refresh()
            assert(ui.zoneHeaders[2].zoneKey=='Westfall')
            ui.zoneHeaders[1].scripts.OnClick(ui.zoneHeaders[1])
            assert(not app.db.collapsedQuestZones.Ashenvale and ui.rows[2].entry.questID==2)
            app:ToggleFilter()
            assert(ui.zoneHeaders[1].zoneKey=='Westfall' and ui.rows[2].entry.questID==1)
        ''')

    def test_shift_lock_controls_the_shared_bar_and_leaves_edit_mode_available(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            local ui, app=NS.UI, NS.app
            local master, lock, hover=ui.master, ui.barLock, ui.barLockHover
            local item=CreateFrame('Button',nil,UIParent,'SecureActionButtonTemplate')
            ui.StyleTargetButton(item,1,1,1)
            item.inBar=true; NS.ItemTree.target=item
            ui.LayoutTargetButtons(app)
            hover.mouseOver=true
            hover.scripts.OnUpdate(hover)
            assert(not lock:IsShown())
            shiftDown=true; hover.scripts.OnUpdate(hover)
            assert(lock:IsShown() and hover.last==item)
            assert(lock:GetWidth()==22 and lock:GetHeight()==26 and lock.point[3]=='TOPLEFT')
            hover.mouseOver=false; lock.mouseOver=true
            hover.scripts.OnUpdate(hover)
            assert(lock:IsShown())
            lock.mouseOver=false; hover.scripts.OnUpdate(hover)
            assert(not lock:IsShown())
            hover.mouseOver=true; hover.scripts.OnUpdate(hover)
            lock.scripts.OnClick(lock)
            assert(app.db.masterLocked and ui.masterSettings.lockToggle:GetChecked())
            assert(master.passThrough[1]=='RightButton' and item.passThrough[1]=='RightButton')
            item.scripts.OnDragStart(item)
            assert(not master.moving)
            event('ADDON_LOADED','QuestTargets')
            assert(app.db.masterLocked)
            assert(ui.BeginMasterMove(app))
            hover.scripts.OnUpdate(hover)
            assert(not lock:IsShown())
            ui.EndMasterMove(app, false)
            hover.scripts.OnUpdate(hover)
            lock.scripts.OnClick(lock)
            assert(not app.db.masterLocked and #item.passThrough==0)
            item.scripts.OnDragStart(item)
            assert(master.moving)
            item.scripts.OnDragStop(item)
            combat=true; hover.scripts.OnUpdate(hover)
            assert(not lock:IsShown())
        ''')

    def test_retail_uses_live_quest_objectives_without_classic_database(self):
        self.lua.execute('''
            WOW_PROJECT_MAINLINE=1; WOW_PROJECT_ID=1
            StaticPopupDialogs={}; StaticPopup_Show=function() error('Retail popup') end
            LibQuestieDB={RequireContract=function() error('Classic database used on Retail') end}
            boot()
            assert(not StaticPopupDialogs.QUESTTARGETS_MISSING_QUESTIEDB)
            assert(NS.Database.Provider()==nil)
            assert(NS.Database.status==NS.L('dbRetail'))
            assert(NS.app.questEntries[1].title=='Wölfe im Wald')
            assert(NS.app.questEntries[1].nameList[1]=='Waldwolf')
            local row=NS.UI.rows[1]
            row.scripts.PreClick(row,'LeftButton',false)
            assert(row.attributes.macrotext1:find('/targetexact',1,true))
            assert(row.attributes.macrotext1:find('Waldwolf',1,true))
        ''')

    def test_retail_detection_works_without_project_constants(self):
        self.lua.execute('''
            GetBuildInfo=function() return '12.1.0','','',120100 end
            StaticPopupDialogs={}; StaticPopup_Show=function() error('Retail popup') end
            boot()
            assert(not StaticPopupDialogs.QUESTTARGETS_MISSING_QUESTIEDB)
            assert(NS.Database.status==NS.L('dbRetail'))
        ''')

    def test_forever_is_not_mistaken_for_retail_without_project_constants(self):
        self.lua.execute('''
            GetBuildInfo=function() return '1.60.1','','',16001 end
            assert(not NS.Core.IsRetail())
        ''')

    def test_new_master_scale_reference_and_saved_size_migration(self):
        self.lua.execute('''
            QuestTargetsDB={masterAppearance='classic',masterScaleX=1.2,masterScaleY=1.5,
                masterModernScale=1.8,masterText='Legacy label',masterPosition={x=125,y=-42},
                masterBorder=true}
            boot()
            local app, master = NS.app, NS.UI.master
            assert(app.db.masterAppearance==nil and app.db.masterText==nil)
            assert(app.db.masterScaleX==nil and app.db.masterScaleY==nil)
            assert(app.db.masterModernScale==1.2 and app.db.masterScaleBaseline==2)
            assert(master.width==72 and master.height==72 and not master.text)
            assert(master.point[4]==125 and master.point[5]==-42)
            assert(app.db.masterDividers==true)
            app.db.masterDividers=false
            event('ADDON_LOADED','QuestTargets')
            assert(app.db.masterModernScale==1.2 and not app.db.masterDividers)
        ''')

    def test_transparency_reveals_icon_over_window_and_marks_drag_area(self):
        self.lua.execute('''
            boot()
            local ui, app = NS.UI, NS.app
            ui.frame.mouseOver=false
            ui.transparencyButton.scripts.OnClick()
            assert(ui.dragHint:GetAlpha()==0)
            flush()
            assert(ui.transparencyButton:GetAlpha()==0)
            ui.frame.mouseOver=true
            ui.frame.scripts.OnUpdate(ui.frame,0.2)
            assert(ui.transparencyButton:GetAlpha()==1)
            assert(ui.dragHint:GetAlpha()==0.1)
            ui.frame.mouseOver=false
            ui.frame.scripts.OnUpdate(ui.frame,0.2)
            assert(ui.dragHint:GetAlpha()==0)
            flush()
            assert(ui.transparencyButton:GetAlpha()==0)
            ui.transparencyButton.scripts.OnClick()
            assert(ui.dragHint:GetAlpha()==0)
        ''')

    def test_quest_update_does_not_interrupt_window_drag(self):
        self.lua.execute('''
            boot()
            local ui, app = NS.UI, NS.app
            ui.drag.scripts.OnDragStart()
            assert(ui.moving and ui.frame.moving)
            quests[3]={questID=3,title='Neue Quest',objectives={
                {type='monster',text='Spinne getötet: 0/2',numFulfilled=0,numRequired=2,finished=false}}}
            event('QUEST_ACCEPTED',3)
            flush()
            assert(ui.moving and ui.frame.moving)
            assert(app.dirty)
            app.pendingData=true
            tick()
            assert(ui.moving and ui.frame.moving)
            ui.drag.scripts.OnDragStop()
            flush()
            assert(not ui.moving and not ui.frame.moving)
            assert(not app.dirty and #app.questEntries==3)
        ''')

    def test_quest_window_has_two_adjacent_footer_buttons(self):
        self.lua.execute('''
            boot()
            local ui=NS.UI
            assert(ui.frame.height==354)
            assert(ui.refreshButton==nil)
            assert(ui.settingsButton.width==117 and ui.feedbackButton.width==117)
            assert(ui.settingsButton.point[1]=='BOTTOMLEFT')
            assert(ui.settingsButton.point[2]==10 and ui.settingsButton.point[3]==8)
            assert(ui.feedbackButton.point[1]=='BOTTOMRIGHT')
            assert(ui.feedbackButton.point[2]==-28 and ui.feedbackButton.point[3]==8)
            assert(ui.feedbackButton.text==NS.L('feedback'))
        ''')

    def test_quest_buttons_have_native_pressed_state(self):
        self.lua.execute('''boot()
            for _,row in ipairs(NS.UI.rows) do
                assert(row.icon==row:GetNormalTexture())
                assert(row.pushedIcon==row:GetPushedTexture())
                assert(row.icon.width==22 and row.icon.height==22)
                assert(row.pushedIcon.width==20 and row.pushedIcon.height==20)
                assert(not row.icon.allPoints and not row.pushedIcon.allPoints)
                assert(row.pushedIcon.point[3]==-1)
                assert(row.fontString==row.number)
                assert(row.pushedTextOffset[1]==1 and row.pushedTextOffset[2]==-1)
                assert(row.icon.atlas==row.pushedIcon.atlas)
                assert(row.scripts.OnMouseDown==nil and row.scripts.OnMouseUp==nil)
            end
            local row=NS.UI.rows[1]
            row.scripts.PreClick(row,'LeftButton',false)
            assert(row.attributes.macrotext1)
        ''')

    def test_transparency_icon_toggles_window_chrome_immediately(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local ui, app = NS.UI, NS.app
            assert(not app.db.transparencyMode)
            assert(not ui.settings.transparencyToggle:GetChecked())
            assert(ui.transparencyButton.point[1]=='TOPLEFT')
            assert(ui.transparencyButton.point[2]==10)
            assert(ui.transparencyButton.point[3]==-1)
            assert(ui.closeButton.width==20 and ui.closeButton.height==20)
            assert(ui.closeButton.point[1]=='TOPRIGHT')
            assert(ui.closeButton.point[2]==-6 and ui.closeButton.point[3]==-1)
            assert(ui.scrollbar.point[3]==-82 and ui.scrollbar.height==206)
            assert(ui.transparencyButton.normalTexture.texture:find('TransparencyEye',1,true))
            assert(ui.transparencyButton.pushedTexture.texture:find('TransparencyEye',1,true))
            assert(type(ui.frame.scripts.OnUpdate)=='function')
            ui.transparencyButton.scripts.OnClick()
            assert(app.db.transparencyMode and ui.settings.transparencyToggle:GetChecked())
            assert(ui.chromeAlpha == 0)
            assert(ui.frame.NineSlice:GetAlpha() == 0)
            assert(ui.settingsButton:GetAlpha() == 0)
            assert(ui.transparencyButton:GetAlpha() == 1)
            assert(not ui.transparencyButton:GetNormalTexture().desaturated)
            assert(QuestTargetsTarget1:GetAlpha() == 1)
            assert(QuestTargetsTarget1.nameText:GetAlpha() == 1)
            assert(QuestTargetsTarget1.attributes.macrotext1)
            ui.transparencyButton.mouseOver = true
            ui.transparencyButton.scripts.OnEnter(ui.transparencyButton)
            assert(GameTooltip.lines[1] == NS.L('transparencyIconTip'))
            flush()
            assert(ui.transparencyButton:GetAlpha() == 1)
            ui.transparencyButton.mouseOver = false
            ui.transparencyButton.scripts.OnLeave(ui.transparencyButton)
            flush()
            assert(ui.transparencyButton:GetAlpha() == 0)
            ui.transparencyButton.mouseOver = true
            ui.transparencyButton.scripts.OnEnter(ui.transparencyButton)
            assert(ui.transparencyButton:GetAlpha() == 1)
            ui.settings.transparencyToggle.scripts.OnClick()
            flush()
            assert(ui.chromeAlpha == 1 and not app.db.transparencyMode)
            assert(ui.frame.NineSlice:GetAlpha() == 1)
            assert(ui.transparencyButton:GetNormalTexture().desaturated)
        ''')

    def test_settings_tabs_keep_language_inside_scroll_content_and_cancel_capture(self):
        self.lua.execute('''
            Settings.RegisterCanvasLayoutSubcategory=function() error('unexpected subcategory') end
            boot(); NS.UI.Settings(NS.app)
            local panel=NS.UI.settings
            assert(#panel.tabs==4 and panel.selectedTab==1)
            assert(panel.languageDropdown.parent.parent==panel.pages[1].content)
            for index,page in ipairs(panel.pages) do
                assert(page.scroll.scrollChild==page.content)
                assert(page.scroll.shown==(index==1))
                page.scroll.scripts.OnSizeChanged(page.scroll,480)
                assert(page.content.width==480)
            end
            NS.UI.SelectSettingsTab(4)
            assert(panel.pages[4].scroll.shown and not panel.pages[1].scroll.shown)
            assert(panel.hotkey.text==NS.L('unbound'))
            assert(panel.hotkeyAction.text==NS.L('masterDefault'))
            panel.hotkey.scripts.OnClick(panel.hotkey)
            NS.UI.SelectSettingsTab(1)
            assert(not panel.hotkey.listening and panel.hotkey.text==NS.L('unbound'))
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton')==nil)
            NS.UI.SelectSettingsTab(4)
            panel.hotkey.scripts.OnClick(panel.hotkey)
            ctrlDown=true
            panel.hotkey.scripts.OnKeyDown(panel.hotkey,'F')
            assert(panel.hotkey.text=='CTRL-F')
            NS.app.db.language='deDE'; NS.UI.ApplyLanguage(NS.app)
            assert(panel.tabs[1].text=='Allgemein')
            assert(panel.hotkeyAction.text==NS.L('masterDefault'))
            assert(panel.hotkey.text=='CTRL-F')
        ''')

    def test_focus_quest_keeps_master_independent_and_toggles_on_right_icon_click(self):
        self.lua.execute('''
            boot()
            local app, ui = NS.app, NS.UI
            local row = ui.rows[1]
            local masterMacro = ui.master.attributes.macrotext1
            assert(not app.db.focusQuestID and app.db.focusMarkEnabled==nil)
            row.icon.mouseOver = true
            row.scripts.PreClick(row, 'RightButton', false)
            row.scripts.PostClick(row, 'RightButton', false)
            assert(app.db.focusQuestID == row.entry.questID)
            assert(#openedQuestIDs == 0)
            assert(ui.master.attributes.macrotext1 == masterMacro)
            assert(ui.focusButton.attributes.macrotext1:find(row.entry.nameList[1], 1, true))
            assert(row.focusMark:IsShown())
            row.scripts.PreClick(row, 'RightButton', false)
            row.scripts.PostClick(row, 'RightButton', false)
            assert(not app.db.focusQuestID and not row.focusMark:IsShown())
            row.icon.mouseOver = false
            row.scripts.PreClick(row, 'LeftButton', false)
            assert(row.attributes.macrotext1:find(row.entry.nameList[1], 1, true))
        ''')

    def test_controller_capture_binds_both_actions_and_releases_input(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            local panel=NS.UI.settings
            local actions={
                {panel.hotkey, 'PAD1', 'CLICK QuestTargetsMaster:LeftButton', 'CTRL-PAD1'},
                {panel.focusHotkey, 'PAD2', 'CLICK QuestTargetsFocused:LeftButton', 'PAD2'},
            }
            for _,action in ipairs(actions) do
                local capture,key,command,expected=unpack(action)
                capture.EnableGamePadButton=function(self,enabled) self.gamepadEnabled=enabled end
                capture.scripts.OnClick(capture)
                assert(capture.scripts.OnGamePadButtonDown, 'controller input was not registered')
                assert(capture.gamepadEnabled)
                IsControlKeyDown=function() return capture==panel.hotkey end
                capture.scripts.OnGamePadButtonDown(capture,key)
                IsControlKeyDown=function() return false end
                assert(GetBindingKey(command)==expected, 'controller button was not bound')
                assert(not capture.gamepadEnabled and not capture.scripts.OnGamePadButtonDown)
                capture.scripts.OnClick(capture)
                capture.scripts.OnKeyDown(capture,'ESCAPE')
                assert(GetBindingKey(command)==expected)
                assert(not capture.gamepadEnabled and not capture.scripts.OnGamePadButtonDown)
                capture.scripts.OnClick(capture)
                panel.pages[4].scroll.scripts.OnHide()
                assert(not capture.gamepadEnabled and not capture.scripts.OnGamePadButtonDown)
                capture.scripts.OnClick(capture)
                combat=true
                capture.scripts.OnGamePadButtonDown(capture,'PAD3')
                assert(GetBindingKey(command)==expected, 'binding changed during combat')
                assert(not capture.gamepadEnabled)
                combat=false
            end
            assert(NS.app.db.focusHotkeyKey=='PAD2')
        ''')

    def test_primary_and_secondary_bindings_preserve_each_other_and_focus_reload(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            local panel=NS.UI.settings
            assert(panel.hotkey2 and panel.focusHotkey2, 'second binding controls missing')
            local function bind(control,key)
                control.scripts.OnClick(control)
                control.scripts.OnKeyDown(control,key)
            end
            bind(panel.hotkey,'F'); bind(panel.hotkey2,'PAD1')
            bind(panel.focusHotkey,'H'); bind(panel.focusHotkey2,'PAD2')
            local first,second=GetBindingKey('CLICK QuestTargetsMaster:LeftButton')
            assert(first=='F' and second=='PAD1')
            assert(panel.hotkey.text=='F' and panel.hotkey2.text=='PAD1')
            assert(NS.app.db.focusHotkeyKey=='H' and NS.app.db.focusHotkeyKey2=='PAD2')
            -- WoW retains its binding set across reload; reset only addon state.
            NS.app.focusBindingsInitialized=nil
            NS.UI.SyncFocusBinding(NS.app)
            first,second=GetBindingKey('CLICK QuestTargetsFocused:LeftButton')
            assert(first=='H' and second=='PAD2', 'second focus binding was lost on refresh')
            bind(panel.hotkey,'J')
            first,second=GetBindingKey('CLICK QuestTargetsMaster:LeftButton')
            assert(first=='J' and second=='PAD1', 'editing primary erased secondary')
            bind(panel.hotkey2,'DELETE')
            first,second=GetBindingKey('CLICK QuestTargetsMaster:LeftButton')
            assert(first=='J' and second==nil)
            bind(panel.focusHotkey,'DELETE')
            first,second=GetBindingKey('CLICK QuestTargetsFocused:LeftButton')
            assert(first=='PAD2' and second==nil, 'remaining binding should move to first slot')
            assert(NS.app.db.focusHotkeyKey=='PAD2' and NS.app.db.focusHotkeyKey2==nil)
            bind(panel.hotkey2,'J')
            first,second=GetBindingKey('CLICK QuestTargetsMaster:LeftButton')
            assert(first=='J' and second==nil, 'duplicate binding must not occupy both slots')
            panel.hotkey.scripts.OnClick(panel.hotkey)
            panel.focusHotkey2.scripts.OnClick(panel.focusHotkey2)
            assert(not panel.hotkey.listening and panel.focusHotkey2.listening)
            NS.UI.SelectSettingsTab(1)
            assert(not panel.focusHotkey2.listening)
            prepareBindingPopups()
            bind(panel.hotkey2,'PAD2')
            assert(GetBindingAction('PAD2')=='CLICK QuestTargetsFocused:LeftButton')
            acceptBindingPopup()
            NS.UI.SyncFocusBinding(NS.app)
            first,second=GetBindingKey('CLICK QuestTargetsMaster:LeftButton')
            assert(first=='J' and second=='PAD2', 'focus refresh reclaimed a reassigned key')
            assert(NS.app.db.focusHotkeyKey==nil and NS.app.db.focusHotkeyKey2==nil)
        ''')

    def test_failed_binding_assignment_preserves_both_slots_and_saved_focus(self):
        self.lua.execute('''
            QuestTargetsDB={focusHotkeyKey='H',focusHotkeyKey2='PAD2'}
            boot(); NS.UI.Settings(NS.app)
            local bind=SetBindingClick
            SetBindingClick=function(key,...)
                if key=='INVALID' then return false end
                return bind(key,...)
            end
            local control=NS.UI.settings.focusHotkey2
            control.scripts.OnClick(control)
            control.scripts.OnKeyDown(control,'INVALID')
            local first,second=GetBindingKey('CLICK QuestTargetsFocused:LeftButton')
            assert(first=='H' and second=='PAD2')
            assert(NS.app.db.focusHotkeyKey=='H' and NS.app.db.focusHotkeyKey2=='PAD2')
        ''')

    def test_focus_hotkey_is_always_available_when_assigned(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            local app, ui = NS.app, NS.UI
            assert(GetBindingKey('CLICK QuestTargetsFocused:LeftButton') == nil)
            assert(ui.settings.focusHotkeyToggle == nil)
            assert(ui.settings.focusHotkey.scripts.OnEnter)
            ui.settings.focusHotkey.scripts.OnEnter(ui.settings.focusHotkey)
            assert(GameTooltip.lines[1] == NS.L('focusHotkeyTip'))
            ui.settings.focusHotkey.scripts.OnLeave(ui.settings.focusHotkey)
            ui.settings.focusHotkey.scripts.OnClick(ui.settings.focusHotkey)
            ui.settings.focusHotkey.scripts.OnKeyDown(ui.settings.focusHotkey, 'H')
            assert(app.db.focusHotkeyKey == 'H')
            assert(GetBindingKey('CLICK QuestTargetsFocused:LeftButton') == 'H')
            ui.settings.focusHotkey.scripts.OnClick(ui.settings.focusHotkey)
            ui.settings.focusHotkey.scripts.OnKeyDown(ui.settings.focusHotkey, 'DELETE')
            assert(GetBindingKey('CLICK QuestTargetsFocused:LeftButton') == nil)
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == nil)
        ''')

    def test_focus_clears_when_quest_leaves_log(self):
        self.lua.execute('''
            boot()
            local app, ui = NS.app, NS.UI
            ui.ToggleFocus(app, ui.rows[1].entry)
            assert(app.db.focusQuestID == 1)
            quests[1], quests[2] = quests[2], nil
            app:Refresh()
            assert(app.db.focusQuestID == nil)
            assert(ui.focusButton.attributes.macrotext1 == '')
        ''')

    def test_master_tooltip_shows_target_mode_and_current_drag_instruction(self):
        self.lua.execute('''
            boot()
            local app, button = NS.app, NS.UI.master
            app.db.showTooltips=true
            for _, allModules in ipairs({true, false}) do
                for _, locked in ipairs({true, false}) do
                    app.db.masterAllModules=allModules
                    app.db.masterLocked=locked
                    GameTooltip:ClearLines()
                    button.scripts.OnEnter(button)
                    assert(GameTooltip.text=='Next Target')
                    assert(GameTooltip.lines[1]==NS.L(allModules and 'masterTip1' or 'masterQuestOnlyTip'))
                    assert(#GameTooltip.lines==2)
                    assert(GameTooltip.lines[2]==NS.L(locked and 'masterLockTip' or 'masterTip2'))
                    assert(GameTooltip.lines[2]:find('right mouse button',1,true))
                end
            end
        ''')

    def test_combat_during_window_drag_releases_refresh_gate_and_saves_position_later(self):
        self.lua.execute('''
            boot()
            local ui, app = NS.UI, NS.app
            ui.drag.scripts.OnDragStart()
            assert(ui.moving and ui.frame.moving)
            combat=true
            event('PLAYER_REGEN_DISABLED')
            assert(not ui.moving and ui.movingPending and app.dirty)
            ui.drag.scripts.OnDragStop()
            assert(not ui.moving and ui.movingPending)
            combat=false
            event('PLAYER_REGEN_ENABLED')
            assert(not ui.moving and not ui.movingPending and not ui.frame.moving)
            assert(type(app.db.position)=='table' and not app.dirty)
            event('QUEST_LOG_UPDATE'); flush()
            assert(not app.dirty)
        ''')

    def test_all_flavors_use_native_compact_controls_and_keep_saved_values(self):
        for flavor, interface in (('Forever', 16001), ('Retail', 120105),
                                  ('Classic', 11509), ('TBC', 20506), ('Mists', 50504)):
            with self.subTest(flavor=flavor):
                self.setUp()
                self.lua.globals().settingsTestInterface = interface
                self._check_native_compact_settings()

    def _check_native_compact_settings(self):
        self.lua.execute('''
            loadedAddons={Questie=false,RXPGuides=false}
            C_AddOns={IsAddOnLoaded=function(name) return loadedAddons[name] end}
            GetBuildInfo=function() return '', '', '', settingsTestInterface end
            local supportsPing=settingsTestInterface==16001 or settingsTestInterface==120105
            C_Ping=supportsPing and {SendMacroPing=function() error('Insecure ping') end} or nil
            StaticPopupDialogs={}
            StaticPopup_Show=function(key) shownPopup=key end
            local categoryID=71
            local layout={initializers={}}
            function layout:AddInitializer(item) self.initializers[#self.initializers+1]=item end
            function layout:GetInitializers() return self.initializers end
            local function initializer(data)
                return {data=data, GetName=function(self)
                    return self.data.setting and self.data.setting:GetName() or self.data.name
                end, AddModifyPredicate=function(self, predicate)
                    self.predicate=predicate
                end, SetParentInitializer=function(self, parent)
                    self.parentInitializer=parent
                end, AddShownPredicate=function(self, predicate)
                    self.shownPredicate=predicate
                end}
            end
            CreateSettingsListSectionHeaderInitializer=function(name)
                return initializer({name=name, kind='section'})
            end
            CreateSettingsButtonInitializer=function(name, text, callback, description)
                return initializer({name=name, buttonText=text, buttonClick=callback,
                    tooltip=description, kind='action'})
            end
            SettingsListElementMixin={
                OnLoad=function() end,
                Init=function(self,item)
                    self.data=item.data
                    if self.Text then
                        self.Text:SetPoint('LEFT',37,0)
                        self.Text:SetPoint('RIGHT',self,'CENTER',-85,0)
                    end
                end,
                Release=function(self) self.data=nil end}
            MinimalSliderWithSteppersMixin={Label={Right=1}}
            local headerTitle=CreateFrame('Frame',nil,UIParent):CreateFontString(nil,'ARTWORK')
            SettingsPanel={RepairDisplay=function() error('Direct native panel refresh') end,
                GetSettingsList=function() return {Header={Title=headerTitle}} end,
                DisplayCategory=function(_,category) headerTitle:SetText(category.name) end}
            local nativeDisplayCategory=SettingsPanel.DisplayCategory
            SettingsInbound={RepairDisplay=function() nativeRepairs=(nativeRepairs or 0)+1 end}
            Settings={VarType={Boolean='boolean', Number='number'},
                CreateElementInitializer=function(template,data)
                    local item=initializer(data)
                    item.data.kind=template=='QuestTargetsBindingSettingTemplate' and 'button' or 'editbox'
                    item.template=template
                    return item
                end,
                RegisterVerticalLayoutCategory=function(name)
                    local category={name=name, layout=layout, GetID=function() return categoryID end,
                        SetName=function(self, value) self.name=value end}
                    nativeCategory=category
                    return category,layout
                end,
                RegisterProxySetting=function(category, variable, kind, name, default, get, set)
                    -- Forever validates a function-valued name without securecallfunction
                    -- before registering it in the map read by ActionBar clicks.
                    assert(type(name)=='string', 'Proxy setting name must be resolved before registration')
                    local item={variable=variable,kind=kind,name=name,default=default,
                        GetValue=get,SetValue=function(first, second)
                            if second~=nil then set(second) else set(first) end
                        end,GetName=function() return name end}
                    nativeSettings[variable]=item
                    return item
                end,
                CreateCheckbox=function(category, value, description)
                    local item=initializer({kind='checkbox',setting=value,
                        description=description})
                    category.layout:AddInitializer(item)
                    return item
                end,
                CreateSliderOptions=function(minimum,maximum,step)
                    return {min=minimum,max=maximum,step=step,
                        SetLabelFormatter=function() end}
                end,
                CreateSlider=function(category,value,options,description)
                    local item=initializer({kind='slider',setting=value,options=options,description=description})
                    category.layout:AddInitializer(item)
                    return item
                end,
                CreateDropdown=function(category,value,choices,description)
                    local item=initializer({kind='dropdown',setting=value,choices=choices,description=description})
                    category.layout:AddInitializer(item)
                    return item
                end,
                CreateControlTextContainer=function()
                    return {data={},Add=function(self,value,label)
                        self.data[#self.data+1]={value=value,label=label}
                    end,GetData=function(self) return self.data end}
                end,
                RegisterAddOnCategory=function(category) nativeRegistered=category; nativeRegistrations=(nativeRegistrations or 0)+1 end,
                OpenToCategory=function(id) assert(id==categoryID); nativeOpened=id end}
            local buttonsLayout={initializers={},AddInitializer=layout.AddInitializer,GetInitializers=layout.GetInitializers}
            Settings.RegisterVerticalLayoutSubcategory=function(parent,name)
                assert(parent==nativeCategory)
                return {name=name,layout=buttonsLayout,SetName=function(self,value) self.name=value end},buttonsLayout
            end
            if settingsTestInterface==16001 then
                SettingsListMixin={}
                local nextLayout=0
                CreateVerticalLayout=function()
                    nextLayout=nextLayout+1
                    return ({layout,buttonsLayout})[nextLayout]
                end
                local createFrame=CreateFrame
                CreateFrame=function(kind,name,parent,template)
                    if template~='SettingsListTemplate' then return createFrame(kind,name,parent,template) end
                    local list=createFrame(kind,name,parent)
                    list.template=template
                    list.Header={Title=list:CreateFontString(nil,'ARTWORK'),
                        DefaultsButton=createFrame('Button',nil,list,'UIPanelButtonTemplate')}
                    list.Header.DefaultsButton.Text=list:CreateFontString(nil,'ARTWORK')
                    function list:Display(rows) self.rows=rows end
                    function list:RepairDisplay(pageLayout)
                        assert(self.rows==pageLayout:GetInitializers())
                        nativeRepairs=(nativeRepairs or 0)+1
                    end
                    return list
                end
                SettingsInbound.RepairDisplay=function() error('Shared Settings list refresh') end
                Settings.RegisterVerticalLayoutCategory=function() error('Shared Settings list registration') end
                Settings.CreateCheckboxInitializer=function(value,options,description)
                    return initializer({kind='checkbox',setting=value,description=description})
                end
                Settings.CreateSliderInitializer=function(value,options,description)
                    return initializer({kind='slider',setting=value,options=options,description=description})
                end
                Settings.CreateDropdownInitializer=function(value,choices,description)
                    return initializer({kind='dropdown',setting=value,choices=choices,description=description})
                end
                Settings.RegisterCanvasLayoutCategory=function(page,name)
                    nativeCategory={name=name,page=page,GetID=function() return categoryID end,
                        SetName=function(self,value) self.name=value end}
                    return nativeCategory
                end
                Settings.RegisterCanvasLayoutSubcategory=function(parent,page,name)
                    assert(parent==nativeCategory)
                    return {name=name,page=page,SetName=function(self,value) self.name=value end}
                end
                Settings.OpenToCategory=function(id)
                    assert(id==categoryID)
                    nativeOpened=id
                    nativeCategory.page:Show()
                    nativeCategory.page.scripts.OnShow()
                end
            end
            nativeSettings={}
            boot()
            assert(nativeCategory and nativeRegistered==nativeCategory, 'Category missing at login')
            assert(layout.initializers[1].data.name=='General', 'The main page must begin with General')
            assert(NS.UI.nativeButtonsCategory.name=='Buttons & Bar', 'The subpage must be named Buttons & Bar')
            assert(nativeOpened==nil, 'Login must not open Options')
            assert(not QuestTargetsPatchNotes)
            assert(NS.UI.nativePatchNotes.data.buttonText=='View')
            NS.UI.nativePatchNotes.data.buttonClick()
            local openedFeedback
            StaticPopup_Show=function(key) openedFeedback=key end
            NS.UI.nativeFeedback.data.buttonClick()
            assert(openedFeedback=='QUESTTARGETS_FEEDBACK_LINK')
            StaticPopup_Show=function(key) shownPopup=key end
            assert(QuestTargetsPatchNotes:IsShown())
            assert(QuestTargetsPatchNotes.scripts.OnUpdate==nil)
            QuestTargetsPatchNotes.close.scripts.OnClick()
            assert(not QuestTargetsPatchNotes:IsShown())
            if QuestTargetsTutorial and QuestTargetsTutorial:IsShown() then
                QuestTargetsTutorial.close.scripts.OnClick()
            end
            NS.UI.nativeIntro.data.buttonClick()
            assert(QuestTargetsTutorial:IsShown())
            QuestTargetsTutorial.close.scripts.OnClick()
            event('PLAYER_LOGIN'); event('ADDON_LOADED','Blizzard_Settings')
            assert(nativeRegistrations==1, 'Duplicate category registration')
            NS.UI.Settings(NS.app)
            assert(nativeRegistered==nativeCategory and nativeOpened==categoryID)
            assert(NS.UI.settings==nil and NS.UI.nativeCategory==nativeCategory)
            C_AddOns.GetAddOnMetadata=function() return '1.5.1-preview' end
            SettingsPanel:DisplayCategory(nativeCategory)
            assert(nativeCategory.name=='Next', 'Version leaked into sidebar')
            if settingsTestInterface==16001 then
                assert(SettingsPanel.DisplayCategory==nativeDisplayCategory, 'Hooked shared Forever Settings panel')
                assert(headerTitle.text=='Next', 'Native heading should originate from Blizzard')
                nativeCategory.page.scripts.OnShow()
                assert(nativeCategory.page.Header.Title.text=='Next 1.5.1-preview')
                assert(nativeCategory.page.rows==layout.initializers)
            else
                assert(headerTitle.text=='Next 1.5.1-preview', 'Missing heading version')
            end
            SettingsPanel:DisplayCategory({name='Other addon'})
            assert(headerTitle.text=='Other addon', 'Changed another addon heading')
            C_AddOns.GetAddOnMetadata=nil
            if settingsTestInterface==16001 then
                local buttonsPage=NS.UI.nativeButtonsCategory.page
                buttonsPage:Show()
                buttonsPage.scripts.OnShow()
                assert(buttonsPage.rows==buttonsLayout.initializers and buttonsPage~=nativeCategory.page)
            end
            local function verifyPage(pageLayout, expected)
                local rows=pageLayout.initializers
                assert(#rows==#expected, 'Wrong number of options')
                for index,key in ipairs(expected) do
                    local item=rows[index]
                    local data=item.data
                    if data.setting then
                        assert(data.setting.variable=='QUESTTARGETS_'..key, key)
                        assert(data.description and data.description~='', 'Missing tooltip: '..key)
                    else
                        assert(data.name==NS.L(key), key)
                        if data.kind~='section' then assert(data.tooltip or data.help, key) end
                    end
                end
            end
            verifyPage(layout, {'general','language','showMinimap','patchNotes','introSettings','feedback',
                'questWindowSection','showMenu','transparencyMode','windowSize','targetMarkers',
                'feedbackMaster','feedbackRestedXP','feedbackItemTree','feedbackRareScanner','feedbackFocus',
                'window','feedbackQuestie','feedbackEllesmere','preferredRaidIcon','muteDeadTargetSound',
                'hotkeys','masterDefault','focusHotkey','itemTreeBinding','rareScannerBinding'})
            verifyPage(buttonsLayout, {'barModulesSection','showMaster','masterAllModules','polestarIntegration','followTheArrowIntegration','restedXPIntegration',
                'showItemTreeButton','showRareScannerButton','rareScannerZone','barAppearanceSection',
                'masterOrientation','buttonSize','masterSpacing','masterBackground','masterBorder','masterDividers',
                'masterLocked','masterMove','integrationSection','showTooltips',
                'questieTrackerButtons','questieTrackerOffset','ellesmereTrackerButtons','ellesmereTrackerOffset','flareUITrackerButtons'})
            local feedbackMasterRow=layout.initializers[12]
            local feedbackDescription=feedbackMasterRow.data.description
            assert(feedbackDescription:find('255',1,true))
            assert((feedbackDescription:find('Show Pings in Chat',1,true)~=nil)==supportsPing)
            local controls={}
            for _,item in ipairs(buttonsLayout.initializers) do
                if item.data.setting then controls[item.data.setting.variable:gsub('^QUESTTARGETS_','')]=item end
            end
            for child,parent in pairs({masterAllModules='showMaster',polestarIntegration='showMaster',followTheArrowIntegration='showMaster',rareScannerZone='showRareScannerButton',
                questieTrackerOffset='questieTrackerButtons',ellesmereTrackerOffset='ellesmereTrackerButtons'}) do
                assert(controls[child].parentInitializer==controls[parent] and controls[child].predicate, child)
            end
            local moduleSetting=nativeSettings.QUESTTARGETS_masterAllModules
            assert(moduleSetting.GetValue()==true and controls.masterAllModules.predicate())
            moduleSetting.SetValue(false)
            assert(NS.app.db.masterAllModules==false and moduleSetting.GetValue()==false)
            moduleSetting.SetValue(true)
            assert(NS.app.db.masterAllModules==true)
            assert(not controls.polestarIntegration.predicate())
            assert(not controls.followTheArrowIntegration.predicate())
            assert(not controls.rareScannerZone.predicate())
            assert(nativeSettings.QUESTTARGETS_showRareScannerButton.default==false)
            assert(not nativeSettings.QUESTTARGETS_showRareScannerButton.GetValue())
            local zoneAvailable, markingAvailable=NS.RareScanner.ZoneAvailable,NS.RareScanner.MarkingAvailable
            NS.RareScanner.ZoneAvailable=function() return true end
            NS.RareScanner.MarkingAvailable=function() return true end
            assert(controls.rareScannerZone.predicate())
            NS.app.db.rareScannerButton=false
            assert(not controls.rareScannerZone.predicate())
            assert(nativeSettings.QUESTTARGETS_showRareScannerButton.default==false)
            assert(not nativeSettings.QUESTTARGETS_showRareScannerButton.GetValue())
            NS.app.db.rareScannerButton=true
            NS.RareScanner.ZoneAvailable,NS.RareScanner.MarkingAvailable=zoneAvailable,markingAvailable
            local allOptions={}
            for _,layoutToRead in ipairs({layout,buttonsLayout}) do
                for _,item in ipairs(layoutToRead.initializers) do allOptions[#allOptions+1]=item end
            end
            local masterFeedback=nativeSettings.QUESTTARGETS_feedbackMaster
            local itemTreeFeedback=nativeSettings.QUESTTARGETS_feedbackItemTree
            assert(masterFeedback.GetValue()==2 and itemTreeFeedback.GetValue()==2)
            masterFeedback.SetValue(1)
            assert(masterFeedback.GetValue()==1 and itemTreeFeedback.GetValue()==2)
            if supportsPing then
                masterFeedback.SetValue(3)
                assert(masterFeedback.GetValue()==3 and itemTreeFeedback.GetValue()==2)
            end
            local polestarSetting=nativeSettings.QUESTTARGETS_polestarIntegration
            assert(polestarSetting.GetValue()==false)
            polestarSetting.SetValue(true)
            assert(not NS.app.db.polestarIntegration)
            loadedAddons.Polestar=true
            assert(controls.polestarIntegration.predicate())
            nativeSettings.QUESTTARGETS_showMaster.SetValue(false)
            assert(not controls.polestarIntegration.predicate())
            nativeSettings.QUESTTARGETS_showMaster.SetValue(true)
            polestarSetting.SetValue(true)
            assert(NS.app.db.polestarIntegration==true)
            polestarSetting.SetValue(false)
            assert(NS.app.db.polestarIntegration==false)
            local defaults = {showMenu=false, feedbackRareScanner=supportsPing and 3 or 1,
                muteDeadTargetSound=true, masterAllModules=true, masterDividers=true,
                showTooltips=true, ellesmereTrackerButtons=false, masterSpacing=0}
            for key, expected in pairs(defaults) do
                assert(nativeSettings['QUESTTARGETS_'..key].default==expected, key)
            end
            if settingsTestInterface==16001 then
                local app=NS.app
                local otherSetting=17
                nativeSettings.UNRELATED={SetValue=function() otherSetting=0 end}
                local oldPopup=StaticPopup_Show
                StaticPopup_Show=function(key)
                    assert(key=='NEXT_RESTORE_DEFAULTS', key)
                    shownPopup=key
                end
                for _,category in ipairs({nativeCategory,NS.UI.nativeButtonsCategory}) do
                    app.db.showTooltips=false
                    app.db.masterSpacing=19
                    app.db.ellesmereTrackerButtons=true
                    app.db.rareScannerButton=false
                    category.page.Header.DefaultsButton.scripts.OnClick()
                    assert(shownPopup=='NEXT_RESTORE_DEFAULTS')
                    assert(not app.db.showTooltips and app.db.masterSpacing==19)
                    combat=true
                    StaticPopupDialogs[shownPopup].OnAccept()
                    assert(app.db.masterSpacing==19)
                    combat=false
                    StaticPopupDialogs[shownPopup].OnAccept()
                    assert(app.db.showTooltips and app.db.masterSpacing==0)
                    assert(not app.db.ellesmereTrackerButtons and otherSetting==17)
                    assert(app.db.rareScannerButton==nil)
                end
                StaticPopup_Show=oldPopup
            end
            local soundSetting=nativeSettings.QUESTTARGETS_muteDeadTargetSound
            assert(soundSetting.GetValue()==true)
            soundSetting.SetValue(true)
            assert(NS.app.db.muteDeadTargetSound==true)
            soundSetting.SetValue(false)
            assert(NS.app.db.muteDeadTargetSound==false)
            local moveRow=NS.UI.nativeMove
            assert(moveRow and moveRow.data.kind==NS.UI.nativePatchNotes.data.kind
                and moveRow.data.kind==NS.UI.nativeFeedback.data.kind)
            assert(moveRow.data.buttonText==NS.L('masterMoveStart'))
            assert(moveRow.data.tooltip==NS.L('masterMoveHelp'))
            moveRow.data.buttonClick()
            assert(NS.UI.masterMoveActive)
            NS.UI.EndMasterMove(NS.app,false)
            assert(not nativeSettings.QUESTTARGETS_focusMarkEnabled)
            local masterCheckbox
            for _,item in ipairs(allOptions) do
                if item.data.kind=='checkbox' and
                    item.data.setting.variable=='QUESTTARGETS_showMaster' then masterCheckbox=item end
            end
            assert(masterCheckbox and masterCheckbox.data.description==NS.L('masterMoveTip'))
            assert(not nativeSettings.QUESTTARGETS_focusHotkeyEnabled)
            assert(nativeSettings.QUESTTARGETS_questieTrackerButtons.GetValue()==false)
            nativeSettings.QUESTTARGETS_questieTrackerButtons.SetValue(false)
            assert(NS.app.db.questieTrackerButtons==nil) -- absent addon
            for _,item in ipairs(allOptions) do
                if item.data.setting and item.data.setting.variable=='QUESTTARGETS_questieTrackerOffset' then
                    assert(not item.predicate())
                end
            end
            loadedAddons.Questie=true
            assert(nativeSettings.QUESTTARGETS_questieTrackerButtons.GetValue()==true)
            nativeSettings.QUESTTARGETS_questieTrackerButtons.SetValue(false)
            assert(NS.app.db.questieTrackerButtons==false)
            nativeSettings.QUESTTARGETS_questieTrackerButtons.SetValue(true)
            nativeSettings.QUESTTARGETS_questieTrackerOffset.SetValue(15)
            assert(NS.app.db.questieTrackerOffset==15)
            loadedAddons.Questie=false
            for _,item in ipairs(allOptions) do
                assert(not (item.data.kind=='button' and item.data.name==NS.L('clear')))
            end
            local hotkeyButton
            for _,item in ipairs(allOptions) do
                if item.data.kind=='button' and item.data.name==NS.L('masterDefault') then hotkeyButton=item end
            end
            local capture=CreateFrame('Button',nil,UIParent)
            hotkeyButton.data.callback(capture)
            capture.scripts.OnKeyDown(capture,'G')
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton')=='G')
            hotkeyButton.data.callback(capture)
            capture.scripts.OnClick(capture,'Button4')
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton')=='BUTTON4')
            assert(not capture.listening and not capture.scripts.OnMouseWheel)
            hotkeyButton.data.callback(capture)
            capture.scripts.OnKeyDown(capture,'DELETE')
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton')==nil)
            local focusButton
            for _,item in ipairs(allOptions) do
                if item.data.kind=='button' and item.data.name==NS.L('focusHotkey') then focusButton=item end
            end
            assert(focusButton)
            assert(focusButton.data.tooltip==NS.L('focusHotkeyTip'))
            focusButton.data.callback(capture)
            capture.scripts.OnKeyDown(capture,'H')
            assert(GetBindingKey('CLICK QuestTargetsFocused:LeftButton')=='H')
            capture.EnableGamePadButton=function(self,enabled) self.gamepadEnabled=enabled end
            for _,action in ipairs({
                {hotkeyButton, 'PAD1', 'CLICK QuestTargetsMaster:LeftButton'},
                {focusButton, 'PAD2', 'CLICK QuestTargetsFocused:LeftButton'},
            }) do
                local initializer,key,command=unpack(action)
                initializer.data.callback(capture)
                assert(capture.scripts.OnGamePadButtonDown, 'native controller input was not registered')
                capture.scripts.OnGamePadButtonDown(capture,key)
                assert(GetBindingKey(command)==key)
                assert(not capture.gamepadEnabled and not capture.scripts.OnGamePadButtonDown)
                initializer.data.callback(capture)
                capture.scripts.OnHide(capture)
                assert(not capture.gamepadEnabled and not capture.scripts.OnGamePadButtonDown)
            end
            for _,action in ipairs({
                {hotkeyButton, 'PAD3', 'CLICK QuestTargetsMaster:LeftButton', 'PAD1'},
                {focusButton, 'PAD4', 'CLICK QuestTargetsFocused:LeftButton', 'PAD2'},
            }) do
                local initializer,key,command,primary=unpack(action)
                assert(initializer.template=='QuestTargetsBindingSettingTemplate')
                local row=CreateFrame('Frame',nil,UIParent)
                row.Text=row:CreateFontString()
                for name,value in pairs(QuestTargetsBindingSettingMixin) do row[name]=value end
                row:OnLoad(); row:Init(initializer)
                assert(#row.Buttons==2)
                assert(row.Buttons[1].template=='UIMenuButtonStretchTemplate')
                assert(row.Buttons[1].text==primary)
                local secondary=row.Buttons[2]
                secondary.EnableGamePadButton=function(self,enabled) self.gamepadEnabled=enabled end
                secondary.scripts.OnClick(secondary)
                secondary.scripts.OnGamePadButtonDown(secondary,key)
                local first,second=GetBindingKey(command)
                assert(first==primary and second==key)
                assert(row.Buttons[1].text==primary and secondary.text==key)
                secondary.scripts.OnClick(secondary)
                row:Release()
                assert(not secondary.listening and not secondary.gamepadEnabled)
                assert(not secondary.scripts.OnGamePadButtonDown)
            end
            assert(NS.app.db.focusHotkeyKey=='PAD2' and NS.app.db.focusHotkeyKey2=='PAD4')
            local itemTreeInitializer
            for _,item in ipairs(allOptions) do
                if item.data.name==NS.L('itemTreeBinding') then itemTreeInitializer=item end
            end
            assert(itemTreeInitializer)
            local itemTreeRow=CreateFrame('Frame',nil,UIParent)
            itemTreeRow.Text=itemTreeRow:CreateFontString()
            for name,value in pairs(QuestTargetsBindingSettingMixin) do itemTreeRow[name]=value end
            itemTreeRow:OnLoad(); itemTreeRow:Init(itemTreeInitializer)
            assert(itemTreeRow.Buttons[1].enabled==false and itemTreeRow.Buttons[2].enabled==false)
            assert(itemTreeRow.Text.textColor[1]==0.5)
            itemTreeInitializer.data.callback(itemTreeRow.Buttons[1],1)
            assert(not itemTreeRow.Buttons[1].listening)
            loadedAddons.ItemTree=true
            itemTreeRow:RefreshBindings()
            assert(itemTreeRow.Buttons[1].enabled and itemTreeRow.Buttons[2].enabled)
            assert(itemTreeRow.Text.textColor[1]==1)
            itemTreeRow:Release()
            local rareBinding
            for _,item in ipairs(allOptions) do
                if item.data.name==NS.L('rareScannerBinding') then rareBinding=item end
            end
            assert(rareBinding and not rareBinding.data.isEnabled())
            local markingAvailable=NS.RareScanner.MarkingAvailable
            NS.RareScanner.MarkingAvailable=function() return true end
            assert(rareBinding.data.isEnabled())
            rareBinding.data.callback(capture,2)
            capture.scripts.OnKeyDown(capture,'K')
            assert(GetBindingAction('K')=='CLICK QuestTargetsRareScannerMark:LeftButton')
            NS.RareScanner.MarkingAvailable=markingAvailable
            local rows={}
            for _,initializer in ipairs({hotkeyButton,focusButton}) do
                local row=CreateFrame('Frame',nil,UIParent)
                row.Text=row:CreateFontString()
                for name,value in pairs(QuestTargetsBindingSettingMixin) do row[name]=value end
                row:OnLoad(); row:Init(initializer)
                assert(row.Text.point[2]==row.Buttons[1], 'base Init overwrote binding row anchors')
                rows[#rows+1]=row
            end
            local secondary=rows[1].Buttons[2]
            prepareBindingPopups()
            secondary.scripts.OnClick(secondary)
            secondary.scripts.OnKeyDown(secondary,'PAD2')
            assert(rows[2].Buttons[1].text=='PAD2', 'binding changed before confirmation')
            acceptBindingPopup()
            assert(rows[2].Buttons[1].text=='PAD4', 'other row kept a reassigned key on screen')
            assert(rows[2].Buttons[2].text==NS.L('unbound'))
            bindings.JUMP={'SPACE'}
            local focusSecondary=rows[2].Buttons[2]
            focusSecondary.scripts.OnClick(focusSecondary)
            focusSecondary.scripts.OnKeyDown(focusSecondary,'SPACE')
            local pendingPopup=bindingPopup
            assert(pendingPopup.shown)
            for _,row in ipairs(rows) do row:Release() end
            StaticPopupDialogs[pendingPopup.which].OnAccept(pendingPopup,pendingPopup.data)
            assert(GetBindingAction('SPACE')=='JUMP', 'released row applied an obsolete confirmation')
            for _,item in ipairs(allOptions) do
                if item.data.kind=='checkbox' and
                    item.data.setting.variable=='QUESTTARGETS_restedXPIntegration' then
                    assert(item.predicate and not item.predicate())
                end
            end
            nativeSettings.QUESTTARGETS_restedXPIntegration.SetValue(true)
            assert(not NS.app.db.restedXPIntegration)
            loadedAddons.Questie=true; loadedAddons.RXPGuides=true
            assert(shownPopup~='QUESTTARGETS_QUESTIE_RELOAD' and not reloaded)
            for _,item in ipairs(allOptions) do
                if item.data.kind=='checkbox' and
                    item.data.setting.variable=='QUESTTARGETS_restedXPIntegration' then
                    assert(item.predicate())
                end
            end
            local rxpFrame=CreateFrame('Frame',nil,UIParent)
            local rxp={RXPFrame={activeSteps={{active=true,elements={{targets={'Guide NPC'}}}}}},
                targeting={activeTargetFrame=rxpFrame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            local master=NS.UI.master
            for i=1,3 do
                nativeSettings.QUESTTARGETS_restedXPIntegration.SetValue(true)
                assert(NS.app.db.restedXPIntegration and NS.RestedXP.active)
                assert(master.attributes.macrotext1:find('Guide NPC',1,true))
                assert(NS.RestedXP.button:IsShown())
                nativeSettings.QUESTTARGETS_restedXPIntegration.SetValue(false)
                assert(not NS.app.db.restedXPIntegration and not NS.RestedXP.active)
                assert(master.entry==master.defaultEntry)
                assert(not NS.RestedXP.button:IsShown())
            end
            assert(not reloaded)
            nativeSettings.QUESTTARGETS_transparencyMode.SetValue(true)
            assert(NS.app.db.transparencyMode)
            nativeSettings.QUESTTARGETS_windowSize.SetValue(1.25)
            assert(NS.app.db.menuScale==1.25)
            assert(not nativeSettings.QUESTTARGETS_masterAppearance and not nativeSettings.QUESTTARGETS_widthLabel
                and not nativeSettings.QUESTTARGETS_heightLabel)
            nativeSettings.QUESTTARGETS_buttonSize.SetValue(1.25)
            flush()
            assert(NS.UI.master.width==75 and NS.UI.master.height==75)
            nativeSettings.QUESTTARGETS_preferredRaidIcon.SetValue(4)
            assert(NS.app.db.markerIcon==4)
            nativeSettings.QUESTTARGETS_language.SetValue(2)
            assert(NS.app.db.language=='deDE' and nativeCategory.name=='Next')
            assert(focusButton.data.tooltip==NS.L('focusHotkeyTip'))
            assert(moveRow.data.name==NS.L('masterMove') and moveRow.data.tooltip==NS.L('masterMoveHelp'))
            assert(layout.initializers[1].data.name==NS.L('general'))
            assert(NS.UI.nativeButtonsCategory.name==NS.L('buttonsBar'))
            assert(NS.UI.nativeFeedback.data.name==NS.L('feedback'))
            assert(feedbackMasterRow.data.tooltip:find(NS.L('targetFeedbackLimitTip'),1,true))
            for _,item in ipairs(allOptions) do
                if item.data.setting then
                    local key=item.data.setting.variable:gsub('^QUESTTARGETS_', '')
                    assert(item:GetName()==NS.L(key), 'Setting label did not follow language change: '..key)
                end
            end
            assert(nativeRepairs and nativeRepairs>=2)
            NS.UI.Settings(NS.app)
            assert(nativeOpened==categoryID and nativeRegistered==nativeCategory)
        ''')

    def test_integration_options_are_disabled_without_their_addons(self):
        self.lua.execute('''
            loadedAddons={Questie=false,RXPGuides=false}
            C_AddOns={IsAddOnLoaded=function(name) return loadedAddons[name] end}
            boot(); NS.UI.Settings(NS.app)
            local panel=NS.UI.settings
            assert(panel.questieTrackerToggle.enabled==false and not panel.questieOffsetControl.slider.enabled)
            assert(panel.restedXPToggle.enabled==false)
            assert(panel.restedXPToggle.caption.textColor[1]==0.5)
            panel.restedXPToggle.scripts.OnClick()
            assert(not NS.app.db.restedXPIntegration)
            loadedAddons.Questie=true
            NS.UI.UpdateSettings(NS.app)
            assert(panel.restedXPToggle.enabled==false)
            loadedAddons.RXPGuides=true
            NS.UI.UpdateSettings(NS.app)
            assert(panel.restedXPToggle.enabled==true)
        ''')

    def test_questie_integration_has_no_reload_setting(self):
        self.lua.execute('''
            StaticPopupDialogs={}
            StaticPopup_Show=function(key) shownPopup=key end
            boot(); NS.UI.Settings(NS.app)
            assert(NS.UI.settings.questieTrackerToggle)
            assert(StaticPopupDialogs.QUESTTARGETS_QUESTIE_RELOAD==nil)
            assert(shownPopup~='QUESTTARGETS_QUESTIE_RELOAD' and not reloaded)
        ''')

    def test_size_numeric_inputs_clamp_round_and_reject_invalid_values(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local control=NS.UI.masterSettings.modernScaleControl
            local function enter(text)
                control.edit:SetText(text)
                control.edit.scripts.OnEnterPressed(control.edit)
                flush()
            end
            enter('1,27')
            assert(NS.app.db.masterModernScale==1.27 and NS.UI.master.width==76)
            enter('99'); assert(NS.app.db.masterModernScale==2)
            enter('-9'); assert(NS.app.db.masterModernScale==0.3)
            enter('invalid'); assert(NS.app.db.masterModernScale==0.3)
            enter(''); assert(control.edit.text=='0.3')
            enter('1e309'); assert(NS.app.db.masterModernScale==0.3)
            control.edit:SetText('1.5')
            control.edit.scripts.OnEscapePressed(control.edit)
            assert(NS.app.db.masterModernScale==0.3 and control.edit.text=='0.3')
            control.slider:SetValue(1.5); flush()
            assert(NS.UI.master.width==90 and NS.UI.master.height==90)
        ''')

    def test_settings_tabs_work_without_modern_settings_api(self):
        self.lua.execute('''
            Settings=nil
            InterfaceOptions_AddCategory=function(panel) legacyPanel=panel end
            InterfaceOptionsFrame_OpenToCategory=function(panel) legacyOpened=panel end
            boot(); NS.UI.Settings(NS.app)
            assert(legacyPanel==NS.UI.settings and legacyOpened==legacyPanel)
            NS.UI.SelectSettingsTab(3)
            assert(NS.UI.settings.pages[3].scroll.shown)
            NS.UI.masterSettings.modernScaleControl.slider:SetValue(1.5); flush()
            assert(NS.UI.master.width==90 and NS.UI.master.height==90)
        ''')

    def test_compact_window_keeps_position_on_refresh_filter_and_scroll(self):
        self.lua.execute('''boot()
            local frame = NS.UI.frame
            assert(frame.width == 282 and frame.height == 354)
            frame:ClearAllPoints()
            frame:SetPoint('CENTER', UIParent, 'CENTER', 137, -42)
            NS.app.db.position = {x=137,y=-42}
            for i=3,9 do quests[i]={questID=i,title='Quest '..i,objectives={{type='monster',text='Wolf getötet: 0/1',numRequired=1,numFulfilled=0,finished=false}}} end
            NS.app:Refresh()
            assert(frame.point[4] == 137 and frame.point[5] == -42)
            NS.UI.ScrollQuests(NS.app, 1)
            assert(frame.point[4] == 137 and frame.point[5] == -42)
            NS.app:ToggleFilter()
            assert(frame.point[4] == 137 and frame.point[5] == -42)
        ''')

    def test_questlog_helpers_are_never_entered_in_combat(self):
        self.lua.execute("""boot()
            local row=QuestTargetsTarget1
            local before=row.attributes.macrotext1
            combat=true
            row.scripts.PostClick(row, 'RightButton', false)
            NS.UI.OpenQuest(row.entry)
            assert(#openedQuestIDs==0, 'Native questlog helper entered during combat')
            assert(row.attributes.macrotext1==before)
            combat=false
            row.scripts.PostClick(row, 'RightButton', false)
            assert(#openedQuestIDs==1 and openedQuestIDs[1]==row.entry.questID)
        """)

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

    def test_canvas_settings_register_at_login_without_opening(self):
        self.lua.execute("""boot()
            assert(NS.UI.settingsCategoryID==42, 'Canvas category missing at login')
            assert(openCategory==nil, 'Startup opened Options')
            assert(not NS.UI.settings:IsShown())
            NS.UI.Settings(NS.app)
            assert(openCategory==42)
        """)

    def test_settings_registration_retries_after_combat_or_late_settings_load(self):
        self.lua.execute("""
            combat=true; boot()
            assert(NS.UI.settingsCategoryID==nil and openCategory==nil)
            combat=false; event('PLAYER_REGEN_ENABLED')
            assert(NS.UI.settingsCategoryID==42 and openCategory==nil)
        """)
        self.setUp()
        self.lua.execute("""
            local native=Settings
            Settings=nil; boot()
            assert(NS.UI.settings==nil)
            Settings=native; event('ADDON_LOADED','Blizzard_Settings')
            assert(NS.UI.settingsCategoryID==42 and openCategory==nil)
        """)

    def test_native_settings_tooltips_minimap_and_hotkey(self):
        self.lua.execute('''QuestTargetsDB={showTooltips=false,hidden=false}; boot()
            assert(NS.UI.minimap and NS.UI.minimap.shown)
            assert(not NS.app.db.showTooltips)
            NS.UI.Tooltip(QuestTargetsTarget1)
            assert(GameTooltip.text == nil)
            NS.UI.Settings(NS.app)
            assert(openCategory == 42 and NS.UI.settingsCategoryID == 42)
            assert(NS.UI.settings.template == nil)
            for _, control in ipairs({NS.UI.settings.masterToggle,
                    NS.UI.settings.menuToggle, NS.UI.settings.tooltipToggle, NS.UI.settings.minimapToggle}) do
                assert(control.template == 'UICheckButtonTemplate')
            end
            assert(NS.UI.settings.feedbackControls[1].selector:GetText()==NS.L('feedbackRaidMarker'))
            assert(NS.UI.settings.masterToggle:GetChecked())
            NS.UI.settings.masterToggle.scripts.OnEnter(NS.UI.settings.masterToggle)
            assert(GameTooltip.lines[1]==NS.L('masterMoveTip'))
            NS.UI.settings.masterToggle.scripts.OnLeave(NS.UI.settings.masterToggle)
            assert(NS.UI.settings.menuToggle:GetChecked())
            assert(not NS.UI.settings.tooltipToggle:GetChecked())
            assert(NS.UI.settings.minimapToggle:GetChecked())
            NS.UI.settings.tooltipToggle.scripts.OnClick()
            assert(NS.UI.settings.tooltipToggle:GetChecked())
            assert(NS.UI.settings.scaleSlider.template == 'OptionsSliderTemplate')
            assert(NS.UI.settings.scaleSmaller == nil and NS.UI.settings.scaleLarger == nil)
            NS.UI.settings.scaleSlider:SetValue(1.25)
            flush()
            assert(NS.app.db.menuScale == 1.25 and NS.UI.frame.scale == 1.25)
            NS.UI.Tooltip(QuestTargetsTarget1)
            assert(GameTooltip.text == 'Wölfe im Wald')
            assert(GameTooltip.lines[1] == 'Waldwolf getötet: 2/8')
            local names = NS.L('tooltipNames')
            assert(GameTooltip.lines[3] == names)
            assert(GameTooltip.lines[4] == 'Waldwolf')
            for _, line in ipairs(GameTooltip.lines) do
                assert(line ~= 'Wölfe im Wald')
                assert(not line:find('QuestieDB', 1, true))
            assert(line ~= NS.L('questieReloadPrompt'))
            end
            NS.UI.settings.minimapToggle.scripts.OnClick()
            assert(not NS.UI.minimap.shown)
            assert(not NS.UI.settings.minimapToggle:GetChecked())
            NS.UI.settings.hotkey.scripts.OnClick(NS.UI.settings.hotkey)
            NS.UI.settings.hotkey.scripts.OnKeyDown(NS.UI.settings.hotkey, 'G')
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == 'G')
            assert(NS.UI.settings.hotkeyClear==nil)
            NS.UI.settings.hotkey.scripts.OnClick(NS.UI.settings.hotkey)
            NS.UI.settings.hotkey.scripts.OnKeyDown(NS.UI.settings.hotkey,'DELETE')
            assert(GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == nil)
        ''')

    def test_hotkey_replacement_and_delete_preserve_the_other_binding(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            local keys={'G','H'}
            GetBindingKey=function() return unpack(keys) end
            SetBinding=function(key)
                for index=#keys,1,-1 do if keys[index]==key then table.remove(keys,index) end end
                return true
            end
            SetBindingClick=function(key)
                keys[#keys+1]=key
                return true
            end
            local hotkey=NS.UI.settings.hotkey
            hotkey.scripts.OnClick(hotkey)
            hotkey.scripts.OnKeyDown(hotkey,'J')
            assert(#keys==2 and keys[1]=='J' and keys[2]=='H')
            keys={'J','K'}
            hotkey.scripts.OnClick(hotkey)
            hotkey.scripts.OnKeyDown(hotkey,'DELETE')
            assert(#keys==1 and keys[1]=='K')
        ''')

    def test_questie_buttons_do_not_protect_tracker_and_recycled_line_is_resynced(self):
        self.lua.execute('''
            QuestTargetsDB={}
            boot()
            local line=CreateFrame('Frame',nil,UIParent)
            line.expandQuest=CreateFrame('Button',nil,line)
            line.mode='quest'; line.Quest={Id=1}
            local pool={
                GetHighestIndex=function() return 1 end,
                GetLine=function() return line end,
                ResetLinesForChange=function()
                    line.mode=nil; line.Quest=nil
                end,
                HideUnusedLines=function() end,
            }
            Questie={db={profile={trackerEnabled=true}}}
            QuestieLoader={ImportModule=function(_,name)
                assert(name=='TrackerLinePool'); return pool
            end}
            NS.app.allEntries={
                {name='Kobold',refs={{questID=1,key='a',title='First',done=0,total=1}}},
                {name='Waldwolf',refs={{questID=2,key='b',title='Second',done=0,total=1}}},
            }
            NS.QuestieTracker.Sync(NS.app)
            local button=NS.QuestieTracker.buttons[1]
            assert(button and button.questID==1 and button.shown)
            assert(button.parent==UIParent and not line.protected)
            pool.ResetLinesForChange()
            button.scripts.PreClick(button,'LeftButton',false)
            assert(not button.shown and button.entry==nil)
            line.mode='quest'; line.Quest={Id=2}
            pool.HideUnusedLines()
            NS.QuestieTracker.Sync(NS.app)
            assert(button.shown and button.questID==2 and button.entry.questID==2)
            assert(not line.protected)
            line.Quest={Id=1}
            button.scripts.PreClick(button,'LeftButton',false)
            assert(not button.shown and button.entry==nil and button.attributes.macrotext1==nil)
        ''')

    def test_minimap_is_registered_with_libdbicon_and_legacy_angle_migrates(self):
        self.lua.execute("""
            QuestTargetsDB={minimapAngle=math.pi/2}
            boot()
            assert(dbiconObjects.QuestTargets==NS.UI.minimap)
            assert(math.abs(NS.app.db.minimap.minimapPos-90)<0.001)
            local old=NS.UI.frame.shown
            brokerObjects.QuestTargets.OnClick(NS.UI.minimap,'LeftButton')
            assert(NS.UI.frame.shown~=old)
            NS.UI.SetMinimapShown(NS.app,false)
            assert(not NS.UI.minimap.shown and NS.app.db.minimap.hide)
            NS.UI.SetMinimapShown(NS.app,true)
            assert(NS.UI.minimap.shown and not NS.app.db.minimap.hide)
        """)

    def test_minimap_vendor_libraries_load_and_broker_is_available(self):
        self.lua.execute('LibStub=nil')
        for name in ('LibStub/LibStub.lua', 'CallbackHandler-1.0/CallbackHandler-1.0.lua',
                     'LibDataBroker-1.1/LibDataBroker-1.1.lua', 'LibDBIcon-1.0/LibDBIcon-1.0.lua'):
            self.lua.execute((ROOT/'QuestTargets/Libs'/name).read_text(encoding='utf-8'))
        self.lua.execute("""
            local object=LibStub('LibDataBroker-1.1'):NewDataObject('Probe',{type='launcher',icon='icon'})
            assert(object.icon=='icon')
            assert(type(LibStub('LibDBIcon-1.0').Register)=='function')
        """)

    def test_new_defaults_modern_master_and_35_pixel_spacing(self):
        self.lua.execute("""
            QuestTargetsDB={}; boot()
            assert(NS.app.db.masterModernScale==1 and NS.UI.master.width==60)
            assert(NS.app.db.questieTrackerOffset==35)
            NS.app.db.questieTrackerOffset=0
            event('ADDON_LOADED','QuestTargets')
            assert(NS.app.db.questieTrackerOffset==0)
        """)

    def test_quest_window_resize_saves_dimensions_and_changes_list_capacity(self):
        self.lua.execute("""boot()
            local ui,app=NS.UI,NS.app
            assert(ui.resizeGrip and ui.frame.resizable)
            ui.resizeGrip.scripts.OnMouseDown(ui.resizeGrip,'LeftButton')
            assert(ui.resizing and ui.frame.sizing=='BOTTOMRIGHT')
            ui.frame:SetSize(400,510)
            ui.frame.scripts.OnSizeChanged(ui.frame,400,510)
            assert(ui.PAGE_SIZE==10 and ui.rows[1].width==356)
            ui.resizeGrip.scripts.OnMouseUp(ui.resizeGrip,'LeftButton')
            assert(not ui.resizing and app.db.menuWidth==400 and app.db.menuHeight==510)
            combat=true
            ui.resizeGrip.scripts.OnMouseDown(ui.resizeGrip,'LeftButton')
            assert(not ui.resizing)
            combat=false
            ui.resizeGrip.scripts.OnMouseDown(ui.resizeGrip,'LeftButton')
            combat=true; event('PLAYER_REGEN_DISABLED')
            assert(ui.resizePending)
            combat=false; event('PLAYER_REGEN_ENABLED')
            assert(not ui.resizePending and not ui.resizing)
        """)

    def test_saved_quest_window_size_is_restored_and_invalid_sizes_are_clamped(self):
        self.lua.execute("""
            QuestTargetsDB={menuWidth=430,menuHeight=510}; boot()
            assert(NS.UI.frame.width==430 and NS.UI.frame.height==510)
            assert(NS.UI.PAGE_SIZE==10)
        """)
        self.setUp()
        self.lua.execute("""
            QuestTargetsDB={menuWidth=0/0,menuHeight=99999}; boot()
            assert(NS.UI.frame.width==282 and NS.UI.frame.height==900)
        """)

    def test_options_title_uses_installed_metadata_version(self):
        self.lua.execute("""
            C_AddOns={GetAddOnMetadata=function(name,key)
                assert(name=='QuestTargets' and key=='Version'); return '1.5.1-preview' end}
            boot()
            assert(NS.UI.OptionsTitle()=='Next 1.5.1-preview')
            assert(NS.UI.settings.titleText.text==NS.UI.OptionsTitle())
        """)

    def test_modern_master_uses_two_compass_states_and_uniform_scale(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local controls, master = NS.UI.masterSettings, NS.UI.master
            local normal, pushed = master:GetNormalTexture(), master:GetPushedTexture()
            assert(normal.texture:find('QuestCompassUp', 1, true))
            assert(pushed.texture:find('QuestCompassDown', 1, true))
            assert(master.width==60 and master.height==60 and not master.text)
            assert(not master.Left and not master.Middle and not master.Right)
            assert(not controls.classicButton and not controls.modernButton and not controls.textEdit)
            controls.modernScaleControl.slider:SetValue(1.1); flush()
            assert(master.width==66 and master.height==66)
            assert(master:GetNormalTexture()==normal and master:GetPushedTexture()==pushed)
            assert(master.attributes.type1=='macro' and master.attributes.macrotext1)
        ''')

    def test_button_bar_options_reflow_secure_buttons_and_edit_outline(self):
        self.lua.execute('''QuestTargetsDB={masterDividers=false}; boot()
            local app, ui = NS.app, NS.UI
            local master, options = ui.master, ui.masterSettings
            local rare = CreateFrame('Button', nil, UIParent, 'SecureActionButtonTemplate')
            local item = CreateFrame('Button', nil, UIParent, 'SecureActionButtonTemplate')
            item.inBar = true
            NS.RareScanner.markButton, NS.ItemTree.target = rare, item
            NS.RareScanner.SyncMark = function() end
            NS.ItemTree.Sync = function() end
            ui.LayoutTargetButtons(app)
            assert(item.point[1]=='LEFT' and item.point[2]==master and item.point[4]==0)
            assert(rare.point[2]==item and not master.barBorder)
            options.backgroundToggle.scripts.OnClick()
            flush()
            local background=master.barBorder.background
            assert(background:IsShown() and master.barBorder:IsShown())
            assert(not master.barBorder.borderVisible and not app.db.masterDividers)
            assert(background.backdrop.bgFile:find('UI-DialogBox-Background',1,true))
            local insets=background.backdrop.insets
            assert(insets.left==4 and insets.right==4 and insets.top==4 and insets.bottom==4)
            options.backgroundToggle.scripts.OnClick()
            flush()
            assert(not master.barBorder:IsShown())

            dropdownChoices = {}
            options.orientationDropdown.initialize()
            dropdownChoices[2].func()
            options.spacingControl.slider:SetValue(12)
            options.borderToggle.scripts.OnClick()
            flush()
            assert(app.db.masterOrientation=='vertical' and app.db.masterSpacing==12 and app.db.masterBorder)
            assert(item.point[1]=='TOP' and item.point[2]==master and item.point[3]=='BOTTOM' and item.point[5]==-12)
            assert(rare.point[2]==item and rare.point[5]==-12)
            assert(master.barWidth==60 and master.barHeight==204)
            local border=master.barBorder
            assert(border:IsShown() and border.parent==master and border.point[5]==-72)
            assert(border.backdrop.edgeSize==7 and border.backdrop.edgeFile:find('TargetBarBorder',1,true))
            assert(border.width==77 and border.height==220)
            options.backgroundToggle.scripts.OnClick()
            flush()
            local framedInsets=border.background.backdrop.insets
            assert(framedInsets.left==4 and framedInsets.right==4 and framedInsets.top==4 and framedInsets.bottom==4)

            assert(not app.db.masterDividers and #border.dividers==0 and border.borderColor[4]==1)
            assert(options.borderToggle.parent==options.dividersToggle.parent
                and options.borderToggle.parent.localeKey=='targetBar')
            options.dividersToggle.scripts.OnClick(); flush()
            local divider=border.dividers[1]
            assert(#border.dividers==2 and divider:IsShown() and border.dividers[2]:IsShown())
            assert(divider.point[3]=='CENTER' and divider.point[5]==36 and divider.width==52 and divider.height==6)
            options.borderToggle.scripts.OnClick(); flush()
            assert(border:IsShown() and divider:IsShown() and border.borderColor[4]==0)
            options.borderToggle.scripts.OnClick(); flush()
            assert(ui.BeginMasterMove(app))
            assert(ui.masterMove.outline.height==212 and ui.masterMove.outline.point[5]==-72)
            ui.EndMasterMove(app, false)
            app.db.masterHidden=true
            app:Refresh()
            assert(item.point[1]=='CENTER' and item.point[2]==master and rare.point[2]==item)
            assert(border.parent==item and border.width==77 and border.height==148)
            assert(divider:IsShown() and not border.dividers[2]:IsShown())
            options.spacingControl.slider:SetValue(0); flush()
            assert(rare.point[5]==0 and border.height==136)
            app.db.masterOrientation='horizontal'; app:Refresh()
            assert(border.width==137 and border.height==76 and border.point[4]==30)
            assert(divider.point[3]=='CENTER' and divider.point[4]==0 and divider.width==3 and divider.height==52)
            item.inBar=false; rare:Hide(); ui.LayoutTargetButtons(app)
            assert(not border:IsShown())
            rare:Show(); ui.LayoutTargetButtons(app)
            assert(border:IsShown() and border.parent==rare and border.width==77)
            assert(not divider:IsShown())
            options.borderToggle.scripts.OnClick(); flush()
            assert(border.background:IsShown() and not border.borderVisible)
            assert(border.background.backdrop.insets.left==4)
            options.backgroundToggle.scripts.OnClick(); flush()
            assert(not border:IsShown())
        ''')

    def test_master_stays_freely_positioned_and_keeps_hotkey_target(self):
        self.lua.execute('''boot(); NS.UI.Settings(NS.app)
            local master = NS.UI.master
            assert(master.point[2] == UIParent and master.width == 60)
            assert(NS.UI.settings.actionBarToggle == nil)
            assert(NS.app.db.actionBarMode == nil)
            local macro = master.attributes.macrotext1
            assert(macro and macro:find('Waldwolf',1,true))
            master.scripts.OnDragStart(master)
            assert(master.moving)
            master.scripts.OnDragStop(master)
            assert(master.point[2] == UIParent and master.width == 60)
            assert(not master.text)
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
            assert(NS.UI.refreshButton == nil)
            assert(NS.UI.feedbackButton.text==NS.L('feedback'))
            assert(NS.UI.settings.feedbackControls[1].caption.text==NS.L('feedbackMaster'))
            assert(NS.UI.settings.hotkeysText.text==NS.L('hotkeys'))
            assert(not NS.UI.master.text)
            NS.app:Refresh()
            assert(NS.UI.filter.text==NS.L('all'))
            dropdownChoices[1].func()
            assert(NS.app.db.language=='enUS' and not reloaded)
            assert(NS.UI.settings.feedbackControls[1].caption.text=='Master button')
            assert(NS.UI.feedbackButton.text=='Feedback')
            dropdownChoices[4].func()
            assert(NS.app.db.language=='frFR' and not NS.UI.master.text)
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

    def test_tracking_and_slash_refresh_update_quest_buttons(self):
        self.lua.execute('''boot(); NS.app:ToggleFilter()
            assert(#NS.app.questEntries == 1)
            quests[2].watched = true
            event('QUEST_WATCH_LIST_CHANGED',2,true); flush()
            assert(#NS.app.questEntries == 2)
            quests[1].watched = false
            event('QUEST_WATCH_LIST_CHANGED',1,false); flush()
            assert(#NS.app.questEntries == 1 and QuestTargetsTarget1.entry.questID == 2)
            quests[1].watched = true
            SlashCmdList.QUESTTARGETS('refresh')
            assert(#NS.app.questEntries == 2)
            combat = true
            quests[2].watched = false
            SlashCmdList.QUESTTARGETS('refresh')
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
            QuestTargetsDB={hidden=false}; boot(); NS.app:ToggleFilter(); NS.app:Toggle()
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
        self.lua.execute('''QuestTargetsDB={hidden=false}; boot(); NS.UI.Settings(NS.app)
            local settings, master = NS.UI.settings, NS.UI.master
            master.scripts.OnDragStart(master)
            assert(master.moving)
            NS.app:Refresh()
            assert(master.moving)
            master.scripts.OnDragStop(master)
            assert(not master.moving and NS.app.db.masterPosition)
            settings.scaleSlider:SetValue(1.1); flush()
            assert(NS.UI.frame.scale > 1 and master.scale == nil)
            combat = true; event('PLAYER_REGEN_DISABLED')
            local scale = NS.UI.frame.scale
            settings.masterToggle.scripts.OnClick()
            settings.menuToggle.scripts.OnClick()
            settings.scaleSlider:SetValue(0.9); flush()
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
                    local retarget = row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true)
                    assert((retarget~=nil)==(row==NS.UI.master))
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

    def test_repeated_click_keeps_quest_row_target_and_allows_master_search(self):
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
                if row==NS.UI.master then
                    assert(second:find('/targetexact [nocombat] Waldwolf',1,true))
                    currentGUID='B'
                else
                    assert(not second:find('/targetexact',1,true))
                end
                row.scripts.PostClick(row,'LeftButton',false)
            end
        ''')

    def test_hybrid_keeps_far_quest_row_target_and_allows_master_search(self):
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
                local retarget = row.attributes.macrotext1:find('/targetexact [nocombat] Waldwolf',1,true)
                assert((retarget~=nil)==(row==NS.UI.master))
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
            row.defaultEntry = entry
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
                    assert(not macro:find('/click',1,true))
                    assert(macro:find('/tm [nocombat,exists,harm,nodead] !8',1,true))
                    if row==NS.UI.master then
                        assert(macro:find('/targetexact [nocombat] '..UnitName(expected),1,true))
                        currentGUID = UnitGUID(expected)
                    else
                        assert(not macro:find('/targetexact',1,true))
                    end
                    row.scripts.PostClick(row)
                    if row==NS.UI.master then assert(NS.Core.lastClick.selected == 'true') end
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
            currentGUID = nil
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
            panel.feedbackControls[6].selector.scripts.OnClick(); flush()
            assert(NS.Core.TargetFeedbackMode(NS.app.db, 'questList')==1)
            assert(NS.Core.TargetFeedbackMode(NS.app.db, 'master')==2)
            assert(not QuestTargetsTarget1.attributes.macrotext1:find('/tm',1,true))
            event('ADDON_LOADED','QuestTargets')
            assert(NS.Core.TargetFeedbackMode(NS.app.db, 'questList')==1 and NS.app.db.markerIcon==3)
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
        self.lua.execute('''QuestTargetsDB={hidden=false}; boot()
            local old = QuestTargetsTarget1.attributes.macrotext1
            combat = true; event('PLAYER_REGEN_DISABLED')
            quests[1].objectives[1].finished = true
            event('QUEST_LOG_UPDATE'); flush()
            NS.UI.ScrollQuests(NS.app, 1); NS.app:ToggleFilter()
            SlashCmdList.QUESTTARGETS('reset'); SlashCmdList.QUESTTARGETS('clear')
            NS.app:Toggle()
            assert(QuestTargetsFrame.shown and NS.app.pendingVisibility == false)
            assert(QuestTargetsTarget1.attributes.macrotext1 == old)
            assert(NS.app.dirty and NS.app.scrollOffset == 0)
            combat = false; event('PLAYER_REGEN_ENABLED')
            assert(not QuestTargetsFrame.shown)
            assert(QuestTargetsTarget1.attributes.macrotext1 == nil)
            assert(not NS.app.dirty)
        ''')

    def test_reload_in_combat_defers_all_ui_creation(self):
        self.lua.execute('''combat = true; QuestTargetsDB={hidden=false}; boot()
            assert(NS.UI.frame == nil)
            NS.app:Toggle(); NS.app:Toggle()
            combat = false; event('PLAYER_REGEN_ENABLED')
            assert(NS.UI.frame and QuestTargetsFrame.shown)
        ''')

    def test_scrolling_clears_stale_macros_and_clamps_after_completion(self):
        self.lua.execute('''
            quests = {}
            for i=1,15 do quests[i]={questID=i,title='Quest '..i,objectives={
                {type='monster',text='Mob '..i..' getötet: 0/1',numFulfilled=0,numRequired=1,finished=false}}} end
            boot()
            assert(NS.UI.scrollbar.shown and NS.UI.previous == nil and NS.UI.next == nil)
            NS.UI.frame.scripts.OnMouseWheel(NS.UI.frame, -1)
            assert(NS.app.scrollOffset == 1 and QuestTargetsTarget1.entry.name == 'Mob 2')
            NS.UI.scrollbar:SetValue(9)
            assert(NS.app.scrollOffset == 9 and QuestTargetsTarget1.entry.name == 'Mob 10')
            assert(QuestTargetsTarget6.entry.name == 'Mob 15')
            for i=15,2,-1 do quests[i]=nil end
            event('QUEST_LOG_UPDATE'); flush()
            assert(NS.app.scrollOffset == 0 and QuestTargetsTarget1.entry.name == 'Mob 1')
            assert(not QuestTargetsTarget2.shown)
            assert(QuestTargetsTarget2.attributes.macrotext1 == nil)
            assert(not NS.UI.scrollbar.shown)
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

    def test_tracked_filter_reads_each_quest_once_for_both_views(self):
        self.lua.execute('''QuestTargetsDB = {watchedOnly=true}; boot()
            local objectives = C_QuestLog.GetQuestObjectives
            local reads = {}
            C_QuestLog.GetQuestObjectives = function(id)
                reads[id] = (reads[id] or 0) + 1
                return objectives(id)
            end
            NS.app:Refresh()
            assert(reads[1] == 1 and reads[2] == 1, 'both views should reuse the same objective read')
            assert(#NS.app.quests == 1 and NS.app.quests[1] == NS.app.allQuests[1])
            assert(#NS.app.allQuests == 2 and not NS.app.error)
        ''')

    def test_tracked_filter_preserves_shared_log_errors_and_master_fallback(self):
        self.lua.execute('''QuestTargetsDB = {watchedOnly=true}; boot()
            local count = C_QuestLog.GetNumQuestLogEntries
            C_QuestLog.GetNumQuestLogEntries = function() return nil end
            NS.app:Refresh()
            assert(NS.app.error == NS.L('logPending'))
            assert(#NS.app.quests == 0 and #NS.app.allQuests == 0)
            C_QuestLog.GetNumQuestLogEntries = count
            tick()
            assert(not NS.app.error and #NS.app.quests == 1 and #NS.app.allQuests == 2)
            C_QuestLog.GetQuestWatchType = nil
            NS.app:Refresh()
            assert(NS.app.error == NS.L('filterMissing'))
            assert(#NS.app.quests == 0 and #NS.app.allQuests == 2)
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

    def test_nameplate_event_burst_scans_once_and_leaves_quest_log_untouched(self):
        self.lua.execute('''boot()
            local count, scan = C_QuestLog.GetNumQuestLogEntries, NS.Scanner.Scan
            local reads, scans = 0, 0
            C_QuestLog.GetNumQuestLogEntries = function()
                reads = reads + 1
                return count()
            end
            NS.Scanner.Scan = function(...)
                scans = scans + 1
                return scan(...)
            end
            plate('Young Wolf','Warme Felle','1/4 Wolfsfell')
            event('NAME_PLATE_UNIT_ADDED','nameplate1')
            event('NAME_PLATE_UNIT_REMOVED','nameplate2')
            assert(#timers == 1)
            flush()
            assert(scans == 1 and reads == 0, 'plate-only changes should avoid reading the quest log')
            assert(QuestTargetsDB.autoTargets.entries['2:1'].names['Young Wolf'])
            assert(NS.app.metadata.unresolved == 0)

            event('NAME_PLATE_UNIT_ADDED','nameplate3')
            quests[2].objectives[1].numFulfilled = 2
            event('QUEST_LOG_UPDATE')
            assert(#timers == 1)
            flush()
            assert(scans == 2 and reads == 1, 'quest events should take precedence in a shared burst')
            assert(NS.app.entries[2].done == 2)
        ''')

    def test_scanner_reuses_recent_tooltip_reads_until_plate_or_quest_changes(self):
        self.lua.execute('''
            local now=0
            GetTime=function() return now end
            plate('Waldwolf','Wölfe im Wald','Waldwolf getötet: 0/5')
            boot()
            assert(tooltipCalls==1)
            now=1
            NS.app:Poll()
            assert(tooltipCalls==1)
            event('NAME_PLATE_UNIT_ADDED','nameplate1'); flush()
            assert(tooltipCalls==2, 'recycled nameplate must be rescanned')
            event('QUEST_LOG_UPDATE'); flush()
            assert(tooltipCalls==3, 'changed quest snapshot must be rescanned')
            now=4
            NS.app:Poll()
            assert(tooltipCalls==4, 'periodic retry must remain available')
        ''')

    def test_scanner_shares_the_quest_title_index_across_tooltips(self):
        self.lua.execute('''
            local questList = NS.Core.ReadQuests(false)
            local titlesRead = 0
            for _, quest in ipairs(questList) do
                local title = quest.title
                quest.title = nil
                setmetatable(quest, {__index = function(_, key)
                    if key == 'title' then
                        titlesRead = titlesRead + 1
                        return title
                    end
                end})
            end
            for i=1,12 do plate('Wolf '..i,'Warme Felle','1/4 Wolfsfell') end
            local learned = {}
            assert(NS.Scanner.Scan(questList, learned))
            assert(tooltipCalls == 12 and learned['2:1'].names['Wolf 12'])
            assert(titlesRead == #questList, 'a scan should index each title once')
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
            assert(NS.UI.status == nil)
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
            for _=1,10 do
                event('NAME_PLATE_UNIT_ADDED','nameplate1'); flush()
            end
            assert(calls[1]==before)
            event('ZONE_CHANGED_NEW_AREA'); flush()
            assert(calls[1]==before+expected)
            -- A full refresh deliberately drops the cache, including after DB data changes.
            NS.app:Refresh()
            assert(calls[1]==before+expected*2)
        ''')

    def test_idle_polls_reuse_quest_aggregation(self):
        self.lua.execute('''
            QuestTargetsDB={watchedOnly=true}
            local calls=0
            local original=NS.Core.QuestEntries
            NS.Core.QuestEntries=function(entries)
                calls=calls+1
                return original(entries)
            end
            boot()
            local before=calls
            for _=1,10 do
                NS.app:Poll()
                NS.UI.Render(NS.app)
                NS.UI.RenderMaster(NS.app)
            end
            assert(calls==before)
            quests[1].objectives[1].text='Waldwolf: 1/4'
            event('QUEST_LOG_UPDATE'); flush()
            assert(calls>before)
        ''')

    def test_late_questiedb_load_invalidates_cached_unresolved_quests(self):
        self.database()
        self.lua.execute('''
            local provider=LibQuestieDB
            LibQuestieDB=nil
            boot()
            assert(NS.app.metadata.unresolved==1)
            LibQuestieDB=provider
            event('ADDON_LOADED','QuestieDB'); flush()
            assert(NS.app.metadata.unresolved==0)
            assert(NS.app.resolutionProvider==provider)
        ''')

    def test_observations_prune_completed_and_changed_objectives(self):
        self.lua.execute('''
            boot()
            local saved=NS.app.learned
            saved['1:1']={signature=NS.Core.Signature(NS.app.allQuests[1].objectives[1]),
                names={Waldwolf=true}}
            saved['2:1']={signature='old objective',names={Falsch=true}}
            saved['999:1']={signature='monster:stale',names={Falsch=true}}
            NS.app:Refresh()
            assert(saved['1:1'] and saved['1:1'].names.Waldwolf)
            assert(saved['2:1']==nil and saved['999:1']==nil)
            table.remove(quests,1)
            event('QUEST_LOG_UPDATE'); flush()
            assert(saved['1:1']==nil)
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
