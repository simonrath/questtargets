# Quest Targets

Quest-targeting addon for **WoW Forever Beta (Interface 160001)**.

**[Download the latest release](https://github.com/simonrath/questtargets/releases/latest)**

## Installation

Download `QuestTargets-1.0.11.zip` from the release page and extract the
`QuestTargets` folder into `Interface/AddOns`. Restart the game after updating.

[QuestieDB Classic](https://github.com/Questie/QuestieDB/releases/) is an optional,
separate data provider and is not included in the download. Select a Classic
database release compatible with your client.

## Features

- One target button per quest and a master button for active objectives.
- Prioritizes quest mobs, then NPCs for quests ready to turn in.
- Name targeting and nearby nameplate detection.
- Configurable target markers, hotkeys, and tooltips.
- Native addon settings, a minimap button, and classic or modern master-button appearance.
- English, German, Spanish, French, Turkish, and Simplified Chinese.

Use `/qt` to open the quest window and `/qt settings` to open settings.
Targeting is subject to the client's protected-action and combat restrictions.
See [the detailed documentation](QuestTargets/README.md) for behavior and limitations.

## Development

Install Python dependencies with `python -m pip install -r tests/requirements.txt`.
Run `python -m unittest discover -s tests -p "test_quest_targets*.py"`.
Database integration tests additionally use the pinned QuestieDB v1.0.1 Vanilla
archive in the system temporary directory at
`quest-targets-questiedb-v1.0.1/QuestieDB-Vanilla.zip`; the build script without
flags downloads and verifies this archive.

Build a minimal release ZIP with PowerShell:

```powershell
./tools/package_quest_targets.ps1 -CurseForge
```

The ZIP contains runtime Lua, TOC, and texture files only. Tests, documentation,
and QuestieDB are excluded.

## License

[MIT](LICENSE). See [QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md) for the
separately distributed data provider.
