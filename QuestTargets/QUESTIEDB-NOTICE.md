# QuestieDB provider and provenance

The Classic, TBC, Mists, and Forever combined builds include the official QuestieDB v1.0.5
flavor archive, without changing any QuestieDB file. Quest Targets is a separate
addon; the QuestieDB code and data belong to QuestieDB and its contributors.

- Project: https://github.com/Questie/QuestieDB
- Source release: https://github.com/Questie/QuestieDB/releases/tag/v1.0.5
- Release metadata: https://github.com/Questie/QuestieDB/releases/download/v1.0.5/release.json
- Producing commit: `e0a6eaa86f181ac99262e34126bcd2ed1a1712d6`
- Classic artifact: `QuestieDB-Vanilla.zip` (SHA-256: `9b84a8ab028a84d4df92460ce1e9f80d2b3594cd066772fff61411466d213111`)
- Burning Crusade artifact: `QuestieDB-TBC.zip` (SHA-256: `5c4ad573c57f53a28e83b7b8fcd324191dcd241a916d1639826a7aeccde16705`)
- Mists of Pandaria artifact: `QuestieDB-Mists.zip` (SHA-256: `87106b580cc2e4dd2468379abba6518ba12fe7826a1997d470b05003e02b165c`)
- Forever artifact: `QuestieDB-Forever.zip` (SHA-256: `993680e91b8bcc1f5454af94478b1f70e0bf02bc4bd596001c8136b440939712`)
- QuestieDB API contract: 3, supporting consumer contract 1.
- Upstream code attribution: Logonz. Upstream data attribution is recorded in
  the included QuestieDB TOC files.

The official Forever archive contains both `QuestieDB_Forever.toc` and
`QuestieDB_Camelot.toc`; both are retained byte for byte. The packaging script
does not create a generic TOC or adapt the Classic provider for Forever.

Redistribution check for v1.0.5 (2026-10-06): the release-tag repository has
no LICENSE file, none of the four pinned flavor archives contains a LICENSE,
COPYING, or NOTICE file, and the release notes do not specify redistribution
terms. No permission for redistribution was established. This notice
does **not** grant redistribution rights. Resolve the distribution terms with
the upstream maintainers before publishing a combined build. Until then, the
minimal Quest Targets package remains the public distribution option, with
QuestieDB installed separately from its official release.

To update a combined installation, close the game and remove the old
`Interface/AddOns/QuestieDB` folder before extracting the matching package.
This avoids retaining TOCs from a different client flavor.
