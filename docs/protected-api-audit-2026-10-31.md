# Prüfung geschützter Blizzard-Aufrufe — 31.10.2026

Geprüft wurde der aktuelle Arbeitsstand einschließlich der noch nicht
veröffentlichten Keybinding-Anpassungen: sämtliche 12 eigenen Lua-Laufzeitdateien
(4.214 Zeilen), Bindings.xml und SettingsCaption.xml. Für Classic Era, TBC,
Mists, Forever und Retail wurden 60 WoW-MCP-Linterläufe durchgeführt und die
Aufrufpfade manuell untersucht. Testcode, Buildskripte und fremder QuestieDB-
Quellcode sind keine im Spiel ausgeführten eigenen Addonmodule und nicht Teil
dieser Aussage. Die vollständigen Lintermeldungen liegen lokal unter
`dist/protected-api-lint.json`.

Dies ist eine Quellcodeprüfung, kein Test in fünf laufenden Clients. Insbesondere
hat die Forever-API-Datenbank keine vollständige Liste dokumentierter Globals;
der native MCP-UI-Quellstand ist nicht mit jedem aktuellen Build identisch.
Eine bereits entstandene Taint-Kette lässt sich damit nicht ausschließen.

## Auffällige Stellen

| Stelle | Ergebnis und Bedeutung |
| --- | --- |
| UI.lua:387–400, UI.lua:1431–1447 | Rechtsklick auf den Questtext führt vor der Kampfsperre zu UI.OpenQuest. Die Funktion prüft den Kampf selbst ebenfalls nicht und ruft QuestMapFrame_OpenToQuestDetails, QuestUtil.OpenQuestDetails, OpenQuestLog oder ShowUIPanel/QuestLog_SetSelection/QuestLog_Update auf. Fehlende Schutzbedingung, in der Lua-Testumgebung bestätigt. Je nach aktivem Clientpfad kann Blizzard das Öffnen verhindern bzw. der Helfer native UI-Daten beeinflussen. Kein Beweis für die frühere ActionBar-Fehlerursache. |
| UI.lua:932 | Direkter Aufruf SettingsPanel:RepairDisplay statt des nativen Inbound-Einstiegs. Interne Blizzard-Methode, kein belegter pauschal verbotener API-Aufruf. Taint-Prüfstelle: Es wird ein gemeinsam genutzter Anzeigepfad aus Addon-Kontext betreten. Der native Code kapselt den inneren Listenaufruf mit securecallfunction; deshalb wäre „verursacht sicher einen Block“ unbelegt. |
| UI.lua:990–1004 | AddShownPredicate-Callbacks für Breite, Höhe, Skalierung und Beschriftung. Blizzards Settings-Suche ruft ShouldShow für alle Initializer auf; ShouldShow ruft diese Addon-Funktionen direkt auf. Konkreter möglicher Taint-Eintritt in die gemeinsame Suche, aber noch kein Nachweis, dass daraus ein geschützter Folgeaufruf scheitert. |
| UI.lua:898, UI.lua:1045–1052 | Eigener GetName-Getter auf dem Initializer und Aktualisierung seiner Anzeigedaten. Gehört zur Addon-UI-Erweiterung; nicht automatisch verboten. Getter laufen beim Zeilenaufbau gekapselt. Keine Mutation von ActionBar-/SpellFlyout-Methoden gefunden. Bei weiterer Taint-Diagnose zusammen mit dem Suchpfad betrachten. |
| Proximity.lua:42–45 | loadstring(value), optional setfenv(chunk, {}), danach pcall(chunk), um QuestieDB-Kartentabellen zu lesen. In allen fünf Linterläufen dieselbe einzelne Fehlerregel. loadstring existiert laut API-Datenbank; dies ist kein nachgewiesener Blizzard-only-Aufruf. Der Code bleibt Addon-/insecure-Code, erhält keine geschützten Rechte. Die leere Umgebung beschränkt globale Zugriffe, sofern setfenv vorhanden ist. Ein Datenparser wäre eine getrennt zu prüfende Alternative. Keine Aussage über eine automatische Ablehnung durch Addon-Plattformen aus dieser Linterregel ableiten. |

