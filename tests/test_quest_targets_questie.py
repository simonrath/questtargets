"""Optional Questie tracker buttons use the same quest-specific secure action."""
import unittest
import test_quest_targets as addon


class QuestieTrackerTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_optional_tracker_buttons_follow_questie_lines(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            assert(NS.UI.settings.questieTrackerToggle==nil)
            assert(#NS.QuestieTracker.buttons==0)
            local lines={}
            for i=1,3 do
                local line=CreateFrame('Button',nil,UIParent)
                line.mode=i==3 and 'achieve' or 'quest'
                line.Quest={Id=i}
                line:SetFrameStrata('HIGH')
                line:SetFrameLevel(100)
                line.expandQuest=CreateFrame('Button',nil,line)
                line.expandQuest.left=120
                line.expandQuest.centerY=400
                lines[i]=line
            end
            local pool={GetHighestIndex=function() return 3 end,
                GetLine=function(i) return lines[i] end}
            Questie={db={profile={trackerEnabled=true}}}
            QuestieLoader={ImportModule=function(_,name)
                assert(name=='TrackerLinePool'); return pool end}
            NS.QuestieTracker.Sync(NS.app)
            local button=NS.QuestieTracker.buttons[1]
            assert(button and button.shown and button.parent==UIParent)
            assert(not lines[1].protected)
            assert(button:GetFrameStrata()=='HIGH')
            assert(button:GetFrameLevel()==101)
            assert(button.point[2]==UIParent)
            assert(button.point[4]==119 and button.point[5]==400)
            assert(button.width==22 and button.height==22)
            assert(button.normalTexture.texture:find('QuestCompassUp',1,true))
            assert(button.pushedTexture.texture:find('QuestCompassDown',1,true))
            assert(button.highlight.texture:find('ButtonHilight-Square',1,true))
            assert(button.fontString==nil and button.number==nil)
            assert(button.entry.questID==1)
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            assert(NS.QuestieTracker.buttons[2]==nil)
            lines[1].expandQuest.left=125
            NS.QuestieTracker.Sync(NS.app)
            assert(button.point[4]==124)
            button.scripts.PreClick(button,'LeftButton',false)
            assert(button.attributes.macrotext1:find('Waldwolf',1,true))
            button.scripts.PostClick(button,'LeftButton',false)
            button.scripts.PreClick(button,'RightButton',false)
            button.scripts.PostClick(button,'RightButton',false)
            assert(NS.app.db.focusQuestID==1)
            assert(NS.UI.focusButton.entry.questID==1)
            assert(NS.UI.rows[1].entry.questID==1)
            assert(button.focusMark:IsShown())
            assert(NS.UI.rows[1].focusMark:IsShown())
            NS.UI.rows[1].icon.mouseOver=true
            NS.UI.rows[1].scripts.PostClick(NS.UI.rows[1],'RightButton',false)
            assert(NS.app.db.focusQuestID==nil and not button.focusMark:IsShown())
            NS.UI.rows[1].icon.mouseOver=false
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
            Questie=nil; QuestieLoader=nil
            NS.QuestieTracker.Sync(NS.app)
            assert(not button.shown)
        ''')

    def test_no_questie_and_combat_do_not_mutate_secure_tracker_buttons(self):
        self.lua.execute('''
            boot()
            assert(#NS.QuestieTracker.buttons==0)
            NS.QuestieTracker.Sync(NS.app)
            combat=true
            NS.QuestieTracker.Sync(NS.app)
            combat=false
            assert(#NS.QuestieTracker.buttons==0)
        ''')

    def test_focus_glow_is_always_visible_in_both_lists_on_all_flavors(self):
        for flavor, interface in (('Forever', 16001), ('Retail', 120100),
                                  ('Classic', 11509), ('TBC', 20506), ('Mists', 50504)):
            for atlas_available in (True, False):
                with self.subTest(flavor=flavor, atlas=atlas_available):
                    self.setUp()
                    self.lua.globals().focusTestInterface = interface
                    self.lua.globals().focusTestAtlas = atlas_available
                    self.lua.execute('''
                        GetBuildInfo=function() return '', '', '', focusTestInterface end
                        C_Texture={GetAtlasInfo=function(atlas)
                            assert(atlas=='UI-QuestPoi-InnerGlow')
                            return focusTestAtlas and {width=32,height=32} or nil
                        end}
                        QuestTargetsDB={focusMarkEnabled=false}
                        quests[2].watched=true
                        plate('Fellwolf','Warme Felle','Wolfsfell: 1/4')
                        boot()
                        assert(NS.app.db.focusMarkEnabled==nil)
                        local lines={}
                        for i=1,2 do
                            local line=CreateFrame('Button',nil,UIParent)
                            line.mode='quest'; line.Quest={Id=i}
                            line.expandQuest=CreateFrame('Button',nil,line)
                            line.expandQuest.left=120; line.expandQuest.centerY=400-i*30
                            lines[i]=line
                        end
                        Questie={db={profile={trackerEnabled=true}}}
                        QuestieLoader={ImportModule=function()
                            return {GetHighestIndex=function() return 2 end,
                                GetLine=function(i) return lines[i] end}
                        end}
                        NS.QuestieTracker.Sync(NS.app)
                        local rows, buttons=NS.UI.rows, NS.QuestieTracker.buttons
                        for i=1,2 do
                            for _,mark in ipairs({rows[i].focusMark,buttons[i].focusMark}) do
                                assert(mark.blendMode=='ADD')
                                assert(not mark:IsShown())
                                if focusTestAtlas then
                                    assert(mark.atlas=='UI-QuestPoi-InnerGlow')
                                else
                                    assert(mark.texture=='Interface\\\\WorldMap\\\\UI-QuestPoi-NumberIcons')
                                    assert(mark.texCoords[1]==0.625 and mark.texCoords[2]==0.75
                                        and mark.texCoords[3]==0.375 and mark.texCoords[4]==0.5)
                                end
                            end
                        end
                        buttons[1].scripts.PostClick(buttons[1],'RightButton',false)
                        assert(rows[1].focusMark:IsShown() and buttons[1].focusMark:IsShown())
                        assert(not rows[2].focusMark:IsShown() and not buttons[2].focusMark:IsShown())
                        rows[2].icon.mouseOver=true
                        rows[2].scripts.PostClick(rows[2],'RightButton',false)
                        assert(not rows[1].focusMark:IsShown() and not buttons[1].focusMark:IsShown())
                        assert(rows[2].focusMark:IsShown() and buttons[2].focusMark:IsShown())
                        NS.app:Refresh()
                        assert(rows[2].focusMark:IsShown() and buttons[2].focusMark:IsShown())
                        buttons[2].scripts.PostClick(buttons[2],'RightButton',false)
                        assert(not rows[2].focusMark:IsShown() and not buttons[2].focusMark:IsShown())
                        NS.UI.Settings(NS.app)
                        assert(NS.UI.settings.focusMarkerToggle==nil)
                    ''')

    def test_automatic_questie_integration_does_not_install_pool_hooks(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            local pool={GetHighestIndex=function() return 0 end,
                GetLine=function() end,
                ResetLinesForChange=function() end,
                HideUnusedLines=function() end}
            local reset, hide=pool.ResetLinesForChange, pool.HideUnusedLines
            Questie={db={profile={trackerEnabled=true}}}
            QuestieLoader={ImportModule=function() return pool end}
            NS.QuestieTracker.Sync(NS.app)
            assert(pool.ResetLinesForChange==reset and pool.HideUnusedLines==hide)
            assert(NS.UI.settings.questieTrackerToggle==nil)
        ''')

    def test_questie_buttons_appear_without_setting_or_reload(self):
        self.lua.execute('''
            boot(); NS.UI.Settings(NS.app)
            local line=CreateFrame('Button',nil,UIParent)
            line.mode='quest'; line.Quest={Id=1}
            line.expandQuest=CreateFrame('Button',nil,line)
            local pool={GetHighestIndex=function() return 1 end,
                GetLine=function() return line end}
            Questie={db={profile={trackerEnabled=true}}}
            QuestieLoader={ImportModule=function() return pool end}
            NS.QuestieTracker.Sync(NS.app)
            local button=NS.QuestieTracker.buttons[1]
            assert(button and button.shown)
            assert(not reloaded)
            Questie=nil; QuestieLoader=nil
            NS.QuestieTracker.Sync(NS.app)
            assert(not button.shown)
        ''')
