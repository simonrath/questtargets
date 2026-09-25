"""Successful name searches must not leave their next-page cursor active."""
import unittest
import test_quest_targets as addon


class ReacquireTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def prepare(self):
        self.lua.execute('''
            boot()
            function searchEntry()
                local e={name='Questgegner Nummer 1',refs={},names={},nameList={}}
                for i=1,6 do local n='Questgegner Nummer '..i
                    e.names[n]=true; e.nameList[i]=n end
                return e
            end
            -- Only this distant mob is available: no nameplate token.
            units.distant={name='Questgegner Nummer 1',guid='distant'}
            function clickSearch(button, delayed)
                button.scripts.PreClick(button,'LeftButton',false)
                local macro=button.attributes.macrotext1
                local hit=macro:find('/targetexact [noexists] '..units.distant.name..'\\n',1,true)
                    or (macro..'\\n'):find('/targetexact '..units.distant.name..'\\n',1,true)
                -- Model just the known /targetexact result, not WoW's secure engine.
                if not delayed then currentGUID=hit and 'distant' or nil end
                button.scripts.PostClick(button,'LeftButton',false)
                return hit,macro
            end
        ''')

    def test_success_deselect_reacquire_first_click_on_both_buttons(self):
        self.prepare()
        self.lua.execute('''
            for _,button in ipairs({NS.UI.master,NS.UI.rows[1]}) do
                button.entry=searchEntry(); currentGUID=nil
                assert(clickSearch(button)) -- first click after reload
                for i=1,5 do
                    currentGUID=nil; event('PLAYER_TARGET_CHANGED')
                    assert(clickSearch(button),'successful batch was skipped after deselection')
                end
            end
        ''')

    def test_delayed_target_event_confirms_search_without_quest_refresh(self):
        self.prepare()
        self.lua.execute('''
            local button=NS.UI.master
            button.entry=searchEntry(); currentGUID=nil
            assert(clickSearch(button,true))
            assert(button.fallbackIndex>1)
            local entry=button.entry
            currentGUID='distant'; event('PLAYER_TARGET_CHANGED')
            assert(button.entry==entry)
            currentGUID=nil; event('PLAYER_TARGET_CHANGED')
            assert(clickSearch(button))
        ''')

    def test_failed_searches_still_rotate_and_later_success_is_reused(self):
        self.prepare()
        self.lua.execute('''
            local button=NS.UI.master
            button.entry=searchEntry(); currentGUID=nil
            units.distant.name='Questgegner Nummer 5'
            assert(not clickSearch(button)); event('PLAYER_TARGET_CHANGED')
            assert(not clickSearch(button)); event('PLAYER_TARGET_CHANGED')
            assert(clickSearch(button))
            currentGUID=nil; event('PLAYER_TARGET_CHANGED')
            assert(clickSearch(button),'later successful batch must be reused too')
            -- If it goes away, move on instead of sticking to its old batch.
            units.distant.name='Questgegner Nummer 1'; currentGUID=nil
            assert(not clickSearch(button))
            assert(clickSearch(button))
        ''')

    def test_dead_players_and_unattempted_names_do_not_confirm_success(self):
        self.prepare()
        self.lua.execute('''
            local button=NS.UI.master
            for _,bad in ipairs({
                {name='Questgegner Nummer 1',dead=true},
                {name='Questgegner Nummer 1',player=true},
                {name='Questgegner Nummer 5'},
            }) do
                button.entry=searchEntry(); button.fallbackIndex=nil; currentGUID=nil
                assert(clickSearch(button,true))
                units.other=bad; currentGUID='other'; event('PLAYER_TARGET_CHANGED')
                currentGUID=nil
                assert(not clickSearch(button))
            end
        ''')

    def test_long_ready_npc_success_preserves_both_cursors(self):
        self.prepare()
        self.lua.execute('''
            local button=NS.UI.master
            local mob,npc=string.rep('M',140),string.rep('N',140)
            button.entry={name=mob,refs={},names={[mob]=true,[npc]=true},
                nameList={mob,npc},mobCount=1,finisherNames={[npc]=true}}
            units.distant.name=npc; units.distant.friendly=true; currentGUID=nil
            assert(not clickSearch(button)) -- long mob and NPC need separate attempts
            assert(clickSearch(button))
            currentGUID=nil; event('PLAYER_TARGET_CHANGED')
            assert(clickSearch(button))
        ''')
