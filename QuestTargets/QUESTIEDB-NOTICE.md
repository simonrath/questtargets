# QuestieDB provider and provenance

The Classic, TBC, Mists, and Forever combined builds include the official QuestieDB v1.0.9
flavor archive, without changing any QuestieDB file. Quest Targets is a separate
addon; the QuestieDB code and data belong to QuestieDB and its contributors.

- Project: https://github.com/Questie/QuestieDB
- Source release: https://github.com/Questie/QuestieDB/releases/tag/v1.0.9
- Release metadata: https://github.com/Questie/QuestieDB/releases/download/v1.0.9/release.json
- Producing commit: `7901fee2753cecb577a72c2e4b7126198e05baec`
- Classic artifact: `QuestieDB-Vanilla.zip` (SHA-256: `72b0353075df53d09d540dbd016c84b37ccce7ea08394421d7558fbd28121f9c`)
- Burning Crusade artifact: `QuestieDB-TBC.zip` (SHA-256: `6bcd8c1aff2ee55e6ec878f9b4f4e9323d645eb56125a56deab2bb7fa3735460`)
- Mists of Pandaria artifact: `QuestieDB-Mists.zip` (SHA-256: `5eb1315a52287c8c664b6aac747fa2e9d6071416c613903e678984d5d6aaf7b6`)
- Forever artifact: `QuestieDB-Forever.zip` (SHA-256: `9c180a2ecfa22328c6c7fa7d4e8154a178229d8e2339fce0b480f80916653edb`)
- QuestieDB API contract: 4, supporting consumer contracts 1–4.
- Upstream code attribution: Logonz. Upstream data attribution is recorded in
  the included QuestieDB TOC files.

The official Forever archive contains both `QuestieDB_Forever.toc` and
`QuestieDB_Camelot.toc`; both are retained byte for byte. The packaging script
does not create a generic TOC or adapt the Classic provider for Forever.

Licensing check for v1.0.9 (2026-10-28): the release-tag repository and all
four pinned flavor archives now include `LICENSE.md`. This file describes
GPLv3 consent for listed contributors, points to Questie's terms for imported
content, and retains an "all rights reserved" fallback for content not otherwise
covered. It does not establish blanket GPLv3 coverage for every historic
contribution. The combined packages retain the upstream license file unchanged;
this notice does not grant additional redistribution rights. The minimal
Quest Targets package remains available without QuestieDB, which can be
installed separately from its official release.

To update a combined installation, close the game and remove the old
`Interface/AddOns/QuestieDB` folder before extracting the matching package.
This avoids retaining TOCs from a different client flavor.
