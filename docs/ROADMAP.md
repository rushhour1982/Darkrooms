# Dark Rooms – Entwicklungs-Roadmap für Version 0.1

## 1. Dokumentstatus

**Dokumentversion:** 0.2 · **Datum:** 20.09.2026 · **Status:** Fachlich grundsätzlich freigabefähig; Entwicklungsworkflow angepasst, abschließende Freigabe ausstehend; noch keine Implementierung begonnen.

Grundlage sind AGENTS.md, CLAUDE.md, README.md sowie das freigegebene [GAME_DESIGN.md](GAME_DESIGN.md), [TECHNICAL_DESIGN.md 0.2](TECHNICAL_DESIGN.md), [DECISIONS.md](DECISIONS.md) und [ARCHITECTURE.md 0.2](ARCHITECTURE.md). ROADMAP.md und TASKS.md waren bislang Platzhalter. Dieses Dokument ändert weder die fachlichen Beschlüsse noch die Architektur.

Das GDD bleibt fachliche Quelle der Wahrheit. Die angenommenen ADRs konkretisieren dort zuvor offene Teilfragen, insbesondere First Person, kontrollierte Interaktion, einen vollständig geladenen kleinen Slice, Godot-3D-Navigation und die sichere Speicherpolitik. Die Architektur wurde inzwischen ausdrücklich freigegeben; ihr früherer Dokumentstatus „zur Freigabe“ ist kein erneuter Blocker. Neue technische oder fachliche Entscheidungen werden durch diese Roadmap nicht still getroffen.

**Planungsbasis:** Godot 4.7.2 Stable, GDScript ohne C#/.NET, Windows x86-64, Tastatur/Maus, Singleplayer, eine Kreatur, 16 GB RAM. Die tatsächliche GPU und der Renderer sind weiterhin offen. Die Architektur bleibt Main-basiert ohne Autoloads, mit einer Systems Sandbox, lokalen Zustandsbesitzern und dem freigegebenen Save-/Restore-Vertrag.

**Statuslesart:** Alle Phasen, Tests, Reviews und Git-Momente sind geplant, nicht ausgeführt. Ein Entscheidungsgate verlangt eine ausdrückliche Auswahl oder einen dokumentierten Testbefund vor dem betroffenen Auftrag. Ein vorläufiges Testprofil ist keine endgültige Gameplayentscheidung. Diese Roadmap ist keine Erlaubnis, jetzt bereits Code, Szenen oder weitere Dateien anzulegen.

## 2. Ziel der Roadmap

Version 0.1 soll ein eigenständig spielbarer, installierbarer Windows-Vertical-Slice mit ungefähr 15–25 Minuten Inhalt werden, nicht nur eine technische Demonstration. Bewegung, Erkundung, zwei unterschiedliche Rätsel, wahrnehmungsbasierte Bedrohung, Storyfortschritt und hochwertige Atmosphäre müssen zusammen funktionieren.

Die Roadmap gliedert die Arbeit in **13 Phasen (P0–P12)** und **neun Milestones (M0–M8)**. Sie beschreibt Ergebnisse, Abhängigkeiten, Entscheidungsgates und Abnahmen. Konkrete Implementierungsaufträge für Claude Code und deren Dateifreigaben folgen erst in TASKS.md; Senior-Reviews durch Codex / Astra High werden gesondert gekennzeichnet.

Die wichtigsten sichtbaren Zwischenstände:

- P0: Anwendung startet im Editor und als Windows-Export.
- P1: Erstmals selbst spielbare First-Person-Sandbox; erster Junior-Test.
- P2/P3: Türen, Schalter, Aufnahmen, Inventar, Lampe, Tempoeffekt und verständlicher Niederlagen-/Neustartablauf.
- P4: Erste vollständige wahrnehmungsbasierte Verfolgung mit Suche und Entkommen.
- P5: Beide Speicherarten funktionieren auch nach Beenden und Neustarten des Spiels.
- P6: Zwei gemeinsam freigegebene Rätsel und echte Storybedingungen funktionieren in der Sandbox.
- P7: Erster nahezu vollständiger Spielablauf im eigenen Roh-Slice, vom Start bis zum Cliffhanger; Präsentation noch teilweise provisorisch.
- P11: Präsentabler, zusammenhängender Slice im überprüften 15–25-Minuten-Zielbereich.
- P12: Stabilisierte, installierbare Releasefassung 0.1.0.

## 3. Produktionsprinzipien

1. **Früh spielbar, fortlaufend verbessern.** Jede Phase endet mit einem sichtbaren Teststand. P0 wird nicht zu einer monatelangen Infrastrukturphase: nur das, was Start, erste Bewegung und Prüfung ermöglicht.
2. **Vorhandene Architektur ausbauen, keine zweite schaffen.** Eine Sandbox wächst schrittweise. Frühe Prüfkörper, Restore-Grundablauf und UI werden später weiterverwendet, nicht als konkurrierende Systeme neu geschrieben.
3. **Risiken vor davon abhängigem Inhalt.** Bewegung/Traversal, Türnavigation, Wahrnehmung, Speichern und Rendering werden getestet, bevor ein fertiges Level auf unbewiesenen Annahmen beruht.
4. **Funktionen früh, Feinschliff später.** Sound, Eingabesicherheit und verständliche Rückmeldung gehören bereits zu Prototypen. P8–P10 sind keine Aufschiebemöglichkeit für fehlende Kernfunktionen.
5. **Nur benötigte Fragen jetzt entscheiden.** Ein offenes Storydetail blockiert keine Bewegung. Ungeklärte Speicherregeln blockieren dagegen die abhängige Save-Implementierung. Gates in §6 begrenzen jeweils nur den betroffenen Teil.
6. **Phasen-Done ist keine Gesamtfreigabe.** Ein System wird zunächst mit vorhandenen Nachbarn abgenommen. Tests mit späteren Nachbarn werden verbindlich wiederholt: insbesondere Movement/Traversal mit Restore in P5 und reale Rätsel-/Story-Saves in P6/P7. Nicht ausführbare spätere Tests gelten nicht als bestanden.
7. **Junior testet echte Fragen.** Kurze beaufsichtigte Tests beginnen früh. Verständlichkeit und Spaß sind getrennt von technischer Fehlerfreiheit zu beobachten; Horrorgrenzen werden vor entsprechenden Inhalten gemeinsam geklärt.
8. **Keine Vorab-Perfektion.** Primitive, einfache Materialien und klar erkennbare Testgeräusche genügen zunächst. Hochwertige Inhalte folgen erst nach tragfähigen Regeln und Workflowtests.
9. **Kein Wachsen des Pflichtumfangs.** Eine neue Idee wird nicht durch ihre Aufnahme in einen Arbeitsauftrag automatisch Teil von 0.1. Kein optionales System darf den Releasepfad blockieren.
10. **Keine Kalenderfiktion.** Komplexität, Risiko und Abhängigkeitsstärke ersetzen Stunden-/Tagesversprechen. Nach echten Befunden wird die Reihenfolge gezielt angepasst, nicht die Architektur unbemerkt umgeschrieben.

### Verbesserungen gegenüber einer rein linearen Systemliste

- Der kleinste brauchbare Inventory-/ItemDefinition-Anteil rückt nach P2, damit eine Aufnahme tatsächlich Besitz verändert und nicht bloß ein Objekt verschwinden lässt. P3 ergänzt Nutzung, Bedienung und Player State.
- Türnavigation wird in P2 mit dem zunächst minimalen späteren Creature-Motor geprüft; die vollständige KI folgt P4. So entsteht keine Abhängigkeit „Türtest wartet auf fertige KI“.
- P3 bietet einen klar begrenzten Anfangs-Wiederanlauf im Speicher; P5 ergänzt daran die vollständige Persistenz. Vor P5 wird kein dauerhafter Checkpoint versprochen.
- P5 prüft Save-Verträge mit neutralen Zuständen. Erst P6/P7 liefern den Nachweis für die echten Rätsel-, Story- und Levelkombinationen.
- Hardware-/Rendererprüfung und erste Darstellungsproben werden vorgezogen. Der Renderer muss vor regulärer Grafikbasis und entsprechender Taschenlampenabstimmung feststehen, nicht erst in P8.

## 4. Milestone-Übersicht

Die in §5 beschriebenen Phasen sind diesen Milestones untergeordnet. Ein Milestone ist erst erreicht, wenn seine Phasen-Done-Bedingungen und zugeordneten Review-/Entscheidungsgates erfüllt sind.

| Milestone | Phasen | Sichtbares Ergebnis / Junior-Test | Wichtigste Abnahme | Noch nicht erforderlich |
| --- | --- | --- | --- | --- |
| M0 – Projekt läuft | P0 | Startbare Anwendung mit Menü-/Sandbox-Grundhülle; Junior kann Start/Beenden sehen | Editor und Windows-Export starten, Main-Lebensdauer und Testpfad stimmen | Bewegung, KI, Saves, echtes Level |
| M1 – Bewegung macht den Raum spielbar | P1 | Junior läuft, schaut, springt, duckt und überwindet ein Testhindernis | Reproduzierbare Bewegung/Kollision, Pause/Fortsetzen, J1 und R1 | Rätsel, Bedrohung, vollständiges Inventar, Persistenz |
| M2 – Interaktive Survival-Sandbox | P2–P3 | Junior öffnet Türen, nimmt Dinge auf, nutzt Lampe/Tempo und erlebt einen Neustart | Eindeutiger Besitz, sichere Interaktion, Tür-/Navigationstest, Health-/Nutzungsregeln | Vollständige KI, echte Story, dauerhafte Saves |
| M3 – Erste nachvollziehbare Bedrohung | P4 | Junior wird gesehen/gehört, verfolgt, kann Sicht brechen, entkommen oder sterben | Eine FSM ohne Allwissenheit; Navigation, Suche, faire Grundreaktionen; J3 und R2 | Finales Kreaturmodell, Endlevel, gespeicherter Fortschritt |
| M4 – Fortschritt bleibt erhalten | P5 | Schließen, neu starten, Auto-/manuellen Stand laden und korrekt wiederanlaufen | Eigenständiger Todes-Wiederanlauf, Savefehler-/Restoretests, R3 | Endgültige Inhaltskombinationen und Speicherorte im Produktlevel |
| M5 – Rätsel und Erzählfortschritt tragen | P6 | Zwei echte freigegebene Rätsel und Hinweise lassen sich testen; J4 | Teilfortschritt/Reset/Saves beider Rätsel, Einmaligkeit, Storybedingungen | Finale Räume, endgültige Art-/Soundqualität, Zielspieldauer |
| M6 – Vollständiger Roh-Slice | P7 | Junior spielt erstmals Anfang → Erkundung/Rätsel/Gefahr → Enthüllung/Cliffhanger im eigentlichen Level | Gesamter Pflichtpfad ohne Debug, beide Savearten und faire Anker; J5 und R4; erste Dauermessung | Fertiger Präsentationsschliff; Zielzeit noch nicht abschließend abgenommen |
| M7 – Präsentabler Release Candidate | P8–P11 | Stimmige Optik, Sound, UI und mehrfach getesteter 15–25-Minuten-Slice | J6, Qualitäts-/Performanceziele, keine fehlenden Pflichtsysteme | Abschließender Installations-/Release-Regressionsnachweis |
| M8 – Dark Rooms 0.1.0 | P12 | Eigenständige installierbare Fassung; Junior spielt den Release Candidate | J7, R5, Release-DoD aus §16 | Alle ausdrücklich optionalen oder späteren Systeme |

## 5. Entwicklungsphasen

Jede Phase enthält Ziel, Abhängigkeiten, Implementierungsergebnis, Test/Done, Entscheidungsgate und Risiken. „Abhängigkeit: stark“ bezeichnet enge Kopplung an bereits funktionsfähige Nachbarsysteme, nicht eine Zeitschätzung. Gate-IDs werden in §6 aufgelöst, Junior-Tests in §8 und Reviews in §9.

### M0 / P0 – Projektbasis und technische Verifikation

**Komplexität:** klein · **Risiko:** mittel · **Abhängigkeit:** gering.

**Ziel und Warum zuerst:** Einen minimalen startbaren Arbeitsstand schaffen und Export-/Hardwareprobleme erkennen, bevor Gameplay darauf aufgebaut wird.

**Abhängigkeiten:** Freigegebene Planungsgrundlage; anschließender ausdrücklicher Implementierungsauftrag. E01 und das vorläufige Testprofil aus E02a.

**Implementierungsergebnis:** Godot-Projekt unter `game/`, Main und GameUI-Grundhülle, Input Actions, eine kleine Systems Sandbox mit einfacher Testansicht, konsistenter Maus-/Fokuswechsel und eigenständiger Windows-Testexport. Engineversion, passende Export Templates, tatsächliche CPU/GPU/VRAM/RAM und Testbetriebssystem sind erfasst. Renderer-Vergleich und Messstrecke sind vorbereitet; ein temporäres Profil wird ausdrücklich als solches geführt.

**Test / Done:**

