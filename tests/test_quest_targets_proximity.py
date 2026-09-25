"""Spatial ranking and fallback regressions against the real Lua modules."""
import unittest
import test_quest_targets as addon


class ProximityTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp
    database = addon.QuestTargetsTests.database

    def spatial(self):
        self.database()
        self.lua.execute('''
            LibQuestieDB.flavor.name='Forever'
            LibQuestieDB.Support={Get=function() return {private={
                areaIdToUiMapId='return {[215]=1412,[99]=999}'}} end}
            px,py,mapID=0.5,0.5,1412
            function CreateVector2D(x,y) return {x=x,y=y} end
            C_Map={GetBestMapForUnit=function() return mapID end,
                GetPlayerMapPosition=function() return {x=px,y=py} end,
                GetWorldPosFromMapPos=function(id,p)
                    return id==999 and 2 or 1,{x=p.x*1000,y=p.y*1000}
                end}
            records.Npc[10].spawns={[215]={{80,50},{51,50}}}
            records.Npc[11].spawns={[215]={{70,50}}}
            records.Npc[12].spawns={[99]={{50,50}}}
            reads=0
            local get=LibQuestieDB.Npc.Get
            LibQuestieDB.Npc.Get=function(id,key)
                if key=='spawns' then reads=reads+1 end
                return get(id,key)
            end
        ''')

    def test_classic_era_keeps_native_spawn_coordinates(self):
        self.spatial()
        self.lua.execute('''
            function GetBuildInfo() return '1.15.9','69722','',11509 end
            LibQuestieDB.flavor.name='Vanilla'
            LibQuestieDB.EraToForever=function() error('Classic must not convert coordinates to Forever') end
            NS.Proximity.Register(LibQuestieDB,10,'Local mob')
            NS.Proximity.Sample()
            assert(NS.Proximity.Distance('Local mob')==100)
        ''')

    def test_nearest_spawn_roles_unknown_and_cache(self):
        self.spatial()
        self.lua.execute('''
            local p=NS.Proximity
            for _,id in ipairs({10,11,12}) do p.Register(LibQuestieDB,id,records.Npc[id].name) end
            p.Sample()
            local e={name='x',names={},nameList={'Unknown','Junger Waldwolf','Waldwolf','Alter Waldwolf'},
                mobCount=3,finisherNames={['Alter Waldwolf']=true}}
            p.Order(e)
            assert(table.concat(e.nameList,'|')=='Waldwolf|Junger Waldwolf|Unknown|Alter Waldwolf')
            assert(p.Distance('Waldwolf')==100) -- nearest of both spawn points, squared yards
            assert(p.Distance('Alter Waldwolf')==nil) -- different continent
            local rev=p.revision
            px=0.505; assert(not p.Sample()); assert(p.revision==rev)
            px=0.7; assert(p.Sample()); p.Order(e)
            assert(e.nameList[1]=='Junger Waldwolf')
            for i=1,20 do p.Order(e); p.Register(LibQuestieDB,10,'Waldwolf') end
            assert(reads==3)
            C_Map.GetPlayerMapPosition=function() return nil end
            assert(p.Sample()); assert(p.Distance('Waldwolf')==nil)
            p.Order(e); assert(#e.nameList==4)
        ''')

    def test_unknown_and_distant_candidates_eventually_in_short_macros(self):
        self.spatial()
        self.lua.execute('''
            NS.Proximity.Register(LibQuestieDB,10,'Waldwolf')
            NS.Proximity.Sample()
            local e={name='x',refs={},names={Waldwolf=true},nameList={'Waldwolf'},mobCount=1,finisherNames={}}
            for i=1,15 do local name='Unbekanntes Questziel '..i
                e.names[name]=true; e.nameList[#e.nameList+1]=name; e.mobCount=e.mobCount+1 end
            local seen,state={},{}
            for i=1,30 do
                local macro=NS.Core.ClickMacro(e,{}, {autoMark=true,markerIcon=8},state)
                assert(#macro<=255)
                if i==1 then assert(macro:find('Waldwolf',1,true)) end
                for _,name in ipairs(e.nameList) do if macro:find(name..'\\n',1,true) then seen[name]=true end end
            end
            for _,name in ipairs(e.nameList) do assert(seen[name],name) end
        ''')

    def test_visible_target_beats_spawn_estimate_and_mob_beats_finisher(self):
        self.spatial()
        self.lua.execute('''
            NS.Proximity.Register(LibQuestieDB,10,'Waldwolf'); NS.Proximity.Sample()
            local e={name='Waldwolf',refs={},names={Waldwolf=true,NPC=true},nameList={'NPC','Waldwolf'},
                mobCount=1,finisherNames={NPC=true}}
            local unit=plate('NPC','Quest',''); unit.friendly=true
            local macro=NS.Core.ClickMacro(e,{}, {},{})
            assert(macro:find('/targetexact [nocombat] NPC',1,true))
            nameplates={}; units={}; currentGUID=nil
            macro=NS.Core.ClickMacro(e,{}, {},{})
            assert(macro:find('Waldwolf',1,true)<macro:find('NPC',1,true))
        ''')

    def test_forever_conversion_not_applied_twice_and_missing_mapping_safe(self):
        self.spatial()
        self.lua.execute('''
            local p=NS.Proximity
            LibQuestieDB.EraToForever=function() error('Forever data already converted') end
            p.Register(LibQuestieDB,10,'Waldwolf'); p.Sample()
            assert(p.Distance('Waldwolf')==100)
            LibQuestieDB.flavor={name='Vanilla'}
            LibQuestieDB.EraToForever=nil
            p.Register(LibQuestieDB,10,'Waldwolf'); p.Sample()
            assert(p.Distance('Waldwolf')==nil) -- old Mulgore frame cannot be trusted
            LibQuestieDB.Support=nil
            LibQuestieDB.flavor={name='Forever'}
            p.Register(LibQuestieDB,10,'Waldwolf'); p.Sample()
            assert(p.Distance('Waldwolf')==nil)
        ''')

    def test_long_names_do_not_starve_either_role(self):
        self.lua.execute('''
            local mob=string.rep('M',140)
            local npc=string.rep('N',140)
            local e={name=mob,refs={},names={[mob]=true,[npc]=true},nameList={mob,npc},
                mobCount=1,finisherNames={[npc]=true}}
            local state,seen={},{}
            for i=1,6 do
                local macro=NS.Core.ClickMacro(e,{}, {autoMark=true,markerIcon=8},state)
                assert(#macro<=255)
                if i==1 then assert(macro:find(mob,1,true)) end
                if macro:find(mob,1,true) then seen.mob=true end
                if macro:find(npc,1,true) then seen.npc=true end
            end
            assert(seen.mob and seen.npc)
        ''')

    def test_vanilla_converter_percentages_same_name_ids_and_sentinels(self):
        self.spatial()
        self.lua.execute('''
            local p=NS.Proximity
            LibQuestieDB.flavor.name='Vanilla'
            conversions=0
            LibQuestieDB.EraToForever=function(area,x,y)
                assert(area==215 and x>=0 and x<=100)
                conversions=conversions+1; return x+10,y
            end
            records.Npc[10].spawns={[215]={{-1,-1},{30,50},{50,50}}}
            records.Npc[11].spawns={[215]={{41,50}}}
            p.Register(LibQuestieDB,10,'Shared'); p.Register(LibQuestieDB,11,'Shared'); p.Sample()
            assert(math.abs(p.Distance('Shared')-100)<0.001)
            assert(conversions==3)
            for i=1,20 do p.Distance('Shared') end
            assert(conversions==3 and reads==2)
            px=0.6; p.Sample(); p.Distance('Shared')
            assert(conversions==3 and reads==2) -- no new projection or database reads
        ''')

    def test_resolver_registers_mobs_and_finishers_and_poll_updates_ranking(self):
        self.spatial()
        self.lua.execute('''
            assert(NS.Database.Provider()==LibQuestieDB)
            quests[3]={questID=3,title='Abgabe',complete=true,objectives={}}
            records.Quest[3]={name='Abgabe',finishedBy={{12}}}
            boot()
            assert(NS.Proximity.Distance('Waldwolf')==100)
            local e=NS.UI.master.entry
            assert(e.nameList[1]=='Waldwolf')
            px=0.7; tick()
            assert(NS.UI.master.entry.nameList[1]=='Junger Waldwolf')
        ''')
