# Dark Rooms – Technical Design Document für Version 0.1

## 1. Dokumentstatus und Zweck

**Dokumentversion:** 0.2 · **Stand:** 19. September 2026

**Status:** Technischer Planungsentwurf nach zweitem Architektur- und Qualitätsdurchgang; keine implementierten oder bereits in Godot getesteten Systeme.

**Fachliche Quelle:** [GAME_DESIGN.md](GAME_DESIGN.md), freigegebener Stand einschließlich Autosave/Checkpoints plus manuellen Speicherpunkten sowie realistischer 3D-Grafik ohne Pixel-Art oder bewusst verpixelte Optik. GDD-Verweise beziehen sich auf dessen nummerierte Abschnitte; O-Nummern auf die offenen Fragen in GDD §32.

Dieses Dokument übersetzt die fachlichen Vorgaben in Systemverantwortlichkeiten, Informationsflüsse, Zustandsmodelle, Persistenzanforderungen und prüfbare Ergebnisse. Es dient anschließend als Grundlage für ARCHITECTURE.md, ROADMAP.md, Implementierungsaufträge an Codex, Reviews durch Claude Code und Tests in Godot. Es ersetzt keine dieser späteren Arbeiten.

### 1.1 Verbindlichkeit

| Kennzeichnung | Bedeutung |
| --- | --- |
| **FEST BESCHLOSSEN** | Vorgabe aus dem GDD oder dem aktuellen technischen Auftrag. Neue Vorgaben des Auftrags werden als solche benannt. |
| **TECHNISCHE ANFORDERUNG** | Notwendige funktionale oder Robustheitsanforderung zur Umsetzung des beauftragten Umfangs; keine neue Story- oder Gameplay-Festlegung. |
| **DESIGNEMPFEHLUNG** | Vorgeschlagene technische Lösung oder Konkretisierung. Auch bei ausführlicher Beschreibung noch keine endgültige Entscheidung. |
| **NOCH OFFEN** | Vor der betroffenen Umsetzung zu entscheidender Punkt. Die Priorisierung erfolgt in §30. |

Die Kennzeichnung gilt jeweils bis zur nächsten Kennzeichnung oder Unterüberschrift. Abnahmekriterien prüfen beschlossene Anforderungen; Kriterien für einen vorgeschlagenen Lösungsweg gelten erst, wenn dieser gewählt wurde. Empfehlungen aus dem GDD bleiben Empfehlungen. Eine grundsätzliche Freigabe des GDD wandelt dessen offene Fragen nicht automatisch in Festlegungen um.

**FEST BESCHLOSSEN – Ergänzungen des technischen Auftrags:** Godot 4 mit GDScript, kein C#/.NET für 0.1; Singleplayer; zunächst Desktop/Windows als praktisches Entwicklungs- und Testziel; 16 GB RAM am Entwicklungsrechner; Pause als Teil des 0.1-Kerns. Die GPU ist unbekannt. Windows konkretisiert das im GDD offene erste Testziel, legt aber keine endgültige Liste unterstützter Betriebssysteme fest.

**TECHNISCHE ANFORDERUNG:** Es entstehen hier keine endgültigen Scriptnamen, Klassenhierarchien, Node-Trees, Signalnamen oder Godot-Ordnerstrukturen. Die genannten Systeme sind Verantwortungsbereiche und müssen später nicht jeweils einer eigenen Klasse entsprechen. Konkrete Engine-Funktionen werden ausschließlich als Umsetzungskandidaten genannt.

## 2. Technische Leitprinzipien

**FEST BESCHLOSSEN:** Modulare, gut lesbare und wartbare Umsetzung; Assets, Spieldaten und Design möglichst engine-unabhängig halten. Fachlich haben Atmosphäre, Story und Rätsel Vorrang; Optik, Bewegung und Sound sind zentrale Qualitätsmerkmale. Es wird ein präsentabler Slice mit etwa 15–25 Minuten Inhalt geplant, kein bloßer Techniktest. Grundlage: GDD §§4–5, 30 und Projektregeln.

**DESIGNEMPFEHLUNG:** „So modular wie sinnvoll, so einfach wie möglich“ wird folgendermaßen konkret:

- Für jeden veränderlichen Zustand gibt es eine eindeutige zuständige Stelle. UI, Audio und Animation bilden ihn ab, statt eigene widersprechende Wahrheiten zu pflegen.
- Fachliche Daten wie Gegenstandstyp, Rätselzustand und Storymarkierung bleiben von sichtbaren Modellen, Sounds und Szenenreferenzen unterscheidbar.
- Spieleraktionen werden als Absicht geprüft und danach als bestätigte Zustandsänderung weitergegeben. Ein Tastendruck allein ist noch kein erfolgreicher Itemverbrauch.
- Speichern, Laden und Levelübergänge erfolgen an konsistenten Zustandsgrenzen. Eine halb abgeschlossene Aktion darf keinen dauerhaften Spielstand erzeugen.
- Konfiguration ersetzt verstreute Zahlen im Code. Nur tatsächlich benötigte Varianten werden gebaut; kein universelles Framework für hypothetische Spiele.
- Technische Fehler sind diagnostizierbar und führen nicht still zu Fortschrittsverlust. Fehlende optionale Darstellung darf die zugrunde liegende Spielregel nicht verändern.

**NOCH OFFEN:** Die späteren Modulgrenzen und Godot-Strukturen werden in ARCHITECTURE.md festgelegt. Dieses Dokument verlangt weder ein bestimmtes Entwurfsmuster noch einen globalen Event-Bus oder eine bestimmte Anzahl zentraler Manager.

### 2.1 Ergebnis des zweiten Architekturchecks

**DESIGNEMPFEHLUNG – ersetzt beziehungsweise präzisiert den Erstentwurf:** Die vielen Fachkapitel sind keine Aufforderung, ebenso viele Laufzeitsysteme zu bauen. Für 0.1 wird eine kleine, szenennahe GDScript-Umsetzung empfohlen: ein klarer Spielablauf, wenige zuständige Zustandsbereiche, eine Kreaturensteuerung und ein gemeinsamer Speicherweg. Chase/Search ist Teil der KI; Health und Tempoeffekt benötigen keine allgemeine Zustands- oder Effektplattform. Die konkrete Bündelung steht in §4.

Schwerpunkt der Überarbeitung sind ein eigenständig ladbarer Speicherstand, sichere Laufwechsel, eindeutige Bewegungszuständigkeit und eine realistische Navigation mit Türen. ARCHITECTURE.md kann diese Empfehlungen jetzt ausarbeiten. Offene Regeln werden nur dort zur Entscheidungsschranke, wo sie eine konkrete Implementierung beeinflussen; §30 ersetzt die bisher zu pauschale Startblockade.

## 3. Zielplattform und Entwicklungsumgebung

**FEST BESCHLOSSEN:** Ein echtes installierbares 3D-Spiel für den zunächst verwendeten Windows-Desktop; Tastatur und Maus in 0.1, Controller später. Godot 4 und GDScript ohne .NET. Keine Open World und kein Multiplayer im Kern. Realistisch wirkende, gut lesbare Grafik; keine Pixel-Art und keine bewusst verpixelte Optik. Die Entwicklung muss mit 16 GB RAM praktikabel bleiben.

**TECHNISCHE ANFORDERUNG:** Das Spiel muss außerhalb des Editors starten und den Slice vollständig ausführen können. Installation und Spielstart dürfen keine Entwicklungsumgebung voraussetzen. Speicherdaten müssen unabhängig vom Installationsordner in einem für den Benutzer beschreibbaren Bereich liegen. Ein neuer Durchlauf und ein späterer erneuter Programmstart müssen auf dem exportierten Spiel geprüft werden.

**DESIGNEMPFEHLUNG:** Eine konkrete stabile Godot-4-Version samt passenden Exportvorlagen für die Entwicklungsphase festhalten. Engine-Updates bewusst prüfen, nicht mitten in der Fehlersuche ungeprüft wechseln. Einen normalen Windows-Benutzer ohne Administratorrechte als Testfall vorsehen. Das Verpacken als Installer ist eine eigene Abschlussaufgabe; ein Editorstart oder bloßer Export ersetzt die Prüfung des installierten Spiels nicht. Grundlage für den späteren Export: [Godot: Exporting for Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).

**NOCH OFFEN:** Exakte Godot-Version, Windows-Versionen, Prozessorarchitektur des Exports, Installer-Verfahren, Referenz-CPU/GPU/VRAM, Bildschirmauflösung und Grafikprofil. 16 GB Arbeitsspeicher sagen nichts Verbindliches über die GPU-Leistung oder verfügbaren Grafikspeicher aus.

## 4. Systemübersicht

**TECHNISCHE ANFORDERUNG:** Die folgenden Verantwortlichkeiten decken den technischen Kern ab. Die Zuordnung dient der Nachverfolgbarkeit, nicht als Klassenplan.

| Verantwortungsbereich | Eingang und Verantwortung | Ergebnis / wichtigste Partner | Fachliche Basis |
| --- | --- | --- | --- |
| Spielablauf und Levelfluss | Start, Menü, Pause, Tod, Abschnittswechsel und Abschluss | Ein zuständiger Ablauf für Eingabefreigabe, Ladebeginn und spielbereite Welt | GDD §§23, 27, 29–30; Auftrag A |
| Spieler | Bewegung samt Traversal und Kamera; eigene Health- und Effektwerte | Ein Bewegungsverantwortlicher, Todesmeldung, tatsächliche Bewegung als Geräuschursache | GDD §§14, 18–19, 28 |
| Interaktion und Besitz | Zielprüfung, Pickup, Inventar, Itemnutzung und Taschenlampenbedienung | Bestätigte Aktion; Inventar besitzt Mengen, Taschenlampe ihren Schaltzustand | GDD §§15, 19 |
| Rätsel und Storyfortschritt | Kleine lokale Rätselregeln und eigenständige Storymarkierungen | Rätsel bestimmen ihre Freigaben; Story liest Bedingungen, ohne Rätselzustände zu duplizieren | GDD §§16, 21–22 |
| Kreatur | Wahrnehmung, Verhalten, Navigation sowie Chase/Search | Eine Steuerung; Bedrohungsstatus als lesbare Ausgabe für Darstellung und Story | GDD §§17–18; Auftrag K |
| Save / Restore | Zusammengehörige Zustände der zuständigen Bereiche lesen und wiederherstellen | Ein gemeinsamer Speicherweg für automatische und manuelle Auslöser | GDD §29 |
| Präsentation | UI und Audio beobachten bestätigte Zustände | Getrennte Darstellung und Tonwiedergabe ohne Entscheidungsgewalt über Fortschritt | GDD §§26–28 |

**DESIGNEMPFEHLUNG:** Diese Bündelung beschreibt zusammenhängende Verantwortungen, keine sieben großen Allzweckklassen. Kurze lokale Bausteine sind sinnvoll, wenn sie eine eigene Zuständigkeit oder Lebensdauer besitzen. Türen brauchen eine Freigabe und ihren eigenen Zustand, nicht den gesamten Spielercontroller. Audio und UI bleiben voneinander austauschbar; Rätsel und Story dürfen trotz gemeinsamer Fortschrittsauswertung nicht dieselben Fakten unabhängig speichern.

Die laufende Welt besitzt ihre aktuellen Werte; Save erzeugt daraus eine Datenkopie und führt keinen permanenten zweiten Live-Zustand. Für später entladene Bereiche darf ein Datenabbild aufbewahrt werden; dann ist dieser Bereich nicht gleichzeitig als aktive Weltinstanz zuständig. Im zunächst kleinen vollständig geladenen Abschnitt entfällt diese Zusatzlogik.

## 5. Game Flow

**FEST BESCHLOSSEN:** Spielstart, Startmenü, Neues Spiel, Pause, Game Over, Neustart am Checkpoint und Slice-Abschluss gehören zum Kern. Grundlage: GDD §§27, 29–30 und Auftrag A.

**TECHNISCHE ANFORDERUNG:** Zu jedem Zeitpunkt ist eindeutig, ob die Welt aktiv gespielt, pausiert, geladen oder beendet wird. Menüs dürfen keine gleichzeitigen Bewegungs-/Interaktionsbefehle in die Welt durchreichen. Tod und Abschluss werden pro Vorgang nur einmal verarbeitet. Während Restore darf weder die Kreatur Schaden verursachen noch der Spieler einen neuen Speicherstand anfordern.

**DESIGNEMPFEHLUNG:**

| Phase | Verhalten | Erlaubter nächster Schritt |
| --- | --- | --- |
| Programmstart | Einstellungen und benötigte Basisdaten prüfen | Startmenü oder verständliche Fehlermeldung |
| Startmenü | Maus frei, Spielsimulation inaktiv | Neues Spiel; Laden/Fortsetzen nach gewähltem Bedienkonzept |
| Neues Spiel / Laden | Welt vorbereiten, Startdaten oder Snapshot vollständig anwenden | Spielen erst nach erfolgreicher Prüfung |
| Spielen | Bewegung, Interaktion, KI und Spielzeit aktiv | Pause, Niederlage, Levelübergang, Abschluss |
| Pause | Bewegung, KI, Schaden und Gameplay-Timer angehalten; UI bedienbar | Zum selben konsistenten Zustand zurückkehren |
| Game Over | Aktuelle Welt nicht weiter als gültigen Fortschritt speichern | Letzten Checkpoint wiederherstellen oder ins Menü |
| Restore | Eingaben sperren, alten Lauf beenden, gültigen Snapshot aufbauen | Spielen oder Fehler mit Rückweg ins Menü |
| Slice-Abschluss | Fortschritt einmal markieren, Abschluss zeigen | Menü beziehungsweise Ende nach festgelegtem Ablauf |

Ein anfänglicher gültiger Wiederanlaufpunkt wird beim Beginn des ersten Abschnitts vorbereitet. Damit funktioniert eine Niederlage auch vor dem ersten später erreichten Checkpoint. Ein vorhandener Spielstand darf durch „Neues Spiel“ nicht unbemerkt zerstört werden; die konkrete Auswahl oder Bestätigung hängt vom offenen Spielstandkonzept ab.

**NOCH OFFEN:** Menüpunkt für Laden/Fortsetzen, genaue Abschlussbedienung, Verhalten bei Fenster-Fokusverlust sowie Pausenverhalten beim Lesen und im Inventar.

**DESIGNEMPFEHLUNG:** Inventar und Textansicht zunächst wie Pause behandeln; die Auswirkung auf Bedrohung muss vor Umsetzung bestätigt werden.

### 5.1 Pause, Laden und Lebensdauer auseinanderhalten

**DESIGNEMPFEHLUNG:** Godots vorhandene Pausen-/Verarbeitungsregeln nutzen, statt eine zweite globale Zeitverwaltung zu entwickeln. Trotzdem prüft jede wirksame Aktion, ob der aktuelle Lauf sie zulässt: Godot-Signale können auch an pausierten Objekten ausgeführt werden. UI und Ladebedienung müssen aktiv bleiben, während Gameplay angehalten ist. Siehe [Godot: Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html).

Restore ist keine gewöhnliche Menüpause. Für die Vorbereitung dürfen notwendige Engine-Aktualisierungen stattfinden, während Spielermotor, KI, Schaden und Spielereignisse ausdrücklich gesperrt bleiben. Eine pausierte Physik und gleichzeitiges Warten auf deren Bereitschaft darf keinen Lade-Stillstand erzeugen. Es gibt höchstens einen aktiven Lade-/Restore-Vorgang; konkurrierende Anfragen werden abgelehnt oder nacheinander bearbeitet.

Nach Levelwechsel oder Neustart werden alte Verbindungen und gehaltene Weltreferenzen gelöst. Verzögerte Ergebnisse prüfen, ob sie noch zum aktuellen Lauf gehören; Ergebnisse aus einem abgebrochenen Lauf werden verworfen. Ein einfacher Laufbezug genügt, falls überhaupt asynchrone Arbeit nötig ist. Verschachtelte Ansichten geben Eingaben erst frei, wenn keine andere aktive Sperre mehr besteht; das Schließen eines Inventarfensters darf beispielsweise keinen Game Over aufheben.

## 6. Player Controller

**FEST BESCHLOSSEN:** Laufen, Sprinten, Springen, Ducken, grundlegendes Klettern/Parkour und Kamerasteuerung; zunächst eine technisch bevorzugte Hauptperspektive. Ein Perspektivwechsel bleibt optional. Grundlage: GDD §§14, 28 und Auftrag B.

**TECHNISCHE ANFORDERUNG:** Eingabe, Kollisionsprüfung und Bewegungszustand müssen übereinstimmen. Die Figur darf beim Aufstehen nicht in eine niedrige Decke ragen, beim diagonalen Gehen keinen unbeabsichtigten Geschwindigkeitsvorteil erhalten und nach einem Laden keine alte Eingabe oder Geschwindigkeit weiterführen. Pause, Tod und Restore sperren die relevanten Bewegungen. Die Kamera darf keine Interaktion durch verdeckende Wände ermöglichen.

**DESIGNEMPFEHLUNG:** Eingabeabsicht von tatsächlicher Bewegung trennen und Bewegung in Godots Physikverarbeitung auswerten. `CharacterBody3D` ist ein geeigneter Kandidat für eine kontrollierte Figur mit Kollisionsreaktion; seine Verwendung legt noch keinen Node-Tree fest. Siehe [Godot: CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html).

