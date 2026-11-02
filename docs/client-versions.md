# Client pins (EU, checked 2026-10-31)

| Flavor | Product | Version/build | Interface |
| --- | --- | --- | --- |
| Retail | wow | 12.1.5.70688 | 120105 |
| Classic Era | wow_classic_era | 1.15.9.70576 | 11509 |
| Burning Crusade Anniversary | wow_anniversary | 2.5.6.70577 | 20506 |
| Mists of Pandaria Classic | wow_classic | 5.5.4.70631 | 50504 |
| Forever | wowf | 1.60.1.70707 | 16001 |

Source: Blizzard's version service, the `eu` row of
`https://eu.version.battle.net/<product>/versions`. Exact URLs are preserved
in [client-versions.json](../tools/client-versions.json). Version metadata
remains reachable independently of game-server availability.

Forever uses `wowf`; the older `wow_classic_beta` channel reports
1.60.1.70532 and is not the current pin. PTR/beta builds of other products
are excluded. Client build numbers are documented pins; WoW uses the
Interface number in the TOC to assess addon-version compatibility. A new
build with the same Interface number does not require another Interface tag.

QuestieDB latest release was checked separately: v1.0.9. Existing provider
artifact SHA-256 pins remain unchanged. The package builder checks each
client's pinned Interface against the TOC before producing any archive.
Automated tests check all five pins, version/interface consistency and
package metadata. They do not establish in-game compatibility by themselves.
