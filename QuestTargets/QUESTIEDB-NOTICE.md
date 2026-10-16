# QuestieDB provider and provenance

The Classic, TBC, Mists, and Forever combined builds include the official QuestieDB v1.0.6
flavor archive, without changing any QuestieDB file. Quest Targets is a separate
addon; the QuestieDB code and data belong to QuestieDB and its contributors.

- Project: https://github.com/Questie/QuestieDB
- Source release: https://github.com/Questie/QuestieDB/releases/tag/v1.0.6
- Release metadata: https://github.com/Questie/QuestieDB/releases/download/v1.0.6/release.json
- Producing commit: `36ca1ca86f6c1838de479c7c7452eb0a57d5c135`
- Classic artifact: `QuestieDB-Vanilla.zip` (SHA-256: `7bbed71d6387e2865e94cc821366cc05fbd7474f32f8640f682f6bc720b0f504`)
- Burning Crusade artifact: `QuestieDB-TBC.zip` (SHA-256: `f62fcc72b9f5f786b2298bdec09c4db16990a405b7aca07433e67bc31ba0f0cf`)
- Mists of Pandaria artifact: `QuestieDB-Mists.zip` (SHA-256: `6e688a122401342cedfcb5879940b70be9b293b3b03678c1ec0feb5b86067a13`)
- Forever artifact: `QuestieDB-Forever.zip` (SHA-256: `d78b066c362eaf28258d9e2d041c0a7b03d6943a2dfc741dec70c6bfd8e1fc27`)
- QuestieDB API contract: 4, supporting consumer contracts 1–4.
- Upstream code attribution: Logonz. Upstream data attribution is recorded in
  the included QuestieDB TOC files.

The official Forever archive contains both `QuestieDB_Forever.toc` and
`QuestieDB_Camelot.toc`; both are retained byte for byte. The packaging script
does not create a generic TOC or adapt the Classic provider for Forever.

Redistribution check for v1.0.6 (2026-10-16): the release-tag repository has
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
