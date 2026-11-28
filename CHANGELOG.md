# Next – Patchnotes

Spielerchronik ab der ersten belegten Veröffentlichung. Die neueste Version steht oben. Historische Angaben zu Downloads und QuestieDB gelten jeweils für die genannte Version.

[English](docs/changelog/enUS.md) · [Español](docs/changelog/esES.md) · [Français](docs/changelog/frFR.md) · [Türkçe](docs/changelog/trTR.md) · [简体中文](docs/changelog/zhCN.md)

## 1.8.5 – 28.11.2026

### Einführung
- **Next Intro:** Mrrml hilft neuen Spielern beim Einstieg in Next. Öffne das Intro unter **Next > Allgemein > Einführung > Starten** in den Addon-Optionen oder mit **/qt intro**.

## 1.8.4 – 27.11.2026

### SilverDragon
- **Neu: SilverDragon-Unterstützung!** Der violette Rare-Button und sein Hotkey visieren den auf der Weltkarte fokussierten SilverDragon-Rare an. **Alle Rares im Gebiet suchen** ist standardmäßig an und durchsucht die bekannten Rares der aktuellen Zone. Wenn beide Addons verfügbar sind, hat RareScanner Vorrang. Der Button erscheint automatisch, sobald eines der beiden Addons verfügbar ist.

### Patchnotes
- Ein Zwerg und ein Murloc begrüßen dich mit Sprechblasen im Patchnotes-Fenster.
- **Neue Patchnotes beim Start anzeigen** ist standardmäßig aus. Du kannst die Option unten im Patchnotes-Fenster aktivieren.

### Standardeinstellungen
- **Automatische Modulauswahl:** Sobald ein kompatibles Addon geladen ist, aktiviert Next dessen Integration und zeigt die zugehörigen Zielbuttons an. Manuell ausgeschaltete Module bleiben aus.
- Das Questfenster startet ausgeschaltet. Modulsuche, Trennlinien, Button-Tooltips und das Stummschalten des Abwahl-Sounds sind aktiv. Der Leistenabstand beträgt 0 px. Der Rare-Button verwendet Ping auf unterstützten Clients.
- Der **Standardwerte**-Button in den Next-Optionen auf Forever setzt nur Next-Optionen zurück.

## 1.8.3 – 26.11.2026

### FlareUI
- **Neu: FlareUI ist jetzt integriert!** Aktiviere unter **Buttons & Leiste** die **FlareUI-Integration**, um neben unterstützten Quests im FlareUI-Tracker einen Next-Zielbutton anzuzeigen. Linksklick visiert ein Ziel an, Rechtsklick setzt den Questfokus. Benötigt FlareUI 7.0.17 oder neuer auf Forever. Im Kampf werden die Buttons ausgeblendet.

### Questliste
- **Questbuttons:** Ein weiteres Klicken behält ein lebendes Ziel der ausgewählten Quest bei. Das gilt für die Next-Questliste und die Buttons in Questie, EllesmereUI und FlareUI.

### ItemTree
- Der **ItemTree-Button** zeigt im Tooltip alle aktuell importierten Mobnamen an.

### Zielleiste
- Die **Tooltips der Zielleiste** beginnen jetzt mit **Next**. Der Masterbutton erklärt kürzer, welche Ziele er sucht und wie sich die Leiste verschieben lässt.

## 1.8.2 – 25.11.2026

### Follow The Arrow
- **Neu: Follow The Arrow ist jetzt integriert!** Aktiviere unter **Buttons & Leiste** die Option **Follow-The-Arrow-Guideziele verwenden**. Der Masterbutton übernimmt dann die Ziele des aktuellen Guide-Schritts aus **FTA Target**. Das funktioniert auch ohne QuestieDB. Das Makro muss in Follow The Arrow aktiviert sein. Die aktuelle Retail-Ausgabe von Follow The Arrow stellt es nicht bereit.

Danke an **EscapeKeyEscapee** für den Vorschlag, Follow The Arrow zu unterstützen!

