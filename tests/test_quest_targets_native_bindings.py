import unittest
import xml.etree.ElementTree as ET
import test_quest_targets as addon


class NativeBindingsTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_native_click_actions_are_registered_and_packaged(self):
        actions = ET.parse(addon.ROOT / 'QuestTargets/Bindings.xml').getroot().findall('Binding')
        self.assertEqual([item.attrib['name'] for item in actions],
                         ['CLICK QuestTargetsMaster:LeftButton', 'CLICK QuestTargetsFocused:LeftButton', 'CLICK QuestTargetsItemTree:LeftButton'])
        self.assertTrue(all(item.attrib['category'] == 'Quest Targets' for item in actions))
        self.assertIn('Bindings.xml', (addon.ROOT/'tools/package_quest_targets.ps1').read_text())
        self.lua.execute('''boot()
            assert(BINDING_HEADER_QUESTTARGETS=='Quest Targets')
            assert(_G['BINDING_NAME_CLICK QuestTargetsMaster:LeftButton']==NS.L('masterDefault'))
            assert(_G['BINDING_NAME_CLICK QuestTargetsFocused:LeftButton']==NS.L('focusHotkey'))
        ''')

    def test_native_assign_clear_and_reload_do_not_restore_stale_focus_keys(self):
        for interface in (11509, 20506, 50504, 16001, 120105):
            with self.subTest(interface=interface):
                self.setUp()
                self.lua.execute('''
                    GetBuildInfo=function() return '', '', '', ... end
                '''.replace('...', str(interface)))
                self.lua.execute('''
                    QuestTargetsDB={focusHotkeyKey='H'}; boot()
                    SetBindingClick('G','QuestTargetsFocused','LeftButton')
                    SetBinding('H')
                    event('UPDATE_BINDINGS'); NS.app:Refresh()
                    assert(GetBindingKey('CLICK QuestTargetsFocused:LeftButton')=='G')
                    assert(NS.app.db.focusHotkeyKey=='G')
                    SetBinding('G'); event('UPDATE_BINDINGS'); NS.app:Refresh()
                    assert(not NS.app.db.focusHotkeyKey)
                    NS.app.db.focusHotkeyKey='STALE'
                    NS.app.focusBindingsInitialized=nil
                    NS.UI.SyncFocusBinding(NS.app)
                    assert(not GetBindingKey('CLICK QuestTargetsFocused:LeftButton'))
                ''')

    def test_native_labels_use_saved_language(self):
        self.lua.execute('''
            QuestTargetsDB={language='deDE'}; boot()
            assert(_G['BINDING_NAME_CLICK QuestTargetsMaster:LeftButton']=='Questziel anvisieren')
            assert(_G['BINDING_NAME_CLICK QuestTargetsFocused:LeftButton']==NS.L('focusHotkey'))
        ''')
