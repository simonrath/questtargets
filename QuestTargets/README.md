# Quest Targets — 1.0.11

Für **WoW Forever Beta**, Interface **160001**. Anklickbare Questmobs mit
Fortschritt, jetzt mit **QuestieDB v1.0.1 (Classic/Vanilla)** als zusätzlicher
Datenquelle. Die Oberfläche verwendet Blizzard-ModernUI; Minikarte und optionaler
moderner Masterbutton zeigen den ausgewählten Quest-Kompass.

## Installation / Update

Aus `QuestTargets-1.0.11.zip` den Ordner **QuestTargets** nach
`Interface/AddOns` des Forever-Clients kopieren. Vorhandene QuestTargets-Dateien
ersetzen und WoW vollständig neu starten. Der Release-Build enthält nur das
Addon; QuestieDB kann separat als optionaler Datenanbieter installiert werden.

**/qt** öffnet oder schließt das Fenster. Oben sollte **QuestieDB · Classic**
stehen. Ohne geladenen Anbieter steht dort ein entsprechender Hinweis;
Questtexte und die bisherige Umgebungserkennung funktionieren weiter.

QuestieDB muss zum Forever-Client und zu Classic-Daten passen. Verwende nicht
ungeprüft eine Mists-/TBC-Datenbank im selben Client.

## Was automatisch erkannt wird

- **Killquests:** konkrete NPCs aus den Questzielen der Datenbank.
- **Gemeinsame Killziele:** sämtliche realen NPCs einer hinterlegten
  Kill-Credit-Gruppe; unsichtbare Platzhalter-NPCs werden nicht hinzugefügt.
- **Sammelquests:** alle hinterlegten NPC-Dropquellen des benötigten Gegenstands.
  Auch Beute aus Behältergegenständen wird über deren NPC-Quellen aufgelöst.
  Händler, Questgeber und anklickbare Weltobjekte werden nicht als Killziele
  ausgegeben.
- **Quests mit Vorstufen-Gegenständen:** ein allgemeiner Resolver verknüpft
  QuestieDB-Quellgegenstände mit dem offenen Itemziel, wenn genau ein
  Datenbank-Itemziel und ein eindeutiges offenes Itemziel vorliegen. Bei
  „Zwergen-Buddelei“ zählen dadurch Buddler und Gutachter von Bael'dun als
  Quellen der Ausgrabungsleiterhacke. Der Inventarbestand schränkt diese
  Ziele nicht ein.
- **Mehrere Mobarten:** erscheinen gleichzeitig als gültige Ziele für dasselbe
  Questziel. Ein weiterer automatisch beobachteter Mob ergänzt die Menge und
  verdrängt keine bereits bekannten Datenbankziele.
- **Lokalisierung:** Mobnamen kommen aus der aktiven Clientsprache der Datenbank.
- **Fortschritt:** kommt weiterhin aus der laufenden Quest-API. Wenn das Ziel
  abgeschlossen ist, verschwinden alle nur dafür benötigten Mobarten gemeinsam.

Bei bekannten Datenbankquests ist **kein vorheriges Auswählen, Mouseover,
Besuchen des Mobs oder manuelles Zuordnen nötig**. Zum Beispiel enthält diese
Datenbank für „Wölfe an der Grenze“ vier NPC-Quellen für Zähes Wolfsfleisch.

Für die Zuordnung werden Quest-ID, lokalisierter Questtitel, Zieltyp und
Zielbezeichnung bzw. explizite Zielpositionen aus der Datenbank abgeglichen.
Die Position in einer Liste bereits gefilterter, unerledigter Ziele wird niemals
als Datenbankindex verwendet. Bei nur einem Ziel desselben Typs auf beiden
Seiten ist auch eine abweichende beschreibende Zielbezeichnung zuordenbar.
Mehrdeutige Zuordnungen werden ausgelassen.

## Grenzen der Classic-Daten in Forever

QuestieDB veröffentlicht derzeit keinen eigenen Forever-Datenbestand. Das Paket
nutzt ausdrücklich **Classic-Daten als Ausgangsbasis**. Neue/geänderte Forever-
Quests können fehlen; gleich benannte, inhaltlich geänderte Quests können trotz
Abgleich veraltete Mobzuordnungen enthalten. Vollständige Forever-Abdeckung ist
nicht zugesagt.

