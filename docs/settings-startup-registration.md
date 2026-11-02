# Optionskategorie beim Login registrieren

Ursache: `UI.Settings` registrierte die Kategorie und öffnete sie im selben
Aufruf. Ohne Aufruf des Minimap-/Menü-Shortcuts fehlte Quest Targets daher in
Blizzards Addon-Optionen.

`UI.RegisterSettings` übernimmt jetzt ausschließlich die Registrierung.
`PLAYER_LOGIN` ruft sie nach Initialisierung der gespeicherten Einstellungen auf.
Nach Kampfende und bei späteren ADDON_LOADED-Ereignissen kann die Registrierung
nachgeholt werden. Bereits registrierte Kategorien werden wiederverwendet.
Der Canvas-Fallback startet mit einem versteckten Panel. Erst `UI.Settings`
öffnet die Kategorie auf ausdrücklichen Benutzerklick.

Regressionen: Login ohne Öffnen und ohne doppelte Registrierung für alle fünf
nativen Flavor-Konfigurationen; Canvas-Fallback; Login während Kampf;
verspätet verfügbare Settings-API; weiterhin Öffnen über den eigenen Shortcut.
Prüfung in Lua-Mocks, kein Test in laufenden Clients.

Referenzsuche: XERJ `qtproject` führt zu `UI.lua:nativeSettings`; der Peer-Treffer
in `RXPGuides/libs/compatibility.lua:33` ist nur ein Kompatibilitäts-Stub und
keine brauchbare Startreferenz. Ergänzend wurde mit dem WoW MCP der native
Forever-Code in `Blizzard_Settings_Shared/Blizzard_Settings.lua:134,154`
geprüft: Kategorie registrieren und Kategorie öffnen sind getrennte Einstiege.
Kein fremder Implementierungscode wurde übernommen.
