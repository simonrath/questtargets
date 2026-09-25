"""Language and optional-provider startup behavior in the Lua addon."""
import unittest
import test_quest_targets as addon


class CommandsPopupTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_new_install_defaults_to_english_but_saved_language_wins(self):
        self.lua.execute('''
            assert(NS.Language()==1)
            boot()
            assert(NS.Language()==1 and NS.L('settings')=='Settings')
            assert(NS.app.db.masterText=='Target quest objective')
            NS.app.db.language='deDE'
            assert(NS.Language()==2 and NS.L('settings')=='Einstellungen')
        ''')

    def test_localized_commands_and_english_aliases(self):
        self.lua.execute('''boot()
            local examples={
                {'enUS','settings','refresh','help'},
                {'deDE','einstellungen','aktualisieren','hilfe'},
                {'esES','configuración','actualizar','ayuda'},
                {'frFR','paramètres','actualiser','aide'},
                {'trTR','ayarlar','yenile','yardım'},
                {'zhCN','设置','刷新','帮助'},
            }
            for _,row in ipairs(examples) do
                NS.app.db.language=row[1]
                assert(NS.Command(row[2])=='settings')
                assert(NS.Command(row[3])=='refresh')
                assert(NS.Command(row[4])=='help')
                SlashCmdList.QUESTTARGETS(row[3])
                assert(NS.app.error==nil)
                SlashCmdList.QUESTTARGETS('settings')
                assert(openCategory==42)
            end
            NS.app.db.language='esES'
            SlashCmdList.QUESTTARGETS('diagnóstico')
            assert(messages[#messages]:find('Resultado tras el clic',1,true))
        ''')

    def test_missing_provider_popup_copyable_link_only_once_at_login(self):
        self.lua.execute('''
            popupCalls={}
            StaticPopupDialogs={}
            StaticPopup_Show=function(key)
                popupCalls[#popupCalls+1]=key
                local box={SetText=function(self,v) self.text=v end,
                    HighlightText=function(self) self.highlighted=true end,
                    SetFocus=function(self) self.focused=true end}
                StaticPopupDialogs[key].OnShow({GetEditBox=function() return box end})
                popupEdit=box
            end
            boot()
            assert(#popupCalls==1)
            local key=popupCalls[1]
            assert(StaticPopupDialogs[key].hasEditBox)
            assert(popupEdit.text=='https://github.com/Questie/QuestieDB/releases/')
            assert(popupEdit.highlighted and popupEdit.focused)
            event('PLAYER_ENTERING_WORLD'); flush()
            assert(#popupCalls==1)
        ''')

    def test_loaded_provider_never_shows_missing_popup(self):
        self.lua.execute('''
            popupCalls=0
            StaticPopupDialogs={}
            StaticPopup_Show=function() popupCalls=popupCalls+1 end
            LibQuestieDB={}
            boot()
            assert(popupCalls==0)
        ''')

    def test_forever_popup_and_select_button_keep_url_available(self):
        self.lua.execute('''
            function GetBuildInfo() return '1.60.1','69913','',160001 end
            function CopyToClipboard() error('restricted API must not be called') end
            StaticPopupDialogs={}
            StaticPopup_Show=function(key) popup=StaticPopupDialogs[key] end
            boot()
            assert(popup.text:find('QuestieDB Forever',1,true))
            assert(popup.text:find('QuestieDB-Forever.zip',1,true))
            assert(popup.button1=='Select URL' and popup.button2=='OK')
            local box={SetText=function(self,v) self.text=v end,
                HighlightText=function(self) self.highlighted=true end,
                SetFocus=function(self) self.focused=true end}
            assert(popup.OnAccept({EditBox=box})==true)
            assert(box.text=='https://github.com/Questie/QuestieDB/releases/')
            assert(box.highlighted and box.focused)
            for _,language in ipairs({'deDE','esES','frFR','trTR','zhCN'}) do
                NS.app.db.language=language
                assert(NS.L('dbInstallForeverText'):find('QuestieDB-Forever.zip',1,true))
            end
        ''')
