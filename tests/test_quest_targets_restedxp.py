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
                {active=false,elements={{tag='target',targets={'Unrelated vendor'}}}},
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
            rxp.RXPFrame.activeSteps[1].active=false
            NS.RestedXP.Sync(NS.app)
            assert(NS.UI.master.entry.name=='Waldwolf')
            assert(#NS.RestedXP.targets==1)
        ''')

    def test_active_flight_path_step_targets_explicit_npc(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{tag='fp',fpId=6},
                    {tag='target',targets={'Gryth Thurden'}}}},
                {active=false,elements={{tag='mob',mobs={'Not a quest mob'}}}},
                {active=false,elements={{tag='target',targets={'Inactive vendor'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            assert(#NS.RestedXP.targets==1)
            assert(NS.UI.master.entry.name=='Gryth Thurden')
            assert(NS.UI.master.entry.finisherNames['Gryth Thurden'])
            assert(NS.UI.master.attributes.macrotext1:find('/targetexact [noexists] Gryth Thurden',1,true))
            assert(NS.RestedXP.button.entry.name=='Gryth Thurden')
            assert(NS.RestedXP.button:IsVisible())
            NS.RestedXP.button.scripts.PreClick(NS.RestedXP.button,'LeftButton',false)
            assert(NS.RestedXP.button.attributes.macrotext1:find('Gryth Thurden',1,true))
        ''')

    def test_active_collect_step_targets_guide_mob_outside_quest_log(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{tag='collect',itemId=769},
                    {tag='mob',mobs={'Elder Crag Boar'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id)
                    if id=='Elder Crag Boar' then return 'Alter Klippeneber' end
                    return id
                end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            assert(NS.UI.master.entry.name=='Alter Klippeneber')
            assert(not NS.UI.master.entry.finisherNames['Alter Klippeneber'])
            assert(NS.UI.master.attributes.macrotext1:find('/targetexact [noexists] Alter Klippeneber',1,true))
            assert(NS.RestedXP.button:IsVisible())
        ''')

    def test_next_guide_target_does_not_clear_current_mob_on_a_miss(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{mobs={'Alter Klippeneber'}}}},
                {active=true,elements={{targets={'Rudra Amberstill'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            local button=NS.RestedXP.button
            assert(button.entry.name=='Alter Klippeneber')
            button.scripts.PreClick(button,'LeftButton',false)
            units.target={name='Alter Klippeneber',guid='Boar'}
            currentGUID='Boar'
            button.scripts.PostClick(button,'LeftButton',false)
            assert(button.entry.name=='Rudra Amberstill')
            flush()
            assert(not button.attributes.macrotext1:find('/targetexact',1,true))
            assert(not NS.UI.master.attributes.macrotext1:find('/cleartarget',1,true))
            button.scripts.PreClick(button,'LeftButton',false)
            local macro=button.attributes.macrotext1
            assert(not macro:find('/targetexact',1,true))
            assert(not macro:find('/cleartarget',1,true))
            assert(currentGUID=='Boar')
            NS.UI.master.scripts.PreClick(NS.UI.master,'LeftButton',false)
            local masterMacro=NS.UI.master.attributes.macrotext1
            assert(not masterMacro:find('/targetexact',1,true))
            assert(not masterMacro:find('/cleartarget',1,true))
        ''')

    def test_native_fallback_preserves_selected_guide_mob(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{mobs={'Alter Klippeneber'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            NS.RestedXP.fallbackOnce=true
            NS.RestedXP.Sync(NS.app)
            local button=NS.RestedXP.button
            assert(button.entry==NS.UI.master.defaultEntry)
            units.target={name='Alter Klippeneber',guid='Boar'}
            currentGUID='Boar'
            button.scripts.PreClick(button,'LeftButton',false)
            local macro=button.attributes.macrotext1
            assert(not macro:find('/targetexact',1,true))
            assert(not macro:find('/cleartarget',1,true))
        ''')

    def test_selected_native_quest_mob_survives_guide_retry(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{targets={'Distant Guide NPC'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            units.target={name='Waldwolf',guid='Wolf'}
            currentGUID='Wolf'
            NS.RestedXP.Sync(NS.app)
            local button=NS.RestedXP.button
            assert(not button.attributes.macrotext1:find('/targetexact',1,true))
            button.scripts.PreClick(button,'LeftButton',false)
            local macro=button.attributes.macrotext1
            assert(not macro:find('/targetexact',1,true))
            assert(not macro:find('/cleartarget',1,true))
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
            assert(NS.UI.master.entry.name=='Nicht im Questlog')
            local button=NS.RestedXP.button
            assert(button and button.parent==frame and button:IsVisible())
            assert(button.point[2]==frame and button.point[4]==4)
            assert(button.attributes.type1=='macro')
            assert(button.entry.name=='Nicht im Questlog')
            assert(button.attributes.macrotext1:find('Nicht im Questlog',1,true))
            button.scripts.PreClick(button,'LeftButton',false)
            button.scripts.PostClick(button,'LeftButton',false)
            assert(NS.UI.master.entry.name=='Waldwolf')
            assert(button.entry.name=='Waldwolf')
            assert(NS.UI.master.attributes.macrotext1:find('Waldwolf',1,true))
            NS.UI.master.scripts.PreClick(NS.UI.master,'LeftButton',false)
            NS.UI.master.scripts.PostClick(NS.UI.master,'LeftButton',false)
            assert(NS.UI.master.entry.name=='Spinne')
            combat=true
            rxp.RXPFrame.activeSteps={{active=true,elements={{mobs={12}}}}}
            NS.RestedXP.Sync(NS.app)
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Spinne',1,true))
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

    def test_no_restedxp_and_inactive_step_do_not_target_unrelated_quests(self):
        self.lua.execute('''
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            assert(NS.UI.master.entry.name=='Waldwolf')
            assert(NS.RestedXP.button==nil)
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={{active=false,elements={{mobs={77}}}}}},
                targeting={activeTargetFrame=frame},settings={profile={enableTargetFrame=true}},
                GetCreatureName=function() return 'Nicht im Questlog' end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            NS.RestedXP.Sync(NS.app)
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
            assert(NS.UI.master.entry.name=='Waldwolf')
            assert(NS.RestedXP.button:IsVisible())
            NS.RestedXP.button.scripts.PreClick(NS.RestedXP.button,'LeftButton',false)
            assert(NS.RestedXP.button.attributes.macrotext1:find('Waldwolf',1,true))
        ''')

    def test_failed_guide_target_uses_native_search_on_next_click(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{targets={'Distant Guide NPC'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            local button=NS.RestedXP.button
            button.scripts.PreClick(button,'LeftButton',false)
            local macro=button.attributes.macrotext1
            assert(macro:find('Distant Guide NPC',1,true))
            assert(macro:find('/targetexact [noexists] Waldwolf',1,true))
            button.scripts.PostClick(button,'LeftButton',false)
            flush()
            assert(button.entry==NS.UI.master.defaultEntry)
            assert(NS.UI.master.entry==NS.UI.master.defaultEntry)
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            button.scripts.PostClick(button,'LeftButton',false)
            assert(button.entry.name=='Distant Guide NPC')
        ''')

    def test_successful_guide_target_does_not_enter_native_fallback(self):
        self.lua.execute('''
            local frame=CreateFrame('Frame','RXPTargetFrame',UIParent)
            local rxp={RXPFrame={activeSteps={
                {active=true,elements={{targets={'Rudra Amberstill'}}}}
            }},targeting={activeTargetFrame=frame},
                settings={profile={enableTargetFrame=true}},
                GetCreatureName=function(id) return id end}
            LibStub=function(name) if name=='AceAddon-3.0' then
                return {GetAddon=function() return rxp end}
            end end
            QuestTargetsDB={restedXPIntegration=true}
            boot()
            local button=NS.RestedXP.button
            button.scripts.PreClick(button,'LeftButton',false)
            units.target={name='Rudra Amberstill',guid='GuideNPC'}
            currentGUID='GuideNPC'
            button.scripts.PostClick(button,'LeftButton',false)
            flush()
            assert(button.entry.name=='Rudra Amberstill')
            assert(not NS.RestedXP.fallbackOnce)
        ''')

    def test_explicit_turn_in_npc_follows_active_guide_step(self):
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
            assert(NS.UI.master.entry.name=='Marschall Dughan')
            assert(NS.UI.master.entry.finisherNames['Marschall Dughan'])
            quests[1].ready=true
            NS.app:Refresh()
            assert(NS.UI.master.entry.name=='Marschall Dughan')
            assert(NS.UI.master.entry.finisherNames['Marschall Dughan'])
            assert(NS.RestedXP.button:IsVisible())
        ''')


if __name__ == '__main__':
    unittest.main()
