-- Generated from CHANGELOG.md and docs/changelog/*.md by tools/update_patch_notes.ps1.
local _, NS = ...
NS.PatchNotesData = {
    deDE = {
        { version = "1.7.4", date = "Vorschau", sections = {
                { title = "Polestar", items = {
                    "**Polestar-Guideziele:** In WoW Forever kannst du mit installiertem Polestar unter **Buttons → Zielleiste → Polestar-Guideziele verwenden** die standardmäßig ausgeschaltete Option aktivieren. Der Hauptbutton sucht benannte offene Ziele des angezeigten Guide-Schritts; ohne Ziele übernimmt die Questsuche. Änderungen werden nach dem Kampf angewendet. Ist auch RestedXP aktiv und verfügbar, hat es Vorrang.",
                }},
            }},
        { version = "1.7.3", date = "20.11.2026", sections = {
                { title = "Optionen", items = {
                    "Fehler in Blizzards **Kontaktoptionen** behoben.",
                }},
            }},
        { version = "1.7.2", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**Nächste Rares zuerst:** Der violette Button sortiert markierte Rares und die Gebietsliste nach der Entfernung zum nächsten bekannten RareScanner-Spawnpunkt. So landen nahe Rares früher im Suchmakro.",
                }},
                { title = "Zielleiste", items = {
                    "**Aktuelle Position bei jedem Klick:** Für die Suche nach Entfernung lesen die Zielbuttons deine Position außerhalb des Kampfes erst beim Klick oder Hotkey ein. Hast du dich bewegt, startet die Suche oben in der aktualisierten Liste. Bleibst du stehen, prüfen weitere Klicks die nächsten Namen.",
                }},
            }},
        { version = "1.7.1", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**Ziel behalten:** Ein lebender Rare aus der Suchliste bleibt ausgewählt, wenn du den violetten Button erneut anklickst oder seinen Hotkey drückst.",
                }},
                { title = "Zielleiste", items = {
                    "**Getrennte Zielsuche:** Der rote Hauptbutton sucht Questziele und bei aktiver RestedXP-Integration auch Ziele des aktuellen Guide-Schritts. Der blaue RestedXP-, gelbe ItemTree- und violette RareScanner-Button suchen jeweils in ihrer eigenen Liste.",
                }},
            }},
        { version = "1.7.0", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**WoW Forever:** Die Zielsuche benötigt das Addon RareScanner. Sie funktioniert außerhalb des Kampfes und innerhalb von WoWs Zielreichweite.",
                    "**Weltkarte:** Markiere Rare-NPCs per Linksklick. Klicke den violetten **RareScanner Button** in der Zielleiste an, um alle markierten Seltenen zu suchen. Der Tooltip zeigt die Suchliste.",
                    "**RareScanner-Makro:** Je nach Namenslänge passen in der Regel **2–4 Rare-Mobs pro Klick** ins Makro. Sind mehr Rares in der Suchliste, klicke erneut, um die nächsten zu prüfen.",
                    "**Show RareScanner Button:** Unter **Buttons → Zielleiste** kannst du den standardmäßig sichtbaren Kompass ausblenden. Ohne Suchziele ist er grau. Im Kampf bleibt er sichtbar und die Suche ist gesperrt.",
                    "**RareScanner-Rares anvisieren:** Unter **Tastenkürzel** kannst du zwei Tasten für den violetten Button belegen. Die Tasten lösen dieselbe Suche aus wie ein Linksklick.",
                    "**Alle Rares im Gebiet suchen:** Aktiviere die Option unter **Buttons → Zielleiste**, damit der RareScanner Button alle Rare-NPCs aus RareScanners Liste für dein aktuelles Gebiet sucht, auch ohne Markierung. Die Liste wechselt mit dem Gebiet und berücksichtigt auch Rares im aktuellen Dungeon, wenn RareScanner sie kennt. Standardmäßig ist die Option aus.",
                    "**Minimap:** Linksklick auf das RareScanner-Symbol eines Seltenen sucht diesen Gegner. Der **Radarimpuls** bestätigt den Klick. Fängt die Minimap den ersten Klick ab, startet der nächste Klick den Zielversuch.",
                }},
                { title = "Zielleiste", items = {
                    "**Zielleiste:** Unter **Buttons → Zielleiste** stellst du die **Button-Anordnung** auf horizontal oder vertikal und den **Button-Abstand** auf 0–32 px. Mit **Bronzerahmen anzeigen** erhält die gesamte Leiste einen gemeinsamen Bronzerahmen mit abgeschrägten Ecken im Stil der FlareUI-Einheitenfenster. Standardmäßig ist die Leiste horizontal, mit 4 px Abstand und ausgeschaltetem Rahmen.",
                    "**Trennlinien anzeigen:** Schalte die gold-silbernen Linien mit Sternen unabhängig vom Bronzerahmen ein oder aus. Die Linien drehen sich bei vertikaler Anordnung mit.",
                    "**Moderner Quest-Kompass:** Der klassische Textbutton und seine Optionen für Breite, Höhe und Schriftzug entfallen. Beim Update wechselt ein klassischer Button automatisch zum Kompass. Die Position bleibt gespeichert, die Größe stellst du unter **Buttons → Zielleiste → Buttongröße** ein.",
                }},
                { title = "Patchnotes-Fenster", items = {
                    "**Patchnotes:** Beim ersten Login mit einer neuen Version öffnet sich die Chronik einmal pro Account und bleibt offen, bis du sie schließt. Du findest sie unter **Optionen → AddOns → Quest Targets → Patchnotes**. Die Chronik folgt deiner gewählten Addon-Sprache.",
                }},
            }},
        { version = "1.6.1", date = "15.11.2026", sections = {
                { title = "Neu", items = {
                    "**EllesmereUI:** Auf Forever gibt es Zielbuttons am Custom Quest Tracker. Linksklick sucht ein Ziel, Rechtsklick setzt den Questfokus.",
                    "**Feedback:** Der Dialog zeigt einen QR-Code für das Formular.",
                }},
                { title = "Verbessert", items = {
                    "Maustasten, Mausrad und Tastenkombinationen lassen sich überall im Spielfenster als Ziel-Hotkey erfassen.",
                    "Questie und EllesmereUI haben getrennte Abstandsregler. Ihre Optionen stehen unter „Buttons“.",
                    "Der Ton beim Abwählen eines Ziels lässt sich optional dämpfen.",
                }},
            }},
        { version = "1.6.0", date = "10.11.2026", sections = {
                { title = "Neu", items = {
                    "**ItemTree-Integration:** Installiere und aktiviere ItemTree separat. Öffne bei einer Zutat die Ansicht **Quellen**, klappe bei Bedarf **Mehr anzeigen** auf und klicke **Mobs übernehmen**. Quest Targets übernimmt die Gegner, die die Zutat fallen lassen.",
                    "**ItemTree-Zielsuche:** Aktiviere unter **Buttons → ItemTree-Button anzeigen** den gelben Kompass oder belege unter **Hotkeys → ItemTree-Mobs anvisieren** eine Taste. Wenn ein Klick nichts findet, klick erneut, um weitere Namen zu prüfen.",
                    "**Aktionsleisten-Makro:** Beim Import legt Quest Targets nach Möglichkeit das Charaktermakro **ItemTree Mobs** an. Du kannst es aus dem Makrofenster in die Aktionsleiste ziehen. Der Zielbutton und sein Hotkey funktionieren auch ohne freien Makroplatz.",
                    "Die **Zielleiste** zeigt den roten Masterbutton, den blauen RestedXP-Button und den gelben ItemTree-Button.",
                }},
                { title = "Verbessert", items = {
                    "Die drei Buttons lassen sich gemeinsam verschieben und skalieren. Du wählst, welche sichtbar sind.",
                    "Die ItemTree-Suche bevorzugt Ziele in deiner Zone und berücksichtigt bekannte Spawnpunkte.",
                }},
            }},
        { version = "1.5.1", date = "03.11.2026", sections = {
                { title = "Neu", items = {
                    "Das Questfenster lässt sich an der **unteren rechten Ecke** vergrößern. Größe und Position bleiben gespeichert.",
                    "Questies Zielbuttons lassen sich abschalten und ihr Abstand lässt sich einstellen.",
                }},
                { title = "Verbessert", items = {
                    "Der **Minimap-Button** funktioniert besser mit Addons, die Minimap-Buttons sammeln.",
                    "Die installierte Version steht in den Optionen. Neue Einstellungen starten mit dem Kompass als Masterbutton.",
                }},
            }},
        { version = "1.5.0", date = "03.11.2026", sections = {
                { title = "Verbessert", items = {
                    "Ein gemeinsamer Download unterstützt Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever und Retail.",
                    "Quest Targets wählt die Questdaten für deinen Client. QuestieDB wird auf den Clients, die es brauchen, separat installiert.",
                }},
            }},
        { version = "1.4.2", date = "03.11.2026", sections = {
                { title = "Verbessert", items = {
                    "**QuestieDB** ist ein eigener Download und kann unabhängig aktualisiert werden. Für Retail ist es nicht erforderlich.",
                }},
            }},
        { version = "1.4.1", date = "02.11.2026", sections = {
                { title = "Verbessert", items = {
                    "Master und Fokus stehen mit beiden Belegungsplätzen in WoWs Tastenbelegung. Bei einer bereits belegten Taste fragt Quest Targets vor dem Überschreiben nach.",
                    "Quest Targets erscheint direkt nach dem Login in den AddOn-Optionen. Regler für die jeweils andere Button-Optik sind ausgegraut.",
                }},
                { title = "Behoben", items = {
                    "Änderungen und Löschungen in WoWs Tastenbelegung bleiben nach einem Neuladen erhalten.",
                    "Rechtsklick öffnet das Questlog nur außerhalb des Kampfes. Karten- und Zielzuordnungen wurden zuverlässiger.",
                }},
            }},
        { version = "1.4.0", date = "30.10.2026", sections = {
                { title = "Neu", items = {
                    "Master und Fokus haben jeweils zwei Hotkey-Plätze für Tastatur und unterstützte Controller.",
                }},
                { title = "Verbessert", items = {
                    "Eine Belegung lässt sich ändern oder löschen, ohne die zweite zu verlieren. Escape bricht die Eingabe ab.",
                }},
            }},
        { version = "1.3.0", date = "29.10.2026", sections = {
                { title = "Verbessert", items = {
                    "Die neue Masterbutton-Positionierung und QuestieDB 1.0.9 aus 1.2.9 wurden als Version 1.3.0 zusammen veröffentlicht.",
                }},
            }},
        { version = "1.2.9", date = "28.10.2026", sections = {
                { title = "Neu", items = {
                    "**Masterbutton verschieben** zeigt einen Ziehgriff in den Einstellungen. „Fertig“ speichert, Escape bricht ab und „Zurücksetzen“ zeigt die Standardposition.",
                }},
                { title = "Verbessert", items = {
                    "Die Classic- und Forever-Pakete enthielten die zu ihrem Client passende QuestieDB 1.0.9.",
                }},
            }},
        { version = "1.2.8", date = "16.10.2026", sections = {
                { title = "Behoben", items = {
                    "QuestieDB 1.0.6 in den damaligen Paketen stellte die Kompatibilität mit Questie 12.1.0 wieder her.",
                }},
            }},
        { version = "1.2.7", date = "15.10.2026", sections = {
                { title = "Neu", items = {
                    "Mit **/qt debug** siehst du Informationen zur letzten Zielsuche.",
                }},
                { title = "Behoben", items = {
                    "WoWs **Aktionsleiste** bleibt nach dem Ändern der Addon-Optionen bedienbar.",
                }},
            }},
        { version = "1.2.6", date = "12.10.2026", sections = {
                { title = "Behoben", items = {
                    "Master- und RestedXP-Button bleiben bedienbar, wenn die Liste der passenden Questziele während eines Guide-Schritts kleiner oder leer wird.",
                }},
            }},
        { version = "1.2.5", date = "09.10.2026", sections = {
                { title = "Neu", items = {
                    "Rechtsklick auf ein Quest-Symbol in Quest Targets oder Questie setzt den Fokus. Ein eigener Hotkey sucht nur Ziele für diese Quest.",
                    "Kompakte native Optionen mit direkt bearbeitbarem Masterbutton-Text.",
                }},
                { title = "Verbessert", items = {
                    "Questies Zielbuttons erscheinen automatisch. RestedXP berücksichtigt die aktuell offenen Ziele des Guide-Schritts.",
                    "Questfenster, Scrollen und Ziehen wurden zuverlässiger. Erledigte Ziele bleiben nicht in der Suche hängen.",
                }},
            }},
        { version = "1.2.4", date = "04.10.2026", sections = {
                { title = "Verbessert", items = {
                    "Wenn RestedXP kein passendes Ziel liefert, kann die Suche zu offenen Quests zurückkehren.",
                    "Ein gültiges Ziel bleibt bei weiteren Klicks ausgewählt, solange keine sichtbare passende Alternative gefunden wird.",
                }},
            }},
        { version = "1.2.3", date = "03.10.2026", sections = {
                { title = "Neu", items = {
                    "RestedXP kann ausdrücklich genannte Questgeber schon vor der Questannahme als Ziele anbieten.",
                    "Unterstützung für Burning Crusade Classic und Mists of Pandaria Classic.",
                }},
                { title = "Verbessert", items = {
                    "Quest Targets steht in der AddOn-Liste unter „Quests“. Auf Classic Era zeigen Questies Zielbuttons den Kompass.",
                }},
            }},
        { version = "1.2.2", date = "03.10.2026", sections = {
                { title = "Neu", items = {
                    "Die optionale RestedXP-Integration sucht nach passenden Zielen im aktiven Guide-Schritt. Ein Zielbutton erscheint bei RestedXP.",
                }},
            }},
        { version = "1.2.1", date = "02.10.2026", sections = {
                { title = "Neu", items = {
                    "Optionaler Zielbutton neben jeder Quest in Questies Tracker.",
                }},
                { title = "Verbessert", items = {
                    "Neue Forever-Schnittstellenversion, überarbeitete Masterbutton-Größe und ein WoW-Rahmen für den Minimap-Button.",
                    "Im transparenten Questfenster erscheinen Ziehhilfe und Umschalter bei Mausberührung. Einstellungen und Feedback stehen nebeneinander.",
                }},
            }},
        { version = "1.2.0", date = "30.09.2026", sections = {
                { title = "Neu", items = {
                    "**Retail 12.1** wird unterstützt. Dafür liest Quest Targets das laufende Questlog und sichtbare Namensplaketten ohne QuestieDB.",
                }},
                { title = "Behoben", items = {
                    "Wenn das Questlog nicht gelesen werden kann, erscheint ein Hinweis statt einer scheinbar leeren Liste.",
                }},
            }},
        { version = "1.1.0", date = "28.09.2026", sections = {
                { title = "Neu", items = {
                    "Die **transparente Ansicht** lässt nur die Questliste stehen. Das Auge am Fenster schaltet die Ansicht um und blendet sich nach kurzer Zeit aus.",
                }},
                { title = "Verbessert", items = {
                    "Schließen-Button und Scrollleiste wurden an das neue Layout angepasst.",
                }},
            }},
        { version = "1.0.22", date = "28.09.2026", sections = {
                { title = "Verbessert", items = {
                    "Die Datenanbindung an QuestieDB wurde aktualisiert. Die öffentliche Addon-Datei nutzte weiterhin den passenden separaten Datenanbieter.",
                }},
            }},
        { version = "1.0.16", date = "27.09.2026", sections = {
                { title = "Neu", items = {
                    "Der **Feedbackbutton** öffnet einen kopierbaren Link für Fehlerberichte und Wünsche. Dafür ist kein GitHub-Konto nötig.",
                }},
            }},
        { version = "1.0.15", date = "27.09.2026", sections = {
                { title = "Verbessert", items = {
                    "**Mausrad und Scrollleiste** ersetzen die Seitenpfeile. Ein Regler in den Optionen ändert die Fenstergröße.",
                    "Tooltips wurden vereinfacht, Hotkeys bekamen einen eigenen Bereich und alle sechs Sprachen wurden aktualisiert.",
                }},
            }},
        { version = "1.0.13", date = "25.09.2026", sections = {
                { title = "Verbessert", items = {
                    "Fehlt QuestieDB, verweist der Hinweis auf das passende Paket für Classic Era oder Forever. Der Link lässt sich im Fenster zum Kopieren auswählen.",
                }},
            }},
        { version = "1.0.12", date = "25.09.2026", sections = {
                { title = "Neu", items = {
                    "Unterstützung für **WoW Classic Era** 1.15.9 neben der Forever-Beta.",
                }},
                { title = "Behoben", items = {
                    "Classic-Quests, Verfolgung, Abschluss und Rechtsklick ins Questlog werden korrekt gelesen. Classic-Spawnkoordinaten bleiben unverändert.",
                }},
            }},
        { version = "1.0.11", date = "25.09.2026", sections = {
                { title = "Neu", items = {
                    "Erste belegte Version für die Forever-Beta. Ein Button pro Quest und ein **Masterbutton** suchen nach offenen Questmobs oder abgabebereiten NPCs.",
                    "QuestieDB ergänzt Ziele aus Killquests, gemeinsame Killziele und Gegner, die benötigte Gegenstände fallen lassen. Lesbare Namensplaketten können weitere passende Ziele liefern.",
                    "Die Questliste zeigt den Fortschritt, filtert verfolgte Quests und öffnet mit Rechtsklick das Questlog. /qt öffnet und schließt das Fenster.",
                    "Zielmarkierung, Hotkey, Tooltips und sechs Sprachen lassen sich in den WoW-Optionen einstellen.",
                    "Der Quest-Kompass erscheint an der Minimap und kann als beweglicher Masterbutton genutzt werden. Die klassische Variante kann einen eigenen Text anzeigen.",
                }},
            }},
    },
    enUS = {
        { version = "1.7.4", date = "Preview", sections = {
                { title = "Polestar", items = {
                    "**Polestar guide targets:** On WoW Forever, with Polestar installed, enable the normally disabled **Buttons → Targeting bar → Follow Polestar guide targets** option. The main compass searches named open goals in the displayed guide step; without targets it falls back to quest search. Changes apply after combat. If RestedXP is also enabled and available, it takes precedence.",
                }},
            }},
        { version = "1.7.3", date = "Nov 20, 2026", sections = {
                { title = "Options", items = {
                    "Fixed an error in Blizzard's **Social settings**.",
                }},
            }},
        { version = "1.7.2", date = "Nov 19, 2026", sections = {
                { title = "RareScanner", items = {
                    "**Nearest rares first:** The purple button orders marked rares and the zone list by distance to the nearest known RareScanner spawn point, so nearby rares are checked sooner.",
                }},
                { title = "Targeting bar", items = {
                    "**Current position on every click:** Out of combat, targeting buttons read your position for distance-based searches only when you click or press a hotkey. If you've moved, the search starts at the top of the updated list. If you stay in place, further clicks check the next names.",
                }},
            }},
        { version = "1.7.1", date = "Nov 19, 2026", sections = {
                { title = "RareScanner", items = {
                    "**Keep your target:** A living rare on the search list stays selected when you click the purple button again or press its hotkey.",
                }},
                { title = "Targeting bar", items = {
                    "**Separate target searches:** The red master button looks for quest targets and adds targets from the active RestedXP guide step when enabled. The blue RestedXP, yellow ItemTree and purple RareScanner buttons each search their own list.",
                }},
            }},
        { version = "1.7.0", date = "Nov 19, 2026", sections = {
                { title = "RareScanner", items = {
                    "**WoW Forever:** Targeting requires the RareScanner addon. It works out of combat and within WoW’s targeting range.",
                    "**World map:** Left-click rare NPCs to mark them. Click the purple **RareScanner Button** on the targeting bar to search for all marked rares. The tooltip lists the targets.",
                    "**RareScanner macro:** Depending on name length, the macro usually fits **2–4 rare mobs per click**. If the list has more rares, click again to check the next ones.",
                    "**Show RareScanner Button:** You can hide the compass under **Buttons → Targeting bar**. It is shown by default and grayed out when it has no targets to search for. It stays visible in combat, with targeting disabled.",
                    "**Target RareScanner rares:** Under **Hotkeys**, you can assign two keys to the purple button. Each key press searches like a left-click.",
                    "**Search all rares in the zone:** Enable this under **Buttons → Targeting bar** to search for every rare NPC RareScanner lists in your current zone, including unmarked ones. The list updates as you change zones and includes rares in your current dungeon when RareScanner has data for it. Off by default.",
                    "**Minimap:** Left-click a rare's RareScanner icon to look for that NPC. A **radar pulse** confirms the click. If the minimap handles the first click, click again to attempt targeting.",
                }},
                { title = "Targeting bar", items = {
                    "**Targeting bar:** Under **Buttons → Targeting bar**, set **Button layout** to horizontal or vertical and **Button spacing** to 0–32 px. Turn on **Show bronze border** for one chamfered bronze frame around the entire bar inspired by FlareUI's unit frames. Defaults are horizontal, 4 px spacing and border off.",
                    "**Show dividers:** Toggle the gold-to-silver dividers with star tips independently of the bronze border. The dividers rotate when the bar is vertical.",
                    "**Modern quest compass:** The classic text button and its width, height and text options have been removed. If you used the classic button, the update switches it to the compass at your saved position. Adjust its size under **Buttons → Targeting bar → Button size**.",
                }},
                { title = "Patch Notes window", items = {
                    "**Patch Notes:** On your first login with a new version, the history opens once per account and stays open until you close it. Find it under **Options → AddOns → Quest Targets → Patch Notes**. The notes follow your chosen addon language.",
                }},
            }},
        { version = "1.6.1", date = "Nov 15, 2026", sections = {
                { title = "New", items = {
                    "**EllesmereUI:** Quest Targets adds buttons to the Custom Quest Tracker on Forever. Left-click to search for a target or right-click to focus the quest.",
                    "**Feedback:** The dialog provides a QR code for the feedback form.",
                }},
                { title = "Improved", items = {
                    "Assign mouse buttons, the mouse wheel, and key combinations as targeting shortcuts anywhere in the game window.",
                    "Questie and EllesmereUI have separate spacing controls under **Buttons**.",
                    "You can mute the sound that plays when a target is cleared.",
                }},
            }},
        { version = "1.6.0", date = "Nov 10, 2026", sections = {
                { title = "New", items = {
                    "**ItemTree integration:** Install and enable ItemTree separately. Open an ingredient’s **Sources** view, expand **Show more** if needed, and click **Import mobs**. Quest Targets imports the mobs that drop that ingredient.",
                    "**ItemTree targeting:** Enable the yellow compass under **Buttons → Show ItemTree button** or assign a key under **Hotkeys → Target ItemTree mobs**. If a click finds nothing, click again to check more names.",
                    "**Action bar macro:** When possible, importing creates the character macro **ItemTree Mobs**. Drag it from the macro window to your action bar. The targeting button and its hotkey work without a free macro slot.",
                    "The **targeting bar** holds the red Master button, the blue RestedXP button, and the yellow ItemTree button.",
                }},
                { title = "Improved", items = {
                    "Move and resize the three buttons together, and choose which ones to show.",
                    "ItemTree searches prioritize targets in your zone and use known spawn points when available.",
                }},
            }},
        { version = "1.5.1", date = "Nov 3, 2026", sections = {
                { title = "New", items = {
                    "Drag the **bottom-right corner** to resize the quest window. Its size and position are saved.",
                    "Turn off Questie’s target buttons or adjust their spacing.",
                }},
                { title = "Improved", items = {
                    "The **minimap button** works better with addons that collect minimap buttons.",
                    "The options show the installed version. New settings use the compass as the Master button.",
                }},
            }},
        { version = "1.5.0", date = "Nov 3, 2026", sections = {
                { title = "Improved", items = {
                    "One download supports Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever, and Retail.",
                    "Quest Targets selects the quest data for your client. Install QuestieDB separately on clients that need it.",
                }},
            }},
        { version = "1.4.2", date = "Nov 3, 2026", sections = {
                { title = "Improved", items = {
                    "**QuestieDB** is a separate download and can be updated on its own. Retail does not require it.",
                }},
            }},
        { version = "1.4.1", date = "Nov 2, 2026", sections = {
                { title = "Improved", items = {
                    "Master and Focus now have both slots in WoW’s keybindings menu. Quest Targets asks before replacing a key that is already assigned.",
                    "Quest Targets appears in AddOn options immediately after login. Controls for the other button style are grayed out.",
                }},
                { title = "Fixed", items = {
                    "Changes and cleared bindings in WoW’s keybindings menu persist after reloading.",
                    "Right-click opens the quest log only out of combat. Map and target matching is more reliable.",
                }},
            }},
        { version = "1.4.0", date = "Oct 30, 2026", sections = {
                { title = "New", items = {
                    "Master and Focus each have two binding slots for keyboard keys and supported controllers.",
                }},
                { title = "Improved", items = {
                    "Change or clear one binding while keeping the other. Press Escape to cancel assignment.",
                }},
            }},
        { version = "1.3.0", date = "Oct 29, 2026", sections = {
                { title = "Improved", items = {
                    "Version 1.3.0 publishes the Master button positioning controls and QuestieDB 1.0.9 together as introduced in 1.2.9.",
                }},
            }},
        { version = "1.2.9", date = "Oct 28, 2026", sections = {
                { title = "New", items = {
                    "**Move master button** adds a drag handle in Settings. Choose Done to save, press Escape to cancel, or choose Reset position to preview the default.",
                }},
                { title = "Improved", items = {
                    "Classic and Forever packages included the matching QuestieDB 1.0.9 for each client.",
                }},
            }},
        { version = "1.2.8", date = "Oct 16, 2026", sections = {
                { title = "Fixed", items = {
                    "Bundling QuestieDB 1.0.6 restored compatibility with Questie 12.1.0.",
                }},
            }},
        { version = "1.2.7", date = "Oct 15, 2026", sections = {
                { title = "New", items = {
                    "Use **/qt debug** to see details about the last target search.",
                }},
                { title = "Fixed", items = {
                    "WoW’s **action bar** stays usable after changing the addon options.",
                }},
            }},
        { version = "1.2.6", date = "Oct 12, 2026", sections = {
                { title = "Fixed", items = {
                    "The Master and RestedXP buttons keep working when the list of quest targets shrinks or becomes empty during a guide step.",
                }},
            }},
        { version = "1.2.5", date = "Oct 9, 2026", sections = {
                { title = "New", items = {
                    "Right-click a quest icon in Quest Targets or Questie to focus it. A separate hotkey searches only for targets for that quest.",
                    "Compact native options let you edit the Master button text directly.",
                }},
                { title = "Improved", items = {
                    "Questie’s target buttons appear automatically. RestedXP uses the remaining targets in the active guide step.",
                    "The quest window, scrolling, and dragging are more reliable. Finished objectives are removed from searches.",
                }},
            }},
        { version = "1.2.4", date = "Oct 4, 2026", sections = {
                { title = "Improved", items = {
                    "If RestedXP has no matching target, the search can fall back to open quests.",
                    "Repeated clicks keep a valid target selected while no matching alternative is visible.",
                }},
            }},
        { version = "1.2.3", date = "Oct 3, 2026", sections = {
                { title = "New", items = {
                    "RestedXP can look for explicitly named quest givers before you accept their quests.",
                    "Added support for Burning Crusade Classic and Mists of Pandaria Classic.",
                }},
                { title = "Improved", items = {
                    "Quest Targets appears under Quests in the AddOn list. Questie’s target buttons show the compass on Classic Era.",
                }},
            }},
        { version = "1.2.2", date = "Oct 3, 2026", sections = {
                { title = "New", items = {
                    "The optional RestedXP integration searches the current guide step. A Quest Targets button appears beside RestedXP.",
                }},
            }},
        { version = "1.2.1", date = "Oct 2, 2026", sections = {
                { title = "New", items = {
                    "An optional target button appears next to each quest in Questie’s tracker.",
                }},
                { title = "Improved", items = {
                    "Updated support for the Forever interface, adjusted Master button sizing, and added a native border to the minimap button.",
                    "In the transparent quest window, hovering shows the drag handle and the toggle. Settings and Feedback appear side by side.",
                }},
            }},
        { version = "1.2.0", date = "Sep 30, 2026", sections = {
                { title = "New", items = {
                    "**Retail 12.1** is supported. Quest Targets reads the live quest log and visible nameplates without QuestieDB.",
                }},
                { title = "Fixed", items = {
                    "If the quest log cannot be read, the window shows a message instead of an apparently empty list.",
                }},
            }},
        { version = "1.1.0", date = "Sep 28, 2026", sections = {
                { title = "New", items = {
                    "**Transparent mode** shows only the quest list. Use the eye icon to toggle the view. The icon fades after a moment.",
                }},
                { title = "Improved", items = {
                    "The close button and scrollbar fit the new layout.",
                }},
            }},
        { version = "1.0.22", date = "Sep 28, 2026", sections = {
                { title = "Improved", items = {
                    "Updated QuestieDB integration. The public addon download still used the appropriate separately installed provider.",
                }},
            }},
        { version = "1.0.16", date = "Sep 27, 2026", sections = {
                { title = "New", items = {
                    "The **Feedback button** opens a copyable link for bug reports and suggestions. No GitHub account is needed.",
                }},
            }},
        { version = "1.0.15", date = "Sep 27, 2026", sections = {
                { title = "Improved", items = {
                    "**Mouse wheel scrolling and a scrollbar** replace the page arrows. Resize the quest window with a slider in Settings.",
                    "Tooltips are simpler, hotkeys have their own section, and text is updated in all six languages.",
                }},
            }},
        { version = "1.0.13", date = "Sep 25, 2026", sections = {
                { title = "Improved", items = {
                    "If QuestieDB is missing, the message points to the right package for Classic Era or Forever. Select the link in the dialog to copy it.",
                }},
            }},
        { version = "1.0.12", date = "Sep 25, 2026", sections = {
                { title = "New", items = {
                    "Added **WoW Classic Era** 1.15.9 support alongside the Forever beta.",
                }},
                { title = "Fixed", items = {
                    "Classic quest reading, tracking, completion, and right-click access to the quest log work correctly. Classic spawn coordinates are preserved.",
                }},
            }},
        { version = "1.0.11", date = "Sep 25, 2026", sections = {
                { title = "New", items = {
                    "First documented Forever beta version. A button per quest and a **Master button** search for active quest mobs or NPCs ready for turn-in.",
                    "QuestieDB adds kill quest targets, shared kill targets, and enemies that drop required items. Readable nameplates can provide more matching targets.",
                    "The quest list shows progress, filters tracked quests, and opens the quest log with a right-click. /qt toggles the window.",
                    "Configure target marking, hotkeys, tooltips, and six languages in the WoW options.",
                    "The quest compass appears on the minimap and can serve as a movable Master button. The classic button supports custom text.",
                }},
            }},
    },
    esES = {
        { version = "1.7.4", date = "Vista previa", sections = {
                { title = "Polestar", items = {
                    "**Objetivos de Polestar:** En WoW Forever, con Polestar instalado, activa **Botones → Barra de objetivos → Seguir objetivos de Polestar**, desactivado por defecto. La brújula principal busca objetivos abiertos con nombre del paso mostrado; si no hay ninguno, busca objetivos de misión. Los cambios se aplican después del combate. Si RestedXP también está activado y disponible, tiene prioridad.",
                }},
            }},
        { version = "1.7.3", date = "20.11.2026", sections = {
                { title = "Opciones", items = {
                    "Corregido un error en los **ajustes sociales** de Blizzard.",
                }},
            }},
        { version = "1.7.2", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**Primero los raros más cercanos:** El botón morado ordena los raros marcados y los de la zona por distancia a su punto de aparición conocido más cercano en RareScanner.",
                }},
                { title = "Barra de objetivos", items = {
                    "**Posición actual con cada clic:** Fuera de combate, los botones de objetivos solo leen tu posición para las búsquedas por distancia al hacer clic o pulsar su atajo. Si te has movido, la búsqueda empieza al principio de la lista actualizada. Si te quedas en el sitio, los siguientes clics comprueban más nombres.",
                }},
            }},
        { version = "1.7.1", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**Conservar el objetivo:** Un raro vivo de la lista sigue seleccionado si vuelves a pulsar el botón morado o su tecla rápida.",
                }},
                { title = "Barra de objetivos", items = {
                    "**Búsquedas independientes:** El botón principal rojo busca objetivos de misión y, si RestedXP está activado en Quest Targets, también los del paso actual de la guía. Los botones azul de RestedXP, amarillo de ItemTree y morado de RareScanner buscan en sus propias listas.",
                }},
            }},
        { version = "1.7.0", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**WoW Forever:** La búsqueda requiere el addon RareScanner. Funciona fuera de combate y dentro del alcance de selección de WoW.",
                    "**Mapa del mundo:** Haz clic izquierdo en un PNJ raro para marcarlo. Pulsa el **Botón de RareScanner** morado en la barra de objetivos para buscar todos los raros marcados. El cuadro de información muestra la lista.",
                    "**Macro de RareScanner:** Según la longitud de los nombres, suelen caber **2–4 enemigos raros por clic** en la macro. Si hay más en la lista, pulsa de nuevo para buscar los siguientes.",
                    "**Mostrar botón de RareScanner:** Puedes ocultar la brújula en **Botones → Barra de objetivos**. Se muestra por defecto y aparece en gris cuando no hay objetivos que buscar. Sigue visible en combate, con la búsqueda desactivada.",
                    "**Apuntar a raros de RareScanner:** En **Teclas rápidas**, puedes asignar dos teclas al botón morado. Cada pulsación busca igual que un clic izquierdo.",
                    "**Buscar todos los raros de la zona:** Activa esta opción en **Botones → Barra de objetivos** para buscar todos los PNJ raros que RareScanner lista en tu zona actual, incluidos los que no están marcados. La lista se actualiza al cambiar de zona e incluye los raros de la mazmorra actual si RareScanner tiene datos de ella. Desactivada por defecto.",
                    "**Minimapa:** Haz clic izquierdo en el icono de RareScanner de un raro para buscarlo. Un **pulso de radar** confirma el clic. Si el minimapa gestiona el primer clic, vuelve a pulsar para intentar seleccionar al raro.",
                }},
                { title = "Barra de objetivos", items = {
                    "**Barra de objetivos:** En **Botones → Barra de objetivos**, elige la **Disposición de botones** horizontal o vertical y ajusta la **Separación de botones** entre 0 y 32 px. Activa **Mostrar borde de bronce** para rodear toda la barra con un único borde de bronce con esquinas biseladas inspirado en los marcos de unidad de FlareUI. Por defecto, la barra es horizontal, con 4 px de separación y el borde desactivado.",
                    "**Mostrar separadores:** Activa o desactiva las líneas de oro a plata con estrellas independientemente del borde de bronce. Giran cuando la barra es vertical.",
                    "**Brújula de misiones moderna:** Se han eliminado el botón clásico de texto y sus opciones de anchura, altura y texto. Al actualizar, el botón clásico se convierte en una brújula en la posición guardada. Ajusta su tamaño en **Botones → Barra de objetivos → Tamaño del botón**.",
                }},
                { title = "Ventana de notas del parche", items = {
                    "**Notas del parche:** El historial se abre una vez por cuenta al iniciar sesión por primera vez con una nueva versión y permanece abierto hasta que lo cierres. Puedes abrirlo desde **Opciones → AddOns → Quest Targets → Notas del parche**. Usa el idioma elegido para el addon.",
                }},
            }},
        { version = "1.6.1", date = "15.11.2026", sections = {
                { title = "Novedades", items = {
                    "**EllesmereUI:** En Forever, Quest Targets añade botones al Custom Quest Tracker. Haz clic izquierdo para buscar un objetivo o clic derecho para enfocar la misión.",
                    "**Comentarios:** La ventana muestra un código QR para abrir el formulario.",
                }},
                { title = "Mejoras", items = {
                    "Asigna botones del ratón, la rueda o combinaciones de teclas como atajos de selección desde cualquier parte de la ventana del juego.",
                    "Questie y EllesmereUI tienen controles de separación independientes en **Botones**.",
                    "Puedes silenciar el sonido al deseleccionar un objetivo.",
                }},
            }},
        { version = "1.6.0", date = "10.11.2026", sections = {
                { title = "Novedades", items = {
                    "**Integración con ItemTree:** Instala y activa ItemTree por separado. Abre la vista **Sources** de un ingrediente, despliega **Show more** si hace falta y pulsa **Import mobs**. Quest Targets importa los enemigos que sueltan ese ingrediente.",
                    "**Selección de objetivos de ItemTree:** Activa la brújula amarilla en **Botones → Mostrar botón de ItemTree** o asigna una tecla a **Target ItemTree mobs** en los atajos. Si no encuentras un objetivo, pulsa de nuevo para comprobar más nombres.",
                    "**Macro de la barra de acción:** Si es posible, la importación crea la macro de personaje **ItemTree Mobs**. Arrástrala desde la ventana de macros a la barra de acción. El botón y su atajo funcionan aunque no quede espacio para macros.",
                    "La **barra de objetivos** incluye el botón principal rojo, el botón azul de RestedXP y el amarillo de ItemTree.",
                }},
                { title = "Mejoras", items = {
                    "Mueve y cambia el tamaño de los tres botones juntos y elige cuáles se muestran.",
                    "La búsqueda de ItemTree prioriza objetivos de tu zona y toma en cuenta los puntos de aparición conocidos.",
                }},
            }},
        { version = "1.5.1", date = "03.11.2026", sections = {
                { title = "Novedades", items = {
                    "Arrastra la **esquina inferior derecha** para cambiar el tamaño de la ventana de misiones. Se guardan el tamaño y la posición.",
                    "Puedes ocultar los botones de objetivos de Questie o ajustar su separación.",
                }},
                { title = "Mejoras", items = {
                    "El **botón del minimapa** funciona mejor con addons que agrupan estos botones.",
                    "Las opciones muestran la versión instalada. La brújula es el botón principal por defecto en configuraciones nuevas.",
                }},
            }},
        { version = "1.5.0", date = "03.11.2026", sections = {
                { title = "Mejoras", items = {
                    "Una sola descarga sirve para Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever y Retail.",
                    "Quest Targets selecciona los datos de misión para tu cliente. Instala QuestieDB por separado si tu cliente lo necesita.",
                }},
            }},
        { version = "1.4.2", date = "03.11.2026", sections = {
                { title = "Mejoras", items = {
                    "**QuestieDB** se descarga y actualiza por separado. Retail no lo requiere.",
                }},
            }},
        { version = "1.4.1", date = "02.11.2026", sections = {
                { title = "Mejoras", items = {
                    "El botón principal y el de enfoque tienen ambos espacios en las asignaciones de teclas de WoW. Quest Targets pide confirmación antes de reemplazar una tecla ya asignada.",
                    "Quest Targets aparece en las opciones de AddOns al iniciar sesión. Los controles del estilo de botón que no está en uso aparecen en gris.",
                }},
                { title = "Correcciones", items = {
                    "Los cambios y las asignaciones eliminadas en WoW se conservan al recargar la interfaz.",
                    "El clic derecho abre el registro de misiones solo fuera de combate. Las asociaciones de mapas y objetivos son más fiables.",
                }},
            }},
        { version = "1.4.0", date = "30.10.2026", sections = {
                { title = "Novedades", items = {
                    "El botón principal y el de enfoque tienen dos asignaciones cada uno para teclado y mandos compatibles.",
                }},
                { title = "Mejoras", items = {
                    "Puedes cambiar o borrar una asignación sin perder la otra. Pulsa Escape para cancelar la asignación.",
                }},
            }},
        { version = "1.3.0", date = "29.10.2026", sections = {
                { title = "Mejoras", items = {
                    "La versión 1.3.0 reúne el ajuste de posición del botón principal y QuestieDB 1.0.9 introducidos en 1.2.9.",
                }},
            }},
        { version = "1.2.9", date = "28.10.2026", sections = {
                { title = "Novedades", items = {
                    "**Mover el botón principal** añade un asa en las opciones. Confirma para guardar, pulsa Escape para cancelar o restablece la posición para ver dónde queda por defecto.",
                }},
                { title = "Mejoras", items = {
                    "Los paquetes de Classic y Forever incluían QuestieDB 1.0.9 para cada cliente.",
                }},
            }},
        { version = "1.2.8", date = "16.10.2026", sections = {
                { title = "Correcciones", items = {
                    "QuestieDB 1.0.6 incluido en los paquetes restauró la compatibilidad con Questie 12.1.0.",
                }},
            }},
        { version = "1.2.7", date = "15.10.2026", sections = {
                { title = "Novedades", items = {
                    "Usa **/qt debug** para ver información de la última búsqueda.",
                }},
                { title = "Correcciones", items = {
                    "La **barra de acción** de WoW sigue funcionando tras cambiar las opciones del addon.",
                }},
            }},
        { version = "1.2.6", date = "12.10.2026", sections = {
                { title = "Correcciones", items = {
                    "Los botones principal y de RestedXP siguen funcionando si la lista de objetivos se reduce o queda vacía durante un paso de la guía.",
                }},
            }},
        { version = "1.2.5", date = "09.10.2026", sections = {
                { title = "Novedades", items = {
                    "Haz clic derecho en un icono de misión en Quest Targets o Questie para enfocarla. Un atajo propio busca solo objetivos de esa misión.",
                    "Las opciones nativas y compactas permiten editar directamente el texto del botón principal.",
                }},
                { title = "Mejoras", items = {
                    "Los botones de Questie aparecen automáticamente. RestedXP usa los objetivos pendientes del paso actual.",
                    "La ventana de misiones, el desplazamiento y el arrastre son más fiables. Los objetivos completados se retiran de la búsqueda.",
                }},
            }},
        { version = "1.2.4", date = "04.10.2026", sections = {
                { title = "Mejoras", items = {
                    "Si RestedXP no tiene un objetivo válido, la búsqueda puede volver a las misiones pendientes.",
                    "Los clics repetidos mantienen el objetivo válido mientras no aparezca una alternativa compatible.",
                }},
            }},
        { version = "1.2.3", date = "03.10.2026", sections = {
                { title = "Novedades", items = {
                    "RestedXP puede buscar a los PNJ mencionados por nombre antes de que aceptes sus misiones.",
                    "Se añade compatibilidad con Burning Crusade Classic y Mists of Pandaria Classic.",
                }},
                { title = "Mejoras", items = {
                    "Quest Targets aparece en la categoría Misiones de la lista de AddOns. En Classic Era, los botones de Questie muestran la brújula.",
                }},
            }},
        { version = "1.2.2", date = "03.10.2026", sections = {
                { title = "Novedades", items = {
                    "La integración opcional de RestedXP busca objetivos del paso actual. Aparece un botón de Quest Targets junto a RestedXP.",
                }},
            }},
        { version = "1.2.1", date = "02.10.2026", sections = {
                { title = "Novedades", items = {
                    "Hay un botón de objetivo opcional junto a cada misión del rastreador de Questie.",
                }},
                { title = "Mejoras", items = {
                    "Se actualiza la compatibilidad con la interfaz de Forever, el tamaño del botón principal y el marco nativo del botón del minimapa.",
                    "Al pasar el ratón por la ventana transparente aparecen el asa y el interruptor. Las opciones y los comentarios quedan uno junto al otro.",
                }},
            }},
        { version = "1.2.0", date = "30.09.2026", sections = {
                { title = "Novedades", items = {
                    "Compatible con **Retail 12.1**. Quest Targets lee el registro de misiones y las placas de nombre visibles sin QuestieDB.",
                }},
                { title = "Correcciones", items = {
                    "Si no se puede leer el registro, la ventana muestra un aviso en lugar de una lista aparentemente vacía.",
                }},
            }},
        { version = "1.1.0", date = "28.09.2026", sections = {
                { title = "Novedades", items = {
                    "El **modo transparente** deja visible solo la lista de misiones. Usa el ojo para cambiar de vista. El icono se oculta al cabo de un momento.",
                }},
                { title = "Mejoras", items = {
                    "El botón de cierre y la barra de desplazamiento se adaptan al nuevo diseño.",
                }},
            }},
        { version = "1.0.22", date = "28.09.2026", sections = {
                { title = "Mejoras", items = {
                    "Se actualizó la integración con QuestieDB. La descarga pública del addon seguía usando el proveedor adecuado instalado por separado.",
                }},
            }},
        { version = "1.0.16", date = "27.09.2026", sections = {
                { title = "Novedades", items = {
                    "El **botón de comentarios** abre un enlace copiable para enviar errores o sugerencias. No necesitas una cuenta de GitHub.",
                }},
            }},
        { version = "1.0.15", date = "27.09.2026", sections = {
                { title = "Mejoras", items = {
                    "La **rueda del ratón y la barra de desplazamiento** sustituyen las flechas de página. Un control deslizante ajusta el tamaño de la ventana.",
                    "Se simplificaron los cuadros de información, los atajos tienen su propia sección y se actualizaron los textos de los seis idiomas.",
                }},
            }},
        { version = "1.0.13", date = "25.09.2026", sections = {
                { title = "Mejoras", items = {
                    "Si falta QuestieDB, el aviso indica el paquete adecuado para Classic Era o Forever. Selecciona el enlace en la ventana para copiarlo.",
                }},
            }},
        { version = "1.0.12", date = "25.09.2026", sections = {
                { title = "Novedades", items = {
                    "Compatible con **WoW Classic Era** 1.15.9, además de la beta de Forever.",
                }},
                { title = "Correcciones", items = {
                    "La lectura, el seguimiento y el estado de las misiones de Classic funcionan correctamente, al igual que el clic derecho para abrir el registro. Se conservan las coordenadas de aparición de Classic.",
                }},
            }},
        { version = "1.0.11", date = "25.09.2026", sections = {
                { title = "Novedades", items = {
                    "Primera versión documentada para la beta de Forever. Un botón por misión y un **botón principal** buscan enemigos para misiones activas o PNJ listos para recibir una entrega.",
                    "QuestieDB aporta enemigos para misiones de eliminación, objetivos compartidos y enemigos que sueltan objetos requeridos. Las placas de nombre legibles pueden aportar más objetivos.",
                    "La lista muestra el progreso, filtra las misiones seguidas y abre el registro con clic derecho. /qt abre o cierra la ventana.",
                    "Configura marcas, atajos, cuadros de información y seis idiomas desde las opciones de WoW.",
                    "La brújula aparece en el minimapa y puede actuar como botón principal móvil. El estilo clásico admite texto personalizado.",
                }},
            }},
    },
    frFR = {
        { version = "1.7.4", date = "Aperçu", sections = {
                { title = "Polestar", items = {
                    "**Cibles Polestar :** Sur WoW Forever, avec Polestar installé, activez **Boutons → Barre de ciblage → Suivre les cibles Polestar**, désactivé par défaut. La boussole principale recherche les objectifs ouverts nommés de l’étape affichée ; à défaut, elle recherche les objectifs de quête. Les changements s’appliquent après le combat. Si RestedXP est aussi activé et disponible, il est prioritaire.",
                }},
            }},
        { version = "1.7.3", date = "20.11.2026", sections = {
                { title = "Options", items = {
                    "Correction d’une erreur dans les **options sociales** de Blizzard.",
                }},
            }},
        { version = "1.7.2", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**Rares les plus proches en premier :** Le bouton violet trie les rares marqués et ceux de la zone selon la distance à leur point d’apparition connu le plus proche dans RareScanner.",
                }},
                { title = "Barre de ciblage", items = {
                    "**Position actuelle à chaque clic :** Hors combat, les boutons de ciblage relèvent ta position pour les recherches par distance uniquement lors d’un clic ou de l’utilisation d’un raccourci. Si tu as bougé, la recherche reprend au début de la liste actualisée. Si tu restes sur place, les clics suivants vérifient les noms suivants.",
                }},
            }},
        { version = "1.7.1", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**Conserver la cible :** Un rare vivant de la liste reste ciblé lorsque tu cliques de nouveau sur le bouton violet ou utilises son raccourci.",
                }},
                { title = "Barre de ciblage", items = {
                    "**Recherches séparées :** Le bouton principal rouge recherche les cibles de quête et, si l’intégration RestedXP est active, celles de l’étape actuelle du guide. Les boutons bleu de RestedXP, jaune d’ItemTree et violet de RareScanner utilisent chacun leur propre liste.",
                }},
            }},
        { version = "1.7.0", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**WoW Forever :** Le ciblage nécessite l’addon RareScanner. Il fonctionne hors combat et à portée de ciblage.",
                    "**Carte du monde :** Clique gauche sur un PNJ rare pour le marquer. Clique sur le **Bouton RareScanner** violet de la barre de ciblage pour rechercher tous les rares marqués. L’infobulle affiche la liste.",
                    "**Macro RareScanner :** Selon la longueur des noms, la macro peut rechercher **2 à 4 créatures rares par clic** en général. Si la liste en contient davantage, clique de nouveau pour rechercher les suivantes.",
                    "**Afficher le bouton RareScanner :** Tu peux masquer la boussole sous **Boutons → Barre de ciblage**. Elle est visible par défaut et grisée lorsqu’aucune cible ne peut être recherchée. Elle reste visible en combat et la recherche est désactivée.",
                    "**Cibler les rares de RareScanner :** Attribue deux touches au bouton violet sous **Raccourcis clavier**. Chaque pression lance la même recherche qu’un clic gauche.",
                    "**Rechercher tous les rares de la zone :** Active cette option sous **Boutons → Barre de ciblage** pour rechercher tous les PNJ rares répertoriés par RareScanner dans ta zone actuelle, y compris ceux qui ne sont pas marqués. La liste se met à jour quand tu changes de zone et inclut les rares du donjon actuel si RareScanner dispose de ces données. L’option est désactivée par défaut.",
                    "**Minicarte :** Clique gauche sur l’icône RareScanner d’un rare pour le rechercher. Une **impulsion radar** confirme le clic. Si la minicarte intercepte le premier clic, clique de nouveau pour tenter le ciblage.",
                }},
                { title = "Barre de ciblage", items = {
                    "**Barre de ciblage :** Sous **Boutons → Barre de ciblage**, règle la **Disposition des boutons** sur horizontale ou verticale et l’**Espacement des boutons** entre 0 et 32 px. Active **Afficher la bordure bronze** pour entourer toute la barre d’une bordure bronze aux angles biseautés inspirée des cadres d’unité de FlareUI. Par défaut, la barre est horizontale, avec un espacement de 4 px et sans bordure.",
                    "**Afficher les séparateurs :** Affiche ou masque les lignes dégradées de l’or à l’argent et leurs étoiles indépendamment de la bordure bronze. Elles pivotent lorsque la barre est verticale.",
                    "**Boussole de quête moderne :** Le bouton texte classique et ses options de largeur, de hauteur et de texte sont supprimés. La mise à jour remplace le bouton classique par la boussole à la position enregistrée. Règle sa taille sous **Boutons → Barre de ciblage → Taille du bouton**.",
                }},
                { title = "Fenêtre des notes de mise à jour", items = {
                    "**Notes de mise à jour :** L’historique s’ouvre une fois par compte à la première connexion avec une nouvelle version et reste ouvert jusqu’à ce que tu le fermes. Retrouve-le sous **Options → AddOns → Quest Targets → Notes de mise à jour**. Il suit la langue de l’addon.",
                }},
            }},
        { version = "1.6.1", date = "15.11.2026", sections = {
                { title = "Nouveautés", items = {
                    "**EllesmereUI :** Sur Forever, des boutons de ciblage s’ajoutent au Custom Quest Tracker. Clique gauche pour rechercher une cible ou clique droit pour mettre la quête en focus.",
                    "**Commentaires :** La fenêtre affiche un code QR pour ouvrir le formulaire.",
                }},
                { title = "Améliorations", items = {
                    "Associe un bouton de souris, la molette ou une combinaison de touches à un raccourci de ciblage depuis n’importe où dans la fenêtre de jeu.",
                    "Questie et EllesmereUI disposent de réglages d’espacement distincts sous **Boutons**.",
                    "Tu peux couper le son joué lorsque la cible est désélectionnée.",
                }},
            }},
        { version = "1.6.0", date = "10.11.2026", sections = {
                { title = "Nouveautés", items = {
                    "**Intégration d’ItemTree :** Installe et active ItemTree séparément. Ouvre la vue **Sources** d’un ingrédient, déplie **Show more** au besoin et clique sur **Import mobs**. Quest Targets importe les ennemis qui fournissent cet ingrédient.",
                    "**Ciblage ItemTree :** Active la boussole jaune sous **Boutons → Afficher le bouton ItemTree** ou attribue un raccourci à **Target ItemTree mobs**. Si le clic ne trouve aucune cible, clique de nouveau pour essayer d’autres noms.",
                    "**Macro de barre d’action :** Si un emplacement est disponible, l’importation crée la macro de personnage **ItemTree Mobs**. Fais-la glisser de la fenêtre des macros vers la barre d’action. Le bouton et son raccourci fonctionnent même sans emplacement de macro libre.",
                    "La **barre de ciblage** accueille le bouton principal rouge, le bouton bleu de RestedXP et le bouton jaune d’ItemTree.",
                }},
                { title = "Améliorations", items = {
                    "Déplace et redimensionne les trois boutons ensemble et choisis lesquels afficher.",
                    "ItemTree privilégie les cibles de ta zone et tient compte des points d’apparition connus.",
                }},
            }},
        { version = "1.5.1", date = "03.11.2026", sections = {
                { title = "Nouveautés", items = {
                    "Fais glisser le **coin inférieur droit** pour redimensionner la fenêtre des quêtes. Sa taille et sa position sont enregistrées.",
                    "Désactive les boutons de ciblage de Questie ou ajuste leur espacement.",
                }},
                { title = "Améliorations", items = {
                    "Le **bouton de minicarte** est mieux pris en charge par les addons qui regroupent les boutons de minicarte.",
                    "Les options affichent la version installée. La boussole devient le bouton principal par défaut dans les nouvelles configurations.",
                }},
            }},
        { version = "1.5.0", date = "03.11.2026", sections = {
                { title = "Améliorations", items = {
                    "Un téléchargement prend en charge Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever et Retail.",
                    "Quest Targets choisit les données de quête adaptées à ton client. Installe QuestieDB séparément si nécessaire.",
                }},
            }},
        { version = "1.4.2", date = "03.11.2026", sections = {
                { title = "Améliorations", items = {
                    "**QuestieDB** se télécharge et se met à jour séparément. Retail n’en a pas besoin.",
                }},
            }},
        { version = "1.4.1", date = "02.11.2026", sections = {
                { title = "Améliorations", items = {
                    "Les deux emplacements des raccourcis du bouton principal et du focus apparaissent dans les raccourcis de WoW. Quest Targets demande confirmation avant de réattribuer une touche.",
                    "Quest Targets apparaît dans les options des addons dès la connexion. Les réglages réservés à l’autre style de bouton sont grisés.",
                }},
                { title = "Corrections", items = {
                    "Les changements et suppressions dans les raccourcis de WoW sont conservés après un rechargement.",
                    "Le clic droit ouvre le journal des quêtes uniquement hors combat. Les associations entre cartes et cibles sont plus fiables.",
                }},
            }},
        { version = "1.4.0", date = "30.10.2026", sections = {
                { title = "Nouveautés", items = {
                    "Le bouton principal et le focus disposent chacun de deux raccourcis pour clavier et manettes compatibles.",
                }},
                { title = "Améliorations", items = {
                    "Modifie ou efface un raccourci sans perdre l’autre. Échap annule l’attribution.",
                }},
            }},
        { version = "1.3.0", date = "29.10.2026", sections = {
                { title = "Améliorations", items = {
                    "La version 1.3.0 publie ensemble le déplacement du bouton principal et QuestieDB 1.0.9 introduits en 1.2.9.",
                }},
            }},
        { version = "1.2.9", date = "28.10.2026", sections = {
                { title = "Nouveautés", items = {
                    "**Déplacer le bouton principal** ajoute une poignée dans les options. Confirme pour enregistrer, appuie sur Échap pour annuler ou réinitialise la position pour voir l’emplacement par défaut.",
                }},
                { title = "Améliorations", items = {
                    "Les paquets Classic et Forever incluaient la version de QuestieDB 1.0.9 adaptée à leur client.",
                }},
            }},
        { version = "1.2.8", date = "16.10.2026", sections = {
                { title = "Corrections", items = {
                    "QuestieDB 1.0.6, inclus dans les paquets, rétablit la compatibilité avec Questie 12.1.0.",
                }},
            }},
        { version = "1.2.7", date = "15.10.2026", sections = {
                { title = "Nouveautés", items = {
                    "Utilise **/qt debug** pour voir les détails de la dernière recherche de cible.",
                }},
                { title = "Corrections", items = {
                    "La **barre d’action** de WoW reste utilisable après avoir modifié les options de l’addon.",
                }},
            }},
        { version = "1.2.6", date = "12.10.2026", sections = {
                { title = "Corrections", items = {
                    "Les boutons principal et RestedXP fonctionnent encore si la liste des cibles rétrécit ou se vide pendant une étape du guide.",
                }},
            }},
        { version = "1.2.5", date = "09.10.2026", sections = {
                { title = "Nouveautés", items = {
                    "Clique droit sur une icône de quête dans Quest Targets ou Questie pour la mettre en focus. Un raccourci dédié cherche les cibles de cette seule quête.",
                    "Les options natives et compactes permettent de modifier directement le texte du bouton principal.",
                }},
                { title = "Améliorations", items = {
                    "Les boutons de Questie s’affichent automatiquement. RestedXP utilise les objectifs encore ouverts de l’étape actuelle.",
                    "La fenêtre de quêtes, le défilement et le déplacement sont plus fiables. Les objectifs terminés sont retirés des recherches.",
                }},
            }},
        { version = "1.2.4", date = "04.10.2026", sections = {
                { title = "Améliorations", items = {
                    "Si RestedXP ne fournit pas de cible valide, la recherche peut revenir aux quêtes en cours.",
                    "Les clics successifs conservent une cible valide tant qu’aucune autre cible correspondante n’est visible.",
                }},
            }},
        { version = "1.2.3", date = "03.10.2026", sections = {
                { title = "Nouveautés", items = {
                    "RestedXP peut chercher les donneurs de quête nommés explicitement avant que tu acceptes leur quête.",
                    "Prise en charge de Burning Crusade Classic et de Mists of Pandaria Classic.",
                }},
                { title = "Améliorations", items = {
                    "Quest Targets apparaît dans la catégorie Quêtes de la liste des addons. Sur Classic Era, les boutons de Questie affichent la boussole.",
                }},
            }},
        { version = "1.2.2", date = "03.10.2026", sections = {
                { title = "Nouveautés", items = {
                    "L’intégration facultative de RestedXP cherche les cibles dans l’étape active du guide. Un bouton Quest Targets apparaît auprès de RestedXP.",
                }},
            }},
        { version = "1.2.1", date = "02.10.2026", sections = {
                { title = "Nouveautés", items = {
                    "Un bouton de ciblage facultatif apparaît à côté de chaque quête dans le suivi de Questie.",
                }},
                { title = "Améliorations", items = {
                    "La prise en charge de l’interface de Forever a été mise à jour, la taille du bouton principal ajustée et le bouton de minicarte doté d’un cadre natif.",
                    "Dans la fenêtre transparente, le survol affiche la poignée et le bouton de bascule. Les options et les commentaires sont côte à côte.",
                }},
            }},
        { version = "1.2.0", date = "30.09.2026", sections = {
                { title = "Nouveautés", items = {
                    "**Retail 12.1** est pris en charge. Quest Targets lit le journal de quêtes et les barres d’info visibles sans QuestieDB.",
                }},
                { title = "Corrections", items = {
                    "Si le journal ne peut pas être lu, un message apparaît à la place d’une liste apparemment vide.",
                }},
            }},
        { version = "1.1.0", date = "28.09.2026", sections = {
                { title = "Nouveautés", items = {
                    "Le **mode transparent** n’affiche que la liste des quêtes. L’icône en forme d’œil change la vue et disparaît après un court instant.",
                }},
                { title = "Améliorations", items = {
                    "Le bouton de fermeture et la barre de défilement s’adaptent à la nouvelle disposition.",
                }},
            }},
        { version = "1.0.22", date = "28.09.2026", sections = {
                { title = "Améliorations", items = {
                    "L’intégration de QuestieDB a été mise à jour. Le téléchargement public utilisait toujours le fournisseur compatible installé séparément.",
                }},
            }},
        { version = "1.0.16", date = "27.09.2026", sections = {
                { title = "Nouveautés", items = {
                    "Le **bouton Commentaires** ouvre un lien à copier pour envoyer des rapports de bugs ou des suggestions. Aucun compte GitHub n’est nécessaire.",
                }},
            }},
        { version = "1.0.15", date = "27.09.2026", sections = {
                { title = "Améliorations", items = {
                    "La **molette et la barre de défilement** remplacent les flèches de page. Un curseur dans les options règle la taille de la fenêtre.",
                    "Les infobulles sont plus simples, les raccourcis ont leur propre section et les textes des six langues ont été mis à jour.",
                }},
            }},
        { version = "1.0.13", date = "25.09.2026", sections = {
                { title = "Améliorations", items = {
                    "Si QuestieDB manque, le message indique le bon paquet pour Classic Era ou Forever. Sélectionne le lien dans la fenêtre pour le copier.",
                }},
            }},
        { version = "1.0.12", date = "25.09.2026", sections = {
                { title = "Nouveautés", items = {
                    "Prise en charge de **WoW Classic Era** 1.15.9 en plus de la bêta de Forever.",
                }},
                { title = "Corrections", items = {
                    "Les quêtes Classic, leur suivi et leur achèvement sont correctement lus. Le clic droit ouvre le journal et les coordonnées d’apparition Classic sont conservées.",
                }},
            }},
        { version = "1.0.11", date = "25.09.2026", sections = {
                { title = "Nouveautés", items = {
                    "Première version documentée pour la bêta de Forever. Un bouton par quête et un **bouton principal** recherchent les ennemis des quêtes actives ou les PNJ prêts à recevoir une quête.",
                    "QuestieDB ajoute les cibles à éliminer, les cibles communes et les ennemis qui fournissent les objets requis. Les barres d’info lisibles peuvent fournir d’autres cibles.",
                    "La liste affiche la progression, filtre les quêtes suivies et ouvre le journal par clic droit. /qt ouvre ou ferme la fenêtre.",
                    "Configure les marqueurs, raccourcis, infobulles et les six langues dans les options de WoW.",
                    "La boussole apparaît sur la minicarte et peut servir de bouton principal déplaçable. Le style classique prend en charge un texte personnalisé.",
                }},
            }},
    },
    trTR = {
        { version = "1.7.4", date = "Önizleme", sections = {
                { title = "Polestar", items = {
                    "**Polestar rehber hedefleri:** WoW Forever'da Polestar yüklüyken varsayılan olarak kapalı **Düğmeler → Hedef çubuğu → Polestar hedeflerini izle** seçeneğini açın. Ana pusula, görüntülenen rehber adımındaki adlı açık hedefleri arar; hedef yoksa görev aramasına döner. Değişiklikler çatışmadan sonra uygulanır. RestedXP de açık ve kullanılabilir olduğunda önceliklidir.",
                }},
            }},
        { version = "1.7.3", date = "20.11.2026", sections = {
                { title = "Seçenekler", items = {
                    "Blizzard’ın **sosyal ayarlarındaki** bir hata düzeltildi.",
                }},
            }},
        { version = "1.7.2", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**En yakın nadirler önce:** Mor düğme, işaretli nadirleri ve bölge listesini RareScanner’daki en yakın bilinen ortaya çıkma noktasının uzaklığına göre sıralar.",
                }},
                { title = "Hedef çubuğu", items = {
                    "**Her tıklamada güncel konum:** Savaş dışında hedef düğmeleri, mesafeye göre arama yapmak için konumunu yalnızca tıkladığında veya kısayola bastığında okur. Hareket ettiysen arama güncellenen listenin başından başlar. Yerinde durursan sonraki tıklamalar sıradaki isimleri arar.",
                }},
            }},
        { version = "1.7.1", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**Hedefi koru:** Mor düğmeye yeniden tıkladığında veya kısayoluna bastığında arama listesindeki canlı nadir yaratık hedefte kalır.",
                }},
                { title = "Hedef çubuğu", items = {
                    "**Ayrı hedef aramaları:** Kırmızı ana düğme görev hedeflerini ve RestedXP entegrasyonu açıksa etkin rehber adımının hedeflerini arar. Mavi RestedXP, sarı ItemTree ve mor RareScanner düğmeleri kendi listelerinde arama yapar.",
                }},
            }},
        { version = "1.7.0", date = "19.11.2026", sections = {
                { title = "RareScanner", items = {
                    "**WoW Forever:** Hedefleme için RareScanner eklentisi gerekir. Arama savaş dışında ve WoW’un hedefleme menzili içinde çalışır.",
                    "**Dünya haritası:** Nadir bir NPC’yi işaretlemek için sol tıkla. Tüm işaretli nadir yaratıkları aramak için hedef çubuğundaki mor **RareScanner Düğmesi**ne tıkla. Bilgi kutusunda hedef listesi yer alır.",
                    "**RareScanner makrosu:** Adların uzunluğuna bağlı olarak makroya genellikle **tıklama başına 2–4 nadir yaratık** sığar. Listede daha fazlası varsa sıradakileri aramak için tekrar tıkla.",
                    "**RareScanner düğmesini göster:** Pusulayı **Düğmeler → Hedef çubuğu** bölümünden gizleyebilirsin. Varsayılan olarak görünür ve aranacak hedef olmadığında gri olur. Savaşta görünür kalır ve arama devre dışıdır.",
                    "**RareScanner nadirlerini hedefle:** **Kısayol tuşları** bölümünden mor düğmeye iki tuş atayabilirsin. Her basış sol tık gibi arama yapar.",
                    "**Bölgedeki tüm nadir yaratıkları ara:** RareScanner’ın bulunduğun bölge için listelediği işaretli ve işaretsiz tüm nadir yaratıkları aramak için **Düğmeler → Hedef çubuğu** bölümündeki bu seçeneği aç. Bölge değiştiğinde liste güncellenir ve RareScanner’da kayıtlıysa bulunduğun zindandaki nadir yaratıkları da içerir. Seçenek varsayılan olarak kapalıdır.",
                    "**Mini harita:** Bir nadir yaratığı aramak için RareScanner simgesine sol tıkla. Bir **radar dalgası** tıklamayı doğrular. İlk tıklamayı mini harita alırsa hedeflemeyi denemek için tekrar tıkla.",
                }},
                { title = "Hedef çubuğu", items = {
                    "**Hedef çubuğu:** **Düğmeler → Hedef çubuğu** altında **Düğme düzeni**ni yatay veya dikey seç, **Düğme aralığı**nı 0–32 piksel arasında ayarla. Tüm çubuğu FlareUI birim çerçevelerinden esinlenen köşeleri kırpılmış tek bir bronz kenarlıkla çevrelemek için **Bronz çerçeveyi göster** seçeneğini aç. Varsayılan düzen yataydır, aralık 4 pikseldir ve çerçeve kapalıdır.",
                    "**Ayırıcıları göster:** Yıldız uçlu altın-gümüş çizgileri bronz çerçeveden bağımsız olarak açıp kapat. Çubuk dikey olduğunda çizgiler de döner.",
                    "**Modern görev pusulası:** Klasik yazılı düğme ve genişlik, yükseklik ve yazı seçenekleri kaldırıldı. Güncellemeyle klasik düğmenin yerini kayıtlı konumda pusula alır. Boyutu **Düğmeler → Hedef çubuğu → Düğme boyutu** bölümünden ayarlayabilirsin.",
                }},
                { title = "Yama notları penceresi", items = {
                    "**Yama Notları:** Yeni sürümle ilk girişte geçmiş hesap başına bir kez açılır ve sen kapatana kadar açık kalır. **Seçenekler → AddOns → Quest Targets → Yama Notları** bölümünden açabilirsin. Notlar eklenti için seçtiğin dili kullanır.",
                }},
            }},
        { version = "1.6.1", date = "15.11.2026", sections = {
                { title = "Yenilikler", items = {
                    "**EllesmereUI:** Forever’da Custom Quest Tracker’a hedefleme düğmeleri eklenir. Hedef aramak için sol, göreve odaklanmak için sağ tıkla.",
                    "**Geri bildirim:** Penceredeki QR kodla geri bildirim formunu açabilirsin.",
                }},
                { title = "İyileştirmeler", items = {
                    "Fare düğmelerini, tekerleği ve tuş kombinasyonlarını oyun penceresinin herhangi bir yerinden hedef kısayolu olarak ata.",
                    "Questie ve EllesmereUI için ayrı aralık ayarları **Düğmeler** bölümünde yer alır.",
                    "Hedef seçimi kaldırıldığında çalan sesi kapatabilirsin.",
                }},
            }},
        { version = "1.6.0", date = "10.11.2026", sections = {
                { title = "Yenilikler", items = {
                    "**ItemTree entegrasyonu:** ItemTree’yi ayrı kur ve etkinleştir. Bir malzemenin **Sources** görünümünü aç, gerekirse **Show more** listesini genişlet ve **Import mobs** düğmesine tıkla. Quest Targets, o malzemeyi düşüren düşmanları içe aktarır.",
                    "**ItemTree hedefleme:** **Düğmeler → ItemTree düğmesini göster** ile sarı pusulayı aç veya kısayollarda **Target ItemTree mobs** için bir tuş ata. Tıklama hedef bulmazsa diğer adları denemek için tekrar tıkla.",
                    "**Eylem çubuğu makrosu:** İçe aktarma, mümkünse **ItemTree Mobs** adlı karakter makrosunu oluşturur. Makro penceresinden eylem çubuğuna sürükle. Hedef düğmesi ve kısayolu boş makro yuvası olmadan da çalışır.",
                    "**Hedef çubuğunda** kırmızı ana düğme, mavi RestedXP düğmesi ve sarı ItemTree düğmesi yer alır.",
                }},
                { title = "İyileştirmeler", items = {
                    "Üç düğmeyi birlikte taşıyabilir, yeniden boyutlandırabilir ve hangilerinin görüneceğini seçebilirsin.",
                    "ItemTree araması bulunduğun bölgedeki hedeflere öncelik verir ve bilinen ortaya çıkma noktalarını kullanır.",
                }},
            }},
        { version = "1.5.1", date = "03.11.2026", sections = {
                { title = "Yenilikler", items = {
                    "Görev penceresini yeniden boyutlandırmak için **sağ alt köşeyi** sürükle. Boyut ve konum kaydedilir.",
                    "Questie’nin hedefleme düğmelerini kapatabilir veya aralıklarını ayarlayabilirsin.",
                }},
                { title = "İyileştirmeler", items = {
                    "**Mini harita düğmesi**, mini harita düğmelerini bir araya toplayan eklentilerle daha iyi çalışır.",
                    "Ayarlar yüklü sürümü gösterir. Yeni ayarlarda ana düğme olarak pusula kullanılır.",
                }},
            }},
        { version = "1.5.0", date = "03.11.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "Tek indirme Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever ve Retail’i destekler.",
                    "Quest Targets, istemcine uygun görev verilerini seçer. Gereken istemcilerde QuestieDB’yi ayrı kur.",
                }},
            }},
        { version = "1.4.2", date = "03.11.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "**QuestieDB** ayrı indirilir ve güncellenebilir. Retail’de gerekli değildir.",
                }},
            }},
        { version = "1.4.1", date = "02.11.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "WoW’un tuş atamalarında ana düğme ve odak için iki yuva da yer alır. Quest Targets, atanmış bir tuşu değiştirmeden önce onay ister.",
                    "Quest Targets, girişten hemen sonra eklenti seçeneklerinde görünür. Diğer düğme stiline ait ayarlar gri gösterilir.",
                }},
                { title = "Düzeltmeler", items = {
                    "WoW’un tuş atamalarındaki değişiklikler ve silinen atamalar arayüz yeniden yüklendiğinde korunur.",
                    "Sağ tıklama görev günlüğünü yalnızca savaş dışında açar. Harita ve hedef eşleştirmeleri daha güvenilirdir.",
                }},
            }},
        { version = "1.4.0", date = "30.10.2026", sections = {
                { title = "Yenilikler", items = {
                    "Ana düğme ve odak, klavye ve desteklenen oyun kumandaları için ikişer kısayol yuvasına sahiptir.",
                }},
                { title = "İyileştirmeler", items = {
                    "Diğer kısayolu koruyarak bir atamayı değiştir veya sil. Atamayı iptal etmek için Escape’e bas.",
                }},
            }},
        { version = "1.3.0", date = "29.10.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "1.3.0 sürümü, 1.2.9’da sunulan ana düğme konum ayarlarını ve QuestieDB 1.0.9’u bir arada yayımlar.",
                }},
            }},
        { version = "1.2.9", date = "28.10.2026", sections = {
                { title = "Yenilikler", items = {
                    "**Ana düğmeyi taşı** ayarlara bir sürükleme tutamacı ekler. Kaydetmek için onayla, iptal etmek için Escape’e bas veya varsayılan konumu görmek için konumu sıfırla.",
                }},
                { title = "İyileştirmeler", items = {
                    "Classic ve Forever paketleri her istemciye uygun QuestieDB 1.0.9’u içeriyordu.",
                }},
            }},
        { version = "1.2.8", date = "16.10.2026", sections = {
                { title = "Düzeltmeler", items = {
                    "Paketlerdeki QuestieDB 1.0.6, Questie 12.1.0 ile uyumluluğu geri getirdi.",
                }},
            }},
        { version = "1.2.7", date = "15.10.2026", sections = {
                { title = "Yenilikler", items = {
                    "Son hedef aramasının ayrıntılarını **/qt debug** ile gör.",
                }},
                { title = "Düzeltmeler", items = {
                    "Eklenti seçenekleri değiştirildikten sonra WoW’un **eylem çubuğu** kullanılabilir kalır.",
                }},
            }},
        { version = "1.2.6", date = "12.10.2026", sections = {
                { title = "Düzeltmeler", items = {
                    "Bir rehber adımı sırasında görev hedeflerinin listesi kısalsa veya boşalsa da ana düğme ve RestedXP düğmesi çalışır.",
                }},
            }},
        { version = "1.2.5", date = "09.10.2026", sections = {
                { title = "Yenilikler", items = {
                    "Quest Targets veya Questie’de bir görev simgesine sağ tıklayarak göreve odaklan. Ayrı bir kısayol yalnızca o görevin hedeflerini arar.",
                    "Kompakt WoW seçeneklerinden ana düğmenin metnini doğrudan değiştirebilirsin.",
                }},
                { title = "İyileştirmeler", items = {
                    "Questie hedefleme düğmeleri otomatik görünür. RestedXP geçerli rehber adımının açık hedeflerini kullanır.",
                    "Görev penceresi, kaydırma ve sürükleme daha güvenilirdir. Tamamlanan hedefler aramadan çıkarılır.",
                }},
            }},
        { version = "1.2.4", date = "04.10.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "RestedXP uygun bir hedef sağlamazsa arama açık görevlere dönebilir.",
                    "Uygun başka bir hedef görünmüyorsa tekrar tıklamak geçerli hedefi korur.",
                }},
            }},
        { version = "1.2.3", date = "03.10.2026", sections = {
                { title = "Yenilikler", items = {
                    "RestedXP, görevlerini kabul etmeden önce adı açıkça belirtilen görev veren NPC’leri arayabilir.",
                    "Burning Crusade Classic ve Mists of Pandaria Classic desteği eklendi.",
                }},
                { title = "İyileştirmeler", items = {
                    "Quest Targets, eklenti listesinde görevler kategorisinde yer alır. Classic Era’da Questie hedefleme düğmeleri pusula simgesini gösterir.",
                }},
            }},
        { version = "1.2.2", date = "03.10.2026", sections = {
                { title = "Yenilikler", items = {
                    "İsteğe bağlı RestedXP entegrasyonu etkin rehber adımındaki hedefleri arar. RestedXP’nin yanında bir Quest Targets düğmesi görünür.",
                }},
            }},
        { version = "1.2.1", date = "02.10.2026", sections = {
                { title = "Yenilikler", items = {
                    "Questie takipçisinde her görevin yanına isteğe bağlı bir hedefleme düğmesi eklendi.",
                }},
                { title = "İyileştirmeler", items = {
                    "Forever arayüz desteği güncellendi, ana düğmenin boyutu ayarlandı ve mini harita düğmesi WoW çerçevesini kullanmaya başladı.",
                    "Şeffaf görev penceresinin üzerine gelince sürükleme tutamacı ve görünüm düğmesi belirir. Ayarlar ve geri bildirim yan yanadır.",
                }},
            }},
        { version = "1.2.0", date = "30.09.2026", sections = {
                { title = "Yenilikler", items = {
                    "**Retail 12.1** desteklenir. Quest Targets, görev günlüğünü ve görünür isim plakalarını QuestieDB olmadan okur.",
                }},
                { title = "Düzeltmeler", items = {
                    "Görev günlüğü okunamazsa pencere boş görünmek yerine bir uyarı gösterir.",
                }},
            }},
        { version = "1.1.0", date = "28.09.2026", sections = {
                { title = "Yenilikler", items = {
                    "**Şeffaf görünüm** yalnızca görev listesini gösterir. Görünümü göz simgesiyle değiştir. Simge kısa süre sonra kaybolur.",
                }},
                { title = "İyileştirmeler", items = {
                    "Kapatma düğmesi ve kaydırma çubuğu yeni düzene uyarlandı.",
                }},
            }},
        { version = "1.0.22", date = "28.09.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "QuestieDB bağlantısı güncellendi. Herkese açık eklenti paketi, ayrı kurulan uygun veri sağlayıcısını kullanmaya devam etti.",
                }},
            }},
        { version = "1.0.16", date = "27.09.2026", sections = {
                { title = "Yenilikler", items = {
                    "**Geri bildirim düğmesi** hata bildirmek veya öneri göndermek için kopyalanabilir bir bağlantı açar. GitHub hesabı gerekmez.",
                }},
            }},
        { version = "1.0.15", date = "27.09.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "Sayfa oklarının yerine **fare tekerleği ve kaydırma çubuğu** kullanılır. Ayarlardaki kaydırıcıyla görev penceresinin boyutunu değiştir.",
                    "Bilgi kutuları sadeleştirildi, kısayollara ayrı bölüm eklendi ve altı dildeki metinler güncellendi.",
                }},
            }},
        { version = "1.0.13", date = "25.09.2026", sections = {
                { title = "İyileştirmeler", items = {
                    "QuestieDB eksikse uyarı, Classic Era veya Forever için doğru paketi gösterir. Kopyalamak için penceredeki bağlantıyı seç.",
                }},
            }},
        { version = "1.0.12", date = "25.09.2026", sections = {
                { title = "Yenilikler", items = {
                    "Forever beta sürümünün yanı sıra **WoW Classic Era** 1.15.9 desteği eklendi.",
                }},
                { title = "Düzeltmeler", items = {
                    "Classic görevleri, takibi ve tamamlanma durumu doğru okunur. Sağ tıklama görev günlüğünü açar ve Classic ortaya çıkma koordinatları korunur.",
                }},
            }},
        { version = "1.0.11", date = "25.09.2026", sections = {
                { title = "Yenilikler", items = {
                    "Forever beta için belgelenen ilk sürüm. Her görev için bir düğme ve bir **ana düğme**, açık görevlerdeki düşmanları veya görevi teslim alacak NPC’leri arar.",
                    "QuestieDB; öldürme görevlerinin hedeflerini, ortak öldürme hedeflerini ve gerekli eşyaları düşüren düşmanları ekler. Okunabilir isim plakaları başka uygun hedefler sağlayabilir.",
                    "Görev listesi ilerlemeyi gösterir, takip edilen görevleri filtreler ve sağ tıklamayla görev günlüğünü açar. /qt pencereyi açar veya kapatır.",
                    "İşaretleri, kısayolları, bilgi kutularını ve altı dil seçeneğini WoW ayarlarından düzenle.",
                    "Görev pusulası mini haritada görünür ve taşınabilir ana düğme olarak kullanılabilir. Klasik düğmenin metni değiştirilebilir.",
                }},
            }},
    },
    zhCN = {
        { version = "1.7.4", date = "预览", sections = {
                { title = "Polestar", items = {
                    "**Polestar 指南目标：** 在 WoW Forever 中安装 Polestar 后，可在**按钮 → 目标按钮栏 → 跟随 Polestar 指南目标**启用默认关闭的选项。主罗盘会搜索当前显示步骤中有名称的未完成目标；没有目标时会回退到任务搜索。战斗中的更改会在战斗结束后应用。如果同时启用且可使用 RestedXP，则优先使用 RestedXP。",
                }},
            }},
        { version = "1.7.3", date = "2026年11月20日", sections = {
                { title = "选项", items = {
                    "修复了暴雪**社交设置**中的一个错误。",
                }},
            }},
        { version = "1.7.2", date = "2026年11月19日", sections = {
                { title = "RareScanner", items = {
                    "**优先搜索附近的稀有怪：** 紫色按钮会按 RareScanner 已知的最近刷新点距离，对已标记稀有怪和当前区域列表排序。",
                }},
                { title = "目标按钮栏", items = {
                    "**每次点击都读取当前位置：** 在战斗之外，只有点击目标按钮或按下快捷键时，才会读取你的位置并按距离搜索。如果你移动过，搜索会从更新后的列表开头开始。留在原地时，再次点击会继续搜索后续的名字。",
                }},
            }},
        { version = "1.7.1", date = "2026年11月19日", sections = {
                { title = "RareScanner", items = {
                    "**保留目标：** 再次点击紫色按钮或按下其快捷键时，已选中的存活稀有怪只要仍在搜索列表中，就会保持选中。",
                }},
                { title = "目标按钮栏", items = {
                    "**独立搜索：** 红色主按钮搜索任务目标，启用 RestedXP 集成后也会搜索当前指南步骤的目标。蓝色 RestedXP、黄色 ItemTree 和紫色 RareScanner 按钮各自使用自己的搜索列表。",
                }},
            }},
        { version = "1.7.0", date = "2026年11月19日", sections = {
                { title = "RareScanner", items = {
                    "**WoW Forever：** 搜索功能需要启用 RareScanner 插件。它仅在非战斗状态下可用，并受 WoW 的选定目标距离限制。",
                    "**世界地图：** 左键点击稀有 NPC 进行标记，再点击目标按钮栏中紫色的 **RareScanner 按钮**，即可搜索所有已标记的稀有怪。鼠标提示会列出目标。",
                    "**RareScanner 宏：** 根据名字的长度，宏通常**每次点击可搜索 2–4 只稀有怪**。如果列表中还有其他稀有怪，请再次点击以继续搜索。",
                    "**显示 RareScanner 按钮：** 可在 **按钮 → 目标按钮栏** 设置中隐藏罗盘。按钮默认显示，没有可搜索的目标时会变灰。战斗中按钮保持可见，搜索功能暂时停用。",
                    "**选定 RareScanner 稀有怪：** 在 **快捷键** 中可为紫色按钮设置两个按键。每次按键的效果与左键点击相同。",
                    "**搜索当前区域的所有稀有怪：** 在 **按钮 → 目标按钮栏** 设置中启用后，可搜索 RareScanner 在当前区域列出的所有稀有怪，包括未标记的稀有怪。切换区域时列表会更新，并包含 RareScanner 已收录的当前地下城稀有怪。此选项默认关闭。",
                    "**小地图：** 左键点击稀有怪的 RareScanner 图标即可搜索它。**雷达波纹**表示已收到点击。如果第一次点击被小地图处理，再点一次即可尝试选定目标。",
                }},
                { title = "目标按钮栏", items = {
                    "**目标按钮栏：** 在 **按钮 → 目标按钮栏** 设置中，可以将 **按钮排列** 设为横向或纵向，并将 **按钮间距** 调整为 0–32 像素。启用 **显示青铜边框** 后，整条按钮栏会显示一圈参考 FlareUI 单位框体样式的斜角青铜边框。默认横向排列，间距为 4 像素，边框关闭。",
                    "**显示分隔线：** 可独立于青铜边框开启或关闭带星形端点的金银渐变分隔线。按钮栏纵向排列时，分隔线会随之旋转。",
                    "**现代任务罗盘：** 经典文字按钮及其宽度、高度和文字设置已移除。更新后，经典按钮会在原位置自动切换为罗盘。可在 **按钮 → 目标按钮栏 → 按钮大小** 中调整大小。",
                }},
                { title = "更新说明窗口", items = {
                    "**更新说明：** 首次登录新版本时，每个账号会自动打开一次版本记录，窗口会保持打开，直到你关闭它。也可通过 **选项 → 插件 → Quest Targets → 更新说明** 随时打开。内容使用插件当前选定的语言。",
                }},
            }},
        { version = "1.6.1", date = "2026年11月15日", sections = {
                { title = "新增", items = {
                    "**EllesmereUI：** 在 Forever 上，Custom Quest Tracker 会显示目标按钮。左键搜索目标，右键聚焦任务。",
                    "**反馈：** 在反馈窗口中扫描二维码即可打开表单。",
                }},
                { title = "改进", items = {
                    "在游戏窗口内任意位置，都可以用鼠标按键、滚轮或组合键设置目标快捷键。",
                    "Questie 和 EllesmereUI 的按钮间距可分别在 **按钮** 设置中调整。",
                    "取消选定目标时播放的声音可以静音。",
                }},
            }},
        { version = "1.6.0", date = "2026年11月10日", sections = {
                { title = "新增", items = {
                    "**ItemTree 集成：** 单独安装并启用 ItemTree。打开材料的 **Sources** 视图，必要时展开 **Show more**，再点击 **Import mobs**。Quest Targets 会导入掉落该材料的敌人。",
                    "**ItemTree 目标搜索：** 在 **按钮 → 显示 ItemTree 按钮** 中启用黄色罗盘，或在快捷键设置中为 **Target ItemTree mobs** 绑定按键。如果未找到目标，再点一次可尝试搜索其他名字。",
                    "**动作条宏：** 如果有空闲宏槽位，导入时会创建角色宏 **ItemTree Mobs**。可将它从宏窗口拖到动作条。没有空闲宏槽位时，目标按钮和快捷键仍可使用。",
                    "**目标按钮栏**包括红色主按钮、蓝色 RestedXP 按钮和黄色 ItemTree 按钮。",
                }},
                { title = "改进", items = {
                    "三个按钮可一起移动和缩放，也可单独选择显示哪些按钮。",
                    "ItemTree 搜索会优先考虑当前区域内的目标，并参考已知刷新点。",
                }},
            }},
        { version = "1.5.1", date = "2026年11月3日", sections = {
                { title = "新增", items = {
                    "拖动任务窗口的 **右下角** 可调整大小。窗口大小和位置会保存。",
                    "可以关闭 Questie 的目标按钮或调整它们的间距。",
                }},
                { title = "改进", items = {
                    "**小地图按钮**与收纳小地图按钮的插件兼容得更好。",
                    "选项中会显示已安装的版本。新配置默认使用罗盘作为主按钮。",
                }},
            }},
        { version = "1.5.0", date = "2026年11月3日", sections = {
                { title = "改进", items = {
                    "同一个下载包支持 Classic Era、燃烧的远征怀旧服、熊猫人之谜怀旧服、Forever 和正式服。",
                    "Quest Targets 会为当前客户端选择对应的任务数据。需要 QuestieDB 的客户端须单独安装它。",
                }},
            }},
        { version = "1.4.2", date = "2026年11月3日", sections = {
                { title = "改进", items = {
                    "**QuestieDB** 可以单独下载和更新。正式服不需要它。",
                }},
            }},
        { version = "1.4.1", date = "2026年11月2日", sections = {
                { title = "改进", items = {
                    "WoW 的按键设置中，主按钮和焦点操作均显示两个快捷键槽位。覆盖已绑定的按键前会先询问确认。",
                    "登录后即可在插件选项中找到 Quest Targets。当前按钮样式不适用的控件会变灰。",
                }},
                { title = "修复", items = {
                    "在 WoW 按键设置中修改或清除的绑定，重载界面后仍会保留。",
                    "右键点击仅在非战斗状态下打开任务日志。地图和目标匹配更可靠。",
                }},
            }},
        { version = "1.4.0", date = "2026年10月30日", sections = {
                { title = "新增", items = {
                    "主按钮和焦点操作各有两个快捷键槽位，支持键盘和兼容手柄。",
                }},
                { title = "改进", items = {
                    "修改或清除一个绑定时会保留另一个。按 Esc 取消绑定操作。",
                }},
            }},
        { version = "1.3.0", date = "2026年10月29日", sections = {
                { title = "改进", items = {
                    "1.3.0 一并发布了在 1.2.9 中加入的主按钮位置设置和 QuestieDB 1.0.9。",
                }},
            }},
        { version = "1.2.9", date = "2026年10月28日", sections = {
                { title = "新增", items = {
                    "在选项中选择 **移动主按钮** 可显示拖拽手柄。确认后保存，按 Esc 取消，或重置以预览默认位置。",
                }},
                { title = "改进", items = {
                    "Classic 和 Forever 安装包当时包含各自对应的 QuestieDB 1.0.9。",
                }},
            }},
        { version = "1.2.8", date = "2026年10月16日", sections = {
                { title = "修复", items = {
                    "随安装包提供的 QuestieDB 1.0.6 恢复了与 Questie 12.1.0 的兼容性。",
                }},
            }},
        { version = "1.2.7", date = "2026年10月15日", sections = {
                { title = "新增", items = {
                    "使用 **/qt debug** 查看上一次目标搜索的详情。",
                }},
                { title = "修复", items = {
                    "更改插件选项后，WoW 的 **动作条**仍可正常使用。",
                }},
            }},
        { version = "1.2.6", date = "2026年10月12日", sections = {
                { title = "修复", items = {
                    "指南步骤中的任务目标列表缩短或变空时，主按钮和 RestedXP 按钮仍可使用。",
                }},
            }},
        { version = "1.2.5", date = "2026年10月9日", sections = {
                { title = "新增", items = {
                    "在 Quest Targets 或 Questie 中右键点击任务图标可聚焦任务。专用快捷键只搜索该任务的目标。",
                    "精简的原生选项支持直接编辑主按钮文字。",
                }},
                { title = "改进", items = {
                    "Questie 的目标按钮会自动显示。RestedXP 使用当前指南步骤尚未完成的目标。",
                    "任务窗口、滚动和拖拽更可靠。已完成的目标会从搜索列表中移除。",
                }},
            }},
        { version = "1.2.4", date = "2026年10月4日", sections = {
                { title = "改进", items = {
                    "如果 RestedXP 没有合适的目标，搜索可以切换到未完成的任务。",
                    "只要没有可见的合适替代目标，重复点击就会保留当前有效目标。",
                }},
            }},
        { version = "1.2.3", date = "2026年10月3日", sections = {
                { title = "新增", items = {
                    "RestedXP 可以在接任务前搜索指南中明确点名的任务发布者。",
                    "新增对燃烧的远征怀旧服和熊猫人之谜怀旧服的支持。",
                }},
                { title = "改进", items = {
                    "Quest Targets 位于插件列表中的任务类别。在 Classic Era 上，Questie 的目标按钮使用罗盘图标。",
                }},
            }},
        { version = "1.2.2", date = "2026年10月3日", sections = {
                { title = "新增", items = {
                    "可选的 RestedXP 集成会搜索当前指南步骤的目标。RestedXP 旁会出现 Quest Targets 按钮。",
                }},
            }},
        { version = "1.2.1", date = "2026年10月2日", sections = {
                { title = "新增", items = {
                    "Questie 任务追踪器中的每个任务旁可显示一个目标按钮。",
                }},
                { title = "改进", items = {
                    "更新了 Forever 界面支持和主按钮大小，并为小地图按钮加入 WoW 原生边框。",
                    "鼠标悬停在透明任务窗口上时会显示拖动手柄和切换开关。选项与反馈按钮并排显示。",
                }},
            }},
        { version = "1.2.0", date = "2026年9月30日", sections = {
                { title = "新增", items = {
                    "支持 **正式服 12.1**。Quest Targets 可直接读取当前任务日志和可见姓名板，无需 QuestieDB。",
                }},
                { title = "修复", items = {
                    "无法读取任务日志时会显示提示，避免窗口看起来只是一个空列表。",
                }},
            }},
        { version = "1.1.0", date = "2026年9月28日", sections = {
                { title = "新增", items = {
                    "**透明模式**只显示任务列表。点击眼睛图标即可切换，图标会在片刻后消失。",
                }},
                { title = "改进", items = {
                    "关闭按钮和滚动条已适配新布局。",
                }},
            }},
        { version = "1.0.22", date = "2026年9月28日", sections = {
                { title = "改进", items = {
                    "更新了 QuestieDB 数据接入。公开下载的插件仍使用另行安装的对应数据插件。",
                }},
            }},
        { version = "1.0.16", date = "2026年9月27日", sections = {
                { title = "新增", items = {
                    "**反馈按钮**会打开一个可复制的链接，用于提交错误报告或建议，无需 GitHub 账号。",
                }},
            }},
        { version = "1.0.15", date = "2026年9月27日", sections = {
                { title = "改进", items = {
                    "**鼠标滚轮和滚动条**取代翻页箭头。可用选项中的滑块调整任务窗口大小。",
                    "简化了鼠标提示，为快捷键添加独立区域，并更新了六种语言的文字。",
                }},
            }},
        { version = "1.0.13", date = "2026年9月25日", sections = {
                { title = "改进", items = {
                    "缺少 QuestieDB 时，提示会指向适用于 Classic Era 或 Forever 的安装包。可在窗口中选中链接进行复制。",
                }},
            }},
        { version = "1.0.12", date = "2026年9月25日", sections = {
                { title = "新增", items = {
                    "在 Forever 测试版之外，新增对 **WoW Classic Era** 1.15.9 的支持。",
                }},
                { title = "修复", items = {
                    "能够正确读取 Classic 任务、追踪和完成状态，并通过右键打开任务日志。保留 Classic 的刷新坐标。",
                }},
            }},
        { version = "1.0.11", date = "2026年9月25日", sections = {
                { title = "新增", items = {
                    "这是有记录的首个 Forever 测试版。每个任务的按钮与 **主按钮**可查找未完成任务所需的怪物或可交任务的 NPC。",
                    "QuestieDB 可补充击杀任务目标、共用击杀目标和掉落所需物品的敌人。可读取的姓名板也能提供更多匹配目标。",
                    "任务列表显示进度，可筛选追踪中的任务，右键打开任务日志。/qt 可打开或关闭窗口。",
                    "可在 WoW 选项中设置目标标记、快捷键、鼠标提示和六种语言。",
                    "任务罗盘会显示在小地图上，也可作为可移动的主按钮使用。经典样式支持自定义按钮文字。",
                }},
            }},
    },
}