- Start/Beenden funktioniert im Editor und ohne Editor als normaler Windows-Benutzer; keine fehlenden Runtime-Ressourcen.
- Main lädt/entlädt genau eine Testwelt; UI bleibt verfügbar. Kein Autoload- oder zweiter Test-Flow wird eingeführt.
- Testdaten sind vom späteren regulären `user://`-Fortschritt getrennt; noch keine Savefunktion behauptet.
- Hardware-/Profilbefund und reproduzierbarer Exportweg liegen vor; Review R0 prüft nur diese kleine Basis. Noch keine Platzhalterdatei für jedes geplante System anlegen.

**Entscheidungsgate:** E01 prüfen, E02a wählen; bei fehlender Engine-/Exportbasis nicht still eine andere Version verwenden. Renderer-Endwahl folgt E02b mit einer aussagekräftigeren Probe.

**Risiken / Grenze:** Setup oder Importprobleme können blockieren. P0 endet trotzdem am kleinsten funktionierenden Startstand, nicht erst an fertiger Save-/KI-/Assetinfrastruktur. Kein echtes Level erforderlich.

### M1 / P1 – First-Person-Spielgefühl

**Komplexität:** hoch · **Risiko:** hoch · **Abhängigkeit:** mittel.

**Ziel und Warum jetzt:** Möglichst früh ein selbst spielbares Ergebnis erhalten; spätere Räume und Fluchten brauchen verlässliche Bewegung.

**Abhängigkeiten:** P0; vorläufig freigegebene Kamera-/Eingabe-/Bewegungsgrenzen E03; einfaches Test-Audioprofil E12a. Noch keine vollständige KI, Savefunktion oder Produktassets voraussetzen.

**Implementierungsergebnis:** Player mit Mausblick, Laufen/Sprinten/Springen/Ducken und einer einfachen erkennbaren Traversalstrecke. Der eine Motor verändert die Position. Boden-/Körperkollision, Schritte mit einfachen Testgeräuschen, Bewegungsdebug und sichere Pause/Fortsetzen sind benutzbar. Zuerst Grundbewegung zeigen, dann innerhalb derselben Phase Ducken/Traversal ergänzen; nicht auf alle Unterfunktionen warten, bevor Junior ausprobieren darf.

**Test / Done:**

- Kurzer Testweg wiederholt ohne offensichtliches Hängenbleiben, Diagonalbonus oder Kameradurchtritt spielbar.
- Ducken unter Decke, verweigertes Aufstehen, Sprunglandung und freier/blockierter Traversalausstieg funktionieren; kein konkurrierender Positionsschreiber.
- Blick/Fokus nach Pause und neuem Sandboxlauf korrekt; keine durchgereichten Klicks oder alten Sprungaufträge.
- Schritte folgen echter Bodenbewegung. J1 und R1 durchgeführt; beobachtete Probleme behoben oder begründet als späterer Feinschliff eingeordnet.
- Noch nicht vorhandenes Restore wird ausdrücklich nicht als getestet markiert: Der kombinierte Motor-/Restore-Nachweis folgt verpflichtend in P5.

**Entscheidungsgate:** E03 anhand des Bewegungsprototyps konkretisieren. Keine endgültigen Flucht-/Raummaße vor diesem Befund. Spätere Änderungen an Körper-/Klettermaßen verlangen Wiederholung der betroffenen Tests.

**Risiken / Grenze:** Traversal und First-Person-Kollision sind frühe Hauptrisiken. Nicht durch freien Teleport, ein zweites Bewegungssystem oder Voll-Parkour umgehen. Das Ergebnis ist bewusst eine sichere Testwelt, kein Horror-Inhaltsentwurf.

### M2 / P2 – Interaktion, echter Besitz und Tür-/Navigationsprobe

**Komplexität:** hoch · **Risiko:** hoch · **Abhängigkeit:** mittel.

**Ziel und Warum jetzt:** Sichtbare Weltreaktionen ermöglichen und die kritische Tür-/Navmesh-Kopplung prüfen, bevor Räume oder Verfolgung davon abhängen.

**Abhängigkeiten:** P1; E04 für kontrollierte Türreaktion/Testaufbau, E05 für minimale Bestands-/kritische Itemregeln und E06 für frühe Text-/Inventaransichten. Für eine erste Importprobe gilt E13a; Primitive allein benötigen noch keine Assetproduktion.

**Implementierungsergebnis:** Interactor/Interactable, Türen, Schalter, Pickups, ein neutraler Testhinweis, stabile IDs und erste Levelvalidierung. Der kleinste verwendbare Inventory-/ItemDefinition-Anteil wird hier mitgebaut: Aufnahme verändert Bestand und Weltfund gemeinsam; eine einfache Bestandsrückmeldung genügt. Noch keine konkreten Spielgegenstände oder Rätselinhalte erfinden.

**Früher Risikoprototyp:** Den vorgesehenen Creature-Körper/NavigationAgent zunächst nur zu festen neutralen Testzielen bewegen lassen. Derselbe Motor und dieselbe Creature-Szene werden P4 erweitert. Damit Türblatt, echte Navmesh-Lücke und bedarfsweise zugewiesenen Link testen – ohne zweite KI, zusätzlichen Gegnertyp oder eigene Navigations-Testarchitektur. Nicht jede Tür erhält automatisch einen Link.

**Test / Done:**

- Interaktion vor/hinter einer Wand, Reichweite und schnelle Wiederholung liefern korrekte Aktion oder Ablehnung. RayCast berücksichtigt Areas und schließt den Player explizit aus.
- Aufgenommenes Item genau einmal im Inventory; bei Ablehnung bleibt es in der Welt. Die bestätigte Schutzregel für kritische Funde ist prüfbar.
- Türverriegelung und Stellung bleiben getrennt; Blockade führt nicht zu Quetschen/Wanddurchtritt. Geöffneter Türflügel blockiert keinen ungeprüften KI-Weg.
- Prüfakteur routet nicht durch den geschlossenen Durchgang; Öffnen, Schließen bei vorhandenem Weg und Navigationsbereitschaft geprüft. Ein Fehlschlag blockiert davon abhängige KI-/Raumproduktion, nicht unabhängige Bestandslogik.
- Leere/doppelte IDs stoppen die Freigabe mit Diagnose. Testhinweis lässt sich bedienen, ohne eine Story festzulegen. J2 durchgeführt.
- Repräsentative kleine Licht-/Material-/Taschenlampenprobe und Messung unter den geprüften Rendererprofilen liefern den Befund für E02b vor P3; keine großflächige Artproduktion.

**Entscheidungsgate:** E04-Testbefund vor P4 bestätigen; E02b vor rendererabhängiger Grafik-/Lampenabstimmung in P3. Bei ungeeigneter Linklösung erst gezielte Neubewertung der Architektur anfordern, nicht nebenbei eine alternative Navigationsplattform bauen.

**Risiken / Grenze:** Aufnahme ohne Inventory wäre Scheinfunktion; deshalb dessen kleiner Kern vorgezogen. Test-Schalter und -Hinweis sind keine finalen Rätsel-/Storyentscheidungen. Door/Navigation darf nicht bis zur fertigen Kreatur ungetestet bleiben.

### M2 / P3 – Itemnutzung, Player State und Niederlage

**Komplexität:** mittel · **Risiko:** mittel · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Aus Bewegung und Besitz einen verständlichen Spielzustand mit Hilfsmitteln, Gefahrfolgen und Neustart machen.

**Abhängigkeiten:** P2 einschließlich Inventory-Kern; E02b, E06, E07 und E08. Ein finaler Kreaturentyp ist für einen kontrollierten Schadentest nicht nötig.

**Implementierungsergebnis:** Kleine Inventarbedienung, verfügbarkeitsabhängige Taschenlampe, Tempo-Verbrauchsgegenstand, Health/Schaden/Tod und Game Over. Ein Anfangs-Wiederanlauf im Speicher führt über denselben Main-/Level-Neuaufbau zurück in einen definierten Sandboxzustand. Kein eigenständiges Resetframework und kein Debugteleport als spielbarer Neustart. Einstellungen/Rückmeldungen werden nur soweit nötig ergänzt.

**Test / Done:**

- Lampe schaltet konsistent mit Besitz; kein verpflichtender Batterieverbrauch eingeführt. Der gewählte Renderer liefert lesbares Licht ohne erfundene Leistungszusage.
- Tempoverbrauch und Effekt starten gemeinsam; Wiederholung folgt E08, Pause hält Restzeit an, Ablauf stellt Basisbewegung wieder her.
- Ein gültiger Treffer zählt einmal, Tod einmal; nach Tod keine weitere Itemnutzung/Bewegung. Health-Regeln bleiben konfigurierbar.
- Game Over und Anfangs-Neustart funktionieren ohne Entwicklerwerkzeug. UI-/Mausmodus und Inventoryzustand sind nachvollziehbar.
- Der Anfangs-Wiederanlauf wird klar als noch nicht dauerhaft gespeichert bezeichnet. Speichern über Prozessende und beliebige Checkpoints gehören erst zur Abnahme P5.

**Entscheidungsgate:** Health-/Trefferregel E07 und Tempo-/Nutzungsregel E08 vor Implementierung; Inventar-/Lese-Pausenregel E06 muss für benutzbare Ansichten feststehen.

**Risiken / Grenze:** Kein Kampf-/Heil-/Ausdauersystem aus offenen Fragen ableiten. Keine zweite Speicherstruktur als Prototypbehelf. Kritische Gegenstände und Flucht ohne Tempo-Bonus dürfen nicht durch frühe Itemregeln blockiert werden.

### M3 / P4 – Creature Prototype und erste Verfolgung

**Komplexität:** hoch · **Risiko:** hoch · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Die zentrale Bedrohung im kleinen Raum auf Fairness prüfen, bevor inszenierte Inhalte oder ein endgültiges Kreaturmodell entstehen.

**Abhängigkeiten:** P1–P3 und bestandene Tür-/Navigationsprobe E04; bestätigtes Wahrnehmungs-Testprofil E09; Inhalts-/Horrorgrenzen E14a vor entsprechender Darstellung und Junior-Test.

**Implementierungsergebnis:** Die eine Creature erhält Patrol, Investigate, Chase, Search und Return in einer FSM. Sicht, feste Geräuschmeldungen, letzte gültige Wahrnehmung, Navigation, Schaden und begrenzte Suche sind verbunden. Quell-Audio und KI-Geräuschparameter bleiben getrennt. Ein einfacher Platzhalterkörper und klar unterscheidbare Testgeräusche genügen; kein Monsterdesign wird damit beschlossen.

**Test / Done:**

- Patrouille → akzeptiertes Geräusch → Untersuchung → Sicht → Chase → Sichtverlust → Search → Return reproduzierbar; neuer gültiger Reiz kann korrekt reagieren lassen.
- Spielerbewegung hinter einer undurchsichtigen Wand aktualisiert nicht heimlich die letzte Sichtposition; gehörte Position wandert nicht mit der Quelle.
- Stummes Spiel verändert nicht die KI-Hörregeln. Wiederholte Reize erzwingen keine endlose Suche.
- Geschlossene Tür, veränderte Route und legal unerreichbarer Spieler haben kontrollierte Ausgänge statt Teleport/Allwissenheit.
- Schaden durch undurchlässige Blockade verhindert; Tod/Anfangs-Neustart beendet alten Chase. Testflucht ohne Tempo-Item möglich.
- J3 und Review R2 bestanden; Gefahr und Entdeckung sind für Junior zumindest grundsätzlich erklärbar. Noch keine Abnahme finaler Horrorwirkung mit Platzhalterassets behaupten.

**Entscheidungsgate:** E09 konkretisiert Parameter/unerreichbare Ziele anhand Befund, ohne willkürliche finale Zahlen. Sicheres Wiederanlaufverhalten wird vor P5 separat in E10 beschlossen; die KI darf es nicht vorwegnehmen.

**Risiken / Grenze:** Höchstes Risiko sind schwer verständliche Wahrnehmung, festhängende Routen und unangenehmer statt spannender Druck. Keine zweite Chase-State-Machine, keine Behavior Trees oder zusätzliche Kreatur zur Kaschierung.

### M4 / P5 – Save, Checkpoints und Restore

**Komplexität:** hoch · **Risiko:** hoch · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Den inzwischen aussagekräftigen Spielzustand dauerhaft erhalten und Wiederanlauf absichern, bevor echte Rätsel-/Levelinhalte darauf aufbauen.

**Abhängigkeiten:** P0–P4, stabile Zustandsbesitzer/IDs. E10 vollständig vor produktivem Save-/KI-Restore-Verhalten, E11 vor vollständiger Save-Bedienung. Ausgereifte Plot-/Rätselinhalte sind noch keine Voraussetzung.

**Implementierungsergebnis:** SaveService, freigegebenes JSON-Datenpaket unter `user://`, Autosave/Checkpoint und zusätzlicher manueller Speicherpunkt; korrekter Todes-Wiederanlauf je ladbarem Stand, Backup/Fallback, Fehleranzeige und inaktiver Weltneuaufbau. Bestehender Main-Anfangs-Wiederanlauf wird erweitert, nicht ersetzt durch einen zweiten Flow.

