# QuestieDB provider provenance

QuestieDB is a separate addon/provider. Its data and runtime are not authored
by Quest Targets.

- Project: https://github.com/Questie/QuestieDB
- Release: https://github.com/Questie/QuestieDB/releases/tag/v1.0.1
- Artifact: `QuestieDB-Vanilla.zip`
- SHA256: `0aa71066dad715aac0af03d79f74acdb669a63df8d2368aed222b63dd20f68b8`
- Provider contract: 2, supports consumer contract 1.
- Release TOC code attribution: Logonz.
- Release TOC data attribution: Muehe/TheCrux(BreakBB)/Drejjmit/Dyaxler/Cheeq/TechnoHunter/Yttrium/Everyone else.

The local combined package keeps provider Lua code, localization and data
unchanged. The packaging script adds Interface 160001 to the Vanilla TOC, uses a
native Blizzard IconAtlas instead of IconTexture, and adds an identical generic
`QuestieDB.toc` so the Forever client can discover the addon. This notice is
copied into the provider directory. Original authorship remains with upstream;
no ownership or new license for their work is asserted here.

These loader adjustments are local compatibility adaptations, **not an official
Forever release of QuestieDB**. They do not convert Classic content into Forever
content. Changed or new Forever quests may have incomplete or outdated database
coverage. Quest Targets checks quest titles and objective identity before using
the baseline and supplements it with readable client observations.

The combined package was prepared for this user's local addon setup. No upstream
release, remote repository, addon catalogue or other public distribution was
created or modified by this task.
