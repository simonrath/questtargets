"""Master positioning transactions; native mouse dispatch still needs WoW."""
import unittest
import test_quest_targets as addon


class MasterMoveTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def prepare(self):
        self.lua.execute('''
            cursorCalls={}
            SetCursor=function(value) cursor=value; cursorCalls[#cursorCalls+1]=value or 'default' end
            UISpecialFrames={}
            boot()
        ''')

    def test_preview_accept_cancel_reset_and_old_right_drag(self):
        self.prepare()
        self.lua.execute('''
            local ui,app=NS.UI,NS.app
            assert(type(ui.BeginMasterMove)=='function', 'move mode missing')
            assert(ui.BeginMasterMove(app))
            local edit=ui.masterMove
            assert(edit.shown and edit.parent==UIParent and not edit.protected)
            assert(edit.grip.height>=28 and edit.grip.width>=28)
            assert(edit.grip.attributes.type1==nil and not edit.grip.secure)
            local macro=ui.master.attributes.macrotext1
            local count=#frames
            assert(ui.BeginMasterMove(app) and #frames==count)
            edit.grip.scripts.OnEnter(edit.grip); assert(cursor=='UI_MOVE_CURSOR')
            edit.grip.scripts.OnDragStart(edit.grip)
            edit.centerX=1100; edit.centerY=650
            edit.grip.scripts.OnLeave(edit.grip); assert(cursor=='UI_MOVE_CURSOR')
            edit.scripts.OnUpdate(edit,0.1)
            assert(ui.master.point[4]==200 and ui.master.point[5]==150)
            assert(app.db.masterPosition==nil, 'preview saved too early')
            edit.grip.scripts.OnDragStop(edit.grip); assert(cursor==nil)
            app:Refresh(); assert(edit.shown and ui.master.point[4]==200)
            edit.done.scripts.OnClick()
            assert(not edit.shown and app.db.masterPosition.x==200 and app.db.masterPosition.y==150)
            assert(ui.master.attributes.type1=='macro' and ui.master.attributes.macrotext1==macro)
            assert(ui.BeginMasterMove(app))
            edit.reset.scripts.OnClick()
            assert(ui.master.point[4]==0 and ui.master.point[5]==-180)
            assert(app.db.masterPosition.x==200)
            edit.cancel.scripts.OnClick()
            assert(ui.master.point[4]==200 and app.db.masterPosition.x==200)
            assert(ui.BeginMasterMove(app))
            edit.reset.scripts.OnClick(); edit.done.scripts.OnClick()
            assert(app.db.masterPosition.x==0 and app.db.masterPosition.y==-180)
            ui.master.scripts.OnDragStart(ui.master); assert(ui.master.moving)
            ui.master.centerX=950; ui.master.centerY=530
            ui.master.scripts.OnDragStop(ui.master)
            assert(not ui.master.moving and app.db.masterPosition.x==50 and app.db.masterPosition.y==30)
        ''')

    def test_combat_cancels_drag_safely_and_keeps_last_released_preview(self):
        self.prepare()
        self.lua.execute('''
            local ui,app=NS.UI,NS.app
            assert(type(ui.BeginMasterMove)=='function', 'move mode missing')
            ui.BeginMasterMove(app)
            local edit=ui.masterMove
            edit.grip.scripts.OnDragStart(edit.grip)
            edit.centerX=1000; edit.centerY=540
            edit.grip.scripts.OnDragStop(edit.grip)
            edit.grip.scripts.OnDragStart(edit.grip)
            edit.centerX=1200; edit.centerY=700
            edit.scripts.OnUpdate(edit,0.1)
            combat=true; event('PLAYER_REGEN_DISABLED')
            assert(not edit.shown and not edit.dragging and cursor==nil)
            assert(not ui.masterMoveActive and app.db.masterPosition==nil)
            edit.grip.scripts.OnDragStop(edit.grip)
            combat=false; event('PLAYER_REGEN_ENABLED')
            assert(not edit.shown and not ui.masterMoveActive)
            assert(app.db.masterPosition.x==100 and app.db.masterPosition.y==40)
            assert(ui.master.point[4]==100 and ui.master.point[5]==40)
            combat=true
            assert(not ui.BeginMasterMove(app))
            assert(messages[#messages]==NS.L('masterMoveCombat'))
        ''')

    def test_hidden_master_escape_and_cursor_lifetime(self):
        self.prepare()
        self.lua.execute('''
            local ui,app=NS.UI,NS.app
            assert(type(ui.BeginMasterMove)=='function', 'move mode missing')
            app.db.masterHidden=true; app:Refresh()
            assert(not ui.BeginMasterMove(app))
            assert(messages[#messages]==NS.L('masterMoveHidden') and app.db.masterHidden)
            app.db.masterHidden=false; app:Refresh()
            ui.BeginMasterMove(app)
            local edit=ui.masterMove
            assert(UISpecialFrames[1]=='QuestTargetsMasterMove')
            edit.grip.scripts.OnEnter(edit.grip)
            edit.grip.scripts.OnLeave(edit.grip); assert(cursor==nil)
            edit.grip.scripts.OnEnter(edit.grip)
            edit:Hide(); edit.scripts.OnHide(edit)
            assert(not ui.masterMoveActive and cursor==nil and app.db.masterPosition==nil)
            ui.BeginMasterMove(app)
            app.db.masterHidden=true; app:Refresh()
            assert(not ui.masterMoveActive and not edit.shown and cursor==nil)
        ''')

    def test_all_flavors_and_styles_keep_right_drag_in_edit_mode(self):
        for interface in (120100,11509,20506,50504,16001):
            for style in ('classic','modern'):
                with self.subTest(interface=interface,style=style):
                    self.setUp()
                    self.lua.execute(f"GetBuildInfo=function() return '', '', '', {interface} end; QuestTargetsDB={{masterAppearance='{style}',masterScaleBaseline=2,masterScaleX=0.3,masterScaleY=0.3,masterModernScale=0.3}}")
                    self.prepare()
                    self.lua.execute('''
                        assert(type(NS.UI.BeginMasterMove)=='function', 'move mode missing')
                        NS.UI.BeginMasterMove(NS.app)
                        local master,edit=NS.UI.master,NS.UI.masterMove
                        master.scripts.OnDragStart(master)
                        assert(edit.dragging and not master.moving)
                        edit.centerX=1050; edit.centerY=620
                        master.scripts.OnDragStop(master)
                        assert(not edit.dragging and NS.app.db.masterPosition==nil)
                        edit.done.scripts.OnClick()
                        assert(NS.app.db.masterPosition.x==150 and NS.app.db.masterPosition.y==120)
                        assert(master.attributes.type1=='macro' and master.attributes.macrotext1)
                    ''')

    def test_fallback_options_start_mode_and_translate_visible_help(self):
        self.prepare()
        self.lua.execute('''
            NS.UI.Settings(NS.app)
            local panel=NS.UI.masterSettings
            assert(panel.moveButton, 'move option missing')
            assert(panel.moveHelp.text==NS.L('masterMoveHelp'))
            assert(not NS.app.db.showTooltips)
            panel.moveButton.scripts.OnClick()
            assert(NS.UI.masterMoveActive and not NS.UI.settings.shown)
            for _,language in ipairs({'enUS','deDE','esES','frFR','trTR','zhCN'}) do
                NS.app.db.language=language; NS.UI.ApplyLanguage(NS.app)
                assert(panel.moveButton.text==NS.L('masterMove'))
                assert(panel.moveHelp.text==NS.L('masterMoveHelp'))
                assert(NS.UI.masterMove.grip.text==NS.L('masterMoveDrag'))
                for _,key in ipairs({'masterMove','masterMoveStart','masterMoveHelp',
                    'masterMoveDrag','masterMoveDone','masterMoveCancel','masterMoveReset',
                    'masterMoveCombat','masterMoveHidden'}) do
                    assert(NS.L(key)~=key, 'missing translation: '..key)
                end
            end
        ''')

    def test_delayed_right_drag_stop_after_combat_does_not_stop_next_drag(self):
        self.prepare()
        self.lua.execute('''
            local ui,app=NS.UI,NS.app
            ui.BeginMasterMove(app)
            ui.master.scripts.OnDragStart(ui.master)
            combat=true; event('PLAYER_REGEN_DISABLED')
            ui.master.scripts.OnDragStop(ui.master)
            combat=false; event('PLAYER_REGEN_ENABLED')
            ui.master.scripts.OnDragStart(ui.master)
            app:Refresh()
            assert(ui.master.moving, 'stale drag stop interrupted next right drag')
        ''')

    def test_position_options_fit_fallback_scroll_area_for_both_styles(self):
        self.prepare()
        self.lua.execute('''
            NS.UI.Settings(NS.app)
            local panel=NS.UI.masterSettings
            for _,style in ipairs({'classic','modern'}) do
                NS.app.db.masterAppearance=style
                NS.UI.UpdateMasterSettings(NS.app)
                local group=panel.moveButton.parent
                assert(panel.height>=math.abs(group.point[#group.point])+group.height,
                    'move options outside scroll area: '..style)
            end
        ''')

    def test_native_move_row_separates_title_help_and_action(self):
        self.prepare()
        self.lua.execute('''
            SettingsListElementMixin={OnLoad=function() end,
                Init=function(self,item)
                    self.data=item.data
                    self.Text:SetPoint('LEFT',self,'LEFT',37,0)
                    self.Text:SetPoint('RIGHT',self,'CENTER',-85,0)
                end, Release=function(self) self.data=nil end}
            local row=CreateFrame('Frame',nil,UIParent)
            row.Text=row:CreateFontString()
            for k,v in pairs(QuestTargetsMoveSettingMixin) do row[k]=v end
            row:OnLoad()
            local calls=0
            local item={data={name=NS.L('masterMove'),help=NS.L('masterMoveHelp'),
                buttonText=NS.L('masterMoveStart'),callback=function() calls=calls+1 end}}
            row:Init(item)
            assert(row.Text.point[1]=='TOPRIGHT', 'native title overlaps help text')
            assert(row.Text.point[2]==row.MoveButton)
            assert(row.Help.text==item.data.help and row.MoveButton.text==item.data.buttonText)
            row.MoveButton.scripts.OnClick(); assert(calls==1)
            row:Release(); row.MoveButton.scripts.OnClick(); assert(calls==1)
        ''')

    def test_clamped_editor_preview_stays_aligned_and_cancel_restores_edge_position(self):
        self.prepare()
        self.lua.execute('''
            NS.app.db.masterPosition={x=940,y=0}
            NS.UI.master:ClearAllPoints()
            NS.UI.master:SetPoint('CENTER',UIParent,'CENTER',940,0)
            UIParent.GetCenter=function() return 960,540 end
            local make=CreateFrame
            function CreateFrame(kind,name,parent,template)
                local f=make(kind,name,parent,template)
                if name=='QuestTargetsMasterMove' then
                    f.GetCenter=function(self)
                        local x=960+self.point[4]
                        local y=540+self.point[5]
                        return math.max(self.width/2,math.min(1920-self.width/2,x)),
                            math.max(self.height/2,math.min(1080-self.height/2,y))
                    end
                end
                return f
            end
            NS.UI.BeginMasterMove(NS.app)
            local x,y=NS.UI.masterMove:GetCenter()
            assert(NS.UI.master.point[4]==x-960 and NS.UI.master.point[5]==y-540,
                'clamped editor detached from master')
            assert(NS.app.db.masterPosition.x==940, 'clamping committed preview')
            NS.UI.EndMasterMove(NS.app,false)
            assert(NS.UI.master.point[4]==940 and NS.app.db.masterPosition.x==940)
        ''')

    def test_repeated_start_closes_reopened_options_without_losing_preview(self):
        self.prepare()
        self.lua.execute('''
            NS.UI.Settings(NS.app)
            NS.UI.BeginMasterMove(NS.app)
            local edit=NS.UI.masterMove
            local before=edit.released
            NS.UI.settings:Show()
            assert(NS.UI.BeginMasterMove(NS.app))
            assert(not NS.UI.settings.shown, 'repeated Start left options in the way')
            assert(edit.released==before)
        ''')

    def test_malformed_saved_position_uses_the_existing_default(self):
        self.prepare()
        self.lua.execute('''
            NS.app.db.masterPosition={x='invalid'}
            NS.UI.BeginMasterMove(NS.app)
            assert(NS.UI.masterMove.original.x==0 and NS.UI.masterMove.original.y==-180,
                'invalid saved coordinates copied into editor')
        ''')


if __name__ == '__main__':
    unittest.main()