Für den frühen Nachweis werden der minimale Puzzle-Zustandsvertrag und neutrale Progress-/Einmalzustände in vorhandener Sandbox/Datentests mitgeführt. Diese prüfen Teil-/Lösungszustand, Türfreigabe und Fundverwendung, definieren aber weder Rätsel A/B noch Story. Kein universelles Puzzleframework und keine zusätzliche Produktions-Testklasse als Voraussetzung. Die realen Inhaltskombinationen bleiben ausdrücklich Abnahmegegenstand P6/P7.

**Test / Done:**

- Beide Speicherarten separat bedienen, Anwendung vollständig beenden, erneut starten und konsistent laden: Player, Inventory, Verbrauch/Effektrestzeit, Lampe, Funde, Türen, Test-Puzzle/Progress und Begegnungszustand passen zusammen.
- Manuellen Stand sichern, zugehörige spätere Autosaves mehrfach überschreiben, alten manuellen Stand laden und sterben: sein eigener Todes-Wiederanlauf bleibt verfügbar.
- Fehlender Schreibzugriff/unterbrochener Schreibvorgang erhält einen gültigen vorherigen Stand; kein falsches Erfolgssignal. Inkompatible Daten/IDs werden verständlich abgelehnt, nicht teilweise geladen.
- Restore aus Pause/Game Over arbeitet ohne Physik-Warte-Deadlock; alte Signals/UI-Referenzen sind entfernt, keine doppelte Kreatur, keine historischen Audio-/Storyaktionen, kein Autosave allein durch initiale Überlappung.
- Nach Laden Items ändern und sterben: Snapshot blieb unverändert. Wiederholte Restores ändern aktuelle Nutzereinstellungen nicht.
- P1-/P3-Regressionen jetzt inklusive Restore prüfen: Duckhaltung, Motor, Kamera, Traversalgrenzen, Health, Tempo und Eingabesicherung. Während instabiler Zustände wird nicht gespeichert.
- Sichere Testanker nach E10 praktisch geprüft; Review R3 bestanden. Das ist Persistenz der Systembasis, noch keine Garantie für später entworfene Räume/Rätsel.

**Entscheidungsgate:** E10 entscheidet Search/Speichern, Gegner-Reset, manuelle Checkpointwirkung und Bestätigung nach I/O-Erfolg. E11 legt sichtbare Savebedienung/Slotanzahl und unterstützte Versionsstände fest. Konkrete Produktlevel-Speicherorte folgen E17 vor P7, nicht hier erfinden.

**Risiken / Grenze:** Hohe Zustandskombinatorik, korruptes Ersetzen, unfairer Wiederanlauf und geteilte mutable Snapshotdaten. Kein Migrationsframework, keine Snapshot-Historie, keine Threads ohne Messbedarf. Ein fehlgeschlagener kritischer Save-Test blockiert abhängige Fortschrittsintegration, nicht unabhängige Autorenarbeit.

### M5 / P6 – Zwei echte Rätsel und Storyfortschritt

**Komplexität:** hoch · **Risiko:** hoch · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Die technische Systembasis mit gemeinsam entwickelten Inhalten verbinden und deren Lösbarkeit prüfen, bevor endgültige Räume gebaut werden.

**Abhängigkeiten:** P5 für integrierte Persistenzabnahme; Autorenarbeit kann schon vorher parallel stattfinden. E14b, E15 und E16a vor der jeweiligen Inhaltsimplementierung. Rätsel A darf früher freigegeben/getestet werden als B; M5 verlangt schließlich beide.

**Implementierungsergebnis:** Die zwei bestätigten unterschiedlichen Rätsellogiken hinter dem vorhandenen kleinen Vertrag, passende Schalter-/Türkopplung und Itemverwendung. Echte freigegebene Hinweise, gefunden/gelesen, Einmaltrigger, erste Enthüllungs- und Abschlussbedingungen werden an Level-Progress angeschlossen. Konkrete Handlung und Rätsel werden von den Spielautoren geliefert, nicht durch diese Roadmap vorgegeben.

**Test / Done:**

- J4 prüft bereits das erste vollständige Rätsel, bevor die gesamte Phase fertig ist. Beide Rätsel sind danach mit verständlichen Eingaben, Fehlversuchen, Teilfortschritt und bestätigter Rücksetzregel lösbar.
- Kritische Items können nicht verlorengehen oder doppelt frei/eingesetzt sein. Keine gegenseitig unerfüllbare Voraussetzung zwischen Rätseln, Türen und Gegenständen.
- Vor, während und nach jedem Rätsel speichern/laden; keine doppelte Belohnung, korrekte Türstellung und abgeleitete Freigabe, keine Mischung mit späterem Fortschritt.
- Hinweise/Storytrigger mehrfach betreten und laden: gefunden/gelesen und Einmaligkeit stimmen, Enthüllung wird nicht mit Abschluss verwechselt.
- Integrations-/Datentests prüfen reale Progress-/Savezustände; neutrale Testdaten aus P5 allein gelten nicht als Beleg. Die Befunde fließen in den vollständigen Loop-Review R4 bei P7 ein.

**Entscheidungsgate:** Inhalte E14b/E15/E16a freigeben, bei unverständlichem Rätsel zunächst fachliche Regel klären statt ein Hilfs-/Questframework hinzuzubauen. Ein zusätzlicher Geheimraum oder optionale Abzweigung ist durch den Levelauftrag nicht automatisch beschlossen.

**Risiken / Grenze:** Designerwissen kann ein Rätsel scheinbar verständlich machen; Test ohne Zuruf einplanen. Noch keine finale Raumgestaltung oder zusätzliche Storysysteme, keine Sprachausgabe. Der Loop in der Sandbox ist nicht schon der fertige Slice.

### M6 / P7 – Eigentliches Vertical-Slice-Level und kompletter Rohdurchlauf

**Komplexität:** sehr hoch · **Risiko:** hoch · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Bewiesene Systeme und freigegebene Inhalte zu einem kleinen zusammenhängenden echten Spielabschnitt verbinden.

**Abhängigkeiten:** P1–P6 und deren kritische Befunde; konkrete Raum-/Ablauffreigabe E16b, Speicherorte E17, repräsentative Import-/Audio-Workflows E12b/E13b, Gestaltungsfreigaben E19 und Ressourcenrahmen E18 vor größerem Ausbau.

**Implementierungsergebnis:** Eigene Vertical-Slice-Szene mit denselben getesteten Gameplay-Bausteinen; die Systems Sandbox bleibt separat erhalten. Der spätere GDD-Rahmen – Wald-Einstieg, verlassener Gebäude-/Spielzeugfabrikbereich, Erkundung, Rätsel, Begegnung, Verfolgung, Enthüllung und Cliffhanger – wird erst gemäß gemeinsam bestätigtem Ablauf räumlich umgesetzt. Die vorgeschlagene Reihenfolge und ein bestimmter Fabrik-/Raumentwurf werden hier nicht neu beschlossen.

Zuerst den gesamten Pflichtweg mit klar lesbarer Rohgeometrie spielbar machen. Anschließend eine kleine repräsentative Asset-/Licht-/Audioprobe in diesem Kontext integrieren und Ressourcenverbrauch prüfen, bevor größere Mengen produziert/importiert werden. Produktassets können ab hier schrittweise erscheinen; fehlender Hochglanz blockiert den ersten vollständigen Durchlauf nicht.

**Test / Done:**

- Startmenü → Anfang → beide Rätsel → Gefahr/Flucht → Storyenthüllung → erkennbarer Abschluss in einem durchgehenden Stand ohne Debugbefehle spielbar. Die Raumreihenfolge folgt E16b, nicht einem technischen Zwang.
- J5 testet den ersten nahezu vollständigen Ablauf. Erste normale Durchlaufdauer wird nach GDD-Messregel erfasst; Abweichungen zum 15–25-Minuten-Ziel und ihre Ursachen sind sichtbar, nicht künstlich durch Wartezeiten kaschiert.
- Pflichtweg funktioniert ohne Tempo-Vorrat; echte Tür-/Traversalgrenzen und alle dynamischen Kreaturendurchgänge sind geprüft. Kein Link darf durch automatischen Navmesh-Anschluss umgangen werden.
- Sichere Speicher-/Kreaturenanker im echten Raum prüfen; beide Savearten, Tod nach altem manuellem Stand, Rückwege, Teilrätsel und Einmaltrigger über Neustart testen. P5-Abnahme wird an realem Inhalt wiederholt.
- Nur ein vollständiges Level geladen; Standalone-Durchlauf sowie erste repräsentative RAM-/Lade-/Framezeitmessung bestehen innerhalb des vereinbarten Zwischenprofils. Kein dauerhaft wachsender Speicher nach Reload.
- Review R4 prüft den vollständigen Loop und die Zusammenführung echter Inhalte mit Save-/Restore- und Levellebensdauer.

**Entscheidungsgate:** E16b/E17 legen konkrete Inhalte/Orte fest. E18 muss vor umfangreichem Level-/Assetausbau anhand der repräsentativen Probe bestätigt sein. Ist das Laden auf 16 GB RAM nicht tragfähig, zuerst Umfang/Assets prüfen; eine geänderte Ladestrategie erfordert gesonderte Neubewertung, kein stilles Streaming.

**Risiken / Grenze:** Größte Produktionsphase; unfertige Details dürfen den vollständigen Pfad nicht verdecken. M6 ist ein Roh-Slice mit dokumentiertem Qualitäts-/Zeitabstand, noch keine Releasebehauptung.

### M7 / P8 – Art, Licht und visuelle Atmosphäre

**Komplexität:** hoch · **Risiko:** mittel · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Den funktionierenden Raum gezielt präsentabel machen, ohne auf unbewiesene Wege oder wechselnde Kameramaße hin zu produzieren.

**Abhängigkeiten:** M6, bestätigter Renderer E02b, Asset-Workflow E13b, E18 und Gestaltungsfreigabe E19. Begrenzte Vorarbeiten/Proben dürfen zuvor parallel laufen; flächiger Ausbau erst nach diesen Grundlagen.

**Implementierungsergebnis:** Geeignete hochwertige Modelle, Materialien/Texturen, bestätigte Figuren-/Kreaturendarstellung und nötige Animationen ersetzen störende Platzhalter. Licht, Schatten, Taschenlampenwirkung und Farb-/Stimmungskonzept werden am tatsächlichen Pflichtweg abgestimmt. Originalassets bleiben unter `source_assets/`, Runtime-Fassungen im Godot-Projekt; Lizenzen werden beim Einführen erfasst.

**Test / Done:**

- Realistisch wirkende, zusammenhängende 3D-Zielrichtung ohne Pixel-Art/bewusste Verpixelung erkennbar; notwendige Wege/Hinweise bleiben lesbar, keine extreme Dauerdunkelheit.
- Assetwechsel verändert nicht unbeabsichtigt Kollisionsmaße, ID, Interaktionsfläche, Navmesh oder Spielregel. Betroffene Bewegungs-/Türtests werden wiederholt.
- Darstellung und Animation folgen Zuständen; kein zweiter Positionsschreiber am Player. Noch offene sichtbare Körperteile werden nicht eigenmächtig als Pflicht hinzugefügt.
- Pflichtstrecke visuell ohne störende Entwicklungsplatzhalter; Kamera/Creature/Material-/Lichtprobe im tatsächlichen Export geprüft. GPU-/RAM-/Ladeziele werden eingehalten oder durch konkrete Maßnahmen wieder erreicht.

**Entscheidungsgate:** E19 vor jeweiliger Gestaltung, optionale Grafikqualitätsstufen nur bei begründetem Bedarf. E02b ist Voraussetzung, keine bis hier aufgeschobene Erstentscheidung.

**Risiken / Grenze:** Assetmenge, Schatten und schwere Originaldateien können die kleine Produktion überfordern. Qualität durch begrenzten Raum und Wiederverwendung, nicht durch zusätzliche Level oder AAA-Budgets suchen.

### M7 / P9 – Sound und Horror-Polish

**Komplexität:** hoch · **Risiko:** mittel · **Abhängigkeit:** mittel.

**Ziel und Warum jetzt:** Bereits funktionierende Audioreaktionen zu einer nachvollziehbaren und spannenden Klanggestaltung zusammenführen.

**Abhängigkeiten:** M6, E12b/E19 und vorhandene funktionale Audioereignisse aus P1–P4. Kann mit P8 parallel laufen, sobald die betroffenen Räume/Quellen hinreichend stabil sind.

**Implementierungsergebnis:** Geeignete Schrittvarianten/Oberflächen, Türen/Schalter, Kreatur, mechanisch-industrielle Umgebung, räumliche Ambience, Musik und UI-Sounds. Gefahr, Orientierung und Ruhephasen sind hörbar abgestimmt; Chase-/Search-Audio folgt weiterhin der einen Creature-FSM. Kein zusätzlicher AudioManager und keine Sprachausgabe.