## Geschützte Operationen, derzeit mit Schutzbedingungen

Die folgenden Aufrufe sind eingeschränkt, aber für Addons im passenden
Ausführungskontext vorgesehen. Ihre bloße Verwendung ist kein Fehler.

| Datei und Einstieg | Einschränkung / vorhandene Absicherung |
| --- | --- |
| UI.lua:28–77 | SetBinding, SetBindingClick und Rollback; SaveBindings. setBindingSlot prüft InCombatLockdown. Der zweite Aufrufer SyncFocusBinding (81) prüft ebenfalls den Kampf. Die Bestätigung prüft zusätzlich erneut Kampf und unveränderte Belegung. |
| UI.lua:295–449 | Erzeugung der SecureActionButton-Zeilen, Größe, Position, Attribute und Sichtbarkeit. UI.Create wird aus app:Refresh nach der Kampfsperre in Main.lua:51 aufgerufen. Der Menürahmen ist über seine Secure-Kinder ebenfalls geschützt. |
| UI.lua:381–402 | PreClick/PostClick setzen macrotext1 nur außerhalb des Kampfes. Ausnahme: Der zuvor beschriebene Rechtsklick-Questlogpfad liegt vor der PostClick-Kampfsperre. |
| UI.lua:1454–1511 | SetScale, SetAttribute, Show/Hide und weitere Zeilenänderungen. Render und RenderRows beginnen mit assert(not InCombatLockdown()); normale Aufrufer Refresh/Scroll/ToggleFocus fangen den Kampf ab. Ein assert ist eine Fehlererkennung, keine nachträgliche Berechtigung. |
| UI.lua:1384–1409 | ClearAllPoints/SetPoint beim Wiederherstellen; StopMovingOrSizing beim Beenden eines Drags. RestorePosition wird aus abgesicherten Erzeugungs-/Resetpfaden aufgerufen. StopMoving verschiebt den geschützten Abschluss auf nach dem Kampf. |
| Main.lua:49–147, Main.lua:288–300 | Zentraler Refresh/Poll/Toggle/Reset: Kampfprüfungen und spätere Übernahme schützen normale Render-/Sichtbarkeits-/Positionsänderungen. |
| Master.lua:7–143 | Secure-Master/Fokus-Button: CreateFrame, Attribute, Position, Größe und Show/Hide. RenderMaster setzt einen Out-of-combat-Assert voraus; RenderFocus sowie PreClick/Attribut-PostClick prüfen den Kampf. |
| Master.lua:146–167 | SetSize des geschützten Masterbuttons. Kein eigener Guard im Helfer; derzeit nur aus dem abgesicherten RenderMaster aufgerufen. Bei neuen Aufrufern beachten. |
| Master.lua:269–271, 285–361 | Positionsvorschau und Übernahme verwenden ClearAllPoints/SetPoint auf dem Master. Aufrufer prüfen den Kampf; bei Kampfbeginn wird nur eine spätere Position gespeichert. |
| Master.lua:314–352 | StopMovingOrSizing/Hide auf dem separaten Editor werden zum Teil im Kampf ausgeführt. Der Editor ist ein eigener ungeschützter UIParent-Frame, weder Secure-Parent noch Anker des Masterbuttons. Deshalb kein nachgewiesener Combat-Verstoß. Nicht mit dem geschützten Master verwechseln. |
| Master.lua:408–435 | HideUIPanel(SettingsPanel/InterfaceOptionsFrame) bzw. Hide als Fallback. BeginMasterMove prüft den Kampf vor diesem Pfad. Native UI-Umschaltung, daher weiterhin eine Integrationsstelle; derzeit kein ungeschützter Kampfaufruf gefunden. |
| QuestieTracker.lua:8–57, 85–129 | Secure-Buttons, SetAttribute, Show/Hide und absolute Positionierung. Sync sowie Klickhandler prüfen den Kampf. Parent und Anker sind UIParent, nicht Questies Tracker. |
| RestedXP.lua:70–131, 152–281 | Secure-Button, macrotext1, Show/Hide und Positionierung. Sync/PreClick/PostClick und verzögerte Aktualisierung prüfen den Kampf. setMacro ist privat und wird über diese abgesicherten Wege erreicht. Parent/Anker sind UIParent. |
| Core.lua:98–120, 175–242, 295–363 | /targetexact, /cleartarget und /tm werden als Makrotext erzeugt und über SecureActionButtonTemplate bei Hardware-Klick/Keybind ausgeführt. Keine direkten TargetUnit-/SetRaidTarget-/CastSpell-/UseAction-Aufrufe. In einigen vorbereiteten Makros ist Zielsuche im Kampf ohne lebendes feindliches Ziel weiterhin möglich; der Stopmacro-Ausdruck ist keine allgemeine Kampfsperre. Das ist erlaubte Secure-Makro-Ausführung, keine Erlaubnis für Lua-Attributänderungen im Kampf. |

