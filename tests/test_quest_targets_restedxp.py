"""RestedXP mode follows active guide steps without borrowing protected buttons."""
import unittest
import test_quest_targets as addon


class RestedXPTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_active_accept_step_targets_its_npc_before_quest_is_in_log(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local accept={tag='accept',questId=6661,completed=false}
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{tag='target',targets={'Monty'}},accept}},
                {active=true,elements={{tag='target',targets={'Unrelated vendor'}}}},
                {active=true,elements={{tag='mob',mobs={'Waldwolf'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            assert(NS.UI.master.entry.name=='Monty')
            assert(NS.UI.master.entry.finisherNames.Monty)
            assert(NS.UI.master.attributes.macrotext1:find('Monty',1,true))
            assert(NS.RestedXP.button.entry.name=='Monty')
            NS.UI.master.scripts.PreClick(NS.UI.master,'LeftButton',false)
            NS.UI.master.scripts.PostClick(NS.UI.master,'LeftButton',false)
            assert(NS.UI.master.entry.name=='Waldwolf')
            accept.completed=true
            NS.RestedXP.Sync(NS.app)
            assert(NS.UI.master.entry.name=='Waldwolf')
            assert(#NS.RestedXP.targets==1)
        ''')

    def test_guided_master_and_attached_button_cycle_matching_quest_targets(self):
        self.lua.execute('''
            quests[3]={questID=3,title='Spinnen',objectives={
                {type='monster',text='Spinne getötet: 0/3',numFulfilled=0,numRequired=3,finished=false}}}
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={{active=true,elements={{mobs={10,11,12}}}}}},
                targeting={activeTargetFrame=frame},settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return ({[10]='Nicht im Questlog',
                    [11]='Waldwolf',[12]='Spinne'})[id] end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function(_,addonName) if addonName=='RXPGuides' then return rxp end end}
            end end
            boot(); NS.UI.Settings(NS.app)
            assert(NS.UI.settings.restedXPToggle:GetChecked()==false)
            assert(NS.UI.master.entry.nameList[1]=='Spinne' or NS.UI.master.entry.nameList[1]=='Waldwolf')
            NS.UI.settings.restedXPToggle.scripts.OnClick()
            assert(NS.app.db.restedXPIntegration)
            assert(NS.UI.master.entry.name=='Waldwolf')
            local button=NS.RestedXP.button
            assert(button and button.parent==frame and button:IsVisible())
            assert(button.point[2]==frame and button.point[4]==4)
            assert(button.attributes.type1=='macro')
            assert(button.entry.name=='Waldwolf')
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            button.scripts.PreClick(button,'LeftButton',false)
            button.scripts.PostClick(button,'LeftButton',false)
            assert(NS.UI.master.entry.name=='Spinne')
            assert(button.entry.name=='Spinne')
            assert(NS.UI.master.attributes.macrotext1:find('Spinne',1,true))
            NS.UI.master.scripts.PreClick(NS.UI.master,'LeftButton',false)
            NS.UI.master.scripts.PostClick(NS.UI.master,'LeftButton',false)
            assert(NS.UI.master.entry.name=='Waldwolf')
            combat=true
            rxp.RXPFrame.activeSteps={{active=true,elements={{mobs={12}}}}}
            NS.RestedXP.Sync(NS.app)
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            combat=false
            NS.RestedXP.Sync(NS.app)
            assert(NS.UI.master.entry.name=='Spinne')
            local replacement=CreateFrame('Frame',nil,UIParent)
            rxp.targeting.activeTargetFrame=replacement
            NS.RestedXP.Sync(NS.app)
            assert(button.parent==replacement and button.rxpFrame==replacement)
            replacement:Hide()
            assert(not button:IsVisible())
            NS.UI.settings.restedXPToggle.scripts.OnClick()
            assert(not NS.app.db.restedXPIntegration and not button.shown)
            assert(NS.UI.master.entry.nameList[1]=='Spinne' or NS.UI.master.entry.nameList[1]=='Waldwolf')
        ''')

    def test_no_restedxp_and_no_matching_step_do_not_target_unrelated_quests(self):
        self.lua.execute('''
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            assert(NS.UI.master.entry.name=='Waldwolf')
            assert(NS.RestedXP.button==nil)
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={{active=true,elements={{mobs={77}}}}}},
                targeting={activeTargetFrame=frame},settings={profile={enableTargetFrame=true}},
                GetCreatureName=function() return 'Nicht im Questlog' end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            NS.RestedXP.Sync(NS.app)
            assert(NS.UI.master.entry==nil)
            assert(NS.UI.master.attributes.macrotext1==nil)
            assert(NS.RestedXP.button==nil or not NS.RestedXP.button.shown)
        ''')

    def test_ready_turn_in_npc_is_eligible_only_when_quest_is_ready(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={{active=true,elements={{targets={9}}}}}},
                targeting={activeTargetFrame=frame},settings={profile={enableTargetFrame=true}},
                GetCreatureName=function() return 'Marschall Dughan' end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            NS.Database.ResolveTurnIns=function() return {['Marschall Dughan']=true} end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            assert(NS.UI.master.entry==nil)
            quests[1].ready=true
            NS.app:Refresh()
            assert(NS.UI.master.entry.name=='Marschall Dughan')
            assert(NS.UI.master.entry.finisherNames['Marschall Dughan'])
            assert(NS.RestedXP.button:IsVisible())
        ''')


if __name__ == '__main__':
    unittest.main()
