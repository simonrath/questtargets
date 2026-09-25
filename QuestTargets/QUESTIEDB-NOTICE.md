# QuestieDB provider notice

QuestieDB is an optional, separately installed addon and data provider.
Its data and runtime are not authored by Quest Targets and are not included
in the published Quest Targets release ZIP.

- Project: https://github.com/Questie/QuestieDB
- Downloads: https://github.com/Questie/QuestieDB/releases/
- Pinned integration-test and combined-build release: v1.0.1
- Artifact: `QuestieDB-Vanilla.zip`
- SHA256: `0aa71066dad715aac0af03d79f74acdb669a63df8d2368aed222b63dd20f68b8`
- Provider contract: 2, with support for consumer contract 1.
- Upstream release TOC code attribution: Logonz.
- Upstream release TOC data attribution: Muehe/TheCrux(BreakBB)/Drejjmit/Dyaxler/Cheeq/TechnoHunter/Yttrium/Everyone else.

## Optional combined development build

Running `tools/package_quest_targets.ps1` without switches downloads and
verifies the pinned archive and produces a combined package. The provider's
Lua code, localization, and data are unchanged. The script adds Interface
160001 to the Vanilla TOC, substitutes a native Blizzard IconAtlas for the
IconTexture metadata, and adds a generic `QuestieDB.toc` for client discovery.
This notice is also copied into the provider directory.

Use `-CurseForge` for the published minimal Quest Targets package. This mode
neither downloads nor includes QuestieDB. `-AddonOnly` also excludes QuestieDB
but includes Quest Targets documentation.

## Compatibility and attribution

The loader adjustments are compatibility adaptations, not an official
Forever release or endorsement from QuestieDB. They do not convert Classic
content into Forever content. Changed or new Forever quests may have
incomplete or outdated database coverage.

Original authorship and upstream licensing remain with QuestieDB and its
contributors. Quest Targets does not assert ownership or grant a new license
for their work. Refer to the upstream project and the chosen release for its
applicable license and distribution terms.