Für unbekannte oder zusätzliche Ziele bleibt die automatische Client-Erkennung
aktiv: Mit sichtbaren gegnerischen Namensplaketten liest das Addon die lesbaren
Questinformationen der Mobs und vergleicht Questtitel und konkretes Ziel mit
deinem Questlog. Es verändert dabei weder dein Target noch die sichtbare
Tooltipanzeige. Diese Ergänzung ist auf die vom Client bereitgestellte Umgebung
begrenzt. Ohne Daten bleibt das Ziel unaufgelöst; es gibt keine manuelle
Zuordnung als Ersatz.

Die Datenbank wird lokal geladen. Es gibt keine HTTP-Abfragen aus dem Spiel
und keinen laufenden Desktop-Helfer. Das Build-Skript lädt die festgelegte
QuestieDB-Veröffentlichung außerhalb des Spiels und prüft deren SHA256.
Datenbank-Aktualisierungen werden mit einem neuen Paket ausgeliefert.

Die Resolver-Kette führt direkte QuestieDB-Ziele, eindeutige Vorstufen-Quellen
und automatisch erkannte Forever-Mobs zu den gültigen Namen pro offenem
Questziel zusammen. Bekannte QuestieDB-NPCs mit Spawn-Daten werden auf die
aktuelle Zone beschränkt; bei fehlenden Zoneninformationen bleiben sie als
Rückfall gültig. Die Zone wird bei einem Zonenwechsel neu geprüft. Die Kette
enthält keine fest codierten Quest-IDs. Wenn eine
Quest mehrere mögliche Itemziele hat, wird `requiredSourceItems` nicht blind
allen Zielen zugeordnet.

## Bedienung

- **Mob anklicken:** nach exaktem Namen anvisieren, ohne Angriff oder Zauber.
- **Rechtsklick auf eine Quest:** öffnet diese im nativen Questlog.
- **Alle Quests / Verfolgte Quests:** angezeigte Quests filtern.
- **Maus über einen Eintrag:** Einzelziele und Herkunft der Mobzuordnung ansehen, wenn Tooltips in den Einstellungen aktiviert sind.
- **Pfeile unten:** weitere Ziele anzeigen, sechs Einträge pro Seite.
- **Titelleiste ziehen:** Fenster außerhalb des Kampfes verschieben.
- **Einstellungen:** öffnet die native WoW-Optionsseite unter AddOns → Quest Targets. Dort lassen sich Tooltips, Minikarten-Button, Markierung, Masterbutton und Menügröße einstellen.
- **Minikarten-Button:** sitzt direkt am Rand der Minikarte und lässt sich dort mit der linken Maustaste verschieben. Linksklick öffnet das Questmenü, Rechtsklick die Einstellungen. Er zeigt den roten Quest-Kompass.
- **Hotkey:** auf der AddOn-Optionsseite „Questziel anvisieren“ anklicken und eine Taste oder Kombination wie STRG+F drücken. Der Hotkey betätigt den Masterbutton.
- **Masterbutton bearbeiten:** Die Unterseite der nativen Addon-Einstellungen bietet getrennte Breiten- und Höhenskalen (X/Y) und einen frei wählbaren, auch leeren Schriftzug. Der Masterbutton bleibt frei verschiebbar.
- **Sprache:** In den nativen Addon-Einstellungen Englisch, Deutsch, Spanisch, Französisch, Türkisch oder vereinfachtes Chinesisch wählen. Die Texte wechseln sofort ohne Neuladen der Oberfläche. Ohne Auswahl folgt das Addon der Clientsprache; für Türkisch ist eine manuelle Auswahl nötig. QuestieDB verwendet weiterhin die Clientsprache für NPC- und Questnamen.
- **/qt reset:** Fensterposition zurücksetzen.
- **/qt rescan:** den Cache eigener automatischer Beobachtungen erneuern.
  QuestieDB bleibt dabei unverändert. `/qt clear` ist ein Alias.
- **/qt help** oder **?**: Hilfe im Chat.

Jede Quest erscheint genau einmal als Button mit ihrem Questnamen. Alle Mobarten
aller offenen Unterziele gehören zu diesem Button. Fortschritt wird pro Unterziel
nur einmal gezählt, unabhängig von der Anzahl möglicher Mobarten. Im Tooltip
stehen die Unterziele und alle bekannten Mobarten. Erledigte Unterziele tragen
keine Ziele mehr bei; dieselbe Mobart kann weiterhin für andere offene Ziele gelten.
Auch eine Quest mit noch unbekannten Mobarten bleibt als einzelner Button sichtbar.

