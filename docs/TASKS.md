# Dark Rooms – Operative Aufgabenplanung

**Version:** 0.1 · **Stand:** 20.09.2026 · **Status:** Erste Aufgabenplanung; keine Implementierung, Tests oder Reviews ausgeführt.

## 1. Grundlage und Reichweite

Verbindliche Grundlage sind AGENTS.md, CLAUDE.md, [GAME_DESIGN.md](GAME_DESIGN.md), [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md) 0.2, [DECISIONS.md](DECISIONS.md), [ARCHITECTURE.md](ARCHITECTURE.md) 0.2 und [ROADMAP.md](ROADMAP.md) 0.2 sowie der aktuelle Planungsauftrag. Kürzel: **GDD**, **TDD**, **ADR**, **Architektur**, **Roadmap**. Abschnittsnummern beziehen sich auf diese Fassungen. Neuere angenommene ADRs konkretisieren ältere Offen-Markierungen nur in ihrem ausdrücklich beschlossenen Umfang.

Detailliert werden ausschließlich **P0 / M0** und **P1 / M1**: fünf P0-Tasks und sechs P1-Tasks einschließlich ihrer Review-/Abnahmearbeit. Davon sind jeweils vier Claude-Arbeitspakete, ergänzt um R0 beziehungsweise J1-Abnahme und R1. P2–P12 bleiben zukünftige Taskgruppen. Diese Planung beauftragt noch keine Durchführung und startet keine Agenten.

**Bestand bei Planung:** Unter `game/` liegt nur `.gitkeep`; es gibt noch kein `project.godot`, keine Szenen oder Scripts. Genannte Runtime-Pfade sind deshalb geplante, bedarfsweise Dateien. Bereits vorhandene Änderungen an den fünf fachlichen Planungsdokumenten gehören zum vorgefundenen Stand und werden nicht überschrieben. Der aktuelle Auftrag verändert ausschließlich `docs/TASKS.md`; keine Implementierung, Godot-Imports, Downloads, Assets oder Commits.

### Rollen

| Rolle | Aufgabe |
| --- | --- |
| ChatGPT / Project Lead | Definiert Tasks, bereitet konkrete Claude-Prompts vor, bewertet Berichte und entscheidet mit den Spielautoren über Scope/Gates; bestimmt, wann Astra zusätzlich benötigt wird. |
| Claude Code / Opus 5.0 | Primärer Implementierer für GDScript und Godot-Szenen; Tests, Self-Review, normale Fehlerbehebung und Prüfung von `git diff`. |
| Codex / Astra High | Senior Engineer / Reviewer an R0/R1 oder bei einem ausdrücklich eingegrenzten schwierigen Problem; kein paralleler zweiter Erstimplementierer. |
| Godot | Praktischer Nachweis von Editor-, Runtime- und Exportverhalten; ein Textreview ersetzt diesen Nachweis nicht. |
| Spielautoren / Junior | Spielgefühl, Verständlichkeit und kreative Abnahme; Junior testet früh informell und am Ende von P1 formal in J1. |

Die ältere umgekehrte Implementierungs-/Reviewzuordnung in TDD §1 wird für diese Tasks durch Roadmap §9 und den aktuellen Auftrag überholt. Historische Formulierungen „zur Freigabe“ in den Quelldokumenten lösen hier keine erneute Gesamtfreigabeschleife aus. Konkrete offene Gates bleiben bestehen.

## 2. Gemeinsame Ausführungsregeln

Die folgenden Regeln gehören zu jedem Task und sind beim Erstellen seines konkreten Auftrags mitzunehmen. Eine Dateiliste bezeichnet die maximale sachliche Änderungsgrenze eines späteren Auftrags, keine Aufforderung, alle aufgeführten Dateien anzulegen.

### Status und Nachweise

| Status | Bedeutung |
| --- | --- |
| PLANNED | Arbeit beschrieben; Voraussetzungen oder Beauftragung stehen noch aus. |
| GATE_OPEN | Eine benannte Entscheidung beziehungsweise ein erforderlicher Nachweis fehlt vor der abhängigen Arbeit. |
| READY | Klar begrenzter Auftrag kann vergeben werden; kein automatischer Arbeitsbeginn. |
| IN_PROGRESS | Konkret beauftragte Arbeit läuft. |
| IMPLEMENTED | Änderung liegt vor; praktische Abnahme noch ausstehend. |
| RUNTIME_TESTED | Die für diesen Task nötigen Godot-/Exporttests sind belegt, soweit anwendbar. |
| REVIEW_REQUIRED | Getesteter Übergabestand wartet auf das zugeordnete Senior-Review. |
| ACCEPTED | Project Lead hat Kriterien und Befunde bewertet; nötige Autoren-/Juniorfreigabe und Reviews liegen vor. |
| BLOCKED | Durchführung stößt auf einen konkreten dokumentierten Hinderungsgrund mit nächstem Klärungsschritt. |

Das Modell ist keine zwingende lineare Kette: Ein reiner Befund- oder Reviewtask braucht kein künstliches `IMPLEMENTED` oder `RUNTIME_TESTED`. Ein Task wird niemals allein wegen geschriebenen Codes oder eines Modellurteils `ACCEPTED`. Einzelne geprüfte Untertasks können vor dem gebündelten Review angenommen werden; **M0/M1 sind erst nach R0/R1 abgenommen**. Ein offener Fehler kann einen Status zurücksetzen.

Jeder Testbericht nennt Task-ID, Datum, Basis-Commit und abgegrenzten Diff oder autorisierte Commit-ID, Enginepfad/-version, Testprofil, Ausgangslage, Schritte, Soll/Ist und Ergebnis. Ergebnisse heißen bestanden, fehlgeschlagen, nicht ausgeführt oder noch nicht anwendbar; letztere beiden zählen nicht als bestanden. Kein fiktiver Buildbezug. Bei ungecommitteten Änderungen Dateiliste und Diff-Bezug so festhalten, dass zwischen Test und Review keine unbemerkte Änderung liegt.

### Gezielter Lesekontext und Dateigrenzen

- AGENTS.md und CLAUDE.md gelten in jedem Task. Zusätzlich nur die im Task genannten Dokumentabschnitte und betroffenen Bestandsdateien lesen; bei einer konkreten Lücke gezielt angrenzenden Kontext ergänzen.
- Als Bestandsdatei gilt ein Runtime-Pfad erst nach seiner tatsächlichen Erstellung im Vorgängertask. Fehlt eine erwartete Voraussetzung, melden statt ein Ersatzsystem bauen. `.gitignore` vor Export-/Importarbeiten lesen.
- **D1 – Befundpflege:** In späteren beauftragten Tasks dürfen ausschließlich deren Status, Gatebelege, Testbefunde und Abnahmevermerke in `docs/TASKS.md` ergänzt werden. Keine Neufassung fremder Tasks. Alternativ zunächst Bericht an den Project Lead; die konkrete Beauftragung legt die Pflege fest. Andere Planungsdokumente brauchen einen gesonderten Änderungsauftrag.
- Zu erlaubten neuen Scripts/Ressourcen gehören ihre erforderlichen Godot-UID-/Importmetadaten. Generierter Cache `game/.godot/` und Ausgaben unter `exports/` bleiben gemäß bestehender `.gitignore` unversioniert. Keine pauschale Freigabe für sonstige generierte Dateien oder geänderte Editorpräferenzen.
- **V1 – Gemeinsame Verbote:** Keine Änderungen außerhalb des Taskumfangs, keine fremden Änderungen zurücksetzen, keine ungefragten Engineupdates, Autoloads, globalen Manager/Event-Busse oder zusätzliche Testarchitektur. Keine vorsorglichen Dateien aus der gesamten Architekturübersicht. Keine neuen Gameplayentscheidungen, kein Inventory, Creature, Save/Restore, Rätsel, echtes Level, Produktassets, Ausdauer, Voll-Parkour oder andere spätere Systeme in P0/P1. Erlaubte Ausnahmen sind ausschließlich die im Task genannten neutralen Testmittel. Keine Assetdownloads oder Produktbibliotheken.

### Claude-Self-Review SR – in jedem Claude-Arbeitspaket verpflichtend

Nach der Implementierung beziehungsweise einer beauftragten Korrektur:

1. Relevante Änderungen selbst gegen Auftrag und Zuständigkeitsgrenzen prüfen.
2. Verfügbare automatisierte/CLI-Tests ausführen; nur sinnvolle bestehende oder auftragsbezogene Prüfungen verwenden.
3. Godot-Projekt auf Parser-, Import-, Ressourcen- und Laufzeitfehler prüfen.
4. `git diff` und `git diff --check` prüfen; neue, noch unversionierte Dateien zusätzlich vollständig lesen.
5. `git status --short` mit dem Ausgangsstand vergleichen: keine unbeabsichtigten Dateien verändert oder neu erzeugt?
6. Prüfen, ob Architektur oder Scope unbeauftragt erweitert wurden.
7. Selbst gefundene Fehler innerhalb des Auftrags beheben.
8. Betroffene Tests nach den Korrekturen erneut ausführen.
9. Nicht testbare Punkte, fehlende Werkzeuge und ausstehende menschliche Prüfungen ausdrücklich melden.

Der jeweilige Task ergänzt hierzu einen Prüfschwerpunkt. SR ist Teil der Durchführung, kein separater Astra-Auftrag. Bei reiner Bestandsprüfung ohne Projekt wird Punkt 3 mit „noch nicht anwendbar“ dokumentiert, nicht als bestandener Projekttest ausgegeben. Keine umfangreiche Testplattform nur zur Erfüllung dieser Liste bauen.

### Git, Übergabe und Commitregel G1

Vor Beginn Basis-Commit und vorhandene Änderungen erfassen. Nur sachlich zum Auftrag gehörende Dateien prüfen und gegebenenfalls explizit stagen; kein pauschales `git add .`, kein Zurücksetzen fremder Änderungen. **Claude darf nur committen, wenn der konkrete Auftrag dies ausdrücklich erlaubt.** Taskstatus, Dateifreigabe und diese Planung erteilen keine Commitfreigabe. Keine automatischen Tags oder Veröffentlichungen.

| Stabiler Integrationsstand | Vorgesehener Commit |
| --- | --- |
| P0-01 bis P0-04 geprüft, Editor-/Exportnachweis vorhanden | `Bootstrap Dark Rooms Godot project` |
| P1-01 bis P1-05 geprüft, vollständige Bewegung und J1 bewertet | `Implement first person player prototype` |

Kleine zusammengehörige Tasks dürfen bis zu diesen Integrationsständen ungecommittet bleiben. Ein ausdrücklich erlaubter getesteter Übergabecommit darf vor R0/R1 liegen; er bedeutet noch keine Milestone-Abnahme. Alternativ nach Review und Nachtests committen. Der konkrete Auftrag bestimmt den Zeitpunkt. Ohne Commit wird Basis plus klar abgegrenzter Diff übergeben. Während Astra den Stand prüft, implementiert Claude nicht gleichzeitig denselben Umfang. Normale Reviewbefunde gehen mit klarer Zuständigkeit an Claude; Astra korrigiert nur in einem gesonderten gezielten Auftrag.

## 3. Reihenfolge und offene Gates

| Reihenfolge | Task | Erstes sichtbares Ergebnis | Zulauf |
| --- | --- | --- | --- |
| 1 | P0-01 – Bootstrap / Environment Verification | Belastbarer Geräte-/Enginebefund und dokumentierbares Testprofil | R0 |
| 2 | P0-02 – Startbare Main-/UI-/Sandbox-Grundhülle | Editor zeigt Menü und neutrale Testwelt | R0 |
| 3 | P0-03 – Input-, Pause- und Fokus-Grundverhalten | Testwelt lässt sich sicher pausieren und verlassen | R0 |
| 4 | P0-04 – Windows-Testexport und Debug-/Release-Grenze | Standalone-Debugtest und startbare Release-Grundhülle | R0 |
| 5 | P0-05 – R0: Projektbasis prüfen | M0-Abnahmeempfehlung mit Nachweisen | R0 selbst |
| 6 | P1-01 – Früher spielbarer First-Person-Kern | Mausblick, WASD, Kollision, Gravity und Jump; informeller Junior-Test | R1 |
| 7 | P1-02 – Sprint und sicheres Ducken | Schneller laufen, unter Decke ducken, sicher aufstehen | R1 |
| 8 | P1-03 – Einfaches markerbasiertes Traversal | Erlaubtes Hindernis überwinden; Blockaden sicher behandeln | R1 |
| 9 | P1-04 – Testschritte und Movement-Diagnose | Hörbare echte Schritte und vollständige Bewegungsanzeige | R1 |
| 10 | P1-05 – Integrierter Movement-Test und J1 | Geprüfter vollständiger P1-Stand und Autorenfeedback | R1 |
| 11 | P1-06 – R1: Player / Movement prüfen | M1-Abnahmeempfehlung und spätere Regressionen | R1 selbst |

Nach P1-01 direkt eine kurze freiwillige Junior-Probe ermöglichen; nicht auf Sprint, Ducken, Traversal oder Footsteps warten. Sie ersetzt J1 nicht und ist kein zusätzlicher formaler Freigabestopp. Kritische technische Fehler werden vor weiterer Nutzung behoben. Neue Spielideen aus Feedback gehen an den Project Lead und die Autoren.

| Gate / offener Teil | Jetzt benötigter Befund | Behandlung |
| --- | --- | --- |
| E01 | Tatsächliche Godot-Version **4.7.2 Stable**, GDScript-Ausgabe, passende Windows-x86-64-Templates, CPU/GPU/VRAM/RAM/Windows | P0-01 erfasst und prüft. Bis zum Nachweis keine abhängige Projektanlage. Abweichende Installation nicht still ersetzen. **Beleg 20.09.2026: ERFÜLLT** (P0-01, Project Lead); Details bei P0-01 „Befund / Abnahme“. |
| E02a | Ein ausdrücklich gewähltes vorläufiges Renderer-Testprofil einschließlich Gerät und Testauflösung | P0-01 bereitet Auswahl vor; Project Lead bewertet den technischen Vorschlag. Keine Variante wird in dieser Planung bevorzugt. Vor P0-02 dokumentieren. **Beleg 20.09.2026: vorläufig gewählt** – Mobile + Vulkan, 1920×1080, erfasster Samsung-Laptop; Compatibility Rückfall, Forward+ späterer Vergleich (E02b); keine Endentscheidung für V0.1. |
| E03, zunächst Bedienung | Testbelegung für Pause und Regel bei Fokusverlust/-rückkehr | Vor P0-03 den benötigten Teil mit Project Lead/Autoren vorläufig bestätigen; keine neue Gate-ID. **Beleg 20.09.2026 (E03a, Project Lead, vorläufig für 0.1):** Escape toggelt Pause im aktiven Gameplay und setzt aus der Pause fort; im Menü/außerhalb des Gameplays löst Escape keine Fortsetzung aus. Fokusverlust im Gameplay pausiert automatisch; Fokusrückkehr setzt nicht automatisch fort, Fortsetzen nur bewusst durch den Spieler. Maus im aktiven First-Person-Gameplay später gefangen, im Menü und in der Pause sichtbar und frei; P0-03 bereitet diese Lebenszyklus-/Mauslogik vor und prüft sie in der Sandbox. Eingabe über Godot Input Actions, keine fest verdrahteten Tastencodes, kein Input-Manager/Event-Bus. Details bei P0-03 „E03a-Beleg“. |
| E03, Bewegung | Kamera/FOV/Empfindlichkeit/Blickgrenzen, Körpermaße, Geschwindigkeiten, Beschleunigen/Bremsen, Gravity, Sprung-/Luft-/Steigungsgrenzen und Bedienung | Vor P1-01 das benötigte vorläufige Profil freigeben. Sprint-/Duckkombinationen und Traversalauslösung/-grenzen spätestens vor P1-02/03 ergänzen. Bis J1/R1 reproduzierbare Befunde; keine finalen Raum-/Fluchtmaße. **Beleg 20.09.2026 (E03 Bewegung, Project Lead, vorläufiges Prototyp-Profil):** First Person, FOV 75°, Spielerhöhe ca. 1,80 m, Augenhöhe ca. 1,65 m, Capsule-Collision, Gehen 5,0 m/s, Sprint 8,0 m/s (erst P1-02), Bodenbeschleunigung 20 m/s², Bodenabbremsung 24 m/s², Schwerkraft ca. 9,8 m/s², Sprunghöhe ca. 1,25 m, reduzierte Luftsteuerung, Maus-Sensitivität als Tuningwert, keine Ausdauer, kein Head Bob, keine Kameraneigung; alle Werte vorläufig bis zum ersten Junior-Playtest. Details bei P1-01 „E03-Beleg“. **Nachtrag 20.09.2026 (E03 Sprint/Crouch, Project Lead, vorläufig):** Sprint linke Shift halten, 8,0 m/s, keine Ausdauer, nicht geduckt, Sprung aus Sprint mit erhaltenem Horizontalimpuls erlaubt; Crouch linke Strg halten, 2,5 m/s, Körper 1,80 → 1,20 m, Augen 1,65 → 1,05 m, kurzer weicher Übergang, Aufstehen nur bei freiem Raum, sonst geduckt bleiben; kein Crouch-Jump, Slide oder Prone. Details bei P1-02 „E03-Nachtrag“. **Nachtrag 20.09.2026 (E03 Traversal, Project Lead, vorläufig):** nur klar geeignete niedrige Hindernisse, automatische Erkennung vor dem Spieler ohne zusätzliche Taste, max. Hindernishöhe ca. 0,9 m, Erkennungsreichweite ca. 1,1 m, nur bei freiem Raum oberhalb/auf der Zielseite, kontrollierte Bewegung zur Zielposition ohne WASD währenddessen, First-Person-Kamera bleibt; kein Wallrun, Ledge-Grabbing, Vault-System, Durchqueren geschlossener Geometrie, keine Ausdauer. Details bei P1-03 „E03-Nachtrag Traversal“. **Nachtrag 20.09.2026 (E03 Schritte, Project Lead, vorläufig):** Schritt je 0,70 m (Gehen) / 0,90 m (Sprint) / 0,50 m (Ducken) zurückgelegter Bodenstrecke; nur bei Bodenkontakt und tatsächlicher horizontaler Bewegung, nicht im Stand, in der Luft, im Traversal oder nachgeholt nach Pause; Sprint ca. +2 dB, Ducken ca. −4 dB gegenüber Gehen; Tonhöhe ±3 % zufällig; separater Landungsimpuls nur nach relevantem Fall mit technisch gewähltem, im Junior-Test abzustimmendem Schwellenwert; kein Traversal-Sound; keine Oberflächen, kein finales Sounddesign. Details bei P1-04 „E03-Nachtrag Schritte“. |
| E12a | Kleine bekannte Testtonquelle, erlaubte Lautstärke, Hörgerät und benötigtes Testimportprofil | Vor P1-04 bestätigen; kein Blocker für den stillen frühen P1-01-Test. Keine finale Soundbibliothek. **Beleg 20.09.2026 (Project Lead, vorläufig):** projektintern erzeugter neutraler kurzer Footstep-/Impulston (keine externe Quelle/Lizenz, nur P1-04-Diagnose, später durch echte Footsteps ersetzt); WAV mono 44,1/48 kHz 16 Bit PCM, ca. 80–150 ms, Peak ca. −6 dBFS, ohne Kompression/Effekte; Laptop-Lautsprecher oder normale Kopfhörer bei moderater Lautstärke; Godot-Import unverändert, kein Streaming, keine Plugins/Zusatzarchitektur; nur technischer Testbeleg, keine Footstep-Bibliothek, Oberflächenvariation, Mixing oder 3D-Audio-Design. Details bei P1-04 „E12a-Beleg“. |
| E02b, E18, E21 | Regulärer Renderer, Ressourcenbudgets, unterstütztes Windows-/Paketprofil | Offen lassen: P0 bereitet Vergleich/Messung vor; E02b spätestens vor P3 beziehungsweise regulärer Grafikarbeit, E18 vor größerem Ausbau P7, E21 vor P12. |