### Polestar
- Der **Masterbutton** versucht zuerst das aktuelle Polestar-Ziel, wenn QuestieDB fehlt und RestedXP keine Ziele liefert.
- Wer nur Polestar als Guide verwendet, bekommt beim Einloggen keinen Hinweis auf fehlendes QuestieDB.
- Der **Masterbutton** berücksichtigt jetzt auch Gegner, die Polestar als Quellen für Sammelziele oder Ziele für den Einsatz eines Questgegenstands vorgibt.
- Wenn du Polestar ohne QuestieDB verwendest, erklärt das Questfenster, wie du die Polestar-Suche in Next einschaltest.

### RareScanner
- Der **RareScanner-Button** berücksichtigt jetzt die Einstellung **Button-Tooltips anzeigen**.
- Ist nur ein Rare in der Liste, verwirft der violette Button tote Ziele bei jeder Markierungseinstellung.
- Die **Zonensuche** lädt Fundorte in kleinen Gruppen. Die Zielnamen stehen sofort zur Suche bereit.

### Performance
- Namensplaketten lösen keine vollständige Questlog-Aktualisierung mehr aus. Die Zielleiste und Tracker-Buttons sparen Arbeit, wenn Ziele und Einstellungen gleich bleiben.

## 1.8.1 – 24.11.2026

### Addon-Name
- **Next** ist ab Version 1.8.1 der Name des Addons. Deine Einstellungen und Tastenkürzel werden beim Update übernommen.

## 1.8.0 – 24.11.2026

### Massive Verbesserungen
- **Gemeinsame Zielsuche** – Der Masterbutton durchsucht Questlog, RestedXP, Polestar, ItemTree und RareScanner gemeinsam, sofern die jeweilige Integration aktiv ist. Bei jedem Klick außerhalb des Kampfes kommen Ziele mit näheren bekannten Koordinaten zuerst, auch Abgabe-NPCs. Der blaue Button sucht nur RestedXP-Guideziele.
- **Alle Module durchsuchen** ist direkt unter **Masterbutton anzeigen** zu finden und standardmäßig aktiv. Schalte die Option aus, um mit dem Masterbutton nur Ziele aus dem Questlog zu suchen.
- **RareScanner-Button** – Aktualisiert die Entfernungsreihenfolge auch bei bereits anvisiertem Rare und prüft lesbare nahe Namensplaketten vor der nächsten Makroseite. Auch im Stand wird der nächste Rare bei jedem Klick erneut geprüft, sofern neben ihm noch ein weiterer Name ins Makro passt.

### Zielmarker
- **Markierung pro Button:** Wähle unter **Zielmarkierung** für jeden Zielbutton zwischen **Schlachtzugszeichen** und **Keine Markierung**. In WoW Forever und Retail steht auch **Ping** zur Auswahl. Ob du Pings im Chat siehst, stellst du in den WoW-Optionen ein.

Danke an **Caedis** für die Idee, gefundene Ziele zu pingen!

### Optionen
- Die nativen Optionen sind jetzt in **Quest Targets** und **Buttons & Leiste** gegliedert. **Patchnotes** und **Feedback** stehen unter **Allgemein**. Abhängige Optionen sind eingerückt und lassen sich einstellen, wenn die zugehörige Funktion verfügbar und aktiviert ist.
- Mit **Leistenhintergrund anzeigen** unter **Aussehen & Position** kannst du einen dunklen WoW-Hintergrund für die Buttonleiste einschalten. Der Bronzerahmen ist etwas dicker.

### Bekannte Probleme
- **Bekanntes Problem im deutschen Forever-Client** – Manche NPCs haben je nach Geschlecht unterschiedliche Namen. QuestieDB liefert pro NPC nur eine Namensform. Fehlt die im Spiel angezeigte Form, kann der Masterbutton den NPC bei der Namenssuche überspringen, etwa „Diebin der Wüstenläufer“.

## 1.7.5 – 22.11.2026

