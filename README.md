# Quest Targets

Quest-targeting addon for **WoW Classic Era 1.15.9 (Interface 11509)** and **WoW Forever Beta (Interface 160001)**.

**[Download the latest release](https://github.com/simonrath/questtargets/releases/latest)**

## Installation

Download `QuestTargets-1.0.17-with-QuestieDB-Vanilla.zip` (Classic Era) or `QuestTargets-1.0.17-with-QuestieDB-Forever.zip` from the release page and extract both the `QuestTargets` and `QuestieDB` folders into `Interface/AddOns`. Restart the game after updating.

The combined release bundles the matching QuestieDB v1.0.4 provider as a separate addon folder. QuestieDB remains optional and can instead be installed separately.

## Features

- One target button per quest and a master button for active objectives.
- Prioritizes quest mobs, then NPCs for quests ready to turn in.
- Name targeting and nearby nameplate detection.
- Configurable target markers, hotkeys, and tooltips.
- Native addon settings, a minimap button, and classic or modern master-button appearance.
- English, German, Spanish, French, Turkish, and Simplified Chinese.
- In-game feedback button linking to [the public feedback form](https://feedback.jacknine.org); no GitHub account needed.

Use `/qt` to open the quest window and `/qt settings` to open settings.
Targeting is subject to the client's protected-action and combat restrictions.
See [the detailed documentation](QuestTargets/README.md) for behavior and limitations.

## Development

Install Python dependencies with `python -m pip install -r tests/requirements.txt`.
Run `python -m unittest discover -s tests -p "test_quest_targets*.py"`.
Build the matching provider bundle with `./tools/package_quest_targets.ps1 -Flavor Vanilla` or `./tools/package_quest_targets.ps1 -Flavor Forever`. The script pins and verifies QuestieDB v1.0.4.

Build a minimal release ZIP with PowerShell:

```powershell
./tools/package_quest_targets.ps1 -CurseForge
```

The ZIP contains runtime Lua, TOC, and texture files only. Tests, documentation,
and QuestieDB are excluded from this minimal CurseForge build.

## License

[MIT](LICENSE). See [QuestieDB notice](QuestTargets/QUESTIEDB-NOTICE.md) for the
separately distributed data provider.