Ein Gatebeleg nennt Entscheidung/Nachweis, Datum, verantwortliche Freigabe, Profil und Grenzen. Die Tabelle behauptet keine erfolgte Auswahl. Zahlen und Halten-/Umschaltregeln werden hier nicht erfunden. Offene spätere Gates verhindern nur die jeweils abhängige Arbeit; E04–E11 und Inhaltsgates sind keine Voraussetzung für eine neutrale P1-Teststrecke.

## 4. P0 – Projektbasis und technische Verifikation

### P0-01 – Bootstrap / Environment Verification

- **Task-ID:** P0-01.
- **Titel:** Engine, Hardware und vorläufiges Testprofil verifizieren.
- **Phase:** P0 – Projektbasis und technische Verifikation.
- **Milestone:** M0 – Projekt läuft; Zulauf R0.
- **Status:** ACCEPTED – 20.09.2026, geprüft und abgenommen durch Project Lead; Befund siehe „Befund / Abnahme“ unten.
- **Verantwortliche Rolle:** Claude Code / Opus 5.0 für Befunderhebung; Project Lead bewertet und koordiniert die Profilwahl.
- **Priorität:** Hoch; zuerst ausführen.
- **Ziel:** Die reale Entwicklungsbasis feststellen, bevor Projektdateien entstehen.
- **Sichtbares Ergebnis:** Kompakter Prüfbericht mit Enginepfad/-ausgabe, Templates, Gerätedaten, Abweichungen und begründetem Vorschlag für E02a.
- **Voraussetzungen / Gates:** Konkreter Auftrag zur Umgebungsprüfung. Keine Voraussetzung, E01/E02a schon als erfüllt zu kennen; genau diese Nachweise werden erarbeitet. Vollständiger Abschluss erst nach E01-Nachweis und dokumentierter E02a-Auswahl.
- **Relevante Dokumentreferenzen:** ADR-007 „Engine-Basis und erstes Exportziel“, ADR-008 „Rendererentscheidung bleibt offen“; TDD §§3, 23, 30.1/T-01/T-03; Architektur §§5, 30–31; Roadmap §5/P0 und §6/E01/E02a.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, `.gitignore`, `game/.gitkeep`; vorhandene Projekt-/Exportkonfiguration nur falls sie inzwischen tatsächlich existiert. Installations- und Templateinformationen lesend prüfen.
- **Erlaubte Dateien / Verzeichnisse:** Erster Durchlauf nur lesend, Bericht und D1. Bei fehlenden Templates darf eine ausdrücklich beauftragte Fortsetzung dieses Tasks ausschließlich den ermittelten Godot-Templateordner für die bestätigte Version ergänzen; exakten Zielpfad vorab im Auftrag festhalten. Keine pauschale Schreibfreigabe für Benutzer-/Installationsordner.
- **Ausdrücklich verbotene Änderungen:** V1; noch kein `project.godot`, keine Szenen/Scripts, keine Treiber-/Engineupdates. Keine Downloads oder Installationen im ersten Prüfauftrag. Fehlende Engine/abweichende Version nicht durch eine andere Baseline kaschieren.
- **Konkrete Arbeit:** 1. Git-Ausgangsstand aufnehmen. 2. Tatsächlich verwendbare Godot-Executable mit vollständiger Versionsausgabe und ohne .NET-Anforderung feststellen. 3. CPU, alle relevanten GPUs, tatsächlich verwendeten Adapter, dedizierten VRAM beziehungsweise Shared-Memory-Situation, RAM und Windows-Version/Build/Architektur samt Erhebungsquelle erfassen. Unzuverlässige VRAM-Angaben kenntlich machen und gezielt nachprüfen. 4. Passende Export Templates samt Windows-x86-64-Debug-/Releasevorlagen und Pfad prüfen. Falls sie fehlen: E01 offen lassen, genaue offizielle Quelle/Version und eng begrenzten Installationsschritt für einen Folgeauftrag benennen; nach erlaubter Installation erneut prüfen. 5. Forward+, Mobile und Compatibility anhand des Hardwarebefunds einordnen, ein temporäres Startprofil mit Testauflösung vorschlagen und die ausdrückliche Auswahl dokumentieren. Der Grafikvergleich folgt mit realer Probe, nicht durch Papierfreigabe.
- **Nicht-Ziele:** Projektbootstrap im Editor, Benchmark, endgültige Rendererwahl, Leistungsversprechen, Mindesthardware, Installer oder Gameplay.
- **Acceptance Criteria:** Alle Gerätefelder sind mit Quelle erfasst oder als konkreter Blocker benannt; Engine-/Templateabgleich ist nachvollziehbar. E01 wird nur bei passendem Nachweis erfüllt; E02a nur mit ausdrücklicher Auswahl. Kein installierter Stand wird allein aus ADR-007 behauptet. Fehlende Basis führt zum begrenzten Folgeauftrag statt zum Start von P0-02.
- **Auszuführende Tests:** Versionsabfrage der gefundenen Executable, Template-/Architekturabgleich, lesende Hardwareabfragen und Git-Vorher-/Nachhervergleich. Kein Testframework.
- **Erforderlicher Godot-Test:** Gefundene Engine starten, Versionsanzeige und fehlerfreien Editor-/Projektmanagerstart prüfen; kein Projekt erzeugen/importieren. Fehlt interaktiver Zugriff, als ausstehenden Nachweis melden.
- **Windows-Exporttest:** Noch nicht ausführbar; erster tatsächlicher Export in P0-04. Templateprüfung ist kein Exportnachweis.
- **Claude-Self-Review:** SR vollständig mit zutreffenden Prüfschritten; insbesondere keine Scheingenauigkeit bei VRAM, keine erfundene Installation, keine unbemerkten Schreib-/Downloadaktionen. Projektprüfung mangels Projekt als nicht anwendbar ausweisen.
- **Erwarteter Bericht:** Geräte-/Versions-/Templatetabelle, verwendete Quellen/Befehle, E01-Ergebnis, E02a-Vorschlag und gegebenenfalls Freigabebeleg, offene Installation/Entscheidung, nächster einzeln beauftragbarer Task.
- **Git-/Commitregel:** G1; kein eigener Commit erforderlich, kein Commit ohne ausdrücklichen Auftrag.
- **Astra-Review:** Gate R0 in P0-05; kein separater Setup-Review. Schwieriger Basisfehler nur nach Entscheidung des Project Leads an Astra.
- **Junior-Test:** Nein; noch keine spielbare Anwendung.
- **Blocker / offene Entscheidung:** Reale Installation, GPU/VRAM, Templates und E02a noch unbekannt. Abschluss kann eine gezielte Templateinstallation oder einen ausdrücklichen neuen Enginebeschluss benötigen; beides wird hier nicht vorweggenommen.
- **Befund / Abnahme (D1, 20.09.2026):**
  - **E01: ERFÜLLT.** Godot **4.7.2 Stable** (`4.7.2.stable.official.ed1daf0bf`), GDScript-Ausgabe ohne .NET, x86-64 bestätigt. Fester Enginepfad: `C:\GameDev\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe` (plus `_console.exe`). Export Templates `4.7.2.stable` (offizielles Paket, SHA512 geprüft) unter `%APPDATA%\Godot\export_templates\4.7.2.stable\` installiert; Windows-x86-64-Debug-/Release-Vorlagen vorhanden und verifiziert.
  - **Hardware/Windows:** Samsung Galaxy Book 750QGK, Intel Core 7 150U, nur integrierte Intel-GPU (128 MB dediziert / ~8 GB shared), 16 GB RAM, Windows 11 Home 25H2 Build 26200.9457, 1920×1080. Projektmanagerstart fehlerfrei; Vulkan-, D3D12- und OpenGL-Initialisierung geprüft.
  - **E02a: VORLÄUFIG GEWÄHLT** durch Project Lead: **Mobile-Renderer + Vulkan**, Testauflösung **1920×1080**, Zielgerät der erfasste Samsung-Laptop, möglichst Netzbetrieb. Compatibility bleibt Rückfalloption; Forward+ wird später mit repräsentativer Szene gegen Mobile verglichen (E02b). Keine endgültige Rendererentscheidung für V0.1.
  - Keine verbleibenden Blocker für P0-02. Der Nachweis der Templates im Editor-Dialog und der erste echte Export folgen mit dem ersten Projekt (P0-02/P0-04).
  - Repository blieb während P0-01 unverändert (Basis-Commit `1190611`; alle Installationen außerhalb des Repositories); kein Commit.

### P0-02 – Startbare Main-/UI-/Sandbox-Grundhülle

- **Task-ID:** P0-02.
- **Titel:** Minimales Godot-Projekt mit wiederverwendbarem Main-Lebenszyklus starten.
- **Phase:** P0 – Projektbasis und technische Verifikation.
- **Milestone:** M0 – Projekt läuft; Zulauf R0.
- **Status:** ACCEPTED – 20.09.2026, nach manuellem Godot-Test durch den Project Lead angenommen; Befund siehe „Befund / Abnahme“ unten. M0 bleibt bis R0 (P0-05) offen.
- **Verantwortliche Rolle:** Claude Code / Opus 5.0.
- **Priorität:** Hoch.
- **Ziel:** Ein kleines wirklich startbares Projekt ohne vorgezogene Systemarchitektur schaffen.
- **Sichtbares Ergebnis:** Main zeigt eine einfache GameUI; im Entwicklungsmodus startet eine neutrale Systems Sandbox mit Boden, Licht und Testansicht, Rückkehr zum Menü und Beenden funktionieren.
- **Voraussetzungen / Gates:** P0-01 abgeschlossen, E01 verifiziert und E02a ausdrücklich gewählt; konkreter Implementierungsauftrag.
- **Relevante Dokumentreferenzen:** ADR-003/007/008; GDD §27; TDD §§5/5.1, 20; Architektur §§5–6, 20–21, 25 „Main und Level“/„UI“, 29 „Ebenen“; Roadmap §5/P0.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, `.gitignore`, `game/.gitkeep`, P0-01-Bericht; bereits vorhandene Dateien innerhalb der folgenden Freigabe vor Änderung lesen.
- **Erlaubte Dateien / Verzeichnisse:** `game/project.godot`, `game/app/main.gd`, `game/app/main.tscn`, `game/ui/game_ui.gd`, `game/ui/game_ui.tscn`, `game/tests/systems_sandbox.tscn`, der minimale gemeinsame Levelkoordinator `game/levels/vertical_slice/vertical_slice.gd`; D1 und notwendige Metadaten gemäß §2.
- **Ausdrücklich verbotene Änderungen:** V1; kein `vertical_slice.tscn` als Produktlevel, kein Player, SaveService, Inventory, Creature, Navigation oder unbenutzte UI-Paneele. Keine zweite Sandbox-/Testflow-Steuerung und keine dauerhaft global vorgeladene Welt.
- **Konkrete Arbeit:** 1. `game/` als Projektroot mit bestätigter Engine und temporärem Rendererprofil anlegen. 2. Dauerhafte Main-Szene mit WorldHost und GameUI verbinden. 3. Nur nötige Menü-/Fehleransicht und Entwicklungsstart/Rückkehr/Beenden erstellen. 4. Eine primitive Sandbox mit fixer Testkamera bereitstellen; ihr Root verwendet den minimal benötigten gemeinsamen Levelvertrag, spätere Teilnehmer bleiben optional. 5. MENU/PREPARING/PLAYING und kontrollierten Abbau für diese Ausbaustufe umsetzen: genau eine Welt, Freigabe erst nach bereitem Aufbau, UI-Referenzen vor Abbau lösen. Keine noch funktionslosen Systeme für spätere Phasen anlegen.
- **Nicht-Ziele:** Movement, vollständige Menügestaltung, sämtliche Main-Phasen, Snapshot-/Neustartfunktion, Produktinhalt oder Rendereroptimierung.
- **Acceptance Criteria:** Projekt öffnet und startet fehlerfrei; Menü → Sandbox → Menü lässt sich wiederholen. Unter WorldHost existiert höchstens eine Welt; UI bleibt erhalten. Main/Level erfüllen ihre Besitzgrenzen ohne Autoload. Aufbau/Abbau erzeugt keine alten Referenzzugriffe. Die Testkamera ist die einzige aktive Weltkamera. Sandboxzugang ist als Entwicklungsfunktion begrenzt; keine Savefunktion oder Produktwelt behauptet. **Erfüllt (20.09.2026):** Start/Öffnen, wiederholter Weltwechsel, höchstens eine Welt, erhaltene UI, Besitzgrenzen ohne Autoload, keine alten Referenzzugriffe, einzige aktive Testkamera und begrenzter Sandboxzugang sind durch Headless-Test und manuellen Godot-Test belegt (siehe „Befund / Abnahme“).
- **Auszuführende Tests:** Verfügbare Godot-CLI-Import-/Parserprüfung und begrenzter Starttest; mehrfacher Weltwechsel mit Prüfung von Instanzen/Fehlerausgabe, ungültige benötigte Referenz diagnostizieren und Teständerung zurücknehmen; SR/Git-Prüfung. Keine KI-/Navbereitschaft erfinden, solange keine Navigation existiert.
- **Erforderlicher Godot-Test:** Projekt im Editor öffnen; Menü, Sandbox, Rückkehr und Beenden praktisch bedienen; wiederholten Aufbau im Remote Scene Tree kontrollieren.
- **Windows-Exporttest:** Folgt verbindlich in P0-04; Editorstart nicht als Standalone-Nachweis verbuchen.
- **Claude-Self-Review:** SR 1–9 vollständig; Schwerpunkt Main als Lebensdauerbesitzer, WorldHost später pausierbar, UI ohne Gameplaywahrheit und keine unnötigen Platzhalterdateien.
- **Erwarteter Bericht:** Dateiliste, kurzer Node-/Besitzüberblick, Startanleitung, reproduzierbarer Weltwechseltest, CLI-/Editorbefund und bekannte Grenzen für P0-03/04.
- **Git-/Commitregel:** G1; mit P0-03/04 zum geprüften Bootstrap-Integrationsstand bündelbar.
- **Astra-Review:** Gate R0 in P0-05, gemeinsam mit P0-01/03/04.
- **Junior-Test:** Optional Start/Beenden zeigen; kein formaler Abnahmetest.
- **Blocker / offene Entscheidung:** E01/E02a; bei Problemen nur betroffenen Aufbau diagnostizieren. Kein Rückfall auf ungeprüften Renderer oder andere Engine.
- **Befund / Abnahme (D1, 20.09.2026):**
  - **Stand:** Basis-Commit `3a1c2fa`; ungecommitteter Diff = neue Dateien `game/project.godot`, `game/app/main.gd` (+`.uid`), `game/app/main.tscn`, `game/ui/game_ui.gd` (+`.uid`), `game/ui/game_ui.tscn`, `game/levels/vertical_slice/vertical_slice.gd` (+`.uid`), `game/tests/systems_sandbox.tscn`. Keine versionierte Datei geändert; `game/.godot/` ignoriert.
  - **Engine/Profil:** `C:\GameDev\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe` (`4.7.2.stable.official.ed1daf0bf`); Mobile + Vulkan, Viewport 1920×1080 (E02a). Laufzeitlog: `Vulkan 1.4.323 – Forward Mobile – Intel(R) Graphics`.
  - **Aufbau:** Main (Node, ALWAYS, `main.gd`) → WorldHost (Node3D, PAUSABLE) + GameUI (CanvasLayer, ALWAYS). Phasen MENU/PREPARING/PLAYING, Laufgeneration pro Weltwechsel, Abbau mit `unbind_world` und abgewarteter Freigabe vor jedem Neuaufbau. Sandbox-Root nutzt den gemeinsamen Levelvertrag `vertical_slice.gd` (`prepare_world`, `set_gameplay_active`). Keine Autoloads. Sandboxzugang nur bei `OS.is_debug_build()` (Debug-/Release-Grenze wird in P0-04 festgelegt).
  - **CLI-/Headless-Tests (Claude, bestanden):** `--check-only` aller Skripte, `--headless --import` fehlerfrei; temporärer Headless-Laufzeittest außerhalb des Repos mit 122/122 bestandenen Prüfungen (5× Menü → Sandbox → Menü, genau eine Welt, Laufgeneration, UI-Bindung/-Lösung, genau eine aktive Kamera, Freigabe alter Welt, Sperre während PREPARING, Fehlerpfade fehlende Szene/ungültige Kamerareferenz mit Rückkehr ins Menü; Teständerung zurückgenommen). Fensterstart und Editorstart mit der festen EXE je 15 s fehlerfrei.
  - **Manueller Godot-Runtime-Test (Project Lead, 20.09.2026, bestanden):** Projekt startet mit F5; Hauptmenü funktioniert; Systems Sandbox lässt sich öffnen; 3D-Sandbox wird korrekt dargestellt; Rückkehr zum Menü funktioniert; keine sichtbaren Laufzeitfehler. Ergebnis: bestanden.
  - **Nicht ausgeführt / noch nicht anwendbar:** Windows-Export (P0-04); Pause/Fokus/Mausmodus (P0-03). Bekannte Grenzen: kein „Neues Spiel“ ohne Produktlevel; 1920×1080-Fenster überragt auf dem 1080p-Panel leicht den Bildschirm (Fenstermodus nicht Teil von P0-02).
  - Kein Commit; Bündelung mit P0-03/04 zum Bootstrap-Integrationsstand gemäß G1.

### P0-03 – Input-, Pause- und Fokus-Grundverhalten

- **Task-ID:** P0-03.
- **Titel:** Eingabeaktionen und sicheren Menü-/Pausenwechsel vorbereiten.
- **Phase:** P0 – Projektbasis und technische Verifikation.
- **Milestone:** M0 – Projekt läuft; Zulauf R0.
- **Status:** ACCEPTED – 20.09.2026, nach manuellem Godot-Test durch den Project Lead angenommen; Befund siehe „Befund / Abnahme“ unten. M0 bleibt bis R0 (P0-05) offen.
- **E03a-Beleg (Project Lead, 20.09.2026, vorläufig verbindlich für Version 0.1):**
  - **Pause:** Escape toggelt die Pause während aktivem Gameplay; Escape im Pausezustand setzt fort. In Hauptmenü-/Nicht-Gameplay-Phasen löst Escape keine ungewollte Gameplay-Fortsetzung aus.
  - **Fokusverlust:** Verliert das laufende Gameplay den Fensterfokus, wird automatisch pausiert. Bei Rückkehr des Fokus wird nicht automatisch fortgesetzt; der Spieler muss Fortsetzen bewusst auslösen.
  - **Maus:** Während aktivem First-Person-Gameplay wird die Maus später gefangen; im Hauptmenü und während der Pause ist der Zeiger sichtbar und frei. P0-03 bereitet diese Lebenszyklus-/Mauslogik bereits vor und prüft sie in der Sandbox, obwohl der Player erst in P1 entsteht.
  - **Input:** Godot Input Actions; keine fest verdrahteten Tastencodes als Architekturprinzip; keine unnötige Input-Manager-/Event-Bus-Architektur.
  - Grenzen: vorläufige Testbelegung, keine Rebinding-Funktion und keine Regel für Inventar/Lesen (E06 bleibt offen).
- **Verantwortliche Rolle:** Claude Code / Opus 5.0.
- **Priorität:** Hoch.
- **Ziel:** Eine verlässliche Eingabe- und Pausenbasis für den anschließenden Player bereitstellen.
- **Sichtbares Ergebnis:** Sandboxstart, Pause, Fortsetzen und Menüwechsel liefern passenden Mausmodus/Fokus; die Input Map ist vorbereitet.
- **Voraussetzungen / Gates:** P0-02 praktisch geprüft; benötigter E03-Teil zu Pausenbelegung und Fokusverlust/-rückkehr vorläufig mit Project Lead/Autoren bestätigt.
- **Relevante Dokumentreferenzen:** GDD §§27–28; TDD §§5/5.1, 18, 26.2/AC-01/03/18; Architektur §§6, 8, 20, 25 „Main und Level“; Roadmap §5/P0, §6/E03/E20.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, `game/project.godot`, Main- und GameUI-Szene/Scripts, gemeinsamer Levelkoordinator und Sandbox aus P0-02; dessen Testbefund.
- **Erlaubte Dateien / Verzeichnisse:** `game/project.godot`, `game/app/main.gd`, `game/app/main.tscn`, `game/ui/game_ui.gd`, `game/ui/game_ui.tscn`, `game/levels/vertical_slice/vertical_slice.gd`, `game/tests/systems_sandbox.tscn`; D1/Metadaten.
- **Ausdrücklich verbotene Änderungen:** V1; kein InputManager, Controller-/Rebindingframework, Player-Motor oder Inventar-/Lesepausenregel. Keine neuen Systeme hinter vorbereiteten Action-Namen.
- **Konkrete Arbeit:** 1. Actions `move_forward`, `move_backward`, `move_left`, `move_right`, `jump`, `sprint`, `crouch`, `interact`, `flashlight`, `inventory`, `use_item`, `pause` vorbereiten. WASD entspricht dem Auftrag; weitere konkrete Belegungen nur aus bestätigtem Testprofil übernehmen, sonst ungebunden lassen. 2. Main als einzigen Besitzer der Weltpause verwenden; Main/UI bleiben bedienbar, WorldHost ausdrücklich pausierbar. 3. Minimales Pausepanel mit Fortsetzen/Rückkehr/Beenden ergänzen. 4. Mausfang, sinnvoller UI-Fokus, konsumierte UI-Eingaben und Aktionspuffer beim Phasenwechsel behandeln. 5. Bestätigte Fokusverlustregel anwenden; keine Kamera-/Gameplayaktion durch Wiederaufnahme-Klick.
- **Nicht-Ziele:** Auswertung aller vorbereiteten Gameplayactions, vollständige Einstellungen, Gameplay-Timerdienste oder neue UI-Ansichten.
- **Acceptance Criteria:** Aktives Spiel hat passenden Mausfang, Menü/Pause freien Zeiger und bedienbaren Fokus. Nur Main setzt die Pause. Pausierte Welt und aktive UI sind praktisch unterscheidbar; Fortsetzen kehrt konsistent zurück. Versteckte Panels fangen keine Eingaben ab. Fokuswechsel folgt dem bestätigten Profil; E06 zu Inventory/Lesen bleibt offen. Tests mit echtem Player sind explizit P1 zugeordnet. **Erfüllt (20.09.2026):** Mausfang in der aktiven Sandbox, freier Zeiger und bedienbarer Fokus in Menü/Pause, Pause allein durch Main (`SceneTree.paused` nur in PAUSED), praktisch unterscheidbare pausierte Welt bei aktiver UI, konsistentes Fortsetzen, keine Eingabeaufnahme durch versteckte Panels und Fokusverhalten gemäß E03a sind durch Fensterlauf-Test und manuellen Godot-Test belegt; E06 bleibt offen, Player-Tests bleiben P1 (siehe „Befund / Abnahme“).
- **Auszuführende Tests:** CLI-/Parserprüfung; Input Map gegen Actionliste prüfen; Start → Pause → Fortsetzen → Menü mehrfach testen, inklusive Tastaturbedienung, Fensterwechsel und Wechsel während gehaltener Tasten. Pausenwirkung mit vorhandenen Engine-Monitoren oder einer temporären lokalen Probe prüfen, danach Probe entfernen. Keine dauerhafte Testlogik nur für einen Zähler bauen.
- **Erforderlicher Godot-Test:** Editorlauf mit Maus-/Tastaturbedienung, Alt-Tab/Fokuswechsel, schneller Wiederholung und Fenstergrößenwechsel; UI-Reaktion während pausierter Welt belegen.
- **Windows-Exporttest:** Dieselben Fokus-/Pausenfälle in P0-04 im Standalone wiederholen.
- **Claude-Self-Review:** SR 1–9 vollständig; besonders Process Modes, Aktionsdurchreichung, Fokus und Trennung von Enginebereitschaft und Gameplayfreigabe prüfen.
- **Erwarteter Bericht:** Action-/Belegungsstand, E03-Teilfreigabe, Phasen-/Mausverhalten, praktische Befunde und noch nicht mögliche Player-Regressionen.
- **Git-/Commitregel:** G1; Bestandteil des gemeinsamen Bootstrap-Integrationspunkts.
- **Astra-Review:** Gate R0 in P0-05; spätere Playerintegration gemeinsam in R1.
- **Junior-Test:** Optional Menü/Pause ansehen; erster Bewegungstest erst P1-01.
- **Blocker / offene Entscheidung:** Fokus- und Testbelegungsregel vor dem betroffenen Verhalten klären. Keine stillschweigende Weltpause für künftige Inventory-/Storyansichten.
- **Befund / Abnahme (D1, 20.09.2026):**
  - **Stand:** Basis-Commit `47b5b40`; ungecommitteter Diff = geänderte Dateien `game/project.godot` (nur neuer Abschnitt `[input]`), `game/app/main.gd`, `game/ui/game_ui.gd`, `game/ui/game_ui.tscn`, `game/tests/systems_sandbox.tscn`. Keine neuen Dateien, keine Autoloads. Engine/Profil wie P0-02.
  - **Input Map:** `move_forward`/`move_backward`/`move_left`/`move_right` = W/S/A/D (physisch), `pause` = Escape; `jump`, `sprint`, `crouch`, `interact`, `flashlight`, `inventory`, `use_item` angelegt, aber ungebunden bis zum bestätigten E03-Bewegungsprofil. Main wertet nur `pause` aus.
  - **Aufbau:** Phase PAUSED ergänzt; Main setzt als Einziges `SceneTree.paused` (nur in PAUSED), sperrt/freigibt Gameplay über `set_gameplay_active` und verwirft beim Eintritt in PLAYING den Aktionspuffer. `pause` in `_unhandled_input` nach UI-Verarbeitung; im Menü ohne Wirkung. `Window.focus_exited` pausiert nur in PLAYING; `focus_entered` ist bewusst nicht verbunden. GameUI: Pausepanel (Fortsetzen/Zurück zum Menü/Beenden), Mausmodus VISIBLE in Menü/Pause/Übergang und CAPTURED in der aktiven Welt, Fokus auf „Fortsetzen“, Pausehinweis aus der Input Map; HUD-Menübutton entfällt. Sandbox: rotierender Marker (AnimationPlayer, kein Script) als sichtbares Pausenmittel.
  - **CLI-/Laufzeittests (Claude, bestanden):** `--check-only`, `--headless --import` fehlerfrei; temporärer Laufzeittest außerhalb des Repos mit 130 Prüfungen im Fensterlauf 130/130 bestanden (Input Map, 5× Escape-Pause/Fortsetzen, Probe: Welt-`_process` steht in der Pause, UI verarbeitet weiter, gehaltene Taste über Pause/Fortsetzen verworfen, synthetischer Fokusverlust → PAUSED, Fokusrückkehr bleibt PAUSED, Rückkehr ins Menü aus Pause, Escape/Fokusverlust im Menü wirkungslos, zweiter Zyklus); headless nur die 6 Mausmodus-Prüfungen nicht aussagekräftig. Editorstart fehlerfrei.
  - **Manueller Godot-Runtime-Test (Project Lead, 20.09.2026, bestanden):** Hauptmenü Maus sichtbar und frei; Sandbox Maus gefangen; Escape pausiert zuverlässig; Pause stoppt den sichtbaren Sandbox-Marker; Fortsetzen aktiviert Gameplay wieder; mehrfaches Pause/Fortsetzen funktioniert; Alt+Tab/Fokusverlust pausiert; Fokusrückkehr setzt nicht automatisch fort; bewusstes Fortsetzen funktioniert; Rückkehr zum Hauptmenü funktioniert; keine sichtbaren Runtime-/Debuggerfehler. Ergebnis: bestanden.
  - **Nicht ausgeführt / noch nicht anwendbar:** Standalone-Wiederholung der Pause-/Fokusfälle und Release-Sperre des Sandboxzugangs (P0-04); Mausblick/„erster Mausimpuls nach Fortsetzen“ und Player-Regressionen (P1-01); Inventar-/Lesepause (E06 offen).
  - Kein Commit; Bündelung mit P0-04 zum Bootstrap-Integrationsstand gemäß G1.

### P0-04 – Windows-Testexport und Debug-/Release-Grenze

- **Task-ID:** P0-04.
- **Titel:** Reproduzierbaren Windows-x86-64-Export praktisch nachweisen.
- **Phase:** P0 – Projektbasis und technische Verifikation.
- **Milestone:** M0 – Projekt läuft; Zulauf R0.
- **Status:** ACCEPTED – 20.09.2026, nach manuellem Standalone-Test beider Builds durch den Project Lead angenommen; Befund siehe „Befund / Abnahme“ unten. M0 bleibt bis R0 (P0-05) offen.
- **Verantwortliche Rolle:** Claude Code / Opus 5.0; praktische Bedienprüfung in Godot/Windows, bei Bedarf durch den User.
- **Priorität:** Hoch.
- **Ziel:** Editorfunktion und eigenständigen Build abgleichen; Entwicklungszugang und Releasegrenze früh beweisen.
- **Sichtbares Ergebnis:** Startbarer Windows-Debugexport mit Sandbox und startbare Release-Grundhülle mit gesperrtem Testzugang; genaue Reproduktionsschritte.
- **Voraussetzungen / Gates:** P0-01 bis P0-03 geprüft; E01 einschließlich passender Templates belegt, E02a unverändert dokumentiert. Falls Templates inzwischen fehlen/abweichen, E01 wieder öffnen und P0-01 gezielt fortsetzen.
- **Relevante Dokumentreferenzen:** ADR-007/008; TDD §§3, 23, 25, 26.2/AC-22–24; Architektur §§28–31; Roadmap §5/P0, §6/E02a/E02b/E18/E21, §10.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, `.gitignore`, `game/project.godot`, Main/UI/Levelkoordinator/Sandbox, vorhandene `game/export_presets.cfg` falls vorhanden; P0-01-Geräte-/Templatebefund und P0-03-Tests.
- **Erlaubte Dateien / Verzeichnisse:** `game/export_presets.cfg`, erforderliche Export-/Debuggrenzen in `game/project.godot`, `game/app/main.gd`, `game/ui/game_ui.gd`, `game/ui/game_ui.tscn`; konkrete Ausgaben unter `exports/p0/` unversioniert; D1/Metadaten. Nur exportbezogene Fehlerkorrekturen an diesen Dateien; sonst Befund an den zuständigen Vorgängertask.
- **Ausdrücklich verbotene Änderungen:** V1; keine Exportbinaries/Caches/privaten Exportdaten im Commit, kein Installer, Signing, Upload oder anderes Exportziel. Keine Releasefreigabe des Sandboxpfads als Behelf und keine vorgezogene Produktlevelszene.
- **Konkrete Arbeit:** 1. Minimalen Windows-x86-64-Preset mit passenden Templates konfigurieren. 2. Debug- und Releaseexport getrennt erzeugen und kennzeichnen. 3. Debug-Sandboxzugang im Entwicklungsmodus erlauben; im Release tatsächlich sperren, nicht nur Button verstecken. Da P0 noch keinen Produktlevel enthält, zeigt Release eine ehrliche bedienbare Grundhülle ohne behauptetes spielbares „Neues Spiel“. 4. Ohne Editor als normaler Benutzer starten, Ressourcen-/Pfadfehler und Eingabewechsel prüfen. 5. Testdatenpfad `user://tests/` als getrennte Konvention festhalten; keine Saveimplementierung zur Demonstration bauen. 6. Messprotokoll für identische Testansicht vorbereiten: Gerät, Renderer, Auflösung, Erst-/Wiederholungslauf, Editor plus Spiel versus Standalone, Framezeiten/RAM/VRAM soweit messbar. Kleine Basisbefunde sammeln, keine repräsentative Grafikeignung behaupten.
- **Nicht-Ziele:** E02b schließen, alle Renderer optimieren, reguläre Grafikbudgets, Installation/Releaseabnahme oder Speichern/Laden testen.
- **Acceptance Criteria:** Debugexport startet und durchläuft Menü/Sandbox/Pause/Fortsetzen/Beenden ohne Editor und fehlende Ressourcen. Release startet und beendet sich korrekt; Sandbox/Testpfade sind nicht aktivierbar. Keine absoluten Entwicklungspfade erforderlich. Exportweg und tatsächliches Test-OS sind reproduzierbar dokumentiert. E02b-Vergleich ist vorbereitet, aber offen. Testdaten können keinen regulären Fortschritt überschreiben; aktuell gibt es noch keine Saves. **Erfüllt (20.09.2026):** Debugexport durchläuft Menü/Sandbox/Pause/Fortsetzen/Beenden ohne Editor und ohne fehlende Ressourcen; Release startet und beendet sich korrekt, Sandbox/Testpfade sind nicht aktivierbar und nicht ausgeliefert; keine absoluten Entwicklungspfade; Exportweg und Test-OS reproduzierbar dokumentiert; E02b bleibt offen, Messbasis vorbereitet; noch keine Saves (siehe „Befund / Abnahme“).
- **Auszuführende Tests:** CLI-/Importprüfung, beide Exportvarianten mit Ergebnis/Fehlerausgabe prüfen, Paketinhalt und Gitstatus kontrollieren; Start/Beenden mehrfach, Fokuswechsel, Pause und Sandbox-Neuaufbau im Debugbuild. Release-Testzugang einschließlich vorhandener Startparameter ablehnen lassen. Vergleichbare Basis-Messläufe dokumentieren.
- **Erforderlicher Godot-Test:** Abschließender Editor-Smoke-Test des tatsächlich exportierten Stands, keine ungetesteten Korrekturen zwischen Befund und Übergabe.
- **Windows-Exporttest:** Ja, verpflichtend: Debug und Release auf dem erfassten Windows-x86-64-System ohne Editor, als normaler Benutzer. Nicht ausführbare UI-/Exporttests verhindern den vollständigen M0-Nachweis.
- **Claude-Self-Review:** SR 1–9 vollständig; Exportressourcen, tatsächliche Debugsperre, Pfade, Templates und unbeabsichtigte generierte Dateien prüfen; behobene Fehler neu exportieren/nachtesten.
- **Erwarteter Bericht:** Buildbezug, Engine-/Templatepfad, Preset und genaue Export-/Startbefehle, Ausgabepfade, OS/Profil, Testmatrix Debug/Release, Messbasis und fehlende Nachweise. Paketartefakte sind interne Testausgaben.
- **Git-/Commitregel:** G1; nach erfolgreicher Prüfung Bootstrap-Integrationspunkt mit vorgesehenem Titel, nur bei ausdrücklicher Commitfreigabe. Unversionierte Exporte nicht aufnehmen.
- **Astra-Review:** Gate R0 unmittelbar anschließend in P0-05; gesamten kleinen P0-Stand übergeben.
- **Junior-Test:** Optional Start/Beenden zeigen; kein J1 erforderlich.
- **Blocker / offene Entscheidung:** Export-/Template-/Hardwarefehler verhindern Übergabe als vollständig geprüft. Finale Plattform-/Installationsbedingungen E21 bleiben offen.
- **Befund / Abnahme (D1, 20.09.2026):**
  - **Stand:** Basis-Commit `41ad13a`; ungecommitteter Diff = neu `game/export_presets.cfg`, geändert `game/app/main.gd` (+5 Zeilen: `print_verbose` der Phasenwechsel für den Standalone-Nachweis, Kommentar zu Release-Grenze und Testdatenkonvention `user://tests/`). Keine Binärartefakte im Repository; `exports/` und `game/.godot/` ignoriert. Keine `export_credentials.cfg`.
  - **Export:** Presets „Windows x86-64 Debug“ (alle Ressourcen, Konsolen-Wrapper) und „Windows x86-64 Release“ (`exclude_filter="tests/*"`, ohne Konsole); x86_64, PCK getrennt, keine Signierung, `modify_resources=false`, kein ANGLE/D3D12. Befehle aus `game/`: `--headless --export-debug "Windows x86-64 Debug" <pfad>` bzw. `--headless --export-release "Windows x86-64 Release" <pfad>`; beide Exit 0 ohne Fehler. Ausgaben unversioniert unter `exports/p0/debug/` (`dark_rooms_debug.exe`, `.console.exe`, `.pck`) und `exports/p0/release/` (`dark_rooms.exe`, `.pck`).
  - **Templates:** `%APPDATA%\Godot\export_templates\4.7.2.stable\`; exportierte EXEs per SHA256 byteidentisch mit `windows_debug_x86_64.exe`, `windows_debug_x86_64_console.exe`, `windows_release_x86_64.exe`; `--version` beider Builds = `4.7.2.stable.official.ed1daf0bf`; keine Diskrepanzmeldung.
  - **Debug-/Release-Grenze:** Sandboxzugang über `OS.is_debug_build()` (Button nur im Debug, Main lehnt sonst ab) und zusätzlich Ausschluss von `tests/*` im Release-Paket (PCK-Prüfung: keine `tests/`-Ressource). Kein Startparameter oder anderer Pfad aktiviert die Sandbox im Release.
  - **Automatisierter Standalone-Test (Claude, 20.09.2026, bestanden):** ohne Editor, als normaler Benutzer ohne Adminrechte, Tastatureingaben per Betriebssystem, echtes zweites Fenster für Fokusverlust, Nachweis über `--verbose`-Phasenlog und Cursor-Clip. Debug: MENU → Sandbox PLAYING (Cursor gefangen) → Escape PAUSED/Fortsetzen mehrfach → Fokusverlust PAUSED → Fokusrückkehr ohne Änderung → bewusstes Fortsetzen → Menü → zweiter Zyklus → Beenden; 0 Fehler; Vulkan 1.4 Forward Mobile. Release: Menü nur mit „Beenden“, Escape wirkungslos, sauberes Beenden, 0 Fehler. Abschließender Editor-Smoke-Test des exportierten Stands: P0-03-Test 130/130.
  - **Manueller Standalone-Test (Project Lead, 20.09.2026, bestanden):** Debug-Build per Doppelklick ohne Editor: Hauptmenü, Sandbox erreichbar, Pause per Escape, Fortsetzen, Alt+Tab/Fokusverlust pausiert, Fokusrückkehr setzt nicht automatisch fort, bewusstes Fortsetzen, Rückkehr zum Menü, Fensteränderungen ohne sichtbare UI-Probleme, Beenden, keine sichtbaren Runtimefehler. Release-Build per Doppelklick: Sandbox nicht angeboten, Entwicklungsbereich nicht zugänglich, Escape im Menü ohne ungewollte Aktion, sauberes Beenden, kein Konsolenfenster, keine sichtbaren Runtimefehler.
  - **Messbasis (vorbereitet, keine Eignungsaussage):** Windows 11 Home 25H2 Build 26200.9457, Samsung 750QGK, Intel Core 7 150U/Intel-iGPU, Vulkan Mobile, Fenster 1920×1080 (Panel 1080p/125 %), VSync an: `--print-fps` 57–61 (Ø 59,9) in Menü und Sandbox; Working Set Debug 358–402 MB Menü, 494 MB Sandbox; Release 359 MB Menü. Nicht gemessen: Erst-/Wiederholungslauf getrennt, VRAM, Editor plus Spiel. `user://` (`%APPDATA%\Godot\app_userdata\Dark Rooms\`) ohne Adminrechte beschreibbar; Testdatenkonvention `user://tests/` festgehalten, keine Saves.
  - Nebenbefund (kein Projektfehler): synthetische Tastatureingaben ohne Hardware-Scancode lösen die auf die physische Escape-Taste gebundene Action `pause` nicht aus.
  - Kein Commit; Bootstrap-Integrationscommit gemäß G1 nur nach ausdrücklicher Freigabe, empfohlen vor R0, damit Astra eine feste Commit-ID prüft.

### P0-05 – R0: Projektbasis prüfen

- **Task-ID:** P0-05.
- **Titel:** Kleiner gebündelter Senior-Review R0 – Projektbasis.
- **Phase:** P0 – Projektbasis und technische Verifikation.
- **Milestone:** M0 – Projekt läuft; Abschlussgate R0.
- **Status:** ACCEPTED – 20.09.2026; R0 durch Codex / Astra High durchgeführt, vom Project Lead geprüft und akzeptiert; **M0 – Projekt läuft: ACCEPTED**. Befund siehe „Befund / Abnahme (R0)“ unten.
- **Verantwortliche Rolle:** Codex / Astra High prüft; Project Lead entscheidet über M0-Abnahme. Normale Korrekturen werden Claude eindeutig zugewiesen.
- **Priorität:** Hoch; vor P1-Freigabe.
- **Ziel:** Den getesteten Bootstrap auf tragfähige minimale Zuständigkeiten und belegten Start/Export prüfen.
- **Sichtbares Ergebnis:** Enger Reviewbericht mit blockierenden Befunden, begrenzten Nachtests oder M0-Abnahmeempfehlung.
- **Voraussetzungen / Gates:** P0-01–04 samt Claude-Self-Reviews und praktischen Editor-/Exportbefunden; E01/E02a belegt, eindeutig fixierter Übergabestand. Keine konkurrierende Umsetzung während des Reviews.
- **Relevante Dokumentreferenzen:** ADR-003/007/008; TDD §§5.1, 26.2/AC-01/03/23/24 nur im vorhandenen Umfang; Architektur §§5–6, 8, 20–21, 29–32; Roadmap §5/P0 und §9/R0.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, P0-01–04-Berichte; deren vollständiger abgegrenzter Diff, neue Dateien, Projekt-/Exportkonfiguration, Main/UI, Levelkoordinator und Sandbox. Keine späteren Systeme vollständig nachlesen.
- **Erlaubte Dateien / Verzeichnisse:** Code und Konfiguration nur lesend; Reviewbericht und D1. Korrekturen erst in gesondertem, eng begrenztem Auftrag.
- **Ausdrücklich verbotene Änderungen:** V1; kein stilgetriebener Neubau, keine zusätzliche Architektur, keine direkte parallele Erstimplementierung.
- **Konkrete Arbeit:** Engine-/Hardware-/Templatebelege und E02a-Grenze prüfen; Runtime-/Quellassettrennung, Main ohne Autoloads, eine Welt/eine Sandbox, UI-/Fokuszuständigkeit, getesteten Exportweg und Release-Testpfadsperre beurteilen. Befunde nach Relevanz mit Dateibezug und Reproduktion erfassen. Nach Korrekturen nur betroffene Befunde/Regressionen nachprüfen; keine neuen regulären Mini-Reviewgates eröffnen.
- **Nicht-Ziele:** Playerreview, Save-/KI-Architektur neu ausarbeiten, finalen Renderer wählen oder vollständigen Release zertifizieren.
- **Acceptance Criteria:** R0 hat ein klares Urteil und belastbare Testreferenzen. Keine offenen blockierenden Basisfehler; nötige Korrekturen und Nachtests sind erledigt. M0 wird erst durch den Project Lead angenommen, nicht durch vorhandene Dateien oder den Commitnamen.
- **Auszuführende Tests:** Diff-/Scope-/Konfigurationsprüfung und Befundabgleich; bei konkretem Verdacht gezielten vorhandenen Test wiederholen. Keine vollständige Testduplizierung ohne Anlass.
- **Erforderlicher Godot-Test:** P0-02–04-Nachweise müssen vorliegen. Änderung aufgrund des Reviews verlangt erneuten betroffenen Editor-/Runtime-Test.
- **Windows-Exporttest:** P0-04-Debug-/Releasebefunde erforderlich; nach export-/startrelevanter Korrektur neu bauen und nachtesten.
- **Claude-Self-Review:** SR-Nachweise aus P0-01–04 sind Eingabe. Jeder spätere Claude-Korrekturauftrag durchläuft erneut SR 1–9; Astra ersetzt ihn nicht.
- **Erwarteter Bericht:** R0, geprüfter Stand, Fokus, Befunde mit Schwere/Reproduktion, vorhandene/fehlende Nachweise, Korrekturzuständigkeit und Empfehlung zur M0-Abnahme.
- **Git-/Commitregel:** G1; Review ist kein Commitauftrag. Ein vorhandener Übergabecommit ist noch keine M0-Freigabe.
- **Astra-Review:** Ja – **R0 selbst**, einmal gebündelt für P0-01 bis P0-04 am Ende P0.
- **Junior-Test:** Nein als Pflicht; M0 benötigt noch keine spielerische Abnahme.
- **Blocker / offene Entscheidung:** Fehlender Runtime-/Exportnachweis oder blockierender R0-Befund hält M0 offen; E03-Bewegungsprofil wird erst für P1 benötigt.
- **Befund / Abnahme (R0, D1, 20.09.2026):**
  - **Geprüfter Stand:** P0-01 bis P0-04 (ACCEPTED) auf Basis der Commits bis `5f6e3d7` „Add Windows export configuration“; Reviewer Codex / Astra High; Entscheidung Project Lead.
  - **Urteil:** keine BLOCKER. Keine Architekturänderung notwendig: Main bleibt Lifecycle-Besitzer, UI bleibt Darstellung, keine Autoloads, kein globaler Event Bus, keine zusätzlichen Manager, keine vorgezogenen P1-Systeme.
  - **IMPORTANT 1 – geschütztes Resume nach Pause / keine unerwünschte Ereigniszustellung:** `Input.flush_buffered_events()` stellt gepufferte Ereignisse zu, statt sie zu löschen; während dieser synchronen Zustellung durften weder die Pause-Action noch alte UI-Buttons einen weiteren Übergang auslösen. Behoben durch Astra: `_activate_gameplay()` durchläuft vor der Freigabe kurz PREPARING (Übergangsansicht), verwirft dann den Aktionspuffer und gibt die Welt erst danach frei (`game/app/main.gd`).
  - **IMPORTANT 2 – Fokusverlust während PREPARING/Weltwechsel:** Ein Fokusverlust während des Weltaufbaus ging verloren und die Welt startete unpausiert. Behoben durch Astra: `_pause_on_activation` wird bei Fokusverlust in PREPARING gesetzt, bei jedem Übergangsbeginn zurückgesetzt und beim Aktivieren als PAUSED mit Pausepanel angewendet (`game/app/main.gd`).
  - **Bestandene Reviewtests:** Lifecycle 122/122; Input/Pause 130/130; neue Regressionstests `game/tests/p0_lifecycle_regression.gd` 55/55 headless, 63/63 Windows/Vulkan, 55/55 aus dem Debug-Paket; Parser/Import fehlerfrei; Debug- und Release-Export erfolgreich; Testressourcen weiterhin aus dem Release ausgeschlossen.
  - **Übergabestand nach Review:** Basis `5f6e3d7` plus Astras Korrekturdiff (`game/app/main.gd`, neu `game/tests/p0_lifecycle_regression.gd` samt `.uid`), zum Zeitpunkt dieser Befundpflege ungecommittet; Commit nur nach ausdrücklicher Freigabe (G1).
  - **M0 – Projekt läuft: ACCEPTED (20.09.2026, Project Lead).** P0 ist damit abgeschlossen. P1 bleibt gegatet, bis das vorläufige E03-Bewegungsprofil freigegeben ist (siehe §3 „E03, Bewegung“ und P1-01).

**M0 – Projekt läuft: ACCEPTED (20.09.2026, nach R0).** P0-01 bis P0-05 sind angenommen; P0 ist abgeschlossen. Spätere Nachprüfungen gemäß §6.

## 5. P1 – First-Person-Spielgefühl

### P1-01 – Früher spielbarer First-Person-Kern

- **Task-ID:** P1-01.
- **Titel:** Player-Grundszene, Mausblick und Grundbewegung mit Sprung.
- **Phase:** P1 – First-Person-Spielgefühl.
- **Milestone:** M1 – Bewegung macht den Raum spielbar; Zulauf R1.
- **Status:** ACCEPTED – 20.09.2026, nach praktischem Test durch Project Lead und informellem Junior-Playtest angenommen; Befund siehe „Befund / Abnahme“ unten. M1 bleibt bis J1/R1 offen.
- **E03-Beleg (Project Lead, 20.09.2026, vorläufiges Prototyp-Profil):**
  - **Perspektive/Kamera:** First Person; FOV 75°; keine Kameraneigung; kein Head Bob.
  - **Körper:** Spielerhöhe ca. 1,80 m; Augenhöhe ca. 1,65 m; Capsule-Collision.
  - **Bewegung:** Gehgeschwindigkeit 5,0 m/s; Sprintgeschwindigkeit 8,0 m/s (erst P1-02); Bodenbeschleunigung 20 m/s²; Bodenabbremsung 24 m/s²; reduzierte Luftsteuerung; keine Ausdauer.
  - **Sprung/Schwerkraft:** Schwerkraft ca. 9,8 m/s² als Ausgangswert; angestrebte Sprunghöhe ca. 1,25 m.
  - **Eingabe:** Maus-Sensitivität als gut änderbarer Tuningwert; Bewegung WASD (P0-03), `pause` Escape (E03a).
  - **Grenze:** Alle Werte sind ausdrücklich vorläufig und werden nach dem ersten Junior-Playtest angepasst; keine finalen Raum-/Fluchtmaße. Noch nicht festgelegt und beim konkreten P1-01-Auftrag mitzugeben oder dort als sichtbar vorläufige Tuningwerte auszuweisen: Belegung von `jump` (GDD-Vorschlag Leertaste), Blickgrenzen (Neigung), maximale Steigung/Stufenhöhe, Startwert der Sensitivität. Sprint-/Duckkombinationen folgen vor P1-02, Traversalgrenzen vor P1-03.
- **Verantwortliche Rolle:** Claude Code / Opus 5.0; Junior/Autoren für frühe freiwillige Rückmeldung.
- **Priorität:** Hoch; frühestes spielbares Ergebnis.
- **Ziel:** Junior kann selbst schauen, laufen, an Geometrie kollidieren und springen.
- **Sichtbares Ergebnis:** Ein echter First-Person-Player bewegt sich auf einer kleinen sicheren Teststrecke in derselben Sandbox.
- **Voraussetzungen / Gates:** M0 einschließlich R0 angenommen; E03-Grundprofil ausdrücklich vorläufig freigegeben: Kamera-/Körpermaße, Blicksteuerung, Bewegungs-/Sprung-/Steigungsgrenzen und erforderliche Belegung. Empfehlungen des GDD sind keine automatische Zahlenfreigabe.
- **Relevante Dokumentreferenzen:** GDD §§14, 28, 34; ADR-001; TDD §§6, 21, 26.2/AC-02/03; Architektur §§7 „Motor und Kamera“, 8, 23, 25 „Player und Creature“, 29; Roadmap §5/P1 und §6/E03.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, `game/project.godot`, Main/UI und gemeinsamer Levelkoordinator, `game/tests/systems_sandbox.tscn`, P0-03-Fokusbefund, R0-Bericht und E03-Freigabe.
- **Erlaubte Dateien / Verzeichnisse:** `game/player/player.tscn`, `game/player/player.gd`, `game/player/player_tuning.gd`, `game/data/player_tuning.tres`, `game/tests/systems_sandbox.tscn`, `game/levels/vertical_slice/vertical_slice.gd`, `game/project.godot`; `game/app/main.gd` und `game/ui/game_ui.gd` nur für Player-Aktivierung/Fokusbindung; `game/debug/debug_overlay.gd`/`.tscn` bei Bedarf für eine kleine reine Zustandsanzeige; D1/Metadaten.
- **Ausdrücklich verbotene Änderungen:** V1; kein Sprint, Crouch oder Traversal in diesem ersten Paket, kein Interactor/Licht/Inventory trotz vollständigem Architektur-Nodebaum. Kein zweiter Motor, keine Root-Animation, keine ungefragten Kameraeffekte, Coyote-Time oder Jump-Buffer-Mechanik.
- **Konkrete Arbeit:** 1. `CharacterBody3D` mit instanzlokaler `CollisionShape3D`/Kapsel, Head und Camera3D erstellen. 2. Körper horizontal, Head vertikal drehen; Empfindlichkeit und Blickgrenzen aus Testprofil, Mausdelta nicht versehentlich mit Bildrate skalieren. 3. WASD im Physiktakt, Diagonalnormalisierung, bestätigte Beschleunigung/Abbremsung, Gravity, Bodenkontakt, Sprung und Landung im einzigen Player-Motor umsetzen. 4. Player in Sandbox instanziieren und P0-Testkamera deaktivieren/entfernen; genau eine aktive Spielkamera. 5. Sicheren Boden, Ecken, Wand und einfaches Sprunghindernis als Testweg ergänzen. 6. Aktivierung, Pause/Fortsetzen, neuen Sandboxlauf und Kamerahistorie prüfen; dann sofort den informellen Junior-Test anbieten.
- **Nicht-Ziele:** Ganze P1-Phase, endgültiges Movement-Tuning, Health/Fallschaden, Bodyvisuals, Horror, Audioabnahme oder formales J1.
- **Acceptance Criteria:** Mausblick, WASD, Kollision und Jump funktionieren zusammen ohne Entwicklerbewegung. Diagonale Bewegung ist nicht schneller; Wände/Ecken und Landungen sind reproduzierbar. Beim Spawnen/neuen Lauf keine alten Geschwindigkeiten/Eingaben/Kamerahistorien. Pause/Fokus stoppen Bewegung und Blick gemäß Profil, kein aufgestauter Sprung durch Fortsetzen. Testwerte sind sichtbar als vorläufige Konfiguration abgelegt.
- **Auszuführende Tests:** CLI-/Parserprüfung; geraden und diagonalen Weg bei gleicher Dauer vergleichen; Anlaufen/Bremsen, Wandkontakt, Ecken, Sprung/Landung und Blick bei unterschiedlichen Bildraten prüfen. Pause und Fokusverlust auch mit gehaltenen Tasten/in der Luft, wiederholter Sandbox-Neulauf. Keine bestandenen Restorefälle behaupten.
- **Erforderlicher Godot-Test:** Vollständige Grundstrecke im Editor selbst durchspielen, Kamera und Kollision praktisch kontrollieren; kurze sichere Junior-Probe direkt danach ermöglichen und Aussagen/Fehler festhalten.
- **Windows-Exporttest:** Kein eigener verpflichtender Zwischenexport; falls Junior den Standalone nutzt, aktualisierten Debugexport mit demselben Stand testen. Verbindliche integrierte Wiederholung in P1-05.
- **Claude-Self-Review:** SR 1–9 vollständig; besonders nur ein Positionsschreiber, Physik-/Mausdelta, normalisierte Eingabe, echte Kollision und keine Vorabdateien späterer Systeme.
- **Erwarteter Bericht:** Steuerung/Testprofil, Startweg, bestandene Grundfälle, Grenzen und informelles Junior-Feedback oder Hinweis, dass die Probe noch nicht stattfand. Kleinster reproduzierbarer Ablauf für jeden Fehler.
- **Git-/Commitregel:** G1; stabiler Zwischenstand darf für spätere P1-Bündelung ungecommittet bleiben.
- **Astra-Review:** Gate R1 in P1-06; kein separater Mouse-Look-/Jump-Review.
- **Junior-Test:** Ja, früh informell nach funktionierendem Mausblick + WASD + Kollision + Jump; vor P1-02/03 anbieten. Formales J1 erst P1-05.
- **Blocker / offene Entscheidung:** E03-Grundprofil; ungewöhnliche Kollisions-/Kameraprobleme zuerst Claude-Diagnose, Astra nur bei schwierigem Problem nach Leadentscheidung. Feedback erlaubt keine stillen Regeländerungen.
- **Befund / Abnahme (D1, 20.09.2026):**
  - **Stand:** Basis-Commit `823e750`; ungecommitteter Diff = neu `game/player/player.gd` (+`.uid`), `game/player/player.tscn`, `game/player/player_tuning.gd` (+`.uid`), `game/data/player_tuning.tres`; geändert `game/levels/vertical_slice/vertical_slice.gd` (optionaler Teilnehmer `player`, Freigabe-Weiterreichung), `game/tests/systems_sandbox.tscn` (Player statt Testkamera, Wände, Platform 0,5 m, Block 1,5 m), `game/project.godot` (nur `jump` → Leertaste). `main.gd`/`game_ui.*` unverändert. Kein Commit; Bündelung nach G1 in P1.
  - **Aufbau:** Player (`CharacterBody3D`, `player.gd`) → BodyShape (instanzlokale Kapsel r 0,35 / h 1,80) und Head (1,65 m) → Camera3D (FOV 75). `player.gd` ist einziger Positionsschreiber; Bewegung im Physiktakt über `move_and_slide()`, Diagonalnormalisierung über `Input.get_vector`, Beschleunigen/Bremsen/Luftsteuerung/Gravity/Sprung aus `PlayerTuning`; Mausblick pro Pixel ohne Bildratenfaktor, Pitch-Clamp ±85°, Sperrfenster von 2 Frames nach jeder Freigabe gegen Kamerasprünge. Weltkamera = Player-Kamera; genau eine aktive Kamera. Freigabe ausschließlich über Level `set_gameplay_active`.
  - **Automatisierte Tests (Claude, bestanden):** Parser/Import fehlerfrei; temporärer P1-01-Laufzeittest außerhalb des Repos 64/64 headless und 64/64 im Fensterlauf (Instanz/Kamera/Maße, 5,0 m/s ohne Drift, 20/24 m/s² exakt, diagonal 5,0 m/s, Sprung 4,95 m/s → 1,29 m, kein Luftsprung, Landung, Wand, Yaw/Pitch-Clamp, Pause ohne Bewegung/Blick, kein Nachlauf und kein Mausimpuls nach Fortsetzen, Fokusverlust in der Luft, Weltwechsel ohne alte Referenzen/Historie); R0-Regression 55/55 headless, 63/63 Windows/Vulkan; Debug-/Release-Export erfolgreich, Release weiterhin ohne `tests/`. Hinweis: Der ältere P0-03-Testlauf zeigt 129/130, weil seine Erwartung „`jump` ungebunden“ seit P1-01 absichtlich veraltet ist (`jump` ist jetzt korrekt auf Leertaste gebunden) – keine Regression.
  - **Manueller Test (Project Lead) und informeller Junior-Playtest (20.09.2026, bestanden):** WASD funktioniert und gefällt Junior; Mouse Look funktioniert und fühlt sich gut an; Maus-Sensitivität, Gehgeschwindigkeit und Sprunghöhe werden zunächst beibehalten; Anlaufen/Stoppen ausreichend gut; Kamera/FOV für den Prototyp passend; keine störenden Kollisions- oder Hängenbleibprobleme; Pause/Fokus/Resume funktionieren weiterhin.
  - **Baseline:** Die Werte in `game/data/player_tuning.tres` (FOV 75°, Höhe 1,80 m / Augen 1,65 m / Radius 0,35 m, Gehen 5,0 m/s, 20 m/s² / 24 m/s², Luftsteuerung 0,3, Gravity 9,8 m/s², Sprunghöhe 1,25 m, 0,10 °/px, Pitch ±85°) gelten als erste spielerisch bestätigte Baseline; keine Tuningänderung erforderlich. Sie bleiben ausdrücklich spätere Tuningwerte; Änderungen nur über ausdrücklichen Auftrag.
  - **Noch nicht anwendbar:** Restore-/Traversal-/Duckfälle (P1-02/03, P5); Bildratenvergleich nur konstruktiv (Blick pro Pixel, Bewegung im Physiktakt).

### P1-02 – Sprint und sicheres Ducken

- **Task-ID:** P1-02.
- **Titel:** Sprinten und Crouch mit sicherem Aufstehen ergänzen.
- **Phase:** P1 – First-Person-Spielgefühl.
- **Milestone:** M1 – Bewegung macht den Raum spielbar; Zulauf R1.
- **Status:** ACCEPTED – 20.09.2026, nach praktischem Test durch Project Lead und informellem Junior-Playtest angenommen; Befund siehe „Befund / Abnahme“ unten. M1 bleibt bis J1/R1 offen.
- **E03-Nachtrag (Project Lead, 20.09.2026, vorläufiges Sprint-/Crouch-Profil):**
  - **Sprint:** linke Shift-Taste halten; Sprintgeschwindigkeit 8,0 m/s; keine Ausdauer; Sprint während Ducken nicht möglich; normales Springen aus dem Sprint erlaubt, vorhandener horizontaler Impuls darf beim Sprung erhalten bleiben; keine zusätzlichen Sprintmechaniken.
  - **Crouch:** linke Strg-Taste halten; geduckte Geschwindigkeit 2,5 m/s; Körperhöhe stehend ca. 1,80 m / geduckt ca. 1,20 m; Augenhöhe stehend ca. 1,65 m / geduckt ca. 1,05 m; Übergang Stehen/Ducken kurz und weich; Loslassen von Strg versucht aufzustehen; Aufstehen nur bei ausreichend freiem Raum über dem Spieler, bei blockierter Decke bleibt er geduckt; kein Crouch-Jump, kein Slide, kein Prone.
  - **Input:** `sprint` → linke Shift-Taste, `crouch` → linke Strg-Taste (physische Tasten; Belegung bisher ungebunden, wird in P1-02 gesetzt).
  - **Grenze:** Alle Werte bleiben vorläufige Tuningwerte und dürfen nach Junior-Playtests verändert werden. Übergangsdauer, Kollisionsradius und Prüfabstand beim Aufstehen sind nicht beziffert und werden in P1-02 als sichtbar vorläufige Tuningwerte ausgewiesen.
- **Verantwortliche Rolle:** Claude Code / Opus 5.0.
- **Priorität:** Hoch.
- **Ziel:** Die zwei zusätzlichen Bewegungsarten innerhalb des vorhandenen Motors verlässlich nutzbar machen.
- **Sichtbares Ergebnis:** Player sprintet und passiert geduckt eine niedrige Stelle; Aufstehen unter blockierter Decke wird sicher verweigert.
- **Voraussetzungen / Gates:** P1-01 praktisch geprüft. E03 um vorläufige Sprint-/Duckwerte, Körper-/Kamerahöhen, Halten/Umschalten und Kombinationen mit Sprung/Luft/Sprint ergänzen und bestätigen.
- **Relevante Dokumentreferenzen:** GDD §§14, 28; TDD §§6–7 nur Bewegungs-/Haltungsachsen, 26.2/AC-02/03/21; Architektur §§7 „Motor und Kamera“, 8, 23, 29; Roadmap §5/P1 und §6/E03.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, Player-Szene/Motor/Tuning aus P1-01, `game/project.godot`, Sandbox; Aktivierungs-/Pausevertrag in Main/Level/UI und bisherige Movement-Befunde.
- **Erlaubte Dateien / Verzeichnisse:** Player-Szene/Motor/Tuning und `game/data/player_tuning.tres`, `game/project.godot`, `game/tests/systems_sandbox.tscn`, vorhandene Movement-Debugansicht nur zur Ergänzung dieser Zustände; D1/Metadaten.
- **Ausdrücklich verbotene Änderungen:** V1; keine Ausdauer, kein Tempo-Item, Health oder zusätzlicher Crouch-/Sprint-Motor. Keine pauschale Laufzustandsänderung geteilter Resources.
- **Konkrete Arbeit:** Sprint aus bestätigter Absicht und Konfiguration berechnen. Haltung STANDING/CROUCHED getrennt von GROUNDED/AIRBORNE behandeln. Kollisionsform pro Instanz verändern, Head/Kamera mit sicheren Übergängen anpassen. Vor Aufstehen vollständigen Freiraum der stehenden Form prüfen. Sandbox um niedrige Decke und Übergang zur freien Höhe erweitern; bestehende Strecke erhalten.
- **Nicht-Ziele:** Finale Bewegungsbalance, Rutschen, Animationen, Kamerawackeln oder neue Fall-/Schadensregeln.
- **Acceptance Criteria:** Sprint bleibt im bestätigten Profil; Crouch verändert Kollision/Kamerahöhe konsistent. Unter Decke kein Aufstehen oder Kameradurchtritt; im freien Raum klappt Aufstehen. Haltungs- und Bewegungszustand widersprechen sich nicht. Zwei Instanzen können ihre Kollisionsformen unabhängig halten. Keine temporäre Modifikation der gemeinsamen Tuningdefinition.
- **Auszuführende Tests:** CLI-Prüfung; Laufen/Sprinten/Stoppen, diagonaler Sprint, Ducken im Freien/unter Decke/am Rand, wiederholtes erfolgloses Aufstehen und anschließender freier Übergang; bestätigte Sprung-/Sprint-/Duckkombinationen, Pause und Fokuswechsel prüfen. Instanzisolierung mit temporärer zweiter Testinstanz nachweisen und diese anschließend entfernen; normal genau ein Player.
- **Erforderlicher Godot-Test:** Niedrige Passage wiederholt in beiden Richtungen durchlaufen; Kollision und Kamera an Decke/Wand prüfen, P1-01-Grundstrecke regressionsprüfen.
- **Windows-Exporttest:** Im integrierten P1-05-Test erforderlich; Zwischenexport bei ausschließlich im Standalone auftretendem Befund.
- **Claude-Self-Review:** SR 1–9 vollständig; insbesondere vollständige Aufstehprüfung, instanzlokale Kollisionsform, getrennte Zustandsachsen und keine neuen Gameplayregeln.
- **Erwarteter Bericht:** E03-Ergänzung, getestete Kombinationen, Maße/Einheiten, sichere und blockierte Fälle sowie verbleibende Tuningfragen.
- **Git-/Commitregel:** G1; gemeinsam mit dem übrigen P1-Prototyp integrierbar.
- **Astra-Review:** Gate R1 in P1-06; kein einzelner Sprint-/Crouch-Review.
- **Junior-Test:** Optional kurze Zwischenprobe nach technischer Prüfung; formale Abnahme zusammen in J1.
- **Blocker / offene Entscheidung:** Sprint-/Duckbedienung und Kombinationen müssen vor Umsetzung bestätigt sein. Ausdauer und Fallfolgen bleiben außerhalb P1.
- **Befund / Abnahme (D1, 20.09.2026):**
  - **Stand:** Basis-Commit `7c56dda`; ungecommitteter Diff = geändert `game/player/player.gd`, `game/player/player_tuning.gd`, `game/data/player_tuning.tres`, `game/project.godot` (nur `sprint` → linke Shift, `crouch` → linke Strg, physisch), `game/tests/systems_sandbox.tscn` (niedriger Durchgang). `player.tscn`, `main.gd`, `game_ui.*`, `vertical_slice.gd` unverändert; keine neuen Dateien. Kein Commit; Bündelung nach G1 in P1.
  - **Aufbau:** Haltungsachse `Posture {STANDING, CROUCHED}` getrennt von der Fortbewegung (`is_on_floor()`), keine Zustandsmaschine. Sprint = Shift halten, 8,0 m/s, nur stehend, Sprung aus dem Sprint mit erhaltenem Horizontalimpuls (Luftsteuerung lenkt nur um, bremst nie). Crouch = Strg halten, 2,5 m/s, kein Sprung in der Hocke, Haltungswechsel nur am Boden. Kollision bleibt beim Ducken hoch, bis die Kamera in 0,15 s auf 1,05 m gesunken ist, dann instanzlokale Kapsel 1,20 m; beim Aufstehen Kapsel sofort 1,80 m nach positiver Freiraumprüfung, Kamera weich auf 1,65 m – Kamera liegt nie außerhalb der Kapsel. Aufstehprüfung über `PhysicsDirectSpaceState3D.intersect_shape` mit stehender Prüfkapsel (+0,05 m Rand, eigener Körper ausgeschlossen); unter blockierter Decke bleibt der Player geduckt und steht beim Verlassen automatisch auf.
  - **Automatisierte Tests (Claude, bestanden):** Parser/Import fehlerfrei; temporärer P1-02-Laufzeittest außerhalb des Repos 61/61 headless und 61/61 im Fensterlauf (Bindings, Sprint 8,00/Gehen 5,00/Crouch 2,50 m/s, Sprung aus Sprint mit 8,00 m/s in der Luft, Ducken/Aufstehen mit Kapsel-/Kamerahöhen, Sprint in Hocke gesperrt, kein Sprung in Hocke, niedriger Durchgang blockiert stehend/passierbar geduckt, `can_stand_up()` false unter Decke, automatisches Aufstehen beim Verlassen ohne Tunneling, Pause/Fokus mit gehaltenen Tasten ohne Nachlauf oder Kamera-/Body-Sprung, Instanzisolierung mit temporärer zweiter Instanz bei unveränderter Tuningdefinition, Weltwechsel spawnt stehend); P1-01-Test 62/64 – die zwei Abweichungen sind die seit P1-02 absichtlich überholten Erwartungen „`sprint`/`crouch` ungebunden“, keine Regression; R0-Regression 55/55 headless, 63/63 Windows/Vulkan; Debug-/Release-Export erfolgreich, Release ohne `tests/`.
  - **Manueller Test (Project Lead) und informeller Junior-Playtest (20.09.2026, bestanden):** normales Laufen weiterhin in Ordnung; Sprint mit linker Shift funktioniert und fühlt sich gut an, Tempo beibehalten; Springen aus Sprint funktioniert; Ducken mit linker Strg funktioniert und fühlt sich gut an, Tempo beibehalten; Kameraübergang angenehm; niedriger Durchgang funktioniert; Aufstehen unter blockierter Decke korrekt verhindert; nach Verlassen sauberes Aufstehen; Sprint und Crouch schließen sich aus; Pause/Fokus/Resume weiterhin in Ordnung; keine störenden Kollisionsprobleme.
  - **Baseline:** Sprint 8,0 m/s, Crouch 2,5 m/s, Körper 1,80 / 1,20 m, Augen 1,65 / 1,05 m sowie die von Claude gewählten `posture_transition_time = 0,15 s` und `stand_clearance_margin = 0,05 m` gelten als spielerisch getestete Baseline (vom Project Lead bestätigt); keine Tuningänderung erforderlich. Alle Werte bleiben spätere Tuningwerte; Änderungen nur per Auftrag.
  - **Grenzen:** Haltungswechsel nur am Boden (konservative Auslegung von „kein Crouch-Jump“); Geräusch-/Sichtbarkeitswirkung von Sprint/Ducken folgt in P1-04/P4; Restore-Fälle erst P5.

### P1-03 – Einfaches markerbasiertes Traversal

- **Task-ID:** P1-03.
- **Titel:** Eine ausdrücklich erlaubte Kletterpassage im Player-Motor prototypisieren.
- **Phase:** P1 – First-Person-Spielgefühl.
- **Milestone:** M1 – Bewegung macht den Raum spielbar; Zulauf R1.
- **Status:** ACCEPTED – 20.09.2026, nach praktischem Test durch Project Lead und informellem Junior-Playtest angenommen; Befund siehe „Befund / Abnahme“ unten. M1 bleibt bis J1/R1 offen.
- **E03-Nachtrag Traversal (Project Lead, 20.09.2026, vorläufiges Profil):**
  - **Umfang:** nur klar geeignete, niedrige Hindernisse; maximale Hindernishöhe zunächst ca. 0,9 m; Erkennungsreichweite vor dem Spieler ca. 1,1 m.
  - **Auslösung:** automatische Erkennung vor dem Spieler, keine zusätzliche Traversal-Taste. Traversal nur bei ausreichendem freien Raum oberhalb und auf der Zielseite.
  - **Ablauf:** kontrollierte Bewegung auf die Zielposition; während des Traversals keine normale WASD-Steuerung; First-Person-Kamera bleibt aktiv; keine Third-Person-Animation.
  - **Ausschlüsse:** kein Wallrun, kein freies Ledge-Grabbing, kein komplexes Vault-System, kein Durchqueren geschlossener Geometrie, keine Ausdauermechanik.
  - **Grenze:** Alle Werte sind vorläufige Tuningwerte und werden nach Junior-Playtest angepasst. Abgleich mit Task/Architektur: „Automatische Erkennung“ bezieht sich auf ausdrücklich erlaubte Passagen (TraversalMarker gemäß Architektur §7/§25 und „Konkrete Arbeit“), nicht auf beliebige Geometrie – das Verbot „kein automatisches Erkennen beliebiger Wände“ bleibt bestehen; der Player erkennt einen Marker in Reichweite automatisch und ohne Taste. Dauer der kontrollierten Bewegung, Auslösebedingung (z. B. Bewegung auf das Hindernis zu) und erlaubte Haltung sind nicht beziffert und werden im P1-03-Auftrag mitgegeben oder als sichtbar vorläufige Tuningwerte ausgewiesen.
- **Verantwortliche Rolle:** Claude Code / Opus 5.0.
- **Priorität:** Hoch; frühes technisches Risiko.
- **Ziel:** Grundklettern mit geprüftem Eintritt, Weg, Ausstieg und sicherem Abbruch zeigen.
- **Sichtbares Ergebnis:** Ein erkennbares primitives Hindernis lässt sich über eine freigegebene Passage überwinden; blockierte Varianten werden abgelehnt oder kontrolliert beendet.
- **Voraussetzungen / Gates:** P1-01/02 geprüft; E03 für Traversalauslösung, Reichweite, Körper-/Haltungsgrenzen, Passage und vorläufigen Ablauf bestätigt. Kein E04-Türsystem erforderlich.
- **Relevante Dokumentreferenzen:** GDD §14; TDD §§15, 26.2/AC-15; Architektur §§7 „Traversal im selben Motor“, 6, 26/TraversalMarker, 29; Roadmap §5/P1, §6/E03, §7 „Traversal“.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, Player-Szene/Motor/Tuning, Sandbox, Levelkoordinator und Main-Pause-/Aktivierungsvertrag; E03 und P1-02-Prüfbericht.
- **Erlaubte Dateien / Verzeichnisse:** `game/world/traversal/traversal_marker.gd`/`.tscn`, vorhandene Player-/Tuningdateien, `game/data/player_tuning.tres`, `game/tests/systems_sandbox.tscn`, `game/levels/vertical_slice/vertical_slice.gd` nur zur lokalen Bindung, `game/project.godot` nur für bestätigte Eingabebelegung; vorhandene Debugansicht; D1/Metadaten.
- **Ausdrücklich verbotene Änderungen:** V1; kein automatisches Erkennen beliebiger Wände, kein Interaktionssystem vor P2, kein Tween/Marker als zweiter Positionsschreiber, kein Teleport als Kletterlösung und kein umfangreiches Parkour.
- **Konkrete Arbeit:** TraversalMarker mit Eintritt/Ausstieg und erlaubtem geometrischem Angebot bauen. Player prüft Reichweite, Einstieg, vollständige Körperfreiheit entlang der Passage und freien Ausstieg vor Beginn. TRAVERSING im bestehenden Motor kollisionsgeprüft ausführen; parallelen Sprung/zweiten Start verhindern. Bei späterer Blockade an letzter kollisionsfreier Lage stoppen und kontrolliert in gültige Fortbewegung zurückkehren. Pause friert den Vorgang ein; Weltabbau verwirft alte Fortsetzungen. Freie/blockierte Varianten in derselben Sandbox bereitstellen.
- **Nicht-Ziele:** Creature-Traversal, Greifen/Ziehen, Schwimmen, Rutschen, Animation-/Parkourframework, Todes-/Saveimplementierung oder finale Levelmaße.
- **Acceptance Criteria:** Freier Weg wiederholt zuverlässig; blockierter Eintritt/Weg/Ausstieg beginnt nicht. Nachträgliche Blockade verursacht weder Durchdrücken noch festhängenden Zustand. Pause/Fortsetzen erhält einen gültigen Ablauf; erneuter Sandboxstart beginnt ohne alte Traversalbewegung. Nur Player schreibt seine Position. Tod-/Restorekombinationen bleiben ausdrücklich ungetestet bis P3/P5.
- **Auszuführende Tests:** CLI-Prüfung; freier Durchgang, zu großer Abstand, gesperrter Eintritt, Wand im Weg, blockierter Ausstieg, schnelle doppelte Auslösung, Pause am Anfang/in der Mitte/vor Ende sowie Weltwechsel während des Vorgangs. Nachträgliche Blockade reproduzierbar mit versetztem neutralem Testkörper im Entwicklungsmodus prüfen, ohne Door-System oder allgemeinen Hinderniscontroller. Normale Lauf-/Sprung-/Duckfälle nachprüfen.
- **Erforderlicher Godot-Test:** Alle geometrischen Fälle praktisch prüfen, insbesondere Körper entlang des Weges und Kamera an der Kante. Testroute/Blockadeanordnung für Wiederholung dokumentieren.
- **Windows-Exporttest:** Freier/blockierter Weg und Pause im Traversal verbindlich in P1-05 im Debugexport wiederholen.
- **Claude-Self-Review:** SR 1–9 vollständig; Schwerpunkt ein Motor, keine ungeprüfte Positionsfahrt, kontrollierte Abbrüche, keine veralteten asynchronen Fortsetzungen und klare spätere Regressionen.
- **Erwarteter Bericht:** Passage-/E03-Profil, reproduzierbare Blockadefälle, Abbruchverhalten, Testresultate und Grenzen für spätere Tod-/Restoretests.
- **Git-/Commitregel:** G1; Teil des gemeinsamen geprüften Player-Prototyps.
- **Astra-Review:** Gate R1 in P1-06; kein separater Kletterreview ohne schwierigen konkreten Befund.
- **Junior-Test:** Optional sichere Zwischenprobe; Grundklettern ist Pflichtteil von J1 in P1-05.
- **Blocker / offene Entscheidung:** E03-Traversalprofil. Nicht zuverlässig beherrschte Körper-/Abbruchprüfung blockiert dessen Abnahme; keine Scope-Erweiterung als Ausweichlösung.
- **Befund / Abnahme (D1, 20.09.2026):**
  - **Stand:** Basis-Commit `2762b58`; ungecommitteter Diff = neu `game/world/traversal/traversal_marker.gd` (+`.uid`) und `traversal_marker.tscn`; geändert `game/player/player.gd`, `game/player/player_tuning.gd`, `game/data/player_tuning.tres`, `game/tests/systems_sandbox.tscn`. `main.gd`, `game_ui.*`, `vertical_slice.gd`, `project.godot` (keine neue Taste) und `player.tscn` unverändert. Kein Commit; Bündelung nach G1 in P1.
  - **Aufbau:** `TraversalMarker` (Area3D mit DetectionZone, Entry am Fuß, Exit auf dem Ziel) bietet dem Player beim Betreten eine Passage an und zieht sie beim Verlassen zurück; er schreibt keine Position. Der Player hält höchstens ein Angebot, prüft Zustand (am Boden, stehend, kein laufender Vorgang), Bewegungsabsicht und Blick auf die Passage (≤ 45°), Abstand zum Eintritt (≤ 1,1 m), Höhe relativ zu den eigenen Füßen (≤ 0,9 m) und die vollständige Körperfreiheit des Weges (senkrecht heben + 0,05 m, dann waagerecht über den Exit) per `test_move()` mit der eigenen Kapsel. Fahrt kollisionsgeprüft über `move_and_collide()` im bestehenden Motor (`_traversal_active` + Wegpunkte, keine Zustandsmaschine, kein Tween/Teleport, keine Registry); währenddessen keine WASD-Bewegung, kein Sprung, kein Haltungswechsel, kein Sprint, Mausblick und First-Person-Kamera bleiben. Nachträgliche Blockade stoppt an der letzten freien Lage und beendet den Vorgang kontrolliert; Pause/Fokusverlust frieren Position und Wegindex ein; Weltabbau verwirft alles.
  - **Sandbox:** gültiges Hindernis 0,8 m (`VaultObstacle`/`VaultMarker`, 4,5 m vor dem Spawn), zu hohes Hindernis 1,3 m (`HighObstacle`/`HighMarker`), Hindernis mit Deckenplatte über dem Ziel (`BlockedObstacle`/`BlockedRoof`/`BlockedMarker`); übrige P1-01/02-Geometrie unverändert.
  - **Automatisierte Tests (Claude, bestanden):** Parser/Import fehlerfrei; temporärer P1-03-Laufzeittest außerhalb des Repos 49/49 headless und 49/49 im Fensterlauf (Angebot/Ablehnungsgründe: zu weit, keine Absicht, seitlich, Blick, geduckt, in der Luft, zu hoch, Weg/Ziel blockiert; gültiger Ablauf mit Start ≈ 1,1 m vor dem Eintritt, ≈ 47 Frames Dauer, Ziel = Markerposition, auch aus 20° und im Sprint; WASD/Jump/Shift/Strg ohne Wirkung währenddessen, kein zweiter Start; nachträgliche Blockade mit temporärem Testkörper → kontrollierter Stopp ohne Durchdrücken, danach frei beweglich, Testkörper entfernt; Pause und Fokusverlust mitten im Vorgang eingefroren, nach Fortsetzen abgeschlossen; Weltwechsel während Traversal ohne alte Referenzen, neuer Lauf ohne Traversalbewegung); P1-02-Test 61/61; P1-01-Test 62/64 (nur die seit P1-02 überholten Erwartungen „`sprint`/`crouch` ungebunden“; Laufstrecke des Tests auf freie Bahn verlegt, da das neue gültige Hindernis vor dem Spawn liegt); R0-Regression 55/55 headless, 63/63 Windows/Vulkan; Debug-/Release-Export erfolgreich, Release ohne `tests/`.
  - **Manueller Test (Project Lead) und informeller Junior-Playtest (20.09.2026, bestanden):** gültiges niedriges Hindernis wird zuverlässig überwunden; automatische Auslösung nachvollziehbar; Traversal aus leicht schrägem Anlauf und mit Sprint-Anlauf funktioniert; seitliches Vorbeilaufen sowie falsche Blick-/Bewegungsrichtung lösen nicht aus; zu hohes Hindernis und blockiertes Ziel korrekt abgelehnt; Pause während Traversal funktioniert; Fokusverlust/Resume ohne inkonsistenten Zustand; erneutes Laden der Sandbox funktioniert; Kamera während Traversal angenehm; keine störenden Kollisionsprobleme.
  - **Baseline:** `traversal_max_height = 0,9 m`, `traversal_detect_range = 1,1 m` (E03) sowie die von Claude gewählten und vom Project Lead bestätigten `traversal_speed = 3,0 m/s`, `traversal_max_angle = 45°`, `traversal_lift_margin = 0,05 m` gelten als erste spielerisch getestete Baseline; keine Tuningänderung erforderlich. Alle Werte bleiben spätere Tuningwerte; Änderungen nur per Auftrag.
  - **Grenzen:** Weg stets „heben, dann waagerecht“; Traversal nur stehend vom Boden; Erkennung nur an Markern (Autorenkonvention: Entry am Fuß, lokale −Z = Passagerichtung); Tod-/Restorekombinationen unerprobt bis P3/P5.

### P1-04 – Testschritte und Movement-Diagnose

- **Task-ID:** P1-04.
- **Titel:** Minimale Footsteps und beobachtbare Bewegungszustände ergänzen.
- **Phase:** P1 – First-Person-Spielgefühl.
- **Milestone:** M1 – Bewegung macht den Raum spielbar; Zulauf R1.
- **Status:** READY – 20.09.2026; P1-01 bis P1-03 ACCEPTED, E12a vorläufig bestätigt (siehe „E12a-Beleg“) und E03 um die Schritttestparameter ergänzt (siehe „E03-Nachtrag Schritte“). Kein automatischer Arbeitsbeginn; konkreter Auftrag steht aus.
- **E03-Nachtrag Schritte (Project Lead, 20.09.2026, vorläufig bestätigt):**
  - **Footstep-Distanz** (zurückgelegte Bodenstrecke pro Schritt): Gehen 0,70 m; Sprint 0,90 m; Ducken 0,50 m.
  - **Triggerregeln:** Footsteps nur bei Bodenkontakt und nur bei tatsächlicher horizontaler Bewegung; kein Footstep im Stand, in der Luft oder während Traversal; nach Pause/Resume kein nachgeholter Schritt.
  - **Lautstärke:** Gehen = Referenzlautstärke; Sprint ca. +2 dB; Ducken ca. −4 dB gegenüber Gehen.
  - **Tonhöhe:** kleine zufällige Variation pro Schritt, ungefähr ±3 %; keine starke hörbare Verfremdung.
  - **Landung:** bei echter Landung nach relevantem Fall ein separater Testimpuls; keine Landungsausgabe bei normalen kleinen Bodenkontakten; der Schwellenwert darf für den Prototyp technisch sinnvoll gewählt und anschließend im Junior-Test abgestimmt werden.
  - **Traversal:** normale Footsteps während Traversal unterdrücken; noch kein eigener Traversal-Sound in P1-04.
  - **Grenzen:** noch keine Oberflächenmaterialien, kein Beton/Holz/Metall-System, kein finales Sounddesign, keine komplexe Audioarchitektur; der Testton aus E12a bleibt temporär. Alle Werte sind vorläufige Tuningwerte.
- **E12a-Beleg (Project Lead, 20.09.2026, vorläufig bestätigt):**
  - **Temporäre Testtonquelle:** projektintern erzeugter, neutraler, kurzer Footstep-/Impulston; keine externe Quelle und damit keine externe Asset-Lizenz erforderlich; ausschließlich für die P1-04-Diagnose; wird später durch hochwertige echte Footstep-Sounds ersetzt.
  - **Testaudio-Profil:** WAV, Mono, 44,1 oder 48 kHz, 16 Bit PCM, ungefähr 80–150 ms Dauer, Peak ungefähr −6 dBFS, keine unnötige Kompression oder Effekte.
  - **Wiedergabe / Test:** zunächst Laptop-Lautsprecher oder normale Kopfhörer; moderate Hörlautstärke, keine maximale Systemlautstärke. Ziel ist die Beurteilung von Timing, Trigger und Dynamik, nicht finales Sounddesign.
  - **Import:** Godot-Import möglichst unverändert und einfach; kein Streaming für diesen kurzen Effekt; keine unnötigen Audio-Plugins; keine zusätzliche Audio-Architektur.
  - **Grenze:** E12a ist nur ein technischer Testbeleg; noch keine finale Footstep-Bibliothek, keine Oberflächenvariation, kein finales Mixing, kein aufwendiges 3D-Audio-Design.
- **Verantwortliche Rolle:** Claude Code / Opus 5.0; Project Lead/Autoren bestätigen Test-Hörsetup.
- **Priorität:** Hoch für vollständige P1-Abnahme, nach erster Spielbarkeit.
- **Ziel:** Tatsächliche Bewegung hörbar und die Ursachen von Bewegungsproblemen sichtbar machen.
- **Sichtbares Ergebnis:** Kleine Testschritte folgen Bodenbewegung; abschaltbare Debuganzeige zeigt reale Movement-/Haltungs-/Freigabezustände.
- **Voraussetzungen / Gates:** P1-01–03 geprüft; E12a und benötigte E03-Schritttestparameter bestätigt. Reine Debuganzeige kann bei offenem Audiogate separat geprüft werden, Audio bleibt dann offen.
- **Relevante Dokumentreferenzen:** GDD §§14, 26; TDD §§19, 25, 26.2/AC-19/24; Architektur §§7, 18, 23, 28; Roadmap §5/P1, §6/E12a und §12 „Placeholder → Produktinhalt“.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, Player-Szene/Motor/Tuning, Sandbox, vorhandene Debugdateien, Main-/UI-Aktivierung, Projekt-/Exportkonfiguration und `.gitignore`; bestätigtes Test-Audioprofil.
- **Erlaubte Dateien / Verzeichnisse:** Vorhandene Player-/Tuningdateien, `game/data/player_tuning.tres`, `game/debug/debug_overlay.gd`/`.tscn`, `game/app/main.gd` nur für Debugbindung, `game/tests/systems_sandbox.tscn`, `game/assets/audio/` ausschließlich freigegebene kleine Testgeräusche; benötigte Buskonfiguration unter `game/` und deren Projektverweis. Falls dateibasierte eigene Testquelle nötig: zugehöriges Original unter `source_assets/audio/` und knapper Herkunftsnachweis unter `licenses/`; D1/Metadaten. Nur konkret benötigte Dateien erzeugen.
- **Ausdrücklich verbotene Änderungen:** V1; keine Produktassetdownloads, fremde Soundbibliothek, Musik/Ambience, KI-Hörlogik, NoiseManager oder neue AudioResource-Klasse. Keine speichernden Debugeingriffe und keine Releasefreigabe des Overlays.
- **Konkrete Arbeit:** Eine kleine bestätigte eigene oder bereits bereitgestellte Testtonquelle einbinden; Herkunft und vorläufigen Charakter festhalten. Schritte aus tatsächlich zurückgelegter Bodenstrecke auslösen und Lauf-/Sprint-/Duckkontext gemäß Testprofil berücksichtigen; lokale Audioquelle am Player, eine Hörperspektive. Anhalten/Luft/Pause/Neuaufbau sauber behandeln. Bestehendes Overlay ergänzen oder minimal erstellen: Haltung, GROUNDED/AIRBORNE/TRAVERSING, tatsächliche Geschwindigkeit/Bodenkontakt, Phase und Eingabefreigabe nur lesend anzeigen. Keine zweite Zustandswahrheit.
- **Nicht-Ziele:** Finale Klangidentität, Oberflächenbibliothek, akustische Simulation, Creature-/Noise-System, umfangreiche Debugkonsole oder persistente Einstellungen.
- **Acceptance Criteria:** Stillstand, gegen Wand gehaltene Lauftaste, Luft und Pause erzeugen keine fortlaufenden Gehschritte. Echte Bodenbewegung erzeugt verständliche Testschritte; Fortsetzen/Neuaufbau verursacht keine aufgestauten Töne. Hörbare Wiedergabe bleibt vom späteren KI-Geräuschmodell getrennt; P1 behauptet noch keinen KI-Hörnachweis. Overlay liest aktuelle Daten, ist abschaltbar und im Release nicht instanziiert/aktivierbar.
- **Auszuführende Tests:** CLI-/Importprüfung; Stillstand, Wandlauf ohne Strecke, Gehen, Sprint, Ducken, Sprung/Landung, Traversal, Pause/Fortsetzen und mehrfacher Weltwechsel. Kein Audio-/Referenzstapeln; Stummschalten verändert Bewegung nicht. Anzeige gegen beobachtete Zustände prüfen und Releasegrenze erneut kontrollieren.
- **Erforderlicher Godot-Test:** Mit bestätigtem Hörgerät/Lautstärke selbst hören; lokale Quelle und Kamera-/Listenerzuordnung kontrollieren. Keine Audioabnahme ausschließlich anhand von Code oder Pegelanzeige.
- **Windows-Exporttest:** Audioressourcen, tatsächliche Hörbarkeit und Debuggrenze in P1-05 verbindlich prüfen.
- **Claude-Self-Review:** SR 1–9 vollständig; tatsächliche Strecke statt Taste als Schrittursache, lokale Audiolebensdauer, Testasset-Herkunft und Debugisolation prüfen.
- **Erwarteter Bericht:** Quelle/Herkunft, Hörsetup/Importprofil, Schrittbedingungen, Debugfelder und Testfälle einschließlich fehlender menschlicher Hörprüfung.
- **Git-/Commitregel:** G1; kleine notwendige Testressourcen mit Herkunft, keine Export-/Cachedateien; Bündelung am P1-Integrationspunkt.
- **Astra-Review:** Gate R1 in P1-06 mit gesamtem Movement-Stand.
- **Junior-Test:** Hörbarkeit und Bewegungsrückmeldung in J1; frühere Bewegungstests warten nicht darauf.
- **Blocker / offene Entscheidung:** E12a und erlaubte Testquelle. Kein Download oder Produktasset als Ersatz für fehlende Freigabe; geringe neutrale Quelle genügt.

### P1-05 – Integrierter Movement-Test und J1

- **Task-ID:** P1-05.
- **Titel:** Vollständigen P1-Stand praktisch prüfen und mit Junior abnehmen.
- **Phase:** P1 – First-Person-Spielgefühl.
- **Milestone:** M1 – Bewegung macht den Raum spielbar; Übergabe an R1.
- **Status:** PLANNED.
- **Verantwortliche Rolle:** Project Lead koordiniert/bewertet; Claude Code / Opus 5.0 führt technische Tests aus; Junior/Spielautoren prüfen Spielgefühl und kreative Abnahme.
- **Priorität:** Hoch; vor R1.
- **Ziel:** Den zusammenhängenden Playerstand statt isolierter Einzelmechaniken beurteilen.
- **Sichtbares Ergebnis:** Reproduzierbar spielbare Teststrecke im Editor und Windows-Debugexport, dokumentierter J1-Befund und fixierter Reviewstand.
- **Voraussetzungen / Gates:** P1-01–04 mit SR und Systemtests; E03/E12a samt verwendetem Profil dokumentiert. Keine bekannten Absturz-/Kollisionsblocker im Junior-Teststand.
- **Relevante Dokumentreferenzen:** GDD §§14, 28, 34; TDD §§26.1–26.2/AC-01/02/03/15/18/19/21–24 im vorhandenen Umfang, 26.4; Architektur §§7–8, 28–31; Roadmap §5/P1, §8/J1, §9/R1 und §11 „Verbindliche spätere Regressionen“.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, P1-01–04-Befunde/E03/E12a, gesamte kleine Movement-Teststrecke und Player-/Traversal-/Audio-/Debugdateien, Main/UI/Level-Verbindungen, Projekt-/Exportkonfiguration.
- **Erlaubte Dateien / Verzeichnisse:** Standardmäßig bestehende Implementierung lesend, D1 und unversionierte Testexporte unter `exports/p1/`. Normale Korrekturen werden mit konkretem Befund in den zuständigen P1-01–04-Task zurückgegeben; nur dessen Dateigrenze gilt, keine pauschale neue Codefreigabe durch diesen Testtask.
- **Ausdrücklich verbotene Änderungen:** V1; keine neuen Mechaniken aus Feedback, kein Produktlevel, keine Health-/Restoreimplementierung für noch nicht mögliche Regressionen und kein Abschwächen der Release-Sandboxsperre.
- **Konkrete Arbeit:** 1. Frischen Lauf mit dokumentierten Testankern starten. 2. Gesamte Strecke mit Blick/WASD/Sprung/Sprint/Ducken/Traversal, Footsteps und Debugzuständen wiederholt prüfen. 3. Pause/Fortsetzen und Fokusverlust bei Stehen, Sprung, Ducken und Traversal kombinieren; neuen Sandboxlauf prüfen. 4. Editor und Standalone-Debugexport vergleichen, Release-Grundhülle/Testsperren erneut testen. 5. J1 begleitet durchführen: zunächst beobachten, nicht fortlaufend vorsagen; Spaß, Verständlichkeit, Hängenbleiben und Kamerakomfort in Juniors Worten festhalten. 6. Technische Fehler von Geschmacks-/Designwünschen trennen, zugewiesene Korrekturen nachtesten; E03-Befund für P1 konkretisieren und Übergabe an R1 fixieren.
- **Nicht-Ziele:** Finale Flucht-/Raumdimensionen, Horrorwirkung, Produktperformance, gesamte V0.1-Abnahme oder nachträgliche Ausweitung von P1.
- **Acceptance Criteria:** Vollständige Teststrecke ohne Entwicklersteuerung spielbar; blockiertes Aufstehen, Eintritt/Weg/Ausstieg und nachträgliche Traversalblockade sicher. Kein Diagonalbonus, Kameradurchtritt, durchgereichter Klick oder alter Sprungauftrag nach Pause/Neulauf. Audio/Anzeige stimmen. J1 durchgeführt und bewertet; technische Blocker behoben, verbleibender Feinschliff ausdrücklich eingeordnet. E03-Ergebnisse reproduzierbar, R1 noch offen. ACs werden nur in tatsächlich vorhandenen Teilumfängen erfüllt markiert.
- **Auszuführende Tests:** Vorhandene CLI-/Parser-/Importprüfungen; kombinierte Regression aus P1-01–04 bei variierender Bildrate, mehrfachen Weltwechseln und Fokuswechseln. Kleinen vergleichbaren RAM-/Framezeitbefund mit Editor plus Spiel und Standalone erfassen; keine unbegründeten FPS-Grenzen. Gezielte Korrekturen nur mit betroffenen Nachtests.
- **Erforderlicher Godot-Test:** Ja, kompletter praktischer Movementdurchlauf und J1. Junior kann bei Unwohlsein/Frust pausieren oder abbrechen; ausstehender/abgebrochener Test bleibt sichtbar und ist keine Abnahme.
- **Windows-Exporttest:** Ja: frisch gebauter Debugexport mit gesamter Strecke, Maus/Fokus/Pause/Audio ohne Editor als normaler Benutzer. Release-Grundhülle startet; Sandbox/Debugwerkzeuge bleiben gesperrt. Das ist noch kein spielbarer Produktrelease.
- **Claude-Self-Review:** Technischer Testbericht und Diff-/Scopeprüfung nach SR; bei jeder Claude-Korrektur erneut SR 1–9 im zuständigen Task. Nicht durchführbare Tests einzeln benennen, nicht vom Editorbefund ableiten.
- **Erwarteter Bericht:** Fallmatrix mit Build-/Profilbezug, Editor-/Exportvergleich, J1-Beobachtungen und Autorenbewertung, Fehler/Nachtests, E03-Befund und offene spätere Regressionen. Prüfpaket für R1 mit engem Fokus vorbereiten.
- **Git-/Commitregel:** G1; getesteter P1-Integrationspunkt mit vorgesehenem Titel möglich, ausschließlich bei konkreter Commitfreigabe; ohne Commit Basis plus abgegrenzten Diff übergeben.
- **Astra-Review:** Gate R1 folgt einmal gebündelt in P1-06 nach Godot- und J1-Befund.
- **Junior-Test:** Ja – **J1**, formaler P1-Abnahmetest am Ende der vollständigen Movement-Phase und vor R1.
- **Blocker / offene Entscheidung:** Ausstehendes J1, nicht getesteter Export oder blockierender Movementfehler verhindert vollständige Übergabe. Tod/Tempo P3, Restore P5 und reale Raumgeometrie P7 werden hier ausdrücklich nicht als bestanden geführt.

### P1-06 – R1: Player / Movement prüfen

- **Task-ID:** P1-06.
- **Titel:** Ein gebündelter Senior-Review R1 des vollständigen Player-Prototyps.
- **Phase:** P1 – First-Person-Spielgefühl.
- **Milestone:** M1 – Bewegung macht den Raum spielbar; Abschlussgate R1.
- **Status:** PLANNED.
- **Verantwortliche Rolle:** Codex / Astra High für Review; Project Lead und Spielautoren für M1-Abnahme, Claude für eindeutig zugewiesene normale Korrekturen.
- **Priorität:** Hoch; vor davon abhängiger weiterer Systemplanung.
- **Ziel:** Kritische Bewegungs-, Kollisions-, Eingabe- und Lebensdauergrenzen des zusammenhängenden Stands prüfen.
- **Sichtbares Ergebnis:** R1-Bericht, erledigte blockierende Befunde und begründete Empfehlung zur M1-Abnahme.
- **Voraussetzungen / Gates:** P1-01–05 getestet, SR-Nachweise, J1 vor R1 durchgeführt und bewertet; E03/E12a-Belege, fixierter Übergabestand ohne konkurrierende Implementierung.
- **Relevante Dokumentreferenzen:** ADR-001; GDD §14; TDD §§6, 15, 26.2/AC-01/02/03/15/19/21/24, 26.4; Architektur §§6–8, 18, 23, 28–29; Roadmap §5/P1, §9/R1 und §11 „Verbindliche spätere Regressionen“.
- **Zu lesende Bestandsdateien:** AGENTS.md, CLAUDE.md, abgegrenzter P1-Diff und neue Dateien, Player/Tuning, TraversalMarker, Sandbox, Audio-/Debugbindung und betroffene Main/UI/Levelstellen; P1-05-Testpaket einschließlich J1.
- **Erlaubte Dateien / Verzeichnisse:** Implementierung nur lesend; Reviewbericht und D1. Korrekturauftrag bei Bedarf separat mit verantwortlicher Rolle und genauer Dateigrenze.
- **Ausdrücklich verbotene Änderungen:** V1; keine Einzelreviews je Mouse Look/Jump/Sprint/Crouch, kein stilgetriebener Neubau, kein zweiter Implementierer und keine vorgezogene Savearchitektur.
- **Konkrete Arbeit:** Einen Positionsschreiber und getrennte Haltungs-/Fortbewegungsachsen prüfen; Körper-/Kamera-/Aufsteh-/Traversalprüfungen, Blockadeabbruch, Pause/Fokus und alte Eingaben beurteilen. Instanzlokale Formen und unveränderte Tuningdefinitionen, Schrittursache und Debugisolation prüfen. Spätere Restore-Verträglichkeit am vorhandenen Aktivierungs-/Positionierungs-/Resetvertrag beurteilen, ohne Restore zu implementieren oder zu behaupten. Relevante Befunde zuweisen, nach Korrektur gezielt nachprüfen.
- **Nicht-Ziele:** Einzeldatei-Stilreview, endgültige Bewegungswerte, Save-/Health-/Creature-Code, Voll-Parkour oder Produktlevel.
- **Acceptance Criteria:** Ein nachvollziehbares Gesamturteil zu P1; keine offenen blockierenden Movement-/Kollisions-/Lebensdauerfehler. Tests und J1 stützen die Abnahme. P3-/P5-/P7-Nachprüfungen sind ausdrücklich vorgemerkt. Erst Project Lead/Autoren setzen M1 nach Bewertung auf angenommen.
- **Auszuführende Tests:** Gezielt Diff/Verträge mit P1-05-Fällen abgleichen; konkrete Verdachtsfälle reproduzieren, vorhandene Tests nutzen. Kein vollständiges doppeltes Testprogramm ohne Anlass.
- **Erforderlicher Godot-Test:** Praktische P1-05-Befunde zwingend. Jede relevante Korrektur braucht betroffene Godot-Nachtests; geändertes Spielgefühl gegebenenfalls erneut Junior vorlegen.
- **Windows-Exporttest:** P1-05-Nachweis erforderlich; export-, input-, audio- oder movementrelevante Korrekturen im aktualisierten Debugbuild nachtesten, Debuggrenzänderungen zusätzlich im Release.
- **Claude-Self-Review:** Vollständige SR-Belege der Implementierung vorausgesetzt; zugewiesene Claude-Korrekturen erneut nach SR 1–9. Senior-Review ersetzt keine Selbstprüfung oder praktische Tests.
- **Erwarteter Bericht:** R1, Stand, enger Prüfumfang, Befunde mit Reproduktion/Schwere, Testlücken/Nachtests, P5-Restorebedarf und M1-Abnahmeempfehlung. Keine pauschale Freigabe späterer Systeme.
- **Git-/Commitregel:** G1; Review allein erlaubt keinen Commit. Nachgeprüfte Korrekturen bleiben eindeutig zum getesteten Integrationsstand zugeordnet.
- **Astra-Review:** Ja – **R1 selbst**, einmal gebündelt für P1-01 bis P1-05 am Ende P1.
- **Junior-Test:** J1 muss vorher vorliegen; erneute gezielte Probe nur bei relevant verändertem Gefühl/Bedienung oder offenem Befund.
- **Blocker / offene Entscheidung:** Blockierende R1-Befunde oder fehlende Runtime-/J1-Nachweise halten M1 offen. Restore ist erst P5 nachweisbar; das ist eine spätere Pflichtprüfung, kein Anlass zum Scopeausbau in P1.

## 6. Verbindliche spätere Nachprüfungen

Diese Verweise sind keine zusätzlichen Mikroaufgaben und keine bereits bestandenen Tests. Sie erhalten die Grenzen früher Teilabnahmen gemäß Roadmap §11 und TDD §26.

| Früher Stand | Später notwendiger Nachweis |
| --- | --- |
| Main, Input, Fokus und Export aus P0 | P5 Restore aus Pause/Game Over einschließlich Signal-/Physikbereitschaft; P7 echte Welt; P12 installierter Release. |
| Bewegung/Traversal aus P1 | P3 Tod während Traversal, Health-/Tempoübergänge; P5 Haltung, Bewegung, Effekt, Position und Kamera nach Restore; P7 reale Wege/Geometrie. |
| Audio und Debug aus P1 | P4 echte Trennung hörbarer Ausgabe und KI-Geräusch; P5 keine historischen Schritte/alten Quellen beim Restore; P9 Mix ohne Regeländerung; P12 Releaseisolation. |
| Vorläufige Hardware-/Rendererbefunde | Aussagekräftiger Vergleich für E02b in P0–P2, spätestens vor P3-Grafik-/Lampenabstimmung; repräsentative Messung/E18 vor größerem Ausbau P7. |

## 7. P2–P12 – Nur zukünftige Taskgruppen

**Wird detailliert, sobald vorherige Phase reale Befunde geliefert hat.** Es werden hier keine späteren Einzel-Task-IDs, Dateifreigaben oder Ausführungsaufträge vergeben. Vor P2 zuerst P0-/P1-Ergebnisse, R0/R1 und offene Gates auswerten; weitere Phasen entsprechend fortschreiben. Quellen sind die gleichnamigen Phasen in Roadmap §5 und ihre Gates in §6.

| Phase / Milestone | Grobe zukünftige Taskgruppen | Maßgebliche Voraussetzungen / spätere Prüfung |
| --- | --- | --- |
| P2 / M2 – Interaktion, echter Besitz und Tür-/Navigationsprobe | Interaction; Doors; Switches; Pickups; Inventory Core/ItemDefinition; neutraler Hinweis; IDs/Validierung; Door/Navigation Prototype mit minimalem späterem Creature-Motor; kleine Rendererprobe | P1; E04/E05/E06, E13a nur bei externer Importprobe; E02b vor P3; J2. Keine vollständige KI oder erfundenen Rätsel. |
| P3 / M2 – Itemnutzung, Player State und Niederlage | Inventarbedienung; Flashlight; Tempo-Item; Health/Schaden/Tod; Game Over; Anfangs-Wiederanlauf im Speicher über vorhandenen Main-Aufbau | P2; E02b/E06/E07/E08; Movement-/Traversalregression bei Tod/Tempo. Noch keine dauerhaften Saves. |
| P4 / M3 – Creature Prototype und erste Verfolgung | Eine FSM; Sicht/Hören; Navigation/Türkopplung; Chase/Search/Return; faire Flucht und kontrollierte Fehlerausgänge | P1–P3, E04/E09/E14a; J3 und R2; kein finales Monsterdesign aus Testkörpern ableiten. |
| P5 / M4 – Save, Checkpoints und Restore | SaveService; JSON/user://; Autosave/Checkpoints und manuelle Speicherpunkte; eigenständiger Todes-Wiederanlauf; Fehler/Backup; neutrale Puzzle-/Progress-Verträge; Weltneuaufbau | P0–P4; E10/E11; R3, TDD §26.3; ausdrücklich Movement-/Haltungs-/Traversal-/Fokusregression nach Restore. |
| P6 / M5 – Zwei echte Rätsel und Storyfortschritt | Zwei unterschiedliche freigegebene Rätsel; Items/Türen; echte Hinweise/Einmalflags; Enthüllungs-/Abschlussbedingungen; Inhalts-Saveregression | P5; E14b/E15/E16a; J4 früh am ersten Rätsel, beide vor M5. Keine Inhaltswahl durch Technik. |
| P7 / M6 – Vertical-Slice-Level und kompletter Rohdurchlauf | Eigene Rohlevelgeometrie; vollständiger Pflichtweg; reale Flucht-/Traversalwege und Saveanker; begrenzte Produktasset-/Licht-/Audioprobe; Ressourcen-/Dauermessung | P1–P6; E12b/E13b/E16b/E17/E18/E19; J5/R4 und reale Bewegungs-/Nav-/Saveregression. |
| P8 / M7 – Art, Licht und visuelle Atmosphäre | Modelle/Materialien/Texturen; benötigte Figuren-/Kreaturendarstellung und Animationen; Licht/Lesbarkeit; Lizenz-/Importprüfung | M6; E02b/E13b/E18/E19; geänderte Geometrie gegen Movement/Navigation nachprüfen. |
| P9 / M7 – Sound und Horror-Polish | Schritte/Oberflächen; Türen/Kreatur/Umgebung; Ambience/Musik/UI; räumliche Warnung und Mischung | M6; E12b/E19 und E14a; funktionale Audioereignisse schon vorhanden, KI-Regeln unverändert halten. |
| P10 / M7 – UI, UX und Spielkomfort | Vorhandene Menüs/Ansichten und Rückmeldungen verfeinern; Maus-/Audioeinstellungen; Lesbarkeit/Komfort | M6; E05–E08/E11/E20; Pflichtbedienung nicht erst hier einführen. |
| P11 / M7 – Integration, Spieltests und Balancing | Gesamtdurchläufe; Movement/Gefahr/Rätsel/Story/Checkpoints abstimmen; 15–25-Minuten-Ziel; Performance; Release Candidate | P7–P10 integriert; J6, Scope-/Regeländerungen ausdrücklich entscheiden. |
| P12 / M8 – Stabilisierung und V0.1 Release | Fehlerbereinigung; kompletter Save-/Lifecycle-Regressionsnachweis; Windows-Installation/Export; Debugsperren; Lizenzen; Releaseprüfung | M7; E21, J7/R5 und Roadmap §16; keine neuen Features oder automatische Veröffentlichung. |

## 8. Konsistenzprüfung der Planung

| Prüffrage / Quelle | Ergebnis dieses Dokumentabgleichs |
| --- | --- |
| P0 vollständig? Roadmap §5/P0, ADR-007/008 | Engine/Hardware/Templates/E01 und E02a in P0-01; Main/UI/Sandbox/Projekt in P0-02; Input/Pause/Fokus in P0-03; Editor-/Windows-Debug-/Releaseexport und Messbasis in P0-04; R0 in P0-05. |
| P1 vollständig? GDD §14, TDD §§6/15/19, Roadmap §5/P1 | Player/Kamera/WASD/Gravity/Jump in P1-01; Sprint/Crouch/sicheres Aufstehen in P1-02; Traversal in P1-03; Schritte/Debug in P1-04; Kombinationen, Export und J1 in P1-05; R1 in P1-06. |
| Früh spielbar? Roadmap §§3/5/8 | Informelle Junior-Probe unmittelbar nach P1-01, vor weiteren Bewegungsarten; formales J1 am Ende. |
| Kleine Claude-Pakete? Roadmap §17 | Zusammenhängende Ergebnisse statt Task pro Script; Environment, Basis, Input, Export und die vier Movement-Ausbaustufen sind getrennt testbar. |
| Architektur eingehalten? Architektur §§6–8/21/29/31 | Main ohne Autoloads, ein Motor, eine Sandbox mit demselben Levelvertrag; spätere Teilnehmer optional. Debugexport spielt Sandbox, Releasegrundhülle sperrt Testpfad. Kein Produktlevel als Exportbehelf. |
| Offene Gates respektiert? Roadmap §6, Architektur §34 | E01/E02a vor Projektanlage, benötigte E03-Teile vor Eingabe/Motor, E12a vor Schritten. E02b bleibt bis zur repräsentativen Probe offen; keine Gameplaywerte erfunden. |
| Reviews gebündelt? Roadmap §9 | Ausschließlich R0 und R1 regulär, keine Feature-Einzelreviews. Godot/J1 vor R1; Claude-Self-Review verpflichtend, Korrekturzuständigkeit eindeutig. |
| Gezielter Kontext? Roadmap §17 | Je Task genaue Abschnitte, ADRs und relevante Bestandsdateien; keine pauschale Pflicht zur vollständigen Neulektüre. |
| Späterer Scope geschützt? GDD §§30–32, TDD §26, Roadmap §§11/13 | P2–P12 nur Gruppen; Tod-/Restore-/Inhaltsnachweise ausdrücklich später. Keine vorgezogenen Inventory-/Save-/KI-/Rätsel-/Asset-/Ausdauersysteme. |
| Redaktionelle Altstände? | TDD §1 nennt ältere vertauschte Agentenrollen; aktueller Auftrag/Roadmap §9 sind maßgeblich. Frühere offene Perspektiv-/Engineangaben werden durch angenommene ADRs konkretisiert. Historische Freigabevermerke sind keine neue sachliche Entscheidung. |

**Ergebnis:** Keine fachlichen Widersprüche dieser Taskplanung zur Roadmap festgestellt. Die genannten redaktionellen Altstände sind kenntlich gemacht; die Quelldokumente bleiben unverändert. Die Entwicklungsmodusgrenze der Sandbox wird durch getrennte Debug-/Releaseprüfungen erhalten. Diese Aussage ist ausschließlich eine Dokumentprüfung: keine Hardwaremessung, kein Godot-Test, kein Export, kein J1 und kein R0/R1 wurden ausgeführt; kein Task wurde automatisch `ACCEPTED`.

## 9. Erster an Claude Code zu vergebender Auftrag

| Feld | Festlegung |
| --- | --- |
| Task | **P0-01 – Bootstrap / Environment Verification** gemäß vollständigem strukturiertem Task in §4 |
| Status / Rolle | READY zur Beauftragung; Claude Code / Opus 5.0 |
| Erster Durchlauf | Nur vorhandene Engine/Templates/Hardware lesend prüfen, E01-Befund und E02a-Vorschlag berichten; kein Godot-Projekt anlegen. |
| Ergebnisgrenze | Nach dem Bericht auswerten. Falls Templates fehlen, nur deren genau begrenzte Installation/Nachprüfung als Fortsetzung ausdrücklich beauftragen. E02a-Auswahl dokumentieren, bevor P0-02 beginnt. |
| Dateigrenze / Git | Bericht und gegebenenfalls ausdrücklich beauftragte D1-Befundpflege; keine Implementierungsdateien, Downloads, Installationen oder Commits im ersten Prüfauftrag. |
| Nächster Schritt | Project Lead erstellt ausschließlich aus P0-01 den konkreten Claude-Code-Prompt. P0-02/03/04 nicht gleichzeitig mitbeauftragen. |

Dies ist die strukturierte Auftragsauswahl, kein Chatprompt und noch keine Ausführungserlaubnis.
