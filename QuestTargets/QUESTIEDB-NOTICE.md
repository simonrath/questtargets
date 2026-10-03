# QuestieDB provider and provenance

The Classic, TBC, Mists, and Forever combined builds include the official QuestieDB v1.0.4
flavor archive, without changing any QuestieDB file. Quest Targets is a separate
addon; the QuestieDB code and data belong to QuestieDB and its contributors.

- Project: https://github.com/Questie/QuestieDB
- Source release: https://github.com/Questie/QuestieDB/releases/tag/v1.0.4
- Producing commit: `365537a340473291f5af3b7a53a5eca94e2a5f1a`
- Classic artifact: `QuestieDB-Vanilla.zip`
- Burning Crusade artifact: `QuestieDB-TBC.zip` (SHA-256: `5b2c398579425b22171e25bd7396268117caaed0f61b19785b81158e3988bf26`)
- Mists of Pandaria artifact: `QuestieDB-Mists.zip` (SHA-256: `cf2e33ccc6e8fd4b4a827fa3b7d33e70a37301ed3123edb618a806205bd542b6`)
- Classic SHA-256: `cf0ac8dfd6b0986a0624db6364d4e42a3691089663b8b00122d8ae2b2d040eed`
- Forever artifact: `QuestieDB-Forever.zip`
- Forever SHA-256: `2435d382c1a78c0876064c197196e73b9f417669f75187f51cc311fd8c2c19e1`
- QuestieDB API contract: 2, supporting consumer contract 1.
- Upstream code attribution: Logonz. Upstream data attribution is recorded in
  the included QuestieDB TOC files.

The official Forever archive contains both `QuestieDB_Forever.toc` and
`QuestieDB_Camelot.toc`; both are retained byte for byte. The packaging script
does not create a generic TOC or adapt the Classic provider for Forever.

The v1.0.4 source repository and the flavor archives contain no LICENSE or
COPYING file, and the GitHub repository does not declare a license. This notice
does **not** grant redistribution rights. Resolve the distribution terms with
the upstream maintainers before publishing a combined build. Until then, the
minimal Quest Targets package remains the public distribution option, with
QuestieDB installed separately from its official release.

To update a combined installation, close the game and remove the old
`Interface/AddOns/QuestieDB` folder before extracting the matching package.
This avoids retaining TOCs from a different client flavor.
