# Questie-Tracker-Optionen

Die Anzeige unserer Questie-Tracker-Buttons ist wieder schaltbar. Standard ist
aktiv; ein gespeichertes `false` bleibt beim Login erhalten. Die Einstellung
beeinflusst weder den Masterbutton noch die native Questliste oder RestedXP.
Beim Abschalten werden außerhalb des Kampfes unsere Buttons ausgeblendet und
ihre Makroattribute geleert. Es werden keine Questie-Methoden ersetzt oder Hooks
installiert; ein Reload ist nicht erforderlich.

`questieTrackerOffset` steuert den horizontalen Abstand in UI-Pixeln (-40 bis 80).
Standard ist 35 px für neue Einstellungen; 0 erhält die frühere Position. Positive Werte vergrößern den Abstand nach links,
negative Werte verschieben die Buttons nach rechts. Die Berechnung berücksichtigt
Questies effektive UI-Skalierung und verankert unsere Buttons weiterhin nur an
UIParent. Im Kampf verhindert der vorhandene Sync-Guard Positions-/Attributänderungen;
gespeicherte Abstandsänderungen werden beim nächsten sicheren Refresh übernommen.

Native Optionen in allen fünf Flavors sowie der Canvas-Fallback enthalten beide
Steuerelemente. Ohne geladenes Questie ist die Option deaktiviert; der Abstandsregler
ist zusätzlich bei ausgeschalteten Buttons deaktiviert.

XERJ-Referenzsuche `qtrefs: questieTrackerButtons` ergab keinen passenden Peer-Treffer.
Grundlage sind der vorhandene eigene QuestieTracker.Sync-Pfad und die vorhandene
RestedXP-Option mit AddModifyPredicate. Keine AddShownPredicate-Callbacks und keine
Änderung an fremden Secure-Frames. Die Lua-Regressionen prüfen Anzeige, Abstand,
Abschalten, Speichern beim Login sowie native Optionen in allen fünf Konfigurationen.
Ein Test im laufenden Spiel steht noch aus.