Die Basiskonfiguration bestimmt Tempo, Beschleunigung, Abbremsung und Sprung. Ein aktiver Tempoeffekt verändert das berechnete Tempo, überschreibt aber nicht dauerhaft den Grundwert. Animation und Schrittgeräusche folgen der tatsächlichen Bewegung, nicht allein der gedrückten Taste. Blickempfindlichkeit und visuelle Kamerabewegung werden getrennt abgestimmt.

Normale Fortbewegung und Traversal dürfen die Position nicht im selben Schritt unabhängig verändern. Der Spielermotor führt die jeweils freigegebene Bewegung aus; Kamera und Animation folgen dem Ergebnis. Kein zusätzlicher Positionsschreiber durch eine Kletteranimation. Mauseingabe ist von kontinuierlicher Bewegungseingabe zu unterscheiden, damit Blickempfindlichkeit nicht versehentlich mit der Bildrate skaliert. Kleine Eingabetoleranzen beim Springen können getestet werden, bleiben aber eine optionale Tuningempfehlung.

Physik- und Darstellungstakt müssen auch bei schwankender Bildrate zusammenpassen. Falls Physikinterpolation verwendet wird, ist ihre Historie nach Teleport oder Restore zurückzusetzen, damit die Kamera nicht durch den alten Weg gleitet. Grundlage: [Godot: Using physics interpolation](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/using_physics_interpolation.html).

**NOCH OFFEN:** First Person oder Third Person, erlaubte Steigungen und Kanten, Sprung-/Luftkontrolle, Duckbedienung, Ausdauer und Fallfolgen.

**DESIGNEMPFEHLUNG:** First Person zunächst als einfacheren Kandidaten für unmittelbaren Horror und die Beschränkung auf eine Kamera evaluieren; diese Empfehlung entscheidet GDD O-03 nicht. Third Person wäre eine ebenso zulässige bewusste Auswahl mit zusätzlichen Anforderungen an Kamerakollision und Figurenpräsentation.

## 7. Player State / Health

**FEST BESCHLOSSEN:** Lebenspunkte, Schaden, Tod, Game Over und Rückkehr zum Checkpoint; ein temporärer Geschwindigkeitseffekt. Konkrete Werte bleiben konfigurierbar. Kein zusätzliches Hunger-, Durst- oder Temperatursystem. Grundlage: GDD §§18–19 und Auftrag C/G.

**TECHNISCHE ANFORDERUNG:** Gesundheit besitzt eine eindeutige Zuständigkeit. Schaden wird nur auf einen gültigen lebenden Spieler angewandt, innerhalb gültiger Wertebereiche verarbeitet und mit Ursache und Ergebnis gemeldet. Der Übergang zu tot darf nicht mehrere Game-Over-Abläufe auslösen. Ab diesem Übergang werden Nutzung, Bewegung und erneuter Schaden kontrolliert unterbunden.

**DESIGNEMPFEHLUNG – korrigiertes Zustandsmodell:** Wenige getrennte Werte statt eines großen Kombinationsautomaten verwenden. Insbesondere sind Ducken, Sprintwunsch und Eingabesperre keine gegenseitig ausschließenden Bewegungszustände:

| Achse | Fachlich relevante Zustände | Umgang beim Restore |
| --- | --- | --- |
| Leben | Lebendig, verletzt, tot; „verletzt“ zunächst als Darstellung vorhandenen Schadens, ohne automatische Bewegungseinbuße | Lebenspunkte des Snapshots anwenden; Lebensstatus konsistent daraus herstellen |
| Fortbewegung | Am Boden, in der Luft oder in kontrolliertem Traversal | Aus gültiger Spawnposition neu bestimmen; keine alte Geschwindigkeit oder halbe Traversal-Bewegung übernehmen |
| Haltung / Bewegungsabsicht | Stehend oder geduckt; Gehen/Sprinten als zulässige Absicht nach der noch festzulegenden Regel | Erforderliche Haltung anwenden; Sprintwunsch nicht als dauerhaftes Save-Faktum behandeln |
| Aktionsfreigabe | Durch Game Flow, Tod oder Interaktionsansicht eingeschränkt | Aus neuem Lauf und aktiven Ansichten ableiten; niemals blind aus dem Save entsperren |
| Temporäre Wirkung | Kein Tempoeffekt oder aktiver Effekt mit verbleibender Spielzeit | Gespeicherte Restzeit einmal anwenden; nicht erneut die volle Dauer gewähren |

Gameplay-Timer zählen nur während freigegebenen Spiels weiter; Godots Verarbeitung liefert dafür die gemeinsame Grundlage (§5.1), ohne einen zusätzlichen Zeitdienst zu verlangen. Der Effekt darf nach Ablauf den aktuellen Grundzustand wiederherstellen, auch wenn zwischenzeitlich Ducken oder Sprinten aktiv wurde. Ein späteres Heilereignis würde denselben Gesundheitsbereich verwenden, ist aber noch keine zugesagte Heilmechanik.

**TECHNISCHE ANFORDERUNG:** Ein bestätigter Treffer darf nicht durch mehrere Kontaktmeldungen oder Animation und Kollision doppelt gezählt werden. Eine Schadensprüfung muss einen aktuell zulässigen Treffer einschließlich Reichweite und Hindernissen nachweisen; Nähe zu einer Kreatur hinter einer geschlossenen Wand genügt nicht. Welche Angriffs-/Trefferregel gewählt wird, bleibt offen. Technische Doppelverarbeitung und mehrere fachlich erlaubte Treffer sind zu unterscheiden.

**NOCH OFFEN:** Maximale Lebenspunkte, Schaden, Trefferabstände, Unverwundbarkeitsfenster, Heilung/Regeneration, Bedeutung der Verletzungsanzeige und sofort tödliche Situationen. Für einen ersten Schadenstest ist eine ausdrücklich vereinbarte vorläufige Regel nötig; Testwerte sind keine endgültigen Gameplaywerte.

## 8. Interaktionssystem

**FEST BESCHLOSSEN:** Türen, Schalter, Pickups, Story-Hinweise und Rätselobjekte müssen mit kontextbezogenen Hinweisen bedienbar sein. Grundlage: GDD §15 und Auftrag D.

**TECHNISCHE ANFORDERUNG:** Das System ermittelt ein gültiges Ziel, die angebotene Handlung und deren Voraussetzungen. Bei Ausführung werden Entfernung, Erreichbarkeit, Spielzustand und Objektzustand erneut geprüft. Ein inzwischen aufgenommenes Item oder deaktivierter Schalter darf durch wiederholte Eingabe nicht doppelt wirken. Ablehnung erhält eine passende Rückmeldung, etwa fehlende Voraussetzung oder volles Inventar.

**DESIGNEMPFEHLUNG:** Ein einheitlicher Ablauf: Ziel erkennen → mögliche Handlung beschreiben → Anfrage prüfen → Änderung vollständig ausführen → Ergebnis melden. Türen und Schalter zunächst mit definierten logischen Zuständen und kontrollierten Übergängen statt frei simulierter Physik planen. Ein offener Türflügel, seine Kollision, seine Verriegelung und sein Interaktionshinweis müssen denselben Zustand darstellen.

Ein Pickup verschwindet erst, wenn das Inventar die Aufnahme bestätigt hat. Bei Türbewegung durch den Spielerraum wird nicht blind Kollision über den Spieler geschoben; Stoppen beziehungsweise Zurückstellen ist ein zu prüfender Vorschlag.

Freigabe und tatsächliche Durchquerbarkeit einer Tür unterscheiden: „Entriegelt“ bedeutet nicht zwingend „offen“. Der Türzustand beschreibt zusätzlich geschlossen, öffnend, offen oder schließend, soweit diese Übergänge verwendet werden. Eine Animation ist Darstellung dieses Zustands; Kollisions- und Navigationsfreigabe folgen dem tatsächlich ausreichend offenen Durchgang. Nummerierte Kollisionslayer werden erst in ARCHITECTURE.md festgelegt; zuvor muss feststehen, was Bewegung, Sicht, Interaktion und Treffer jeweils blockiert.

**NOCH OFFEN:** Reichweite, Zielauswahl in der gewählten Perspektive, Drücken/Halten, Türverhalten bei Hindernissen und physische gegenüber vereinfachter Interaktion. Komplexes Greifen/Ziehen ist keine Voraussetzung des Kerns.

## 9. Inventar und Items

**FEST BESCHLOSSEN:** Kleines Inventar, Taschenlampe, Tempo-Verbrauchsgegenstand sowie Unterstützung für Rätsel-/Zugangs- und Story-Gegenstände. Kritische Gegenstände dürfen keinen unlösbaren Spielstand verursachen. Grundlage: GDD §19 und Auftrag E.

**TECHNISCHE ANFORDERUNG:** Gegenstandsdefinition, konkreter Bestand und Weltfund müssen unterscheidbar sein. Eine Aufnahme erhöht den Bestand und markiert denselben Weltfund als eingesammelt; eine Nutzung prüft Besitz, erlaubten Zustand und Wirkung, bevor die Anzahl sinkt. Bestandsänderung und Wirkung dürfen nicht durch einen Speicheraufruf auseinandergerissen werden. Weltfunde erhalten dauerhafte Identitäten, damit Laden keine Duplikate erzeugt.

**DESIGNEMPFEHLUNG:** Unverzichtbare Gegenstände zunächst nicht wegwerfbar machen und ihre Aufnahme bei vollem Inventar durch reservierte Kapazität oder getrennte Verwaltung absichern. Welche der beiden Lösungen gilt, bleibt offen. Storyinformationen unabhängig von der begrenzten Nutzgegenstandsfläche erneut zugänglich halten. Bereits in ein Rätsel eingesetzte Gegenstände werden über den Rätselzustand nachgewiesen und nicht zugleich als freier Besitz behandelt.

Der Tempo-Gegenstand ist ein Vorteil, keine zwingende Eintrittskarte für die Flucht. Eine frühzeitige Nutzung darf den Slice nicht blockieren. Mehrfachnutzung während aktiver Wirkung wird entweder begründet abgelehnt oder nach einer ausdrücklich gewählten Erneuerungsregel verarbeitet; unkontrolliertes Stapeln ist auszuschließen.

**NOCH OFFEN:** Inventargröße und Bedienung, Stapelbarkeit, Auswahl/Benutzung, Abwerfen, Schutz kritischer Gegenstände, konkrete Gegenstände und Effekt-Erneuerung. Die im GDD empfohlenen vier bis sechs Plätze sind keine verbindliche Kapazität.

## 10. Taschenlampe

**FEST BESCHLOSSEN:** Ein-/Ausschalten und erkennbare Lichtwirkung; kein Batterieverbrauch als Pflichtsystem für 0.1. Realistische Lesbarkeit ohne dauerhafte extreme Dunkelheit. Grundlage: GDD §§19, 24–25 und Auftrag F.

**TECHNISCHE ANFORDERUNG:** Besitz beziehungsweise Verfügbarkeit und eingeschalteter Zustand sind getrennt. Ohne verfügbare Taschenlampe darf kein Licht aktiv bleiben. Nach Laden müssen Licht, Bedienbarkeit und gespeicherter Schaltzustand übereinstimmen. Licht und Schatten dürfen keinen Durchblick durch undurchsichtige Wände vortäuschen, der Rätsel oder Orientierung verfälscht.

**DESIGNEMPFEHLUNG:** Batterieverbrauch zunächst weglassen. Lichtparameter als Konfiguration behandeln und den Lichtzustand von Darstellung und Eingabe trennen; so lässt sich eine später ausdrücklich gewünschte Ressource ergänzen. Eine Taschenlampe wird nicht automatisch zu einem KI-Geräusch oder Sichtbarkeitsbonus des Spielers.

**NOCH OFFEN:** Reichweite, Lichtkegel, Helligkeit, Schattenprofil, Anfangsbesitz und Reaktion der Kreatur. Batterie-UI und Ressourcenverbrauch werden nicht vorsorglich als Kernsystem gebaut.

## 11. Puzzle-System

**FEST BESCHLOSSEN:** Mindestens zwei unterschiedliche Rätsel mit Schwerpunkt Schalter/Türen. Lösbarkeit, Rücksetzbarkeit und Speichern müssen technisch unterstützt werden. Die endgültigen Rätsel sind offen; die beiden GDD-Beispiele bleiben Vorschläge. Grundlage: GDD §16 und Auftrag I.

**TECHNISCHE ANFORDERUNG:** Jedes Rätsel besitzt Identität, zulässige Eingaben, Voraussetzungen, Teilzustand und eine eindeutig prüfbare Lösung. Es muss feststehen, welches System einen zugehörigen Schalterzustand oder eine Türfreigabe bestimmt. Wiederholte Auswertung einer bereits vorhandenen Lösung darf keine zusätzlichen Gegenstände, Freigaben oder Storyereignisse erzeugen.

**DESIGNEMPFEHLUNG:** Einen kleinen gemeinsamen Vertrag vorsehen: Eingabe prüfen, Zustand ändern, Ergebnis melden, Zustand beschreiben und aus gespeicherten Daten wiederherstellen. Die konkrete Rätsellogik bleibt je Rätsel individuell. Kein visueller Rätseleditor und keine allgemeine Skriptsprache sind für zwei Rätsel nötig.

Teilfortschritt umfasst beispielsweise aktivierte Bedienelemente oder bereits bestätigte Eingabeschritte, ohne hier eine bestimmte Lösung festzulegen. Ein Fehlversuch setzt nur den fachlich vorgesehenen Teil zurück. Ein Entwickler-Reset muss stets möglich sein; ein Resetknopf im fertigen Spiel ist dadurch nicht beschlossen. Ein angewandter Lösungszustand wird beim Laden direkt dargestellt, statt die gesamte Lösungssequenz erneut als Gameplay abzuspielen.

Für jede Verknüpfung festhalten, ob ein Rätsel eine Tür entriegelt, unmittelbar öffnet oder lediglich eine weitere Bedingung erfüllt. Eine gelöste Aufgabe und ein geschlossener, aber bedienbarer Türflügel sind nicht automatisch ein Widerspruch. Weder Tür noch Story speichern zusätzlich ein zweites unabhängiges „Rätsel gelöst“. Beim Restore wird die Freigabe aus dem zuständigen Rätselzustand abgeleitet.

Für zwei Rätsel genügt eine manuelle Prüfung ihrer Voraussetzungen: Kein benötigter Schalter oder Gegenstand liegt ausschließlich hinter dem Zugang, den er erst ermöglichen soll. Auch Rückwege, eingesetzte Items und einseitige Türen gehören in diese Prüfung. Dafür keinen allgemeinen Lösbarkeitsbeweiser bauen. Rätsel-Fortschrittsänderungen und unmittelbar notwendige Folgeänderungen müssen vor einem Snapshot abgeschlossen sein; ihre sichtbare Animation darf später enden.

**NOCH OFFEN:** Auswahl der Rätsel, Eingaben, Zurücksetzregeln bei Fehlversuchen, Hilfen, Verbrauch von Rätselgegenständen und Zustände verbundener Türen. Für 0.1 ist keine Craftingmechanik als Rätselvoraussetzung zulässig, solange sie optional bleibt.

## 12. Creature AI

**FEST BESCHLOSSEN:** Eine Kreatur/ein Gegnertyp in 0.1. Patrouille, Sicht- und Geräuschreaktion, Verfolgung, Sichtverlust, Suche und Rückkehr müssen unterstützt werden. Keine permanente Kenntnis der Spielerposition. Grundlage: GDD §17 und Auftrag J.

**TECHNISCHE ANFORDERUNG:** Wahrnehmung liefert nur Informationen, die die Kreatur tatsächlich erhalten hat. Verhalten entscheidet über ein Ziel, Navigation über einen erreichbaren Weg und Bewegung über dessen kollisionsgeprüfte Ausführung. Ein Navigationsproblem ist kein neuer Beweis für die Position des Spielers.

**DESIGNEMPFEHLUNG:** Ein überschaubares Zustandsmodell genügt zunächst. „Geräusch wahrnehmen“, „Spieler sehen“ und „Sicht verlieren“ sind dabei Ereignisse; sie benötigen nicht zwingend eigene dauerhaft aktive KI-Zustände.

| Zustand / Ereignis | Reaktion und Übergangsbedingung | Verwendete Information |
| --- | --- | --- |
| Patrouille | Definierte erreichbare Ziele ablaufen; relevantes Geräusch führt zur Untersuchung | Patrouillenbereich, keine versteckte Spielerortung |
| Geräusch wahrnehmen | Kandidat nach Reichweite, Intensität und Relevanz prüfen | Ereignisort und Zeitpunkt |
| Geräusch untersuchen | Wahrgenommenen Ort erreichen oder dessen Umgebung prüfen | Eingefrorener Ereignisort, kein mitwanderndes Spielerziel |
| Spieler sehen | Bestätigte Sicht führt zur Verfolgung | Aktuell sichtbare Position |
| Verfolgen | Auf bestätigte neue Sichtinformation reagieren | Letzte gültige Sichtung und bekannte Wege |
| Sicht verlieren | Letzte Sichtposition behalten, keine unsichtbaren Aktualisierungen beziehen | Ort/Zeit der letzten Sichtung |
| Suchen | Letzten bekannten Bereich erreichen und begrenzt absuchen | Erreichbare Suchpunkte; neue Wahrnehmung kann unterbrechen |
| Suche abbrechen | Nach konfiguriertem Ende ohne neue Hinweise Rückkehr beginnen | Keine neue Zielposition aus dem Spielerobjekt |
| Zur Patrouille zurückkehren | Gültigen Einstieg in die Route finden, dann patrouillieren | Eigene Route und Navigation |

