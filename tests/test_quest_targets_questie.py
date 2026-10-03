"""Optional Questie tracker buttons use the same quest-specific secure action."""
import unittest
import test_quest_targets as addon


class QuestieTrackerTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_optional_tracker_buttons_follow_questie_lines(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            assert(NS.UI.settings.questieTrackerToggle:GetChecked()==false)
            assert(#NS.QuestieTracker.buttons==0)
            local lines={}
            for i=1,3 do
                local line=CreateFrame('Button',nil,UIParent)
                line.mode=i==3 and 'achieve' or 'quest'
                line.Quest={Id=i}
                line.expandQuest=CreateFrame('Button',nil,line)
                lines[i]=line
            end
            local pool={GetHighestIndex=function() return 3 end,
                GetLine=function(i) return lines[i] end}
            Questie={db={profile={trackerEnabled=true}}}
            QuestieLoader={ImportModule=function(_,name)
                assert(name=='TrackerLinePool'); return pool end}
            NS.UI.settings.questieTrackerToggle.scripts.OnClick()
            local button=NS.QuestieTracker.buttons[1]
            assert(NS.app.db.questieTrackerButtons==true)
            assert(button and button.shown and button.parent==lines[1])
            assert(button.point[2]==lines[1].expandQuest)
            assert(button.point[4]==-1)
            assert(button.width==22 and button.height==22)
            assert(button.normalTexture.texture:find('QuestCompassUp',1,true))
            assert(button.pushedTexture.texture:find('QuestCompassDown',1,true))
            assert(button.highlight.texture:find('ButtonHilight-Square',1,true))
            assert(button.fontString==nil and button.number==nil)
            assert(button.entry.questID==1)
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            assert(NS.QuestieTracker.buttons[2]==nil)
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            button.scripts.PostClick(button,'LeftButton',false)
            combat=true
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            combat=false
            lines[1].Quest={Id=999}
            NS.QuestieTracker.Sync(NS.app)
            assert(not button.shown)
            lines[1].Quest={Id=1}
            NS.QuestieTracker.Sync(NS.app)
            assert(button.shown)
            NS.UI.settings.questieTrackerToggle.scripts.OnClick()
            assert(not button.shown and not NS.app.db.questieTrackerButtons)
        ''')

    def test_no_questie_and_combat_do_not_mutate_secure_tracker_buttons(self):
        self.lua.execute('''
            QuestTargetsDB={questieTrackerButtons=true}
            boot()
            assert(#NS.QuestieTracker.buttons==0)
            NS.QuestieTracker.Sync(NS.app)
            combat=true
            NS.QuestieTracker.Sync(NS.app)
            combat=false
            assert(#NS.QuestieTracker.buttons==0)
        ''')