### Polestar
- **Polestar-Guideziele:** In WoW Forever kannst du mit installiertem Polestar unter **Buttons → Zielleiste → Polestar-Guideziele verwenden** die standardmäßig ausgeschaltete Option aktivieren. Der Masterbutton sucht benannte offene Ziele des angezeigten Guide-Schritts; ohne Ziele übernimmt die Questsuche. Änderungen werden nach dem Kampf angewendet. Ist auch RestedXP aktiv und verfügbar, hat es Vorrang.
- Bei Sammelzielen durchsucht der Masterbutton auch alternative NPC-Quellen. Ein bereits anvisierter, passender freundlicher NPC bleibt beim erneuten Klick ausgewählt.

Danke an **postblink** für die Polestar-Integration!

## 1.7.4 – 21.11.2026

### Questliste
- Die **Questliste** gruppiert Quests alphabetisch nach den Gebieten aus dem Questlog. Klicke außerhalb des Kampfes auf eine Gebietsüberschrift, um die Gruppe ein- oder auszuklappen. Die Auswahl wird pro Charakter gespeichert.

### Zielleiste
- **Position der Buttonleiste sperren** verhindert versehentliches Verschieben beim Rechtsziehen. Aktiviere die Sperre unter **Buttons → Zielleiste** oder halte außerhalb des Kampfes **Umschalt** über die Leiste und klicke auf das Schloss oben links.

Danke an **virtual_pip** für die Idee auf CurseForge!

### Patchnotes-Fenster
- Aktiviere **Künftige Patchnotes ausblenden** unten rechts, um das automatische Öffnen bei Updates zu überspringen. Unter **Optionen → AddOns → Quest Targets → Patchnotes** kannst du das Fenster weiterhin öffnen und die Einstellung zurücknehmen.

### Feedback
- Die **Scan-Anleitung** steht über dem QR-Code und der Hinweis zum Kopieren direkt über dem URL-Feld.

## 1.7.3 – 20.11.2026

### Optionen
- Fehler in Blizzards **Kontaktoptionen** behoben.

## 1.7.2 – 19.11.2026

### RareScanner
- **Nächste Rares zuerst:** Der violette Button sortiert markierte Rares und die Gebietsliste nach der Entfernung zum nächsten bekannten RareScanner-Spawnpunkt. So landen nahe Rares früher im Suchmakro.

### Zielleiste
- **Aktuelle Position bei jedem Klick:** Für die Suche nach Entfernung lesen die Zielbuttons deine Position außerhalb des Kampfes erst beim Klick oder Hotkey ein. Hast du dich bewegt, startet die Suche oben in der aktualisierten Liste. Bleibst du stehen, prüfen weitere Klicks die nächsten Namen.

## 1.7.1 – 19.11.2026

### RareScanner
- **Ziel behalten:** Ein lebender Rare aus der Suchliste bleibt ausgewählt, wenn du den violetten Button erneut anklickst oder seinen Hotkey drückst.

### Zielleiste
- **Getrennte Zielsuche:** Der rote Hauptbutton sucht Questziele und bei aktiver RestedXP-Integration auch Ziele des aktuellen Guide-Schritts. Der blaue RestedXP-, gelbe ItemTree- und violette RareScanner-Button suchen jeweils in ihrer eigenen Liste.

## 1.7.0 – 19.11.2026

### RareScanner
- **WoW Forever:** Die Zielsuche benötigt das Addon RareScanner. Sie funktioniert außerhalb des Kampfes und innerhalb von WoWs Zielreichweite.
- **Weltkarte:** Markiere Rare-NPCs per Linksklick. Klicke den violetten **RareScanner Button** in der Zielleiste an, um alle markierten Seltenen zu suchen. Der Tooltip zeigt die Suchliste.
- **RareScanner-Makro:** Je nach Namenslänge passen in der Regel **2–4 Rare-Mobs pro Klick** ins Makro. Sind mehr Rares in der Suchliste, klicke erneut, um die nächsten zu prüfen.
- **Show RareScanner Button:** Unter **Buttons → Zielleiste** kannst du den standardmäßig sichtbaren Kompass ausblenden. Ohne Suchziele ist er grau. Im Kampf bleibt er sichtbar und die Suche ist gesperrt.
- **RareScanner-Rares anvisieren:** Unter **Tastenkürzel** kannst du zwei Tasten für den violetten Button belegen. Die Tasten lösen dieselbe Suche aus wie ein Linksklick.
- **Alle Rares im Gebiet suchen:** Aktiviere die Option unter **Buttons → Zielleiste**, damit der RareScanner Button alle Rare-NPCs aus RareScanners Liste für dein aktuelles Gebiet sucht, auch ohne Markierung. Die Liste wechselt mit dem Gebiet und berücksichtigt auch Rares im aktuellen Dungeon, wenn RareScanner sie kennt. Standardmäßig ist die Option aus.
- **Minimap:** Linksklick auf das RareScanner-Symbol eines Seltenen sucht diesen Gegner. Der **Radarimpuls** bestätigt den Klick. Fängt die Minimap den ersten Klick ab, startet der nächste Klick den Zielversuch.

