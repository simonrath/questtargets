import unittest
import test_quest_targets as addon


class MouseBindingTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def prepare(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app); prepareBindingPopups()
            panel=NS.UI.settings
            SaveBindings=function() saves=(saves or 0)+1; return true end
            saves=0
        ''')

    def test_middle_and_extra_buttons_in_both_slots_for_all_actions(self):
        for key in ('hotkey', 'hotkey2', 'focusHotkey', 'focusHotkey2',
                    'itemTreeHotkey', 'itemTreeHotkey2'):
            for mouse, binding in (('MiddleButton', 'BUTTON3'), ('Button4', 'BUTTON4'),
                                   ('Button5', 'BUTTON5'), ('Button31', 'BUTTON31')):
                with self.subTest(control=key, mouse=mouse):
                    self.setUp(); self.prepare()
                    self.lua.execute('key,mouse,binding=...', key, mouse, binding)
                    self.lua.execute('''
                        local control=panel[key]
                        local original=control:GetScript('OnClick')
                        original(control,'LeftButton')
                        control.scripts.OnClick(control,mouse)
                        local target=key:find('focus') and 'QuestTargetsFocused'
                            or (key:find('itemTree') and 'QuestTargetsItemTree' or 'QuestTargetsMaster')
                        assert(GetBindingAction(binding)=='CLICK '..target..':LeftButton')
                        assert(not control.listening and saves==1)
                        assert(control:GetScript('OnClick')==original)
                        assert(control.clicks[1]=='LeftButtonUp')
                    ''')

    def test_modifiers_wheel_and_cleanup(self):
        self.prepare()
        self.lua.execute('''
            local control=panel.hotkey
            control.scripts.OnClick(control,'LeftButton')
            ctrlDown=true; altDown=true; shiftDown=true
            control.scripts.OnClick(control,'Button4')
            assert(GetBindingAction('CTRL-ALT-SHIFT-BUTTON4')=='CLICK QuestTargetsMaster:LeftButton')
            ctrlDown=false; altDown=false; shiftDown=false
            for _,delta in ipairs({1,-1}) do
                control.scripts.OnClick(control,'LeftButton')
                assert(control.mouseWheel)
                assert(control.scripts.OnMouseWheel, 'wheel capture missing')
                control.scripts.OnMouseWheel(control,delta)
                assert(GetBindingAction(delta>0 and 'MOUSEWHEELUP' or 'MOUSEWHEELDOWN')
                    =='CLICK QuestTargetsMaster:LeftButton')
                assert(not control.mouseWheel and not control.scripts.OnMouseWheel)
            end
        ''')

    def test_primary_mouse_buttons_cancel_without_overwriting_world_controls(self):
        for mouse in ('LeftButton', 'RightButton'):
            with self.subTest(mouse=mouse):
                self.setUp(); self.prepare()
                self.lua.execute('mouse=...',mouse)
                self.lua.execute('''
                    local control=panel.hotkey
                    control.scripts.OnClick(control,'LeftButton')
                    control.scripts.OnClick(control,mouse)
                    assert(not control.listening and saves==0)
                    assert(not GetBindingKey('CLICK QuestTargetsMaster:LeftButton'))
                ''')

    def test_occupied_mouse_binding_requires_confirmation(self):
        self.prepare()
        self.lua.execute('''
            SetBinding('BUTTON4','JUMP')
            local control=panel.hotkey
            control.scripts.OnClick(control,'LeftButton')
            control.scripts.OnClick(control,'Button4')
            assert(bindingPopup and bindingPopup.shown)
            assert(GetBindingAction('BUTTON4')=='JUMP' and saves==0)
            acceptBindingPopup()
            assert(GetBindingAction('BUTTON4')=='CLICK QuestTargetsMaster:LeftButton')
            assert(saves==1)
        ''')

    def test_combat_and_tab_change_cancel_mouse_capture(self):
        for action in ('combat', 'tab'):
            with self.subTest(action=action):
                self.setUp(); self.prepare()
                self.lua.execute('action=...',action)
                self.lua.execute('''
                    local control=panel.hotkey
                    local original=control:GetScript('OnClick')
                    original(control,'LeftButton')
                    if action=='combat' then combat=true; event('PLAYER_REGEN_DISABLED')
                    else NS.UI.SelectSettingsTab(1) end
                    assert(not control.listening and not control.mouseWheel)
                    assert(control:GetScript('OnClick')==original)
                    assert(not control.scripts.OnMouseWheel and saves==0)
                ''')

    def test_existing_wheel_handler_and_enabled_state_are_restored(self):
        self.prepare()
        self.lua.execute('''
            local control=panel.hotkey
            local wheel=function() end
            control.IsMouseWheelEnabled=function(self) return self.mouseWheel end
            control:EnableMouseWheel(true)
            control:SetScript('OnMouseWheel',wheel)
            control.scripts.OnClick(control,'LeftButton')
            control.scripts.OnKeyDown(control,'ESCAPE')
            assert(control.mouseWheel and control:GetScript('OnMouseWheel')==wheel)
        ''')
