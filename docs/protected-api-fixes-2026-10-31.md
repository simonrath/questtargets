# Korrektur der vier Audit-Funde

Der Arbeitsstand korrigiert die vier konkreten Risiken aus der
[Quellcodeprüfung](protected-api-audit-2026-10-31.md). Die damaligen Befunde
bleiben als Ausgangszustand dokumentiert.

1. `UI.OpenQuest` prüft den Kampf vor jedem nativen Questlog-Einstieg.
   Ein Rechtsklick öffnet das Questlog außerhalb des Kampfes weiterhin direkt.
   Im Kampf wird die Aktion verworfen; es erscheint später kein unerwartetes Fenster.
2. Die Optionsaktualisierung verwendet `SettingsInbound.RepairDisplay`, sofern
   verfügbar. Der direkte Aufruf von `SettingsPanel:RepairDisplay` entfällt.
3. Breite, Höhe und moderne Skalierung verwenden Modify-Predicates und den
   Darstellungs-Initializer als Parent. Dadurch aktualisiert die native
   Elternbenachrichtigung die Verfügbarkeit beim Darstellungswechsel. Das eigene
   Beschriftungsfeld implementiert dazu `EvaluateState`. Unpassende Einstellungen
   sind grau statt ausgeblendet; gespeicherte Werte bleiben erhalten. Keine
   AddShownPredicate-Callbacks mehr in der globalen Optionssuche.
4. Kartentabellen werden ausschließlich als numerische Daten gelesen, ohne
   `loadstring`, `setfenv` oder Ausführung eines Chunks. Unterstützt werden die
   echten QuestieDB-Strings mit Zeilenkommentaren, Null-Sentinels und Overrides
   sowie bereits geladene Tabellen. Ungültige Strings liefern eine leere Tabelle.

Die SecureActionButtons und ihre außerhalb des Kampfes gesetzten Attribute
bleiben bestehen. WoW benötigt diesen vorgesehenen Secure-Pfad für Zielwechsel
per Hardware-Klick oder Tastendruck. Ein vollständiger Verzicht auf geschützte
Mechanismen würde die Zielauswahl zerstören. Die Korrektur entfernt riskante
Aufrufpfade, nicht den dafür vorgesehenen Secure-Mechanismus.

## Referenzen und Prüfung

XERJ: `qtproject` liefert `UI.OpenQuest`; `qtrefs` liefert Questies
`Modules/Libs/QuestieCombatQueue.lua` als Beispiel für die vorgelagerte
Kampfsperre. Kein Peer-Treffer für `SettingsInbound RepairDisplay
AddShownPredicate`; hierfür wurde der native WoW-MCP-Quellcode verwendet.
Kein fremder Implementierungscode wurde übernommen.

Native Forever-Quellen: `Blizzard_SettingsInbound.lua:156–159`,
`Blizzard_SettingControls.lua:120–141, 311–320, 370–371, 536–543`,
`Blizzard_SettingsList.lua:106–137`. Der Inbound-Delegate kapselt den
Panel-Einstieg; Parent-Initializer liefern die native Änderungsbenachrichtigung.
Die anderen vier nativen UI-Quellstände sind im MCP nicht synchronisiert.

Regressionstests prüfen den Kampf-Rechtsklick, den Inbound-Aufruf statt des
direkten Panel-Aufrufs, die Aktivierungsbedingungen und Parent-Verknüpfung
für alle fünf Flavor-Konfigurationen sowie unveränderte Kartendaten aller
vier gepinnten QuestieDB-v1.0.9-Pakete. Manipulierte Kartentexte werden abgewiesen.
Die vollständige Lua-/Paket-Testsuite läuft ohne laufenden Spielclient.

Der MCP-Linter meldet in den beiden geänderten Laufzeitdateien für alle fünf
Flavors keine Fehler. Konservative Frame-/Secure- und API-Warnungen bleiben:
insbesondere verfolgt der Linter zentrale Kampf-Guards nicht über alle Aufrufer.
Dies ist weder eine Garantie für vollständige Taint-Freiheit noch ein Nachweis,
dass der frühere intermittierende ActionBar-Fehler damit endgültig behoben ist.
