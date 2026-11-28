"""Polestar guide integration exercises Next's real secure master path."""
import unittest
import test_quest_targets as addon


class PolestarTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_polestar_option_and_upstream_lock_fit_and_work_together(self):
        self.lua.execute('''
            C_AddOns={IsAddOnLoaded=function(name) return name=='Polestar' end}
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals={{t='kill',status='active',subject='Wolf'}}} end}}
            boot()
            NS.UI.Settings(NS.app)
            local options, master = NS.UI.settings, NS.UI.masterSettings
            local bar = master.lockToggle.parent
            assert(options.polestarToggle.parent==bar)
            assert(options.polestarToggle.point[2] > options.masterToggle.point[2])
            assert(options.masterToggle.point[3] > options.polestarToggle.point[3])
            assert(options.polestarToggle.point[3] > options.restedXPToggle.point[3])
            assert(master.dividersToggle.point[3] > master.lockToggle.point[3])
            assert(master.lockToggle.point[3] > master.moveButton.point[3])
            assert(master.moveHelp.point[5] - master.moveHelp.height >= -bar.height)
            assert(options.pages[3].content.height >= 390 + bar.height)
            assert(options.polestarToggle:GetChecked() and NS.UI.master.entry.name=='Wolf')
            master.lockToggle.scripts.OnClick()
            assert(NS.app.db.masterLocked and NS.UI.master.entry.name=='Wolf')
        ''')

    def test_first_click_prefers_polestars_current_goal_without_questiedb_or_restedxp(self):
        self.lua.execute('''
            C_AddOns={IsAddOnLoaded=function(name) return name=='Polestar' end}
            local goals={}
            for i=1,6 do
                goals[i]={t='kill',status='pending',subject='Earlier Guide Objective '..i}
            end
            goals[7]={t='turnin',status='active',npcName='Current Guide NPC'}
            local current=7
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {current=current,goals=goals} end}}
            QuestTargetsDB={polestarIntegration=true,restedXPIntegration=true,autoMark=false}
            boot()
            assert(not NS.Database.Provider() and not NS.RestedXP.active)
            local button=NS.UI.master
            button.scripts.PreClick(button,'LeftButton',false)
            local macro=button.attributes.macrotext1
            assert(macro:match('/targetexact %[noexists%] ([^%c]+)')=='Current Guide NPC', macro)
            assert(#macro<=NS.Core.MACRO_BYTES)
            current=6
            button.scripts.PreClick(button,'LeftButton',false)
            macro=button.attributes.macrotext1
            assert(macro:match('/targetexact %[noexists%] ([^%c]+)')=='Earlier Guide Objective 6', macro)
        ''')

    def test_polestar_only_login_skips_missing_questiedb_popup(self):
        self.lua.execute('''
            GetBuildInfo=function() return '1.60.1','','',16001 end
            local installed={Polestar=true}
            C_AddOns={IsAddOnLoaded=function(name) return installed[name]==true end}
            local missingDialog='QUESTTARGETS_MISSING_QUESTIEDB'
            local warnings=0
            StaticPopupDialogs={}
            StaticPopup_Show=function(key)
                if key==missingDialog then warnings=warnings+1 end
            end
            boot()
            QuestTargetsTutorial.secondary.scripts.OnClick()
            assert(warnings==0, 'Polestar-only login showed the QuestieDB warning')
            installed.RXPGuides=true
            event('PLAYER_LOGIN')
            assert(warnings==1)
            installed.Polestar=nil
            installed.RXPGuides=nil
            event('PLAYER_LOGIN')
            assert(warnings==2)
        ''')

    def test_missing_database_status_guides_when_polestar_was_disabled(self):
        self.lua.execute('''
            GetBuildInfo=function() return '1.60.1','','',16001 end
            C_AddOns={IsAddOnLoaded=function(name) return name=='Polestar' end}
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals={{t='kill',status='active',subject='Wolf'}}} end}}
            QuestTargetsDB={polestarIntegration=false}
            boot()
            assert(NS.app.db.polestarIntegration==false)
            assert(NS.UI.database.text:find('Polestar',1,true), 'Missing Polestar guidance when disabled')
            NS.UI.Settings(NS.app)
            NS.UI.settings.polestarToggle.scripts.OnClick()
            assert(NS.UI.database.text==NS.L('dbMissing'))
            assert(NS.UI.master.entry.name=='Wolf')
        ''')

    def test_current_collect_prioritizes_named_raw_npc_sources(self):
        self.lua.execute('''
            local raw={{t='kill',npc=12,target='Previous Mob'},
                {t='collect',quest=94434,item=2589,
                    fromNpcs={{npc=6497,npcName='Astor Hadren'},
                        {npc=3617,npcName='Lordaeron Citizen'}, {npcName='Bad/quit'}}}}
            Polestar={Names={Npc=function(id) if id==6497 then return 'Localized Astor' end end},
                Engine={GetStepIndex=function() return 1 end,
                    GetStepView=function() return {current=2,goals={
                        {t='kill',status='pending',subject='Previous Mob'},
                        {t='collect',status='active',subject='Linen Cloth'},
                    }} end,
                    GetGuide=function() return {steps={{goals=raw}}} end}}
            QuestTargetsDB={polestarIntegration=true,autoMark=false}
            boot()
            local master=NS.UI.master
            master.scripts.PreClick(master,'LeftButton',false)
            local macro=master:GetAttribute('macrotext1')
            assert(macro:match('/targetexact %[noexists%] ([^%c]+)')=='Localized Astor', macro)
            assert(master.entry.names['Lordaeron Citizen'])
            assert(not master.entry.names['Astor Hadren'] and not master.entry.names['Bad/quit'])
        ''')

    def test_current_use_targets_creatures_from_the_guide(self):
        self.lua.execute('''
            local raw={{t='use',item=13892,fromNpcs={
                {npc=4700,npcName='Aged Kodo'}, {npc=4701,npcName='Dying Kodo'},
            }}}
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {current=1,goals={
                    {t='use',status='active',subject='Kodo Kombobulator'},
                }} end,
                GetGuide=function() return {steps={{goals=raw}}} end}}
            QuestTargetsDB={polestarIntegration=true,autoMark=false}
            boot()
            local master=NS.UI.master
            master.scripts.PreClick(master,'LeftButton',false)
            local macro=master:GetAttribute('macrotext1')
            assert(macro:match('/targetexact %[noexists%] ([^%c]+)')=='Aged Kodo', macro)
            assert(master.entry.names['Dying Kodo'] and not master.entry.names['Kodo Kombobulator'])
        ''')

    def test_collect_alternative_cycles_and_excludes_unsafe_or_object_sources(self):
        self.lua.execute('''
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals={
                    {t='collect',status='active',source={kind='npc',name='Grell',also='Grellkin',enemy=true}},
                    {t='collect',status='pending',source={kind='npc',name='Grell',also='Bad/quit',enemy=true}},
                    {t='collect',status='active',source={kind='object',name='Chest',also='Crate'}},
                }} end}}
            QuestTargetsDB={polestarIntegration=true,autoMark=false}
            boot()
            assert(NS.UI.master.entry.names.Grell and NS.UI.master.entry.names.Grellkin)
            local button=NS.UI.master
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Grell',1,true))
            button.scripts.PostClick(button,'LeftButton',false)
            assert(button.entry.names.Grellkin)
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Grellkin',1,true))
        ''')

    def test_friendly_collect_sources_stay_selected_across_master_clicks(self):
        self.lua.execute('''
            local goals={{t='collect',status='active',source={kind='npc',
                name='Friendly Trader',also='Other Trader',enemy=false}}}
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals=goals} end}}
            QuestTargetsDB={polestarIntegration=true,autoMark=false}
            boot()
            assert(NS.UI.master.entry.finisherNames['Friendly Trader'])
            assert(NS.UI.master.entry.finisherNames['Other Trader'])
            units.target={name='Friendly Trader',friendly=true}
            assert(NS.Core.ValidCurrentTarget(NS.UI.master.entry))
            local button=NS.UI.master
            button.scripts.PreClick(button,'LeftButton',false)
            assert(not button.attributes.macrotext1:find('/cleartarget',1,true))
            button.scripts.PostClick(button,'LeftButton',false)
            button.scripts.PreClick(button,'LeftButton',false)
            assert(not button.attributes.macrotext1:find('/cleartarget',1,true))
            goals[1].source.enemy=true
            NS.RestedXP.Sync(NS.app)
            assert(not NS.UI.master.entry.finisherNames['Friendly Trader'])
            assert(not NS.Core.ValidCurrentTarget(NS.UI.master.entry))
        ''')

    def test_friendly_collect_source_overrides_matching_native_name_only(self):
        self.lua.execute('''
            local goals={{t='collect',status='active',source={kind='npc',
                name='Waldwolf',also='Other Trader',enemy=false}}}
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals=goals} end}}
            QuestTargetsDB={polestarIntegration=true,autoMark=false}
            boot()
            assert(NS.UI.master.defaultEntry.names['Waldwolf'])
            assert(NS.UI.master.entry.finisherNames['Waldwolf'])
            units.target={name='Other Trader',friendly=true}
            assert(NS.Core.ValidCurrentTarget(NS.UI.master.entry))
            NS.UI.master.scripts.PreClick(NS.UI.master,'LeftButton',false)
            assert(not NS.UI.master.attributes.macrotext1:find('/cleartarget',1,true))
            goals[1].npcName='Different Mob'
            NS.RestedXP.Sync(NS.app)
            assert(not NS.UI.master.entry.finisherNames['Different Mob'])
            assert(NS.UI.master.entry.finisherNames['Other Trader'])
        ''')

    def test_master_follows_open_polestar_goals_and_returns_to_native(self):
        self.lua.execute('''
            local goals = {
                {t='kill', status='active', subject='Timber Wolf', subjectKind='npc'},
                {t='turnin', status='pending', npcName='Marshal McBride'},
                {t='kill', status='done', subject='Old Wolf', subjectKind='npc'},
            }
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals=goals} end,
                GetGuide=function() return {steps={{goals={}}}} end}}
            QuestTargetsDB={polestarIntegration=true,autoMark=false}
            boot()
            assert(NS.UI.master.entry.name=='Timber Wolf')
            NS.UI.master.scripts.PreClick(NS.UI.master,'LeftButton',false)
            assert(NS.UI.master.attributes.macrotext1:find('Timber Wolf',1,true))
            NS.UI.master.scripts.PostClick(NS.UI.master,'LeftButton',false)
            assert(NS.UI.master.entry.names['Marshal McBride'])
            assert(not NS.UI.master.entry.names['Old Wolf'])
            goals={}
            NS.app:Poll()
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
        ''')

    def test_provider_absence_errors_and_combat_keep_native_safe(self):
        self.lua.execute('''
            QuestTargetsDB={polestarIntegration=true}
            boot()
            assert(not NS.RestedXP.active)
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() error('provider failed') end}}
            NS.app:Poll()
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
            local before=NS.UI.master.attributes.macrotext1
            combat=true
            NS.app:Poll()
            NS.RestedXP.Sync(NS.app)
            assert(NS.UI.master.attributes.macrotext1==before)
            combat=false
            Polestar=nil
            NS.app:Poll()
            assert(not NS.RestedXP.active)
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
        ''')

    def test_selected_npc_never_borrows_another_raw_npc(self):
        self.lua.execute('''
            Polestar={Names={Npc=function(id) if id==1 then return 'Wrong NPC' end end},
                Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals={
                    {t='turnin',status='active',npcName='Correct NPC'}}} end,
                GetGuide=function() return {steps={{goals={{npc=1}}}}} end}}
            QuestTargetsDB={polestarIntegration=true}
            boot()
            assert(not NS.UI.master.entry.names['Wrong NPC'])
            assert(NS.UI.master.entry.name=='Correct NPC')
        ''')

    def test_no_target_for_inactive_objects_or_unsafe_names(self):
        self.lua.execute('''
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals={
                    {t='accept',status='na',npcName='Hidden'},
                    {t='kill',status='skipped',subject='Skipped'},
                    {t='collect',status='active',subject='Copper Ore',source={kind='object',name='Chest'}},
                    {t='turnin',status='active',npcName='Bad\\n/quit'},
                }} end}}
            QuestTargetsDB={polestarIntegration=true}
            boot()
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
        ''')

    def test_master_combines_both_guides_and_keeps_blue_restedxp_only(self):
        self.lua.execute('''
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals={{t='kill',status='active',subject='Polestar Wolf'}}} end}}
            local rxp={RXPFrame={activeSteps={{active=true,elements={{mobs={'RXP Bear'}}}}}},
                GetCreatureName=function(id) return id end}
            local oldLibStub=LibStub
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            else return oldLibStub(name) end end
            QuestTargetsDB={polestarIntegration=true,restedXPIntegration=true}
            boot()
            assert(NS.UI.master.entry.names['RXP Bear'] and NS.UI.master.entry.names['Polestar Wolf'])
            assert(NS.RestedXP.button.entry.names['RXP Bear'])
            assert(not NS.RestedXP.button.entry.names['Polestar Wolf'])
            NS.app.db.restedXPIntegration=false
            NS.RestedXP.Sync(NS.app)
            assert(not NS.UI.master.entry.names['RXP Bear'])
            assert(NS.UI.master.entry.name=='Polestar Wolf')
            assert(not NS.RestedXP.button:IsShown())
            NS.app.db.polestarIntegration=false
            NS.RestedXP.Sync(NS.app)
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
        ''')

    def test_step_change_refreshes_after_combat(self):
        self.lua.execute('''
            local name='First Wolf'
            Polestar={Engine={GetStepIndex=function() return 1 end,
                GetStepView=function() return {goals={{t='kill',status='active',subject=name}}} end}}
            QuestTargetsDB={polestarIntegration=true}
            boot()
            assert(NS.UI.master.entry.name=='First Wolf')
            combat=true
            name='Second Wolf'
            NS.app:Poll()
            assert(NS.UI.master.entry.name=='First Wolf')
            combat=false
            event('PLAYER_REGEN_ENABLED')
            flush()
            NS.app:Poll()
            assert(NS.UI.master.entry.name=='Second Wolf')
        ''')