**Aktualisieren** oder `/qt refresh` liest Quests und Verfolgung erneut ein.
Questannahme, Abgabe, Entfernung, Fortschritt und Änderungen der Verfolgung lösen
die Aktualisierung automatisch aus. Im Filter „Verfolgte Quests“ werden nur die
aktuell verfolgten Quests angezeigt. Im Kampf wird die Aktualisierung vorgemerkt
und unmittelbar nach Kampfende durchgeführt.

## Zielauswahl, Markierungen und Kampf

Außerhalb des Kampfes prüft jeder Linksklick die aktuell sichtbaren gegnerischen
Namensplaketten. Lebende angreifbare NPCs mit passenden Namen bilden einen
Zyklus, einschließlich aller hinterlegten alternativen Mobarten für dieselben
Questziele. Ist bereits ein Kandidat ausgewählt, folgt der nächste; nach dem
letzten beginnt die Liste wieder vorne. Bei nur einem Kandidaten bleibt dieser
ausgewählt. Ohne passendes aktuelles Target beginnt der Zyklus am ersten Eintrag.
Die Reihenfolge ist anhand der NPC-GUID stabil, **nicht nach Entfernung sortiert**.
Tote Ziele, Spieler und freundliche Einheiten werden ausgeschlossen. Die Tokens
werden bei jedem Klick neu ermittelt, damit verschwundene Namensplaketten nicht
als gespeicherte Ziele weiterverwendet werden.

Ohne erkennbare Kandidaten und im Kampf verwenden die vorbereiteten
SecureActionButtons weiterhin die Namensauswahl für die Mobarten der angeklickten Quest. Beispiel mit einer Mobart:

```text
/cleartarget
/targetexact [noexists] MOBNAME
/cleartarget [dead]
/tm [exists,harm,nodead] !8
```

Die Namensauswahl probiert Alternativen nacheinander bis zu einem lebenden Treffer.
Bei sehr großen Namenslisten begrenzt das Makrolimit diese Ausweichfunktion; die
Rotation sichtbarer Ziele außerhalb des Kampfes berücksichtigt weiterhin alle
Mobarten der Quest.

Bei dieser Namensauswahl bleibt ohne Treffer oder bei einem toten Treffer kein
Target ausgewählt; ein Durchschalten ist dabei nicht garantiert. Erreichbarkeit,
Sichtlinie, Entfernung, fremde Belegung und gleichnamige, aber nicht benötigte
NPCs werden nicht zuverlässig unterschieden.

**Einstellungen** im Fenster oder `/qt settings` öffnet die native ModernUI-Seite.
Automatisches Markieren ist standardmäßig eingeschaltet, Symbol **Totenkopf**.
Zur Wahl stehen Stern, Kreis, Diamant, Dreieck, Mond, Quadrat, Kreuz und Totenkopf.
Die Auswahl wird pro Charakter gespeichert. Der Marker wird beim Zielklick über
den nativen `/tm`-Befehl gesetzt; `!` verhindert das Entfernen desselben Symbols
bei erneutem Klick. Manuelle Zielwechsel außerhalb des Addons lösen keine
Markierung aus. Gruppen-/Schlachtzugsrechte gelten weiterhin. Das gleiche Symbol
kann nur auf einem Ziel liegen und wandert bei der Auswahl weiter. Ausschalten
beendet zukünftiges automatisches Markieren; vorhandene Marker bleiben bestehen.
Bei Quest-NPCs bleibt die erste Zielsuche ohne Markierung, wenn zuvor ein
freundlicher Spieler ausgewählt war. Ein weiterer Klick auf den nun gültigen
Quest-NPC setzt das Symbol über das sichere Makro, ohne das Ziel abzuwählen.

Im Kampf bleiben vorbereitete Zielbuttons benutzbar, soweit der Client die Aktion
erlaubt. Neue Ziele, Änderungen am Fenster und die Umgebungserkennung warten bis
Kampfende. Das gezielte Durchschalten ist deshalb auf außerhalb des Kampfes
beschränkt. Änderungen in bereits geöffneten Einstellungen wirken nach Kampfende.
Auch nach einem `/reload` im Kampf wird das Fenster erst danach erstellt.

