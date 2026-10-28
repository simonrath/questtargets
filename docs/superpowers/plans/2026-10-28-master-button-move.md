# Masterbutton Move Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Supplement right dragging with a discoverable positioning mode.
**Architecture:** Movement transactions and an independent UIParent editor in Master.lua; options in UI.lua; combat integration in Main.lua. Preserve secure click scripts/attributes.
**Tech Stack:** Lua 5.1, Python/lupa unittest.
**Spec:** ../specs/2026-10-28-master-button-move-design.md

## Global Constraints

- Use existing isolated cloud checkout and work branch; no extra worktree or publication.
- Native UI_MOVE_CURSOR; minimum 28-unit grip; six languages; five flavors and two styles.
- No protected frame mutations during combat; editor parents and anchors only to UIParent.
- Existing right dragging and targeting remain available.

## Review Focus

- Combat during a drag: no retained cursor or protected writes; deferred position cleanup.
- Refresh/hide/style changes: no resurrected editing or corrupt saved positions.
- Repeated entry/Escape/reload: no duplicate controls or premature persistence.
- Small buttons/screen edges: reachable grip and completion controls.
- Both native and fallback options: discoverable entry without tooltips.

### Task 1: Movement transaction and cursor

**Files:** QuestTargets/Master.lua, QuestTargets/Main.lua, tests/test_quest_targets_master_move.py, tests/quest_targets_mock.lua.
**Interfaces:** UI.BeginMasterMove(app) -> boolean; UI.EndMasterMove(app, accept); UI.ResetMasterMove(app); UI.UpdateMasterMove(app); existing UI.StopMaster(app).
- [x] Add tests for preview/accept/cancel/reset, right dragging, cursor lifetime, hidden master, repeated entry, refresh and combat cleanup across flavors/styles.
- [x] Run new module: expect failure because BeginMasterMove is absent.
- [x] Implement independent editor/grip and transactional persistence, preserve secure targeting, integrate deferred combat cleanup.
- [x] Run focused tests: expect pass.

### Task 2: Options and localization

**Files:** QuestTargets/UI.lua, QuestTargets/Locale.lua, new test module.
**Consumes:** UI.BeginMasterMove(app).
- [x] Add failing tests for native/fallback entries and localized copy.
- [x] Add visible action/help, close settings on successful entry, explain hidden/combat failures; refresh labels in all six languages.
- [x] Run focused tests: expect pass.

### Task 3: Documentation and verification

**Files:** README.md, QuestTargets/README.md, plan/spec.
- [x] Document new mode and preserved right dragging.
- [x] Full suite and all flavor/minimal builds must pass without skips.
- [x] Independent whole-change review; fix important findings with RED→GREEN tests.
- [x] Record results; leave reviewable changes, no push/merge/publication.

## Execution ledger

User approved implementation; proceed inline without renewed approval. Task 1 produces BeginMasterMove(app) consumed by Task 2; no interface conflicts. Current base 4eebbb2. Existing workspace is isolated, branch work.


## Completion ledger

Task 1: complete — transaction/grip/native cursor, old right dragging, deferred combat cleanup. New feature tests observed RED before production implementation, then GREEN.
Task 2: complete — native custom settings row and fallback positioning group; six-language copy and live refresh. Both option-entry tests observed RED→GREEN.
Task 3: complete — English/German docs, independent whole-change review, final 169/169 tests (no skips), all five flavor ZIPs and minimal ZIP built, MCP XML schema validation passed, git diff --check clean.

Review fixes: native inherited title/help overlap; fallback scroll bounds for both styles; clamped editor/target alignment; repeated Start closing reopened options. Each has a regression observed RED→GREEN. Also covered stale right-drag stop after combat and malformed saved positions. No deferred review findings.

Ruling: preserve existing cloud checkout/work branch and leave changes for review, without merge/push/publication — user's explicit publication constraint takes precedence over the skill's integration menu.
Ruling: near screen edges, nudge the editing preview inward with the clamped editor so every control remains reachable; Cancel restores original coordinates — avoids a detached grip and first-drag jump; cost is a temporary inward preview shift before confirmation.

Native mouse dispatch, actual cursor rendering, five real clients and WoW's taint engine remain manual validation requirements. The independent reviewer had packaging failures when running without the required XDG environment; the canonical configured run passed all tests and builds afterward.
