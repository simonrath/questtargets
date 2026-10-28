# Masterbutton verschieben: ergänzender Bearbeitungsmodus

Status: vom Nutzer zur Umsetzung freigegeben. Gewählte Richtung: ergänzender Modus aus den Optionen, bestehendes Rechtsziehen bleibt erhalten. Nutzerentscheidung vom 28.10.2026.

## Anlass und Befund

Issues [#21](https://github.com/simonrath/questtargets/issues/21) und [#23](https://github.com/simonrath/questtargets/issues/23) melden fehlende bzw. nicht erkennbare Verschiebbarkeit. Kein Flavor angegeben. Untersuchung auf main, 4eebbb2, Addon 1.2.8.

Der gemeinsame Masterbutton registriert bereits Rechtsziehen außerhalb des Kampfes. Beide Darstellungen verwenden diese Implementierung ohne Flavor-Weiche. Die zusätzliche Diagnose hat in 10/10 Kombinationen aus fünf Flavors und zwei Darstellungen Registrierung, Handler, Positionsspeicherung und Combat-Grenzen bestanden. Die vorhandene Testsuite besteht mit 158 Tests, ohne Skips. Die Tests simulieren die Lua-Handler, nicht Blizzards native Mausereignisse oder Taint-Engine. Ein Fehler in einem tatsächlichen Client ist deshalb nicht ausgeschlossen.

Nachgewiesene Hürde: showTooltips ist standardmäßig aus. Deshalb erscheint die bereits vorhandene Verschiebehilfe am Button nicht. Im Kampf wird der Drag-Start außerdem still abgewiesen. /qt reset setzt nur das Questfenster zurück.

Die Issues sind gelesen und lokal bearbeitet; ein GitHub-Startkommentar oder Statuswechsel ist wegen Forbidden auf REST und GraphQL nicht erfolgt.

## Betrachtete Ansätze

1. Nur die bisherige Rechtsdrag-Geste erklären: geringster Aufwand, aber die ungewöhnliche Bedienung bleibt.
2. Ergänzender Bearbeitungsmodus aus den Optionen: sichtbarer Einstieg, größere Drag-Fläche und klarer Abschluss. Vom Nutzer gewählt.
3. Dauerhafter Griff: direkt erreichbar, aber dauerhaft zusätzlicher Platzverbrauch. Nicht gewählt.

## Bedienung

- In Optionen → Masterbutton erscheint eine gut sichtbare Aktion „Masterbutton verschieben“. Darunter steht unabhängig von der Tooltip-Einstellung: „Mit rechter Maustaste jederzeit außerhalb des Kampfes verschiebbar. Für Linksziehen den Bearbeitungsmodus starten.“
- Die Aktion startet den Modus außerhalb des Kampfes und schließt die Einstellungen, damit sie den Button nicht verdecken.
- Ein separater Verschiebegriff am umrandeten Masterbutton zeigt „Mit linker Maustaste ziehen“. Seine Trefferfläche bleibt auch bei kleinem Masterbutton mindestens 28 × 28 UI-Einheiten groß. Diese Größe ist ein Entwurfsvorschlag.
- Beim Überfahren des Griffs und während des Ziehens erscheint der native WoW-Verschiebecursor. Er bleibt während des Drags auch außerhalb des Griffs erhalten. Beim Verlassen ohne Drag, beim Drag-Ende, Abbruch und Modusende wird der eigene Cursorzustand aufgelöst.
- Eine kleine, separate Leiste bietet „Fertig“ und „Abbrechen“. „Fertig“ übernimmt die Position; „Abbrechen“ bzw. Escape stellt die Ausgangsposition wieder her. Bis zur Übernahme ist die Position eine Vorschau. Ein zusätzlicher Button „Position zurücksetzen“ stellt die Standardposition als Vorschau her. Diese Abschluss-/Reset-Aktionen sind Vorschläge innerhalb der gewählten Richtung.
- Bei ausgeblendetem Masterbutton erklärt der Einstieg, dass zuerst „Masterbutton anzeigen“ aktiviert werden muss. Die gespeicherte Sichtbarkeit wird nicht still verändert.
- Der Modus gilt nur für die aktuelle Sitzung. Nach Login/Reload gilt der normale Zustand; vorhandene gespeicherte Positionen bleiben kompatibel.
- Außerhalb des Modus bleibt Rechtsziehen unverändert möglich. Im Modus verwenden beide Drag-Wege dieselbe Vorschau-/Abschlusslogik; Rechtsziehen wird nicht entfernt. Linksklick auf den eigentlichen Zielbutton und Hotkeys behalten ihre bisherige Funktion. Linksziehen erfolgt ausschließlich über den Griff und löst kein Zielmakro aus.

## Native Cursor: geprüft

Verwendet wird `SetCursor("UI_MOVE_CURSOR")`, beim Aufräumen `SetCursor(nil)`. Kein eigener Cursor und keine neue Textur erforderlich.

Das ist in den lokal synchronisierten Blizzard-Quellen belegt:

- Retail: Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.lua, PanelDragBarMixin:UpdateCursor, um Zeile 1495.
- Forever: derselbe Mixin in Mainline/SharedUIPanelTemplates.lua, um Zeile 1627.
- Classic und Classic Era: Blizzard_SharedXML/Classic/SharedUIPanelTemplates.lua, PanelDragBarMixin:OnDragStart, um Zeile 1060.
- Außerdem verwenden Blizzards PTRFeedback-Frames in allen vier Quellzweigen `Interface\\CURSOR\\UI-Cursor-Move.blp` mit SetCursor.
- Der WoW-MCP weist die Move-Textur im gemeinsamen Dateiverzeichnis mit FileDataID 532327 und die Unable-Variante mit 1094569 nach. Die semantische Cursor-ID wird gegenüber festen FileDataIDs bevorzugt. Der gemeinsame Dateikatalog allein beweist keine Verfügbarkeit in jeder historischen Clientversion.

Die Moduslogik soll eigene Ereignishandler verwenden; nicht den vollständigen Blizzard-Mixin ungeprüft übernehmen, dessen Schnittstellen zwischen den Zweigen variieren. Der Zeiger wird nur über dem Griff bzw. während eines aktiven Drags beansprucht, nicht global über sämtlicher UI. Die tatsächliche Anzeige muss vor Veröffentlichung in den unterstützten Clients geprüft werden.

## Kampf, Sicherheit und Umfang

Einstieg im Kampf deaktivieren bzw. mit „Im Kampf nicht möglich“ erklären. Beim Kampfstart die Bearbeitung beenden, Cursor freigeben und keine geschützten Frame-Mutationen ausführen. Einen noch laufenden Drag und erforderliche Positionsbereinigung nach dem Kampf kontrolliert abschließen; keine automatische Wiederöffnung des Modus. Die letzte losgelassene Vorschauposition soll übernommen werden, damit keine überraschende Rückbewegung entsteht. Dies ist ein Umsetzungsvorschlag; das Verhalten beim Kampfübergang benötigt echte Client-Prüfung.

Griff und Bearbeitungsleiste von den geschützten Zielaktionen trennen. SecureActionButton-OnClick nicht ersetzen. Insbesondere nicht vorübergehend Zielattribute entfernen, die im Kampf nicht wiederhergestellt werden könnten. Sichere Sichtbarkeit und Hit-Testing des Griffs am Kampfübergang müssen bei der Implementierung geprüft werden; gewöhnliches Hide/Show geschützter Frames im Kampf ist keine zulässige Annahme.

Eine gemeinsame Implementierung für Retail, Era, TBC, Mists und Forever; klassische und moderne Darstellung; native Optionen und ältere Fallback-Einstellungen. Neue Texte in den sechs vorhandenen Sprachen. Keine Änderung an Questzielwahl, Makros, Hotkeys, Questie oder RestedXP.

Einmalige Onboarding-Hinweise sind für diese Änderung nicht erforderlich: sichtbarer Optionseinstieg und Modusanleitung liefern die primäre Erklärung ohne zusätzliche Popups.

## Geplante Änderungen und Abnahme

Master.lua: Modus-/Drag-Zustand, Griff, Cursor und Positionsübernahme. UI.lua: Einstieg in beiden Optionsoberflächen. Main.lua: Combat-/Abschlussintegration soweit nötig. Locale.lua: Texte. Bestehende Lua-Tests und Mock: gezielte Verhaltenstests für die neue Bedienung und unverändertes Rechtsziehen.

Automatisch prüfen: fünf Flavors × zwei Darstellungen; Tooltips aus; wiederholter Moduseinstieg ohne doppelte Frames; Vorschau, Übernehmen, Abbrechen und Reset; gespeicherte Position; Cursor auf Hover/Drag/Leave/Ende; kein Makro durch Griff; Combat-Sperre und verzögerte Bereinigung; weiterhin funktionierendes Rechtsziehen und Hotkeys. Die vorhandene Testsuite muss weiterhin vollständig bestehen.

Im echten Spiel prüfen: native Mausereignisse und Cursor in jedem Flavor; Combat während Drag; UI-Skalierung/Bildschirmrand; sehr kleine Buttons; Zugriff nach Schließen der Einstellungen; Questie/RestedXP; überlagernde Fenster; kein Taint. Besonders TBC und Mists separat prüfen: Der MCP bietet dafür keinen eigenständigen aktuellen Clientprozess und verwendet gemeinsame Classic-Referenzen.

Erfolg: Ein Spieler findet die Aktion ohne Tooltip oder externe Anleitung und kann den Masterbutton beim ersten Versuch per Linksziehen über den Griff positionieren. Gewohnte Nutzer können weiterhin rechtsziehen.
