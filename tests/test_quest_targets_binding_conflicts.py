"""Confirmation must precede any change to an occupied keyboard/controller key."""
import unittest
import test_quest_targets as addon


class BindingConflictTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def prepare(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app); prepareBindingPopups()
            BINDING_NAME_JUMP='Jump'
            bindings=bindings or {}; bindings.JUMP={'SPACE','PAD1'}
            SaveBindings=function() saves=(saves or 0)+1; return true end
            local panel=NS.UI.settings
            function assign(control,key)
                control.scripts.OnClick(control)
                control.scripts.OnKeyDown(control,key)
            end
            assign(panel.hotkey,'F'); assign(panel.hotkey2,'G')
            assign(panel.focusHotkey,'H'); assign(panel.focusHotkey2,'K')
            saves=0
        ''')

    def test_controller_conflicts_require_confirmation_for_both_slots_of_both_actions(self):
        for focused in (False, True):
            for slot in (1, 2):
                with self.subTest(focused=focused, slot=slot):
                    self.setUp()
                    self.prepare()
                    self.lua.execute('focused,slot=...', focused, slot)
                    self.lua.execute('''
                        local panel=NS.UI.settings
                        local control=focused and (slot==1 and panel.focusHotkey or panel.focusHotkey2)
                            or (slot==1 and panel.hotkey or panel.hotkey2)
                        control.EnableGamePadButton=function(self,on) self.gamepadEnabled=on end
                        control.scripts.OnClick(control)
                        control.scripts.OnGamePadButtonDown(control,'PAD1')
                        assert(bindingPopup and bindingPopup.shown, 'occupied key needs confirmation')
                        local definition=StaticPopupDialogs[bindingPopup.which]
                        assert(definition.hideOnEscape and bindingPopup.text:find('Jump',1,true))
                        assert(GetBindingAction('PAD1')=='JUMP' and saves==0)
                        assert(not control.listening and not control.gamepadEnabled)
                        assert(NS.app.db.focusHotkeyKey=='H' and NS.app.db.focusHotkeyKey2=='K')
                        acceptBindingPopup()
                        local command=focused and 'CLICK QuestTargetsFocused:LeftButton'
                            or 'CLICK QuestTargetsMaster:LeftButton'
                        local first,second=GetBindingKey(command)
                        assert(first==(slot==1 and 'PAD1' or (focused and 'H' or 'F')))
                        assert(second==(slot==2 and 'PAD1' or (focused and 'K' or 'G')))
                        assert(GetBindingKey('JUMP')=='SPACE' and saves==1)
                    ''')

    def test_cancel_escape_and_unavailable_dialog_leave_old_bindings_untouched(self):
        self.prepare()
        self.lua.execute('''
            local control=NS.UI.settings.hotkey2
            assign(control,'PAD1')
            assert(bindingPopup and bindingPopup.shown, 'confirmation missing')
            local popup=bindingPopup
            StaticPopupDialogs[popup.which].OnCancel(popup,popup.data,'clicked')
            StaticPopup_Hide(popup.which)
            assert(GetBindingAction('PAD1')=='JUMP' and saves==0)
            assign(control,'PAD1')
            popup=bindingPopup
            StaticPopupDialogs[popup.which].OnCancel(popup,popup.data,'escape')
            StaticPopup_Hide(popup.which)
            assert(GetBindingAction('PAD1')=='JUMP' and saves==0)
            StaticPopup_Show=function() return nil end
            assign(control,'PAD1')
            assert(GetBindingAction('PAD1')=='JUMP' and saves==0)
            local first,second=GetBindingKey('CLICK QuestTargetsMaster:LeftButton')
            assert(first=='F' and second=='G')
        ''')

    def test_stale_confirmation_cannot_overwrite_a_new_owner_or_changed_target(self):
        for change in ('owner', 'target', 'combat', 'hide', 'popup_hide', 'new_capture'):
            with self.subTest(change=change):
                self.setUp()
                self.prepare()
                self.lua.execute('change=...', change)
                self.lua.execute('''
                    local panel=NS.UI.settings
                    assign(panel.hotkey2,'PAD1')
                    assert(bindingPopup and bindingPopup.shown, 'confirmation missing')
                    local popup=bindingPopup
                    if change=='owner' then
                        SetBindingClick('PAD1','OtherAction','LeftButton')
                    elseif change=='target' then
                        SetBinding('F'); SetBindingClick('J','QuestTargetsMaster','LeftButton')
                    elseif change=='combat' then
                        combat=true; event('PLAYER_REGEN_DISABLED')
                    elseif change=='hide' then
                        panel.scripts.OnHide(panel)
                    elseif change=='popup_hide' then
                        StaticPopup_Hide(popup.which)
                    else
                        panel.focusHotkey.scripts.OnClick(panel.focusHotkey)
                    end
                    StaticPopupDialogs[popup.which].OnAccept(popup,popup.data)
                    assert(saves==0, 'stale confirmation changed bindings')
                    assert(GetBindingAction('PAD1')==(change=='owner' and 'CLICK OtherAction:LeftButton' or 'JUMP'))
                ''')

    def test_free_keys_own_keys_and_deletion_do_not_ask_for_confirmation(self):
        self.prepare()
        self.lua.execute('''
            assign(NS.UI.settings.hotkey2,'F')
            assert(not bindingPopup)
            assign(NS.UI.settings.hotkey2,'L')
            assert(not bindingPopup)
            assign(NS.UI.settings.hotkey2,'DELETE')
            assert(not bindingPopup)
            assert(GetBindingAction('PAD1')=='JUMP')
        ''')

    def test_failed_confirmed_assignment_restores_the_displaced_action(self):
        self.prepare()
        self.lua.execute('''
            assign(NS.UI.settings.hotkey2,'PAD1')
            local bind=SetBindingClick
            SetBindingClick=function(key,...)
                if key=='PAD1' then return false end
                return bind(key,...)
            end
            acceptBindingPopup()
            local first,second=GetBindingKey('CLICK QuestTargetsMaster:LeftButton')
            assert(first=='F' and second=='G')
            first,second=GetBindingKey('JUMP')
            assert(first=='SPACE' and second=='PAD1', 'failed assignment lost the original action')
            assert(saves==0)
        ''')

    def test_native_popup_formats_binding_names_with_percent_signs_as_data(self):
        self.prepare()
        self.lua.execute('''
            BINDING_NAME_JUMP='Heal 50%'
            local ok=pcall(assign,NS.UI.settings.hotkey2,'PAD1')
            assert(ok, 'native formatter interpreted a binding label as format code')
            assert(bindingPopup.text:find('Heal 50%',1,true))
            assert(GetBindingAction('PAD1')=='JUMP')
            acceptBindingPopup()
            assert(GetBindingAction('PAD1')=='CLICK QuestTargetsMaster:LeftButton')
        ''')