### Zielleiste
- **Zielleiste:** Unter **Buttons → Zielleiste** stellst du die **Button-Anordnung** auf horizontal oder vertikal und den **Button-Abstand** auf 0–32 px. Mit **Bronzerahmen anzeigen** erhält die gesamte Leiste einen gemeinsamen Bronzerahmen mit abgeschrägten Ecken im Stil der FlareUI-Einheitenfenster. Standardmäßig ist die Leiste horizontal, mit 4 px Abstand und ausgeschaltetem Rahmen.
- **Trennlinien anzeigen:** Schalte die gold-silbernen Linien mit Sternen unabhängig vom Bronzerahmen ein oder aus. Die Linien drehen sich bei vertikaler Anordnung mit.
- **Moderner Quest-Kompass:** Der klassische Textbutton und seine Optionen für Breite, Höhe und Schriftzug entfallen. Beim Update wechselt ein klassischer Button automatisch zum Kompass. Die Position bleibt gespeichert, die Größe stellst du unter **Buttons → Zielleiste → Buttongröße** ein.

### Patchnotes-Fenster
- **Patchnotes:** Beim ersten Login mit einer neuen Version öffnet sich die Chronik einmal pro Account und bleibt offen, bis du sie schließt. Du findest sie unter **Optionen → AddOns → Quest Targets → Patchnotes**. Die Chronik folgt deiner gewählten Addon-Sprache.

## 1.6.1 – 15.11.2026

### Neu
- **EllesmereUI:** Auf Forever gibt es Zielbuttons am Custom Quest Tracker. Linksklick sucht ein Ziel, Rechtsklick setzt den Questfokus.
- **Feedback:** Der Dialog zeigt einen QR-Code für das Formular.

### Verbessert
- Maustasten, Mausrad und Tastenkombinationen lassen sich überall im Spielfenster als Ziel-Hotkey erfassen.
- Questie und EllesmereUI haben getrennte Abstandsregler. Ihre Optionen stehen unter „Buttons“.
- Der Ton beim Abwählen eines Ziels lässt sich optional dämpfen.

## 1.6.0 – 10.11.2026

### Neu
- **ItemTree-Integration:** Installiere und aktiviere ItemTree separat. Öffne bei einer Zutat die Ansicht **Quellen**, klappe bei Bedarf **Mehr anzeigen** auf und klicke **Mobs übernehmen**. Quest Targets übernimmt die Gegner, die die Zutat fallen lassen.
- **ItemTree-Zielsuche:** Aktiviere unter **Buttons → ItemTree-Button anzeigen** den gelben Kompass oder belege unter **Hotkeys → ItemTree-Mobs anvisieren** eine Taste. Wenn ein Klick nichts findet, klick erneut, um weitere Namen zu prüfen.
- **Aktionsleisten-Makro:** Beim Import legt Quest Targets nach Möglichkeit das Charaktermakro **ItemTree Mobs** an. Du kannst es aus dem Makrofenster in die Aktionsleiste ziehen. Der Zielbutton und sein Hotkey funktionieren auch ohne freien Makroplatz.
- Die **Zielleiste** zeigt den roten Masterbutton, den blauen RestedXP-Button und den gelben ItemTree-Button.

### Verbessert
- Die drei Buttons lassen sich gemeinsam verschieben und skalieren. Du wählst, welche sichtbar sind.
- Die ItemTree-Suche bevorzugt Ziele in deiner Zone und berücksichtigt bekannte Spawnpunkte.

