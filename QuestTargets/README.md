# Quest Targets — 1.0.22

Addon für **WoW Classic Era 1.15.9 (Interface 11509)** und **WoW Forever Beta (Interface 160001)**. Quest Targets bietet einen
Button pro Quest sowie einen Masterbutton zum Anvisieren passender Questmobs
und Abgabe-NPCs.

## Installation

Für lokale Tests gibt es zwei getrennte Pakete: `QuestTargets-<Version>-Classic.zip`
für Classic Era und `QuestTargets-<Version>-Forever.zip` für Forever. Jedes ZIP
enthält auf oberster Ebene `QuestTargets/` und die passende, unveränderte
offizielle `QuestieDB/` v1.0.4. Vor einem Update das Spiel schließen und einen
bereits vorhandenen Ordner `Interface/AddOns/QuestieDB` entfernen. Danach beide
Ordner aus dem zum Client passenden ZIP nach `Interface/AddOns` entpacken und
das Spiel neu starten. So bleiben keine alten TOC-Dateien zurück.

Der bisherige, datenbankfreie Build `QuestTargets-<Version>.zip` bleibt für
öffentliche Verteilung erhalten. Dafür kann
[QuestieDB](https://github.com/Questie/QuestieDB/releases/) separat installiert
werden: `QuestieDB-Forever.zip` für Forever oder `QuestieDB-Vanilla.zip` für
Classic Era. Bei fehlendem Anbieter zeigt das Addon beim Login einen
Download-Hinweis. Die Erkennung über Questtexte und lesbare
Questinformationen sichtbarer Namensplaketten bleibt verfügbar.

Die kombinierten Pakete dürfen erst veröffentlicht werden, wenn die
Weiterverteilungsrechte von QuestieDB und der Test im Spiel geklärt sind.
Herkunft und Prüfsummen stehen im [QuestieDB-Hinweis](QUESTIEDB-NOTICE.md).

## Bedienung

- `/qt`: Questfenster öffnen oder schließen.
- Linksklick auf eine Quest: passende Ziele ihrer offenen Unterziele anvisieren.
- Rechtsklick auf eine Quest: diese im nativen Questlog öffnen.
- Masterbutton: Ziele aller aktiven Quests berücksichtigen; offene Mobziele
  haben Vorrang vor Abgabe-NPCs bereiter Quests.
- „Alle Quests“ / „Verfolgte Quests“: die Liste filtern. Der Masterbutton
  arbeitet unabhängig von diesem Filter.
- Mausrad oder Scrollbalken: weitere Quests in der Liste anzeigen.
- „Aktualisieren“: Questdaten erneut einlesen. Änderungen an Quests,
  Fortschritt und Verfolgung aktualisieren das Addon auch automatisch.
- „Bug melden / Verbesserung vorschlagen“: kopierbaren Link zum englischen
  Feedbackformular anzeigen. Eine GitHub-Anmeldung ist nicht erforderlich.
- Titelleiste ziehen: Questfenster verschieben. Den Masterbutton mit gedrückter
  rechter Maustaste verschieben.
- Minikarten-Button: Linksklick öffnet das Questfenster, Rechtsklick die
  Einstellungen. Mit der linken Maustaste am Minikartenrand verschieben.

Die kleinen Questbuttons zeigen beim Drücken eine native Klickanimation.
Jede Quest erscheint einmal mit ihrem Fortschritt. Alle bekannten Mobarten
aller offenen Unterziele sind gültige Ziele dieses Questbuttons. Erledigte
Unterziele liefern keine zusätzlichen Mobziele. Tooltips zeigen die Unterziele
und die gültigen Mobarten an.

## Einstellungen

„Einstellungen“ oder `/qt settings` öffnet die native WoW-Addon-Optionsseite.
Interne Reiter gliedern die Optionen in Allgemein, Zielmarkierung, Masterbutton
und Hotkeys. Eingerahmte Gruppen und scrollbare Inhalte halten die Einstellungen
auch bei kleineren Fenstergrößen erreichbar. Unter Allgemein stehen Anzeige,
Fenstergröße und Sprache; der Hotkey wird im eigenen Reiter zugewiesen.

Der Masterbutton unterstützt eine Tastenzuweisung einschließlich Kombinationen
wie STRG+F. Im Reiter „Masterbutton“ stehen zwei Darstellungen bereit:

- **Klassisch:** nativer Textbutton mit unabhängig einstellbarer Breite und
  Höhe sowie frei wählbarem, auch leerem Schriftzug.
- **Modern:** Quest-Kompass mit ungedrückter und gedrückter Grafik, ohne
  Schriftzug und mit einem gemeinsamen Größenfaktor für beide Achsen.

Die Standardsprache ist Englisch. Deutsch, Spanisch, Französisch, Türkisch
und vereinfachtes Chinesisch sind ebenfalls auswählbar. Die Oberflächensprache
wechselt sofort; Quest- und NPC-Namen folgen weiterhin der Clientsprache.
Größenregler bieten ein direkt bearbeitbares Zahlenfeld; 1 entspricht 100 %.
Einstellungen werden pro Charakter gespeichert.

Automatische Markierung ist standardmäßig mit dem Totenkopf aktiviert. Alle
acht nativen Zielmarker stehen zur Wahl. Gruppenrechte gelten weiterhin.
Bei Abgabe-NPCs kann ein weiterer Klick auf das bereits ausgewählte gültige
Ziel nötig sein, um die Markierung zu setzen. Ausschalten der Funktion
entfernt vorhandene Marker nicht.

## Erkennung und Grenzen

Die Resolver kombinieren direkte Datenbankziele, NPC-Dropquellen benötigter
Gegenstände, eindeutige Vorstufen-Gegenstandsquellen und automatisch erkannte
Clientinformationen. Es ist keine manuelle Zuordnung eines Mobs zu einer
Quest erforderlich. Mehrdeutige Zuordnungen werden ausgelassen.

Bekannte Spawn-Zonen begrenzen die Datenbankziele auf die aktuelle Zone.
Verfügbare Spawn-Koordinaten helfen bei der Reihenfolge der Namenssuche.
Fehlende oder unzuverlässige Ortsdaten bleiben als Rückfall berücksichtigt;
Spawn-Punkte sind keine garantierten aktuellen Positionen lebender NPCs.
Classic-Daten können neue oder geänderte Forever-Quests unvollständig oder
abweichend abbilden.

Das Anvisieren erfolgt per sicherer Namenssuche auf einen Klick oder Hotkey.
Sichtbare Namensplaketten helfen bei der Kandidatenauswahl. Auch ohne
Namensplaketten kann der Client bekannte Namen anvisieren. Ein bestimmtes
Exemplar unter mehreren gleichnamigen Mobs lässt sich damit nicht zuverlässig
wählen; garantiertes Durchschalten aller Exemplare ist nicht zugesagt.

Ein bereits gültiges Ziel bleibt bei fehlenden sichtbaren Alternativen
außerhalb des Kampfes ausgewählt. Sehr große Namenslisten werden wegen des
Makrolimits in Teilmengen durchsucht und können weitere Klicks erfordern.
Entfernung, Sichtlinie und tatsächliche Erreichbarkeit bestimmen die Regeln
des Clients. Weltobjekte sind keine anvisierbaren NPC-Ziele.

Im Kampf gelten die Einschränkungen geschützter Aktionen. Vorbereitete
Buttons bleiben im erlaubten Umfang nutzbar; Änderungen an geschützten
Buttons und am Questfenster werden nach Kampfende übernommen. Das Addon
führt keine HTTP-Abfragen im Spiel aus.

## Weitere Befehle

- `/qt refresh`: Questdaten aktualisieren.
- `/qt reset`: Position des Questfensters zurücksetzen.
- `/qt rescan` oder `/qt clear`: gespeicherte automatische Beobachtungen
  zurücksetzen; QuestieDB wird nicht verändert.
- `/qt debug`: Diagnose zum letzten Zielklick ausgeben.
- `/qt help`: Hilfe anzeigen.

Englische Befehle funktionieren in jeder Sprache. Die Hilfe zeigt zusätzlich
übersetzte Befehle für die ausgewählte Sprache.

## Entwicklung und Build

Die Test- und Build-Anleitung steht in der
[Repository-README](../README.md#development).

```powershell
./tools/package_quest_targets.ps1
./tools/package_quest_targets.ps1 -CurseForge
```

Der erste Aufruf erzeugt beide kombinierten lokalen Test-Builds, der zweite den
minimalen Build ohne QuestieDB. Angaben zum Datenanbieter und seiner Herkunft
stehen im [QuestieDB-Hinweis](QUESTIEDB-NOTICE.md).