Bestätigte Sicht hat bei konkurrierenden Reizen zunächst Vorrang vor einem schwächeren Geräusch. Das ist eine Empfehlung; Prioritäten und Übergangszeiten müssen nachvollziehbar konfiguriert werden. Die Darstellung soll Wechsel erkennbar machen, ohne vollständige interne KI-Daten im HUD zu zeigen.

Für 0.1 genügt ein endlicher Automat mit Patrouille, Untersuchung, Verfolgung, Suche und Rückkehr. Ein-/Ausgeschaltet wegen Levelphase oder Restore ist eine Lebensdauerfreigabe, keine zusätzliche intelligente Verhaltensschicht. Keine parallele Behavior-Tree-, Planungs- oder eigene Chase-Steuerung vorsehen. Die Suche nutzt wenige gültige Punkte nahe der letzten Wahrnehmung, mit begrenzter Dauer und begrenzten Neuplanungsversuchen. Auch Untersuchung und Rückkehr benötigen einen Ausgang bei unerreichbarem Ziel.

Neue Reize dürfen die KI nicht in jedem Bild zwischen Zuständen umschalten lassen. Wiederholungen desselben bereits verarbeiteten Geräuschs verlängern eine Suche nicht unbegrenzt; wirklich neue Wahrnehmungen werden nach der gewählten Regel bewertet. Kurze Stabilisierung von Wahrnehmungswechseln ist ein Tuningkandidat, keine zusätzliche Kenntnis unsichtbarer Positionen. Mit diesen Grenzen ist der beauftragte KI-Umfang für eine Kreatur realistisch; eine allgemeine intelligente Raumsuche ist nicht erforderlich.

Für die kleine begehbare Umgebung sind Godots 3D-Navigation und `NavigationAgent3D` Kandidaten. Wegsuche, physische Kollision und Hindernisvermeidung sind zu unterscheiden: Avoidance ersetzt keine begehbare Route und verändert nicht automatisch die Wegsuche. Siehe [Godot: Using NavigationAgents](https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html).

**DESIGNEMPFEHLUNG – Navigation konkretisiert:** Vorberechnete begehbare Flächen und wenige ausdrücklich gesteuerte Durchgänge bevorzugen; nicht bei jeder Türbewegung den gesamten Level neu berechnen. Bei geschlossenen Türen muss die entsprechende Routenverbindung tatsächlich unbenutzbar sein, etwa über getrennte Flächen und eine schaltbare Verbindung. Eine zusätzliche physische Tür allein verhindert die Wahl eines falschen Pfades nicht. Die konkrete Lösung bleibt T-04.

Für eine Kreatur Hindernisvermeidung nur einschalten, wenn ein nachgewiesener dynamischer Konflikt sie benötigt. Pfadverfolgung benötigt regelmäßige Aktualisierung; neue Wegsuche nicht mit jedem Bild ungeprüft neu anfordern. Erst nach Synchronisation der Navigationsdaten Ziele abfragen. Diese Unterscheidung vermeidet leere Startpfade und flackernde Richtungswechsel; siehe die oben verlinkte Godot-Dokumentation.

Ein sichtbarer Spieler auf einer absichtlich nicht erreichbaren Stelle ist kein Navigationsdefekt. Die Kreatur kennt dort gegebenenfalls seine sichtbare Position, kann aber keinen Weg erzwingen; das Verhalten benötigt eine freigegebene Grenze und einen kontrollierten Ausgang. Ein ungültiges Navigationsnetz im Pflichtweg ist dagegen ein technischer Fehler. Keinen dieser Fälle durch Teleportieren zum Spieler, Wanddurchtritt oder direkten Schaden über eine Blockade kaschieren.

**NOCH OFFEN:** Endgültiges Navigationsverfahren, Türdurchquerung, erreichbare Parkourverbindungen, Patrouillen-/Suchraum, Reizprioritäten, Sicht-/Hörgrenzen, Geschwindigkeiten und Zeiten. Weder Gestalt noch Stimme oder Hintergrund der Kreatur werden hier festgelegt.

## 13. Wahrnehmung / Sicht / Geräusche

**FEST BESCHLOSSEN:** Die Kreatur reagiert auf Sicht und vorgesehene Geräusche. Unterschiedliche Spielerhandlungen können unterschiedliche Geräuschintensitäten erzeugen; weitere Geräuschquellen sollen ergänzbar sein. Grundlage: GDD §§14, 17, 26 und Auftrag K.

**TECHNISCHE ANFORDERUNG:** Sicht prüft Reichweite, Blickrichtung und Verdeckung. Eine Position hinter einer undurchsichtigen Wand darf nicht als sichtbarer Spieler weitergegeben werden. Wahrnehmungsinformationen besitzen Quelle, Ort und Aktualität. Eine gespeicherte Erinnerung ist ausdrücklich keine aktuelle Sichtung.

**DESIGNEMPFEHLUNG:** Spielerbewegung meldet diskrete Geräusche für tatsächliche Schritte, Landungen oder ausdrücklich lärmerzeugende Interaktionen. Ein fachliches Geräuschereignis enthält Quellidentität, Position zum Ereigniszeitpunkt, Art, Intensität und Spielzeitpunkt. Die Hörwahrnehmung beurteilt es mit konfigurierter Reichweite und Dämpfung. Sprinten wird gegenüber vorsichtigem Bewegen als auffälligerer Tuningkandidat geprüft, nicht mit endgültigen Zahlen festgelegt.

Hörbare Wiedergabe und KI-Geräuschereignis entstehen aus derselben bestätigten Aktion, bleiben aber getrennte Ausgaben. Die KI liest keine Lautsprecherlautstärke und analysiert keine Audiodatei. Stummschalten des Spiels ändert ihre Wahrnehmung nicht. Eine fehlende Schrittdatei darf im Entwicklungstest die Hörlogik nicht aushebeln, ist jedoch vor Abnahme als fehlende Spielerinformation zu beheben.

Zunächst eine einfache dokumentierte Hörregel für Entfernung und Hindernisse wählen. Vollständige Schallausbreitung durch sämtliche Räume ist nicht erforderlich. Sichtverdeckung, akustische Dämpfung und Navigationsblockade sind unterschiedliche Eigenschaften und dürfen nicht als eine einzige Wahr/Falsch-Regel verwechselt werden.

Ereignisse besitzen eine begrenzte Gültigkeit und gehören zum aktuellen Lauf. Eigene Geräusche der Kreatur, reine UI-Töne und dekorative Ambience lösen nur dann KI-Reaktionen aus, wenn dies ausdrücklich vorgesehen ist; im einfachen Startumfang werden sie nicht als Spielerreiz behandelt. Physische Interaktion und Schallprüfung dürfen keine Rückkopplungsschleife aus Hören, Bewegen und erneutem Selbsthören erzeugen. Für eine Kreatur ist kein räumlicher Index oder allgemeiner Akustikserver notwendig.

**NOCH OFFEN:** Sichtprüfpunkte an der Figur, Abtastraten, Schwellen, Schrittabstände, Oberflächenfaktoren und Dämpfung durch Türen/Wände. Lichtabhängige Sichtbarkeit und Taschenlampenerkennung sind weiterhin unbeschlossen. Debuganzeigen müssen nachvollziehbar machen, welche Regel eine Erkennung ausgelöst hat.

## 14. Chase-/Search-Auswertung innerhalb der Kreaturensteuerung

**FEST BESCHLOSSEN:** Verfolgungsbeginn, aktive Verfolgung, Sichtverlust, Suche, erfolgreiches Entkommen sowie Tod/Neustart werden unterstützt. Verfolgung darf nicht ausschließlich aus geskripteten Abläufen bestehen; Inszenierung kann ergänzen. Grundlage: GDD §§17–18, 30 und Auftrag L.

**TECHNISCHE ANFORDERUNG:** Eine Verfolgung beginnt aufgrund einer gültigen KI-Entscheidung. Sichtverlust ist noch kein automatisch erfolgreiches Entkommen. Erst die abgeschlossene Suche ohne erneute Wahrnehmung kann das entsprechende Ergebnis auslösen. Stirbt der Spieler, hat der Todesablauf Vorrang vor einer Flucht-Erfolgsmeldung.

**DESIGNEMPFEHLUNG – vereinfacht:** Ruhig, verfolgt und gesucht aus dem einzigen KI-Zustandsmodell ableiten; „entkommen“ ist das einmalige Ergebnis einer beendeten Bedrohung, kein unabhängig gespeicherter Dauerzustand. Audio, UI und Story beobachten diese Ausgabe. Keine zweite Zustandsmaschine und keine zweite Suchuhr bauen. Eine inszenierte erste Begegnung darf Verfügbarkeit oder Ausgangsbedingungen der Kreatur setzen; nach Beginn muss der Verlauf auf Wahrnehmung und tatsächlicher Bewegung beruhen. Fortschrittsrelevanter Begegnungsabschluss gehört zur Story-/Levelmarkierung, nicht zu einem zusätzlichen Chase-Save.

Bei Neustart werden alte Suchzeiten, Verfolgungsmeldungen und zugehörige Audioanforderungen beendet. Die Kreatur wird nach der in §17 festgelegten Restore-Politik vorbereitet. Ohne Tempo-Gegenstand muss ein vorgesehener Ausweg bestehen; optionales Verstecken darf dafür nicht notwendig sein.

**NOCH OFFEN:** Exakte Beginn-/Endbedingungen der ersten Begegnung, Suchdauer, Erfolgsvoraussetzungen für Storyfortschritt und gegebenenfalls Regeln für Rätsel während Gefahr. Die technische Schnittstelle unterstützt solche Bedingungen, erfindet sie aber nicht.

## 15. Parkour / Traversal

**FEST BESCHLOSSEN:** Einfache klar erkennbare Hindernisse, grundlegendes Klettern und Überwinden gehören zum Slice. Schwimmen, umfangreiches Rutschen und komplexes Greifen/Ziehen sind kein Pflichtumfang. Grundlage: GDD §14 und Auftrag M.

**TECHNISCHE ANFORDERUNG:** Ein Traversal-Vorgang beginnt nur mit gültigem Einstieg, erreichbarem Ziel und ausreichend freiem Platz für die Figur. Das Ziel darf nicht hinter einer geschlossenen Tür oder in einer Wand liegen. Beginn, laufende Bewegung, Ende und Unterbrechung müssen kontrolliert sein. Tod und Restore dürfen keinen halbfertigen Traversal-Zustand zurücklassen.

**DESIGNEMPFEHLUNG:** Zunächst wenige bewusst vorbereitete Hindernistypen mit geprüften Einstieg-/Ausstiegsbereichen verwenden. Das ist zuverlässiger planbar als frei erkannte Kletterflächen an jeder Geometrie. Den zurückgelegten Weg auf Kollision prüfen, nicht nur den Zielpunkt. Während Traversal nicht gleichzeitig ein zweites Springen oder Klettern starten.

Bei ungültigem oder plötzlich blockiertem Ziel die Handlung vor Beginn ablehnen oder währenddessen zu einem geprüften sicheren Punkt abbrechen. Pause hält den Ablauf an. Ob Schaden einen lebenden Spieler aus dem Klettern reißt, ist eine eigene offene Regel.

**NOCH OFFEN:** Automatisch oder ausdrücklich ausgelöstes Klettern, Hindernismaße, Zeitablauf, zulässige Unterbrechungen und Fähigkeiten der Kreatur an diesen Hindernissen. Sichere Testhindernisse müssen nach Auswahl der Perspektive und vor endgültigem Levelmaßstab abgestimmt werden.

## 16. Story- und Progress-System

**FEST BESCHLOSSEN:** Story-Hinweise, Texte, Umweltinformationen, Fortschrittsmarkierungen, erste Enthüllung und Cliffhanger ohne anfängliche Sprachausgabe. Fortschritt beruht auf Wissen, Werkzeugen und Zugängen, nicht auf XP. Grundlage: GDD §§21–22 und Auftrag N.

**TECHNISCHE ANFORDERUNG:** Hinweise und relevante Ereignisse besitzen stabile Identitäten. Gefunden, gelesen und spielentscheidend ausgelöst sind unterschiedliche Sachverhalte, soweit der spätere Inhalt diese Unterscheidung benötigt. Voraussetzungen werden anhand bestätigter Spielzustände geprüft. Wiederholtes Betreten oder Laden darf ein einmaliges Ereignis nicht unkontrolliert mehrfach auslösen.

**DESIGNEMPFEHLUNG:** Storydefinitionen enthalten Inhalt oder Inhaltsreferenz, Bedingungen und die jeweils resultierende Fortschrittsmarkierung. Textpräsentation liest diese Daten; sie entscheidet nicht selbst über Tür- oder Rätsellösungen. Umweltinformationen benötigen nur dann einen Speicherzustand, wenn ihre Entdeckung tatsächlich relevant ist; nicht jedes betrachtete Dekorationsobjekt wird protokolliert.

Enthüllung und Slice-Ende getrennt markieren, damit die Enthüllung nicht schon durch das Laden ihres Bereichs als erlebt gilt. Unterbrochene mehrteilige Ereignisse brauchen einen vereinbarten sicheren Wiedereinstieg; die bloße Wiedergabe einer Animation ist keine belastbare Fortschrittsquelle.

**NOCH OFFEN:** Inhalte, Bedingungen, Figuren, Geheimnis, Enthüllung, genauer Cliffhanger, Lesebedienung und Replay-Verhalten. Technisch wird kein Plot und keine konkrete Ereignisreihenfolge als endgültig festgeschrieben.

## 17. Save / Checkpoint / Restore

### 17.1 Umfang und Begriffe

**FEST BESCHLOSSEN:** Autosave / Checkpoints **und zusätzlich manuelle Speicherpunkte** gehören zu 0.1. Manuelle Speicherpunkte sind keine Zusage für freies Speichern an jeder Position. Eine Niederlage führt zum letzten Checkpoint zurück. Anzahl der Spielstände, genaue Speicherorte und Bedienung bleiben offen. Grundlage: GDD §§29, 30.3, O-13.

**TECHNISCHE ANFORDERUNG:** Ein Snapshot bezeichnet hier einen zusammengehörigen gespeicherten Fortschrittsstand. Autosave ist dessen automatische Sicherung; ein manueller Speicherpunkt erlaubt eine vom Spieler ausgelöste Sicherung am vorgesehenen Ort. Der Todes-Checkpoint und ein manuell auswählbarer Spielstand dürfen nicht stillschweigend als dasselbe behandelt werden. Ein Zeitpunkt oder eine Dateinummer allein beschreibt noch keinen gültigen Wiederanlauf.

Ein älterer Snapshot ersetzt den relevanten Laufzustand vollständig. Er darf nicht mit später erreichten Rätsellösungen, Gegenständen oder Storymarkierungen vermischt werden. Speichern muss auch nach Beenden und erneutem Starten des installierten Spiels funktionieren; eine reine Kopie im Arbeitsspeicher genügt nicht.

**DESIGNEMPFEHLUNG:** Zunächst nur stabile, lebende Zustände an freigegebenen Speicherstellen sichern. Kein Snapshot mitten im Tod, in einem halben Pickup oder in einer laufenden Kletterbewegung. Für 0.1 bevorzugt Speicherstellen außerhalb aktiver Verfolgung/Suche vorsehen. Das ist eine noch zu bestätigende Speicherpolitik, keine im GDD festgelegte Einschränkung manueller Speicherpunkte.

Ein manueller Snapshot sollte den dazugehörigen letzten Todes-Checkpoint beziehungsweise dessen Snapshot-Zuordnung bewahren. Dadurch führt Laden eines älteren manuellen Standes nicht nach der nächsten Niederlage versehentlich zu einem Checkpoint aus einer späteren Zeit. Ob ein manueller Speicherpunkt zugleich einen neuen Todes-Checkpoint aktiviert, bleibt ausdrücklich offen.

**DESIGNEMPFEHLUNG – wichtige Korrektur zur Checkpoint-Zuordnung:** Eine ID auf einen später überschriebenen Autosave reicht nicht aus. Jeder ladbare Stand muss seinen vollständigen gültigen Todes-Wiederanlauf erhalten. Für den kleinen Slice bevorzugt ein eigenständig lesbares Datenpaket mit aktuellem Snapshot und, nur wenn verschieden, einer mitgesicherten Checkpoint-Datenkopie. Diese Kopie enthält keine weitere Kette von Save-Verweisen. Bei identischem aktuellem Stand und Todes-Checkpoint genügt ein Datensatz. Dadurch ist weder eine unbegrenzte Snapshot-Historie noch ein System zur Verwaltung abhängiger Save-Dateien erforderlich. Die Anzahl der vom Spieler sichtbaren Speicherplätze bleibt davon unberührt und offen.

### 17.2 Persistenzmatrix

**TECHNISCHE ANFORDERUNG:** „Zwingend persistent“ bedeutet: Die Information muss aus dem Snapshot selbst oder einer eindeutig versionierten, stabilen Konfiguration vollständig rekonstruierbar sein. Nicht jede abgeleitete Eigenschaft braucht ein zweites gespeichertes Feld. Die Tabelle legt fachlichen Informationsbedarf fest, kein Dateiformat.

