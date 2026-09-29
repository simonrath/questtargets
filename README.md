# Quest Targets

Quest-targeting addon for **WoW Classic Era 1.15.9 (Interface 11509)** and **WoW Forever Beta (Interface 160001)**.

**[Download the latest release](https://github.com/simonrath/questtargets/releases/latest)**

## Installation

The build script produces separate `QuestTargets-<version>-Classic.zip` and
`QuestTargets-<version>-Forever.zip` packages. Choose the ZIP for your client.
Each contains `QuestTargets/` and the corresponding official `QuestieDB/` at
the ZIP root. Close the game, remove an existing `Interface/AddOns/QuestieDB`
folder, extract both folders into `Interface/AddOns`, then restart the game.
Removing the old folder prevents TOCs from another game flavor lingering.

The public minimal `QuestTargets-<version>.zip` remains available without
QuestieDB; install the matching provider separately from the
[official QuestieDB releases](https://github.com/Questie/QuestieDB/releases/).
Combined packages are local test builds until QuestieDB redistribution terms
and in-client compatibility have been confirmed.

## Features

- One target button per quest and a master button for active objectives.
- Prioritizes quest mobs, then NPCs for quests ready to turn in.
- Name targeting and nearby nameplate detection.
- Configurable target markers, hotkeys, and tooltips.
- Native addon settings, a minimap button, and classic or modern master-button appearance.
- Optional transparency mode immediately leaves only the quest list visible; its toggle icon hides after two seconds and reappears on hover.
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
the official v1.0.4 Vanilla and Forever artifacts; the packaging script
downloads missing artifacts and verifies their SHA-256 hashes.

Build both combined local test packages with PowerShell:

```powershell
./tools/package_quest_targets.ps1
```

Build a minimal release ZIP with PowerShell:

```powershell
./tools/package_quest_targets.ps1 -CurseForge
```

The minimal ZIP contains runtime Lua, TOC, and texture files only. Tests,
documentation, and QuestieDB are excluded. `-AddonOnly` also omits QuestieDB
but includes documentation. Use `-Flavor Classic` or `-Flavor Forever` to build
only one combined flavor. See the [QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md)
for source hashes and the unresolved redistribution terms.

## License

[GNU GENERAL PUBLIC LICENSE](LICENSE) for Quest Targets only. QuestieDB is a separate upstream project;
see the [QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md).
