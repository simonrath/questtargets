import unittest

import test_quest_targets as addon


class TutorialTests(unittest.TestCase):
    setUp = addon.QuestTargetsTests.setUp

    def test_empty_log_practice_uses_secure_self_target_and_restores_list(self):
        self.lua.execute("""
            quests = {}
            boot()
            local intro = QuestTargetsTutorial
            assert(intro and intro:IsShown())
            assert(intro.title:IsShown() and intro.title:GetText() == 'Next! Intro')
            assert(intro.bubble:GetWidth() == 414 and intro.bubble:GetHeight() == 244)
            local mascotAnchor = intro.mrrml.point
            assert(mascotAnchor[2] == intro.bubble and mascotAnchor[3] == 'BOTTOMLEFT')
            assert(intro.primary.point[2] == intro.bubble and intro.secondary.point[2] == intro.bubble)
            intro.primary.scripts.OnClick()
            assert(not intro.title:IsShown())
            intro.primary.scripts.OnClick()
            assert(intro.pointer:IsShown() and NS.UI.master:IsShown())
            intro.pointer.scripts.OnUpdate(intro.pointer, 0.1)
            local firstX = intro.pointer.point[4]
            NS.UI.master.centerX = 1000
            intro.pointer.scripts.OnUpdate(intro.pointer, 0.1)
            assert(intro.pointer.point[4] > firstX)
            intro.secondary.scripts.OnClick()
            local row = NS.UI.rows[1]
            assert(intro.pointer:IsShown() and intro.pointer.target == row.icon)
            assert(intro.mrrml.point == mascotAnchor and intro.bubble:GetWidth() == 414)
            assert(intro.secondary.point[2] == intro.bubble and intro.secondary.point[4] == 0)
            assert(NS.UI.frame:IsShown() and NS.app.db.hidden)
            assert(row.entry.tutorial and row:IsShown() and row.focusMark:IsShown())
            assert(row:GetAttribute('type1') == 'target' and row:GetAttribute('unit') == 'player')
            assert(#NS.app.quests == 0 and #NS.app.entries == 0)
            local selfTargeted = false
            UnitIsUnit = function(a, b) return selfTargeted and a == 'target' and b == 'player' end
            row.scripts.PostClick(row, 'LeftButton', false)
            assert(row.entry and row.entry.tutorial)
            selfTargeted = true
            row.scripts.PostClick(row, 'LeftButton', false)
            assert(intro.text:GetText() == NS.L('tutorialCelebrate'))
            assert(not intro.pointer:IsShown() and intro.pointer.target == nil)
            assert(NS.UI.frame:IsShown() and NS.app.db.hidden and row:GetAttribute('type1') == 'macro')
            assert(row:GetAttribute('unit') == nil and not row.entry)
            intro.primary.scripts.OnClick()
            assert(intro:IsShown() and intro.text:GetText() == NS.L('tutorialFarewell'))
            assert(intro.primary:GetText() == 'Next!' and not intro.secondary:IsShown() and not intro.close:IsShown())
            assert(NS.UI.frame:IsShown() and not NS.app.db.hidden)
            intro.primary.scripts.OnClick()
            assert(not intro:IsShown() and QuestTargetsNewsDB.onboarding == 'done')
            assert(NS.UI.frame:IsShown() and not NS.app.db.hidden)
        """)

    def test_existing_player_can_replay_and_bind_before_hiding_master(self):
        self.lua.execute("""
            QuestTargetsDB = {masterHidden=false}
            ItemTree = {UI={}}
            boot()
            assert(not QuestTargetsTutorial)
            NS.UI.Settings(NS.app)
            local settings = NS.UI.settings
            assert(settings.introButton.parent == settings.pages[1].content)
            assert(settings.introButton.point[3] < settings.patchNotesButton.point[3])
            settings.introButton.scripts.OnClick()
            local intro = QuestTargetsTutorial
            assert(intro:IsShown() and not settings:IsShown())
            intro.primary.scripts.OnClick()
            intro.secondary.scripts.OnClick()
            assert(not NS.app.db.masterHidden and not intro.primary.enabled)
            assert(intro.keyGlow:IsShown() and intro.keyGlow.borderColor[4] < 1)
            intro.key.scripts.OnClick(intro.key)
            assert(intro.keyGlow.borderColor[4] == 1)
            intro.key.scripts.OnKeyDown(intro.key, 'G')
            assert(intro.primary.enabled and GetBindingKey('CLICK QuestTargetsMaster:LeftButton') == 'G')
            intro.primary.scripts.OnClick()
            assert(NS.app.db.masterHidden and NS.UI.rows[1].entry.tutorial)
            assert(NS.app.db.hotkeysOnly and NS.UI.master.barWidth == 0)
            assert(NS.UI.master:IsShown() and NS.UI.master:GetAlpha() == 0)
            assert(NS.ItemTree.target:IsShown() and NS.ItemTree.target:GetAlpha() == 0)
            assert(NS.app.db.itemTreeButton ~= false)
            assert(not intro.keyGlow:IsShown())
            combat = true
            event('PLAYER_REGEN_DISABLED')
            assert(not intro:IsShown())
            combat = false
            event('PLAYER_REGEN_ENABLED')
            assert(intro:IsShown() and NS.UI.rows[1].entry.tutorial)
            UnitIsUnit = function(a, b) return a == 'target' and b == 'player' end
            local row = NS.UI.rows[1]
            row.scripts.PostClick(row, 'LeftButton', false)
            assert(NS.UI.frame:IsShown() and (not row.entry or not row.entry.tutorial))
            intro.secondary.scripts.OnClick()
            assert(NS.app.db.hidden and not NS.UI.frame:IsShown())
            assert(intro:IsShown() and intro.text:GetText() == NS.L('tutorialFarewell'))
            intro.primary.scripts.OnClick()
            assert(not intro:IsShown())
            assert(NS.UI.master.entry.names.Waldwolf)
            NS.UI.Settings(NS.app)
            NS.UI.settings.masterToggle.scripts.OnClick()
            flush()
            assert(not NS.app.db.hotkeysOnly and NS.UI.master:GetAlpha() == 1)
            assert(NS.ItemTree.target.inBar)
        """)