**Test / Done:**

- Relevante Quellen räumlich einordnen; Warnung/Handlungsrückmeldung nicht durch Musik oder Daueralarm verdeckt.
- Spieler kann plausiblen Entdeckungsanlass erkennen. Änderungen am Mix ändern nicht die KI-Geräuschregeln.
- Pause, Tod, Restore und wiederholter Weltwechsel erzeugen keine alten Loops, Doppelstimmen oder erneut abgespielten Einmalhinweise.
- Atmosphäre trägt auch ohne dauernd sichtbare Kreatur; Grenzen E14a gelten. Fehlende Pflicht-Warntöne sind Abnahmefehler, nicht akzeptabler Platzhalter.
- Audioimport und Lautstärkegruppen funktionieren auf dem vereinbarten Hörsetup im Export, ohne unnötige Speicherlast.

**Entscheidungsgate:** Endgültige Mischung/Varianten erst hier abstimmen; grundlegende Quellen, Warnfunktionen und Workflow müssen längst vorhanden sein. Größere Änderungen der Horrorintensität erneut gemeinsam prüfen.

**Risiken / Grenze:** „Mehr laut“ ersetzt keine Atmosphäre. Keine neue Kreaturenfähigkeit oder inszenierte Zwangssequenz erfinden, um akustische Schwächen zu überdecken.

### M7 / P10 – UI, UX und Spielkomfort

**Komplexität:** mittel · **Risiko:** mittel · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Die früh vorhandene Bedienung konsistent, lesbar und präsentabel machen; keine Pflichtmenüs erstmals hier nachliefern.

**Abhängigkeiten:** M6, bestätigte Regeln E05–E08/E11 sowie verfeinertes Bedien-/Lesbarkeitsprofil E20. Kann abschnittsweise parallel zu P8/P9 laufen.

**Implementierungsergebnis:** Einheitlicher Schliff für Start/Laden, Pause, Inventory, Hinweise/Storytext, Health, Tempo, Speicherstatus, Game Over und Abschluss. Sinnvolle Audio-/Mauseinstellungen und die von der Architektur vorgesehenen getrennten Nutzereinstellungen funktionieren. Minimalistische HUD-Fläche beibehalten.

**Test / Done:**

- Jeder normale Pflichtvorgang ist ohne Debug erreichbar; Auto-/manueller Stand, Speichersperre und Dateifehler werden verständlich unterschieden.
- Maus/Fokus und Tastaturbedienung nach jeder Ansicht, Niederlage und Restore korrekt; keine versehentliche Weltaktion hinter einem UI-Klick.
- UI zeigt nach Neubindung sofort richtigen Bestand/Health/Progress. Keine veralteten Quellen oder eigenen Gameplaykopien.
- Texte/Hinweise in vereinbarten Fenster-/Bildschirmbedingungen lesbar; Nutzereinstellungen über Neustart erhalten und nicht durch älteren Checkpoint zurückgesetzt.
- Geänderte Optik erfordert keinen neuen Bedienablauf ohne Freigabe. E06/E11 sind frühere Regeln, keine noch offenen Polishfragen.

**Entscheidungsgate:** E20 schließt Darstellungs-/Komfortdetails, nicht Gesundheits-, Speicher- oder Inventarregeln. Keine große neue Options-/Rebindingplattform als ungeplanter Pflichtumfang.

**Risiken / Grenze:** Späte Regeländerungen würden Save, Tests und Inhalte zurückwerfen. Deshalb grundlegende Bedienung früh testen, hier nur verfeinern und regressionsprüfen.

### M7 / P11 – Integration, Spieltests und Balancing

**Komplexität:** hoch · **Risiko:** hoch · **Abhängigkeit:** stark.

**Ziel und Warum jetzt:** Aus einzeln funktionierenden und präsentablen Teilen ein geschlossenes, faires und zeitlich passendes Erlebnis machen.

**Abhängigkeiten:** P7–P10 integriert; keine fehlenden Pflichtfunktionen. Kernregelsätze sind freigegeben, finale Tuningwerte werden durch Tests abgestimmt statt erfunden.

**Implementierungsergebnis:** Mehrfach durchgespielter kompletter Slice mit abgestimmter Bewegung, Rätselschwierigkeit, Gefahr, Health, Tempo, Checkpoints, Storyverständlichkeit, Audio/Licht und Ressourcenverbrauch. J6 besteht aus mehreren gezielten Rückmeldeschleifen mit jeweils klarer Testfrage.

**Test / Done:**

- Ein normaler erster vollständiger Durchlauf liegt ungefähr im 15–25-Minuten-Zielbereich. Orientierung, Lesen und Rätsellösen zählen; Menüzeit, lange Pausen und wiederholte Niederlagen separat betrachten. Geübte Wiederholung darf kürzer sein.
- Junior kann den Pflichtpfad einschließlich beider Rätsel ohne Entwicklerzuruf bewältigen; nach Möglichkeit ergänzt eine noch unvertraute Person den Test, da Junior als Mitautor Lösungen bereits kennen kann.
- Flucht bleibt ohne Tempo-Item möglich; Entdeckung, Suchende und Niederlage sind erklärbar; faire Checkpoints erzwingen nicht wiederholt lange bereits gelöste Strecken.
- Nach Abschluss lassen sich zentrale Erkenntnis und offene Schlussfrage wiedergeben, ohne neue Story in der Technik zu erfinden.
- Komplette Durchläufe, Fehlversuche, spätere/ältere Saves und Neustarts funktionieren im integrierten Export; bestätigte Leistungsziele auf Referenzhardware eingehalten.
- Keine fortschrittsblockierenden oder datenverlustgefährdenden Fehler bekannt. Verbleibende kleine Präsentationsfehler haben eine ausdrückliche Einordnung für P12. Der Stand kann als Release Candidate eingefroren werden.

**Entscheidungsgate:** Tuningänderungen bleiben innerhalb freigegebener Regeln. Änderungen an Rätselzugängen, Itemschutz, Speicherpolitik oder Horrorgrenzen benötigen erneute fachliche Freigabe und passende Regression, auch wenn sie als „Balancing“ bezeichnet werden.

**Risiken / Grenze:** Endlosschleifen aus neuen Features/Polish vermeiden. Zielzeit nicht durch Leerlauf strecken; zuerst Ursachen in Orientierung, Schwierigkeit und Rhythmus prüfen. Integration beginnt praktisch früher, wird hier aber vollständig abgenommen.

### M8 / P12 – Stabilisierung und V0.1 Release

**Komplexität:** mittel · **Risiko:** hoch · **Abhängigkeit:** stark.

**Ziel und Warum zuletzt:** Den eingefrorenen Inhalt als verlässlich installierbare Version veröffentlichungsfähig machen, nicht noch neue Systeme ergänzen.

**Abhängigkeiten:** M7/Release Candidate; E21 zu unterstütztem Windows-Testprofil, Installations-/Paketweg und Distribution. Passende Export Templates sind seit P0 nachgewiesen, werden erneut geprüft.

**Implementierungsergebnis:** Fehlerbereinigter Windows-x86-64-Release-Build, abgeschlossene Lizenz-/Ressourcenprüfung, dokumentierte unterstützte Save-/Inhaltsversion und getesteter Installations-/Startweg. Debugaktionen sind im Release tatsächlich gesperrt, nicht nur unsichtbar. Der konkrete Installer-/Paketweg wird nicht durch diese Roadmap ausgewählt.

**Test / Done:**

- §16 vollständig erfüllt; Installation/Start als normaler Benutzer ohne Editor und ohne Entwicklungspfade funktioniert.
- J7 spielt den Release Candidate; Review R5 prüft kritische Restfehler, Save-/Lebensdauerregression und Releasekonfiguration. Relevante Fixes werden am neu gebauten Kandidaten erneut getestet.
- Beide Speicherarten über mehrere Prozessstarts, alter manueller Stand mit eigenem Todes-Wiederanlauf, Backup/Schreibfehler, Teilrätsel und finale Story-/Levelzustände getestet.
- Speicherverbrauch nach wiederholten Reloads stabil, realer Export erfüllt Budgets; keine fehlenden Assets/Warntöne oder offenen Lizenzfragen.
- Finale Version/Buildidentität steht fest, derselbe geprüfte Inhalt wird ausgeliefert. Ein offener Fortschrittsverlust, Softlock, reproduzierbarer Absturz oder Kernfunktionsfehler verhindert M8.

**Entscheidungsgate:** E21 und Releasefreigabe nach Befunden. Bei kritischem Fehler zurück zur betroffenen Phase, kein „fertig“ allein wegen eines Versionslabels. Kein automatischer Upload/öffentlicher Release ohne gesonderten Auftrag.

**Risiken / Grenze:** Export-/Dateipfade, Unterschiede zum Editor, Release-Debugsperren und Altstände. Keine neuen Gameplayideen im Release Candidate; reine optionale Erweiterungen bleiben außerhalb dieses Durchlaufs.

## 6. Entscheidungsgates

Diese Tabelle enthält **keine ausgewählten Gameplaywerte**. Sie legt fest, wann welche Antwort gebraucht wird. Quellenkürzel: GDD O-xx = offene fachliche Frage; TDD T-xx = technische Restfrage; Architektur §34 = maßgebliche Implementierungsschranken. Bereits durch ADRs entschiedene Grundlagen werden geprüft, nicht erneut beliebig geöffnet.

Fachliche Regeln/Inhalte entscheiden die Spielautoren gemeinsam, unterstützt durch ChatGPT als Project Lead. Technische Vorschläge erhalten eine begründete Auswahl anhand Tests; Claude Code liefert Implementierungs-, Self-Review- und Testbefunde, der Project Lead bewertet sie und zieht Astra High am vorgesehenen Review-Gate oder bei schwierigem Problem hinzu. Entscheidungen werden erst in einem gesondert autorisierten Auftrag in den zuständigen Planungsdokumenten festgehalten. Hier werden keine anderen Dokumente verändert.