## Prüfung und Build

```text
python -m unittest discover -s tests -p "test_quest_targets*.py" -v
```

Die Verhaltenstests benötigen `lupa`. Die zusätzlichen Integrationstests benötigen
`cbor2` und die festgelegte QuestieDB-ZIP im Download-Cache des Build-Skripts.
Sie laden die echten, unveränderten Lua-Dateien und Daten aus QuestieDB v1.0.1;
nur die clientseitige CBOR/Base64/Dekompressionsschnittstelle wird nachgebildet.
Geprüft werden unter anderem reale deutsche Kill-/Sammelquests, mehrere
Dropquellen, gemeinsame Zähler, verschobene erledigte Teilziele, Rotation mit
alternativen Mobarten, ein Button pro Quest, eindeutige Fortschrittszählung,
Verfolgungsänderungen, manuelles Aktualisieren, Tokenwechsel, Markereinstellungen
und Kampfsperren.

```powershell
./tools/package_quest_targets.ps1
./tools/package_quest_targets.ps1 -AddonOnly
```

Das kombinierte Paket enthält zwei separate Addon-Ordner. Der QuestieDB-Loader
bekommt zusätzlich Interface 160001, einen nativen IconAtlas und eine generische
TOC; die Daten und Lua-Dateien des Anbieters bleiben unverändert. Details und
Urheberzuordnung: [QUESTIEDB-NOTICE.md](QUESTIEDB-NOTICE.md).

**Noch offen:** echter Forever-Client-Test, einschließlich der Verfügbarkeit von
`C_EncodingUtil`, der Provider-Ladereihenfolge, Combat-Taint und abweichender
Forever-Questinhalte. Die Loader-Anpassung ist kein offizieller Forever-Support
von QuestieDB.

## Quellen

