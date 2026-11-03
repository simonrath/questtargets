# Resize-Griff am Questfenster

Unten rechts befindet sich ein nativer SizeGrabber. Linksklick und Ziehen nutzt
StartSizing(BOTTOMRIGHT); die Grenzen sind 282–700 UI-Einheiten breit und
198–900 hoch. Die vorhandene Menü-Skalierung bleibt unabhängig davon erhalten.
Beim Loslassen werden Größe und aktuelle Bildschirmposition gespeichert. Alte
Profile ohne Größenangaben behalten 282×354.

Zwanzig sichere Zeilen werden außerhalb des Kampfes vorab angelegt. Je nach
Fensterhöhe sind 2–20 sichtbar; Breite der Questtexte, Scrollbereich und untere
Buttons passen sich an. Der Griff hat neben Feedback einen reservierten Platz.
Im Transparenzmodus wird er bei Mouseover sichtbar.

Combat-Guards verhindern StartSizing, Layout-/Zeilenänderungen und
StopMovingOrSizing aus Addon-Code im Kampf. Ein Kampfbeginn während des Ziehens
merkt den Abschluss vor; PLAYER_REGEN_ENABLED beendet und speichert ihn sicher.
Der normale Daten-Refresh verändert während des Ziehens keine Fenstergeometrie.

XERJ qtrefs lieferte Questie/Libs/AceGUI-3.0/widgets/AceGUIContainer-Frame.lua
(SizerSE_OnMouseDown) als Ansatz. Keine Implementierung kopiert. WoW MCP bestätigte
StartSizing und SetResizeBounds für Forever; die nativen Griff-Texturen wurden
über wow_file_search geprüft (386864/386862/386863). Tests simulieren Größe,
Zeilenkapazität, Speichern, Wiederherstellen, ungültige Größen und Kampfunterbrechung.
Ein visueller Test des echten Maus-Resizings im Client steht noch aus.