## 1.5.1 – 03.11.2026

### Neu
- Das Questfenster lässt sich an der **unteren rechten Ecke** vergrößern. Größe und Position bleiben gespeichert.
- Questies Zielbuttons lassen sich abschalten und ihr Abstand lässt sich einstellen.

### Verbessert
- Der **Minimap-Button** funktioniert besser mit Addons, die Minimap-Buttons sammeln.
- Die installierte Version steht in den Optionen. Neue Einstellungen starten mit dem Kompass als Masterbutton.

## 1.5.0 – 03.11.2026

### Verbessert
- Ein gemeinsamer Download unterstützt Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever und Retail.
- Quest Targets wählt die Questdaten für deinen Client. QuestieDB wird auf den Clients, die es brauchen, separat installiert.

## 1.4.2 – 03.11.2026

### Verbessert
- **QuestieDB** ist ein eigener Download und kann unabhängig aktualisiert werden. Für Retail ist es nicht erforderlich.

## 1.4.1 – 02.11.2026

### Verbessert
- Master und Fokus stehen mit beiden Belegungsplätzen in WoWs Tastenbelegung. Bei einer bereits belegten Taste fragt Quest Targets vor dem Überschreiben nach.
- Quest Targets erscheint direkt nach dem Login in den AddOn-Optionen. Regler für die jeweils andere Button-Optik sind ausgegraut.

### Behoben
- Änderungen und Löschungen in WoWs Tastenbelegung bleiben nach einem Neuladen erhalten.
- Rechtsklick öffnet das Questlog nur außerhalb des Kampfes. Karten- und Zielzuordnungen wurden zuverlässiger.

## 1.4.0 – 30.10.2026

### Neu
- Master und Fokus haben jeweils zwei Hotkey-Plätze für Tastatur und unterstützte Controller.

### Verbessert
- Eine Belegung lässt sich ändern oder löschen, ohne die zweite zu verlieren. Escape bricht die Eingabe ab.

## 1.3.0 – 29.10.2026

### Verbessert
- Die neue Masterbutton-Positionierung und QuestieDB 1.0.9 aus 1.2.9 wurden als Version 1.3.0 zusammen veröffentlicht.

## 1.2.9 – 28.10.2026

### Neu
- **Masterbutton verschieben** zeigt einen Ziehgriff in den Einstellungen. „Fertig“ speichert, Escape bricht ab und „Zurücksetzen“ zeigt die Standardposition.

### Verbessert
- Die Classic- und Forever-Pakete enthielten die zu ihrem Client passende QuestieDB 1.0.9.

## 1.2.8 – 16.10.2026

### Behoben
- QuestieDB 1.0.6 in den damaligen Paketen stellte die Kompatibilität mit Questie 12.1.0 wieder her.

## 1.2.7 – 15.10.2026

### Neu
- Mit **/qt debug** siehst du Informationen zur letzten Zielsuche.

### Behoben
- WoWs **Aktionsleiste** bleibt nach dem Ändern der Addon-Optionen bedienbar.

## 1.2.6 – 12.10.2026

### Behoben
- Master- und RestedXP-Button bleiben bedienbar, wenn die Liste der passenden Questziele während eines Guide-Schritts kleiner oder leer wird.

## 1.2.5 – 09.10.2026

### Neu
- Rechtsklick auf ein Quest-Symbol in Quest Targets oder Questie setzt den Fokus. Ein eigener Hotkey sucht nur Ziele für diese Quest.
- Kompakte native Optionen mit direkt bearbeitbarem Masterbutton-Text.

### Verbessert
- Questies Zielbuttons erscheinen automatisch. RestedXP berücksichtigt die aktuell offenen Ziele des Guide-Schritts.
- Questfenster, Scrollen und Ziehen wurden zuverlässiger. Erledigte Ziele bleiben nicht in der Suche hängen.

## 1.2.4 – 04.10.2026

### Verbessert
- Wenn RestedXP kein passendes Ziel liefert, kann die Suche zu offenen Quests zurückkehren.
- Ein gültiges Ziel bleibt bei weiteren Klicks ausgewählt, solange keine sichtbare passende Alternative gefunden wird.