- [QuestieDB-Veröffentlichung v1.0.1](https://github.com/Questie/QuestieDB/releases/tag/v1.0.1)
- [Öffentliche QuestieDB-API](https://github.com/Questie/QuestieDB/blob/master/docs/api.md)
- [Blizzard Quest-API](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua)
- [Blizzard Tooltip-API](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua)
- [Blizzard Zielmarker-Befehl mit !-Syntax](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua)

## Masterbutton und Fensterdarstellung

Der separate native Button **Questziel anvisieren** (140 × 22) berücksichtigt
alle aktiven Quests mit offenen Unterzielen sowie die NPCs von Quests, die der
Client als abgabebereit meldet, auch bei nicht verfolgten Quests.
Er funktioniert unabhängig vom Filter und vom ausgeblendeten Questmenü.
Der erste Klick reserviert im begrenzten Makro Platz für einen gültigen
Abgabe-NPC, auch wenn viele Mobarten offen sind. Mobnamen stehen vorher und
haben Vorrang. Weitere Klicks wechseln durch die Kandidaten. Die Reihenfolge
ist stabil, nicht nach Entfernung sortiert.
Die bestehenden Grenzen gelten: sichtbare Namensplaketten für die Rotation,
außerhalb des Kampfes; sonst begrenzte Namensauswahl. Marker-Einstellungen gelten
auch für den Masterbutton.

Mit gedrückter **rechter Maustaste ziehen**, um den Masterbutton außerhalb des
Kampfes frei zu verschieben. Die Position bleibt pro Charakter gespeichert.
Unter **/qt settings** lassen sich Masterbutton und Questmenü unabhängig ein-
und ausblenden. Dort lässt sich die Menügröße mit Minus/Plus in Zehn-Prozent-
Schritten zwischen 50 und 150 Prozent verändern. Der Masterbutton bleibt dabei
normal groß. Änderungen an geschützten Fenstern werden im Kampf vorgemerkt.
Auch bei ausgeblendeten Fenstern bleiben die Einstellungen über /qt settings
und das Questmenü über /qt erreichbar.

## Korrektur 0.6.2: Forever-Namensplaketten

Die Namensplaketten-Erkennung verwendet jetzt `GetUnit()` beziehungsweise
`unitToken` des Forever-Clients. Das frühere Feld `namePlateUnitToken` bleibt
als Rückfall für ältere Frames unterstützt. Ein freigegebener moderner Frame
wird nicht über veraltete Felder weiterverwendet. Die Korrektur gilt sowohl
für die automatische Mob-Erkennung als auch für Questbuttons und Masterbutton.

Ohne verwertbare Namensplaketten werden lange Namenslisten außerhalb des Kampfes
mit weiteren Klicks abschnittsweise durchsucht. Dadurch gehen Mobarten jenseits
des Makrolimits nicht dauerhaft verloren. Ein einzelner Klick kann ohne sichtbare
Namensplaketten weiterhin nicht beliebig viele Mobarten prüfen. Im Kampf bleibt
nur die vorbereitete Namensauswahl aktiv.

Regressionstests bilden das Forever-Frameformat, den Wechsel A → B → A für beide
Buttonarten, freigegebene Frames und vollständige Abdeckung langer Namenslisten
nach. Sie ersetzen keinen Test der geschützten Zielbefehle im Spiel.

Quellabgleich: [Forever NamePlateBaseMixin](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlateBase.lua).

## Hybrid-Zielauswahl ab 0.6.2

Questbuttons und Masterbutton verwenden dieselbe Logik:
1. Kein lebendes passendes Ziel ausgewählt: Wenn eine gültige Namensplakette
   sichtbar ist, wird ihr konkreter Unit-Token sofort mit `/target` gewählt.
   Sonst verwendet der Button `/targetexact` nach Namen; das erlaubt die Auswahl
   auch jenseits der Namensplaketten-Sichtweite, soweit der Client sie erlaubt.
2. Passendes Ziel bereits ausgewählt: zum nächsten gültigen lebenden Gegner mit
   sichtbarer Namensplakette wechseln. Ist das aktuelle Ziel noch außerhalb der
   Namensplaketten-Sichtweite, beginnt der Zyklus mit dem ersten sichtbaren Kandidaten.
3. Keine verwertbaren Namensplaketten: Ein vorhandenes gültiges Ziel bleibt
   erhalten; ohne gültiges Ziel wird erneut nach Namen gesucht. Lange Listen
   werden außerhalb des Kampfes mit weiteren Klicks abschnittsweise durchsucht.

Im Kampf bleibt die vorbereitete Namenssuche aktiv. Marker-Einstellungen gelten
für beide Wege. Die Hybridlogik vergrößert nicht die vom Client erlaubte Suchweite.

## Korrektur 0.6.3: aktuelles Ziel behalten

Ein gültiges aktuelles Ziel bleibt erhalten, wenn keine sichtbare Alternative
verfügbar ist. Der Wechsel per Namensplakette löscht das vorherige Ziel nicht
mehr vorab; verschwindet der Kandidat vor der Ausführung, bleibt das bisherige
Ziel bestehen. Dies gilt für Questbuttons und Masterbutton, mit und ohne Marker.
Im Kampf bewahrt die vorbereitete Namenssuche jedes lebende feindliche aktuelle
Ziel, da dessen Questzuordnung dort nicht zuverlässig dynamisch geprüft werden
kann. Für eine neue Namenssuche im Kampf muss es zuvor manuell abgewählt werden.

## Korrektur 0.6.4: kurze vollständige Makros

Nach gemeldeten abgeschnittenen Makrooptionen im Forever-Client begrenzt der
Generator alle Zielmakros konservativ auf 255 Byte statt bisher 1.000 Byte.
Er teilt lange Namenslisten nur zwischen vollständigen Zielbefehlen auf;
weitere Klicks durchsuchen die folgenden Abschnitte. NPC-Namen einschließlich
UTF-8-Zeichen bleiben vollständig. Bei außergewöhnlich langen Namen wird eine
kurze Einzelabfrage verwendet; passt der optionale Marker nicht mehr hinein,
entfällt er für diese Einzelabfrage. Die Erhaltung eines vorhandenen Ziels und
die Namensplaketten-Rotation bleiben erhalten.

Ein Regressionstest prüft 180 aufeinanderfolgende Klicks ohne Ziele, vollständige
Bedingungen und Namen, die Bytegrenze und die Abdeckung aller Namen. Die genaue
Ursache der clientseitigen Kürzung und das Verschwinden der Chatmeldungen müssen
noch im Spiel bestätigt werden. Chatmeldungen werden nicht unterdrückt.

## Durchschalten und Diagnose in 0.6.5

Die Kandidatensuche benötigt keine lesbaren GUIDs mehr. Zur Wiedererkennung des
aktuellen Ziels wird zuerst UnitIsUnit verwendet, als Rückfall eine lesbare GUID.
Die Reihenfolge folgt den numerischen Namensplaketten-Tokens. Namensplaketten-
Tabellen mit Lücken werden vollständig erfasst. Die Änderung behebt diese
reproduzierbaren Ausfälle, ist aber noch nicht im Forever-Client bestätigt.

Nach einem fehlgeschlagenen Klick liefert `/qt debug` den letzten vorbereiteten
Klickpfad, Kampfstatus, Anzahl der Namensplaketten und gültigen Kandidaten sowie
das gewünschte Token und den unmittelbaren Vergleich mit dem aktuellen Ziel.
Die Ergebnisprüfung kann eine verzögerte Client-Aktualisierung nicht ausschließen.
Im Kampf werden keine neuen Kandidaten vorbereitet; dann kann der Diagnosewert
des letzten vorbereiteten Klicks noch von vor dem Kampf stammen.

## Direkte Zielaktion, aktualisiert in 1.0.1

Sichtbare Kandidaten werden bereits beim ersten Klick mit dem konkreten
Namensplaketten-Token über Blizzards sicheren `/target`-Befehl gewählt. Der
vorherige Umweg über `/click` auf einen versteckten Zielbutton entfällt. Ohne
sichtbaren Token bleibt die Namenssuche aktiv. Questbuttons und Masterbutton
reagieren nur auf die Loslass-Phase, sodass ein physischer Klick genau eine
vorbereitete Zielaktion ausführt. Der Zielwechsel und die Marker-Reihenfolge
sind durch Verhaltenstests abgedeckt; die tatsächliche Ausführung im
Forever-Client ist noch zu bestätigen.

`/qt debug` zeigt für diesen Pfad **Direkte Zielaktion** sowie das Ergebnis des
unmittelbaren Zielvergleichs. Referenz: [Forever SecureTemplates](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua).

## Abgabe-NPCs im Masterbutton (0.7.0)

Der Masterbutton bezieht Abgabe-NPCs aus QuestieDBs `finishedBy`-NPC-Liste,
sobald `C_QuestLog.ReadyForTurnIn(questID)` die aktive Quest als abgabebereit
meldet. Falls diese API fehlt, wird `C_QuestLog.IsComplete` verwendet.
Quest-ID und lokalisierter Questtitel müssen mit dem Datenbankeintrag
übereinstimmen. Objekt-Abgaben und NPCs unbekannter oder abweichender Quests
werden nicht als Zielnamen ergänzt.

Mobarten offener Ziele stehen vor Abgabe-NPCs. Die Namenssuche probiert diese
Reihenfolge innerhalb des aktuellen Makroabschnitts. Wegen des 255-Byte-Limits
brauchen lange Listen mehrere Klicks; eine globale Priorität über sämtliche
Abschnitte kann der Client nicht in einem Klick garantieren. Die bisherige
clientseitige Einschränkung beim Durchschalten einzelner gleichnamiger Gegner
besteht weiterhin. Der Masterbutton zeigt NPCs nur so zuverlässig an, wie
QuestieDB Namen in der aktiven Clientsprache bereitstellt. Im Test der echten
Vanilla-Datenbank existiert für Quest 7 ein Abgabe-NPC-Eintrag, dessen Name als
„Marshal McBride“ geliefert wird; eine erfolgreiche deutsche Zielsuche ist
im Forever-Client nicht geprüft.


## Räumliche Priorisierung (1.0.2)

Sichtbare gültige Einheiten bleiben vor der geschätzten Spawnnähe priorisiert.
Die Namenssuche sortiert innerhalb jeder Rolle nach dem nächsten bekannten
Spawnpunkt: Questmobs zuerst, anschließend abgabebereite Quest-NPCs. Mehrere
NPC-IDs mit demselben Namen und mehrere Spawnpunkte werden gemeinsam ausgewertet.
Entfernte Kandidaten und Namen ohne verlässliche Koordinaten bleiben in den
rotierenden Makroabschnitten erhalten. Es gibt keinen harten Entfernungsfilter
und keine behauptete universelle Anvisierreichweite. Die bestehenden Zonenfilter
bleiben bestehen. Ein bereits gültiges Ziel wird bei fehlender Alternative behalten.

Spawn-Daten werden pro Provider/NPC gecacht. QuestieDBs Support-Zuordnung wandelt
AreaIDs in UI-MapIDs um; Blizzard projiziert die Prozentkoordinaten in Welt-Yards.
Die Position wird im vorhandenen Sekundentakt geprüft. Erst nach mindestens
10 Yards (ca. 9,1 Metern), Kartenwechsel oder Verlust/Wiederkehr der Position
wird die Entfernungsrangfolge neu berechnet. Klicken liest keine neuen Spawn-Daten.

Native Forever-Daten werden unterstützt. Vanilla-Daten verwenden, sofern vorhanden,
QuestieDBs EraToForever-Konvertierung. Bei alten Providern ohne diesen Helfer
werden Mulgore, Östliche Pestländer, Rotkammgebirge und Sturmwind nicht anhand
abweichender Era-Koordinaten eingestuft. Ohne Mapping, Position oder geeigneten
Datenprovider arbeitet die bisherige Namenssuche als Rückfall weiter. Eine fehlende
Entfernung ist kein Beleg für ein ungültiges Ziel. Positionsdaten sind Spawnangaben,
keine Live-Ortung; Patrouillen und weggezogene Gegner können davon abweichen.

Die Makros bleiben maximal 255 Bytes lang. Passen beide Rollen wegen langer Namen
nicht gemeinsam hinein, folgt auf den Mobversuch beim nächsten erfolglosen Klick
der NPCversuch. Die Mobpriorität gilt innerhalb des jeweiligen Suchabschnitts;
eine Suche aller Namen in einem einzigen Klick kann damit nicht garantiert werden.

Validierung: 80 Lua-Verhaltenstests einschließlich echter QuestieDB-v1.0.1-Daten,
Koordinatenkonvertierung, Caches, Bewegungsschwelle, unbekannter Positionen,
Namensplaketten-Priorität und vollständiger Rückfallrotation. Die Ausführung
sicherer Zielaktionen muss weiterhin im Forever-Client bestätigt werden.
Der CurseForge-Build enthält ausschließlich TOC und Laufzeit-Lua, keine
QuestieDB, Dokumentation oder Testdateien.

Koordinatenvertrag: https://github.com/Questie/QuestieDB/blob/master/docs/api.md


## Erneutes Anvisieren nach erfolgreicher Namenssuche (1.0.3)

Die Suchposition wurde zuvor bei jedem Versuch zum nächsten Makroabschnitt
weitergeschaltet, auch bei einem Treffer. Nach manuellem Abwählen musste die
Suche deshalb einmal umlaufen. Ein UI-Reload setzte die Position zurück.

Ein bestätigter Treffer stellt jetzt beide Suchzeiger auf den erfolgreichen
Abschnitt zurück. Das gilt für Questbuttons, Masterbutton und Abgabe-NPCs.
Erfolglose Versuche rotieren weiterhin; eine geänderte räumliche Reihenfolge
setzt wie bisher den Suchbeginn neu. Nur ein lebendes, gültiges Nichtspieler-Ziel,
dessen Name im tatsächlich versuchten Makro enthalten war, bestätigt den Treffer.

Die Bestätigung erfolgt in PostClick und bei PLAYER_TARGET_CHANGED, falls der
Client das neue Ziel verzögert meldet. Der Ereignishandler liest nur das Ergebnis
und aktualisiert Lua-Suchzeiger; er führt keine Zielaktion aus, schreibt keine
Secure-Attribute und löst keinen vollständigen Quest-Refresh aus.

85 Tests bestanden. Der Ablauf Treffer → Abwählen → erneuter erster Klick ist
in der Lua-Testumgebung reproduziert und geprüft, ebenso spätere erfolgreiche
Suchabschnitte, Fehlschläge, verzögerte Ereignisse und lange Abgabe-NPC-Namen.
Der tatsächliche sichere Makroablauf im Forever-Client bleibt im Spiel zu prüfen.


## Namensplaketten als Erkennung, Namenssuche als Zielaktion (1.0.4)

Die vorangegangene direkte Zielaktion per @nameplateN schlug im gemeldeten
Forever-Client fehl, obwohl die Einheit lesbar und als Questziel erkannt war.
Ohne Namensplaketten funktionierte hingegen die Namenssuche. Das Vorhandensein
eines lesbaren Tokens beweist keine erfolgreiche sichere Zielaktion.

Der sichtbare Kandidat liefert jetzt seinen geprüften Namen für
`/targetexact [nocombat] NAME`. Der Befehl enthält kein @nameplateN und kein
vorheriges /cleartarget. Die Auswahl unter mehreren gleichnamigen Einheiten
übernimmt der Client. Insbesondere ist das gezielte Durchschalten einzelner
Instanzen desselben Mobnamens NICHT implementiert/garantiert. Frühere Aussagen
und Tests, die eine erfolgreiche Token-Zielaktion simulierten, waren dafür
kein Nachweis. Die entsprechenden Hilfetexte wurden in allen sechs Sprachen
korrigiert. Die Diagnose zeigt 1.0.4 und den tatsächlich gesuchten Namen;
ihr Erfolgswert ist bei diesem Pfad ein Namensabgleich, kein Instanznachweis.

Die räumliche Reihenfolge und der erfolgreiche Suchabschnitt der Namenssuche
ohne sichtbare Kandidaten bleiben erhalten. Es werden keine geschützten
Zielfunktionen direkt aus Addon-Lua aufgerufen. Auch keine versteckten Klicks.
87 Tests bestanden, echte Zielausführung weiterhin im Spiel zu bestätigen.

Quellvergleich des Forever-Slashhandlers (kein Nachweis der Engine-Ausführung):
https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua


## Lokalisierte /qt-Befehle und QuestieDB-Hinweis (1.0.5)

Neue Installationen zeigen Englisch als Standardsprache; die bestehende
Sprachauswahl wird weiterhin beibehalten. Frühere automatisch gesetzte
Masterbutton-Texte werden beim Wechsel zur englischen Standardsprache
entsprechend migriert. Englische /qt-Befehle bleiben in jeder Sprache verfügbar.
Zusätzlich funktionieren die angezeigten lokalen Befehle für Einstellungen,
Aktualisieren, Position zurücksetzen, Erkennung erneuern, Hilfe und Diagnose in
Deutsch, Spanisch, Französisch, Türkisch und vereinfachtem Chinesisch. Die
Diagnoseausgabe und der erste Hilfetext sind ebenfalls lokalisiert. Die
Befehlsverarbeitung erhält UTF-8-Zeichen unverändert.

Wenn LibQuestieDB beim Login fehlt, erscheint einmal pro Login ein natives
Hinweisfenster mit dem vorselektierten, per Strg+C kopierbaren offiziellen
QuestieDB-Releaseübersicht:
https://github.com/Questie/QuestieDB/releases/
Bei geladenem QuestieDB erscheint der Hinweis nicht. QuestieDB ist weiterhin
eine separate Installation und wird nicht in den CurseForge-Build aufgenommen.


## Download-Link im QuestieDB-Hinweis (1.0.6)

Das Hinweisfenster zeigt die QuestieDB-Releaseübersicht statt eines fest
verdrahteten Vanilla-ZIPs. Dort kann die passende aktuelle Version gewählt werden.


## Minikarten-Button (1.0.8)

Die vorzeitig eingeführte Designauswahl wurde wieder entfernt. Bis zur
Auswahl eines neuen Designs zeigte der Button das native Quest-Ausrufezeichen.

## Kompassgrafik (1.0.9)

Der Minikarten-Button nutzt nun den ausgewählten roten Quest-Kompass. Für den
Masterbutton kann unter Darstellung zwischen dem bisherigen klassischen
Textbutton und dem modernen Kompass gewählt werden. Im modernen Modus zeigt der
Button beim Drücken die vertiefte Variante, enthält keinen Schriftzug und wird
mit einem einzigen Größenfaktor proportional skaliert. Die klassischen X-/Y-
Regler und der Schriftzug bleiben beim Wechsel zurück zum klassischen Modus
erhalten. Die beiden Grafiken liegen als TGA-Dateien im Addon.

## Korrektur der Button-Darstellung (1.0.10)

Der klassische native Button verwendet drei Hintergrundteile. Der Stilwechsel
blendet diese und die Kompass-Texturen jetzt über ihre Deckkraft um. Dadurch
werden beim Laden und beim Zurückwechseln keine fehlenden Texturen oder
Texture-Objekte an die Asset-Setter des Clients übergeben.