| Zustandsbereich | Zwingend persistente Information | Ableitung / erneute Initialisierung |
| --- | --- | --- |
| Snapshot-Metadaten | Schema-/Inhaltsversion, Laufzuordnung, Level-/Abschnittsidentität, Speicherart und vollständig auflösbarer Todes-Checkpoint | ID auf eine überschreibbare fremde Save-Datei genügt nicht; eine technische Dateisicherung ist kein zusätzlicher Spielerslot |
| Spielerposition | Eindeutiger Bezug zum Level, gültige Position und Ausrichtung beziehungsweise dauerhaft definierter Speicheranker | Kollision und Kameradarstellung neu aufbauen; feste Anker müssen dieselbe Position nachvollziehbar rekonstruieren |
| Haltung / Lebenszustand | Lebenspunkte und jede für den sicheren Spawn erforderliche Haltung | Lebendig/verletzt aus konsistenten Daten ableiten; kein toter regulärer Wiederanlaufstand |
| Inventar | Gegenstandsidentitäten, Mengen, tatsächlich besessene Werkzeuge, relevante Auswahl | UI-Reihenfolge nur speichern, falls sie eine gewählte Bedienregel verlangt |
| Verbrauchsgegenstände | Bestand nach bestätigter Nutzung | Spätere Verbräuche werden beim Laden eines älteren Snapshots verworfen |
| Tempoeffekt | Aktivität, Effektidentität und verbleibende Gameplay-Dauer, sofern am Speicherpunkt aktiv | Tempo aus Basis und Effekt berechnen; weder doppelt anwenden noch volle Dauer zurückgeben |
| Taschenlampe | Verfügbarkeit/Besitz und Ein-/Aus-Zustand | Lichtobjekt aus Konfiguration neu herstellen |
| Weltfunde / eingesetzte Items | Identitäten eingesammelter oder eingesetzter Funde und ihre Verwendung | Eingesammelte Objekte bleiben entfernt; eingesetzte Teile sind nicht zusätzlich frei im Inventar |
| Türen | Eigenständige stabile Stellung und unabhängige Verriegelung, soweit nicht vollständig von einem Rätsel abgeleitet | Freigabe getrennt von Türstellung; Übergänge nur gemäß vereinbarter Speicherregel in einen konsistenten stabilen Zustand überführen |
| Schalter | Unabhängige Schaltstellung oder zugehöriger persistenter Rätsel-Teilzustand | Keine zweite widersprüchliche Kopie desselben Zustands |
| Rätsel | Identität, Teilfortschritt, Lösung, eingesetzte Gegenstände und verbindliche Folgezustände | Darstellung und abgeleitete Zugänge neu auswerten, ohne Belohnungen erneut auszulösen |
| Story | Relevante gefunden/gelesen/ausgelöst-Markierungen, Enthüllungs- und Abschlusszustand | Bereits bestätigte einmalige Ereignisse nicht noch einmal als neu behandeln |
| Level | Aktivierte Zugänge, relevante einmalige Auslöser, freigegebene Abschnitte und notwendige Weltänderungen | Rein dekorative Zustände nur bei tatsächlicher Spielrelevanz persistieren |
| Kreatur / Begegnung | Verfügbarkeit, freigegebene Begegnungsphase und unumkehrbarer Begegnungsfortschritt | Momentaner KI-Zustand nur unter der genehmigten Reset-Politik neu initialisierbar; siehe unten |
| Bewegungs-/Darstellungsdetails | Keine Persistenz für veraltete Eingaben, Fußschrittphase oder rein visuelle Übergänge erforderlich | Geschwindigkeit, Bewegungssperren, Kamerainterpolation und einmalige Effekte kontrolliert neu starten |
| Laufzeit-Infrastruktur | Keine Persistenz für Objektzeiger, Navigationspfade, laufende Audiospieler oder ausstehende Ereigniswarteschlangen | Aus dem restaurierten Fachzustand neu aufbauen; alte Laufereignisse verwerfen |

**DESIGNEMPFEHLUNG – Gegner-Reset:** Bei bestätigter Speicherung an dafür geprüften sicheren Stellen die Kreatur an einem zum Snapshot gehörigen gültigen Anker mit geeignetem Ausgangsverhalten neu initialisieren. „Gerade keine Verfolgung“ reicht als Sicherheitsnachweis nicht: Eine nah patrouillierende Kreatur, ein blockierter Fluchtweg oder ein sichtbarer Positionssprung können einen unfairen Restore erzeugen. Spieleranker, Kreaturenanker, Sichtlinien und restaurierte Türen müssen zusammen geprüft werden. Letzte Sichtung, gehörte Altgeräusche, Such-Timer und laufende Verfolgung werden nur unter dieser vereinbarten Politik verworfen. Begegnungsfreigaben verhindern zu frühe Aktivierung und ungewollte Wiederholung.

Falls Speichern während aktiver Bedrohung zugelassen wird, ist dieser vereinfachte Reset nicht automatisch korrekt. Dann müssen mindestens Position, Verhalten, letzte gültige Wahrnehmung, verbleibende Suchzeiten und relevante Interaktionszustände gespeichert oder durch eine ausdrücklich freigegebene Wiederanlaufregel ersetzt werden. Die Position des Spielers wird auch nach Restore nicht als neue KI-Wahrnehmung erfunden. Diese Alternative ist vor Umsetzung zu entscheiden, nicht still zu mischen.

### 17.3 Konsistenz und Schreibvorgang

**TECHNISCHE ANFORDERUNG:** Aufnahme, Itemverbrauch und Rätsellösung werden entweder vollständig vor oder vollständig nach dem Snapshot erfasst. Fehler beim Schreiben dürfen den letzten brauchbaren Stand nicht zerstören. Eine Erfolgsanzeige darf erst erscheinen, wenn die Speicherung tatsächlich abgeschlossen wurde. Bei fehlendem Schreibzugriff oder vollem Datenträger bleibt der vorige Stand erhalten und der Fehler sichtbar.

**DESIGNEMPFEHLUNG:** Eine versionierte, validierbare Datenbeschreibung mit stabilen fachlichen IDs verwenden; keine Laufzeitobjekte oder zufällig vergebenen Instanznummern speichern. Einen vollständigen Snapshot zunächst separat schreiben, prüfen und erst dann als aktuellen Stand veröffentlichen; einen letzten gültigen Stand als Rückfall behalten. Das konkrete Ersetzungsverfahren wird auf Windows einschließlich abgebrochenem Schreiben geprüft, statt pauschal Absturzsicherheit zu versprechen.

Nur ein Schreibvorgang zur selben Zeit. Für die kleinen Zustandsdaten zunächst serielles Schreiben an der zulässigen Zustandsgrenze testen; einen Hintergrundthread erst bei gemessenem Ruckeln ergänzen. Eine asynchron geschriebene Kopie darf nicht weiter verändert werden; verspätete Ergebnisse dürfen weder einen neueren Save noch die Checkpointzuordnung eines neuen Laufs überschreiben. Temporärdatei und Ersatzdatei müssen so gewählt werden, dass das getestete Ersetzungsverfahren tatsächlich auf demselben Dateisystem erfolgt.

Für 0.1 empfohlen: Einen neu erreichten Checkpoint erst nach erfolgreicher vollständiger Sicherung als dauerhaft und als neuen Todes-Wiederanlauf bestätigen. Scheitert der Vorgang, bleiben vorheriger gültiger Stand und Checkpointzuordnung erhalten; die UI sagt klar, dass der neue Fortschritt nicht gesichert wurde. Beim allerersten Start bleibt der definierte Anfangs-Wiederanlauf aus §5 auch ohne erfolgreich geschriebene Datei verfügbar; er ist deshalb noch kein dauerhaft gesicherter Spielstand. Diese technische Konsistenzregel ist vor Umsetzung der Checkpointbedienung zu bestätigen. Der laufende Durchlauf muss deshalb nicht abstürzen.

Die fachliche Zustandsänderung wird kurz vollständig ausgeführt und anschließend kopiert; keine Datenbanktransaktionen, Ereignishistorie oder automatische Rückabwicklung beliebiger Systeme bauen. Rätsel-/Türanimationen oder einmalige Storydarstellungen, die beim Speicheranlass noch laufen, brauchen einen definierten stabilen Zustand oder ein begründetes, begrenztes Verschieben der Anfrage. Eine manuelle Anfrage darf nicht minutenlang unsichtbar warten und später einen unerwarteten Ort speichern. Ablehnung beziehungsweise Verzögerung muss erkennbar sein; die erlaubten Speicherphasen bleiben T-05.

Ein lesbares Format wie JSON ist für den kleinen Zustand ein Kandidat. Positionen und andere Engine-Datentypen müssen darin ausdrücklich als einfache Daten dargestellt werden; alternativ ist ein kontrolliertes binäres Format möglich. Das offizielle [Godot-Tutorial zu Savegames](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html) erläutert Serialisierung und Formatgrenzen; dessen Beispiel ist keine fertige Projektarchitektur. Für beschreibbare Laufzeitdaten ist Godots `user://` der vorgesehene Kandidat, nicht `res://` oder der Installationsordner. Siehe [Godot: File paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html).

Stabile IDs werden beim Erstellen des jeweiligen Levelinhalts vergeben und beim Duplizieren auf Eindeutigkeit geprüft; sie werden nicht bei jedem Start neu erzeugt. Save-Daten enthalten fachliche Werte und bekannte Inhalts-IDs, keine frei zu instanzierenden Objekt- oder Scriptpfade. Zunächst nur explizit unterstützte Schema-/Inhaltsversionen laden und andere verständlich ablehnen; Migration erst bei einem konkreten Versionsübergang ergänzen. Ein allgemeines Migrationsframework ist für 0.1 nicht erforderlich. Nutzereinstellungen wie Lautstärke oder Empfindlichkeit sind getrennt vom Spielfortschritt: Laden eines älteren Checkpoints darf diese nicht zurücksetzen.

### 17.4 Reihenfolge beim Restore

**DESIGNEMPFEHLUNG:**

1. Speicherpaket einschließlich Todes-Checkpoint auf Version, Pflichtfelder, Wertebereiche, vorab verfügbare Inhalts-IDs und fachliche Widersprüche prüfen. Bei ungültigen Daten den bisherigen Lauf noch nicht zerstören.
2. Neuen Restore-Vorgang exklusiv beginnen; Eingaben, KI, Schaden und Gameplay-Timer sperren, alte Rückmeldungen ungültig machen und Präsentation auf Laden setzen.
3. Nach Datenvorprüfung alte Weltreferenzen lösen und Welt entladen, dann benötigten Levelinhalt inaktiv aufbauen. Auf 16 GB RAM nicht zwei vollständige Level nur für eine Rückabwicklung gleichzeitig behalten. Scheitert der Aufbau, bleiben Save-Dateien erhalten und ein Rückweg ins Menü verfügbar.
4. Konkrete Objekt-IDs und Verbindungen im aufgebauten Level auflösen und prüfen; dann zuständige Daten für Inventar/Funde, Rätsel, Story und Level anwenden. Neue Objekte dürfen bei ihrer Initialisierung noch keine Start-, Pickup- oder Storyaktionen auslösen.
5. Daraus Freigaben ableiten und unabhängige Tür-/Schalterstellungen herstellen. Darstellungsanimationen nicht als nachträgliche Wahrheit gegen diese Daten laufen lassen.
6. Nötige Physik-/Navigationsaktualisierungen zulassen, ohne Gameplay freizugeben (§5.1). Spieler und Kreatur nach gewählter Restore-Politik positionieren; Kollision, Anker und Wege nach Synchronisation validieren. Zustände und Effekte genau einmal anwenden.
7. Bei ausbleibender Bereitschaft oder ungültigem Spawn begrenzt und diagnostizierbar abbrechen, keine Endlosschleife. Andernfalls Audio/UI aus dem fertigen Zustand neu herstellen und Kamerahistorie zurücksetzen.
8. Checkpointbezug und aktuellen Lauf gemeinsam freigeben. Alte Ereignisse nicht wiederverwenden; Wiederherstellung niemals als neue Story-, Pickup- oder Geräuschaktion ausgeben.

**NOCH OFFEN:** Format und Schema, Spielstandanzahl, Speicherstellen/Bedienung, Snapshot-Auslöser, Regel für Speichern bei Gefahr, Verhältnis manueller Speicherpunkt/Todes-Checkpoint und Kompatibilitätsversprechen zwischen Versionen. Die Persistenzmatrix beschreibt den erforderlichen Informationsumfang; die konkrete fachliche Rücksetzpolitik bleibt zu bestätigen.

## 18. UI

**FEST BESCHLOSSEN:** Startmenü, Pause, Interaktionshinweise, kleines Inventar, Gesundheits-/Schadensrückmeldung, Game Over und Speicher-/Checkpoint-Rückmeldung. Eine Tempoanzeige ist bei Bedarf vorzusehen. Minimale Ablenkung und keine große dauerhaft belegte HUD-Fläche. Grundlage: GDD §27 und Auftrag P.

**TECHNISCHE ANFORDERUNG:** Die UI zeigt bestätigte Zustände und stellt Anfragen, verändert aber nicht eigenständig Gesundheit, Inventar oder Rätsel. Ein belegtes Eingabefenster verhindert unbeabsichtigte Aktionen darunter. Fokus und Mausmodus müssen nach Pause, Lesen, Tod und Restore zur jeweiligen Situation passen. Speichern erfolgreich, noch nicht abgeschlossen und fehlgeschlagen sind unterscheidbar.

**DESIGNEMPFEHLUNG:** Kontextinformationen nur bei Relevanz einblenden; lesbare Textflächen mit einheitlicher Eingaberückmeldung. Ein aktueller Tempoeffekt kann durch ein kleines zeitlich begrenztes Symbol beziehungsweise eine Restzeitanzeige vermittelt werden. Schadensrückmeldung darf notwendige Sichtinformation während einer Flucht nicht überdecken.

Tastaturbelegung und Interaktionstexte aus der tatsächlichen Konfiguration anzeigen. Texte und Bedienelemente bei unterschiedlichen Fenstergrößen prüfen. Pause-Menü und Textansicht nutzen denselben vereinbarten Eingabefokus, ohne ihre konkrete Gestaltung festzulegen.

Eine neu eingeblendete oder nach Restore neu erzeugte Ansicht liest zuerst den vollständigen aktuellen Zustand und reagiert danach auf Änderungen. Nur auf zukünftige Meldungen zu warten würde bereits aufgenommene Items, aktive Effekte oder Speicherstatus unterschlagen. Für diesen kleinen UI-Umfang genügt direkte Zustandsabfrage beim Öffnen; kein zusätzliches reaktives Datenframework.

**NOCH OFFEN:** Finales HUD, Schriftgrößen, Inventarlayout, Health-Darstellung, Untertitel/Zugänglichkeit, Bedienen manueller Speicherpunkte und Menüweg zum Laden. „Fortsetzen“ bleibt ein sinnvoller Vorschlag, nicht der einzig mögliche Ladezugang.

## 19. Audio

**FEST BESCHLOSSEN:** 3D-Positionsaudio, Schritte, Kreaturengeräusche, Türen, Schalter, mechanische/industrielle Umgebung, Ambience, Musik und UI-Rückmeldung. Sound vermittelt Atmosphäre, Orientierung, Handlungsfolgen und Gefahr. Zunächst keine Sprachausgabe. Grundlage: GDD §26 und Auftrag O.

**TECHNISCHE ANFORDERUNG:** Audio folgt tatsächlichen Aktionen und Zustandswechseln. Ein angehaltener oder stehender Spieler erzeugt keine fortlaufenden Gehschritte. Weltquellen besitzen sinnvolle Positionen und Reichweiten; UI-Sounds benötigen keine Weltposition. Doppelt ausgelöste Tür- oder Verfolgungsmeldungen dürfen keine ständig gestapelten Wiedergaben erzeugen. Nach Restore dürfen alte Verfolgungsgeräusche nicht weiterlaufen.