## 1.2.3 – 03.10.2026

### Neu
- RestedXP kann ausdrücklich genannte Questgeber schon vor der Questannahme als Ziele anbieten.
- Unterstützung für Burning Crusade Classic und Mists of Pandaria Classic.

### Verbessert
- Quest Targets steht in der AddOn-Liste unter „Quests“. Auf Classic Era zeigen Questies Zielbuttons den Kompass.

## 1.2.2 – 03.10.2026

### Neu
- Die optionale RestedXP-Integration sucht nach passenden Zielen im aktiven Guide-Schritt. Ein Zielbutton erscheint bei RestedXP.

## 1.2.1 – 02.10.2026

### Neu
- Optionaler Zielbutton neben jeder Quest in Questies Tracker.

### Verbessert
- Neue Forever-Schnittstellenversion, überarbeitete Masterbutton-Größe und ein WoW-Rahmen für den Minimap-Button.
- Im transparenten Questfenster erscheinen Ziehhilfe und Umschalter bei Mausberührung. Einstellungen und Feedback stehen nebeneinander.

## 1.2.0 – 30.09.2026

### Neu
- **Retail 12.1** wird unterstützt. Dafür liest Quest Targets das laufende Questlog und sichtbare Namensplaketten ohne QuestieDB.

### Behoben
- Wenn das Questlog nicht gelesen werden kann, erscheint ein Hinweis statt einer scheinbar leeren Liste.

## 1.1.0 – 28.09.2026

### Neu
- Die **transparente Ansicht** lässt nur die Questliste stehen. Das Auge am Fenster schaltet die Ansicht um und blendet sich nach kurzer Zeit aus.

### Verbessert
- Schließen-Button und Scrollleiste wurden an das neue Layout angepasst.

## 1.0.22 – 28.09.2026

### Verbessert
- Die Datenanbindung an QuestieDB wurde aktualisiert. Die öffentliche Addon-Datei nutzte weiterhin den passenden separaten Datenanbieter.

## 1.0.16 – 27.09.2026

### Neu
- Der **Feedbackbutton** öffnet einen kopierbaren Link für Fehlerberichte und Wünsche. Dafür ist kein GitHub-Konto nötig.

## 1.0.15 – 27.09.2026

### Verbessert
- **Mausrad und Scrollleiste** ersetzen die Seitenpfeile. Ein Regler in den Optionen ändert die Fenstergröße.
- Tooltips wurden vereinfacht, Hotkeys bekamen einen eigenen Bereich und alle sechs Sprachen wurden aktualisiert.

## 1.0.13 – 25.09.2026

### Verbessert
- Fehlt QuestieDB, verweist der Hinweis auf das passende Paket für Classic Era oder Forever. Der Link lässt sich im Fenster zum Kopieren auswählen.

## 1.0.12 – 25.09.2026

### Neu
- Unterstützung für **WoW Classic Era** 1.15.9 neben der Forever-Beta.

### Behoben
- Classic-Quests, Verfolgung, Abschluss und Rechtsklick ins Questlog werden korrekt gelesen. Classic-Spawnkoordinaten bleiben unverändert.

## 1.0.11 – 25.09.2026

### Neu
- Erste belegte Version für die Forever-Beta. Ein Button pro Quest und ein **Masterbutton** suchen nach offenen Questmobs oder abgabebereiten NPCs.
- QuestieDB ergänzt Ziele aus Killquests, gemeinsame Killziele und Gegner, die benötigte Gegenstände fallen lassen. Lesbare Namensplaketten können weitere passende Ziele liefern.
- Die Questliste zeigt den Fortschritt, filtert verfolgte Quests und öffnet mit Rechtsklick das Questlog. /qt öffnet und schließt das Fenster.
- Zielmarkierung, Hotkey, Tooltips und sechs Sprachen lassen sich in den WoW-Optionen einstellen.
- Der Quest-Kompass erscheint an der Minimap und kann als beweglicher Masterbutton genutzt werden. Die klassische Variante kann einen eigenen Text anzeigen.