| Gate | Entscheidung / Nachweis | Exakter Bedarf in der Roadmap | Grundlage / freizugebendes Ergebnis |
| --- | --- | --- | --- |
| E01 | Festgelegte Engine/Exportbasis und tatsächliche Hardware verifizieren | Zu Beginn P0, vor darauf aufbauenden Projektarbeiten | ADR-007, T-01: 4.7.2, Templates, Windows x86-64; CPU/GPU/VRAM/RAM/OS erfassen. Keine Version ändern, wenn die Installation abweicht. |
| E02a | Vorläufiges Renderer-Testprofil ausdrücklich wählen | P0 vor erster Projekt-/Testkonfiguration | ADR-008, T-03: ein zum Gerät passendes temporäres Profil; keine automatisch bevorzugte Variante. |
| E02b | Renderer und erstes reguläres Grafikprofil anhand Vergleich bestätigen | Vergleich P0–P2; vor rendererabhängiger Grafik-/Lampenabstimmung in P3 und jeder regulären Artproduktion | Forward+, Mobile, Compatibility mit realer GPU und kleiner repräsentativer Probe bewerten. Nicht bis P8 aufschieben. |
| E03 | Kamera-/Eingabe-/Bewegungstestprofil; danach reproduzierbare Sprung-/Klettergrenzen | Vor Motoraufbau P1 vorläufig wählen; bis P1-Abnahme testen; vor Raummaßen P7 bestätigen | O-03/O-08/O-17, T-10: Perspektive ist bereits First Person; Gefühl, Maße und konkrete Werte nicht. Kein implizites Ausdauersystem. |
| E04 | Kontrollierte Türblockadereaktion und Durchgangskopplung praktisch bestätigen | Vor Türprototyp P2 Testregel vereinbaren; erfolgreicher Kopplungsnachweis vor P4; jede konkrete Route erneut P7 | ADR-002/004, Architektur §§10/17: Link nur bei tatsächlich dynamischem KI-Weg; keine automatisch als unzugänglich erklärten Räume. |
| E05 | Minimales Inventory, Kapazität/Stapeln, kritischer Itemschutz und Aufnahmebedienung | Vor echten Pickups/Inventory in P2; spätere Nutzung darauf aufbauen | O-11, T-09: kein vorgetäuschter Pickup ohne Besitz und keine Regel, die nötige Items verlieren lässt. |
| E06 | Lesen/Inventory: Eingabe, Öffnen/Schließen und Weltpause | Vor erster bedienbarer Hinweis-/Bestandsansicht in P2; spätestens vor Inventory-Nutzung P3 | O-17, T-07/T-09: Grundpause ist Pflicht; Weltpause während Ansichten nicht still festlegen. |
| E07 | Minimale Health-, Treffer- und Todesregel einschließlich einschlägiger Fallfolgen | Vor Damage/Death in P3 | O-10, T-07/T-10: Regeln bestätigen, Zahlen konfigurierbar. Heilung nicht automatisch ergänzen. |
| E08 | Tempoeffekt: Nutzung, Wiederholung/Stapeln/Erneuerung und vorläufiges Tuning | Vor Nutzungssystem in P3; Balance erneut P4/P11 | O-12, T-11: zeitlich begrenzter Bonus, niemals Voraussetzung für Pflichtflucht. |
| E09 | Sicht-/Geräuschmodell, Dämpfung, Such-/Untersuchungsregeln und unerreichbare Ziele | Vor vollständigem Wahrnehmungsverhalten P4 Testprofil wählen; anhand P4-Befund bestätigen | O-07/O-08, T-12: Reichweiten/Zeiten nicht hier erfinden; konkrete Quellen und nachvollziehbare Ausgänge. |
| E10 | Sichere Savezustände, Search/Speichern, Gegnerreset, manuelles Speichern als Todes-Checkpoint und Checkpoint-Aktivierung nach I/O-Erfolg | Vollständig vor produktivem Save-/KI-Restore-Verhalten in P5 | ADR-005, T-05, Architektur §19: beide Speicherarten stehen fest, diese Detailregeln noch nicht. |
| E11 | Slotanzahl/-bedienung, technisches Schema-/Inhaltsversionsprofil und kompatible Altstände | Vor vollständiger Savebedienung/Serialisierung in P5 | ADR-006, T-13: JSON/user:// und eigenständiges Paket sind vorgegeben; kein neues Format oder Migrationsframework nötig. |
| E12a | Einfaches Test-Audioprofil/Hörsetup | Vor ersten Schritten/Testgeräuschen P1 | T-14: kleine bekannte Testquellen, überprüfbare Lautstärke, noch keine finale Bibliothek/Mischung. |
| E12b | Audio-Workflow, bestätigte Oberflächen, Importprofile und Hörsetup für Produktinhalt | Spätestens vor regulärer Audiointegration P7; funktionale Warnung bereits P4 geprüft | T-14: spätere Mischung P9 darf das früh benötigte Gameplayfeedback nicht ersetzen. |
| E13a | Maßstab und kleiner Austausch-/Importversuch | Vor erster externer Testassetintegration; falls in P2 verwendet, davor | T-15: glTF/GLB bleibt Kandidat aus der Planung, keine automatische Assetauswahl. Primitivtests benötigen keine große Pipeline. |
| E13b | Regulärer Asset-Workflow und benötigte Runtime-/Importprofile | Vor regulären Produktassets P7; in P8 nicht erst erfinden | T-15: Originale getrennt, Lizenzen nachvollziehbar, Größen praktikabel. |
| E14a | Alters-/Inhaltsgrenzen, Gewalt-/Niederlagendarstellung und vertretbare Horrorintensität | Vor konkretem Horror-/Kreatureninhalt und J3 in P4; frühe sichere Bewegungstests bleiben möglich | O-01/O-07: keine Alterszielgruppe oder gestalterische Härte aus dem Wort Horror ableiten. |
| E14b | Relevante Hauptfigur-, Welt-/Setting- und Storyentscheidungen einschließlich Hinweise, Enthüllung, Cliffhanger | Vor entsprechenden Inhalten in P6 | O-04/O-05/O-06: gemeinsame Autorenarbeit; technische Testflags sind kein Ersatz. |
| E15 | Die beiden unterschiedlichen Rätsel, Items, Fehlversuchs-/Reset-/Hilferegeln | Jeweils vor ihrer Implementierung in P6; beide vor M5 | O-09, T-16: Freigabe kann gestaffelt erfolgen, keine endgültigen Inhalte aus neutralen Savefixtures ableiten. |
| E16a | Grundlegender Ablauf und Bedingungen zwischen Rätsel/Story/Begegnung | Vor Verknüpfung echter Inhalte P6 | O-15, T-16: GDD-Ablauf ist Empfehlung; Auswahl ausdrücklich bestätigen. |
| E16b | Konkreter kleiner Levelplan, Zugänge, Flucht-/Traversalwege und Umfang möglicher Abzweigungen | Vor eigentlichem Levelaufbau P7 | O-15: geprüfte Bewegung/Navigation berücksichtigen; kein automatisch beschlossener Geheimraum. |
| E17 | Konkrete Auto-/manuelle Speicherstellen und zugehörige sichere Wiederanlaufanker | Vor deren Integration in P7; räumlicher Nachweis vor M6 | O-13: P5 verwendet Testanker, nicht vorweggenommene Produktorte. |
| E18 | Messbare Ressourcen-, Framezeit- und Ladezeitziele für Referenzgerät | Messbasis P0–P3; vor größerem Level-/Assetausbau in P7 anhand repräsentativer Probe bestätigen | T-18, Architektur §30: Editor und Spiel gemeinsam auf 16 GB RAM berücksichtigen; keine AAA-Zahlen erfinden. |
| E19 | Gestaltungsfreigaben für Figur/Kreatur, Umgebung, Farb-/Licht-/Klangrichtung | Vor jeweiliger Produktasset-/Stimmungsarbeit; erste Probe P7, größere Ausarbeitung P8/P9 | O-04/O-07/O-16: realistische lesbare 3D-Richtung steht fest; konkrete Designs bleiben Autorenentscheidung. |
| E20 | Konkrete Lesbarkeits-/Komfortziele und UI-Feindarstellung | Grundbedienung jeweils P0–P5; vor verbleibendem UI-Polish P10 | O-17, T-21: nur Darstellungsdetails vertagen, keine Pflichtbedienung oder Input-Sicherheit. |
| E21 | Unterstütztes Windows-Profil, Installations-/Paketweg, Lizenz-/Releasebedingungen | Test-OS in P0 erfassen; Verteilungs-/Installationsweg vor P12 festlegen | O-02, T-22: früher Export bleibt Pflicht, tatsächliche Veröffentlichung benötigt separaten Auftrag. |

**Gate-Behandlung:** Bei offener Antwort wird nur die abhängige Arbeit nicht begonnen. Neutrale technische Tests sind mit ausdrücklich vorläufigem Profil erlaubt, dürfen aber nicht als finaler Inhalt oder abgenommene Spielregel in den Slice gelangen. Fallen spätere Tests durch, wird das betroffene Gate wieder geöffnet und sein abhängiger Nachweis wiederholt; keine pauschale Freigabe aller Phasen durch einen einzelnen Prototyp.

## 7. Technische Risikoprototypen

Die Prototypen sind kleine Ausbaustufen der bestehenden Sandbox und der später verwendeten Systeme. Kein separater Wegwerf-Prototyp als zweite Architektur. Ein fehlgeschlagener Nachweis führt zu einer begrenzten Untersuchung und gegebenenfalls ausdrücklichen Neubewertung, nicht zu ständig mehr Infrastruktur.

| Risiko | Frühester Nachweis / Wiederholung | Konkreter Versuch | Was der Befund freigibt oder blockiert |
| --- | --- | --- | --- |
| First-Person-Bewegung | P1; erneut P5/P7 | Ecken, Decke, Landen, Blick/Fokus und unterschiedliche Laufbedingungen | Körper-/Kameramaße und verlässlichen Bewegungsauftrag; keine fertigen Fluchtwege vorher |
| Traversal | P1; erneut mit Tod P3 und Restore P5 | Hindernis wiederholt überwinden, blockierter Ausstieg, Pause/Tod | Zulässige Klettergeometrie; kein Voll-Parkour als Ausweichlösung |
| Tür + Navigation | P2; mit echter FSM P4 und jedem Produktdurchgang P7 | Geschlossen/offen, bereits berechnete Route, Durchgangsbelegung, Map-Synchronisation | Gewählte Linkkopplung und relevante Durchgänge; blockiert abhängigen Raum-/KI-Ausbau bei Fehler |
| Wahrnehmung / Suche | P4; erneut P7/P11 | Sicht verdecken, Quelle nach Geräusch bewegen, stumm schalten, unerreichbares Ziel, Reizwiederholung | Nachvollziehbare Verfolgung ohne Allwissenheit; noch kein finales Creature-Art notwendig |
| Save / Restore | Daten-/Besitzgrenzen ab P2; vollständiger Rundlauf P5; echte Inhalte P6/P7 | Altes manuelles Paket trotz überschriebenem Autosave, I/O-Fehler, Teilzustände, wiederholtes Laden | Dauerhaften Fortschritt; echte Inhaltsregression bleibt zusätzliche Pflicht |
| Renderer / Ressourcen | Hardware P0; Probe P2/P3; repräsentativer Raum P7 | Beleuchtung/Lampe/Material, Export, Editor plus Spiel, Lade-/RAM-Spitze | Renderer-/Ressourcenprofil vor Massenintegration; kein pauschales AAA-Ziel |

**Wiedervorlage:** Änderungen an Körpermaßen, Türanimation, Navmesh, Sicht-/Geräuschregeln, Save-Schema, Inhalts-IDs oder größeren Asset-/Lichtprofilen wiederholen die betroffene Probe. Ein grüner Test mit Primitiven gilt nicht automatisch für ein anders dimensioniertes Produktasset.

## 8. Junior-Playtests

Sieben feste Rückmeldepunkte ergänzen kleine freiwillige Zwischenproben. Ein Test fragt gezielt nach wenigen Dingen; die entwickelnde Person beobachtet zunächst ohne die Lösung vorzusagen. Bei Unwohlsein, Frust oder unklarer Bedienung darf jederzeit pausiert oder abgebrochen werden. Vor Horrorpräsentation werden E14a und ein passender begleiteter Rahmen geklärt, nicht Juniors Alter oder Belastbarkeit angenommen.

| Testpunkt | Zeitpunkt / Milestone | Was Junior selbst testet | Beobachtung / gewünschter Nachweis |
| --- | --- | --- | --- |
| J1 – Erster Movement-Test | P1 / M1 | Sicher bewegen, schauen, springen, ducken und einfach klettern | Macht Bewegung Spaß? Sind Eingaben verständlich? Wo hakt es oder wird die Kamera unangenehm? Testweg ohne Entwicklersteuerung bewältigbar. |
| J2 – Erste Interaktion | P2 / Zwischenstand M2 | Tür öffnen, Schalter bedienen, Item aufnehmen, Testhinweis lesen | Erkennt er Ziele und Rückmeldungen? Versteht er Erfolg/Ablehnung und Besitz? Keine Kenntnisse der Scriptstruktur voraussetzen. |
| J3 – Erste Verfolgung | P4 / M3 | Erkundung mit einer zunächst einfachen Kreatur, entdeckt werden, Sicht brechen, fliehen oder neu starten | Versteht er, warum er entdeckt wurde? Ist Gefahr spannend oder nur nervig? Hat er eine plausible Gegenmaßnahme? Grenzen E14a einhalten. |
| J4 – Erstes echtes Rätsel | Früh in P6 / auf dem Weg zu M5 | Ein vollständig freigegebenes Rätsel selbst lösen; später das zweite vergleichen | Hinweise nachvollziehbar? Lösung erklärbar? Fehlversuch verständlich? Kein stilles Tutorial durch Zurufen. |
| J5 – Erster vollständiger Roh-Slice | P7 / M6 | Gesamten vorgesehenen Ablauf inklusive Savepunkt und Abschluss spielen | Wo verliert er Orientierung? Ist ein Checkpoint fair? Kommen Hinweise und Enthüllung an? Dauer erstmals sinnvoll erfassen. |
| J6 – Balancingrunden | P11 / M7 | Wiederholte gezielte Durchläufe, darunter Flucht ohne Tempo-Vorrat und Rückkehr nach Niederlage | Erkennt er Gefahren, sieht er genug, wirken Ruhe/Bedrohung passend, bleibt Frust begrenzt? Veränderung gegenüber vorherigem Test festhalten. |
| J7 – Release Candidate | P12 / M8-Vorbereitung | Installierte Fassung ohne Editor/Debug starten, spielen, schließen und einen Stand laden | Vollständigkeit, verständliche Bedienung, fairer Wiederanlauf und Gesamtwirkung bestätigen; neue Fehler gehen zurück in die Stabilisierung. |

Ergebnis je Test: getesteter Build/Commit, kurze Ausgangslage, Beobachtung in Juniors Worten, reproduzierbare Fehler und klarer nächster Prüfpunkt. Nicht alle Geschmacksreaktionen sind Bugs; mögliche Designänderungen werden gemeinsam entschieden. Junior ist Mitautor und nach mehreren Tests vertraut mit dem Spiel: Zielzeit/Rätselverständlichkeit wenn möglich zusätzlich mit einer unvertrauten Testperson überprüfen. Hier wird keine bestimmte Testgruppengröße festgelegt.

## 9. Rollen, Entwicklungsworkflow und Astra-Review-Gates

### Verbindliche Rollenverteilung

Die folgenden Modellbezeichnungen bilden die vereinbarte Arbeitsaufteilung ab. Dieses Planungsdokument startet keine Agenten, delegiert keine Aufträge automatisch und erlaubt noch keine Implementierung.

