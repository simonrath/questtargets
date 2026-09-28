# QuestieDB provider notice

Quest Targets uses QuestieDB through its public API. The combined GitHub release bundles the upstream QuestieDB v1.0.4 addon as a separate `QuestieDB/` directory, alongside `QuestTargets/`. QuestieDB remains authored and maintained by the Questie project.

- Project: https://github.com/Questie/QuestieDB
- Release: https://github.com/Questie/QuestieDB/releases/tag/v1.0.4
- Classic Era: `QuestieDB-Vanilla.zip`, SHA256 `cf0ac8dfd6b0986a0624db6364d4e42a3691089663b8b00122d8ae2b2d040eed`
- Forever: `QuestieDB-Forever.zip`, SHA256 `2435d382c1a78c0876064c197196e73b9f417669f75187f51cc311fd8c2c19e1`
- Provider contract: 2, with support for consumer contract 1.

The build script verifies each upstream archive before packaging and copies its contents without changing provider Lua, data or TOC files. Attribution and any license notices included with the upstream archive must be retained. Quest Targets' MIT license covers Quest Targets' own files only; it does not relicense QuestieDB.

Use `./tools/package_quest_targets.ps1 -Flavor Vanilla` or `-Flavor Forever` for combined GitHub bundles. `-CurseForge` and `-AddonOnly` continue to build the addon without QuestieDB. QuestieDB can also be installed separately from its official release.
