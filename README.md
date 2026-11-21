# Quest Targets

Quest-targeting addon for **WoW Classic Era 1.15.9 (Interface 11509)**, **Burning Crusade Classic 2.5.6 (20506)**, **Mists of Pandaria Classic 5.5.4 (50504)**, **WoW Forever 1.60.1 (16001)**, and **Retail 12.1.5 (120105)**.

**[Download the latest release](https://github.com/simonrath/questtargets/releases/latest)**

## Installation

Download `QuestTargets-<version>.zip` for any supported client: Retail, Classic,
TBC, Mists, or Forever. The same ZIP works on all five and contains only `QuestTargets/`. Close WoW and replace
`Interface/AddOns/QuestTargets` with the folder from the ZIP.

For Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, and Forever,
install and enable **QuestieDB** separately from
[CurseForge](https://www.curseforge.com/wow/addons/questiedb) or the
[official QuestieDB releases](https://github.com/Questie/QuestieDB/releases/).
Choose the version for your client. QuestieDB is no longer included in Quest Targets.
If QuestieDB is already installed, keep it and update it separately.
QuestieDB supplies data only; keep the full Questie addon enabled to use its tracker.

Retail needs no QuestieDB and reads objectives from the Retail quest log. Mob names
come from readable quest text and visible nameplates. Item sources and turn-in NPCs
without names in the quest text are not inferred on Retail.

## Features

The [patch notes](CHANGELOG.md) follow the selected addon's language and open
once on the first login with a new version. Open them again under
**Options → AddOns → Quest Targets → Patch Notes**.

Release maintainers: [Set up automatic CurseForge publishing](docs/curseforge-publishing.md).

Quest Targets also appears under **Options → Keybindings → Quest Targets**.
The master, focused quest, ItemTree and RareScanner actions support two binding slots each.
Native changes, including clearing a focused-quest binding, are kept across
refreshes and reloads. In the addon's own Hotkeys section, assigning an occupied
keyboard/controller key requires confirmation before replacing its old action.

- One target button per quest and a master button for active objectives.
- Prioritizes quest mobs, then NPCs for quests ready to turn in.
- Name targeting and nearby nameplate detection.
- Configurable target markers, hotkeys, and tooltips.
- Compact native addon settings in every supported client, with a minimap button and a resizable, movable compass button bar.
- Quest-specific target buttons appear automatically beside quest rows in Questie's tracker when Questie is installed and enabled.
- Right-click a quest icon in either quest list to focus that quest. The always-visible focus highlight is shared between both lists; a separate configurable hotkey targets only the focused quest while the master button keeps its normal behavior.
- **RestedXP:** Enable **Show RestedXP button** under **Buttons → Targeting bar**. The blue compass looks for targets in your active guide step, including mobs, quest NPCs and flight masters. The main compass also prioritizes the guide step and falls back to regular quest objectives when the step has no target.
- **RareScanner on WoW Forever:** Click a rare icon on the world map to mark it, then use the purple compass or its hotkeys to search marked rares. Enable **Search all rares in the zone** under **Buttons → Targeting bar** to include unmarked rares and known dungeon rares. Click a rare icon on the minimap to look for that rare directly.
- **Polestar on WoW Forever:** Enable **Follow Polestar guide targets** under **Buttons → Targeting bar** to use the main compass for named, open goals in the displayed Polestar step. Normal quest targeting remains the fallback; secure updates wait until combat ends. RestedXP takes precedence when both integrations are enabled and available. Polestar's own controls are unchanged.
- Optional transparency mode immediately leaves only the quest list visible. Its toggle icon hides two seconds after the cursor leaves the window and reappears when the cursor moves anywhere over it. A 90% transparent draggable strip is shown only while the cursor is over the window.
- The compact quest window has adjacent Settings and Feedback buttons; quest data also refreshes automatically or with `/qt refresh`.
- Under **Buttons → Targeting bar**, choose the visible compasses, adjust size, layout and spacing, and toggle the bronze border and dividers independently.
- English, German, Spanish, French, Turkish, and Simplified Chinese.
- In-game feedback button with a copyable link and a QR code for
  [the public feedback form](https://feedback.jacknine.org/). Scan the code with
  your phone to submit feedback; no GitHub account is needed.

Use `/qt` to open the quest window and `/qt settings` to open settings.
Under **Hotkeys**, each action has two binding buttons side by side,
like WoW's native keybinding rows. Click either slot and press a keyboard key or
an Xbox/controller button, middle/extra mouse button, or scroll the mouse wheel.
Ctrl, Alt, and Shift modifiers also work with mouse inputs. While listening,
left- or right-click cancels assignment; these primary mouse buttons are reserved.
Keep the pointer over the binding button when assigning mouse input.
Changing or clearing one slot keeps the other binding;
when the first slot is cleared, the remaining binding moves into it. The controller must already be recognized by WoW
and native gamepad input must be enabled (`/console GamePadEnable 1` on clients
that support it). Escape cancels assignment; Delete or Backspace clears the selected slot.
Clients without the gamepad frame API retain keyboard binding support.
To position the bar, open **Buttons → Targeting bar → Move button bar**.
Outside combat, drag the handle with the left mouse button; the native move cursor
shows where you can drag. Choose **Done** to save, **Cancel** or Escape to restore
the previous position, or **Reset position** to preview the default position.
Holding the right mouse button and dragging the master button still works directly.
If combat starts during editing, editing ends and the last released position is
saved after combat. The positioning controls are available even with tooltips off.
Targeting is subject to the client's protected-action and combat restrictions.
Under **Target markers**, **Mute dead-target clearing sound** optionally suppresses
the deselection sound for 100 ms when a Quest Targets button or hotkey replaces
a dead NPC. It is off by default and adds no macro bytes. Selection sounds and
living-target changes stay audible; another playback of the same deselection
sound during the short window is also muted. Standalone action-bar macros are
not covered. In-game timing still needs validation on each supported client.
See [the detailed documentation](QuestTargets/README.md) for behavior and limitations.

## Development

Follow the [internal patch notes guide](docs/patch-notes-guide.md) for every
change. Maintain the German player history in [CHANGELOG.md](CHANGELOG.md)
and its five translations under [docs/changelog](docs/changelog). Run
`./tools/update_patch_notes.ps1` before packaging. The English in-game history
is separate from the English CurseForge notes for a specific release.

The patch notes use the scrollable version-card pattern from
[FlareUI's What's New panel](https://github.com/malkkav/FlareUI/blob/main/Settings/Panel.lua).
The Quest Targets entry in Options uses the existing action-row pattern
from `QuestTargetsMoveSettingMixin` in `QuestTargets/UI.lua`.
The window uses Blizzard templates, following the existing
`DefaultPanelFlatTemplate` and NineSlice setup in `UI.Create`.

Install Python dependencies with `python -m pip install -r tests/requirements.txt`.
Run `python -m unittest discover -s tests -p "test_quest_targets*.py"`.
Database integration tests use the pinned QuestieDB v1.0.9 Vanilla archive in
the system temporary directory at
`quest-targets-questiedb-v1.0.9/QuestieDB-Vanilla.zip`. Package tests verify that every flavor contains Quest Targets only;
building packages requires no QuestieDB download or provider cache.

Build the universal release package with PowerShell:

```powershell
./tools/package_quest_targets.ps1
```

The result is `dist/QuestTargets-<version>.zip`, shared by all five clients.
It contains runtime Lua, XML, TOC, and texture files only. Tests, documentation,
and QuestieDB are excluded. Legacy `-Flavor`, `-AddonOnly`, and `-CurseForge`
arguments remain accepted and produce the same universal archive.

Build a test package with a unique version and filename:

```powershell
./tools/package_quest_targets.ps1 -PreviewVersion 1.6.1
```

The ZIP name and its embedded TOC version include a UTC timestamp, such as
`QuestTargets-1.6.1-preview.20261115-120000-123Z.zip`. This makes installed test
builds distinguishable in the options heading. The source TOC is preserved.
Existing archives are never overwritten. Use `-OutputDirectory <folder>` for
another destination. Package tests build in temporary directories so they
cannot replace downloaded release files.

## License

[GNU GENERAL PUBLIC LICENSE](LICENSE) for Quest Targets only.

### QuestieDB attribution

Quest Targets accesses the separately installed QuestieDB addon through its public
API. QuestieDB code and data belong to the [QuestieDB team and its contributors](https://github.com/Questie/QuestieDB).
Quest Targets 1.4.2 and later do not redistribute QuestieDB. See the
[QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md) for earlier package provenance.
