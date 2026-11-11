import unittest
import test_quest_targets as addon


class DeadTargetSoundTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def prepare(self):
        self.lua.execute('''
            boot()
            muted, unmuted = {}, {}
            MuteSoundFile=function(id) muted[#muted+1]=id end
            UnmuteSoundFile=function(id) unmuted[#unmuted+1]=id end
            units.target={name='Dead Wolf',dead=true}
            NS.app.db.muteDeadTargetSound=true
            probe=CreateFrame('Button',nil,UIParent)
            macro='/cleartarget\\n/targetexact Waldwolf'
        ''')

    def test_dead_target_mute_is_temporary_and_macro_bytes_are_unchanged(self):
        self.prepare()
        self.lua.execute('''
            macro=macro..string.rep(' ',255-#macro)
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            assert(probe.attributes.macrotext1==macro)
            assert(#probe.attributes.macrotext1==255)
            assert(#muted==1 and muted[1]==567520)
            assert(#unmuted==0)
            flush()
            assert(#unmuted==1 and unmuted[1]==567520)
        ''')

    def test_living_players_absent_targets_disabled_and_noop_stay_audible(self):
        self.prepare()
        self.lua.execute('''
            local function attempt() NS.Core.SetClickMacro(probe,macro,NS.app.db) end
            units.target.dead=false; attempt()
            units.target.dead=true; units.target.player=true; attempt()
            units.target=nil; attempt()
            units.target={name='Wolf',dead=true}
            NS.app.db.muteDeadTargetSound=false; attempt()
            NS.app.db.muteDeadTargetSound=true
            macro='/tm [exists] !8'; attempt()
            assert(#muted==0)
        ''')

    def test_repeated_clicks_keep_mute_until_latest_cleanup(self):
        self.prepare()
        self.lua.execute('''
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            local first=table.remove(timers)
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            first(); assert(#unmuted==0)
            flush(); assert(#unmuted==1)
            assert(#muted==1)
        ''')

    def test_missing_audio_api_and_secret_values_fail_open(self):
        self.prepare()
        self.lua.execute('''
            local mute=MuteSoundFile
            MuteSoundFile=nil
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            MuteSoundFile=mute
            issecretvalue=function(v) return v==true end
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            assert(#muted==0 and probe.attributes.macrotext1==macro)
        ''')

    def test_actual_master_and_quest_clicks_use_option_and_default_is_off(self):
        self.prepare()
        self.lua.execute('''
            for _,button in ipairs({NS.UI.master,NS.UI.rows[1],NS.UI.focusButton}) do
                button.entry=NS.UI.rows[1].entry
                button.scripts.PreClick(button,'LeftButton',false)
                assert(#muted>0)
                flush()
            end
        ''')
        self.setUp()
        self.lua.execute('boot(); assert(NS.app.db.muteDeadTargetSound==false)')

    def test_settings_toggle_enables_and_disables_saved_option(self):
        self.prepare()
        self.lua.execute('''
            NS.UI.RegisterSettings(NS.app)
            local toggle=NS.UI.settings.soundToggle
            assert(toggle, 'missing dead-target audio setting')
            toggle.scripts.OnClick(toggle)
            assert(NS.app.db.muteDeadTargetSound==false)
            toggle.scripts.OnClick(toggle)
            assert(NS.app.db.muteDeadTargetSound==true)
        ''')

    def test_combat_hotkey_mutes_without_changing_protected_attributes(self):
        self.prepare()
        self.lua.execute('''
            local master=NS.UI.master
            local before=master.attributes.macrotext1
            combat=true
            master.scripts.PreClick(master,'LeftButton',false)
            assert(#muted==1)
            assert(master.attributes.macrotext1==before)
            combat=false; flush(); assert(#unmuted==1)
        ''')

    def test_logout_releases_own_mute_and_invalidates_timer(self):
        self.prepare()
        self.lua.execute('''
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            event('PLAYER_LOGOUT')
            assert(#unmuted==1)
            flush(); assert(#unmuted==1)
        ''')

    def test_timer_failure_does_not_leave_sound_muted(self):
        self.prepare()
        self.lua.execute('''
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            C_Timer.After=function() error('timer unavailable') end
            NS.Core.SetClickMacro(probe,macro,NS.app.db)
            assert(#unmuted==1)
            flush(); assert(#unmuted==1)
        ''')
