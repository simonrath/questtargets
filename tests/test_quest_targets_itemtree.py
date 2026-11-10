import unittest
import test_quest_targets as addon
import test_quest_targets_proximity as proximity


class ItemTreeTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp
    database = addon.QuestTargetsTests.database

    def test_import_ranks_current_zone_then_spawn_distance_without_a_macro_slot(self):
        proximity.ProximityTests.spatial(self)
        self.lua.execute('''
            C_Map.GetAreaInfo=function(area) return area==215 and 'Local zone' or 'Far zone' end
            function GetRealZoneText() return 'Local zone' end
            boot()
            local frame=CreateFrame('Frame',nil,UIParent)
            local function row(id, name, zone)
                return {kind='row',depth=1,node={kind='npc',id=id,name=name},source={type='Drop',zone=zone}}
            end
            ItemTree={UI={Frame={frame=frame,rootKey='item:2673',View=function() return 'sources' end},
                Tree={pane=frame,rows={row(nil,'AAA outside zone','Far zone'),
                    row(11,'Distant wolf','Local zone'),row(10,'Close wolf','Local zone')}}}}
            NS.ItemTree.Import(NS.app)
            local target=NS.ItemTree.target
            assert(table.concat(target.entry.nameList,'|')=='Waldwolf|Junger Waldwolf|AAA outside zone')
            assert(NS.Proximity.Distance('Waldwolf') < NS.Proximity.Distance('Junger Waldwolf'))
            px=0.7
            NS.Proximity.Sample()
            NS.ItemTree.Sync(NS.app)
            assert(target.entry.nameList[1]=='Junger Waldwolf')
        ''')

    def test_hotkeys_disabled_until_itemtree_is_loaded(self):
        self.lua.execute('''
            local loaded=false
            C_AddOns={IsAddOnLoaded=function(name) return name=='ItemTree' and loaded end}
            boot()
            NS.UI.Settings(NS.app)
            local panel=NS.UI.settings
            assert(panel.itemTreeHotkey.enabled==false and panel.itemTreeHotkey2.enabled==false)
            assert(panel.itemTreeHotkeyAction.textColor[1]==0.5)
            loaded=true
            NS.UI.UpdateSettings(NS.app)
            assert(panel.itemTreeHotkey.enabled and panel.itemTreeHotkey2.enabled)
            assert(panel.itemTreeHotkeyAction.textColor[1]==1)
        ''')

    def test_import_current_mob_drops_and_assign_key(self):
        self.lua.execute('''
            boot()
            local frame=CreateFrame('Frame',nil,UIParent)
            local pane=CreateFrame('Frame',nil,frame)
            local function row(name, source, depth)
                return {kind='row',depth=depth or 1,node={kind='npc',name=name},source={type=source}}
            end
            ItemTree={UI={Frame={frame=frame,rootKey='item:2673',View=function() return 'sources' end},
                Tree={pane=pane,rows={row('Kojote','Drop'),row('Kojote','Drop'),
                    row('Other mob','Drop',2),row('Vendor','Vendor'),row('Kojotenrudelanführer','Drop')}}}}
            local macro
            MAX_ACCOUNT_MACROS=120
            local macroIndex=121
            function GetMacroIndexByName(name) assert(name=='ItemTree Mobs'); return macro and macroIndex or 0 end
            function GetMacroBody() return macro and (macro:gsub('\\n','\\r\\n')..'\\r\\n') end
            function CreateMacro(name, icon, body, character)
                assert(name=='ItemTree Mobs' and character and not combat); macro=body; return 1
            end
            function EditMacro(index, name, icon, body) assert(not combat); macro=body; return 1 end
            NS.ItemTree.Sync(NS.app)
            local button=NS.ItemTree.button
            assert(button:IsShown() and button.parent==frame)
            button.scripts.OnClick()
            assert(macro:find('Kojote',1,true) and macro:find('Kojotenrudelanführer',1,true))
            assert(macro:match('^/stopmacro %[combat,harm,nodead%]'))
            units.target={name='Unrelated wolf'}
            event('PLAYER_TARGET_CHANGED'); flush()
            assert(macro:find('/cleartarget [harm,nodead]',1,true))
            units.target={name='Kojote'}
            event('PLAYER_TARGET_CHANGED'); flush()
            assert(macro:match('^/stopmacro %[harm,nodead%]'))
            combat=true
            units.target={name='Unrelated wolf'}
            event('PLAYER_TARGET_CHANGED'); flush()
            assert(macro:match('^/stopmacro %[harm,nodead%]'))
            combat=false
            units.target=nil
            event('PLAYER_TARGET_CHANGED'); flush()
            assert(macro:match('^/stopmacro %[combat,harm,nodead%]'))
            assert(macro:find('/tm [exists,harm,nodead] !8',1,true))
            NS.app.db.markerIcon=3
            NS.ItemTree.Sync(NS.app)
            assert(macro:find('/tm [exists,harm,nodead] !3',1,true))
            NS.app.db.autoMark=false
            NS.ItemTree.Sync(NS.app)
            assert(not macro:find('/tm ',1,true))
            macro=macro:gsub('^/stopmacro %[combat,harm,nodead%]', '/cleartarget')
            NS.app.db.itemTreeMacroBody=macro
            NS.ItemTree.Sync(NS.app)
            assert(macro:match('^/stopmacro %[combat,harm,nodead%]'))
            assert(not macro:find('Other mob',1,true) and not macro:find('Vendor',1,true))
            assert(#macro<=255 and NS.ItemTree.target.attributes.macro1==nil)
            local rows={}
            for i=1,8 do rows[i]=row('Wolf number '..i,'Drop') end
            ItemTree.UI.Tree.rows=rows
            button.scripts.OnClick()
            local target=NS.ItemTree.target
            assert(#target.entry.nameList==8 and target.attributes.macro1==nil)
            target.scripts.PreClick(target,'LeftButton',false)
            assert(target.attributes.macrotext1:find('Wolf number 1',1,true))
            target.scripts.PostClick(target,'LeftButton',false)
            target.scripts.PreClick(target,'LeftButton',false)
            assert(not target.attributes.macrotext1:find('Wolf number 1',1,true))
            target.scripts.PostClick(target,'LeftButton',false)
            local visited={}
            for _=1,8 do
                target.scripts.PreClick(target,'LeftButton',false)
                for name in target.attributes.macrotext1:gmatch('/targetexact %[noexists%] ([^\\n]+)') do
                    visited[name]=true
                end
                target.scripts.PostClick(target,'LeftButton',false)
            end
            for i=1,8 do assert(visited['Wolf number '..i]) end
            plate('Wolf number 8')
            target.scripts.PreClick(target,'LeftButton',false)
            assert(target.attributes.macrotext1:find('/targetexact [nocombat] Wolf number 8',1,true))
            target.scripts.PostClick(target,'LeftButton',false)
            NS.UI.Settings(NS.app)
            local key=NS.UI.settings.itemTreeHotkey
            key.scripts.OnClick(key)
            key.scripts.OnKeyDown(key,'F9')
            assert(GetBindingAction('F9')=='CLICK QuestTargetsItemTree:LeftButton')
            ItemTree.UI.Tree.rows={row('New mob','Drop')}
            combat=true; button.scripts.OnClick(); combat=false
            assert(not macro:find('New mob',1,true) and #target.entry.nameList==8)
            macro='/cleartarget\\n/targetexact [noexists][dead][help] Kojote\\n/cleartarget [dead][help]'
            NS.app.db.itemTreeMacroBody=nil
            macroIndex=1
            button.scripts.OnClick()
            assert(macro:find('Kojote',1,true))
            assert(target.entry.nameList[1]=='New mob')
            macroIndex=121
            button.scripts.OnClick()
            assert(macro:find('New mob',1,true) and not macro:find('Kojote',1,true))
            local edited=macro..'\\n/say my own text'
            macro=edited
            button.scripts.OnClick()
            NS.ItemTree.Sync(NS.app)
            assert(macro==edited and NS.ItemTree.target.attributes.macro1==nil)
            ItemTree.UI.Frame.View=function() return 'uses' end
            NS.ItemTree.Sync(NS.app)
            assert(not button:IsShown())
        ''')
