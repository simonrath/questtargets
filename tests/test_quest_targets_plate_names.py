import unittest
import test_quest_targets as addon


class PlateNameTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_visible_targets_do_not_use_nameplate_as_secure_target(self):
        self.lua.execute('''boot()
            plate('Waldwolf','','').guid='A'
            plate('Waldwolf','','').guid='B'
            for _,row in ipairs({NS.UI.master,NS.UI.rows[1]}) do
                currentGUID=nil
                row.scripts.PreClick(row,'LeftButton',false)
                local macro=row.attributes.macrotext1
                assert(not macro:find('@nameplate',1,true),'readable nameplate token is not a reliable secure target')
                assert(macro:find('/targetexact [nocombat] Waldwolf',1,true))
                assert(not macro:find('/cleartarget',1,true))
                currentGUID='A'; row.scripts.PostClick(row,'LeftButton',false)
                assert(NS.Core.lastClick.selected=='true')
            end
        ''')

    def test_visible_different_names_rotate_without_claiming_instance_selection(self):
        self.lua.execute('''boot()
            plate('Waldwolf','','').guid='A'
            plate('Anderer Wolf','','').guid='B'
            local row=NS.UI.master
            row.entry={name='Waldwolf',names={Waldwolf=true,['Anderer Wolf']=true},
                nameList={'Waldwolf','Anderer Wolf'},refs={}}
            currentGUID='A'
            row.scripts.PreClick(row,'LeftButton',false)
            assert(row.attributes.macrotext1:find('/targetexact [nocombat] Anderer Wolf',1,true))
            currentGUID='B'; row.scripts.PostClick(row,'LeftButton',false)
            assert(NS.Core.lastClick.selected=='true')
            assert(NS.Core.lastClick.name=='Anderer Wolf')
        ''')
