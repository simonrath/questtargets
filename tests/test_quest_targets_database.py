"""Integration against the SHA256-pinned, real QuestieDB v1.0.1 Vanilla release.

Run tools/package_quest_targets.ps1 first to populate its download cache.
Requires the test-only cbor2 package as well as lupa.
"""
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
RELEASE = Path(tempfile.gettempdir()) / 'quest-targets-questiedb-v1.0.1/QuestieDB-Vanilla.zip'


@unittest.skipUnless(RELEASE.is_file(), 'Pinned QuestieDB release not downloaded')
class RealQuestieDBTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from questiedb_harness import load_release
        cls.lua = load_release(RELEASE)
        cls.lua.execute('''NS={}
            function UnitName() error('Database lookup must not require a selected mob') end
        ''')
        for name in ('Core.lua', 'Locale.lua', 'Database.lua', 'Proximity.lua', 'Resolvers.lua'):
            cls.lua.execute('assert(loadstring(...))("QuestTargets",NS)',
                            (ROOT / 'QuestTargets' / name).read_bytes())

    def test_real_german_wolf_meat_all_four_sources_before_encounter(self):
        self.lua.execute('''
            local q={id=33,title='Wölfe an der Grenze',typeCounts={item=1},objectives={
                {index=1,type='item',text='Zähes Wolfsfleisch: 0/8',done=0,total=8}}}
            local entries, meta=NS.Core.BuildEntries({q},{})
            assert(meta.unresolved==0 and #entries==4)
            local names={}
            for _, entry in ipairs(entries) do
                assert(entry.refs[1].database and entry.done==0 and entry.total==8)
                names[entry.name]=true
            end
            for _, npcID in ipairs({69,299,704,705}) do assert(names[NpcDB.name(npcID)]) end
        ''')

    def test_real_gold_dust_and_candles_share_four_npc_buttons(self):
        self.lua.execute('''
            local a={id=47,title='Tauschhandel mit Goldstaub',typeCounts={item=1},objectives={
                {index=1,type='item',text='Goldstaub: 2/10',done=2,total=10}}}
            local b={id=60,title='Koboldkerzen',typeCounts={item=1},objectives={
                {index=1,type='item',text='Große Kerze: 1/8',done=1,total=8}}}
            local entries=NS.Core.BuildEntries({a,b},{})
            assert(#entries==4)
            for _, entry in ipairs(entries) do assert(#entry.refs==2 and entry.done==3 and entry.total==18) end
            b.objectives={}
            entries=NS.Core.BuildEntries({a,b},{})
            assert(#entries==4)
            for _, entry in ipairs(entries) do assert(#entry.refs==1 and entry.done==2 and entry.total==10) end
        ''')

    def test_real_kill_quest_uses_localized_npc_name(self):
        self.lua.execute('''
            local q={id=7,title='Säuberung im Koboldlager',typeCounts={monster=1},objectives={
                {index=1,type='monster',text='Koboldgezücht getötet: 0/10',done=0,total=10}}}
            local entries=NS.Core.BuildEntries({q},{})
            assert(#entries==1 and entries[1].name=='Koboldgezücht')
            assert(entries[1].refs[1].database)
        ''')

    def test_real_ready_quest_uses_recorded_npc_turnin_only(self):
        self.lua.execute('''
            local q={id=7,title='Säuberung im Koboldlager',ready=true,objectives={}}
            local names=NS.Database.ResolveTurnIns(q)
            assert(names['Marshal McBride'] == true)
            assert(NS.Database.ResolveTurnIns({id=7,title=q.title,ready=false})['Marshal McBride'] == nil)
            assert(next(NS.Database.ResolveTurnIns({id=7,title='Andere Quest',ready=true})) == nil)
        ''')

    def test_real_database_and_forever_observation_form_union(self):
        self.lua.execute('''
            local q={id=33,title='Wölfe an der Grenze',typeCounts={item=1},objectives={
                {index=1,type='item',text='Zähes Wolfsfleisch: 0/8',done=0,total=8}}}
            local learned={['33:1']={signature='item:Zähes Wolfsfleisch',names={['Neuer Forever-Wolf']=true}}}
            local entries=NS.Core.BuildEntries({q},learned)
            assert(#entries==5)
        ''')

    def test_real_dwarven_digging_resolves_conversion_source_mobs(self):
        self.lua.execute('''
            local q={id=746,title='Zwergen-Buddelei',typeCounts={item=1},objectives={
                {index=1,type='item',text='Zerbrochene Werkzeuge: 0/5',done=0,total=5}}}
            assert(next(NS.Database.Resolve(q)[1]) == nil)
            local names=NS.Resolvers.Resolve(q)[1]
            assert(names["Buddler von Bael'dun"] and names["Gutachter von Bael'dun"])
            local entries, meta=NS.Core.BuildEntries({q},{})
            assert(meta.unresolved == 0 and #entries == 2)
            local quests=NS.Core.QuestEntries(entries)
            assert(#quests == 1 and #quests[1].nameList == 2)
            assert(quests[1].total == 5 and quests[1].done == 0)
            assert(next(NS.Resolvers.Resolve({id=746,title='Andere Quest',objectives=q.objectives})) == nil)
            q.objectives={}
            assert(next(NS.Resolvers.Resolve(q)) == nil)
        ''')


if __name__ == '__main__':
    unittest.main()
