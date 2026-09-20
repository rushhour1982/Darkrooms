# Dark Rooms – Software- und Godot-Architektur

## 1. Dokumentstatus

**Version:** 0.2 · **Datum:** 19.09.2026 · **Status:** Zweiter kritischer Architekturreview abgeschlossen; zur Freigabe, noch nicht implementiert.

Verbindliche Grundlage sind [GAME_DESIGN.md](GAME_DESIGN.md), [TECHNICAL_DESIGN.md, Version 0.2](TECHNICAL_DESIGN.md), [DECISIONS.md](DECISIONS.md), AGENTS.md und CLAUDE.md. Das GDD hat fachlich Vorrang. ADR-001 bis ADR-007 konkretisieren ausdrücklich zuvor offene Teilfragen; ADR-008 lässt den Renderer offen. Die Platzhalter-README enthält keine zusätzlichen Spielentscheidungen.

Dieses Dokument beschreibt die vorgeschlagene Umsetzung des 0.1-Kerns. Dateinamen, Node-Bäume und Verträge sind Architekturvorschläge, keine bereits vorhandenen Dateien. **TECHNISCHE EMPFEHLUNG** bezeichnet einen begründeten Umsetzungsansatz; **NOCH OFFEN** bezeichnet eine nicht erteilte fachliche oder technische Freigabe. Insbesondere werden offene Speicher-, Health-, Inventar-, Rätsel- und Storyregeln nicht durch Implementierungsdetails entschieden.

Es entstehen in diesem Arbeitsschritt ausschließlich Dokumentationsänderungen. Es gibt noch keinen Nachweis durch ausführbare Szenen, Hardwaremessungen oder einen Export.

## 2. Architekturziele

- Einen gestalteten Singleplayer-Vertical-Slice von etwa 15–25 Minuten ermöglichen: First Person, Erkundung, zwei unterschiedliche Rätsel, eine Kreatur, Flucht, Storyfortschritt und Abschluss.
- Bewegung, Sound, Atmosphäre und lesbare realistisch wirkende 3D-Darstellung zuverlässig unterstützen; keine Pixel-Art oder bewusst verpixelte Optik.
- Konsistente Weltzustände vor schöner Darstellung priorisieren: Ein Gegenstand hat einen nachvollziehbaren Besitzort, eine Tür eine tatsächliche Stellung, ein Rätsel einen maßgeblichen Zustand.
- Autosaves/Checkpoints und manuelle Speicherpunkte einschließlich korrektem Todes-Wiederanlauf robust umsetzen.
- Auf einem Entwicklungsrechner mit 16 GB RAM praktisch bearbeitbar bleiben; GPU, Renderer und Leistungsbudgets nicht vorwegnehmen.
- Kleine, einzeln prüfbare Implementierungsaufträge und Reviews ermöglichen, ohne eine Plattform für hypothetische spätere Features zu bauen.

## 3. Architekturprinzipien

1. **Eine Wahrheit pro Zustand.** Der zuständige Besitzer verändert ihn; UI, Audio und Animation bilden ihn ab. Ein Snapshot ist eine unveränderliche Kopie, keine zweite laufend synchronisierte Welt.
2. **Szenenbesitz statt globale Dienste.** Main besitzt die Lebensdauer, das Level seine lokalen Objekte, jeder Akteur seine eigenen Zustände. Keine Autoloads als Ausgangspunkt.
3. **Direkte Aufträge nach unten, lokale Meldungen nach oben.** Bekannte Eigentümerschaft verwendet direkte Referenzen; entkoppelte Rückmeldungen lokale Godot-Signals. Kein globaler Event-Bus.
4. **Kleine zusammenhängende Scripts.** Player-Motor und Traversal bleiben zusammen; Chase/Search gehören zur einen Kreaturensteuerung. Auslagerung erst bei einer echten Verantwortungsgrenze.
5. **Statische Definition, Laufzustand und Speicherzustand trennen.** Gemeinsam geladene Resources sind keine Laufzustandscontainer.
6. **Zuerst validieren, dann verändern.** Aufnahme, Itemeinsatz und Rätselschritt laufen ohne Unterbrechung als kurze logische Änderung; danach folgen Meldungen und Präsentation.
7. **Initialisierung ist keine Spielaktion.** Restore löst weder neue Funde noch Storybelohnungen, Geräuschereignisse oder Treffer aus.
8. **Explizite Grenzen statt stiller Reparaturen.** Keine KI-Teleports, heimliche Spielerortung, willkürlichen Spawnkorrekturen oder automatisch verworfenen Pflichtdaten.

Die fachlichen Daten verwenden einfache Werte und stabile IDs. Godot-Resources dienen als Editoradapter; Originalassets und Design bleiben außerhalb des Runtime-Projekts. Es wird dafür kein zusätzlicher Import-/Export-Frameworkbau verlangt.

### Godot-Praxisprüfung des zweiten Reviews

Die Empfehlungen wurden gegen die offizielle Godot-4.7-Dokumentation geprüft. Das ist eine API-/Entwurfsprüfung für die projektseitige Basis 4.7.2, kein ausgeführter Patchstand- oder Physiktest.

