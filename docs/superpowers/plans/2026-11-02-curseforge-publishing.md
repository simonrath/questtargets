# CurseForge-Veröffentlichung vorbereiten

Ziel: Veröffentlichte stabile GitHub-Releases automatisch als fünf vorhandene
Flavor-Pakete an CurseForge-Projekt 1709717 übertragen. Kein Neubau beim Upload.
Aktivierung und API-Token bleiben manuelle Repository-Einstellungen.

1. Tests für Release-/ZIP-/Prüfsummenprüfung, eindeutige Game-Version-Auflösung,
   spielerorientierte Patchnotes und Wiederholungsschutz schreiben und rot ausführen.
2. Python-Standardbibliothek + vorhandene GitHub-CLI verwenden. Alle Pakete vor dem
   ersten Upload prüfen. Vor jedem POST eine eindeutige GitHub-Referenz reservieren;
   unsichere Upload-Ergebnisse niemals automatisch wiederholen.
3. GitHub-Workflow für release/published und manuelle Dry-Runs erstellen; Token als
   Secret, Freischaltung als Variable, Actions auf Commit pinnen. Keine PR-Uploads.
4. Englische Spieler-Patchnotes pro Version getrennt von Entwickler-Release-Details
   pflegen und automatisch übernehmen. Beispiel 1.4.1 und Anleitung ergänzen.
5. Unit-Tests, vorhandene Addon-Tests und lesenden Dry-Run gegen GitHub ausführen.
   Ohne CurseForge-Token keinen echten Upload behaupten oder durchführen.

Referenzen: XERJ qtrefs: Questie/upload-cf.sh (vorgebautes Artefakt, X-API-TOKEN,
Versions-IDs, Reservierung vor Upload), offizieller CurseForge Upload API-Artikel
9000197321, GitHub Actions release/published-Dokumentation. Ansatz unabhängig
implementieren; keinen ungeprüften fremden Code übernehmen.
