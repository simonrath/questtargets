"""Polestar guide integration exercises Quest Targets' real secure master path."""
import unittest
import test_quest_targets as addon


class PolestarTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

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
            assert(NS.UI.master.entry.name=='Marshal McBride')
            assert(not NS.RestedXP.allEntry.names['Old Wolf'])
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
            assert(not NS.RestedXP.allEntry.names['Wrong NPC'])
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
            assert(#NS.RestedXP.targets==0)
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
        ''')

    def test_restedxp_precedence_and_handoff_to_polestar(self):
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
            assert(NS.RestedXP.provider=='restedxp')
            assert(NS.UI.master.entry.name=='RXP Bear')
            NS.app.db.restedXPIntegration=false
            NS.RestedXP.Sync(NS.app)
            assert(NS.RestedXP.provider=='polestar')
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