| Baustein | Urteil und notwendige Grenze |
| --- | --- |
| CharacterBody3D für Player und Creature | Beibehalten: Beide werden per Script bewegt und benötigen Weltkollision. Schwerkraft/Bodenverhalten im jeweiligen Motor behandeln; weder freie Rigidbody-Simulation noch ein zweiter Bewegungsschreiber. [Referenz](https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html) |
| AnimatableBody3D für Door | Beibehalten: Kontrollierte bewegte Kollision; physiksynchrone Animation. Kollisionskörper verhindert nicht selbst das Quetschen, deshalb Freiraumprüfung (§10). |
| NavigationRegion3D / NavigationAgent3D | Beibehalten: Gebackene Flächen plus ein Agent; CharacterBody bewegt sich selbst. Agentbereitschaft und Pfadfolge testen, keine Avoidance-Pflicht. [Agent-Referenz](https://docs.godotengine.org/en/4.7/classes/class_navigationagent3d.html) |
| NavigationLink3D | Nur für benötigte dynamische Durchgänge, nicht generell pro Tür. Region-Alternative ist nicht automatisch einfacher oder stabiler (§17). |
| RayCast3D | Beibehalten: Ein kurzer Strahl genügt. Areas aktivieren, Player explizit ausschließen, bei Interaktionsauslösung veralteten Treffer vermeiden (§9). |
| SceneTree.paused / process_mode | Beibehalten für echte Pause; Restore dagegen unpausierte Engine mit gesperrtem Gameplay. Signals benötigen weiterhin Freigabeprüfung (§6). |
| Resources | Beibehalten für wenige statische Definitionen; keine geteilten Laufzustände und keine überflüssigen Konfigurationsklassen (§23). |
| RefCounted | Beibehalten für SaveService und Inventory, nicht für eine reine Geräuschmeldung; keine zyklischen Besitzerreferenzen (§4). |
| FileAccess / DirAccess | Beibehalten: direktes serielles Datei-I/O mit Fehlerprüfung, kein zusätzlicher Speicherdienst oder Thread. Windows-Ersetzen separat testen (§19). |
| JSON | Beibehalten für primitive, lesbare Fortschrittsdaten. Explizite Typ-/Werteprüfung nötig; keine automatische Godot-Objektserialisierung (§19). |
| user:// | Beibehalten als beschreibbarer benutzerbezogener Speicherort; Produktnamen/-pfad später stabil konfigurieren, Entwicklungs-Testdaten getrennt halten. [Dateipfade](https://docs.godotengine.org/en/4.7/tutorials/io/data_paths.html) |

Das Ergebnis rechtfertigt gezielte Vereinfachungen, keinen Austausch der Engine-Grundbausteine und keine neue Architekturschicht.

## 4. Gesamtübersicht

Die Architektur besteht aus einer dauerhaft vorhandenen **Main-Szene**, genau einer geladenen **Levelinstanz**, lokalen **Akteuren/Weltobjekten** und einer zustandslosen **UI-Darstellung**. „Zustandslos“ meint hier ohne eigene Gameplay-Wahrheit; Fokus und offene Ansichten gehören selbstverständlich zur UI.

```text
Main: Spielphase, Lauflebensdauer, Einstellungen, Checkpointzuordnung
├── SaveService: Datenprüfung und Datei-I/O, keine Weltregeln
├── GameUI: Darstellung und Bedienwünsche
└── WorldHost → VerticalSlice: lokaler Zusammenbau, IDs, Storyfortschritt
    ├── Player → Inventory; Interactor; Kamera/Licht/Schritte
    ├── Creature → eine FSM; Wahrnehmung; Navigation
    ├── Puzzle A / Puzzle B → freizugebende Türen
    └── Türen, Schalter, Pickups, Hinweise, Speicher- und Traversalpunkte
```

Main wechselt nicht die gesamte Hauptszene, sondern ersetzt nur das Kind unter WorldHost. SaveService und Inventory bleiben kleine `RefCounted`-Objekte, keine Nodes oder Singletons: Datei-I/O gehört nicht in den Flow, reine Bestandsregeln nicht in den Bewegungsmotor. Beide benötigen weder SceneTree noch eigene Verarbeitung und sind direkt testbar. Sie halten keine Rückreferenzen auf Main, Player oder UI und keine Callbacks auf ihre Besitzer. Referenzgezählte Zyklen werden dadurch vermieden; ein Zusammenlegen würde nur diese klaren Grenzen entfernen. [Godot 4.7 – RefCounted](https://docs.godotengine.org/en/4.7/classes/class_refcounted.html)

Das Level verdrahtet lokale Objekte einmal beim Aufbau; es ist kein allgemeiner Service-Locator. Separate Health-, Chase-, Quest-, Flashlight-, Noise- oder AudioManager sind nicht vorgesehen. Der Review behält die dauerhafte Main-Szene ohne Autoloads bei: Eine zusätzliche globale Instanz würde für dieselbe Lebensdauer einen weiteren Besitzer schaffen.

## 5. Projektordner

**TECHNISCHE EMPFEHLUNG:** Featurebezogene Ablage. Szene und zugehöriges Script liegen zusammen; keine parallelen globalen `scenes/`- und `scripts/`-Bäume.

```text
game/                              # späterer Godot-Projektroot / res://
├── project.godot                   # erst bei freigegebener Implementierung
├── app/                            # Main und SaveService
├── levels/vertical_slice/           # Slice-Szene, lokale Ablauf-/Zusammenbau-Logik
├── player/                         # Player, Interactor, Inventory, PlayerTuning
├── creature/                       # Kreatur und CreatureTuning
├── world/
│   ├── interactable.gd             # kleiner gemeinsamer Interaktionsvertrag
│   ├── door/
│   ├── switch/
│   ├── pickup/
│   ├── story/                      # Hinweise und räumliche Story-Trigger
│   ├── save_point/                 # ein Prefab für beide Speicherarten
│   └── traversal/                  # ausdrücklich erlaubte Kletterstellen
├── puzzles/                        # gemeinsamer Vertrag und zwei konkrete Logiken
├── items/                          # ItemDefinition und kleine .tres-Definitionen
├── ui/                             # eine UI-Szene mit Menüpaneelen
├── data/                           # Player-/Creature-Tuning, kurze Datentabellen
├── assets/                         # ausschließlich benötigte Runtime-Fassungen
│   ├── models/
│   ├── materials/
│   ├── textures/
│   └── audio/                      # SFX, Ambience, Musik; bei Bedarf Unterordner
├── debug/                          # kleine abschaltbare Entwicklungsansicht
└── tests/                          # eine technische Sandbox und Datentests
```

`source_assets/` und `licenses/` bleiben außerhalb von `game/`. Bearbeitbare Originale werden nicht pauschal von Godot importiert. Geeignete gemeinsam verwendete Materialien und Audiodateien liegen einmal unter `assets/`; kleine projektspezifische Definitionen bleiben bei ihrem Feature. Keine vorsorglichen Ordner für Netzwerk, Kampf, Crafting, Streaming oder Plugins.

Dateien und Ordner erhalten `snake_case`, benannte GDScript-Typen bei Bedarf `PascalCase`. Keine langen Vererbungsbäume und kein pauschales `class_name` für jedes Script. Physische Pfade sind keine persistenten Objektidentitäten.

## 6. Szenenarchitektur

| Szene | Lebensdauer / Besitzer | Aufgabe und Nodes | Lokale Daten / Ausgaben |
| --- | --- | --- | --- |
| `app/main.tscn` | Gesamte Anwendung | `Node`, WorldHost, GameUI; `main.gd` | Phase, aktuelle Laufgeneration, Todes-Snapshot, Einstellungen; aktiviert/entlädt Level, meldet Speicherergebnis |
| `levels/vertical_slice/vertical_slice.tscn` | Ein neuer Lauf oder Restore; Main | `Node3D`, Welt, Navigation, Akteure, Puzzle-Nodes; `vertical_slice.gd` | Lokales ID-Verzeichnis, Story-/Begegnungsfortschritt; aggregierter Snapshot, Abschluss-/Save-Anfragen |
| `player/player.tscn` | Levelinstanz | `CharacterBody3D`, Kamera, Kapsel, Interactor, Licht, Schrittaudio | Bewegung, Health, Inventory, Tempoeffekt; Zustands-, Todes-, Hinweis- und Geräuschmeldungen |
| `creature/creature.tscn` | Levelinstanz; zunächst ggf. inaktiv | `CharacterBody3D`, `NavigationAgent3D`, Sichtursprung, Audio | FSM, Wahrnehmungsgedächtnis, Route; Gefahrzustand, Geräuschdarstellung, geprüfte Schadensanfrage |
| `world/door/door.tscn` | Je Tür im Level | Interactable, bewegtes Kollisionsblatt, Animation, Audio; nur bei KI-relevantem Durchgang eine zugewiesene Linkreferenz | Verriegelungsquelle und Türstellung; Zustands-/Durchgangsmeldung |
| `world/switch/switch.tscn` | Je Schalter im Level | Interactable mit Trefferfläche und Darstellung | Bindung an Puzzle-Eingabe oder eigenständige Stellung; gültige Eingabe |
| `world/pickup/pickup.tscn` | Je Weltfund; bleibt auch eingesammelt als kleiner Zustandsanker vorhanden | Interactable, `Area3D`, Visuals | Itemdefinition, Menge, eingesammelt; Aufnahmeanfrage |
| `world/story/story_note.tscn` | Je lesbarem Hinweis | Interactable, Trefferfläche, Visuals | Hinweis-ID/Text; Öffnungsanfrage, kein eigener Fortschritt |
| `world/story/story_trigger.tscn` | Je räumlichem Auslöser | `Area3D` | Trigger-ID/Bedingung; Eintrittsmeldung, kein zweiter Einmalstatus |
| `world/save_point/save_point.tscn` | Je vorgesehenem Speicherpunkt | Interactable, Interaktionsfläche, Auslösebereich, Anker | Modus automatisch/manuell und geprüfte Ankerreferenzen; Save-Anfrage |
| `world/traversal/traversal_marker.tscn` | Je erlaubtem Hindernis | `Area3D`, Eintritts-/Ausstiegsmarker | Erlaubte geometrische Passage; Angebot an Player, kein eigener Positionsschreiber |
| `ui/game_ui.tscn` | Gesamte Anwendung; Main | `CanvasLayer`, Control-Paneele, UI-Audio | Ansicht/Fokus; keine Kopie des Spielfortschritts |

Main Menu, Pause Menu, Game Over und Slice-Ende sind zunächst Paneele derselben UI-Szene, keine vier Szenen mit vier Scripts. Checkpoint und manueller Speicherpunkt verwenden dasselbe Prefab mit explizitem Modus, aber verschiedene fachliche Save-Anlässe. Die zwei Puzzle-Nodes sind im Level eingebettet; separate Puzzle-Szenen entstehen erst, wenn tatsächlich Geometrie wiederverwendet wird.

### Aufbau, Pause und Abbau

Main führt die Phasen `MENU`, `PREPARING`, `PLAYING`, `PAUSED`, `GAME_OVER`, `COMPLETED`. `PREPARING` umfasst Neues Spiel und Restore, ohne eine zweite globale Zustandsmaschine. I/O besitzt zusätzlich nur einen exklusiven Belegtstatus. Main allein setzt `SceneTree.paused`: wahr in PAUSED/GAME_OVER/COMPLETED, falsch in MENU/PREPARING/PLAYING. Damit bleiben auch Weltanimationen und Timer nach Tod/Abschluss stehen; die weiterhin aktive UI bleibt bedienbar.

- **Neues Spiel:** alte Welt abbauen, Level inaktiv instanziieren, Referenzen prüfen, Anfangszustand/Anker anwenden, Physik und Navigation synchronisieren, Anfangs-Wiederanlauf kopieren, dann freigeben. Er ist ohne erfolgreichen Dateischreibvorgang noch kein dauerhafter Save.
- **Pause:** Main und UI verarbeiten weiter; WorldHost ist ausdrücklich `PROCESS_MODE_PAUSABLE`, nicht vom dauerhaft laufenden Main geerbtes `ALWAYS`. `SceneTree.paused` stoppt die Spielsimulation. Fokus/Maus werden angepasst.
- **Restore:** `SceneTree.paused` ist für die Aufbau-/Synchronisationsphase aufgehoben; Gameplay bleibt durch Aktivierungsflags gesperrt. Sonst würde die Wiederherstellung auf stillgelegte Physik warten. Auch Signalempfänger prüfen Phase/Laufgeneration: Pausierte Nodes können weiterhin Signals empfangen. Grundlage: [Godot 4.7 – Pause und Process Mode](https://docs.godotengine.org/en/4.7/tutorials/scripting/pausing_games.html).
- **Tod:** Player meldet genau einmal den Übergang zu tot. Main sperrt Gameplay und zeigt Game Over; Neustart verwendet den zu diesem Verlauf gehörenden Todes-Snapshot.
- **Abschluss:** Level meldet eine bestätigte Abschlussbedingung einmalig; Main zeigt den Abschlusszustand. Abschluss ist weder automatisch ein neuer Checkpoint noch eine erfundene Storysequenz.
- **Abbau:** Gameplay deaktivieren, externe Verbindungen lösen, UI-Ziele verwerfen, Level freigeben und dessen Freigabe abwarten. Erst dann neue Welt erzeugen. Die zu Beginn des Weltwechsels geänderte Laufgeneration entwertet verspätete Ergebnisse.

### Konkrete Besitz- und Aktivierungsgrenze

Main erzeugt/freigibt die Levelinstanz, erzeugt SaveService und bindet die dauerhafte UI. Player erzeugt sein Inventory. Levelobjekte einschließlich Player und Creature entstehen als Kinder der Levelszene und werden mit ihr freigegeben; weder UI noch SaveService erzeugen Weltobjekte. Ein Pickup wird beim Einsammeln nur deaktiviert. Godots Szenen-`owner` für das Speichern einer Szene ist dabei nicht mit der hier beschriebenen Laufzeitverantwortung zu verwechseln.

Main erteilt die Gameplayfreigabe über einen einzigen Level-Auftrag `set_gameplay_active`. Level reicht diesen beim Phasenwechsel an Akteure, Interaktionen und Trigger weiter; kein eigenes konkurrierendes Flow-Modell. Sperren bedeutet Verarbeitung unterbrechen, nicht fachliche Zustände zurücksetzen; Pause/Fortsetzen erhält etwa den KI-Zustand. Creature darf nur verarbeiten, wenn zusätzlich ihre Begegnungsfreigabe vorliegt. In PREPARING bleibt die Engine unpausiert, aber weder Bewegung, Sensoren, Schaden noch logische Interaktionen laufen. Animations-/Audio-Autostarts sind während des Aufbaus aus; physische Kollision und Navigationsregistrierung dürfen bereit werden. Die Freigabe ersetzt nicht die feinere Player-Eingabesicherung bei offenen Ansichten.

Main erhöht die Laufgeneration genau einmal pro Weltwechsel. Normale lokale, synchrone Aufrufe benötigen keine zusätzlichen Generationstoken. Nur über den Weltwechsel hinaus mögliche Fortsetzungen nach `await` oder verzögerte Aufträge prüfen die erfasste Generation sowie ihre noch gültige Zielinstanz. Ein reines „Node existiert noch“ genügt zwischen Sperren und Freigeben nicht.

## 7. Player

`player.gd` auf `CharacterBody3D` bleibt alleiniger Schreiber der Spielerposition, sowohl für normale Bewegung als auch Traversal und explizites Positionieren beim Restore. Es besitzt Blicksteuerung, Geschwindigkeit, Haltung, Lebenspunkte, Tempoeffekt und Taschenlampenschalter. `player_interactor.gd` übernimmt Zielwahl und Interaktionsprüfung; `inventory.gd` nur Bestandslogik. Das sind drei Verantwortungsbereiche, keine Komponentenkette für jede Bewegungsart.

### Motor und Kamera

- Bewegung und Kollisionsantwort laufen im Physiktakt über den CharacterBody-Motor. Eingaberichtung normalisieren; Beschleunigung, Bremsen, Sprint und Sprung aus PlayerTuning lesen. Keine festen Gameplayzahlen in der Architektur.
- Haltung `STANDING/CROUCHED` ist getrennt von Fortbewegung `GROUNDED/AIRBORNE/TRAVERSING`. Aufstehen verlangt eine Formprüfung im freien Raum. Die veränderliche Kollisionsform wird pro Instanz isoliert, nicht als gemeinsam veränderte Resource benutzt.
- Körper dreht horizontal, Head vertikal; Camera3D bleibt Kind von Head. Vertikale Blickgrenzen und Empfindlichkeit sind konfigurierbar. Animationen bewegen nicht den Player-Root. Sichtbare Körperteile und Kameraeffekte bleiben gestalterisch offen.
- Head-/Kollisionsübergänge dürfen Kamera und Interaktionsstrahl nicht durch Wände oder Decken schieben. Beim Spawn wird die Bewegungs-/Kamerahistorie zurückgesetzt.
- Schritte entstehen aus tatsächlich zurückgelegter Bodenbewegung, nicht nur aus gedrückten Tasten. Lauf-/Sprint-/Duck-Kontext und optionale Oberflächenkategorie bestimmen Audio und das separate KI-Geräuschereignis.

### Traversal im selben Motor

Ein expliziter TraversalMarker bietet eine erlaubte Passage an; kein automatisches Erkennen beliebiger Wände. Player prüft Reichweite, Eintritt, Platz für seine Körperform entlang des Weges und freien Ausstieg. Erst dann beginnt `TRAVERSING`. Auch dabei bleibt die Bewegung kollisionsgeprüft; keine ungeprüfte Positions-Tweenfahrt.

Bei blockiertem Start wird die Aktion abgelehnt. Eine nachträgliche Blockade stoppt den Motor an der letzten kollisionsfreien Lage und führt kontrolliert aus dem Traversalzustand zurück; kein Durchdrücken durch Geometrie. Tod bricht Traversal ab, Pause friert ihn ein, währenddessen wird nicht gespeichert. Marker und erlaubte Bewegungsgrenzen werden gemeinsam im Bewegungsprototyp validiert. Schwimmen, komplexes Greifen/Ziehen und Voll-Parkour erhalten keine vorsorglichen Systeme.

### Health und Tempo

Lebenspunkte, Lebenszustand, Trefferfreigabe und Effektrestzeit sind Player-Laufzustand. Schaden wird zentral am Player geprüft; tote/inaktive Spieler nehmen keine weiteren Treffer an. Der Übergang zu tot ist idempotent. Kreatur und Player verhindern doppelte Verarbeitung derselben Trefferaktion; die konkrete Trefferfrequenz, Heilung und Fallfolgen bleiben offen.

Tempo ist ein Faktor auf konfigurierte Bewegung, kein dauerhaft überschriebenes Basistempo. Verbrauch und Aktivierung erfolgen zusammen. Wiederholte Nutzung, Stapelung/Erneuerung und konkrete Wirkung bleiben offene Regeln. Restzeit verwendet pausierbare Gameplayzeit; Laden setzt die gespeicherte Restzeit genau einmal. Keine allgemeine Status-Effekt-Engine.

## 8. Input

Vorgesehene Input Actions: `move_forward`, `move_backward`, `move_left`, `move_right`, `jump`, `sprint`, `crouch`, `interact`, `flashlight`, `inventory`, `use_item`, `pause`. Konkrete Belegung, Halten/Umschalten und Itemauswahl bleiben abstimmbar. Mausbewegung liefert für First Person relative Blickdaten; später kann ein Controller dieselben fachlichen Bewegungs-/Blickaufträge speisen.

Player liest Bewegungsaktionen im Physiktakt nur bei Gameplayfreigabe. Einzelaktionen werden nach UI-Verarbeitung behandelt; ein UI-Klick darf nicht zugleich interagieren oder ein Item benutzen. Main besitzt Pause/Ansichtswechsel; Interactor behandelt `interact`; Player behandelt Bewegung, Licht und bestätigte Itemnutzung. UI verwendet Godots Fokusnavigation und konsumiert behandelte Eingaben.

Main gibt pro Phase Freigaben für Bewegung/Blick/Interaktion/Itemnutzung vor. Bei Tod, Restore und Abschluss sind Gameplayaktionen gesperrt. Beim Wechsel in Menüs werden Aktionspuffer verworfen, die Maus freigegeben und ein sinnvoller Control fokussiert; beim Fortsetzen wird sie wieder eingefangen. Kein aufgestauter Sprung oder Klick nach Laden. Ob Lesen/Inventar auch die Welt pausiert, bleibt offen; Eingabesicherheit gilt bei beiden Varianten. Es gibt keinen globalen InputManager und keine hardcodierten Tastencodes als Steuerungsmodell.

## 9. Interaktion

`interactable.gd` ist eine kleine `Node3D`-Basis für Türen, Schalter, Pickups, Notizen und Speicherpunkte. Gemeinsamer Vertrag:

| Operation | Bedeutung |
| --- | --- |
| `get_action_info` | Aktueller Text, Verfügbarkeit und ggf. Ablehnungsgrund; keine Zustandsänderung |
| `request_interaction` | Erneute lokale Prüfung und genau eine Aktion oder begründete Ablehnung |
| `persistent_id` | Stabile Weltidentität, nicht automatisch die Item-/Storydefinitions-ID |

Interactor verfolgt einen kurzen Kamera-RayCast mit ausdrücklich aktivierter Area-Erkennung und ausgeschlossener eigener Player-Kollision. Der Ray liegt unter Camera3D; `exclude_parent` allein ist deshalb kein verlässlicher Ausschluss des Player-Roots. Der nächste Treffer kann eine Wand sein; erst danach wird der Interactable-Vorfahre innerhalb desselben Levelobjekts aufgelöst. Beim Auslösen Entfernung, Sichtbarkeit, Zielinstanz und Aktivierung erneut prüfen. Nach Blickänderung nötigenfalls `force_raycast_update` verwenden, statt den zwischengespeicherten Treffer des letzten Physiktakts zu übernehmen. [Godot 4.7 – RayCast3D](https://docs.godotengine.org/en/4.7/classes/class_raycast3d.html)

Das Objekt führt lokale Logik aus oder meldet eine typisierte Anfrage an das Level. Es erhält nicht pauschal Zugriff auf Main, SaveService oder die komplette Player-Instanz. Zunächst nur eine primäre Aktion pro Ziel, kein universelles System für Aktionslisten und mehrstufige Fähigkeiten.

**TECHNISCHE EMPFEHLUNG – Kollisionskonvention:** Benannte 3D-Layer `WorldSolid`, `Player`, `Creature`, `Interactable`, `Trigger`. Feste Türen zählen zu WorldSolid und Interactable; Pickup-Hitflächen zu Interactable; Eintrittsbereiche zu Trigger. Interaktionsqueries berücksichtigen WorldSolid und Interactable, Sichtqueries die verdeckende Welt und den Spieler, Trigger nur passende Akteure. Bewegungsabfragen bleiben von Interaktionsabfragen getrennt. Die Masken werden in der ersten Testwelt geprüft; zusätzliche Layer erst bei konkretem Bedarf.

## 10. Türen

Door besitzt die tatsächliche Stellung `CLOSED/OPENING/OPEN/CLOSING`. Verriegelung ist davon getrennt: Eine entriegelte Tür kann geschlossen sein. Ein Puzzle gibt einen Zugang frei, nicht automatisch die Animation oder Position des Türblatts. Ob eine bestimmte Freigabe zusätzlich Öffnen anfordert, bestimmt erst die bestätigte Rätselregel.

Verriegelung hat pro Tür genau eine maßgebliche Quelle: lokaler unabhängiger Zustand **oder** abgeleitete Freigabe eines gebundenen Puzzles. Mehrere konkurrierende Schreiber werden beim Levelaufbau abgelehnt. Puzzleabhängige Verriegelung wird nicht zusätzlich als unabhängiger Save-Wert gespeichert; die stabile Türstellung schon.

**TECHNISCHE EMPFEHLUNG, im Review beibehalten:** Kontrolliertes Türblatt mit `AnimatableBody3D`, Kollisionsform und Visuals; `AnimationPlayer` bewegt dieses Blatt im Physikmodus mit `sync_to_physics`, keine freie `RigidBody3D`-Tür. Kein zusätzliches `move_and_collide` auf demselben Türblatt. Door autorisiert Übergänge und setzt beim Restore die bestätigte Endstellung, ohne die Animation abzuspielen. Das ist für eine sichtbare bewegte Kollision passender als ein nur springend versetzter StaticBody. [Godot 4.7 – AnimatableBody3D](https://docs.godotengine.org/en/4.7/classes/class_animatablebody3d.html)

Ein Durchgangs-/Schwenkbereich prüft Player und Kreatur. Empfehlung: Schließen bei Belegung ablehnen; bei neu eintretender Blockade während des Schließens stoppen und sicher wieder öffnen, nicht quetschen. Diese Blockadereaktion ist eine technische Empfehlung, keine neue Schadensregel; ihre konkrete Darstellung wird im Türprototyp bestätigt.

Nicht jede Door-Instanz erhält Navigationslogik: Ein Link wird nur für einen tatsächlich zustandsabhängigen Kreaturendurchgang im Level zugewiesen (§17). Dann gilt: Link vor dem Schließen deaktivieren, erst bei vollständig offener physisch passierbarer Tür aktivieren und den aktiven Kreaturenweg nach Map-Synchronisation neu bewerten. Das Navmesh muss dort unterbrochen sein; Türkollision allein sperrt keine Route. Die offene Blattstellung darf auch keinen benachbarten gebackenen Weg blockieren. Übergänge sind keine zulässigen Save-Zustände; Restore spielt keine alte Öffnungsanimation samt Sound nach.

## 11. Inventar / Items

`item_definition.gd` definiert eine statische Resource: `item_id`, Anzeigename, Kategorie, Darstellungsreferenzen, Stapelbarkeit/Stackgrenze, Kennzeichnung kritischer Gegenstände und ggf. Tempoeffektparameter. Gemeinsame Definitionen enthalten weder aktuellen Bestand noch „eingesammelt“. Keine Assetauswahl durch diese Felder.

`inventory.gd` ist ein vom Player besessenes `RefCounted`-Objekt mit Bestandsdaten und kleinem Vertrag: Aufnahme prüfen/ausführen, Verfügbarkeit prüfen, bestätigten Verbrauch ausführen, Zustand ausgeben/anwenden. Item-IDs verweisen auf bekannte Definitionen. Slotzahl, Bedienung, Stapelregeln und Schutz kritischer Items müssen vor verbindlicher Bestandslogik bestätigt werden. Kein Raster-, Ausrüstungs- oder Gewichtssystem als Voraussetzung.

Aufnahmeablauf: Pickup meldet Anfrage → Level prüft aktive Phase, noch vorhandenen Fund und Inventory-Aufnahmemöglichkeit → Bestand und Fundstatus werden synchron ohne `await` gemeinsam geändert → erst anschließend UI/Audio benachrichtigen. Bei Ablehnung bleibt der Weltfund vorhanden. Pickup bleibt als versteckter, nicht interaktiver Zustandsanker instanziiert; seine kleinen Metadaten erlauben Restore, ohne zerstörte Objekte anhand von Scriptpfaden neu zu erzeugen.

Itemnutzung wird nach Kategorie explizit behandelt. Player bestätigt die Nutzung eigener Werkzeuge/Tempo-Items mit seinem Inventory direkt; Level ist dafür kein Durchleiter. Nur bei einem Vorgang über mehrere Besitzer – etwa Inventory und Puzzle – koordiniert Level die vorgeprüfte gemeinsame Änderung. Eingesetzte kritische Gegenstände werden am Puzzle vermerkt und sind nicht zugleich frei verfügbar. Fehlversuche verbrauchen keine notwendigen Gegenstände ohne bestätigte, lösbare Rücksetzregel.

„Ohne await“ allein garantiert keine ungestörte Änderung: Auch synchrone Signals könnten einen weiteren Auftrag auslösen. Deshalb senden die beteiligten Änderungsmethoden erst nach Abschluss aller Teiländerungen ihre Ergebnisrückmeldung. Bis dahin verhindert eine lokale Wiedereintrittssperre eine zweite Interaktion/Snapshotaufnahme. Keine Datenbanktransaktion, nur ein kurzer klarer Änderungsabschnitt.

**NOCH OFFEN:** Konkrete Schutzregel bei vollem Inventar. Bis zur Entscheidung keine Abwurffunktion oder Verlustmechanik als Standard implementieren. Der Pflichtfluchtweg muss auch ohne verbleibendes Tempo-Item funktionieren.

## 12. Taschenlampe

Kein eigenes Flashlight-Script. Player besitzt den Ein-/Aus-Zustand und steuert einen `SpotLight3D` an der First-Person-Kamera. Verfügbarkeit ergibt sich aus dem Inventar, nicht aus einem zweiten Besitzflag. Ungültige Kombinationen wie eingeschaltet ohne verfügbares Werkzeug werden im Snapshot abgelehnt.

Konfigurierte Reichweite, Lichtkegel, Helligkeit und Schatten werden nach Rendererentscheidung auf Lesbarkeit und Kosten geprüft. Ein-/Ausschalten ist eine Player-Aktion mit Audio-/UI-Rückmeldung. Beim Restore wird direkt der gespeicherte Zustand hergestellt. Batterieverbrauch ist kein Pflichtsystem und wird nicht vorsorglich implementiert; späterer Ressourcenverbrauch kann an diese kleine Zustandsgrenze anschließen.

## 13. Rätsel

`puzzle.gd` ist ein kleiner gemeinsamer `Node`-Vertrag; `puzzle_a.gd` und `puzzle_b.gd` enthalten später jeweils die eigene bestätigte Logik. A/B sind technische Platzhalter, keine Festlegung der beiden Rätsel. Kein Graph-Editor, Regelinterpreter oder universelles Puzzleframework.

| Vertrag | Zuständigkeit |
| --- | --- |
| Stabile Puzzle-ID | Zuordnung von Eingaben, Save und Debug |
| Eingabe prüfen / anwenden | Prüft Voraussetzung und erlaubten Zustandswechsel; Änderung ohne Unterbrechung |
| Zustand lesen | Teilfortschritt, eingesetzte Gegenstände, Lösungsstatus für Darstellung/Progress |
| Snapshot prüfen / anwenden | Nur eigene Daten prüfen; ohne Belohnungen oder Live-Interaktionen wiederherstellen |
| Abgeleitete Ausgaben herstellen | Zugeordnete Türfreigaben und Schalterdarstellung aus maßgeblichem Zustand erzeugen |
| Debug Reset | Definierter Test-Ausgangszustand einschließlich abhängiger Item-/Türdaten über Level-Koordination |

Ein gebundener Schalter meldet eine Eingabe an sein Puzzle und liest die Darstellung daraus. Er speichert nicht denselben Teilzustand ein zweites Mal. Ein wirklich eigenständiger Schalter darf eine eigene Stellung besitzen; Bindungsmodus und Zustandsbesitzer müssen eindeutig sein. Puzzle hält direkte Referenzen auf seine Ausgangstüren. Door kennt das Puzzle nicht zurück; sie empfängt nur die gültige Freigabe.

Der Lösungsstatus wird möglichst aus den gespeicherten Teilzuständen abgeleitet. Falls eine bestätigte Regel eine unumkehrbare Lösung benötigt, wird diese als eigener historischer Zustand gespeichert und gemeinsam validiert. Kein grundsätzliches, widersprüchliches zweites `solved`-Flag. Debug Reset ist nicht automatisch eine vom Spieler verfügbare Resetaktion; die spielerische Rücksetzbarkeit und Fehlerkorrektur werden je Rätselregel festgelegt. Ein Reset mit eingesetzten Gegenständen darf diese nicht vernichten oder duplizieren.

## 14. Story / Progress

`vertical_slice.gd` besitzt wenige Mengen/Flags für gefundene und gelesene Hinweis-IDs, ausgelöste Einmalereignisse, bestätigte Storymarkierungen, Begegnungsfreigaben und Slice-Abschluss. StoryNote und StoryTrigger sind Melder, keine konkurrierenden Fortschrittsspeicher.

Gefunden und gelesen werden getrennt modelliert. Welches Ereignis „gelesen“ bestätigt, ist eine noch festzulegende Bedienregel; bloßer Bereichseintritt muss es nicht sein. Storybedingungen dürfen Puzzle-Zustände abfragen, speichern deren Lösung aber nicht nochmals als eigene Wahrheit. Ereignishistorie nur für tatsächlich benötigte Einmaligkeit, kein beliebig wachsendes Aktionsprotokoll.

Level verarbeitet erfüllte Bedingungen und meldet Textdarstellung, Begegnungsfreigabe oder Abschluss an zuständige Empfänger. Restore setzt Daten still und stellt daraus den gültigen Zustand her; es simuliert nicht erneut den Durchlauf durch Trigger. Einmalige Enthüllung und Slice-Abschluss erhalten getrennte fachliche Markierungen, sobald deren Inhalte bestätigt sind. Keine Quest-Engine, Dialogmaschine oder Sprachausgabe. Texte können zunächst als kleine exportierte Daten an Hinweisen liegen; Storyinhalt wird hier nicht erfunden.

## 15. Creature AI

`creature.gd` auf `CharacterBody3D` enthält **eine explizite endliche Zustandsmaschine**. Zustandswechsel, Wahrnehmung, begrenztes Gedächtnis und Navigation sind klar getrennte Methodenbereiche desselben Scripts, keine Scriptdatei pro Zustand. `creature_tuning.gd` enthält nur Konfiguration. Level aktiviert die eine Kreatur anhand des freigegebenen Begegnungsfortschritts.

| Zustand | Gültige Ziele und Verhalten | Wesentliche Ausgänge |
| --- | --- | --- |
| Patrol | Vom Level zugewiesene Patrouillenmarker | Gültiges Geräusch → Investigate; Sicht → Chase |
| Investigate | Eingefrorener Ort eines akzeptierten Geräuschereignisses | Sicht → Chase; untersuchter/unerreichbarer Ort oder begrenzte Dauer → Search bzw. Return nach bestätigter Regel |
| Chase | Aktuell bestätigte Sichtposition; nach Sichtverlust nur letzter bekannter Ort | Sichtverlust → Search; Tod/Deaktivierung beendet Verhalten |
| Search | Begrenzte Suchpunkte um die letzte gültige Wahrnehmung, nicht um die verborgene aktuelle Spielerposition | Sicht → Chase; abgeschlossene/abgebrochene Suche → Return |
| Return | Erreichbarer zugewiesener Patrouillenmarker | Erreicht → Patrol; neuer gültiger Reiz → Untersuchung/Verfolgung |

Die Zuordnung innerhalb der genannten Übergänge wird konfigurierbar und im KI-Prototyp abgestimmt; keine endgültigen Suchzeiten oder Reichweiten. Eintritt/Austritt jedes Zustands setzt relevante Timer/Ziele explizit. Wiederholte unveränderte Reize dürfen Suche und Untersuchung nicht endlos verlängern. Ein Abschlussgrund wird für Debug festgehalten.

Chase-/Search-Status für Musik und Warnrückmeldung ist eine Ausgabe dieser FSM, kein zweiter ChaseManager. „Entkommen“ folgt erst der bestätigten Aufgabe der Suche, nicht bereits einem verdeckten Sichtstrahl. Skriptinszenierungen dürfen Startbedingungen setzen, ersetzen aber nicht die wahrnehmungsbasierte Verfolgung.

Die Kreatur besitzt keinen Zugriff auf SaveService, Inventar oder die komplette Weltregistrierung. Sie erhält Player als Wahrnehmungskandidat, Patrouillen-/Suchmarker und zulässige Aktivierung. Nur die Sicht-/Trefferprüfung darf die aktuelle Spielerposition prüfen; Zielsteuerung verwendet bestätigte Beobachtungen. Eine Trefferanfrage braucht gültige Reichweite, freie Trefferlinie und eine neue zulässige Trefferaktion. Danach ruft Creature den vorhandenen Player-Vertrag `apply_damage` direkt auf; ein zusätzlicher Umweg über Level bietet keinen Nutzen. Player bestätigt oder verwirft den Auftrag anhand seiner Health-/Aktivierungsregel. Die konkrete Schadensregel bleibt offen; kein allgemeines Kampfsystem.

Tod, Levelabbau und Restore beenden alte Ziele, Sensorergebnisse und Schadensfreigaben. Kreaturenanker und Ausgangsverhalten nach Laden werden erst mit der offenen Reset-Politik verbindlich (§19, §34).

## 16. Wahrnehmung / Noise

### Sicht

Creature prüft konfigurierbare Entfernung und Blickwinkel, danach eine Physik-Sichtlinie vom `VisionOrigin` zu vorgesehenen Spielerzielpunkten. Undurchsichtige Weltgeometrie und geschlossene Türen verdecken. Anzahl/Zielpunkte und Prüfintervall sind Tuning, keine neue Körperteil-Simulation. Sichtprüfungen dürfen seltener als Bewegung laufen, ohne die Steuerung an die Bildrate zu binden.

Ergebnis ist eine bestätigte Beobachtung mit Position und Zeitpunkt. Nach Sichtverlust bleibt die letzte bekannte Position unverändert, bis eine neue zulässige Wahrnehmung vorliegt. Ein Player-Verweis ist keine Erlaubnis, in Search weiterhin seine Position zu lesen.

### Geräusche

**Hörbares Audio für Menschen und KI-Geräuschereignisse sind ausdrücklich verschieden.** Eine Schrittaktion kann beides auslösen. Lautstärkeregler, fehlende Audiodatei oder stummgeschaltete Lautsprecher verändern nicht die KI-Regeln. Die KI analysiert keine Audiodateien.

**Review-Vereinfachung:** Für fünf übergebene Werte ist keine eigene `noise_event.gd` nötig. Ein lokales Signal mit festen typisierten Parametern genügt; Creature kopiert nur den tatsächlich akzeptierten Reiz in ihr Wahrnehmungsgedächtnis. Kein veränderlich geteiltes Ereignisobjekt:

| Feld | Inhalt |
| --- | --- |
| Quelle | Stabile Akteur-/Objekt-ID, keine dauerhaft gehaltene Node-Referenz |
| Position | Weltposition zum Ereigniszeitpunkt, nicht später nachgeführte Quellposition |
| Intensität | Konfigurierter fachlicher Wert, nicht die Audio-Buslautstärke |
| Typ | Bestätigte Aktionskategorie, etwa Schritt oder Türaktion |
| Zeitpunkt | Monotoner Erfassungszeitpunkt zur Reihenfolge/Diagnose, nicht für Such- oder Effektzeit; diese verwenden pausierbare lokale Timer |

Level verbindet die Noise-Signals der vorgesehenen Quellen beim Aufbau direkt mit Creature; es verarbeitet nicht jeden Schritt selbst. Die synchrone Verbindung bleibt innerhalb derselben Levelinstanz. Inaktive/pausierte Quellen erzeugen keine neuen Gameplayreize, der Empfänger prüft ebenfalls seine Freigabe. Keine globale Queue, eigene Ereignisnummerierung oder Laufgeneration pro Schallereignis. Bei einem später wirklich verzögerten Reiz greift die allgemeine Lebensdauerregel aus §6.

Creature filtert Quellen und Typen, prüft Reichweite/Intensität und ggf. die später bestätigte einfache Dämpfungsregel. Eigene Kreaturentöne, UI und rein dekorative Ambience sind standardmäßig keine Suchauslöser; zusätzliche Quellen werden bewusst angeschlossen. Hörbarkeit durch Wände/Türen bleibt eine zu testende Wahrnehmungsregel, keine vollständige Akustiksimulation.

## 17. Navigation

**TECHNISCHE EMPFEHLUNG:** Statisch vorbereitete `NavigationRegion3D`-Flächen und ein `NavigationAgent3D` unter Creature. Creature bewegt ihren CharacterBody selbst kollisionsgeprüft; Agent liefert den Weg. Kein permanentes Navmesh-Rebake und zunächst keine Agent-Avoidance.

Der Agent wird erst nach bestätigter Map-Synchronisation abgefragt. Während einer aktiven Route wird die nächste Wegposition im Physiktakt verarbeitet; neue Ziele werden nur bei relevant geändertem Ziel oder ungültiger Route gesetzt, nicht pauschal pro Frame. Ein leerer Weg vor Bereitschaft ist kein Beweis für Unerreichbarkeit. [Godot 4.7 – NavigationAgents](https://docs.godotengine.org/en/4.7/tutorials/navigation/navigation_using_navigationagents.html)

### Reviewentscheidung: nur notwendige Durchgänge dynamisch koppeln

Der Ansatz Navmesh-Lücke + schaltbarer Link + physische Kollision bleibt für **tatsächlich dynamische Kreaturendurchgänge** bestehen. Er wird nicht länger in jedes Door-Prefab eingebaut. Das Level weist nur den betroffenen Türen eine Linkreferenz zu; Links liegen im statischen Navigation-Zweig. Es entsteht dafür weder ein neues Script noch ein weiterer Prefabtyp.

| Variante | Bewertung für 0.1 |
| --- | --- |
| Unveränderlicher Kreaturenweg / Tür ohne Einfluss auf begehbare KI-Flächen | Kein dynamischer Navigationsbaustein nötig. Gilt nur, wenn Türöffnung, Blattbewegung und alle bestätigten Spielzustände diese Eigenschaft tatsächlich erhalten. |
| Navmesh-Lücke + schaltbarer NavigationLink3D | Bevorzugter Startansatz für die wenigen nachweislich nötigen dynamischen Verbindungen; explizit sperrbar und ohne Rebake testbar. |
| Kleine schaltbare Brücken-Region | Mögliche lokale Alternative bei nachgewiesenem Linkproblem, aber nicht pauschal einfacher: zusätzliche Mesh-/Kantenverbindungen und dieselbe Synchronisationspflicht. NavigationRegion3D ist ebenfalls als experimentell markiert. |
| Nur Türkollision oder Avoidance | Kein Ersatz für gesperrte Wegsuche; die Kreatur würde weiterhin einen unpassierbaren Weg erhalten. Verworfen. |
| Eigenes Wegpunkt-/Türgraphsystem oder wiederholtes Rebake | Für eine Kreatur zusätzlicher Pflege-/Implementierungsaufwand ohne belegten Nutzen. Verworfen. |

Die Experimentell-Markierung allein beweist weder Untauglichkeit des Links noch Stabilität einer Region-Alternative. Die offizielle Dokumentation beschreibt beide Bausteine und die Kantenverbindung; ihre zuverlässige Verwendung in diesem Projekt muss der frühe Test nachweisen. [Godot 4.7 – NavigationRegion3D](https://docs.godotengine.org/en/4.7/classes/class_navigationregion3d.html)

**Scope-Grenze:** Hier werden keine konkreten Türen als für die Kreatur unzugänglich erklärt und keine Fluchtwege geändert. Der spätere bestätigte Levelentwurf bestimmt, welche Verbindungen relevant sind. Eine schließbare Tür auf einer möglichen Kreaturenroute darf niemals nur zur Vereinfachung als statisch passierbar behandelt werden. Die Klassifikation muss vor der Navigationsabnahme geprüft sein.

### Kontrollierter dynamischer Türdurchgang

1. Navmesh-Flächen vor/hinter der Tür haben eine echte Lücke am Durchgang. Automatische Kantenverbindung oder überlappende Regionen dürfen diese Lücke nicht unbemerkt überbrücken.
2. Genau ein zugeordneter `NavigationLink3D` verbindet dort die begehbaren Seiten. Er bezeichnet eine Route über physisch vorhandenen Boden, keinen Teleport und keine Sprunganimation.
3. Door aktiviert den Link nur bei sicher passierbarer offener Stellung. Navigation berücksichtigt deaktivierte Links nicht als neue Route; Endpunktabstände und Verbindungsradius müssen zur gebackenen Geometrie passen. [Godot 4.7 – NavigationLink3D](https://docs.godotengine.org/en/4.7/classes/class_navigationlink3d.html)
4. Level verbindet die Durchgangsmeldung beim Aufbau direkt mit Creature. Bei Änderung eines dynamischen Durchgangs ihren aktiven Weg invalidieren; nach Map-Synchronisation neu planen. Für eine Kreatur lohnt keine zusätzliche Analyse, welche Route genau betroffen ist. Ein schon berechneter Weg wird nicht blind weitergelaufen.
5. Durchgangsbelegung verhindert das Einschließen eines Akteurs beim Schließen (§10). Körperradius, Navmesh-Abstand und Türbreite werden gemeinsam getestet.

NavigationLink3D und die übrigen eingesetzten Navigationsbausteine müssen auf der festgelegten Engineversion getestet werden. Ein Link-/Region-Propertywechsel bedeutet nicht sofort eine aktualisierte Server-Map; insbesondere nicht auf ein Map-Signal warten, das bereits vor Beginn des Wartens eingetroffen sein kann. Nach bestätigter Server-Synchronisation aktuellen Zustand prüfen und begrenzt abbrechen, falls Bereitschaft ausbleibt. Der Türtest umfasst offene/geschlossene Stellung, Schließen auf vorhandenem Weg und Restore beider Zustände. Erst ein konkretes Testergebnis begründet den Wechsel zur lokalen Alternative; nicht beide Varianten vorsorglich implementieren.

Ein sichtbarer, aber legal unerreichbarer Spieler ist von defekter Navigation zu unterscheiden. Creature versucht nur begrenzt erneut zu planen und verwendet anschließend einen nachvollziehbaren Such-/Rückkehr-Ausgang. Bei beschädigter Navigation diagnostizierbar sicher stoppen, nicht durch Wände bewegen oder an den Spieler teleportieren. Verpflichtende Flucht-/Kletterwege brauchen einen bestätigten Umgang mit solchen Erreichbarkeitsgrenzen; weder Gegnerparkour noch Türöffnung durch die Kreatur werden hier erfunden.

## 18. Audio

Audioquellen bleiben bei ihren Verursachern: Player-Schritte, Kreatur, Türen und Schalter verwenden lokale `AudioStreamPlayer3D`. Räumliche Umgebungsquellen gehören ins Level. Level besitzt zusätzlich wenige Ambience-/Musikplayer; UI besitzt einen nicht räumlichen UI-Player. Keine Autoload-Audiobibliothek, kein Pool und keine Musik-State-Machine für 0.1.

Vorgeschlagene Busse: `Master`, `SFX`, `Ambience`, `Music`, `UI`. Main wendet Nutzereinstellungen auf die Busse an. Lautstärken bleiben getrennt von Saves. Oberflächenkennung am kollidierten Boden kann die Schrittauswahl beeinflussen; Kategorien und Varianten werden erst mit dem Audio-Workflow festgelegt. Zunächst reichen exportierte Stream-/Variantenlisten, kein eigener AudioResource-Typ.

Creature-Zustandsmeldungen erlauben Level einfache Übergänge zwischen bestätigten Atmosphären-/Gefahrkontexten. Audio entscheidet weder über Sichtung noch Entkommen. Gleichzeitige Loops und Übergänge begrenzen; beim Restore alte Stimmen stoppen und nur die zum wiederhergestellten Zustand passenden Schleifen neu beginnen. Kein erneutes Abspielen historischer Türaktionen oder Enthüllungssounds. Pauseverhalten folgt der Welt; UI-Audio bleibt bedienbar. Fehlende dekorative Dateien werden diagnostiziert; fehlende unverzichtbare Warnsignale blockieren die Abnahme.

## 19. Save / Restore

### 19.1 Zuständigkeiten und sichere Grenzen

Main besitzt den aktuellen Todes-Wiederanlauf als reine Datenkopie und die exklusive Save-/Restore-Koordination. Nur Main darf SaveService zum Schreiben/Laden aufrufen; UI, Speicherpunkte und Debug melden lediglich Wünsche. Level prüft Weltstabilität und sammelt Zustände; jeder Zustandsbesitzer prüft/separiert seine Daten. `save_service.gd` übernimmt Schema-Prüfung, JSON und Datei-I/O. SaveService kennt keine Nodes und entscheidet nicht, wann die Kreatur gefährlich oder ein Rätsel gelöst ist.

Ein SavePoint meldet entweder automatischen Eintritt oder manuelle Interaktion mit seiner stabilen ID. Main/Level prüfen: freigegebene Spielphase, lebender Spieler, vorgesehener Speicherbereich, zulässige Bedrohungslage, gültiger Wiederanlauf, kein Traversal, keine Türbewegung, kein unvollständiger Item-/Puzzle-/Storyübergang. Eine stabile Pose benötigt geprüfte Boden-/Körperfreiheit; bloßer Eintritt in eine Area während Sprung oder Fall genügt nicht. Aktive Verfolgung ist ausgeschlossen. Die Zulässigkeit während Search und genaue sichere Stellen bleiben offen. Eine Anfrage wird sichtbar angenommen oder begründet abgelehnt; keine unsichtbare, unbegrenzt verzögerte Speicherung an einem späteren Ort.

**NOCH OFFEN – Implementierungsschranke:** Gegner-Resetpolitik, Zulässigkeit bestimmter Suchzustände, manuelle Speicherung als neuer Todes-Checkpoint sowie Bestätigung der empfohlenen Checkpoint-Aktivierung erst nach Schreib-Erfolg. Diese Fragen sind nicht durch das folgende Schema entschieden. Das Schema bietet die nötige Zuordnung; produktives Saveverhalten darf nicht mit einer stillen Standardregel starten.

### 19.2 Speicherpaket

Vorgeschlagene Datenstruktur, keine Codeimplementierung:

```text
SaveEnvelope
├── schema_version: Ganzzahl (erster technischer Schemastand: 1)
├── content_revision: Kennung der kompatiblen Inhaltsfassung
├── run_id: Herkunft des Spielverlaufs
├── save_kind: auto | manual
├── current: Snapshot
└── restart: null (= current ist Todes-Wiederanlauf) oder vollständiger Snapshot
             keine weitere SaveEnvelope und keine Verweiskette

Snapshot
├── level_id, anchor_id, save_point_id (beim Anfangszustand null)
├── player
│   ├── position: [x, y, z] im lokalen Koordinatensystem des Levels
│   ├── yaw, pitch, stance, health
│   ├── inventory: [{item_id, quantity}], ggf. bestätigte relevante Auswahl
│   ├── flashlight_on
│   └── speed_effect: null oder {effect_id, remaining_gameplay_seconds}
├── objects: Objekt-ID → {kind, state}
├── puzzles: Puzzle-ID → rätselspezifischer geprüfter Teil-/Folgezustand
├── progress: Hinweis-/Trigger-ID-Mengen und bestätigte Fortschrittsmarkierungen
└── encounter: Begegnungsfreigabe, unumkehrbarer Fortschritt,
              Wiederanlaufanker/-regel nach noch zu bestätigender Resetpolitik
```

`run_id` bleibt beim Laden desselben Verlaufs erhalten. Die **Laufgeneration** für flüchtige Callbacks wird dagegen bei jedem Weltwechsel neu gesetzt und nicht aus dem Save übernommen. Es werden keine Objektzeiger, NodePaths, Scriptpfade, Ressourceninstanznummern oder frei zu instanzierenden Dateinamen gespeichert. `level_id` wird ausschließlich über eine bekannte Main-Zuordnung auf die erlaubte Levelszene abgebildet.

Wenn aktueller Stand und Todes-Wiederanlauf identisch sind, ist `restart` ausdrücklich `null`; ein fehlendes Feld gilt dagegen als ungültig. Andernfalls enthält es einen vollständigen zweiten Snapshot. Ein manueller Save bleibt so nach Überschreiben späterer Autosaves eigenständig. Die offene manuelle Checkpointregel bestimmt, ob der bisherige Wiederanlauf eingebettet oder der aktuelle Stand zum Wiederanlauf erklärt wird; keine stille Standardauswahl.

**Reviewentscheidung:** SaveEnvelope, Snapshot und optional eingebetteter Wiederanlauf bleiben die kleinste eigenständige Lösung, sind aber lediglich Datenstrukturen, keine weiteren Scriptklassen. Das redundante `restart_mode` entfällt. Eine `record_revision` entfällt ebenfalls: Exklusive serielle I/O benötigt keine Versionsfolge für konkurrierende Schreibvorgänge. Schema-/Inhaltsversion und Laufzuordnung bleiben erhalten. Maximal zwei Snapshots pro Paket, eine technische Backupkopie, keine Historienverwaltung.

### 19.3 Persistenzbesitzer

| Quelle | Gespeicherte maßgebliche Daten | Nicht zusätzlich speichern / neu aufbauen |
| --- | --- | --- |
| Player einschließlich Inventory | Pose, gültige Haltung, Health, Bestand, relevante Auswahl, Lichtzustand, Effektrestzeit | Besitz der Lampe aus Bestand; lebendig/verletzt aus Health-Regel; Geschwindigkeit und Eingaben neu |
| Pickup | Eingesammelt und ggf. bestätigte Fundmenge; ID pro Weltinstanz | Sichtbarkeit/Interaktionsfreigabe daraus ableiten |
| Puzzle A/B | Teilzustand, eingesetzte Items, notwendiger unumkehrbarer Fortschritt | Gebundene Schalter und Türfreigaben daraus ableiten |
| Door | Stabile Stellung, nur eigenständige Verriegelung | Bewegungsphase, Animation, NavigationLinkstatus nicht separat persistieren |
| Eigenständiger Switch | Seine Stellung, sofern nicht Puzzlebesitz | Keine zweite Kopie puzzleabhängiger Eingaben |
| Level | Story-/Einmalflags, bestätigte Weltänderungen und Begegnungsfortschritt | Kein zweiter Puzzle-Lösungsstand |
| Creature / Level gemeinsam nach klarer Teilzuständigkeit | Level: Begegnungsfreigabe; Creature: nur Daten der bestätigten Wiederanlaufregel | Keine doppelte Aktivierungswahrheit; Reset von FSM/Wahrnehmung nur nach Freigabe |

Notes, Trigger und SavePoints besitzen IDs, benötigen aber nicht automatisch eigene dynamische Save-Datensätze. Ihre ggf. relevanten Einmalmarkierungen gehören zu Progress. Statische Levelanker bleiben versionierte Konfiguration. Die Begegnungsdaten des Levels werden genau einmal unter `encounter` abgelegt, nicht zusätzlich unter `progress`. `anchor_id` bezeichnet den geprüften Wiederanlaufbezug; die gespeicherte Playerpose muss innerhalb seiner bestätigten sicheren Bedingungen liegen. Der Anfangs-Wiederanlauf besitzt ebenfalls einen stabilen Anker, benötigt aber keinen zuvor benutzten SavePoint.

**TECHNISCHE EMPFEHLUNG – noch zu bestätigen:** Für sichere Speicherstellen Creature an einem zugehörigen geprüften Anker mit festgelegtem Anfangsverhalten initialisieren. Spielerpose, Türen, Sichtlinie und Fluchtmöglichkeit müssen dazu passen. Erst mit dieser Freigabe dürfen alte Sichtungen, Geräusche, Suchzeit und Pfad verworfen werden. Ein bloßes „nicht in Chase“ beweist keine sichere Situation. Wird später eine andere Politik gewählt, ist das Encounter-Schema vor Implementierung entsprechend zu erweitern, nicht ein beliebiger Live-KI-Zustand unvollständig zu sichern.

### 19.4 Serialisierung und Prüfung

Snapshotkopien bestehen aus tief kopierten Dictionaries, Arrays und JSON-Grundtypen. Auch beim Anwenden werden veränderliche Daten in eigene Laufzeitcontainer übernommen: Eine spätere Inventaränderung darf niemals den im Main behaltenen Todes-Snapshot verändern. Vektoren werden ausdrücklich als Zahlenarrays, IDs als Strings kodiert. JSON-Zahlen werden auf Endlichkeit, Grenzen und bei Zählwerten auf Ganzzahligkeit geprüft; keine implizite Typannahme nach dem Parsen. Größen-/Verschachtelungsgrenzen schützen vor kaputten Dateien. Die JSON-API stellt Serialisierung bereit, ersetzt aber nicht diese fachliche Validierung. [Godot 4.7 – JSON](https://docs.godotengine.org/en/4.7/classes/class_json.html)

SaveService prüft Version, Struktur und Typen. Main prüft bekannte Level-/Itemdefinitionen; Level prüft konkrete Objekt-IDs, Arten, Beziehungen und Zustandskombinationen nach Aufbau. Pflichtfelder, unbekannte Pflicht-IDs oder widersprüchliche Besitz-/Puzzlebeziehungen führen zur Ablehnung, nicht zu einem teilweise gefüllten Spielstand. Geladene Daten werden nie als Resource oder Script ausgeführt. Erst ausdrücklich unterstützte Schema-/Inhaltsfassungen akzeptieren; ein einzelner späterer Versionswechsel erhält bei Bedarf eine gezielte Konvertierung, kein Migrationsframework.

### 19.5 Dateiverfahren und Checkpoint-Bestätigung

Technischer Pfadvorschlag: `user://saves/<record_id>.json`, daneben temporäre Datei und letzte gültige Sicherung `.bak`; separate Einstellungen in `user://settings.cfg`. Datensatz-IDs werden intern aus einer erlaubten Zeichenmenge erzeugt, nie als beliebige Pfade aus Save-Inhalt übernommen. Dies definiert **keine Anzahl sichtbarer Slots**. Backup und Temporärdatei sind keine zusätzlichen Spielerslots.

Für kleine Zustände zunächst seriell schreiben, nur eine Anfrage zur Zeit:

1. Am zulässigen Zustandsrand vollständig kopieren; nachträgliche Weltänderungen verändern diese Kopie nicht.
2. Paket und Wiederanlauf prüfen, dann temporär im selben Verzeichnis schreiben. Schreib-/Flushfehler prüfen, Datei explizit schließen und erneut einlesen/validieren.
3. Vor Ersetzen des Ziels den bisher gültigen Stand als geprüfte Sicherung bewahren. Ein bereits beschädigtes Ziel darf die letzte gültige Sicherung nicht verdrängen.
4. Ziel mit geprüftem Verfahren ersetzen; Ergebnis kontrollieren. Bei jedem fehlgeschlagenen Schritt alten Stand/Backup erhalten und Fehler zurückgeben. Verwaiste temporäre Dateien werden nicht still als erfolgreiche Saves angezeigt.
5. Erst nach Erfolg UI bestätigen. **Empfehlung, noch freizugeben:** neuen Todes-Checkpoint ebenfalls erst jetzt übernehmen; beim Scheitern den vorherigen behalten. Anfangs-Wiederanlauf im Speicher bleibt auch bei fehlendem Dateizugriff verfügbar, ohne eine erfolgreiche Sicherung vorzutäuschen.

`FileAccess` und `DirAccess` bleiben die vorgesehenen Engine-Bausteine. Das tatsächliche Ersetzen einschließlich Abbruchpunkten muss auf Windows getestet werden; aus `flush` oder Umbenennen folgt keine pauschale Garantie gegen jeden Stromausfall. [Godot 4.7 – FileAccess](https://docs.godotengine.org/en/4.7/classes/class_fileaccess.html), [Godot 4.7 – DirAccess](https://docs.godotengine.org/en/4.7/classes/class_diraccess.html)

Beim Laden wird ein ungültiger Hauptstand nicht automatisch mit beliebigem späterem Fortschritt kombiniert. Ein geprüftes Backup desselben Datensatzes kann als klar gekennzeichneter älterer Rückfall angeboten werden. Keine automatische Löschung oder Überschreibung inkompatibler Saves. Hintergrundthreads erst bei gemessenem Bedarf; dann ausschließlich unveränderliche Datenkopien, nicht SceneTree-Zugriffe.

### 19.6 Restore-Protokoll

1. **Vorprüfung:** Datei und eingebetteten Todes-Wiederanlauf vollständig auf Schema, Version und vorab bekannte Definitionen prüfen. Ungültige Daten lassen eine noch laufende Welt unangetastet.
2. **Exklusiv beginnen:** Main setzt PREPARING, sperrt Bedienung, erhöht Laufgeneration und zeigt Ladezustand. Kein zweiter Restore oder Save gleichzeitig.
3. **Alte Welt entfernen:** Referenzen und Verbindungen nach außen lösen, Audio stoppen, Welt freigeben. Keine zwei vollständigen Level zur Absicherung gleichzeitig im RAM halten.
4. **Inaktiv aufbauen:** Freigegebene Levelszene instanziieren. `_ready` bindet nur lokale Referenzen; keine Pickups, Storyereignisse oder KI-Aktionen. ID-Verzeichnis/Beteiligte prüfen, Signals einmal verbinden. Sowohl aktuellen Snapshot als auch eingebetteten Todes-Wiederanlauf gegen die konkreten IDs und Zustandsverträge prüfen, jeweils anhand ihrer eigenen Daten. Dafür keine zweite Welt laden. Die räumliche Prüfung erfolgt für den jetzt anzuwendenden Snapshot in Schritt 7; beim späteren Todes-Restore durchläuft der eingebettete Stand denselben Ablauf. Dessen Ankerkombinationen müssen zuvor im Test nachgewiesen sein.
5. **Maßgebliche Zustände anwenden:** Inventar/Funde, Puzzle-Teilzustände, Story-/Leveldaten und Begegnungsfreigabe still setzen. Danach unabhängige Tür-/Schalterstände und daraus abgeleitete Freigaben/Visuals/Kollision herstellen. Nicht durch Aufruf gewöhnlicher Interaktionen laden.
6. **Spieler/Kreatur vorbereiten:** Player wendet Pose, Haltung, Health und Effekt einmalig an; Creature folgt der bestätigten Resetpolitik. Engine-Physik/Navigation dürfen synchronisieren, Akteursmotoren, Schadenslogik, Trigger und Gameplaytimer bleiben deaktiviert.
7. **Räumlich prüfen:** Map-Bereitschaft, vollständige Spielerform, Boden/Ausstieg und vereinbarte sichere Beziehung der Anker zu restaurierten Türen/Kreatur prüfen. Beim noch unbewegten CharacterBody dafür Form-/Bodenqueries verwenden, nicht auf einen erst durch normale Bewegung aktualisierten Bodenstatus warten. Begrenztes Warten mit Diagnose; bei Fehler kontrolliert abbrechen, keine Teleportreparatur. Kamerahistorie und alte Eingaben zurücksetzen.
8. **Freigeben:** UI und erforderliche Ambience aus dem fertigen Zustand initialisieren, Todes-Snapshot und aktuellen Verlauf gemeinsam übernehmen, Phase PLAYING setzen und über Level Gameplay freigeben. Triggerinitialisierung darf keinen automatischen Save allein durch den Restore am Speicherpunkt erzeugen; die automatische Auslösung muss zunächst neu freigegeben werden, etwa nach Verlassen und erneutem Eintritt. Bereits erfüllte Einmaltrigger bleiben unterdrückt. Keine historischen Ereignisse wieder abspielen.

Ein Fehler nach Entladen der alten Welt führt bedienbar ins Menü; Saves bleiben erhalten. Ein älterer Stand ersetzt den Verlauf vollständig, nicht per Merge. Nutzereinstellungen bleiben unberührt. Wiederholtes Anwenden derselben Daten muss bis auf ausdrücklich erlaubte Neuinitialisierung dasselbe Ergebnis liefern.

## 20. UI

`game_ui.gd` besitzt eine UI-Szene mit Paneelen für Start/Laden, HUD, Inventar, Storytext, Pause, Game Over, Slice-Ende und Lade-/Fehlermeldungen. Main setzt die zulässige Ansicht; UI sendet Bedienwünsche zurück. Sie besitzt weder Health noch Bestand noch Puzzlefortschritt.

Main ruft vor Weltabbau `unbind_world` an der UI auf: Verbindungen zu alten Quellen trennen, Lesereferenzen/Fokusziel löschen und weltbezogene Paneele schließen. Nach erfolgreichem Restore folgt `bind_world` mit den neuen Quellen. UI verbindet dann einmal deren Zustandssignale und liest im selben synchronen Schritt die Anfangsdaten; erst danach wird Gameplay freigegeben. Die Referenzen dienen ausschließlich dem Lesen. UI-Bedienwünsche gehen an Main, das den zuständigen Auftrag auslöst. Kein dauerhaftes Spiegelinventar und kein Main-Durchleiter für jede HUD-Änderung. Beim späteren Öffnen einer Ansicht nochmals aktuellen Zustand lesen.

HUD zeigt nur nötige Interaktion, Gesundheits-/Schadensrückmeldung, Speichermeldung und ggf. Tempoeffekt. Umfang der permanenten Anzeige bleibt Designfrage. „Gespeichert“ erscheint erst nach erfolgreichem I/O; Ablehnung, laufender Vorgang und Fehler sind unterscheidbar. Ladebedienung beider Speicherarten ist vorgesehen, aber konkrete Slotanzahl und Menülayout bleiben offen.

UI besitzt Maus-/Fokusdarstellung in Abstimmung mit Main: freier Zeiger in Menüs, eingefangene Maus im aktiven First-Person-Spiel, kein Durchreichen behandelter Klicks. Pausenregeln von Lesen und Inventar bleiben offen. Ein exklusiver Ansichtsstatus mit nachvollziehbarer Rückkehr genügt; kein allgemeines Fensterframework.

## 21. Autoloads

**Empfehlung: null Autoloads für Version 0.1.** Main bleibt ohnehin während der gesamten Anwendung bestehen. Die benötigte szenenübergreifende Lebensdauer ist damit abgedeckt.

| Kandidat | Lösung ohne Autoload | Begründung |
| --- | --- | --- |
| Game / Flow | Main-Root | Lebensdauer und Übergänge haben einen sichtbaren Besitzer |
| Save | RefCounted SaveService im Main | Benötigt keine selbstständig verarbeitende Singleton-Node; Datentests können ihn direkt erzeugen |
| Audio | Lokale Player/Level/UI-Quellen, Buskonfiguration durch Main | Keine globale Weltreferenz oder dauerhaft geladene Soundbibliothek nötig |
| Konfiguration | Kleine explizit referenzierte Resources, Einstellungen im Main | Vermeidet versteckte Abhängigkeiten und veränderliche globale Defaults |
| Event-Bus | Lokale Signals | Der kleine Szenenbaum hat bekannte Kommunikationswege |

Spätere echte anwendungsweite Anforderungen können diese Entscheidung begründet ändern. Die Test-Sandbox verwendet denselben Main-Zusammenbau, nicht ersatzweise globale Manager.

## 22. Kommunikation / Signals

Die folgenden Namen sind Vertragsvorschläge, keine implementierte API. Direkte Aufrufe transportieren Aufträge/Abfragen; Signals melden Ergebnisse oder Bitten an den zuständigen Besitzer. Lokale Referenzen werden beim Aufbau gesetzt/validiert, nicht pro Frame durch globale Suche ermittelt.

| Ablauf | Konkrete Richtung | Grenze / Garantie |
| --- | --- | --- |
| Fokus/Interaktion | Interactor → Interactable `get_action_info` / `request_interaction` | Ziel wird bei Auslösung nochmals geprüft |
| Aufnahme | Pickup-Signal → Level → Inventory-Prüfung + Pickup-Änderung → UI-Meldung | Erst konsistente Änderung, dann externe Benachrichtigung |
| Schalter | Switch → Puzzle-Eingabe → Door-Freigabe; Änderung → Switch-Ansicht | Puzzle besitzt den Teilzustand, Door die Stellung |
| Eigene Itemnutzung | UI-Wunsch → Main → Player; Player → eigenes Inventory | Player bestätigt Verbrauch und Effekt zusammen, ohne Level-Umweg |
| Puzzle-Itemeinsatz | Anfrage → Level-Koordination → Inventory und Puzzle | Nur die besitzerübergreifende Änderung braucht Koordination |
| Geräusch | Quellsignal → Creature `receive_noise`; einmal von Level verbunden | Feste Wertparameter, kein weitergereichtes Ereignisobjekt |
| Schaden | Creature → bereits bekannter Player `apply_damage` | Direkter Auftrag; Player bestätigt Health/Tod genau einmal |
| Tod | Player-Todsignal → Main → Game Over / Restore | Kein zweiter konkurrierender Todablauf |
| Story | Note/Trigger → Level-Progress → Main/UI | Einmaligkeit beim Progress, nicht in der UI |
| Speichern | SavePoint → Level-Stabilitätsprüfung → Main → Level `capture_snapshot` → SaveService | SaveService erhält nur Daten; Ergebnis zurück über Main |
| Restore | Main → Level `apply_snapshot` → zuständige Objekte | Stilles Anwenden, anschließend einmalige UI-Neubindung |
| Gefahr / Durchgang | Creature-Zustand → Level-Audio; Door-Durchgangssignal → Creature | Level verbindet die Durchgangsmeldung nur beim Aufbau; Door kennt Creature nicht |

Lokale Verbindungen innerhalb der Levelinstanz werden einmal beim Aufbau hergestellt. Die dauerhaften Empfänger Main und UI trennen ihre Weltverbindungen ausdrücklich vor dem Abbau. Direkte Methoden sind für Aufträge mit bekanntem Ziel einfacher; Signals dienen Zustandsmeldungen und Quellen, die ihren Empfänger nicht kennen sollen. Verzögerte Fortsetzungen beachten §6, synchrone Meldungen benötigen keinen eigenen Tokenapparat. Keine unbegrenzte Event-Historie, kein generischer Message-Router, kein Observer-Framework.

## 23. Resources / Daten

| Art | Ablage / Besitzer | Änderbarkeit |
| --- | --- | --- |
| Static Configuration | `PlayerTuning`, `CreatureTuning`, `ItemDefinition` als kleine `.tres`-Resources; geometrische Marker/Bindungen in Szenen | Während eines Laufs als unveränderlich behandeln |
| Runtime State | Player, Inventory, Creature, einzelne Weltobjekte und Level-Progress | Nur jeweiliger Besitzer verändert ihn |
| Save State | Tief kopierte primitive Daten; Main hält Todes-Snapshot, SaveService schreibt Pakete | Nach Aufnahme unverändert |

Godot lädt wiederholt referenzierte Resources gemeinsam; Laufzustand in einer solchen Definition würde mehrere Instanzen koppeln. Daher keine aktuellen Health-, Puzzle-, Bestands- oder Timerwerte dort ablegen. Veränderte Kollisionsformen und Debug-Tuningkopien ausdrücklich instanzlokal halten. [Godot 4.7 – Resources](https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html)

PlayerTuning umfasst Bewegungs-/Kameragrenzen und Health-Basis. CreatureTuning umfasst Geschwindigkeiten, Sicht/Hören, Such-/Untersuchungszeiten und bestätigte Schadensparameter. ItemDefinition enthält Typ-/Stack-/Effektkonfiguration. Keine willkürlichen finalen Zahlen; ungültige Wertebereiche werden beim Aufbau gemeldet.

Für zwei Rätsel genügen zunächst exportierte spezifische Eingaben/Referenzen an ihren Nodes; keine zusätzliche Puzzledaten-Sprache. Audio verwendet zunächst vorhandene Stream-Resources und einfache Listen. Erst bei tatsächlicher Wiederverwendung einen eigenen Konfigurationstyp ergänzen. glTF/GLB als Austauschformat bleibt eine Empfehlung aus dem Technical Design; Importprofile und Asset-Workflow sind noch zu bestätigen.

## 24. Stabile IDs

**TECHNISCHE EMPFEHLUNG:** Lesbare, manuell vergebene `persistent_id` als exportierter `StringName` an jeder relevanten gescripteten Levelinstanz. Reine `Marker3D`-Anker erhalten denselben Wert als im Inspector gepflegte Node-Metadaten; dafür ist kein zusätzliches Markerscript nötig. Level liest beide Varianten beim Aufbau in dasselbe geprüfte ID-Verzeichnis ein. Im Save wird daraus ein String. Konvention beispielsweise `slice_01/door_01` oder `slice_01/pickup_01`; das sind neutrale technische Beispiele, keine Raum-/Storyfestlegungen.

- Ein Level hat eine dauerhafte `level_id`. IDs sind innerhalb dieses Levels eindeutig; der Levelpräfix erleichtert Prüfung und Diagnose.
- Prefabs besitzen keine schon ausgefüllte Weltinstanz-ID. Beim Platzieren wird sie vergeben; Duplizieren verlangt eine neue ID. Keine automatische Neugenerierung beim Start oder Rename.
- Itemdefinition, Welt-Pickup und Storyinhalt haben unterschiedliche Identitäten: zwei Funde desselben Itemtyps besitzen zwei Pickup-IDs, aber dieselbe Item-ID.
- Player und die eine Kreatur erhalten feste Akteur-IDs; Türen, Schalter, Puzzle, Story-Trigger/-Notizen, SavePoints sowie referenzierte Wiederanlaufmarker ebenfalls stabile IDs.
- Level baut einmal beim inaktiven Start ein lokales Verzeichnis auf. Es prüft leere/doppelte IDs, Objekttyp, Puzzleausgänge, Referenzen und Anker. Bei Fehlern keine Gameplayfreigabe. Kein globales Verzeichnis und keine Suche im gesamten SceneTree pro Frame.
- Kleine Editorwarnungen für fehlende IDs ergänzen die Startprüfung. Die vollständige Duplikatprüfung erfolgt beim Level-Validieren/Start und in Tests; ein eigenes Editorplugin ist dafür nicht nötig.
- Die Prüfung meldet bei einer Doppel-ID beide verursachenden Node-Pfade zur Diagnose; diese Pfade werden nicht gespeichert. IDs werden auf das vereinbarte kleingeschriebene ASCII-Format ohne Leerzeichen geprüft, nicht still getrimmt oder umbenannt. Das genügt für den kleinen Slice; kein UUID-Generator oder Editorplugin.
- Node-Name, NodePath, Resource-UID und Laufzeit-Instance-ID ersetzen diese Identität nicht. Umbenennen/Umordnen eines Nodes ändert die Save-ID nicht. Entfernen oder fachliches Umwidmen einer ID erfordert eine neue Inhaltsrevision und eine ausdrückliche Kompatibilitätsentscheidung.

Beim Restore werden Pflichtobjekte ausschließlich anhand dieser IDs im neu aufgebauten Level aufgelöst. Fehlende/unerwartete Zustände werden nach Schema geprüft; bei gameplayrelevanten Widersprüchen abbrechen, nicht still das Level-Default übernehmen.

## 25. Node Trees

Die folgenden Bäume zeigen den vorgesehenen Kern, keine erzeugten Szenendateien. Visuals, Kollisionsmaße, Animationen und Inhalte werden erst später gestaltet. Zusätzliche rein darstellende Kinder können ohne neue Systemschicht entstehen.

### Main und Level

```text
Main (Node, main.gd; process_mode ALWAYS)
├── WorldHost (Node3D; process_mode PAUSABLE)
│   └── VerticalSlice (bei Bedarf instanziert)
├── GameUI (Instanz; process_mode ALWAYS)
└── DebugOverlay (nur bei erlaubtem Entwicklungsmodus instanziiert)

VerticalSlice (Node3D, vertical_slice.gd; zunächst gameplay-inaktiv)
├── World (Node3D; statische Geometrie, Licht, Umgebungsquellen)
├── Navigation (Node3D)
│   ├── NavigationRegion3D (eine oder wenige Flächen nach Durchgangsbedarf)
│   └── NavigationLink3D (nur je tatsächlich dynamischem KI-Durchgang)
├── Actors (Node3D)
│   ├── Player (Instanz)
│   └── Creature (Instanz; Begegnungsfreigabe separat)
├── Interactables (Node3D; Tür-/Schalter-/Pickup-/Hinweisinstanzen)
├── Puzzles (Node)
│   ├── PuzzleA (Node, puzzle_a.gd)
│   └── PuzzleB (Node, puzzle_b.gd)
├── Triggers (Node3D; Story-/SavePoint-/Traversal-Instanzen)
├── Anchors (Node3D; benannte Marker3D für Start, Wiederanlauf, Patrouille, Test)
├── Ambience (AudioStreamPlayer; nur nicht räumliche Grundatmosphäre)
└── Music (AudioStreamPlayer)
```

Wald-Einstieg und Gebäudebereich können unter World getrennte Gestaltungsgruppen sein, bleiben aber gleichzeitig geladen. Exploration, Rätsel, Begegnung, Verfolgung, Enthüllung und Abschluss entstehen aus lokalen Bedingungen, nicht je einer neuen Hauptszene. Der empfohlene GDD-Ablauf ist kein hiermit beschlossener Raumplan oder neues lineares Stage-System.

### Player und Creature

```text
Player (CharacterBody3D, player.gd)
├── BodyShape (CollisionShape3D; instanzlokale CapsuleShape3D)
├── Head (Node3D)
│   └── Camera3D (einzige aktive Spielkamera)
│       ├── InteractionRay (RayCast3D)
│       └── Flashlight (SpotLight3D)
├── Interactor (Node, player_interactor.gd)
└── Footsteps (AudioStreamPlayer3D)

Creature (CharacterBody3D, creature.gd)
├── BodyShape (CollisionShape3D)
├── NavigationAgent3D
├── VisionOrigin (Marker3D)
├── Visuals (Node3D; Darstellung noch offen)
└── Voice (AudioStreamPlayer3D)
```

Inventory und Tuning sind Script-/Resource-Referenzen, keine zusätzlichen Nodes. Für Creature-Sicht reichen gezielte Physikqueries, kein zusätzlicher Sensorbaum. Kamera und Audiolistener-Zuordnung werden beim Aktivieren einer Welt eindeutig gesetzt; die Debugansicht erzeugt keine zweite aktive Spielkamera.

### Door und Pickup

```text
Door (Node3D, door.gd; Interactable)
├── Leaf (AnimatableBody3D)
│   ├── CollisionShape3D
│   └── Visuals (Node3D)
├── AnimationPlayer (physiksynchron; bewegt Leaf)
├── Clearance (Area3D)
│   └── CollisionShape3D
└── ActionAudio (AudioStreamPlayer3D)

Pickup (Node3D, pickup.gd; Interactable)
├── HitArea (Area3D)
│   └── CollisionShape3D
└── Visuals (Node3D)
```

Door hat bei Bedarf eine exportierte Referenz auf den zugeordneten NavigationLink im Level, aber keinen standardmäßig aktiven Link im Prefab. Ohne Referenz muss ihre fehlende Relevanz für Kreaturenwege nachgewiesen sein (§17). Ein Switch verwendet dieselbe kleine HitArea-/Visuals-Anordnung, optional mit lokalem ActionAudio. StoryNote ergänzt Text-/Hinweis-ID. SavePoint hat getrennte manuelle HitArea und automatische TriggerArea; nur der konfigurierte Auslösemodus ist aktiv. Zugeordnete sichere Anker werden als geprüfte Markerreferenzen gebunden, nicht im Save frei erfunden.

### UI

```text
GameUI (CanvasLayer, game_ui.gd; ALWAYS)
├── Root (Control; gesamte Fensterfläche)
│   ├── MainMenu (Control; Neues Spiel und Ladebedienung)
│   ├── HUD (Control)
│   │   ├── InteractionHint
│   │   ├── HealthFeedback
│   │   ├── SpeedEffectFeedback
│   │   └── SaveFeedback
│   ├── InventoryPanel (Control)
│   ├── StoryPanel (Control)
│   ├── PausePanel (Control)
│   ├── GameOverPanel (Control)
│   ├── CompletionPanel (Control)
│   └── LoadingAndErrorPanel (Control)
└── UISound (AudioStreamPlayer)
```

Die Blatt-Controls werden erst beim UI-Auftrag konkret gestaltet; unsichtbare Paneele dürfen keinen Fokus oder Mausaktionen abfangen. Gemeinsame Texte/Buttons brauchen nicht automatisch eigene Scripts.

## 26. Script-/Dateiübersicht

Alle Pfade sind relativ zu `game/`; ausschließlich geplante Dateien. Die Tabelle beschreibt bewusst jede zentrale Verantwortung statt beliebig viele Platzhaltermanager vorzusehen.

| Datei | Verantwortung | Szene / Owner | Wesentliche Abhängigkeiten |
| --- | --- | --- | --- |
| `app/main.gd` | Flow, Weltlebensdauer, UI-Bindung, Todes-Snapshot, Einstellungen | Main | Levelvertrag, SaveService, GameUI |
| `app/save_service.gd` | Schema-/Dateiprüfung, JSON, letzter gültiger Dateistand | RefCounted im Main | Primitive Daten, FileAccess/DirAccess; keine Nodes |
| `levels/vertical_slice/vertical_slice.gd` | Lokaler Zusammenbau, IDs, Story/Begegnung, koordinierte Änderungen | VerticalSlice | Player, Creature, Puzzle, lokale Weltobjekte |
| `player/player.gd` | Motor, Kamera, Haltung, Health, Effekt, Licht, Schritte | Player | PlayerTuning, Inventory, Interactor |
| `player/player_interactor.gd` | Fokus, Reichweite, Interaktionsauftrag | Player/Interactor | Kamera-RayCast, Interactable |
| `player/inventory.gd` | Bestand, Aufnahme-/Verbrauchsprüfung, Datenkopie | RefCounted im Player | ItemDefinition; keine UI/Welt |
| `player/player_tuning.gd` | Statisches Player-Konfigurationsschema | Resource | Keine Laufzeit-Nodes |
| `creature/creature.gd` | Eine FSM, Wahrnehmung, Navigation, direkter Schadensauftrag | Creature | CreatureTuning, Agent, zugewiesene Ziele/Player-Vertrag |
| `creature/creature_tuning.gd` | Statisches KI-Konfigurationsschema | Resource | Keine Laufzeit-Nodes |
| `world/interactable.gd` | Minimaler Interaktionsvertrag und ID | Basis für interaktive Weltobjekte | Keine Main-/UI-/Save-Abhängigkeit |
| `world/door/door.gd` | Stellung, Verriegelung, Blatt, ggf. Navigationskopplung | Door | Interactable, AnimatableBody3D, optional zugewiesener NavigationLink3D |
| `world/switch/switch.gd` | Gültige Eingabe und Schalterdarstellung | Switch | Interactable, ggf. zugewiesenes Puzzle |
| `world/pickup/pickup.gd` | Weltfundstatus und Aufnahmeanfrage | Pickup | Interactable, ItemDefinition |
| `world/story/story_note.gd` | Lesbarer Hinweis, Öffnungsanfrage | StoryNote | Interactable, statische Hinweisdefinition |
| `world/story/story_trigger.gd` | Räumliche Eintrittsmeldung | StoryTrigger/Area3D | Zugewiesene Trigger-ID; kein eigener Progressspeicher |
| `world/save_point/save_point.gd` | Automatischer oder manueller Speicheranlass | SavePoint | Interactable, Ankerreferenzen; kein Datei-I/O |
| `world/traversal/traversal_marker.gd` | Erlaubte Passage und geometrische Prüfdaten | TraversalMarker/Area3D | Eintritt/Ausstieg; keine Playerbewegung |
| `puzzles/puzzle.gd` | Kleiner Zustands-/Eingabe-/Restore-Vertrag | Basis-Node | Direkte Ausgangsreferenzen, primitive Zustände |
| `puzzles/puzzle_a.gd` | Erste später bestätigte Rätsellogik | PuzzleA im Level | Puzzle-Vertrag, zugewiesene Türen |
| `puzzles/puzzle_b.gd` | Zweite später bestätigte Rätsellogik | PuzzleB im Level | Puzzle-Vertrag, zugewiesene Türen |
| `items/item_definition.gd` | Statische Gegenstandsdefinition | Resource | Keine Laufzustände |
| `ui/game_ui.gd` | Ansichten, Fokus, Präsentation, Bedienwünsche | GameUI | Von Main gebundene Quellen nur lesend; lokale Controls |
| `debug/debug_overlay.gd` | Begrenzte Zustandsanzeige/Testaktionen | DebugOverlay/CanvasLayer im Main | Explizite Debugreferenzen, keine Releasepflicht |
| `tests/data_checks.gd` | Automatisierte Daten-/Vertragstests | Separater Testlauf | Inventory, SaveService, Puzzle-Datenverträge |

Zusätzlich geplant: `.tscn`-Dateien der zwölf Kernszenen aus §6; `debug/debug_overlay.tscn`; eine kombinierte technische Testwelt `tests/systems_sandbox.tscn`. Kleine `.tres`-Instanzen für Player-/Creature-Tuning und tatsächliche Items sowie eine Audio-Buskonfiguration sind Daten, keine weiteren Scripts. Exportkonfiguration entsteht erst im Implementierungsauftrag.

**Größenordnung nach Review:** 22 Scripts für den Kern einschließlich drei Resource-Schemas, ein Debugscript, ein Testscript; insgesamt ungefähr **24 Scripts statt 25**. **Zwölf Kernszenen**, eine Debugszene und eine Testwelt; insgesamt ungefähr **14 Szenen statt 15**. Die Geräuschdatenklasse und eine doppelte Testwelt entfallen. Das ist eine Planungsgröße, kein Auftrag zur vollständigen Vorab-Erstellung.

Weitere Zusammenlegungen sind derzeit nicht klar besser: Player/Interactor/Inventory trennen Motor, räumliche Zielwahl und reine Bestandsregeln; Creature samt einer Tuningdefinition bleibt kompakt. Interactable und Puzzle haben kleine wiederkehrende Verträge. Die Welt-Prefabs bündeln gültige Kollisions-/Darstellungskonfiguration und ersparen fehlerträchtiges manuelles Nachbauen; Scriptdateien allein wären keine bessere Wiederverwendung. Zwei Rätsellogiken werden erst nach Inhaltsfreigabe erstellt, weitere Komponenten nur bei belegtem Bedarf.

## 27. Fehlerbehandlung

Einfache strukturierte Rückgaben mit Erfolg/Fehlergrund für erwartbare Ablehnungen; Godot-Warnungen/Fehler mit Level-ID, Objekt-ID und Phase für technische Defekte. Keine Enterprise-Loggingbibliothek. Wiederholte identische Laufzeitfehler begrenzen, damit Konsole und RAM nicht volllaufen.

| Fall | Reaktion |
| --- | --- |
| Fehlende/doppelte ID oder falsche Referenz | Level vor Freigabe abbrechen; betroffene IDs/Nodes nennen; kein zufälliger Gewinner |
| Fehlendes dekoratives Asset/Audio | Verständliche Diagnose; nur weiter, wenn Spielregel, Kollision und Orientierung intakt bleiben |
| Fehlendes Pflichtasset, Kollisionsobjekt oder Warnsignal | Kein stilles unsichtbares Hindernis/Item; Aufbau bzw. Abnahme stoppen |
| Ungültiger/inkompatibler Save | Vorprüfung ablehnen; Hauptdatei behalten; passenden geprüften Backup-Rückfall anbieten |
| Schreiben scheitert | Kein Erfolgssignal, alter gültiger Stand/Checkpoint bleibt nach bestätigter Politik; laufendes Spiel nicht zerstören |
| Navigation nicht bereit/defekt | Begrenzte Warte-/Retryphase, Diagnose und kontrollierter Abbruch bzw. sicherer KI-Stopp |
| Legal unerreichbares Ziel | Wahrnehmung bleibt gültig, aber kein Wanddurchtritt; bestätigter Such-/Rückkehr-Ausgang |
| Ungültiger Spawn | Keine beliebige nächste Navmeshposition als Playerreparatur; Restore abbrechen, Save erhalten |
| Tür widerspricht Puzzle | Maßgebliche Quelle prüfen; widersprüchliches Save ablehnen, abgeleitete Darstellung kontrolliert herstellen |
| Kritisches Item fehlt/ist doppelt | Vorprüfung/Transaktionsgrenze schützt; fehlerhafte Daten ablehnen, nicht unbemerkt Ersatzitem erfinden |
| Spieler außerhalb erlaubter Geometrie | Im Test reproduzierbar melden; Wiederanlauf anbieten, keine versteckte Belohnung oder Teleportabkürzung |
| Alter Callback nach Restore | Über Laufgeneration verwerfen, ohne neue Welt zu verändern |

## 28. Debug

Eine kleine `debug_overlay.tscn` zeigt Player-Haltung/Bewegung/Health/Effekt, Creature-FSM und Übergangsgrund, letzte Sichtung/gehörten Reiz, Ziel/Route, Puzzle-Zustand, aktuelle Phase, Laufgeneration und Save-/Restore-Schritt. Eine begrenzte Liste letzter Zustandswechsel genügt; keine vollständige Ereignisaufzeichnung.

Entwicklungsaktionen: Health setzen, Player kontrolliert zu einem benannten Testanker versetzen, Puzzle über Level koordiniert zurücksetzen, an gültigem Punkt Save auslösen, ungültige Saves/Schreibfehler gezielt testen, temporäre Tuningkopie verändern. Sichtkegel/-strahl, gehörten Ort und Navmesh über Godot-Debuganzeige bzw. einfache Hilfsdarstellung prüfen. Auch Debugteleport verwendet ausschließlich den Player-Motorvertrag und setzt dessen Bewegung zurück.

Debug-Eingriffe sind im Release gesperrt, nicht bloß unsichtbar. Main lädt die Ansicht nur im erlaubten Entwicklungsmodus. Testdaten verwenden einen eigenen Pfad `user://tests/`, nicht reguläre Saves. Live-Tuning verändert Kopien, keine `.tres`-Dateien. Mutierte Debugläufe dürfen keine regulären Spielstände überschreiben; ein normaler Neulauf startet wieder aus freigegebener Konfiguration. Kein Editorwerkzeugprojekt, keine universelle Cheat-Konsole.

## 29. Testarchitektur

### Ebenen

1. **Daten-/Vertragstests:** Kleiner headless-fähiger GDScript-Testlauf ohne zusätzliches Testframework. Inventory, Save-Paket/Version/JSON-Rundlauf, Snapshot-Unveränderlichkeit und reine Puzzle-Zustandsübergänge automatisieren. Erwartbare Fehler und Rückgabewerte ebenso prüfen wie Erfolg. Ein Framework erst ergänzen, wenn dessen Nutzen nachgewiesen ist.
2. **Eine Systems Sandbox:** Ein kleiner Bewegungsbereich mit Boden, Ecke, niedriger Decke und erlaubtem/blockiertem Traversal sowie ein abgegrenzter Bereich für Tür, Schalter, Pickup, Puzzle-Testzustände, Sichtblockade, Kreatur und beide Speicherarten. Echter Player und echte Systeme. Für reine Bewegungstests bleibt Creature über ihre vorhandene Aktivierungsgrenze deaktiviert; für KI-Tests werden feste Startzustände geladen. Keine zweite Welt und kein zusätzlicher Testszenen-Manager nötig.
3. **Integrierter Slice / Export:** Tatsächliche Inhalte, sichere Speicheranker, Flucht ohne Tempo-Item, Audioverständlichkeit, Dauerlauf und Windows-Export mit denselben Zustandsverträgen prüfen.

Die Sandbox wird über einen nur im Entwicklungsmodus erlaubten Levelpfad im unveränderten Main-Lebenszyklus geladen. Ihr Root verwendet zunächst dieselbe Levelkoordination mit Testkonfiguration; in der frühen Ausbaustufe sind noch nicht benötigte Teilnehmer ausdrücklich optional, keine Platzhaltermanager nötig. Gameplaymethoden erhalten keine Sonderzweige für Testnamen. Getrennte benannte Testanker und frischer Aufbau vor jedem Fall verhindern gegenseitige Beeinflussung. Bewegungstests dürfen nicht die komplette KI-/Save-Implementierung zum Start voraussetzen. Erst bei nachgewiesener Störung/Unübersichtlichkeit wird eine zweite Testwelt abgetrennt. Testfälle dokumentieren Ausgangslage, Schritte, Erwartung und Ergebnis im späteren Testauftrag; jetzt entstehen keine zusätzlichen Dateien.

### Architekturspezifische Abnahmefälle

| Prüfung | Erwarteter Nachweis / TDD-Bezug |
| --- | --- |
| Main-Lebensdauer und Sperren | Wiederholt Menü → Neues Spiel → Pause → Tod → Restore; genau eine Welt und ein Player; keine pausierte Signaländerung, kein Physik-Warte-Deadlock. AC-01/03 |
| Motor-/Traversalbesitz | Keine Animation schreibt Player-Root; Ducken unter Decke, blockierter Ausstieg und Tod/Pause im Traversal bleiben kontrollierbar. AC-02/15 |
| Effekt / Health | Verbrauch einmalig, Restzeit pausiert/restauriert, Tod einmalig, keine doppelten oder durch Wände wirkenden Treffer. AC-04/05 |
| Interaktion und Inventory | Wand verdeckt Pickup; Doppelklick erzeugt keinen doppelten Besitz; voller Bestand folgt bestätigter kritischer Itemregel. AC-06/07 |
| Lampe | Besitz, Ein/Aus und sichtbares Licht stimmen nach Restore; keine implizite Batteriepflicht. AC-08 |
| Puzzlebesitz | Teilfortschritt und eingesetztes Item laden; Lösung gibt Tür frei, ohne Stellung fälschlich zu duplizieren; Reset konsistent. AC-09 |
| KI ohne Allwissenheit | Hinter Wand bewegter Player verändert letzte Sichtposition nicht; gehörtes Ereignis behält seinen Ort; wiederholter Reiz erzwingt keine endlose Suche. AC-10/11/12 |
| Türroute | Geschlossene Tür vor, während und nach Routenberechnung; keine alternative Navmesh-Kantenverbindung durch die Sperre. AC-13 |
| Flucht und Progress | Suche endet nachvollziehbar, Pflichtweg ohne Tempo-Item lösbar; Story-/Abschlussereignis nicht doppelt. AC-14/16/20 |
| Save-Eigenständigkeit | Manuellen Stand sichern, zugehörigen Autosave mehrfach überschreiben, Spiel neu starten, manuell laden und sterben: eigener korrekter Wiederanlauf bleibt erhalten. AC-17 / TDD §26.3 |
| Save-Fehlerfenster | Schreib-, Backup- und Ersetzungsfehler einzeln injizieren; alter gültiger Stand und ehrliche Rückmeldung bleiben erhalten. AC-17 |
| Restore-Idempotenz | Identische Daten wiederholt laden: gleiche fachliche Welt, keine doppelten Funde, Kreaturen, Sounds, Signals oder Belohnungen; kein Autosave aus initialer Bereichsüberlappung. Nach Laden Items ändern und sterben: Todes-Snapshot bleibt unverändert. AC-17/19 |
| UI und Audio | Sofortige richtige Anfangsdarstellung nach Neubindung, korrekter Fokus, keine Altloops; Audio-Stummschaltung ändert KI nicht. AC-18/19 |
| IDs / Resources | Doppelte ID stoppt Freigabe und benennt beide Nodes; zwei Instanzen ändern nicht gegenseitig Zustand oder gemeinsame Definition; Snapshot bleibt auch nach Anwenden und Weiterspielen eingefroren. AC-21 |
| Speicher-/Laufzeitkosten | Nach Aufwärmen wiederholter Weltwechsel ohne dauerhaft anwachsende Referenzen/Audioquellen; Editor + Spiel praktikabel. AC-22 |
| Export / Debug / Optionales | Speichern als normaler Windows-Benutzer; Release ohne Debugeingriff; Kern ohne Verstecken, Crafting und Perspektivwechsel. AC-23/24/25 |

Die vollständigen fachlichen Acceptance Criteria des Technical Design §26 gelten zusätzlich. Räumliches Verhalten, Kameragefühl, faire Gefahr und Soundverständlichkeit brauchen Spieltests; bestandene Datentests ersetzen diese nicht. In diesem Architekturauftrag wurden noch keine Laufzeittests ausgeführt.

## 30. Performance

- Genau eine vollständige Levelinstanz im Speicher. Main hält nur eine kleine erlaubte Level-ID/Pfad-Zuordnung und lädt große Szenen bei Bedarf; keine dauerhaft global vorgeladene Welt, die trotz Entladen ihre Assets festhält.
- Beim Weltwechsel auch starke Referenzen auf die alte PackedScene, Akteure, Audioquellen und große Ressourcen lösen. Teilen unveränderlicher Materialien/Streams ist sinnvoll; keine pauschalen Tiefkopien großer Assets.
- Itemkataloge und Tuning klein halten. Eine im Menü benötigte Itemdefinition lädt nicht das komplette Weltmodell; visuelle Weltassets gehören zur Pickup-/Leveldarstellung. Instanzkopien nur für tatsächlich veränderte kleine Daten/Kollisionsformen.
- Eine aktive komplexe KI. Perzeption nach konfiguriertem Intervall, Pfadänderung nach Bedarf, Bewegung im Physiktakt. Keine globale Objektsuche pro Frame, keine unbeschränkten Suchpunkte oder Reizhistorien.
- Zunächst keine Threads, Objektpools, Streaming-Infrastruktur oder Laufzeit-Rebakes ohne Messbedarf. Serielle kleine Saves früh auf spürbare Unterbrechungen prüfen.
- Texturen nach sichtbarem Nutzen dimensionieren; extreme Auflösung nicht als Standard. Licht-/Schattenkosten, Materialvarianten und Audioimport bewusst begrenzen. Musik/Ambience nicht unnötig unkomprimiert komplett im RAM halten.
- Lade-/Restore-Zeit, CPU-/GPU-Framezeit, RAM-Spitze und VRAM soweit verfügbar messen; Erstimport/ersten Lauf von wiederholtem Lauf unterscheiden. Editor und Spiel gemeinsam sowie eigenständigen Release prüfen.

Konkrete Zahlen für FPS, RAM, Texturauflösung oder Ladezeit wären bis zur Referenzhardware nur **DESIGNEMPFEHLUNGEN**, keine zugesicherten Budgets. Hier wird kein Renderer bevorzugt: Forward+, Mobile und Compatibility werden entsprechend ADR-008 mit tatsächlicher GPU und frühem Grafiktest bewertet. Realistische Wirkung, klare Orientierung und keine dauerhafte extreme Dunkelheit bleiben fachliche Vorgaben, nicht automatisch ein teures Beleuchtungsverfahren.

## 31. Build / Export

Godot **4.7.2 Stable**, GDScript und Windows x86-64 sind die festgelegte Basis. Editor und passende Export Templates später gemeinsam festhalten; keine stille Umstellung auf eine andere Version oder .NET. Dieses Dokument bestätigt keine vorhandene Installation.

`game/` wird später der Runtime-Projektroot. Quellassets und Lizenzverwaltung bleiben im übergeordneten Repository; nur benötigte Runtime-Dateien gelangen ins Spielpaket. Lizenzpflichtige Hinweise müssen vor Distribution berücksichtigt werden. Keine absoluten Entwicklungspfade im Build; `res://` für mitgelieferte Ressourcen, `user://` für Saves/Einstellungen. Kritische Inhalte über Godots Ressourcenreferenzen exportierbar machen; gegebenenfalls benötigte Rohdatendateien ausdrücklich im Export prüfen.

Debugexport erlaubt isolierte Entwicklungshilfen, Release sperrt deren Aktionen und reguläre Testpfade. Ein früher Standalone-Smoke-Test prüft Start, Fokus, Audio, Speichern und erneutes Laden als normaler Windows-Benutzer ohne Editor. Installation, konkrete Windows-Mindestversion und finale Verpackung bleiben spätere Aufgaben; jetzt wird kein Installer gebaut.

## 32. Abhängigkeiten

```text
Main → SaveService (nur Daten/I-O)
Main → Level → Akteure / Weltobjekte / Puzzle
Main → GameUI (Zustandsansichten)
Player → Inventory → ItemDefinition
Interactor → Interactable
Switch → Puzzle → Door
Creature → NavigationAgent / eigene Wahrnehmung / Tuning / Player-Schadensvertrag
GameUI → gebundene Zustandsquellen (nur Lesen und Änderungsmeldungen)
```

Rückmeldungen laufen über lokale Signals zu passenden Empfängern; nicht jede Meldung muss durch Level oder Main. Insbesondere kennt Door weder Puzzle noch Main/Creature; Pickup kennt nicht Inventory; UI verändert kein Gameplayobjekt direkt. Level darf explizit koordinieren, ohne sich fremde Zustände zusätzlich zu eigen zu machen.

SaveService prüft Datenform, aber keine Rätsellösung. Puzzle prüft seine Eingabe, aber keinen UI-Fokus. Audio folgt Zuständen, erzeugt keine KI-Wahrheit. Creature erhält lokale Ziele und Wahrnehmung, kein vollständiges Weltmodell. Main organisiert Lebensdauer, enthält weder Motorformeln noch Puzzle- oder KI-Regeln.

### Harte Zuständigkeitsgrenzen für die Implementierung

| Besitzer | Darf koordinieren / entscheiden | Darf nicht übernehmen |
| --- | --- | --- |
| Main | Anwendung, Phase, eine Welt, Save-/Restore-Auftrag, Todes-Snapshot, UI-Bindung, Einstellungen | Itemregeln, Trefferprüfung, Puzzlelösung, jeden HUD-/Geräuschwechsel weiterleiten |
| VerticalSlice | IDs/Referenzen validieren, lokale Verbindungen herstellen, Progress/Begegnung, Snapshot sammeln/anwenden, kurze Mehr-Objekt-Änderungen | Player-/KI-Ticks, Inventory-Regeln, Datei-I/O, UI-Fokus, globale Audiosteuerung oder Rätsellogik |
| Player / Creature / Puzzle / Door | Jeweils eigene Regeln und eigenen Laufzustand | Über Main/Level auf beliebige fremde Systeme zugreifen |

Level darf seine wenigen Ambience-/Musikquellen anhand eigener Ereignisse umschalten, baut aber keinen Audio-Service. Snapshot-Aggregation ruft die Besitzer auf; Level implementiert ihre Serializer/Validatoren nicht nochmals. Main ruft den Levelvertrag auf; es durchsucht nicht dessen Node-Baum nach Einzeltüren. Werden in einem dieser beiden Scripts die verbotenen Verantwortlichkeiten nötig, zuerst die Zuständigkeit korrigieren statt einen Universalmanager auszulagern.

Bei Wachstum zuerst eine tatsächlich zusammenhängende Verantwortung aus einem Script lösen; nicht vorsorglich jeden Methodenbereich in eine Komponente verwandeln. Weitere Levels können denselben Levelvertrag erfüllen, neue Items dieselbe Definition nutzen, neue Rätsel eigene Logik hinter demselben kleinen Vertrag erhalten. Das verlangt heute weder eine abstrakte Levelhierarchie noch generische Dependency Injection.

## 33. Architektur-Risiken

| Risiko | Frühe Absicherung / Grenze |
| --- | --- |
| Main oder Level wird ein unübersichtlicher Sammelmanager | Harte Grenzen aus §32; kein Durchleiten jedes Geräuschs/Treffers/HUD-Wechsels, lokale direkte Aufträge/Verbindungen |
| Geschlossene Tür bleibt im Navmesh verbunden oder als irrelevant fehlklassifiziert | Alle tatsächlichen Kreaturenwege samt offener Blattstellung prüfen; nur nötige Links, echte Lücke, Test mit bestehendem Pfad; Experimentell-Markierung nicht durch bloßen Wechsel zur Region umgehen |
| Restore wartet auf pausierte Physik | PREPARING von Pause trennen; Engine-Synchronisation bei gesperrtem Gameplay zulassen |
| Manueller Save verliert seinen Todes-Wiederanlauf | Eigenständiges Paket statt Referenz auf überschreibbaren Autosave; separater Regressionstest |
| Sichere Speicherung ist nur scheinbar sicher | Spieler-/Kreaturenanker, Sichtlinien, Türen und Wege gemeinsam prüfen; Resetpolitik bleibt Freigabeschranke |
| Doppelte Progress-/Tür-/Schalterwahrheit | Pro Feld genau ein Besitzer; abgeleitete Zustände weder separat speichern noch unabhängig ändern |
| Synchrone Rückmeldung unterbricht eine halbe Item-/Puzzleänderung | Rückmeldungen erst nach vollständiger Änderung; lokale Wiedereintrittssperre, kein Transaktionsframework |
| Gemeinsame Resources werden verändert | Statische Definitionen schreibgeschützt behandeln; instanzlokale kleine Kopien testen |
| KI erhält versteckte aktuelle Spielerposition | Wahrnehmungszugriff begrenzen; letzte bekannte Sicht-/Geräuschposition als Kopie; Tests mit verdeckter Bewegung |
| Traversal oder Türanimation drückt durch Geometrie | Ein Player-Positionsschreiber, Formprüfung, physiksynchrone Tür und kontrollierte Blockadereaktion |
| Signals/Callbacks greifen nach Restore in neue Welt ein | Lokale Lebensdauer, Verbindungen lösen, Laufgeneration prüfen, UI neu binden |
| Bereichseintritt beim Restore löst ungewollt Autosave aus | Aufbau inaktiv, initiale Überlappung nicht als neue Aktion behandeln, Trigger kontrolliert neu freigeben |
| Dateifehler zwischen Backup und Ersetzen | Jeden I/O-Schritt prüfen; gültige Kopie bewahren; Windows-Abbruchtests statt unbelegter Atomaritätszusage |
| ID-Änderung zerstört alte Saves | Explizite Autor-ID, Duplikatprüfung, Inhaltsrevision, keine stillen Defaults oder automatische Migration |
| Geladene Resources bleiben nach Weltabbau hängen | Große globale Preloads vermeiden, Referenzen lösen, wiederholte Reloads und RAM-Verlauf messen |
| Unklare Health-/Inventar-/Savebedienung erzeugt technische Scheinentscheidungen | Offene Regeln vor den betroffenen Implementierungsaufträgen bestätigen, nicht im Code verstecken |
| Gemeinsame Sandbox beeinflusst isolierte Tests | Benannte Testanker, feste Ausgangslage, Creature bei Bewegungstests deaktivieren, frischer Weltaufbau; bei belegtem Bedarf später trennen |
| Architektur funktioniert nur in der Sandbox | Dieselben Scripts und derselbe Main-Flow; früh echter Export, später kompletter Slice und menschliche Tests |

## 34. Offene Architekturentscheidungen

Bereits entschieden und nicht erneut zur Auswahl gestellt: First Person, kontrollierte Interaktion, vollständig geladener kleiner Slice, Godot-3D-Navigation, beide Speicherarten an geeigneten stabilen Zuständen, JSON/`user://`, Godot 4.7.2/GDScript/Windows x86-64. Folgende Restfragen behalten ihren offenen Status:

| Priorität / Zeitpunkt | Entscheidung oder Nachweis | Auswirkung |
| --- | --- | --- |
| Vor regulärer Grafikbasis | Tatsächliche CPU/GPU/VRAM, Referenzhardware und Rendererwahl durch Grafiktest (ADR-008) | Kein endgültiges Beleuchtungs-/Importbudget vorher; temporäre Testprofile sind keine Produktfreigabe |
| Vor verbindlichem Save-/Restore-Verhalten | Darf an bestimmten Search-Zuständen gespeichert werden? Welche sichere Gegner-Resetregel und Anker gelten? | Encounter-Schema/Restore und sichere Punkte werden erst danach abschließend umgesetzt |
| Vor Checkpoint-/manueller Savebedienung | Aktualisiert manuelles Speichern den Todes-Checkpoint? Empfehlung „Checkpoint erst nach I/O-Erfolg“ bestätigen | Bestimmt Paketerzeugung und Checkpoint-Promotion; beide Speicherarten bleiben Pflicht |
| Vor vollständiger Save-UI | Anzahl/Bedienung der Slots, konkrete Speicherorte/Auslöser und Versionskompatibilität | Pfad-/Schemaentwurf legt diese Spielregeln nicht fest |
| Vor Health und Ansichtsverhalten | Minimale Treffer-/Todesregel, Pause beim Lesen und Inventar | Schadensfrequenz, Timer und Eingabesicherungen abstimmen; keine Heilung erfinden |
| Vor verbindlichen Item-/Zugangsregeln | Kapazität, Stapeln, Nutzung/Auswahl, kritischer Itemschutz und Tempo-Wiederholungsregel | Inventory-Validierung und Puzzleverbrauch; Tempo nicht als Pflichtfluchtschlüssel |
| Im frühen Bewegungs-/Navigationstest | Kletter-/Sprunggrenzen, Türblockadereaktion, Navmesh-Linkkopplung und Verhalten bei unerreichbarem Spieler | Levelmaße/Fluchtwege vor Inhaltsproduktion absichern; keine Gegner-Teleports |
| Im Wahrnehmungs-/Audiotest | Hör-/Sichttuning, Dämpfung, Oberflächen, Audio-Workflow/Testsetup | Nachvollziehbare Gefahr und Warnung; keine globale Akustiksimulation |
| Vor regulärer Assetintegration | Austausch-/Importformate, Maßstab, Material-/Texturprofile | Quell-/Runtime-Trennung praktisch bestätigen |
| Vor konkreten Inhaltsaufträgen | Zwei Rätselregeln, Story-/Enthüllungsbedingungen, Reset-/Einmalfolgen und Levelplan | Neutrale Verträge genügen nicht zur Erfindung freigegebener Spielinhalte |
| Nach repräsentativen Messungen | Ressourcen-/Framezeit-/Ladebudgets, ggf. gezielte Entlastung | 16-GB-Tauglichkeit belegen; Ladestrategie nur bei nachgewiesenem Bedarf revidieren |

**Vor ROADMAP.md ist kein weiterer allgemeiner Architekturentscheid zwingend nötig**, sofern die Roadmap diese Entscheidungsschranken und Prototypnachweise ausdrücklich vor die jeweils abhängige Umsetzung setzt. Unbedingt zu klären sind sie vor den betroffenen Implementierungsaufträgen. Der vorliegende Architekturentwurf selbst benötigt noch Prüfung/Freigabe; er ist kein stiller neuer ADR-Beschluss.

## 35. Voraussetzungen für ROADMAP.md

Die spätere Roadmap kann aus folgenden Abhängigkeiten abgeleitet werden; dies ist keine Änderung der Roadmap und noch keine Aufgabenvergabe:

1. **Basis und erste Nachweise:** festgelegte Engine prüfen, Hardware erfassen/Renderervergleich planen, Main-Lebensdauer/Input/UI-Hülle und isolierte Testpfade vorbereiten. Früh einen minimalen Windows-Export testen.
2. **Risiken vor Inhalt:** Eine Sandbox schrittweise aufbauen: zuerst Motor/Kamera/Traversal, danach Tür/Navmesh/Link und lokale Interaktion ergänzen. Parallel dazu Datenverträge für Inventory/Save prüfen, ohne endgültige Rätsel-/Storyinhalte.
3. **Zustandsbesitzer verbinden:** IDs/Level-Validierung, Pickup/Inventory, freigegebene Healthregeln, einfache Puzzleverträge und lokale Progressdaten. Erst danach kann Save alle maßgeblichen Quellen verlässlich sammeln.
4. **Gefahr und Wiederanlauf:** Kreaturen-FSM, Sicht/Geräusche und Türnavigation im selben kleinen Testlevel abstimmen. Nach Freigabe der Savepolitik beide Speicherarten, Todeszuordnung, Restore und Fehlerfälle integrieren.
5. **Gestalteter Slice:** bestätigte Inhalte, reale Audio-/Assetintegration und Ablauf auf dieser getesteten Basis aufbauen; anschließend Profiling, Lesbarkeit, Atmosphäre und vollständiger Exportdurchlauf.

Nach festgelegten Verträgen können UI-Darstellung, reine Datentests und lokale Audio-/Assetaufbereitung unabhängig bearbeitet werden. Player/Traversal und Creature/Nav dürfen getrennt entwickelt, müssen aber früh an derselben Tür-/Geometriegrenze geprüft werden. Save/Restore ist **nicht** unabhängig von Level-IDs und Zustandsbesitz. Zwei konkrete Rätselinhalte sind **nicht** ohne Designfreigabe parallel zu erfinden.

Besonders prototypbedürftig: Bewegung/Traversalgefühl, Tür-/NavigationLinkkopplung, faire Sicht-/Hörsuche, sichere Restore-Anker sowie Rendering auf der realen GPU. Verstecken, Crafting/Kombinieren, Perspektivwechsel und spätere Abwehr erhalten keine Voraussetzungen im 0.1-Pflichtpfad.

## 36. Definition of Done

### Für diesen Architekturentwurf

- Vorgesehene Szenen, Scriptverantwortungen, Datenbesitzer und Abhängigkeitsrichtung sind beschrieben; konkrete Dateien und Node-Bäume sind vorgeschlagen.
- Player hat einen Positionsschreiber, Creature eine FSM, Türstellung und Puzzlefreigabe sind getrennt, Save enthält nur primitive Daten mit stabilen Identitäten.
- Beide Speicherarten und eigenständiger Todes-Wiederanlauf sind strukturell möglich; offene Reset-/Bedienregeln werden ausdrücklich nicht vorweggenommen.
- Lebensdauer, Pause, Restore-Synchronisation, Fehlerfälle, Debug und Testgrenzen sind konkret genug für nachfolgende Implementierungsaufträge.
- Performanceleitplanken passen zum kleinen Slice; Renderer/GPU und finale Budgets bleiben offen.
- Es wurden keine Szenen, Scripts, Projektkonfiguration, Assets oder Änderungen an anderen Planungsdokumenten benötigt.

### Spätere Implementierungsabnahme

Diese ist **noch nicht erfüllt**: Die offenen Regeln müssen für den jeweiligen Teilauftrag freigegeben, die geplanten Systeme implementiert und die TDD-Kriterien sowie §29 nachweisbar bestanden werden. Dazu gehören Neustart des installierten Spiels, beide Savearten, wiederholter Restore, faire KI, Flucht ohne Tempo-Item und überprüfter Ressourcenverbrauch. Architekturpapier allein ist kein Spiel- oder Funktionsnachweis.

### Konsistenzprüfung vom 19.09.2026

| Grundlage / Prüfpunkt | Ergebnis |
| --- | --- |
| GDD §§14–30 und offene Punkte | Pflichtbewegung, zwei Rätsel, eine Kreatur, beide Speicherarten, Audio/Story und optische Zielrichtung erhalten; keine neuen Inhalte oder optionalen Pflichten |
| TDD 0.2, besonders §§5, 11–17, 21–26 | Zustandsbesitz, eine KI-FSM, sichere tiefe Snapshots, lokales Ereignisleben, Restore-Reihenfolge und Testanforderungen übernommen und strukturell konkretisiert |
| ADR-001 bis ADR-004 | First Person, kontrollierte Objekte, vollständig geladener Bereich und kontrollierte Godot-Navigation umgesetzt |
| ADR-005/006 | Kein freies Gefahrenspeichern; manuelle Stände eigenständig; JSON unter user://; offene Reset-/Checkpointdetails sichtbar geblieben |
| ADR-007/008 | Engine/Exportziel übernommen, keine Rendererwahl erfunden |
| Overengineering | Null Autoloads; nach Review eine Sandbox, keine Geräuschdatenklasse, kein redundanter Restart-Modus und keine Schreibrevisionsfolge; weiterhin keine globalen Frameworks |
| Zyklen und Doppelzustände | Keine Besitzer-Rückreferenzen in Datenobjekten, direkte Aufträge und lokale Verbindungen statt unnötiger Relays; abgeleitete Zustände nicht doppelt persistent |

**Dokumentabgleich nach dem zweiten Review: keine fachlichen Widersprüche festgestellt.** Die angenommenen ADRs lösen nur die dort genannten früher offenen Teilfragen. Die reduzierte Navigationskopplung betrifft ausschließlich nachweislich irrelevante Türen und ändert keine Zugangsregel. Beide Speicherarten samt eigenständigem Wiederanlauf, zwei Rätsel, eine Kreatur, sämtliche Pflichtbewegungen sowie offene Designentscheidungen bleiben erhalten.

**Reviewurteil:** Version 0.2 ist als Planungsdokument aus technischer Sicht bereit zur Freigabe und anschließend für ROADMAP.md. Die offenen Entscheidungen aus §34 und die Prototypnachweise bleiben Schranken vor der jeweiligen Implementierung. Weder dieser Review noch die API-Prüfung ersetzen den frühen Tür-/Navigationstest, sichere Restore-Tests oder Messungen auf der tatsächlichen Hardware.

## 37. Dokumenthistorie

| Version | Datum | Änderung |
| --- | --- | --- |
| 0.1 | 19.09.2026 | Platzhalter durch konkreten Architekturentwurf auf Basis des freigegebenen GDD, TDD 0.2 und ADR-001 bis ADR-008 ersetzt. Main-basierte Lebensdauer ohne Autoloads, lokale Zustandsbesitzer, Szenen-/Dateiplan, Save-/Restore-Verträge, Tests und Entscheidungsschranken ergänzt. Keine Implementierung oder neue Spielinhalte. |
| 0.2 | 19.09.2026 | Zweiter kritischer Review: eine Sandbox statt zwei Testwelten, typisierte Noise-Signals statt eigener Datenklasse, direkte lokale Kommunikationswege, kleineres Save-Paket ohne redundante Felder, Navigationskopplung nur für nötige Durchgänge. Main-/Level-Grenzen, UI-Neubindung, Restore-/Triggerfreigabe, ID-Diagnosen und synchrone Änderungsgrenzen präzisiert. Main ohne Autoloads, RefCounted-Datenbesitzer und Kernprefabs begründet beibehalten. Godot-API- und Dokumentabgleich, keine Implementierung oder neuen Spielentscheidungen. |
