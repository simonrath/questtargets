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

## Features

- One target button per quest and a master button for active objectives.
- Prioritizes quest mobs, then NPCs for quests ready to turn in.
- Name targeting and nearby nameplate detection.
- Configurable target markers, hotkeys, and tooltips.
- Native addon settings, a minimap button, and classic or modern master-button appearance.
- Optional quest-specific target buttons beside quest rows in Questie's tracker when Questie is installed and enabled.
- Optional RestedXP guide targeting for the master button, with a matching button on RestedXP's target frame. Only active-step targets that match open quest objectives or ready turn-in NPCs are used; repeated clicks advance through them. Secure targets refresh after combat.
- Optional transparency mode immediately leaves only the quest list visible. Its toggle icon hides two seconds after the cursor leaves the window and reappears when the cursor moves anywhere over it. A 90% transparent draggable strip is shown only while the cursor is over the window.
- The compact quest window has adjacent Settings and Feedback buttons; quest data also refreshes automatically or with `/qt refresh`.
- At 100%, both master-button styles are the size previously shown at 150%; saved scales are migrated to preserve their visible size.
- English, German, Spanish, French, Turkish, and Simplified Chinese.
- In-game feedback button linking to [the public feedback form](https://feedback.jacknine.org); no GitHub account needed.

Use `/qt` to open the quest window and `/qt settings` to open settings.
Targeting is subject to the client's protected-action and combat restrictions.
See [the detailed documentation](QuestTargets/README.md) for behavior and limitations.

## Development

Install Python dependencies with `python -m pip install -r tests/requirements.txt`.
Run `python -m unittest discover -s tests -p "test_quest_targets*.py"`.
Database integration tests use the pinned QuestieDB v1.0.1 Vanilla archive in
the system temporary directory at
`quest-targets-questiedb-v1.0.1/QuestieDB-Vanilla.zip`. Package tests use
the official v1.0.4 Vanilla, TBC, Mists, and Forever artifacts; the packaging script
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

Credit for QuestieDB belongs to the QuestieDB team and its contributors. The bundled package comes from the [official QuestieDB v1.0.4 release](https://github.com/Questie/QuestieDB/releases/tag/v1.0.4). Its source is available in the [QuestieDB repository](https://github.com/Questie/QuestieDB).
