# Standard-Minimap-Button und neue Vorgaben

Der bisherige eigene QuestTargetsMinimapButton wurde durch einen registrierten
LibDBIcon-1.0-Button ersetzt. Ein LibDataBroker-Launcher namens QuestTargets
stellt Icon, Tooltip und Klickaktionen bereit. Links toggelt das Questfenster,
rechts öffnet die Optionen. LibDBIcon übernimmt Rahmen, Dragging, Kartenform und
die für Minimap-Sammler sichtbare Registrierung. Fremde Button-Scripts werden
nicht ersetzt; kein eigener Positions-/Drag-Loop bleibt bestehen.

LibStub, CallbackHandler-1.0, LibDataBroker-1.1 und LibDBIcon-1.0 werden unverändert
eingebettet, vor dem eigenen Code geladen und vollständig samt Hinweisen und
Lizenzen verpackt. Bezugsstand und SHA-256-Werte stehen in minimap-library-pins.json.
Referenzsuche über XERJ führte zu Questies docs/minimap-status-indicator.md und der
dort beschriebenen LibDBIcon-Registrierung. Eigene Adapterimplementierung gemäß
https://www.wowace.com/projects/libdbicon-1-0 (Register, GetMinimapButton, Show/Hide).

Neue Positionen werden unter minimap.minimapPos in Grad gespeichert. Bestehende
minimapAngle-Werte in Radiant sowie minimapHidden werden beim ersten Umstieg
übernommen. Optionen verwenden die Library-Methoden und speichern minimap.hide.
Der Titel der Optionen liest Version aus den installierten Addon-Metadaten;
er enthält daher auch den Preview-Zusatz des Testpakets.
Die Kategorie und ihr Sidebar-Name bleiben dabei „Quest Targets“. Da Blizzard
denselben Kategorienamen für Liste und Überschrift benutzt, setzt ein
hooksecurefunc-Posthook auf DisplayCategory ausschließlich den sichtbaren
Header-Text unserer ausgewählten Kategorie. Fremde Kategorien werden nicht
geändert. Referenz: WoW MCP Forever, Blizzard_SettingsPanel.lua:874–908.
Keine dynamischen GetName-Callbacks in der gemeinsamen Kategorienregistrierung.

Für neue Einstellungen gelten masterAppearance=modern und questieTrackerOffset=35.
Vorhandene klassische Auswahl und individuelle Abstände bleiben erhalten.

Tests prüfen Library-Registrierungsvertrag, Laden der echten mitgelieferten
Libraries, Klickaktionen, Sichtbarkeit, Positionsmigration, Metadaten-Titel,
Defaults und Erhalt vorhandener Werte sowie die Libraries und Lizenzen im ZIP.
Die eigentliche Anzeige bzw. Sammlung durch fremde Minimap-Addons muss im Client
getestet werden; die Lua-Tests ersetzen keinen solchen Kompatibilitätstest.