## Weitere Module und Abgrenzung

- Core.lua:420–495 liest moderne Questlog-APIs mit geprüften Classic-Fallbacks.
  Retail-Lintermeldungen zu GetQuestLogTitle/GetNumQuestLogEntries betreffen
  diese bedingten Fallbacks und belegen keinen Aufruf entfernter APIs im
  normalen Retail-Pfad.
- Scanner.lua:74–132 liest C_TooltipInfo/GetNamePlates außerhalb des Kampfes;
  kein sichtbarer Tooltip wird zum Scannen manipuliert und kein Ziel geändert.
- Database.lua, Resolvers.lua, Locale.lua: keine direkte geschützte Spielaktion
  gefunden. BINDING_NAME-/HEADER-Globals gehören zum vorgesehenen eigenen
  Binding-Namensraum.
- Diagnostics.lua beobachtet Fehler und liest Daten. Es ersetzt keine
  Blizzard-Methode und ruft keine geschützte Aktion auf. Die bekannte
  Nichtunterstützung tabellenwertiger issecurevariable-Schlüssel ist ein
  Diagnoseproblem, keine geschützte Spielaktion.
- Bindings.xml enthält native CLICK-Einträge, keinen Lua-Zielwechsel.
  SettingsCaption.xml definiert ausschließlich eigene UI-Templates.
- Keine direkten Zugriffe gefunden, die MainActionBar:SetPointBase,
  SpellFlyout:Hide, UseAction, TargetUnit, CastSpellByName oder SetRaidTarget
  aus unserem Lua-Code ausführen oder ihre nativen Handler ersetzen.

## Einordnung der fünf Flavors

Classic, TBC, Mists, Forever und Retail teilen denselben eigenen Laufzeitcode;
die grundlegenden Combat-/Secure-Regeln gelten in allen fünf. Die tatsächliche
Questlog-Implementierung und native Settings-Interna sind clientabhängig.
Die Linterwarnungen zu Frame-Methoden sind konservativ und verfolgen weder
alle Aufrufer-Guards noch den tatsächlichen Parent-/Ankergraph vollständig.
Deshalb werden die Warnungszahlen nicht als Anzahl realer Fehler ausgegeben.

Referenz für den Questlogpfad: Blizzard_UIPanels_Game/Mainline/QuestMapFrame.lua
1175–1178 und 2182–2185; ShowUIPanel prüft in
Blizzard_UIParentPanelManager/Shared/UIParentPanelManager.lua:886
CheckProtectedFunctionsAllowed, bevor es an den nativen Delegate übergibt.
Referenz für Settings: Blizzard_SettingsPanel.lua:802–808 und 612–638,
Blizzard_SettingsList.lua:106–137 sowie SettingsSearchableElementMixin.ShouldShow.
Alle mit dem WoW MCP gelesen. Der Rechtsklickpfad wurde zusätzlich in einem
einmaligen Lua-Test nachvollzogen: Mit combat=true wird der Questlog-Helfer
aufgerufen. Das bestätigt die fehlende Addon-Sperre, nicht eine bestimmte
Taint-Folge in einem laufenden Client.

Es wurden für diese Prüfung keine Laufzeitdateien geändert.
