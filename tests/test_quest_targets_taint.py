"""Read-only evidence capture for intermittent protected ActionBar failures."""
import unittest
import test_quest_targets as addon


class TaintDiagnosticsTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_blocked_action_records_function_stack_and_tainted_fields(self):
        self.lua.execute('''
            boot()
            ActionButton1=CreateFrame('Button',nil,UIParent)
            ActionButton1.action=3
            SpellFlyout=CreateFrame('Frame',nil,UIParent)
            local originalHide=SpellFlyout.Hide
            issecurevariable=function(object,key)
                if object==ActionButton1 and key=='action' then return false,'QuestTargets' end
                return true
            end
            debugstack=function() return 'SecureTemplates.lua:357 UseAction()' end
            event('ADDON_ACTION_BLOCKED','QuestTargets','UseAction()')
            local report=NS.app.db.taintDiagnostics
            assert(report and #report.events==1)
            local saved=report.events[1]
            assert(saved.func=='UseAction()' and saved.event=='ADDON_ACTION_BLOCKED')
            assert(saved.stack:find('UseAction',1,true))
            assert(saved.fields['ActionButton1.action']=='QuestTargets')
            assert(SpellFlyout.Hide==originalHide and ActionButton1.action==3)
            assert(not reloaded)
        ''')

    def test_reports_are_bounded_and_other_addons_are_not_recorded(self):
        self.lua.execute('''
            boot()
            event('ADDON_ACTION_BLOCKED','OtherAddon','UseAction()')
            assert(not NS.app.db.taintDiagnostics)
            for i=1,8 do event('ADDON_ACTION_FORBIDDEN','QuestTargets','Blocked '..i) end
            local report=NS.app.db.taintDiagnostics
            assert(#report.events==5 and report.events[1].func=='Blocked 4')
            assert(report.events[5].func=='Blocked 8')
            assert(report.events[5].stack=='Stack API unavailable')
        ''')

    def test_first_observed_transition_survives_later_snapshots_and_refresh(self):
        self.lua.execute('''
            boot()
            local tainted=false
            issecurevariable=function(object,key)
                if object==_G and key=='SpellFlyout' and tainted then return false,'QuestTargets' end
                return true
            end
            NS.Diagnostics.Sample(NS.app,'before')
            assert(not NS.app.db.taintDiagnostics)
            tainted=true
            NS.Diagnostics.Sample(NS.app,'after')
            local first=NS.app.db.taintDiagnostics.first
            assert(first.phase=='after' and first.fields['SpellFlyout']=='QuestTargets')
            NS.Diagnostics.Sample(NS.app,'later')
            NS.app:Refresh()
            assert(NS.app.db.taintDiagnostics.first==first)
        ''')

    def test_secure_probe_failure_does_not_interrupt_targeting_or_combat_events(self):
        self.lua.execute('''
            boot()
            issecurevariable=function() error('API restricted') end
            debugstack=function() error('API restricted') end
            local macro=NS.UI.master.attributes.macrotext1
            combat=true
            event('ADDON_ACTION_BLOCKED','QuestTargets','SpellFlyout:Hide()')
            combat=false
            assert(NS.app.db.taintDiagnostics.events[1].func=='SpellFlyout:Hide()')
            assert(NS.UI.master.attributes.macrotext1==macro)
            NS.app:Refresh()
        ''')

    def test_new_session_replaces_previous_sessions_first_observation(self):
        self.lua.execute('''
            QuestTargetsDB={taintDiagnostics={schema=1,events={},
                first={phase='previous-session',fields={SpellFlyout='OldAddon'}}}}
            boot()
            issecurevariable=function(object,key)
                if object==_G and key=='SpellFlyout' then return false,'QuestTargets' end
                return true
            end
            NS.Diagnostics.Sample(NS.app,'current-session')
            assert(NS.app.db.taintDiagnostics.first.phase=='current-session')
        ''')

    def test_settings_registry_capture_reads_fields_without_calling_getters(self):
        self.lua.execute('''
            boot()
            local addonSetting={variable='QUESTTARGETS_restedXPIntegration'}
            local lockSetting={variable='lockActionBars',pendingValue=true}
            local settingsMap={[addonSetting]={},[lockSetting]={}}
            local getter=function() error('Settings getter must not be called') end
            addonSetting.GetVariable=getter
            lockSetting.GetValue=getter
            lockSetting.GetValueDerived=getter
            Settings.GetValue=getter
            Settings.GetSetting=getter
            SettingsPanel={settings=settingsMap,GetSetting=getter}
            issecurevariable=function(object,key)
                if object==settingsMap and key==addonSetting then return false,'QuestTargets' end
                if object==Settings and key=='GetValue' then return false,'OtherAddon' end
                if object==lockSetting and key=='pendingValue' then return false,'QuestTargets' end
                return true
            end
            event('ADDON_ACTION_FORBIDDEN','QuestTargets','UseAction()')
            local saved=NS.app.db.taintDiagnostics.events[1]
            assert(saved.probes.available and saved.probes.failed==0)
            assert(saved.probes.settingsMapAvailable and saved.probes.settingsEntriesScanned==2)
            assert(saved.fields['Settings.GetValue']=='OtherAddon')
            assert(saved.fields['SettingsPanel.settings[QUESTTARGETS_restedXPIntegration]']=='QuestTargets')
            assert(saved.fields['Settings.lockActionBars.pendingValue']=='QuestTargets')
            assert(SettingsPanel.settings==settingsMap and settingsMap[addonSetting])
            assert(lockSetting.pendingValue==true and Settings.GetValue==getter)
        ''')

    def test_probe_availability_distinguishes_missing_api_from_restricted_api(self):
        self.lua.execute('''
            boot()
            issecurevariable=nil
            event('ADDON_ACTION_BLOCKED','QuestTargets','UseAction()')
            local events=NS.app.db.taintDiagnostics.events
            assert(events[1].probes.available==false and events[1].probes.attempted==0)
            issecurevariable=function() error('API restricted') end
            event('ADDON_ACTION_BLOCKED','QuestTargets','UseAction()')
            assert(events[2].probes.available==true and events[2].probes.failed>0)
        ''')

    def test_settings_registry_scan_is_bounded_and_tolerates_unexpected_entries(self):
        self.lua.execute('''
            boot()
            local settingsMap={}
            for i=1,2050 do settingsMap[{variable=i}]=true end
            SettingsPanel={settings=settingsMap}
            issecurevariable=function() return true end
            event('ADDON_ACTION_BLOCKED','QuestTargets','UseAction()')
            local probes=NS.app.db.taintDiagnostics.events[1].probes
            assert(probes.settingsEntriesScanned==2048 and probes.settingsScanTruncated)
            SettingsPanel.settings='unexpected value'
            event('ADDON_ACTION_BLOCKED','QuestTargets','UseAction()')
            assert(not NS.app.db.taintDiagnostics.events[2].probes.settingsMapAvailable)
        ''')
