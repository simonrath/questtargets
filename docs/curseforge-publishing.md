# GitHub-Releases automatisch auf CurseForge veröffentlichen

Vorbereitet für [Quest Targets auf CurseForge](https://www.curseforge.com/wow/addons/questtargets),
Projekt-ID **1709717**, und GitHub-Repository `simonrath/questtargets`.
Es wurde noch kein CurseForge-Upload durchgeführt und kein Token eingerichtet.

## Einmalige Einrichtung

1. **Dateien auf GitHub prüfen.** Die Vorbereitung wird auf dem Standardbranch
   `main` bereitgestellt. Dort müssen die beiden Workflows unter
   `.github/workflows`, `tools/publish_curseforge.py`, `tools/curseforge.json`
   und die Spieler-Patchnotes unter `docs/curseforge/` vorhanden sein.
   Die Aktivierungsvariable bleibt zunächst aus; es ist kein neuer
   Addon-Release für die Einrichtung erforderlich.
2. **CurseForge Upload-Token erstellen.** Im CurseForge-Konto des Projektinhabers
   die [API-Tokens-Seite](https://authors.curseforge.com/account/api-tokens)
   öffnen und einen Token für die Veröffentlichung erzeugen. Benötigt wird ein
   Token der **Upload API**, kein API-Key der allgemeinen CurseForge-Download-API.
   Das Konto muss Dateien für Projekt 1709717 hochladen dürfen.
3. **Token auf GitHub hinterlegen.** Unter
   [Repository → Settings → Secrets and variables → Actions](https://github.com/simonrath/questtargets/settings/secrets/actions)
   auf **New repository secret** klicken:
   - Name: `CF_API_TOKEN`
   - Secret: der eben erzeugte CurseForge-Token.
   Den Token nicht in Dateien, Issues, Patchnotes oder diesen Chat schreiben.
4. **GitHub Actions prüfen.** Unter **Settings → Actions → General** müssen
   Actions und der gepinnte `actions/checkout`-Workflow erlaubt sein. Der
   Veröffentlichungsjob beantragt `contents: write`, um Wiederholungen über
   Reservierungs-Tags zu verhindern. Übergeordnete Organisationsrichtlinien
   dürfen diesen Zugriff nicht sperren. Ein allgemeines Umschalten aller
   Workflows auf Schreibrechte ist nicht erforderlich.
5. **Lesenden Probelauf starten.** Unter
   [Actions](https://github.com/simonrath/questtargets/actions) den Workflow
   **Publish GitHub release to CurseForge** auswählen → **Run workflow**:
   - Branch: `main`
   - Tag: `v1.4.2`
   - `dry_run`: **true / angehakt lassen**
   - Flavor: `All`
   Der Probelauf liest die CurseForge-Versionsliste und die GitHub-Pakete,
   prüft die ZIPs und zeigt die Spieler-Patchnotes. Er erstellt keine
   Reservierungen und lädt keine Dateien hoch. Token und Game-Version-Zuordnung
   müssen ohne Fehler erkannt werden, bevor du fortfährst.
6. **Automatik aktivieren.** Unter **Settings → Secrets and variables → Actions
   → Variables → New repository variable** anlegen:
   - Name: `CURSEFORGE_ENABLED`
   - Value: `true`
   Das ist eine Variable, kein Secret. Fehlt sie oder hat sie einen anderen Wert,
   werden neue GitHub-Releases nicht automatisch hochgeladen.

Es ist kein zusätzlicher CurseForge-Webhook nötig. Wenn im CurseForge-Projekt
bereits ein eigener GitHub-Packager/Webhook aktiv ist, diesen deaktivieren,
damit zwei unabhängige Abläufe keine doppelten Dateien erzeugen.

## Was beim nächsten Release automatisch passiert

Ein veröffentlichter **stabiler** GitHub-Release wie `v1.4.2` startet den Workflow.
Entwürfe und Pre-Releases werden nicht auf CurseForge veröffentlicht.

Der Workflow lädt diese Dateien aus genau diesem GitHub-Release herunter:

- `QuestTargets-1.4.2-Classic.zip`
- `QuestTargets-1.4.2-TBC.zip`
- `QuestTargets-1.4.2-Mists.zip`
- `QuestTargets-1.4.2-Forever.zip`
- `QuestTargets-1.4.2-Retail.zip`
- `SHA256SUMS.txt`

Er baut die Pakete nicht neu. Vor dem ersten Upload prüft er alle ausgewählten
Dateien, ihre SHA-256-Werte, ZIP-Pfade, TOC-Versionen und Flavor-Inhalte. Die
fünf Pakete enthalten ausschließlich Quest Targets. QuestieDB wird für Nicht-Retail-Clients separat installiert; die CurseForge-Abhängigkeit richtet der Projektinhaber manuell ein. Das zusätzliche Minimal-ZIP wird nicht nochmals auf CurseForge geladen.

Die unterstützte Spielversion jedes Flavors stammt aus `tools/client-versions.json`.
Ihre CurseForge-ID wird über die aktuelle Upload-API-Versionsliste eindeutig
aufgelöst. TOC-Interface-Nummern werden **nicht** als CurseForge-IDs verwendet.
Fehlt eine Version oder ist ihr Name mehrdeutig, stoppt der Ablauf, statt einen
falschen Client auszuwählen. Beim Aktualisieren der unterstützten Clients müssen
Pins und Release-Pakete weiterhin zusammenpassen.

CurseForge erhält fünf Dateien vom Typ **Release** mit den passenden Spielversionen
und denselben englischen Spieler-Patchnotes. Nach Annahme des Uploads gelten
weiterhin CurseForges Freigabe-/Moderationsregeln; eine Datei kann dort zunächst
als ausstehend erscheinen. Die zurückgegebenen Datei-IDs stehen im Actions-Log
und in der Zusammenfassung des Laufs.

## Spieler-Patchnotes

Für jeden Release gehört eine englische Datei
`docs/curseforge/<version>.md` dazu, zum Beispiel `docs/curseforge/1.4.2.md`.
Die Anweisung für künftige Release-Arbeiten steht bereits in `AGENTS.md`:
Bei der Release-Vorbereitung werden diese Notizen aus den tatsächlich geänderten
Funktionen formuliert. Die Veröffentlichung übernimmt sie automatisch unverändert.

Schreibe, was Spieler bemerken: neue Steuerung, neue Optionen, korrigiertes
Verhalten. Keine Commit-Listen, internen Funktionsnamen, Teststatistiken oder
Entwicklungswerkzeuge. Ausführliche technische Notizen bleiben separat unter
`docs/releases/`. Eine fehlende/leere Spieler-Datei stoppt den Upload;
GitHub-generierte Commit-Patchnotes werden nicht ersatzweise veröffentlicht.

Beispiel:

```markdown
# Quest Targets 1.4.2

- Assign controller buttons to your targeting actions.
- Fixed an issue that prevented settings from appearing after login.
```

## Bestehenden Release nachträglich übertragen

Die Aktivierung veröffentlicht alte Releases nicht rückwirkend. Dazu denselben
Workflow manuell mit dem gewünschten vorhandenen Tag starten und `dry_run`
nach erfolgreichem Probelauf auf **false** stellen. `CURSEFORGE_ENABLED=true`
ist auch bei manuellen echten Uploads erforderlich. Vorher auf CurseForge prüfen,
ob diese Version bereits manuell hochgeladen wurde: Solche Alt-Uploads kennt
der neue Wiederholungsschutz nicht.

Wenn ein zukünftiger GitHub-Workflow Releases mit seinem eingebauten
`GITHUB_TOKEN` erzeugt, löst das normalerweise keinen zweiten release-Workflow
aus. Dann entweder den Publisher im selben Ablauf aufrufen oder anschließend
diesen Workflow per `workflow_dispatch` starten. Die bisherige Veröffentlichung
über die authentifizierte lokale GitHub-CLI kann `release: published` auslösen.

## Fehler und Wiederholungen

Vor jedem tatsächlichen Upload wird ein GitHub-Tag reserviert, etwa
`curseforge/v1.4.2/Classic`. Er verhindert einen erneuten Upload desselben
Release-Flavors auch nach einem abgebrochenen Lauf. Es gibt keine automatische
Wiederholung eines Upload-POSTs: Nach einem Verbindungsabbruch könnte CurseForge
die Datei bereits angenommen haben.

- Bereits erfolgreiche Flavors nicht erneut übertragen. Bei einem Teilfehler
  die übrigen einzeln mit dem manuellen Flavor-Auswahlfeld veröffentlichen.
- Bei einer vorhandenen Reservierung zuerst anhand des Actions-Logs und der
  CurseForge-Dateiliste feststellen, ob der Upload angenommen wurde.
- **Nur wenn sicher keine entsprechende Datei angelegt wurde**, den genau
  betroffenen Reservierungs-Tag auf GitHub löschen und diesen Flavor erneut
  starten. Nicht den eigentlichen Release-Tag `v1.4.2` löschen.
- Die Automatik pausieren: `CURSEFORGE_ENABLED` auf `false` setzen. Einen bereits
  laufenden Upload bei Bedarf zusätzlich unter Actions abbrechen.

Lokaler Dry-Run (Python 3 und authentifizierte GitHub-CLI erforderlich):

```powershell
# CF_API_TOKEN vorher sicher als Umgebungsvariable setzen.
python tools/publish_curseforge.py --tag v1.4.2 --dry-run
```

## Quellen und Grenzen der Vorbereitung

- [Offizielle CurseForge Upload API](https://support.curseforge.com/support/solutions/articles/9000197321-curseforge-upload-api):
  Header-Authentifizierung, Versionsabfrage und multipart-Upload.
- [GitHub release-Ereignisse](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#release)
  und [GITHUB_TOKEN-Ereignisregeln](https://docs.github.com/en/actions/concepts/security/github_token).
- XERJ-Referenz: `Questie/upload-cf.sh` im gepinnten `qtrefs`-Korpus. Verwendet
  wurde der Ansatz „existierendes Artefakt prüfen und Upload vorher reservieren“;
  kein fremder Implementierungscode wurde übernommen.

Ohne Token kann die Vorbereitung die echte CurseForge-Authentifizierung,
Versionsantwort, Projektberechtigung und Moderation nicht testen. Unit-Tests
verwenden simulierte Antworten. Ein tokenfreier Dry-Run mit
`--offline-versions <fixture.json>` prüft zusätzlich echte GitHub-Dateien gegen
ausdrücklich simulierte Versions-IDs; diese Option ist bei `--publish` gesperrt.
