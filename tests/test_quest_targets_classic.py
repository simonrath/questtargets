"""Classic 1.15.9 quest-log API and native quest-window regressions."""
import unittest
import test_quest_targets as addon


class ClassicTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_legacy_log_watch_filter_and_turnin_status(self):
        self.lua.execute('''
            C_QuestLog.GetInfo=nil
            C_QuestLog.GetNumQuestLogEntries=nil
            C_QuestLog.GetQuestWatchType=nil
            C_QuestLog.ReadyForTurnIn=nil
            function GetNumQuestLogEntries() return 4 end
            function GetQuestLogTitle(i)
                if i==1 then return 'Zone',0,nil,true end
                local q=quests[i-1]
                return q.title,10,nil,false,false,q.complete,nil,q.questID
            end
            function IsQuestWatched(i) return i==2 and 1 or false end
            quests[3]={questID=3,title='Turn in',complete=1,objectives={}}
            boot()
            local all,err=NS.Core.ReadQuests(false)
            assert(not err and #all==3)
            assert(all[1].id==1 and all[1].objectives[1].done==2)
            assert(all[3].ready and #all[3].objectives==0)
            local watched=NS.Core.ReadQuests(true)
            assert(#watched==1 and watched[1].id==1)
            QuestMapFrame_OpenToQuestDetails=nil
            QuestLogFrame={}
            function ShowUIPanel(f) assert(f==QuestLogFrame); opened=true end
            function QuestLog_SetSelection(i) selected=i end
            function QuestLog_Update() updated=true end
            NS.UI.OpenQuest({questID=2})
            assert(opened and updated and selected==3)
        ''')


if __name__ == '__main__':
    unittest.main()