**DESIGNEMPFEHLUNG:** Lautstärkegruppen für Gesamtlautstärke, Welt-/Aktionsgeräusche, Atmosphäre, Musik und UI vorsehen; die endgültigen Busnamen bleiben Architekturarbeit. `AudioStreamPlayer3D` ist der Godot-Kandidat für räumliche Quellen, nicht für jeden Menüklick. [Godot: Audio streams](https://docs.godotengine.org/en/stable/tutorials/audio/audio_streams.html).

Oberflächen liefern zunächst eine einfache Kategorie für Schritte; keine vollständige Materialsimulation. Jede Kategorie kann wenige Varianten und einen Standardersatz besitzen. Kreaturenbewegung und hörbare Warnsignale werden zum tatsächlichen Verhalten synchronisiert. Ambience und Musik leiten ihre Phase aus Level-/Bedrohungszuständen ab; sie steuern diese nicht rückwärts.

Kurze wiederkehrende Effekte und lange Musik-/Ambience-Dateien benötigen unterschiedliche Importprofile. Für häufige kurze Effekte WAV mit geprüftem Importprofil erwägen, für lange Inhalte komprimierte Formate wie Ogg Vorbis. Speicherersparnis gegen Dekodieraufwand testen; Ogg benötigt laut Godot mehr Dekodierleistung als WAV. Siehe [Godot: ResourceImporterOggVorbis](https://docs.godotengine.org/en/stable/classes/class_resourceimporteroggvorbis.html). Das ist keine Auswahl konkreter Audiodateien.

Beim Pausieren Gameplay-Wiedergaben und Timer kontrolliert anhalten; UI darf weiter reagieren. Nach Restore können Ambience-Loops neu gestartet werden, sofern keine Rätselinformation von einer exakten Wiedergabeposition abhängt. Kritische Warnsounds erhalten Vorrang gegenüber dekorativen Stimmen, wenn die Anzahl gleichzeitiger Quellen begrenzt wird.

Für die gewählte Kamera genau eine zuständige Hörperspektive verwenden; Menü- oder temporäre Kameras dürfen keine zweite räumliche Wiedergabe erzeugen. Beim Verlassen eines Abschnitts seine Loops und Referenzen beenden, beim Zurückkehren nur einmal neu aufbauen. Physische Wände garantieren nicht automatisch eine passende akustische Dämpfung: Die hörbare Darstellung und die vereinfachte KI-Hörregel müssen gemeinsam erprobt werden, ohne dafür sofort eine vollständige Raumschalllösung einzuführen.

**NOCH OFFEN:** Aufnahme-/Bearbeitungsworkflow, Import-/Lautheitsregeln, konkrete Oberflächenkategorien, Varianten, Reichweiten, Raumdämpfung, Audiozielgerät und visuelle Alternativen für wichtige Signale. Sounddesign und Kreaturenstimme werden nicht erfunden.

## 20. Level- und Szenenfluss

**FEST BESCHLOSSEN:** Einzelne gestaltete Abschnitte und ein kurzer zusammenhängender Slice. Technisch vorzubereiten sind Wald-Einstieg, Gebäude, Exploration, Rätsel, erste Kreaturenbegegnung, Verfolgung, Enthüllung und Abschluss. Der vorgeschlagene Ablauf aus GDD §30.2 bleibt eine Designempfehlung; konkrete Räume oder endgültige Reihenfolge werden nicht festgelegt.

**TECHNISCHE ANFORDERUNG:** Abschnittswechsel bewahren Inventar, relevante Story- und Rätselzustände sowie den gültigen Checkpointbezug. Jeder Eintritt benötigt einen gültigen Spawnbezug und eine bereite Welt mit Kollision und erforderlichen Navigationsdaten. Ein Abschluss wird über bestätigte Fortschrittsbedingungen erkannt, nicht allein über den Dateinamen einer Szene.

**DESIGNEMPFEHLUNG:** Für den kleinen Slice zunächst wenige zusammenhängende geladene Bereiche prüfen. Nur bei gemessenem Speicher-/Ladeproblem auf klar abgegrenzte Ladeübergänge erweitern. Kein Open-World-Streaming und keine prozedurale Raumgenerierung vorsorglich einplanen.

Leveldaten benötigen stabile Abschnitts- und Objektidentitäten, Start-/Checkpointanker, Verknüpfungen zu Rätseln und Storymarkierungen sowie gültige KI-Bereiche. Die konkrete Aufteilung in Godot-Szenen folgt erst in ARCHITECTURE.md. Zuerst einen einfachen begrenzten Ladeablauf messen. Hintergrundladen ist nur bei tatsächlichem Bedarf ein weiterer Kandidat: Geladene Ressourcen bedeuten noch keine fertig instanziierte Welt, bereite Physik oder synchronisierte Navigation. Siehe [Godot: Background loading](https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html).

Weltaufbau und Gameplay-Aktivierung sind getrennte Schritte. Erst registrieren die Objekte ihre Referenzen, danach erhalten sie Start- oder Restore-Daten, zuletzt dürfen sie handeln. Der gleiche Aufbauweg dient Neuem Spiel und Restore; nur die Eingangsdaten unterscheiden sich. Beim Abbau werden Weltereferenzen und aktive Präsentation freigegeben. Für einen kleinen Slice ist vollständiger Neuaufbau beim Restore leichter prüfbar als das Zurückdrehen sämtlicher lebender Objekte in beliebigem Zustand.

**NOCH OFFEN:** Einmaliges Laden oder wenige Übergänge, Grenzen der geladenen Bereiche, Verhalten bei Rückwegen und Ladeanzeige. Eine Warnung vor noch nicht bereiter Navigation muss erkennbar sein; künstliche feste Wartezeiten ersetzen keine Bereitschaftsprüfung.

## 21. Daten und Konfiguration

**TECHNISCHE ANFORDERUNG:** Grundkonfiguration, aktuelle Laufzustände und gespeicherte Snapshots sind unterscheidbar. Ein Debug-Tuningwert darf keine irreversible Änderung eines Spielstands auslösen. Alle Referenzen auf relevante Gegenstände, Rätsel, Storymarkierungen und Weltobjekte sind eindeutig prüfbar.

**DESIGNEMPFEHLUNG – Godot-Datenhaltung:** Typisiertes GDScript und überschaubare, im Inspector bearbeitbare Konfigurationsdaten bevorzugen. Godot-Resources können Definitionen tragen; ihre fachlichen Felder sollen einfach übertragbar bleiben. Eine zusätzliche allgemeine Engine-Abstraktionsschicht oder zwei gleichzeitig gepflegte Definitionen in JSON und Resource sind dafür nicht nötig.

Geladene Resources können von mehreren Instanzen gemeinsam genutzt werden. Deshalb keine Itemmenge, gelöste Rätselstellung oder aktuellen Lebenspunkte in eine geteilte Definition schreiben. Veränderlicher Laufzustand gehört zur jeweiligen Instanz beziehungsweise zum zuständigen Laufbereich; Debugänderungen verwenden ausdrücklich isolierte Testwerte. Auch eine Snapshot-Datenkopie darf keine verschachtelten veränderlichen Listen des laufenden Spiels weiterteilen. Siehe [Godot: Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html).

**DESIGNEMPFEHLUNG:** Folgende Datenbereiche vorsehen, ohne Dateien, Resource-Klassen oder ein endgültiges Austauschformat festzulegen:

| Bereich | Konfigurierbare Werte / Definitionen | Validierung und Abstimmung |
| --- | --- | --- |
| Bewegung | Geh-/Sprinttempo, Beschleunigung, Bremsung, Sprunghöhe, Ducktempo/-höhe, Steigungs-/Traversalgrenzen | Einheitliche Maße; erreichbare Wege, Kollisionsmaße und tatsächliche Bewegung gemeinsam prüfen |
| Kamera | Empfindlichkeit, Blickgrenzen, Blickfeld, optionale Glättung | Keine endgültige Perspektive oder starke Kamerawirkung voraussetzen |
| Gesundheit | Maximum, Schadensmengen, gegebenenfalls bestätigte Treffer-/Erholungszeiten | Kein negativer Schaden durch ungültige Daten; Gesundheit im erlaubten Bereich |
| Kreatur | Patrouillen-/Verfolgungstempo, Sichtweite/-winkel, Hörparameter, Suchdauer, Reizprioritäten, Schaden | Zeit-, Winkel- und Entfernungswerte mit definierten Einheiten; Navigation passend zur Körpergröße |
| Geräusche | Aktionsart, Intensität, Reichweite, Oberflächenfaktor, Wiederholungsintervall, Dämpfung | Keine falschen Einheiten zwischen hörbarer Lautstärke und KI-Intensität |
| Items | Stabile Typ-ID, Kategorie, Stapelbarkeit, maximaler Stapel, Nutzungsvoraussetzung, Fortschrittsrelevanz | Keine unbekannten Typen oder negativen Mengen; kritische Eigenschaften konsistent |
| Inventar / Effekte | Kapazität, erlaubte Kategorien, Effektstärke/-dauer, bestätigte Erneuerungsregel | Endwerte bleiben Tuning; kein unbeschränktes Effektstapeln |
| Taschenlampe | Lichtkegel, Reichweite, Helligkeit, Schattenoptionen | Lesbarkeit und Ressourcenverbrauch prüfen; kein implizites Batteriesystem |
| Rätsel | Zustandsmenge, zulässige Eingaben, Voraussetzungen, Teilfortschritt, Lösungsbedingung, Resetregel | Alle benötigten Objekte bekannt; Lösung erreichbar; keine endgültigen Rätselinhalte |
| Story | Hinweis-ID, Text-/Darstellungsreferenz, Voraussetzungen und Fortschrittsmarkierung | Keine Verweise auf nicht vorhandene Hinweise; Einmaligkeit prüfbar |
| Audio | Lautstärkegruppe, Reichweite, Priorität, Varianten, Loop-/Pausenverhalten | Fehlende Dateien erkennen; kritische Hinweise nicht durch Stimmenlimit verdrängen |
| Level / Save | Abschnitts-/Objekt-IDs, Anker, zulässige Wiederanlaufzustände, Schema-/Inhaltsversion | Doppelte IDs und ungültige Zustandskombinationen vor Nutzung melden |

Maße und Tuningbereiche werden dokumentiert, etwa Entfernungen in Metern und Dauer in Gameplay-Sekunden. Externe Quellformate möglichst offen halten; als 3D-Austauschkandidat eignet sich glTF/GLB, ohne dass damit Assets ausgewählt werden. Godot unterstützt diese Formate als Teil seiner Importpipeline: [Godot: Available 3D formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html). Godot-spezifische Import- und Darstellungsdaten bleiben von der fachlichen Definition unterscheidbar.

**NOCH OFFEN:** Genaue Werte, Datenformate, erlaubte Tuningbereiche und Asset-Importprofile. Es werden keine willkürlichen endgültigen Gameplayzahlen festgeschrieben. Beispielbudgets in §23 sind ausschließlich DESIGNEMPFEHLUNGEN.

## 22. Systemkommunikation

**TECHNISCHE ANFORDERUNG:** Fachliche Zustandsänderung und ihre Präsentation dürfen auseinandergehalten werden. Empfänger benötigen die Ursache und das Ergebnis einer bestätigten Aktion, nicht beliebigen Schreibzugriff auf andere Systeme. Kommunikation muss beim Laden still wiederherstellen können, ohne Gameplay erneut auszulösen.

**DESIGNEMPFEHLUNG:** Die folgenden Abläufe definieren Informationsbedarf, keine Signalnamen oder Transportarchitektur.

| Auslöser und Ablauf | Benötigte Informationen | Konsistenzregel |
| --- | --- | --- |
| Tatsächliche Bewegung → Geräuschereignis → Hörwahrnehmung → KI | Quelle, Aktionsart, Ort, Intensität, Zeitpunkt | Keine kontinuierliche Spielerposition als Ersatz für ein altes Geräusch |
| Spielerinteraktion → Schalter → Rätselzustand → Türfreigabe → Save-Zustand | Ziel-ID, Eingabe, bestätigter Rätselzustand, betroffene Freigabe | Rätsel ist zuständig für seine Freigabe; Save liest erst den vollständigen Folgezustand |
| Kreaturenkontakt → Schaden → Health → Tod → Game Over → Restore | Gültige Ursache, Schadensergebnis, Todesübergang, Checkpointzuordnung | Ein Tod erzeugt einen Ablauf; kein Autosave eines zerstörten Laufzustands |
| Pickup → Inventar → Weltfund entfernt → UI/Save | Fund-ID, Itemtyp, bestätigte Menge, Ergebnis | Kein Entfernen ohne erfolgreichen Zugang ins Inventar |
| Itemnutzung → Bestand und Effekt → Bewegung/UI/Save | Zulässige Nutzung, Verbrauchsmenge, Effekt und Restdauer | Verbrauch und Wirkung als zusammengehörige Änderung |
| Story-Auslöser → Fortschritt → Text/UI/Level → Save | Hinweis-/Ereignis-ID, Voraussetzungen, neue Markierung | Wiederholte Meldung liefert keine zweite einmalige Belohnung |
| Sichtprüfung → KI → Verfolgung/Suche → Audio/UI | Wahrnehmung mit Aktualität, vorherige/neue Phase | Audio darf keine unabhängige zweite Chase-Wahrheit erzeugen |
| Speicherpunkt → Snapshot → Datenträger → UI | Speicherart, zulässiger Zustand, Snapshotzuordnung, Erfolg/Fehler | Schreibfehler ist kein Speichererfolg |
| Restore → Weltzustände → Kollision/Navigation → Spieler/Kreatur → UI/Audio | Zusammengehöriger Snapshot und Bereitschaft der Bereiche | Keine alten Ereignisse aus dem vorherigen Lauf nach Freigabe anwenden |

Wiederherstellen desselben Zustands darf keine neuen Belohnungen oder Nebenwirkungen erzeugen. Das bedeutet nicht, jede legitime wiederholte Benutzung eines Schalters oder jeden weiteren Treffer zu verwerfen: Zustandsanwendung und neue Spielaktion sind verschiedene Vorgänge.

Für 0.1 direkte, kurze Aufrufe für geprüfte Änderungen und lokale Meldungen für deren Darstellung bevorzugen. Kritische Folgeänderungen werden unmittelbar vor der nächsten Snapshot-Grenze abgeschlossen, nicht über eine beliebig lange Ereigniskette verteilt. Animationen dürfen asynchron folgen. Tod sperrt neue Nutzung und Speicheranfragen; bereits vollständig bestätigte Änderungen werden nicht nachträglich halb zurückgenommen. Keine allgemeine Transaktions-, Replay- oder Nachrichtenplattform aufbauen.

Die Zuständigkeit für genau einmaliges Auslösen liegt beim verursachenden Vorgang, nicht bei einer globalen Liste sämtlicher Ereignisse. Abbau und Neuaufbau dürfen keine mehrfachen Verbindungen oder alte wartende Aktionen zurücklassen. Einfache Laufprüfung bei verzögerten Ergebnissen und erneutes Lesen bei UI-Aufbau reichen aus, wenn keine weitere Parallelität eingeführt wird.

## 23. Performance und Ressourcen

**FEST BESCHLOSSEN:** 16 GB RAM am Entwicklungsrechner; GPU und belastbare Zielhardware noch unbekannt. Editor und Spiel müssen gemeinsam praktikabel bleiben. Qualitätsschwerpunkte sind Optik, Atmosphäre, Bewegung und Sound, nicht maximale Assetauflösung. Grundlage: technischer Auftrag und GDD §§24, 34.

**DESIGNEMPFEHLUNG:**

| Bereich | Ausgangspunkt für 0.1 | Was später gemessen wird |
| --- | --- | --- |
| Levelumfang | Wenige sorgfältig ausgearbeitete Bereiche; begrenzte Sichtweiten und geladene Inhalte | Spitzen beim Laden, Verweildauer ungenutzter Ressourcen |
| Texturen | Für viele gewöhnliche Oberflächen zunächst 1K–2K als Arbeitsbereich; kleinere Texturen für kleine Objekte, höhere Auflösung nur nach sichtbarem Bedarf | Tatsächliche Importgröße, RAM/VRAM und sichtbarer Nutzen; keine pauschalen 4K-/8K-Pakete |
| Materialien / Geometrie | Geeignete Materialien und Objekte wiederverwenden; Kollisionsgeometrie vereinfachen | Renderaufwand, Kollision, Importdauer und Datei-/Speichergröße |
| Licht / Schatten | Wenige bewusst ausgewählte dynamische Schattenlichter; statische Lichtlösungen prüfen | GPU-Zeit, Lesbarkeit, Kosten der Taschenlampe und möglicher Lichtberechnung im Editor |
| KI / Navigation | Eine komplex aktive Kreatur; Wahrnehmung und Wegaktualisierung bedarfsgerecht | Physik-/KI-Zeit und Navigationsspitzen bei Tür- und Zustandswechseln |
| Audio | Kurze und lange Inhalte getrennt importieren; gleichzeitige Wiedergaben begrenzen und priorisieren | Speicher, Dekodierlast, hörbare Aussetzer, verlorene Warnungen |
| Laden | Zuerst einfacher Ladeweg; mehrstufiges Laden nur bei gemessenem Bedarf | Kaltstart, Levelübergang, Checkpoint-Restore und kurzzeitig doppelt geladene Welt |
| Entwicklungsbetrieb | Betriebssystem und Arbeitswerkzeuge haben Reserve neben Editor und Testspiel | Gesamtauslastung, Auslagerung und Speicherwachstum bei wiederholtem Laden |

Die Dateigröße einer komprimierten Textur ist kein RAM-/VRAM-Budget; mehrere Materialkarten, Mipmaps und Importdaten zählen mit. Für den technischen Slice keine großen unbearbeiteten Quelldaten zusätzlich ins Laufzeitprojekt laden. Referenzen auf entladene Welten, Audioschleifen und unnötige Vorkopien vermeiden, bevor komplexes Streaming oder eigene Ressourcenpools erwogen werden. Ein begrenzter Engine-Cache nach dem ersten Laden ist nicht automatisch ein Leck; wiederholte Läufe dürfen aber kein unbegrenztes Wachstum zeigen.

1K–2K ist ein vorläufiger Arbeitsbereich, kein festes Gameplay- oder Qualitätsbudget. Bei 16 GB RAM niemals nahezu den gesamten Arbeitsspeicher allein dem Spiel zuteilen. Keine extrem großen Scans, flächendeckenden hochauflösenden Einzelmaterialien oder umfangreichen Echtzeit-Lichtverfahren als Voraussetzung planen. Auch VRAM und gemeinsam genutzter Grafikspeicher können unabhängig vom RAM zum Engpass werden.

Für Rendering zunächst Forward+, Mobile und Compatibility gegen die tatsächlich vorhandene GPU und benötigte Bildwirkung prüfen. Godot bietet diese drei Renderer mit unterschiedlichen Hardware- und Funktionsprofilen; ein Wechsel kann Anpassungen an Licht und Materialien erfordern. Siehe [Godot: Overview of renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html). Kein bestimmter Renderer und keine anspruchsvolle Lichttechnik ist hiermit ausgewählt.

Als vorläufiges Spielgefühl-Ziel können stabile 60 Bilder/s bei einer später festgelegten Auflösung dienen, sofern die gemessene Hardware dies erlaubt. Das ist ausdrücklich eine DESIGNEMPFEHLUNG und keine Abnahmegarantie. Zunächst Vergleichsmessungen mit dokumentiertem Gerät, Engine-Version, Profil und Teststrecke sammeln. Neben dem Durchschnitt auch sichtbare Framezeitspitzen beim ersten Betreten, bei Verfolgungen, Speichern und Laden beurteilen.

Zwei Messfragen getrennt behandeln: Ist der Entwicklungsbetrieb mit Editor plus Spiel praktikabel, und ist der eigenständige Release-Export flüssig? Für beide CPU-, GPU- und Speicherengpässe unterscheiden. Erstbesuch eines Bereichs und wiederholten Besuch separat messen, um Import-/Darstellungsaufbau nicht mit dauerhaftem Gameplayaufwand zu verwechseln. Nicht alle Renderer vollständig optimieren; nach Hardwareprüfung ein Startprofil wählen und nur bei gemessener Unverträglichkeit wechseln.

**NOCH OFFEN:** Verbindliche Auflösung, Bildrate, Ladezeit- und RAM/VRAM-Budgets sowie Anzahl/Qualität dynamischer Lichter. Diese Ziele erst nach Hardwareerfassung und einem repräsentativen technischen Test festlegen. Keine Leistungsprüfung wurde in diesem Dokumentauftrag ausgeführt.

## 24. Fehlerfälle und Robustheit

**TECHNISCHE ANFORDERUNG:** Bei Fehlern muss der Fortschritt entweder konsistent weiter nutzbar bleiben oder ein nachvollziehbarer Wiederanlauf angeboten werden. Ein Softlock ist ein Zustand, in dem das Spiel weiterläuft, der notwendige Fortschritt aber nicht mehr erreichbar ist; solche Zustände dürfen durch die folgenden Fälle nicht entstehen.

**DESIGNEMPFEHLUNG:** Die Reaktionen konkretisieren die Robustheitsanforderung. Fachlich offene Rücksetzregeln müssen vor Implementierung bestätigt werden.

| Kritischer Fall | Gewünschte Reaktion | Nachweis |
| --- | --- | --- |
| Wichtiger Gegenstand verloren / Inventar voll | Verlust nach gewählter Schutzregel verhindern; abgelehnte Aufnahme belässt den Fund. Bei beschädigten Daten gültigen Stand anbieten, keinen Gegenstand beliebig duplizieren. | Zugang bleibt erreichbar; Fund und Inventar sind konsistent. |
| Tempo-Item vor Verfolgung verbraucht | Vorgesehene Flucht mit Grundbewegung weiterhin lösbar; kein heimlicher Pflichtverbrauch. | Verfolgung mit leerem Bestand durchspielbar. |
| Teilweise gelöstes Rätsel wird geladen | Gespeicherten Teilfortschritt samt eingesetzten Items wiederherstellen. | Nächste gültige Eingabe ist möglich; kein unvollständiger Reset. |
| Tod während Verfolgung | Lauf sperren, einmal Game Over; letzten gültigen Checkpoint samt damaligem Bestand und Weltzustand anwenden. | Keine alte Verfolgung oder doppelter Schadensimpuls nach Restore. |
| KI verliert Navigation | Ungültiges Ziel melden, begrenzt neu planen und auf einen erreichbaren zulässigen Zustand zurückgehen. | Kein Durchlaufen von Wänden, kein Endlosrechnen und keine erfundene Sichtung. |
| Notwendige Route bleibt blockiert | Entwicklungsfehler sichtbar machen; kontrollierten Checkpoint-Wiederanlauf ermöglichen. | Kein scheinbar normales Spiel mit dauerhaft unmöglichem Weiterkommen. |
| Spieler außerhalb gültiger Wege / im Boden | Fehler protokollieren und an geprüfte Position beziehungsweise Checkpoint zurückführen, ohne neuen schlechten Stand zu sichern. | Kein Spawn in Kollision und keine Wiederholungsschleife. |
| Tür und Rätsel widersprechen sich | Zuständige Quelle prüfen: rätselabhängige Freigabe aus Rätselzustand, unabhängige Türstellung aus gültigem eigenen Zustand. Unlösbaren Snapshot ablehnen. | Lösung, Darstellung, Kollision und Interaktion passen zusammen. |
| Älterer Checkpoint wird geladen | Gesamten Fortschritt dieses Standes anwenden, spätere Laufdaten verwerfen. | Kein zukünftiges Item, Storyflag oder Checkpointziel bleibt versehentlich erhalten. |
| Manuell geladen / danach gestorben | Zugeordneten Todes-Checkpoint des geladenen Verlaufs verwenden, entsprechend der freigegebenen Speicherpolitik. | Kein Sprung in einen späteren, fremden Fortschrittsstand. |
| Fehlende Audio-Datei | Diagnose plus geprüfter Ersatz, falls vorhanden; keine Ausnahme, die Spielregeln unterbricht. | KI-Geräusch bleibt definiert; kritische Warnung vor Abnahme repariert. |
| Fehlendes nicht kritisches Asset | Im Entwicklungsbetrieb klarer Ersatz und Diagnose. | Spiel bleibt testbar; kein unbemerkter Platzhalter im präsentablen Slice. |
| Fehlende spielkritische Geometrie / Daten | Laden kontrolliert abbrechen und zum Menü beziehungsweise gültigen Stand zurückführen. | Kein Spieler fällt durch fehlenden Boden oder erhält falsche Rätselregeln. |
| Speicherdaten älterer Version | Versionsprüfung; nur bekannte Migration anwenden, sonst verständlich ablehnen und Datei erhalten. | Keine stille Interpretation inkompatibler Daten. |
| Speicherdaten neuerer Version / beschädigt | Nicht überschreiben; kompatiblen Rückfallstand anbieten, falls vorhanden. | Keine Teilwelt und kein unbemerkter Fortschrittsverlust. |
| Schreiben abgebrochen / kein Platz / keine Rechte | Fehler melden, bisher gültigen Snapshot beibehalten, Erfolg nicht behaupten. | Letzter gültiger Stand bleibt ladbar. |
| Doppelte Interaktion / doppelte Ereignisse | Bereits bestätigte Aktion erkennen beziehungsweise aktuellen Zustand erneut prüfen. | Kein doppelter Pickup, Verbrauch, Schaden oder Storyabschluss. |
| Ungültige Konfiguration / doppelte IDs | Vor Spielstart oder beim Prüfen des Abschnitts eindeutig melden. | Kein später zufällig ausgewählter Zustand. |
| Alter manueller Stand verweist auf inzwischen überschriebenen Checkpoint | Mitgesicherten eigenen Wiederanlauf verwenden; unvollständiges Paket vor dem Restore ablehnen. | Kein Verweis auf fremden späteren Fortschritt und keine stille Wahl irgendeines Checkpoints. |
| Speicheranfrage während Tür-/Storyübergang | Nur konsistente Zustandsgrenze sichern; Anfrage nach bestätigter Regel sichtbar verzögern oder ablehnen. | Kein halboffener blockierender Zugang und kein verloren gegangenes Einmalereignis. |
| Navigation synchronisiert während Restore nicht | Bereitschaft mit Diagnose und begrenztem Abbruch prüfen; aktive Gameplay-Sperre von Engine-Aktualisierung trennen. | Kein endloser Ladebildschirm oder Gegnerstart vor fertiger Welt. |
| Alte Rückmeldung trifft nach Neuem Spiel ein | Laufbezug prüfen und veraltetes Ergebnis ignorieren. | Kein überschriebener neuer Save und keine Aktion auf neuen Objekten. |
| Zwei Instanzen teilen veränderliche Konfiguration | Instanzzustände isolieren; versehentliche Änderung im Debugtest sichtbar machen. | Ein Rätsel, Item oder Effekt verändert keine fremde Instanz. |
| Gegner sieht unerreichbaren Spieler | Gültige Sicht merken, aber keine unzulässige Route oder Treffer erzwingen; begrenztes Verhalten nach freigegebener Regel. | Keine Wandtreffer oder dauerhafte Neuplanungsschleife. |

Ein technischer Rückfall zur sicheren Position darf keine still eingeführte neue Gameplaystrafe sein. Ob er einen Checkpoint-Restore mit dessen Fortschrittsrücksetzung erfordert, muss dem Spieler erkennbar sein. Wiederholt auftretende Navigations- oder Kollisionsfehler sind zu beheben und gelten nicht durch einen Fallback als abgenommen.

## 25. Debug-Werkzeuge

**TECHNISCHE ANFORDERUNG:** Die Entwicklung muss Zustände und ihre Ursachen nachvollziehen können, ohne das Spielgefühl allein anhand unsichtbarer interner Abläufe zu beurteilen. Debugfunktionen sind kein verpflichtendes Feature des fertigen Spiels.

**DESIGNEMPFEHLUNG:** Eine kleine zuschaltbare Entwicklungsansicht reicht aus; keine eigene umfangreiche Werkzeuganwendung.

| Werkzeug | Zu beobachtende oder testweise veränderbare Information | Schutz vor falschen Testergebnissen |
| --- | --- | --- |
| Spielerzustand | Gesundheit, Haltung, Bewegung, Tempoeffekt/Restzeit, Eingabesperren durch Menüs | Anzeige liest tatsächlichen Zustand, keine zweite Kopie |
| Gesundheit setzen | Kontrollierte Schadens-/Todesfälle auslösen | Gleiche Zustandsprüfung wie normale Gesundheit verwenden |
| Checkpoint / Restore | Testcheckpoint auslösen, Speicherergebnis, Snapshotversion und zugeordneter Todes-Checkpoint anzeigen | Separaten Testlauf verwenden; regulären Fortschritt nicht unbeabsichtigt überschreiben |
| Rätsel setzen/resetten | Teil-/Lösungszustand und davon abhängige Türen untersuchen | Verknüpfte Zustände konsistent aktualisieren |
| KI-Ansicht | Verhalten, Ziel, letzte Sichtung, gehörtes Ereignis, Suchrestzeit, Pfadstatus | Wahre Spielerposition im Debugbild nicht als KI-Eingabe verwenden |
| Sicht-/Hörprüfung | Sichtbereich, blockierte Sichtprüfung, Hörort/-reichweite und Reizgrund darstellen | Anzeige der tatsächlich verwendeten Parameter |
| Entwicklungs-Teleport | Zu geprüften Testankern springen | Altes Tempo, Traversal und unpassende Wahrnehmungen zurücksetzen; Test als künstlich markieren |
| Laufzeit-Tuning | Bewegung, KI-Reichweiten/-Zeiten und Audioparameter zeitweise ändern | Ausgangswerte wiederherstellbar; Änderungen nicht heimlich dauerhaft speichern |
| Daten-/Leistungsprüfung | Doppelte IDs, fehlende Referenzen, Framezeiten, Ladezeiten und Speicherverlauf | Testgerät und Konfiguration zusammen mit Ergebnis festhalten |

Zusätzlich genügt eine kleine begrenzte Liste der letzten entscheidenden Zustandswechsel: Ursache, alter/neuer Zustand und Laufbezug. Für Save/Restore dessen aktuelle Phase, Schreibfehler und ausbleibende Bereitschaft sichtbar machen; keine unbegrenzten Protokolle pro Bild. Einen absichtlich fehlschlagenden Schreib-/Ladevorgang testweise auslösen können. Wiederholte Neubauten auf verbleibende Weltinstanzen und doppelte Audio-/Ereignisreaktionen prüfen. Das spart Fehlersuche, ohne ein Replay- oder Telemetrieprodukt zu bauen.

Der veröffentlichte Build soll solche Eingriffe standardmäßig deaktivieren beziehungsweise ausschließen. Ein technischer Fehlerbericht benötigt Ablauf, erwartetes/tatsächliches Ergebnis, Konfiguration und gegebenenfalls Snapshotbezug; ein umfassendes Telemetriesystem ist nicht vorgesehen.

## 26. Teststrategie und Acceptance Criteria

### 26.1 Testebenen

**TECHNISCHE ANFORDERUNG:** Es werden technische Funktionsfähigkeit und spielerische Qualität getrennt nachgewiesen. Ein funktionierender Speicheraufruf beweist noch keinen konsistenten Spielstand; ein technisch erreichbarer Weg beweist noch keine gute Flucht. Alle folgenden Tests sind geplant, nicht bereits ausgeführt.

**DESIGNEMPFEHLUNG:**

1. **Daten- und Logikprüfung:** Gültige Konfiguration, Bestandsänderung, Rätselübergang, Health und Snapshotprüfung ohne fertige Präsentation prüfen. Dafür später kleine automatisierte Tests nutzen, wo sie konkrete Fehler verhindern.
2. **Systemtest in Godot:** Bewegungs-/Kollisionsfälle, sichtbare und verdeckte Wahrnehmung, Interaktion, Audio und Restore in einem reproduzierbaren Testabschnitt prüfen.
3. **Integration:** Zusammenhängende Aktion vom Eingang bis zur UI und Speicherung prüfen; insbesondere Pickup, Lösung, Tod und Rückladen.
4. **Export-/Installationstest:** Auf dem festgelegten Windows-Ziel ohne Editor starten, bedienen, speichern, beenden und erneut laden. Schreibschutz des Installationsordners berücksichtigen.
5. **Spieltest des Slice:** Erstversuch mit normalem Erkunden und Lesen, Flucht ohne Tempo-Item sowie 15–25-Minuten-Ziel und GDD-Qualitätsfragen beurteilen.

Für einen Fehler einen kleinsten wiederholbaren Ablauf festhalten. Zufällige Audio-/Suchvarianten im Entwicklungstest reproduzierbar wählen können; das verlangt kein deterministisches Gesamtsimulationssystem. Nach Änderungen gezielt die betroffenen Abhängigkeiten nachtesten, nicht beliebig alle Fälle wiederholen.

### 26.2 Prüfkriterien pro Hauptsystem

**TECHNISCHE ANFORDERUNG:** Ein System ist erst funktionsfähig, wenn das beobachtbare Ergebnis seiner Pflichtfälle stimmt. Wo eine offene Regel betroffen ist, wird die gewählte Regel vor dem Test dokumentiert; die Tabelle entscheidet diese Regel nicht.

| ID / System | Testanordnung | Erwartetes Ergebnis |
| --- | --- | --- |
| AC-01 Game Flow | Starten → Neues Spiel → Pause → Fortsetzen; verschachtelte Ansichten, Restore aus Pause sowie wiederholten Tod/Abschluss prüfen | Eindeutige Phasen; keine Gameplayänderung durch pausierte Rückmeldungen; keine vorzeitige Entsperrung; Restore endet kontrolliert statt auf angehaltene Physik zu warten. |
| AC-02 Bewegung | Laufen, Sprinten, Springen und Ducken samt Übergängen auf Boden, an Ecken, unter niedriger Decke und bei variierender Bildrate | Jede Pflichtbewegung reproduzierbar; Haltung und Fortbewegung widersprechen sich nicht; kein Diagonalbonus, Aufstehen in Geometrie oder konkurrierender Positionsschreiber. |
| AC-03 Kamera / Eingabe | Gewählte Perspektive, engere Umgebung, Menü öffnen/schließen und Restore testen | Kontrollierbarer Blick, korrekter Mausmodus, keine Kamera-/Interaktionsabkürzung durch Wände; keine alten Eingaben nach Laden. |
| AC-04 Player State / Effekt | Tempo-Item nutzen, Bewegungsart wechseln, pausieren, laden und Wirkung auslaufen lassen | Effekt zeitlich begrenzt, Bestand korrekt, Restdauer gemäß Speicherregel; keine dauerhafte Beschleunigung oder doppelte Anwendung. |
| AC-05 Health / Death | Einen Treffer über mehrere technische Meldungen, mehrere fachlich erlaubte Treffer, blockierte Trefferlinie, Tod und weiteren Treffer testen | Ein Treffer nicht doppelt gezählt; gültige weitere Treffer nach gewählter Regel; kein Schaden durch undurchlässige Blockade; Tod genau einmal und korrekter Wiederanlauf. |
| AC-06 Interaktion | Tür, Schalter, Fund und Hinweis aus gültiger Entfernung, hinter Wand und durch schnelle Wiederholung bedienen | Passender Hinweis; nur gültige Aktion wirkt; keine Doppelaufnahme; Ablehnung und Erfolg sind unterscheidbar. |
| AC-07 Inventar / kritische Items | Volles Inventar, wichtiger Fund, bereits eingesetztes Item und erneutes Laden kombinieren | Gewählte Schutzregel verhindert Verlust/Softlock; Weltfund, freier Bestand und eingesetzte Gegenstände widersprechen sich nicht. |
| AC-08 Taschenlampe | Ein/Aus, Pause, Speicherstand mit beiden Zuständen und fehlender Verfügbarkeit testen | Gespeicherter Zustand stimmt mit Licht und Bedienung überein; kein Pflichtverbrauch einer Batterie; Lichtwirkung ist im gewählten Profil lesbar. |
| AC-09 Rätsel | Für beide Rätsel Voraussetzungen, Fehlversuch, Teilfortschritt, Lösung, Reset und Ladezustände prüfen | Keine unerfüllbare Zugangsschleife; Freigabe und tatsächliche Türstellung gemäß jeweiliger Regel korrekt; kein Itemverlust und keine doppelte Belohnung. |
| AC-10 Kreaturenverhalten | Patrouille → Untersuchung → Sicht → Verfolgung → Sichtverlust → Suche → Rückkehr; Reizwiederholung und unerreichbare Ziele ergänzen | Übergänge begründet; Wiederholung desselben Reizes verhindert das Ende nicht unbegrenzt; Untersuchung/Rückkehr besitzen kontrollierte Ausgänge; kein eigener konkurrierender Chase-Automat. |
| AC-11 Sicht | Spieler innerhalb/außerhalb von Sichtweite und Sichtwinkel, danach hinter undurchsichtiger Wand bewegen | Nur gültige Sicht aktualisiert eine Sichtung; letzte bekannte Position wandert hinter der Wand nicht mit. |
| AC-12 Geräuschwahrnehmung | Verschiedene bestätigte Aktionen an festen Testorten; Lautsprecher stummschalten; Quelle danach bewegen | Reaktion folgt konfigurierter Intensität, Entfernung und Dämpfung; altes Ereignis behält seinen Ort; Stummschalten ändert die KI-Regeln nicht. |
| AC-13 Navigation | Tür schließen/öffnen, Route unterbrechen, unerreichbaren sichtbaren Spieler und noch nicht synchronisierte Navigation prüfen | Route respektiert tatsächlichen Durchgang; Aktualisierung erst nach Bereitschaft; kein Richtungsflackern, Wanddurchtritt oder unbegrenztes Neuplanen; legale Unerreichbarkeit von fehlerhafter Navigation unterscheidbar. |
| AC-14 Chase / Search | Verfolgung aus Wahrnehmung beginnen, Sicht brechen, Suchbereich verlassen, erneut sichtbar werden und alternativ sterben | Entkommen erst gemäß Suchregel; erneute Sicht führt zurück in Gefahr; Tod beendet alten Chase; ohne Tempo-Item bleibt der vorgesehene Weg lösbar. |
| AC-15 Traversal | Sicheres Hindernis mehrfach überwinden, blockierten Ausstieg prüfen, pausieren und währenddessen sterben | Reproduzierbarer gültiger Ablauf; kein Wanddurchtritt, doppeltes Starten oder festhängender Zustand nach Pause/Tod. |
| AC-16 Story / Progress | Hinweis finden/lesen, Trigger erneut betreten und vor/nach relevanter Markierung laden | Fortschritt aus Bedingungen korrekt; Einmalereignisse nicht doppelt; gespeicherte Enthüllung und Abschluss nicht verwechselt. |
| AC-17 Save / Restore | Autosave und manuellen Speicherpunkt separat nutzen; Spiel beenden und den jeweiligen Stand laden | Beide Speicherarten funktionieren dauerhaft; konsistente Position, Health, Inventar, Effekte, Welt, Story und KI-Initialisierung; Details siehe 26.3. |
| AC-18 UI | Menüs, Lesen, Inventar und Fenstergrößen prüfen; Ansicht erst nach Itemaufnahme beziehungsweise Restore öffnen | Aktueller Anfangszustand sofort sichtbar; korrekter Fokus, keine durchgereichten Aktionen, eindeutiger Speicherfehler; keine Abhängigkeit von einer bereits verpassten Meldung. |
| AC-19 Audio | Vorbeigehen an räumlicher Quelle, Schritte auf vereinbarten Oberflächen, Türaktion, Verfolgung, Pause und Restore | Richtung und Anlass nachvollziehbar; keine stehenden Schritte, Audiostapel oder alte Chase-Loops; wichtige Warnungen bleiben hörbar. |
| AC-20 Levelfluss | Vorgesehenen Abschnittsablauf und Rückwege durchlaufen, Eintritt laden und Abschluss erneut betreten | Gültige Übergänge, konsistente Zugänge und Anker; keine Freigabe vor bereiter Welt; Abschluss nur nach gültiger Bedingung. |
| AC-21 Daten / Konfiguration | Doppelte Objekt-ID, fehlende Referenz und ungültigen Tuningwert einbringen; zwei Instanzen derselben Definition unterschiedlich verändern | Eindeutige Diagnose; IDs über Neustart stabil; geteilte Definition unverändert und individuelle Zustände unabhängig; Snapshotkopie verändert sich nach Aufnahme nicht weiter. |
| AC-22 Performance | Repräsentative Strecke und Restore sowohl mit Editor als auch im eigenständigen Release-Export messen; Erstbesuch und Wiederholung trennen | Ergebnis innerhalb später vereinbarter Budgets; nach begrenztem Aufwärmen stabiler Speicherverlauf, keine dauerhaft gehaltenen alten Welten; CPU-/GPU-/Ladespitzen unterscheidbar. |
| AC-23 Export / Installation | Installieren, ohne Editor als normaler Windows-Benutzer spielen, speichern, schließen und neu starten | Vollständiger Slice läuft; Ressourcen enthalten; Spielstände beschreibbar und erneut ladbar; Debugeingriffe im normalen Build nicht freigegeben. |
| AC-24 Debug / Isolation | Zustände ändern, zurücksetzen, Testlauf beenden und normalen Durchlauf beginnen | Werkzeuge zeigen echte Ursachen; Teständerungen bleiben nicht versehentlich im regulären Spiel oder dessen Saves. |
| AC-25 Optionaler Umfang | Verstecken, Crafting und Perspektivwechsel nicht aktivieren | Der gesamte Pflichtpfad samt Rätseln, Flucht und Abschluss bleibt spielbar. |

### 26.3 Besondere Save-Integrationstests

**TECHNISCHE ANFORDERUNG:** Folgende Fälle ergänzen AC-17 und sind für die Kombination aus Checkpoints und manuellen Speicherpunkten wesentlich:

- Vor und nach einer Aufnahme speichern/laden: Genau ein Besitzort desselben Fundes bleibt bestehen.
- Mit teilgelöstem Rätsel speichern/laden: Eingaben, eingesetzte Gegenstände und Türzustand passen zusammen; das Rätsel kann beendet werden.
- Nach gelöstem Rätsel laden: Freigabe bleibt korrekt; keine zweite Belohnung oder erneut blockierte Pflichttür.
- Nach Checkpoint ein Tempo-Item nutzen und sterben: Checkpointbestand wird wiederhergestellt; separater manueller Stand behält seinen eigenen Bestand.
- Mit aktivem Tempoeffekt an zulässigem Punkt speichern, neu starten und laden: Restzeit stimmt; Anwendung erfolgt genau einmal.
- Einen älteren manuellen Stand laden und sterben: Zugehöriger Todes-Checkpoint entspricht dem geladenen Verlauf, nicht späterem Fortschritt.
- Danach den früher zugehörigen Autosave mehrfach überschreiben und den manuellen Stand erneut laden: Sein Todes-Wiederanlauf bleibt vollständig und korrekt verfügbar.
- Vor erstem späteren Checkpoint sterben: Vereinbarter Anfangs-Wiederanlauf funktioniert.
- Während Speichern einen Fehler beziehungsweise Abbruch erzeugen: Der vorher gültige Stand bleibt verfügbar, kein falsches Erfolgssignal.
- Speicherpunkt bei noch bewegter Tür oder laufendem Einmalereignis benutzen: Sichtbare Annahme/Ablehnung nach gewählter Regel; späterer Restore weder halb blockiert noch erzählerisch übersprungen.
- Unmittelbar nach Restore einer sicheren Speicherung: Kreatur und Spieler befinden sich in der vereinbarten fairen Ausgangslage; keine sofortige Niederlage aus ungeprüften Ankern.
- Inkompatible Version, unbekannte Pflicht-ID oder widersprüchlichen Rätsel-/Türzustand laden: Kontrollierte Ablehnung oder geprüfte Migration; keine halb spielbare Welt.
- Dieselben Zustandsdaten wiederholt anwenden: Keine Item-, Gegner-, Audio- oder Ereignisduplikate; Ergebnis bleibt fachlich gleich.
- Lautstärke/Empfindlichkeit verändern, dann alten Checkpoint laden: Aktuelle Nutzereinstellungen bleiben erhalten.

### 26.4 Kleine, gezielte Regressionen statt großer Testinfrastruktur

**DESIGNEMPFEHLUNG:** Je Fall Ausgangsdaten, Schritte, erwarteten Zustand und tatsächliches Ergebnis festhalten. Für die Systembasis wenige reproduzierbare technische Testanordnungen verwenden; keine ausgearbeitete Story oder finale Assets voraussetzen.

| Prüffall | Konkreter Nachweis |
| --- | --- |
| Laufwechsel | Wiederholt Neues Spiel und Restore ausführen; anschließend genau ein Spieler, eine freigegebene Kreatur und die erwartete Anzahl Weltschleifen. Eine alte Rückmeldung verändert den neuen Lauf nicht. |
| Save/Load-Rundlauf | Vor und nach Laden die fachlichen Daten vergleichen, abzüglich ausdrücklich definierter Neuinitialisierung. Snapshotkopie bleibt trotz weiterer Aktionen unverändert. |
| Fehler beim Wiederaufbau | Fehlende Objekt-ID, absichtlich gescheiterter Schreibvorgang und ausbleibende Navigation jeweils isoliert auslösen; Diagnose, erhaltene Saves und bedienbarer Abbruch nachweisen. |
| Gemeinsame Definition | Zwei gleich definierte Testobjekte verschieden verändern; nur der jeweils zuständige Laufzustand ändert sich, auch nach erneutem Laden. |
| Wirkliche Sicht-/Hörursache | Reiz, akzeptierte Wahrnehmung und Verhalten zeitlich vergleichen; dekorativer Ton, eigener Kreaturenton und veralteter Reiz erzeugen keine ungewollte endlose Suche. |
| Zustandskombination | Ducken unter Decke, ablaufender Tempoeffekt, Pause und anschließender Restore kombinieren; weder falsche Höhe noch dauerhaftes Sprinttempo oder freie Eingabe im Menü. |

Zuerst kleine Daten-/Zustandstests automatisieren und räumliches Verhalten in Godot prüfen. Nicht jede Darstellungsanimation braucht einen eigenen automatisierten Test. Kameraqualität, Warnsignalverständlichkeit und gerechte Flucht bleiben zusätzlich Gegenstand menschlicher Spieltests.

**NOCH OFFEN:** Testwerkzeugwahl, konkrete Testgeometrie, freigegebene Referenzdaten und Leistungsbudgets. Die Umsetzung der Tests folgt erst nach den dafür benötigten Architekturentscheidungen.

## 27. Modularität / Erweiterbarkeit

**FEST BESCHLOSSEN:** Modulare Architektur und wartbarer Code; spätere Erweiterung soll ohne kompletten Neubau des Slice möglich sein. Daraus folgt keine Verpflichtung, optionale Features jetzt zu implementieren.

**DESIGNEMPFEHLUNG:**

| Spätere Erweiterung | Heute sinnvoll vorzubereiten | Heute nicht erforderlich |
| --- | --- | --- |
| Weitere Level | Stabile Abschnitts-/Objekt-IDs, getrennte Definition und Laufzustand, klarer Eintritt/Restore | Weltstreaming, generische Welterzeugung |
| Weitere Kreaturen | Konfigurierbare Wahrnehmung und Verhalten, keine fest verdrahtete einzige Spielerortung | Framework für große Gegnermengen oder sämtliche Verhaltensbäume |
| Weitere Gegenstände | Itemdefinition und Inventarbestand getrennt, geprüfte Nutzungsergebnisse | Dutzende Itemklassen oder ein universelles Effektsystem |
| Weitere Rätsel | Zustands-/Eingabe-/Restore-Vertrag und unabhängige Rätsellogik | Eigene Rätselprogrammiersprache oder Editor |
| Weitere Story-Hinweise | Stabile Fortschrittsmarkierungen und Inhalte getrennt von Darstellung | Vollständiges Quest-/Dialogbaum-System ohne fachlichen Bedarf |
| Controller | Fachliche Eingabeaktionen unabhängig von konkreter Taste | Unbeauftragte Controllerabstimmung in 0.1 |
| Begrenzte Abwehr | Schadens-/Wirkungsanfragen und KI-Reaktionen sauber begrenzen | Waffen, Trefferkombinationen und Kampffortschritt |
| Weitere Audioumgebungen | Kategorisierte Quellen, Varianten und definierte Mischgruppen | Vollständige akustische Simulation |
| Kleines Crafting | Verlässliche Inventaränderung als zusammengehöriger Vorgang | Rezeptbaum, Bauwirtschaft oder komplexes Produktionssystem |

Eine neue Funktion muss an vorhandene fachliche Verträge anschließen können. Die konkrete technische Abstraktion darf erst entstehen, wenn mindestens ein realer Anwendungsfall ihren Nutzen zeigt. Keine Pflicht zu externen Laufzeitdiensten, Multiplayer-Synchronisation oder einer zusätzlichen Datenbank.

## 28. Optionaler Umfang

**FEST BESCHLOSSEN:** Einfaches Verstecken, sehr kleines Crafting/Kombinieren und Perspektivwechsel sind ausschließlich Erweiterungen. Sie dürfen den Kern nicht voraussetzen. Grundlage: GDD §§30.4, 31 und Auftrag R.

**DESIGNEMPFEHLUNG:**

| Option | Möglicher späterer Anschluss | Nachweis bei Weglassen |
| --- | --- | --- |
| Einfaches Verstecken | Interaktion und sichtbare/verdeckt wahrnehmbare Zustände; konkrete Regel erst nach Freigabe | Sichtkontakt kann durch Wege und Geometrie gebrochen werden; keine Pflicht-Versteckanimation nötig. |
| Einzelne Itemkombination | Geprüfter Verbrauch und Erzeugung im Inventar, speicherbarer Ergebniszustand | Beide Pflichträtsel besitzen ohne Kombination eine gültige fachliche Lösung. |
| Perspektivwechsel | Bestehende Bewegungsabsicht und eine weitere Kameradarstellung | Bewegung, UI und Rätsel funktionieren vollständig mit der gewählten Hauptperspektive. |

Keine unsichtbaren Abhängigkeiten einbauen, etwa eine Tür, die nur mit einem optional gecrafteten Objekt aufgeht. Schwimmen, umfangreiches Rutschen, komplexes Greifen/Ziehen, dynamisches Tag/Nacht und separate Minigame-Modi werden nicht als heimliche Pflichtsysteme geplant. Die Gesamtvision wird dadurch nicht gestrichen.

## 29. Technische Risiken

**DESIGNEMPFEHLUNG:** Die Priorität beschreibt, wie früh ein Risiko untersucht werden sollte, nicht die Reihenfolge einer bereits beschlossenen Roadmap.

| Risiko | Priorität / mögliche Folge | Geplante Begrenzung und Nachweis |
| --- | --- | --- |
| Unbekannte GPU und Grafikprofil | Hoch; gewählte Lichtwirkung oder Zielbildrate eventuell nicht tragfähig | Hardware erfassen, Renderer früh vergleichen, AC-22; keine anspruchsvolle Beleuchtung als Voraussetzung. |
| Zu große Assets bei 16 GB RAM | Hoch; lange Importe, Auslagerung, Editor und Testspiel behindern sich | Wenige Ressourcen, angemessene Importprofile, Spitzen und Wiederholungsläufe messen. |
| Wechsel der Perspektive nach Levelausarbeitung | Hoch; Raummaßstab, Kamera und Traversal müssen überarbeitet werden | Hauptperspektive vor verbindlicher Umsetzung auswählen, AC-02/03/15. |
| Inkonsistente Save-/Weltzustände | Hoch; verlorene Items, falsche Türen, unlösbarer Fortschritt | Eindeutige Zuständigkeiten, vollständiger Snapshot, Restore-Reihenfolge und AC-17/26.3. |
| Überschriebener Checkpoint hinter einem manuellen Save | Hoch; alter Spielstand lädt, Tod führt aber zu falschem oder fehlendem Fortschritt | Eigenständig auflösbares Speicherpaket; Autosave nach manuellem Stand überschreiben und Wiederanlauf testen. |
| Unklare manuelle Speicherpolitik | Hoch; ungerechtfertigter Gegnerreset oder falscher Todes-Checkpoint | Gefahrenspeichern und Checkpointzuordnung ausdrücklich vor dem Save-System entscheiden. |
| Scheinbar sicherer Gegnerreset | Hoch; sofortige Erkennung oder blockierter Ausweg nach Laden | Spieler-/Kreaturenanker und Türen gemeinsam prüfen; fehlende aktive Verfolgung allein genügt nicht. |
| Navigations-/Tür-/Parkourkonflikte | Hoch; Kreatur läuft durch Blockade oder Verfolgung endet technisch | Bewegung, Kollision und Wege gemeinsam testen; kein Ersatz durch Allwissenheit. |
| Unzuverlässige Traversal-Erkennung | Hoch; Hängenbleiben während Flucht | Wenige geprüfte Hindernisse, Einstieg/Weg/Ausstieg prüfen, AC-15. |
| Versteckte Positionsweitergabe | Hoch; Kreatur bleibt unfair an unsichtbarem Spieler | Wahrnehmungsdaten begrenzen, Debugvergleich und AC-11/12. |
| Audio und KI-Geräusche widersprechen sich | Hoch; Spieler versteht Entdeckung nicht | Gemeinsame Aktionsursache, getrennte Ausgaben, Lautstärke-unabhängige KI und Warnsoundprüfung. |
| Pause-/Timer-/Restore-Konflikte | Mittel bis hoch; Effekt verschwindet, KI läuft weiter, doppelter Tod | Einheitliche Gameplay-Zeit, Laufereignisse begrenzen, AC-01/04/05. |
| Restore wartet auf angehaltene Engine-Aktualisierung | Hoch; endloser Ladezustand | Gameplay-Sperre und technische Vorbereitung getrennt; begrenzte Bereitschaftsprüfung, AC-01/13. |
| Alte Verbindungen / verspätete Lade- oder Schreibergebnisse | Hoch; Aktionen im falschen Lauf, doppelte Wiedergabe, Speicherwachstum | Exklusive Vorgänge, Laufprüfung und vollständiger Abbau; wiederholte Neubauten nach §26.4. |
| Geteilte veränderliche Resource oder Snapshotliste | Hoch; mehrere Objekte ändern sich zugleich oder Save-Kopie verändert sich nachträglich | Definitionen unverändert lassen, Instanzwerte und Kopien isolieren; AC-21. |
| Lade- und erste Darstellungsruckler | Mittel; Flucht und Atmosphäre brechen | Repräsentativen Export messen, Inhalte vorher bereitstellen, Ladestrategie nach Befund. |
| Zu viele abstrakte Systeme | Mittel; Aufwand ohne spielbaren Fortschritt | Chase in KI, Health/Effekt beim Spieler, gemeinsame Save-Pipeline; keine zusätzliche Zeit-, Transaktions- oder Migrationsplattform. |
| Optionale Features werden vorausgesetzt | Hoch für Umfang; Slice ohne Zusatzsystem nicht abschließbar | AC-25 und explizite Abhängigkeitsprüfung jeder Rätsel-/Fluchtstrecke. |
| Editor funktioniert, Windows-Export nicht | Hoch für Auslieferung; fehlende Daten oder unbeschreibbare Saves | Früher Exporttest, abschließend Installation und Neustart ohne Editor prüfen. |

## 30. Offene technische Entscheidungen

**NOCH OFFEN:** Alle folgenden Einträge benötigen eine spätere Entscheidung beziehungsweise einen begründeten Testbefund. Die jeweils genannte Empfehlung ist keine Vorwegnahme. GDD-Fragen bleiben fachlich maßgeblich.

### 30.1 Vor ARCHITECTURE.md und vor abhängiger Implementierung

**DESIGNEMPFEHLUNG – korrigierte Entscheidungsschranken:** Vor Beginn eines Architekturentwurfs besteht kein pauschaler Klärungszwang für die gesamte Liste. Zuständigkeiten, Lebensdauer und Datengrenzen sind bereits planbar. ARCHITECTURE.md darf entscheidungsabhängige Stellen ausdrücklich offen halten, soll aber nicht vorsorglich beide Perspektiven, mehrere Save-Modelle oder mehrere Navigationslösungen implementierungsreif ausarbeiten.

**NOCH OFFEN:** Vor verbindlicher Festlegung der betroffenen Architekturteile sind vor allem Hauptperspektive (T-02), Speicher-/Wiederanlaufpolitik (T-05), physische Interaktion/Türnavigation (T-04/T-06) und Weltlebensdauer/Ladestrategie (T-08) zu klären. Vor dem jeweiligen Implementierungsauftrag gelten die folgenden Abhängigkeiten. Ein ausdrücklich vereinbartes vorläufiges Profil ist zulässig, bleibt aber als vorläufig kenntlich.

| ID | Entscheidung | Warum sie früh benötigt wird / zulässiger Ausgangspunkt |
| --- | --- | --- |
| T-01 | Konkrete Godot-4-Version und Exportziel | Vor Projekt-/Exportbasis; kein Hindernis für rein fachlichen Architekturentwurf. |
| T-02 | First Person oder Third Person als Hauptperspektive für 0.1 | Vor verbindlicher Kamera-, Interaktions- und Spielerumsetzung; nicht nötig, um Save-Datenverantwortung zu beschreiben. First Person bleibt Empfehlung. GDD O-03. |
| T-03 | Tatsächliche Referenzhardware und anfängliches Rendering-/Grafikprofil | Vor Grafikbasis und Ressourcenbudgets; CPU/GPU/VRAM erfassen und ein Startprofil wählen. Nicht sämtliche Systemverträge davon abhängig machen. GDD O-02/O-16. |
| T-04 | Grundprinzip der Kreaturennavigation und Umgang mit Türen/Traversalgrenzen | Vor Navigations-/Verfolgungsumsetzung; sichtbares unerreichbares Ziel und technischen Defekt unterscheiden. GDD O-07/O-08. |
| T-05 | Speicherpolitik, Todes-Checkpointzuordnung und erstes versioniertes Save-Format | Politik vor verbindlichem Save-/KI-Restore-Entwurf, konkretes Format vor Serialisierung. Gefahrenspeichern, faire Anker und Verhältnis manueller Punkt/Todes-Checkpoint klären; keine global überschriebene Referenz. GDD O-13. |
| T-06 | Vereinfachte oder physische Interaktion als Grundansatz | Vor Tür-/Schalter-/Traversalumsetzung und zugehörigem Save-Schema; kontrollierte logische Interaktion empfohlen. GDD O-09/O-11. |
| T-07 | Minimale Health-/Todesregel und Zeit-/Pausenregeln | Vor Schaden und den jeweiligen Ansichten; Grundpause ist Pflicht, Pause beim Lesen/Inventar bleibt Auswahl. Keine Heilmechanik vorwegnehmen. GDD O-10/O-17. |
| T-08 | Erste Ladestrategie des Slice | Vor konkreter Weltlebensdauer und Referenzverwaltung; klein vollständig laden bevorzugt, Übergänge nur nach Bedarf. GDD O-15. |

**DESIGNEMPFEHLUNG:** Entscheidungen an der jeweils benötigten Stelle treffen, statt alle 22 Fragen zum globalen Startblocker zu machen. Keine beliebigen Gameplayannahmen treffen, um einen noch abhängigen Implementierungsauftrag künstlich freizugeben. ARCHITECTURE.md kann diese Abhängigkeiten als klar begrenzte Entscheidungspunkte aufnehmen.

### 30.2 KANN WÄHREND DES PROTOTYPINGS ENTSCHIEDEN WERDEN

**NOCH OFFEN:** Diese Punkte können anhand kleiner Tests entschieden werden, müssen aber vor Fertigstellung des jeweils abhängigen Systems feststehen. Prototyping beschreibt hier eine spätere Entwicklungsphase; es wird durch dieses Dokument nicht begonnen.

| ID | Entscheidung | Spätester fachlicher Bedarf |
| --- | --- | --- |
| T-09 | Inventarbedienung, Kapazität, Stapeln und Schutz kritischer Items | Vor endgültigem Inventar-/Pickup-Verhalten und Rätselzugängen; GDD O-11. |
| T-10 | Bewegungs-/Klettergrenzen, Eingabeverhalten und Trefferfolgen | Vor verbindlichen Fluchtwegen und Levelmaßen; GDD O-08/O-10. |
| T-11 | Tempoeffekt-Regel und vorläufige Health-/KI-Tuningwerte | Vor vollständigem Gefahrentest; Stärke, Dauer, Suchzeiten und Schadensmengen bleiben abstimmbar. GDD O-07/O-10/O-12. |
| T-12 | Hördämpfung, Wahrnehmungsprüfungen und konkrete Navigationsparameter | Vor Abnahme fairer Verfolgung und Suche; GDD O-07/O-08. |
| T-13 | Speicheranzahl, konkrete Orte, Bedienung und Umfang kompatibler Altstände | Vor vollständigem Save-UI-/Restore-Test; beide Speicherarten sind bereits Pflicht. GDD O-13. |
| T-14 | Audio-Workflow, Oberflächenkategorien, Importprofile und Test-Hörsetup | Vor Integration größerer Audiomengen; kritische Signale bereits bei Systemtests prüfen. |
| T-15 | Asset-Austausch-/Importformate, Maßstab und Datenformate | Vor erster regulärer Assetintegration; glTF/GLB ist Empfehlung, keine Assetauswahl. |
| T-16 | Rätsel-/Storybedingungen und zugehörige Reset-/Einmalregeln | Nach gemeinsamer Inhaltsentscheidung, vor Umsetzung der konkreten Rätsel und Enthüllung; GDD O-06/O-09. |
| T-17 | Testwerkzeuge, Debugoberfläche und endgültige Restore-Validierung | Früh mit dem ersten betroffenen System; keine nachträgliche Blackbox-Prüfung. |
| T-18 | Konkrete Ressourcen-, Ladezeit- und Framezeitbudgets | Nach repräsentativen Messungen; vor umfangreicher Level-/Assetproduktion. |

**DESIGNEMPFEHLUNG:** Zielgruppe, Gewaltgrenzen, Hauptfigur und konkrete Handlung sind keine technischen Ersatzentscheidungen. Sie bleiben im GDD offen und werden vor den entsprechenden Inhaltsarbeiten geklärt. Sie müssen nicht durch erfundene Inhalte gefüllt werden, um reine Zustands- oder Speichertests zu planen.

### 30.3 KANN BIS ZUM POLISH OFFEN BLEIBEN

**NOCH OFFEN:** Nur Verfeinerungen dürfen so lange warten; keine grundlegenden Regeln oder fehlende Pflichtfunktionen.

| ID | Entscheidung | Grenze des Aufschubs |
| --- | --- | --- |
| T-19 | Feine Lichtbalance, Materialabstimmung und optionale Grafikqualitätsstufen | Renderer, grobe Lesbarkeit und tragfähiges Budget stehen vorher fest. |
| T-20 | Endgültige Soundmischung, Variantenbalance und Musikübergänge | Akustische Erkennbarkeit und KI-Geräuschregeln müssen vorher funktionieren. |
| T-21 | Visuelle UI-Verfeinerung und feinere Kameraglättung | Bedienkonzept, Fokus, Grundlesbarkeit und Bewegungsgefühl dürfen nicht bis dahin offenbleiben. |
| T-22 | Finale Verpackung des Installers und Präsentation des Abschlussbildschirms | Standalone-Export und Speichern ohne Editor werden bereits früher geprüft. |

Optionale Systeme werden nicht automatisch zum Polish-Pflichtumfang. Controller, Perspektivwechsel und weitere Gameplaymechaniken folgen nur dem jeweils erteilten Auftrag.

## 31. Definition of Done für Technical Design / V0.1-Systembasis

### 31.1 Technical Design als Planungsdokument

**TECHNISCHE ANFORDERUNG:** Der Planungsentwurf ist vollständig, wenn:

- Alle beauftragten Kernsysteme mit Verhalten, Verantwortlichkeit und Informationsbedarf beschrieben sind.
- Autosave/Checkpoints und zusätzliche manuelle Speicherpunkte ausdrücklich enthalten und nicht optionalisiert sind.
- Persistenz, Neuinitialisierung und offene Restore-Politik voneinander unterscheidbar sind.
- Für alle Hauptsysteme prüfbare Abnahmekriterien und für kritische Fehler robuste Reaktionen vorliegen.
- Offene Gameplay-Entscheidungen aus dem GDD nicht still festgelegt und technische Empfehlungen gekennzeichnet sind.
- Godot 4/GDScript, Windows-Testziel und 16 GB RAM in Planung und Risiken berücksichtigt werden.
- ARCHITECTURE.md daraus später konkrete Zuständigkeiten und Schnittstellen ableiten kann, ohne hier schon vollständige Klassen-, Datei- oder Szenenstrukturen zu erhalten.

Vollständige Planung bedeutet nicht Implementierungsfreigabe jeder Empfehlung. Die Entscheidungen aus §30.1 werden vor der jeweils abhängigen Festlegung beziehungsweise Implementierung getroffen; ein Architekturentwurf kann vorher beginnen. Dieses Dokument behauptet keine bereits bestandenen Laufzeittests.

### 31.2 Spätere V0.1-Systembasis

**TECHNISCHE ANFORDERUNG:** Die spätere Systembasis ist funktionsfähig, wenn die funktionalen Anteile von AC-01 bis AC-25 und die Save-/Lebensdauertests in einer zusammenhängenden technischen Teststrecke erfüllt sind. Diese darf Platzhalter und abstrakte Rätsel-/Storybedingungen verwenden; ein konkreter Inhalt ist dadurch nicht beschlossen. Ein eigenständiger Export muss starten, speichern und laden. Finale Installation, Produktionsinhalte und Präsentationsqualität werden erst am Slice abgenommen. Es dürfen keine bekannten fortschrittsblockierenden Zustandsfehler offen sein.

Eine funktionsfähige Systembasis allein ist noch nicht der fertige Vertical Slice. Für dessen Abnahme gelten AC-01 bis AC-25 im vollständigen Spiel sowie die fachlichen GDD-Qualitätsziele: ungefähr 15–25 Minuten, zwei tatsächlich unterschiedliche gestaltete Rätsel, wirksame Hinweise/Enthüllung, Atmosphäre, lesbare realistische Optik, überzeugende Bewegung und Sound sowie eine installierbare spielbare Fassung. Keine Pflichtfunktion darf nur über ein Debugwerkzeug erreichbar sein. Der frühere Entwurf vermischte diese beiden Abnahmestufen; sie sind hier ausdrücklich getrennt.

### 31.3 Konsistenzprüfung gegen das GDD

**Prüfergebnis nach dem zweiten Durchgang:** Keine verbleibenden fachlichen Widersprüche zum GDD festgestellt. Interne Schwächen des Erstentwurfs bei Bewegungszuständen, Checkpoint-Verweisen, Restore-Bereitschaft und Abnahmestufen wurden korrigiert. Die folgenden Abgrenzungen bleiben ausdrücklich erhalten:

| Geprüfter Punkt | Ergebnis |
| --- | --- |
| Speichern, GDD §§29–32 | Autosave/Checkpoints plus manuelle Speicherpunkte sind Pflicht; freies Speichern und genaue Bedienung nicht beschlossen. |
| Grafik, GDD §24 | Realistisch wirkendes 3D ohne Pixel-Art/verpixelten Stil; Hardwareprofil und konkrete Lichttechnik offen. |
| Perspektive, GDD O-03 | First Person nur technische Empfehlung; keine stille Festlegung oder Pflicht zum Wechsel. |
| Rätsel/Story/Kreatur, GDD §§16–17, 21 | Zustände und Schnittstellen beschrieben; keine endgültigen Inhalte, Namen oder Designs erfunden. |
| Kampf und Crafting, GDD §§18, 20 | Flucht/Survival bleiben Kern; weder Kampfsystem noch Bauen oder Crafting als Pflichtvoraussetzung eingeführt. |
| Bewegung, GDD §14 | Grundlegendes Parkour enthalten; Schwimmen, umfangreiches Rutschen und Greifen/Ziehen nicht in den Kern gezogen. |
| GDD-Empfehlungen | Taschenlampe ohne Batterieverbrauch, KI-Reset, Tempo-Balancing und andere Konkretisierungen als Empfehlungen beziehungsweise offene Regeln behandelt. |
| Zusätzlicher technischer Auftrag | Windows-Testziel, Singleplayer, GDScript ohne .NET und Pause sind ausdrücklich vom aktuellen Auftrag gedeckt; das GDD bleibt unverändert. |
| Ressourcen und Umfang | 16 GB RAM berücksichtigt; keine unbegründeten finalen Leistungs-/Gameplaywerte, keine technischen AAA-Pflichten. |

Interne Gegenprüfung: Nur ein Bewegungsverantwortlicher und ein KI-Verhaltensmodell; Freigaben getrennt von Türstellung; Datenzuständigkeiten ohne permanente Save-Zweitkopie; Checkpoint-Wiederanlauf unabhängig von überschriebenen anderen Dateien; Pause getrennt von Restore-Vorbereitung; alte Laufmeldungen gesperrt; Einstellungen getrennt vom Fortschritt; Abnahmekriterien unterscheiden Systembasis und fertigen Slice. Die entsprechenden Fehler- und Prüffälle sind in §§24–26 enthalten.

Offene Designspannungen sind keine aufgelösten Entscheidungen: Exakte Health-Regeln, Gefahrenspeichern, KI-Reset und Perspektive benötigen weiterhin bewusste Auswahl. Die Konsistenzprüfung betrifft den Dokumentinhalt, nicht eine noch nicht vorhandene Umsetzung.

## 32. Dokumenthistorie

| Datum | Version | Änderung | Status |
| --- | --- | --- | --- |
| 19.09.2026 | 0.1 | Technischer Planungsentwurf für den Dark-Rooms-Vertical-Slice: Systemverhalten, Kommunikation, Persistenz/Restore, Konfiguration, Ressourcen, Fehlerfälle, Debugmöglichkeiten, Abnahmekriterien und priorisierte offene Entscheidungen. | Gegen das freigegebene GDD geprüft; technische Empfehlungen nicht automatisch freigegeben; keine Implementierung. |
| 19.09.2026 | 0.2 | Zweiter Architektur- und Qualitätsdurchgang: Verantwortungen gebündelt, Bewegungsmodell und KI vereinfacht, Tür-/Navigationsverträge präzisiert, selbstständige Save-Pakete und sicherer Weltlebenszyklus empfohlen, Resource-Isolation und Regressionstests ergänzt, Entscheidungsschranken und Abnahmestufen korrigiert. | GDD unverändert; wichtige technische Abweichungen als DESIGNEMPFEHLUNG begründet; keine neuen Gameplay-Festlegungen oder Implementierung. |

Die verlinkte offizielle Godot-Dokumentation wurde am 19.09.2026 als technische Referenz herangezogen. Ihre `stable`-Links können sich mit neuen Engine-Versionen ändern; bei Wahl der konkreten Godot-Version sind die entsprechenden Angaben erneut abzugleichen. Die fachlichen Vorgaben stammen aus dem GDD und dem aktuellen Auftrag, nicht aus externen Beispielen.