| Rolle | Verantwortung | Grenze |
| --- | --- | --- |
| ChatGPT / Project Lead | Game- und Technical-Lead: Anforderungen/Scope, Aufgabenzerlegung, Promptvorbereitung, Bewertung der Ergebnisse, Unterstützung bei Designentscheidungen und Auswahl nötiger Senior-Reviews | Kein primärer Repository-Implementierer; kreative Freigaben bleiben bei den Spielautoren. |
| Claude Code / Opus 5.0 | Primärer Implementierer: Code-Erstentwurf, Godot-Szenen/GDScript, Tests, normale Featureintegration, Routine-Bugfixes und kleinere Refactorings | Zuerst eigener Self-Review und Fehlerbehebung; keine fehlenden Designfreigaben durch Annahmen ersetzen. |
| Codex / Astra High | Senior Engineer / Senior Reviewer: kritische Milestones, schwierige Architekturprobleme, komplexe Bugs, Save/Restore, Creature AI/Navigation, Performanceanalyse, größere Refactorings und Release-Candidate-Review | Keine Routineinstanz nach jeder Änderung; eng begrenzte Prüfung beziehungsweise gezielte Korrektur echter relevanter Probleme. |
| Godot | Praktische Laufzeitprüfung: Editor-/Exporttests, Physik, Navigation, Grafik, Audio und tatsächliches Spielverhalten | Ein Textreview durch ein Modell ersetzt niemals einen Godot-Test. Nicht ausgeführte Tests bleiben als fehlender Nachweis sichtbar. |
| Spielautoren / Junior | Spielgefühl, Spaß, Horrorwirkung, Verständlichkeit, Rätsel, Gestaltung und kreative Freigaben | Spielerische Rückmeldung ergänzt technische Tests; sie ersetzt keine Save-/Runtimeprüfung. |

### Normaler Entwicklungszyklus

1. Der Project Lead definiert einen begrenzten Auftrag mit Ziel, relevanten Dokumentabschnitten, erlaubten Dateien, Nicht-Zielen, Tests und Abnahmekriterien.
2. Claude liest zuerst die relevanten Dateien, implementiert, führt verfügbare Tests aus, macht einen Self-Review, prüft `git diff` und behebt selbst gefundene Probleme. Betroffene Tests werden nach Korrekturen erneut ausgeführt, bevor das Ergebnis zur Abnahme geht.
3. Der Stand wird praktisch in Godot und gegebenenfalls im Export getestet. Normale Fehler gehen zunächst zur Behebung an Claude zurück. Junior/User testen, sobald der Auftrag spielerisch relevant ist; die festen Testpunkte aus §8 bleiben bestehen.
4. Erst der getestete, eindeutig bezeichnete Stand geht am vorgesehenen Gate oder bei einem konkreten schwierigen Problem an Astra High. Astra prüft zusammengehörige Änderungen mit engem Fokus und ändert im autorisierten Korrekturauftrag nur echte relevante Probleme; kein stilgetriebener Neubau funktionierender Systeme.
5. Nach Korrekturen folgen betroffene Tests und ein erneuter Godot-Test. Der Project Lead bewertet Befunde und Grenzen; Commit und Milestone-Abnahme erfolgen gemäß Auftrag und §10, nicht automatisch durch ein Modellreview.

**Sequenzielle Übergabe:** Claude-Implementierung → getesteter Stand / autorisierter Commit → Astra-Review → gezielte Korrektur → erneuter Test → Abnahme. Ein getesteter Übergabecommit ist noch keine Milestonefreigabe und benötigt kein zusätzliches Versionslabel. Ist kein Commit autorisiert, wird der geprüfte Stand durch Basis-Commit und eindeutig abgegrenzten Diff festgehalten. Ohne vorgesehenes oder begründet zusätzliches Review-Gate kann normale Arbeit nach ihren Tests direkt zur Abnahme gehen.

Claude und Astra bearbeiten **niemals gleichzeitig unabhängig dasselbe Feature**. Vor dem Review wird der Übergabestand fixiert; während Astra prüft oder korrigiert, läuft keine konkurrierende Claude-Implementierung desselben Umfangs. Befunde werden anschließend eindeutig einem Korrekturauftrag zugeordnet, damit nicht beide dieselbe Lösung bauen. §12 erlaubt weiterhin unabhängige Arbeiten, keine konkurrierenden Implementierungen.

### Token- und Kosteneffizienz

**Astra reviewed Milestones, nicht Einzeldateien.** Astra High wird in dieser Arbeitsplanung als teurere/knappere Senior-Ressource gezielt eingesetzt; Routinearbeit verbleibt bei Claude.

- Zusammengehörige Änderungen eines Milestones möglichst gemeinsam prüfen; nicht jedes Script benötigt einen separaten Senior-Review.
- Claude prüft seinen Code zuerst selbst. Ein Review ist kein Ersatz für Self-Review, normale Fehlerbehebung oder fehlende Laufzeittests.
- Reviewauftrag auf konkrete Risiken und Nachweise begrenzen. Funktionierende Systeme nicht allein aus Stilgründen neu schreiben; Nachprüfung auf Befunde und betroffene Regressionen konzentrieren.
- Relevante Änderung, Basis-/Buildbezug, gezielte Dokumentreferenzen, Gate-Entscheidungen, Reproduktionsschritte, vorhandene Testresultate und bekannte Grenzen übergeben. Fehlende Tests ausdrücklich benennen, nicht als bestanden behandeln.

Beispiel P2: Claude implementiert den zusammengehörigen Interaktionsumfang mit Türen, Pickups, Schaltern und Interactor; danach erfolgen Godot-Tests. Nur bei konkretem Bedarf folgt ein fokussierter Zusatzreview des Gesamtsystems durch Astra, nicht vier einzelne Reviews. Die regulären Gates bleiben unverändert.

### Sechs reguläre Senior-Review-Gates

Alle R0–R5 sind Astra-Reviews auf einem von Claude implementierten und selbst geprüften Stand mit passenden Godot-Testbefunden. Junior/User testen an den zugeordneten Punkten vor dem Senior-Review; R0 benötigt noch keinen spielerischen Abnahmetest.

| Gate | Zeitpunkt | Vorbereitung / Senior-Fokus und Abschluss |
| --- | --- | --- |
| R0 – Projektbasis | Ende P0 / M0 | Claude implementiert die Basis und prüft Editor/Export. Astra führt einen kleinen Architektur-/Setup-Review durch: Ordner-/Quellassetgrenze, Main ohne Autoloads, frühe Sandbox, Engine-/Exportbefund. Keine Vorabarchitektur aller Systeme. |
| R1 – Player / Movement | Ende P1 / M1 | Claude implementiert, Godot und Junior testen. Astra prüft einen Positionsschreiber, Movementstruktur, Kollisions-/Traversalgrenzen, Input/Maus/Pause und Testbarkeit sowie spätere Restore-Verträglichkeit; Restore-Regressionsbedarf für P5 festhalten. |
| R2 – Creature | Ende P4 / M3 | Claude implementiert und behebt normale Bugs. Astra prüft eine FSM, Sicht, Geräusche, keine versteckte Spielerortung, Navigation/Türkopplung, Sichtverlust/Search/Return, Lebensdauer und kontrollierte Fehlerausgänge. |
| R3 – Save/Restore | Ende P5 / M4 | Claude implementiert und liefert Systemtests. Astra-High-Review ist wegen hoher Systemkritikalität verpflichtend: Snapshot-Isolation, IDs, Savepakete mit eigenem Todes-Wiederanlauf, I/O-Erfolg/Fallback, Restore/Pausentrennung, alte Signals, UI-Neubindung und Levellebensdauer. Noch offene Produktinhalte ausdrücklich abgrenzen. |
| R4 – Vollständiger Gameplay-Loop | Ende P7 / M6 | Claude integriert, Junior/User testen den vollständigen Ablauf. Astra prüft nur kritische systemübergreifende Punkte und Regressionen: reale Rätsel-/Story-/Weltzustände, Itemschutz, fairer Wiederanlauf, alte Saves, Save-/Restore- und Levellebensdauer sowie Ressourcenbefund; keine Sandbox-only-Freigabe. |
| R5 – Release Candidate | P12 vor M8 | Claude behebt bekannte Fehler und liefert Nachtests. Astra prüft abschließend kritische Regressionen, Save/Restore, Lifecycle, Performancebefunde und Releasekonfiguration einschließlich Export/Installation, Debugsperre, Lizenzbefunden und offenen Fehlern; Freigabeempfehlung nur mit belastbaren Nachweisen. |

**Zusätzliche Reviews nur bei konkretem Bedarf:** Der Project Lead kann einen engen Astra-Auftrag für einen schwer reproduzierbaren oder systemübergreifenden Bug, unzuverlässige Navigation einschließlich P2-Türkopplung, Save-Korruption, ein belegtes Performanceproblem, ein großes Refactoring oder eine Architekturänderung vorsehen. Eine nötige Planungsänderung braucht weiterhin gesonderte Freigabe. Das ist kein Pflichtreview nach jeder kleinen Änderung und keine Erlaubnis zum Scope-Ausbau. Blockierende Befunde werden behoben oder durch eine ausdrücklich freigegebene Änderung der betroffenen Planung gelöst; sie dürfen nicht nur als Kommentar im Code verbleiben.

### Kompakte Aufgabenzuordnung

| Claude: typische Implementierungsaufträge | Astra: gezielte Senior-Aufträge |
| --- | --- |
| Bootstrap, Main/UI-Grundhülle, Player Movement, Interaktion, Doors/Switches/Pickups, Inventory, Flashlight, Health, UI, Audiointegration, Story Trigger, freigegebene Rätsel, Assetintegration, Tests, normale Bugfixes und kleine Refactorings | Architekturreview, komplexe Creature-/Navigationsprobleme, Save-/Restore-Review, schwere systemübergreifende Bugs, große Refactorings, Performanceanalyse und Release-Candidate-Review |

Auch Creature und Save/Restore werden zunächst von Claude implementiert; ihre höhere Kritikalität begründet den Senior-Review, nicht zwei konkurrierende Erstimplementierungen.

## 10. Git-/Versionsstrategie

### Nachvollziehbare Integrationspunkte

Kleine zusammengehörige Änderungen committen, sobald sie innerhalb ihres Umfangs getestet sind. Kein riesiger Commit über mehrere Systeme, aber auch keine künstlich geplanten Tippfehler-Commits. Die nachfolgenden Bezeichnungen sind Vorschläge für spätere, jeweils autorisierte Integrationspunkte; in diesem Auftrag wird nichts committed oder getaggt.

| Stand | Sinnvoller Commit-Moment | Optionale interne Build-/Tag-Version |
| --- | --- | --- |
| M0 / P0 | Projektbasis und erster Windows-Export | `0.0.1` |
| M1 / P1 | Abgenommener Player-Prototyp | Commit-ID genügt; keine zusätzliche Spielversion nötig |
| P2 / M2-Zwischenstand | Interaktion, echte Aufnahmen und Türprobe | Commit-ID genügt |
| M2 / P3 | Interaktive Sandbox mit Items/Player State | `0.0.2` |
| M3 / P4 | Creature-/Verfolgungsprototyp | `0.0.3` |
| M4 / P5 | Persistenz und bestandene Restore-Systemtests | `0.0.4` |
| M5 / P6 | Beide Rätsel und Story-Progress integriert | Commit-ID genügt |
| M6 / P7 | Vollständiger Roh-Slice | `0.0.5` |
| M7 / P11 | Präsentabler integrierter Kandidat | `0.1.0-rc.1` |
| M8 / P12 | Geprüfte Releasefassung | `0.1.0` |

Weitere Kandidaten erhalten nur bei neuem prüfbarem Build eine fortlaufende RC-Kennung. P8–P10 können mehrere sinnvolle Integrationscommits haben, ohne je eine neue öffentliche Spielversion zu benötigen. Alle Vorabstände können intern bleiben; Nummerierung oder Tag ist keine Veröffentlichungsfreigabe.

**Drei getrennte Identitäten:** Spielversion beschreibt den Entwicklungsstand; Save-Schemaversion die Datenstruktur; Inhaltsrevision die kompatible Welt-/ID-Fassung. Nicht jede Spielversion ändert das Save-Schema. Änderungen an persistenten IDs/Inhaltsregeln erfordern dagegen eine bewusste Kompatibilitätsprüfung. Keine automatische Migration oder dauerhafte Abwärtskompatibilität zusagen. Teststände und echte Nutzer-Saves bleiben getrennt.

Ein Milestonevermerk sollte Build/Commit, Gate-Status und Testbefunde zusammenführen. Ein fehlgeschlagener Test wird nicht durch ein Tag geheilt; der gleiche geprüfte Stand muss später exportiert werden.

## 11. Abhängigkeiten

### Hauptpfad mit parallelem Präsentationsausbau

