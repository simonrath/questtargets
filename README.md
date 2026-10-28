# Quest Targets

Quest-targeting addon for **WoW Classic Era 1.15.9 (Interface 11509)**, **Burning Crusade Classic 2.5.6 (20506)**, **Mists of Pandaria Classic 5.5.4 (50504)**, **WoW Forever Beta (16001)**, and **Retail 12.1 (120100)**.

**[Download the latest release](https://github.com/simonrath/questtargets/releases/latest)**

## Installation

The build script produces local `QuestTargets-<version>-Retail.zip`,
`QuestTargets-<version>-Classic.zip`, `QuestTargets-<version>-TBC.zip`,
`QuestTargets-<version>-Mists.zip`, and `QuestTargets-<version>-Forever.zip`
packages by default. Choose the ZIP for your client. The non-Retail
packages contain `QuestTargets/` and the corresponding official `QuestieDB/` at
the ZIP root. Close the game, remove an existing `Interface/AddOns/QuestieDB`
folder, extract both folders into `Interface/AddOns`, then restart the game.
Removing the old folder prevents TOCs from another game flavor lingering.

The public minimal `QuestTargets-<version>.zip` remains available without
QuestieDB; install the matching provider separately from the
[official QuestieDB releases](https://github.com/Questie/QuestieDB/releases/).
Retail users can install `QuestTargets-<version>-Retail.zip` directly; it needs
no QuestieDB and reads objectives from the Retail quest log. Mob names come
from readable quest text and visible nameplates. Item sources and turn-in NPCs
without names in the quest text are not inferred on Retail.
The combined packages include the matching QuestieDB release; see the
[QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md) for its provenance.
They bundle QuestieDB 1.0.6, which supports both Quest Targets and Questie 12.1.0.
QuestieDB supplies data only; keep the full Questie addon installed and enabled
to use its tracker.

## Features

- One target button per quest and a master button for active objectives.
- Prioritizes quest mobs, then NPCs for quests ready to turn in.
- Name targeting and nearby nameplate detection.
- Configurable target markers, hotkeys, and tooltips.
- Compact native addon settings in every supported client, with inline master-button text editing, a minimap button, and classic or modern master-button appearance.
- Quest-specific target buttons appear automatically beside quest rows in Questie's tracker when Questie is installed and enabled.
- Right-click a quest icon in either quest list to focus that quest. The always-visible focus highlight is shared between both lists; a separate configurable hotkey targets only the focused quest while the master button keeps its normal behavior.
- Optional RestedXP guide targeting for the master button, with a matching button on RestedXP's target frame. Active-step mobs and explicitly named targets are eligible even outside the quest log, including gathering mobs, quest NPCs, and flight masters. If the guide has no target, the native quest search takes over immediately; failed guide searches try a native quest target in the same macro when space allows, then fall back to the full native search on the next click. Repeated clicks keep a valid current target unless another matching target is visible. Secure targets refresh after combat.
- Optional transparency mode immediately leaves only the quest list visible. Its toggle icon hides two seconds after the cursor leaves the window and reappears when the cursor moves anywhere over it. A 90% transparent draggable strip is shown only while the cursor is over the window.
- The compact quest window has adjacent Settings and Feedback buttons; quest data also refreshes automatically or with `/qt refresh`.
- At 100%, both master-button styles are the size previously shown at 150%; saved scales are migrated to preserve their visible size.
- English, German, Spanish, French, Turkish, and Simplified Chinese.
- In-game feedback button linking to [the public feedback form](https://feedback.jacknine.org); no GitHub account needed.

Use `/qt` to open the quest window and `/qt settings` to open settings.
To position the master button, open **Settings → Master button → Move master button**.
Outside combat, drag the handle with the left mouse button; the native move cursor
shows where you can drag. Choose **Done** to save, **Cancel** or Escape to restore
the previous position, or **Reset position** to preview the default position.
Holding the right mouse button and dragging the master button still works directly.
If combat starts during editing, editing ends and the last released position is
saved after combat. The positioning controls are available even with tooltips off.
Targeting is subject to the client's protected-action and combat restrictions.
See [the detailed documentation](QuestTargets/README.md) for behavior and limitations.

## Development

Install Python dependencies with `python -m pip install -r tests/requirements.txt`.
Run `python -m unittest discover -s tests -p "test_quest_targets*.py"`.
Database integration tests use the pinned QuestieDB v1.0.6 Vanilla archive in
the system temporary directory at
`quest-targets-questiedb-v1.0.6/QuestieDB-Vanilla.zip`. Package tests use
the official v1.0.6 Vanilla, TBC, Mists, and Forever artifacts; the packaging script
downloads missing artifacts and verifies their SHA-256 hashes.

Build all five local packages with PowerShell:

```powershell
./tools/package_quest_targets.ps1
```

Build a minimal release ZIP or only the Retail package with PowerShell:

```powershell
./tools/package_quest_targets.ps1 -CurseForge
./tools/package_quest_targets.ps1 -Flavor Retail
```

The minimal ZIP contains runtime Lua, TOC, and texture files only. Tests,
documentation, and QuestieDB are excluded. `-AddonOnly` also omits QuestieDB
but includes documentation. Use `-Flavor Classic`, `-Flavor TBC`, `-Flavor Mists`, or `-Flavor Forever` to build
only one combined flavor. See the [QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md)
for source hashes and the unresolved redistribution terms.

## License

[GNU GENERAL PUBLIC LICENSE](LICENSE) for Quest Targets only.

### QuestieDB attribution

Questie is listed on [CurseForge](https://www.curseforge.com/wow/addons/questie) under the GNU General Public License version 3 (GPLv3). Quest Targets includes an unmodified copy of QuestieDB, the database used by Questie. Quest Targets is a separate addon that accesses QuestieDB through its public API; we have not changed QuestieDB’s code or data.

Credit for QuestieDB belongs to the QuestieDB team and its contributors. Local combined packages use the [official QuestieDB v1.0.6 release](https://github.com/Questie/QuestieDB/releases/tag/v1.0.6). Its source is available in the [QuestieDB repository](https://github.com/Questie/QuestieDB). Redistribution terms remain unresolved; see the [QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md) before publishing combined packages.