```text
P0 Basis → P1 Bewegung → P2 Interaktion + Inventory-Kern + Türprobe
                                       ↓
                       P3 Nutzung/Health/Neustart → P4 Creature
                                                        ↓
                            P5 Persistenz → P6 echte Rätsel/Story
                                                        ↓
                                              P7 vollständiger Roh-Slice
                                                ├── P8 Art/Licht ──┐
                                                ├── P9 Audio ─────┼→ P11 Integration → P12 Release
                                                └── P10 UI/UX ────┘

Hardware/Renderer: P0–P2 → Grafikbasis P3 → repräsentativer Befund P7
Autorenarbeit: parallel vorbereiten → Inhaltsgates vor P6/P7
```

Die Pfeile beschreiben Abnahmen und Mindestvoraussetzungen, keine Pflicht, unabhängige Arbeit künstlich warten zu lassen. In P2 ist der navigierende Prüfkörper bereits ein kleiner Teil der späteren Creature, keine fertige FSM. In P5 sind neutrale Puzzle-/Progress-Verträge bereits vorhanden, echte Regeln folgen P6. So entstehen keine versteckten Zyklen.

| Abhängigkeit | Warum / Konsequenz |
| --- | --- |
| E03/P1 → Räume und Fluchtwege | Körper-/Klettermaße zuerst testen, sonst muss das Level nachgebaut werden. |
| Inventory-Kern → echte Aufnahme | Fundstatus und Besitz müssen gemeinsam geändert werden; UI allein ist kein Inventory. |
| Türprobe → Creature-Routen → endgültige Durchgänge | Kollisionskörper, Navmesh und Link müssen zusammen funktionieren; Levelkonkretisierung braucht erneuten Nachweis. |
| Zustandsbesitzer + IDs + freigegebene Savepolitik → Persistenz | Save kann unklare oder doppelte Wahrheit nicht reparieren. |
| Neutrale Saveabnahme → echte Inhalte → erneute Saveabnahme | P5 schützt Systemgrenzen; P6/P7 prüfen konkrete Teilzustände, Einmalfolgen und Anker. |
| Autorenfreigabe → Puzzle-/Story-/Raumproduktion | Technische Platzhalter legen keinen Inhalt fest. |
| Hardware/Renderer/Importprobe/Budgets → größere Assetmengen | Früh gemessener Rahmen schützt den 16-GB-Rechner und verhindert teuren Präsentationsumbau. |
| P8/P9/P10 integriert → P11 → Release | Einzelne schöne Systeme genügen nicht für spielerische Geschlossenheit und Releasequalität. |

### Verbindliche spätere Regressionen früher Phasen

| Frühe Abnahme | Später erneut zu prüfen |
| --- | --- |
| P0 Weltlebensdauer/Input/Export | P5 Restore aus Pause/Game Over; P7 reale Welt; P12 installierter Release |
| P1 Bewegung/Traversal | P3 Tod/Tempo; P5 Haltung/Effekt/Position nach Restore; P7 tatsächliche Wege |
| P2 Door/Pickup/IDs | P4 KI-Route; P5 Snapshot; P6 Puzzlebindung; P7 reale Geometrie |
| P4 Wahrnehmung/Chase | P5 Resetpolitik; P7 Fluchtwege/Anker; P9 Mix ohne veränderte KI-Regeln |
| P5 Persistenz | P6 echte Inhalte; P7 räumliche Kombinationen; P11/P12 vollständige Regression |

## 12. Parallelisierbare Arbeiten

Parallelität meint unabhängige fachliche Arbeitspakete, nicht gleichzeitig widersprüchliche Änderungen an Main, Level oder Save-Verträgen. Claude und Astra dürfen dasselbe Feature nicht gleichzeitig unabhängig bearbeiten; für Implementierung, Review und gezielte Korrektur gilt die sequenzielle Übergabe aus §9. Gemeinsame Verträge werden zuerst abgestimmt; Integration erfolgt in kleinen nachvollziehbaren Ständen.

| Parallel möglich | Frühester sinnvoller Zeitpunkt | Grenze |
| --- | --- | --- |
| Gemeinsame Figuren-/Story-/Rätselerarbeitung | Bereits neben P0/P1, soweit die Autoren das wünschen | Kein Codeauftrag ersetzt ihre Freigabe; Umsetzung erst nach den jeweils einschlägigen Gates E14a/E14b, E15 und E16a/E16b. |
| Reine Inventory-/Save-Datentests und UI-Grunddarstellung | Nach den jeweils klaren Verträgen ab P2 | UI besitzt keinen eigenen Bestand; Save prüft keine erfundene Rätsellogik. |
| Audio-/Assetrecherche und Lizenzsichtung | Nach Inhaltsgrenzen, noch vor regulärer Produktion | Keine Käufe/Downloads durch diese Roadmap; kein perfektes Asset als Blocker früher Gameplaytests. |
| Kleine Renderer-/Importproben | P0–P2 neben Player/Interaktion | Auf echte Hardware und begrenzte Proben konzentrieren, keine vollständige Artpipeline vorziehen. |
| Art, Audiogestaltung und UI-Polish | Vorarbeiten früher, größerer Ausbau nach M6 | Dieselben Inhalte/Gates nutzen; Änderungen an Geometrie oder Regeln erneut integrieren/testen. |

### Placeholder → Produktinhalt

| Abschnitt | Geeigneter Inhalt | Wechselbedingung |
| --- | --- | --- |
| P0–P2 | Primitive, einfache lesbare Materialien, kleine Testgeräusche, neutraler Hinweis | Keine finalen Designs nötig; einzelne repräsentative Grafik-/Importprobe nach Gate erlaubt. |
| P3–P5 | Dieselbe Sandbox mit funktionalem Licht/Audio, einfacher Creature-Darstellung, neutralen Savefixtures | Regeln und Wahrnehmung bewerten, nicht durch Hochglanz verdecken. |
| P6 | Freigegebene Rätsel/Story mit weiterhin provisorischer Präsentation | Inhalt muss wirklich funktionieren, nicht nur als Textliste im Dokument stehen. |
| P7 | Eigene Rohlevelgeometrie, erste begrenzte Produktasset-/Audio-/Lichtintegration | Freigegebener Levelplan/Importworkflow; repräsentative Messung vor größerem Ausbau. |
| P8–P10 | Geeignete Modelle, nötige Animationen, Texturen/Materialien, Soundbibliothek, Musik und UI-Ausarbeitung | Gestaltung/Lizenzen/Budgets bestätigt; keine neue Funktion nur wegen eines Assets ergänzen. |
| P11–P12 | Integrierte Produktfassung | Keine störenden Pflichtpfad-Platzhalter; Änderungen nur noch mit gezielter Regression. |

## 13. Scope-Schutz

Verbindlich bleiben die Pflichtfunktionen aus GDD §30.3: Menü/Neues Spiel, First-Person-Bewegung einschließlich Sprint/Sprung/Ducken/Grundklettern, Interaktion/Türen/Schalter/Pickups, kleines Inventory, Lampe und Tempo-Item, Health/Tod/Wiederanlauf, **Autosave/Checkpoints plus manuelle Speicherpunkte**, zwei unterschiedliche Rätsel, Storyhinweise/Enthüllung/Cliffhanger, eine Kreatur mit Sicht/Hören/Chase/Search, minimale UI und atmosphärische Präsentation.

Nicht in den Pflichtpfad aufnehmen: Multiplayer, Open World, umfangreiches Crafting, Basebuilding, vollständiges Kampfsystem, weitere Kreaturen, Perspektivwechsel, Schwimmen, Voll-Parkour, komplexes Greifen/Ziehen, dynamischer Tag/Nacht-Zyklus, Sprachausgabe oder Quest-System. Auch einfaches Verstecken und kleine Kombinationen bleiben gemäß GDD optional; diese Basis-Roadmap plant sie nicht ein.

**Änderungsregel:** Neue Idee zuerst fachlich einordnen, Nutzen für den Slice und Auswirkungen auf bestehende Gates/Tests benennen. Erst nach ausdrücklicher Scopeentscheidung darf ein späterer Auftrag sie aufnehmen. Sonst separat parken. Ein technisches Hindernis ist kein Freibrief für neue Gameplaymechaniken, mehrere Rendererpfade, globale Manager oder eine andere Speicherpolitik.

Ab M6 steht der vollständige Pflichtpfad im Vordergrund; ab dem Release Candidate werden keine neuen Features begonnen. Bei Kapazitätsproblemen zuerst optionalen Umfang, Raumgröße oder überzogene Präsentationskomplexität überprüfen. Pflichtsavearten, zweites Rätsel oder robuste Tests nicht still streichen. Eine Änderung des freigegebenen Kernumfangs wäre eine neue gemeinsame Entscheidung.

## 14. Post-0.1-Ideen

Dies ist eine Einordnung, kein versprochener Backlog und keine Abhängigkeit für 0.1.

| Status nach GDD | Möglicher späterer Gegenstand | Voraussetzung |
| --- | --- | --- |
| Ausdrücklich später vorgesehen | Controller-Unterstützung | Funktionierender Tastatur-/Mauskern, eigener späterer Auftrag |
| Optional für 0.1, hier nicht eingeplant | Einfaches Verstecken, kleine Kombinationen/Crafting, Perspektivwechsel | Nach dem Kern separat Nutzen/Aufwand prüfen; keine Zusage zur Aufnahme |
| Weitergehende Gesamtvision | Schwimmen, Rutschen, mehr Parkour, Greifen/Ziehen | Konkreten spielerischen Einsatz auswählen, nicht vorsorglich implementieren |
| Interessant, aber nicht zugesagt | Begrenzte Abwehr, Tag/Nacht, Zeit-Challenges oder Minigames | Neue fachliche Auswahl und Scopefreigabe |
| Keine automatische spätere Zusage | Multiplayer, viele Kreaturentypen, umfangreicher Kampf/Crafting, Sprachausgabe | Grundsätzlicher Nutzen müsste erst entschieden werden |
| Würde die Grundrichtung ändern | Große Open World, klassisches Basebuilding, XP-/Level-System | Ausdrückliche Änderung der Spielvision erforderlich |

## 15. Roadmap-Risiken

| Produktionsrisiko | Früh sichtbares Warnzeichen | Reaktion |
| --- | --- | --- |
| Zu lange Infrastrukturphase | P0 produziert viele Manager/Dateien, aber keinen startbaren Export | Zum kleinsten Main-/Sandboxstand zurückkehren; geplante Dateiübersicht ist keine Vorab-Erstellungsliste. |
| Nur scheinbare frühe Spielbarkeit | Pickup verschwindet ohne Besitz, Neustart ist ein Debugteleport, KI folgt verborgenem Playerziel | Echte kleine Zustandsänderung und die vereinbarten Verträge abnehmen; Demo nicht als funktionierendes System zählen. |
| Zirkuläre Phasenabhängigkeit | Türtest wartet auf volle KI, Save wartet auf finale Story, Bewegung wartet auf Restore | Wiederverwendbare frühe Teilproben plus ausdrücklich spätere Integrationsabnahmen wie in §§3/11. |
| Unentschiedene Regeln werden im Code festgelegt | „Nur vorläufig“ wird ohne Review zum Produktverhalten | Betroffenes Gate schließen, bevor die verbindliche Implementierung beginnt. |
| Contentproduktion überholt Technik | Viele fertige Räume vor Bewegung-/Navnachweis oder Assets vor Budget | Proben/Gates vorziehen, abhängigen Ausbau begrenzen; unabhängige Autorenarbeit kann weiterlaufen. |
| Save wird einmal getestet und vergessen | Neutrale P5-Fixtures gelten auch für alle späteren Rätsel-/Levelzustände | P6/P7/P12 verpflichtende reale Regressionen; unerfüllte Fälle nicht als Done markieren. |
| Zu spätes Rendering-/Audiofeedback | Lampen-/Warnwirkung wird erst kurz vor Release erprobt | Erste technische Proben P1–P4; Produktprofil vor Ausbau, finale Mischung später. |
| Alleinige Routine-Spieltests | Junior kennt nach vielen Durchläufen jede Lösung; Zeit scheint zu kurz | Erstlaufregel beachten, beobachten ohne Zuruf, wenn möglich unvertraute Testperson ergänzen. |
| Horror wird nur frustrierend oder unlesbar | Entdeckungen unverständlich, dauernder Alarm, notwendige Wege unsichtbar | Wahrnehmung/Rückmeldung, Licht und Rhythmus innerhalb der bestätigten Regeln überarbeiten. |
| Ressourcen-/Lizenzprobleme spät sichtbar | Importspitzen, dauerhaft gehaltene Welten, unklare Rechte | Kleine Assetproben, Messung mit Editor und Spiel, Rechte je Integration und nochmals vor Release prüfen. |
| Unendlicher Polish/Scope Creep | Neue Mechaniken werden als kleine Qualitätsverbesserung getarnt | Pflichtpfad/DoD schützen, Ideen parken, RC ohne neue Features. |
| Review wird Ersatz für Tests | Code wirkt plausibel, Export-/Restorefälle wurden nicht gespielt | Reviews müssen Befunde/fehlende Nachweise klar trennen; Release nur nach praktischer Abnahme. |

## 16. Definition of Done für V0.1

Version 0.1.0 ist erst fertig, wenn **alle** folgenden Bereiche praktisch belegt sind. Die Roadmap selbst erfüllt diese Bedingungen noch nicht.

### Spiel und Inhalt

- Ein vollständiger Durchlauf vom Startmenü bis zum erkennbaren Abschluss funktioniert ohne Entwicklerwerkzeug und entspricht den freigegebenen Inhalten.
- Zwei tatsächlich unterschiedliche Rätsel, Storyhinweise, erste größere Enthüllung und Cliffhanger sind vorhanden und nachvollziehbar; keine erfundenen Platzhalter gelten als fertige Geschichte.
- Der normale erste Durchlauf erreicht ungefähr 15–25 Minuten gemäß GDD-Messregel. Die Dauer wird nicht durch künstliche Wartezeiten oder unnötige Wege erzwungen.
- Alle Pflichtbewegungen funktionieren verlässlich; die eine Kreatur reagiert nachvollziehbar auf Sicht/Geräusche, verfolgt, sucht und kehrt zurück, ohne Allwissenheit oder Teleportkorrektur.
- Flucht und Fortschritt bleiben ohne Tempo-Vorrat möglich. Kritische Items, Fehlversuche und Save-/Restorekombinationen erzeugen keinen Softlock.

### Persistenz und Bedienung

- Autosave/Checkpoints und zusätzliche manuelle Speicherpunkte funktionieren dauerhaft über Prozessende und Neustart; kein freies Speichern an beliebiger Position vorausgesetzt.
- Jeder ladbare Stand behält seinen zugehörigen Todes-Wiederanlauf, auch nach Überschreiben anderer Autosaves. Player/Inventory/Funde/Türen/Rätsel/Story/Begegnung passen zusammen.
- Schreibfehler erhalten einen brauchbaren vorherigen Stand; Erfolg/Fehler und inkompatible Daten werden ehrlich angezeigt. Unterdrückte alte Signals, Snapshotkopien und kontrollierter Weltneuaufbau sind regressionsgeprüft.
- Start, Pause, Inventory, Storytext, Health-/Schadensfeedback, Interaktion, Save-Rückmeldung, Game Over und Abschluss sind ohne Debug erreichbar. Fokus/Maus und Nutzereinstellungen stimmen nach jedem Übergang.

### Präsentation, Leistung und Release

- Zusammenhängende realistisch wirkende 3D-Präsentation ohne Pixel-Art/bewusste Verpixelung, mit guter Orientierung statt dauerhafter extremer Dunkelheit.
- Bewegung, Optik, Atmosphäre und Sound tragen das Erlebnis; keine störenden sichtbaren Pflichtpfad-Platzhalter oder fehlenden relevanten Warngeräusche.
- Referenzhardware und Leistungs-/Lade-/Ressourcenziele sind entschieden und gemessen; Editor plus Spiel bleiben auf dem 16-GB-Entwicklungsrechner praktikabel, der Release erfüllt sein bestätigtes Profil.
- Installierte Windows-x86-64-Fassung funktioniert als normaler Benutzer ohne Editor/Entwicklungspfade; Debugeingriffe sind gesperrt, benötigte Ressourcen/Export Templates passen, Lizenzen sind geprüft.
- Junior-Testpunkte, kritische Reviews und relevante Nachtests liegen mit Buildbezug vor. Keine bekannten reproduzierbaren Abstürze, Datenverlust-/Fortschrittsblocker oder fehlenden Kernfunktionen offen. Kleine verbleibende Fehler müssen ausdrücklich bewertet sein und dürfen diese Kriterien nicht verletzen.

### Bezug auf die freigegebenen Acceptance Criteria

| TDD-Prüfbereich | Erste Systemabnahme | Verbindlicher Endnachweis |
| --- | --- | --- |
| AC-01–03 Flow, Bewegung, Kamera/Input | P0/P1 | P5 Restore, P7 realer Raum, P12 Release |
| AC-04–08 Effekt, Health, Interaktion, Inventory, Lampe | P2/P3 | P5/P6 Zustand, P11/P12 Gesamtspiel |
| AC-09 Rätsel | Neutraler Vertrag P5, echter Inhalt P6 | P7/P11/P12 Lösbarkeit und Savekombinationen |
| AC-10–14 Creature, Sicht, Geräusch, Navigation, Chase/Search | Türprobe P2, komplette KI P4 | P5 Reset, P7/P11/P12 Fairness/Integration |
| AC-15 Traversal | P1 | P3/P5 Zustandswechsel, P7/P12 Pflichtwege |
| AC-16–17 Story und Save/Restore | P5 neutrale Daten, P6 echte Story | P7 und komplette TDD-§26.3-Regression in P12 |
| AC-18–20 UI, Audio, Levelfluss | Funktionsanteile P0–P7 | P8–P11 Qualität, P12 installierter Durchlauf |
| AC-21–22 Daten/Konfiguration, Performance | P0–P5 Basis, P7 repräsentative Messung | P11/P12 Integrität und Ressourcenverhalten |
| AC-23–25 Export, Debugisolation, optionaler Umfang | Export P0, Isolation fortlaufend | P12 ohne Debugpflicht oder optionale Abhängigkeit |

Die vollständigen Kriterien im TDD werden durch diese Zuordnung nicht verkürzt. Architektur §29 und die GDD-Qualitätsziele gelten zusätzlich; eine einzelne erfolgreiche „Golden Path“-Vorführung genügt nicht.

## 17. Übergang zu TASKS.md

Nach Freigabe dieser Roadmap wird TASKS.md in einem eigenen Auftrag abgeleitet. Der Project Lead bereitet grundsätzlich Implementierungsaufträge für **Claude Code / Opus 5.0** vor. Sie sollen zunächst P0 und anschließend den kleinsten spielbaren P1-Stand abdecken, nicht die gesamte Architektur auf einmal erzeugen. **Codex / Astra High** erhält gesondert gekennzeichnete Senior-Review-, Diagnose- oder gezielte Korrekturaufträge gemäß §9.

Jeder spätere Task soll enthalten:

- Task-ID, Phase/Milestone, Aufgabentyp und verantwortliche Rolle.
- Ziel und begrenztes sichtbares Ergebnis; erfüllte Gate-/Systemvoraussetzungen.
- Relevante Dokumentabschnitte und betroffene Bestandsdateien als gezielter Lesekontext.
- Ausdrücklich erlaubte Dateien und Nicht-Ziele.
- Überprüfbare Abnahmekriterien und auszuführende Tests einschließlich nötiger Godot-/Exporttests.
- Self-Review-Anforderung für Claude: relevante Dateien lesen, implementieren, verfügbare Tests ausführen, eigenen Code und `git diff` prüfen, selbst gefundene Probleme beheben und nachtesten; fehlende Testmöglichkeiten melden.
- Git-/Commitregel: ob und in welchem Umfang ein Commit erlaubt ist; keine automatische Commitfreigabe durch einen Taskstatus.
- Kennzeichnung, ob danach ein Astra-Review erforderlich ist: reguläres Gate R0–R5 mit Zeitpunkt/gebündeltem Umfang, begründeter Zusatzreview oder kein separater Senior-Review. Enge Reviewfrage und nötige Übergabenachweise angeben.

Ein Task soll klein genug für Umsetzung und Self-Review bleiben; Senior-Reviews bündeln dagegen die zusammengehörigen Ergebnisse des jeweiligen Milestones. Hier werden noch keine Mikroaufträge oder einzelnen Scriptänderungen formuliert. Bei gezielter Korrektur ist eindeutig festzulegen, ob Claude oder Astra sie ausführt; niemals beide unabhängig am selben Feature.

**Gezielter Kontext statt vollständiger Neulektüre:** Der Project Lead verweist auf tatsächlich relevante Abschnitte, etwa GAME_DESIGN §…, TECHNICAL_DESIGN §… und ARCHITECTURE §…, sowie die benötigten Nachbarsysteme und Gate-Beschlüsse. Keine pauschale Pflicht, bei jeder Kleinaufgabe sämtliche großen Planungsdokumente erneut vollständig zu lesen. Geltende Repository-Regeln bleiben verbindlich; reicht der bereitgestellte Ausschnitt nicht aus oder erscheint ein Widerspruch, den Kontext gezielt erweitern und fehlende Freigaben klären statt raten.

Sinnvolle Status unterscheiden: geplant, Gate offen, implementiert, praktisch geprüft und abgenommen. Ein offener Gatebefund, ausstehender Senior-Review oder später nötiger Regressionstest wird sichtbar mitgeführt. Weder Claude noch Astra ersetzen fehlende Gameplayfreigaben durch eigene Annahmen. Claude-Self-Review gehört zu jedem Implementierungsauftrag; Astra-Review und Junior-Feedback werden an den vorgesehenen Punkten eingeplant, nicht pauschal nach jeder Textkorrektur.

### Konsistenz- und Produktionsprüfung dieses Entwurfs

| Grundlage / Frage | Ergebnis des Dokumentabgleichs |
| --- | --- |
| GDD, besonders §§29–32/34 | Beide Speicherarten, zwei Rätsel, eine Kreatur, Pflichtbewegungen und 15–25-Minuten-Ziel erhalten; keine konkreten Rätsel, Story, Räume oder Werte erfunden. |
| TDD 0.2, besonders §§17/26/30–31 | Systembasis und fertiger Slice getrennt; Save-/Restore- und Zustandskombinationen früh sowie erneut mit echten Inhalten geprüft; offene Regeln zeitlich zugeordnet. |
| ADR-001 bis ADR-008 | First Person, kontrollierte Objekte, kleine vollständig geladene Welt, Engine/Exportziel und JSON/user:// berücksichtigt; Renderer offen bis Test-/Auswahlgate. |
| Architektur 0.2 | Main ohne Autoloads, ein Player-Motor/eine KI-FSM, lokale Zustandsbesitzer, eine Sandbox, bedarfsweise Türlinks, eigenständige Savepakete und keine zusätzlichen Frameworks. |
| Früh spielbar? | Ja: P0 startet, P1 liefert erste selbst spielbare Bewegung; Interaktion, Bedrohung und Persistenz folgen als sichtbare Stände. |
| Risiken früh genug? | Bewegung/Traversal P1, Türnavigation P2, Wahrnehmung P4, dauerhafte Saves P5; Hardware/Rendererprobe schon P0–P2. |
| Lange Infrastrukturphasen? | Keine Vollimplementierung aller Manager/Dateien vor Spielbarkeit; frühe Teilproben verwenden spätere Produktionssysteme. |
| Offene Entscheidungen rechtzeitig? | §6 verknüpft sie mit der tatsächlich abhängigen Arbeit; frühes UI/Inventory und Rendering haben vorgezogene Gates, späte Inhalte bleiben zunächst offen. |
| Scope geschützt? | Pflichtumfang bleibt vollständig; optionale und visionsfremde Ideen erzeugen keine Abhängigkeiten. RC dient Stabilisierung, nicht Expansion. |
| Entwicklungsworkflow konsistent? | ChatGPT führt und bereitet Aufträge vor; Claude implementiert mit Self-Review; Astra prüft sechs reguläre Gates und begründete Sonderfälle. Godot-Laufzeittests und Junior-/Autorenfreigaben bleiben eigenständige Nachweise; keine konkurrierende Implementierung desselben Features. |

**Prüfergebnis:** Keine fachlichen Widersprüche zu den freigegebenen Grundlagen festgestellt. Dies ist eine Dokumentprüfung; keine Phase, Laufzeitabnahme oder Hardwaremessung wurde dadurch ausgeführt. Ausschließlich ROADMAP.md wird in diesem Auftrag bearbeitet; TASKS.md, Architektur, Code, Szenen und Git-Historie bleiben unverändert.

## 18. Dokumenthistorie

| Dokumentversion | Datum | Änderung |
| --- | --- | --- |
| 0.1 | 20.09.2026 | Platzhalter durch Roadmap mit 13 Phasen, neun Milestones, Entscheidungsgates, frühen Risikoprototypen, sieben Junior-Testpunkten, sechs regulären Review-Gates und interner Versionsstrategie ersetzt. Frühe Spielbarkeit, wiederkehrende Inhalts-/Restoreabnahmen, Scope-Schutz und Release-DoD beschrieben. Keine Implementierung, keine Änderung weiterer Dateien, kein Commit. |
| 0.2 | 20.09.2026 | Ausschließlich Entwicklungsworkflow angepasst: ChatGPT als Project Lead, Claude Code / Opus 5.0 als primärer Implementierer mit Self-Review, Codex / Astra High als gezielter Senior Engineer/Reviewer. Sechs bestehende Review-Gates neu zugeordnet, sequenzielle Übergabe und Token-/Kosteneffizienz beschrieben, TASKS-Vorbereitung und Rollenverweise angeglichen. Phasen, Milestones, technische Gates, Junior-Tests, Architektur, Scope, Versionierungsstrategie und Definition of Done unverändert. Keine Implementierung, keine Änderung weiterer Dateien, kein Commit. |
