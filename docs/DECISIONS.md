# Dark Rooms – Architecture Decisions

## Zweck und Verbindlichkeit

Dieses Dokument hält die gemeinsam getroffenen technischen Entscheidungen für Version 0.1 fest. Grundlage sind die Projektregeln, das freigegebene [Game Design Document](GAME_DESIGN.md) und das freigegebene [Technical Design Document, Version 0.2](TECHNICAL_DESIGN.md).

Die Einträge konkretisieren ausdrücklich bisher offene Fragen oder bestätigen technische Empfehlungen. Sie ändern keine darüber hinausgehenden Game-Design-Entscheidungen. Wo GDD oder Technical Design einen hier entschiedenen Teilaspekt noch als offen führen, dokumentiert dieser Beschluss den neueren Entscheidungsstand. Die übrigen offenen Fragen und Empfehlungen bleiben unverändert. Eine spätere Neubewertung ist möglich, aber keine Erlaubnis, einen angenommenen Beschluss stillschweigend zu ersetzen.

**Statusbedeutung:** „Angenommen“ bezeichnet einen gemeinsam freigegebenen Beschluss im angegebenen Umfang. Ein bevorzugter Startansatz gilt als Ausgangspunkt, bleibt aber bei dokumentiertem technischem Anlass revidierbar. „Offen“ bedeutet, dass noch keine konkrete Lösung gewählt wurde.

## Übersicht

| ID | Thema | Status / Ergebnis |
| --- | --- | --- |
| ADR-001 | Hauptperspektive | Angenommen: First Person für 0.1 |
| ADR-002 | Interaktionsmodell | Angenommen: kontrollierte/logische Interaktionen |
| ADR-003 | Level-/Ladestrategie | Angenommen: zunächst ein kleiner vollständig geladener Bereich |
| ADR-004 | Kreaturennavigation | Angenommen: Godots 3D-Navigation mit kontrollierten Durchgängen |
| ADR-005 | Save-/Restore-Politik | Angenommen: beide Speicherarten an vorgesehenen stabilen/sicheren Zuständen |
| ADR-006 | Save-Datenformat und Speicherort | Angenommen als bevorzugter Startansatz: JSON unter `user://` |
| ADR-007 | Engine und erstes Exportziel | Angenommen: Godot 4.7.2 Stable, GDScript, Windows x86-64 |
| ADR-008 | Rendering | Offen: Bewertung nach GPU-Erfassung und frühem Grafiktest |

## ADR-001 – First Person als Hauptperspektive

**ID:** ADR-001

**Datum:** 19.09.2026

**Status:** Angenommen für Version 0.1.

**Entscheidung:** Version 0.1 verwendet First Person als Hauptperspektive. Third Person beziehungsweise ein Perspektivwechsel bleibt für spätere Versionen grundsätzlich möglich; daraus entsteht keine zusätzliche Pflicht für 0.1.

**Begründung:** First Person unterstützt unmittelbaren Horror und Atmosphäre, erleichtert die Abstimmung räumlichen Audios und die Erkundung aus Sicht der Hauptfigur. Die Konzentration auf diese Perspektive reduziert den Aufwand für eine Third-Person-Kamera und die vollständige Darstellung der Charakteranimation.

**Konsequenzen:** Kamera, Interaktionszielwahl, Lesbarkeit von Hindernissen und Parkour werden zunächst für First Person ausgelegt. Eine zweite Kamera- und Bedienvariante wird nicht parallel vorausgesetzt. Welche Körperteile oder Animationen aus der Egoansicht sichtbar sind, wird hier nicht festgelegt. Die feste Hauptfigur und ihre noch offenen gestalterischen Eigenschaften bleiben unverändert.

**Mögliche spätere Neubewertung:** Für eine spätere Version kann Third Person oder ein Perspektivwechsel anhand eines konkreten Spielerlebnisziels und des zusätzlichen Kamera-, Animations- und Testaufwands geprüft werden. Eine Änderung der Hauptperspektive von 0.1 würde einen neuen ausdrücklichen Beschluss erfordern.

**Bezug:** GDD §§14, 28 und O-03; Technical Design §6 und T-02. Die Auswahl der Hauptperspektive ist entschieden, weitere Kamera- und Bewegungsdetails bleiben offen.

## ADR-002 – Kontrollierte/logische Interaktionen

**ID:** ADR-002

**Datum:** 19.09.2026

**Status:** Angenommen als Grundansatz für Version 0.1.

**Entscheidung:** Türen, Schalter, Pickups und Rätselobjekte besitzen klare logische Zustände. Animation und Darstellung folgen diesen Zuständen. Eine vollständige physikalische Simulation von Türen oder Gegenständen ist keine Voraussetzung für 0.1.

**Begründung:** Kontrollierte Zustandsübergänge machen Interaktionen vorhersehbar, leichter testbar und konsistent speicherbar. Sie begrenzen den Aufwand und vermeiden, dass zufällige physikalische Lagen notwendige Gegenstände oder Wege blockieren.

**Konsequenzen:** Die jeweilige Zustandslogik bestimmt, ob eine Aktion erlaubt ist und welches Ergebnis sie hat. Türstellung, Verriegelung, Kollision und Navigierbarkeit müssen zusammenpassen; eine Türfreigabe ist nicht automatisch eine offene Tür. Kollisionsprüfung bleibt notwendig: Der Verzicht auf freie Physiksimulation bedeutet nicht, dass Figuren oder Türen durch Hindernisse bewegt werden dürfen. Es werden noch keine konkreten Animationen, Eingabetasten oder endgültigen Rätselregeln festgelegt.

**Mögliche spätere Neubewertung:** Einzelne physikbasierte Interaktionen können ergänzt werden, wenn sie einen konkreten spielerischen Nutzen zeigen und Lösbarkeit, Speicherung sowie Ressourcenbedarf beherrschbar bleiben. Sie dürfen den funktionierenden 0.1-Kern nicht nachträglich voraussetzen.

**Bezug:** GDD §§15–16; Technical Design §§8, 11 und T-06. Der Grundansatz ist entschieden, konkrete Interaktions- und Blockaderegeln bleiben offen.

## ADR-003 – Kleiner vollständig geladener Vertical-Slice-Bereich

**ID:** ADR-003

**Datum:** 19.09.2026

**Status:** Angenommen als anfängliche Strategie für Version 0.1; anhand realer Messungen revidierbar.

**Entscheidung:** Zunächst wird ein kleiner zusammenhängender Vertical-Slice-Bereich vollständig geladen. Es gibt kein Open-World-Streaming und keine komplexe Streaming-Infrastruktur.

**Begründung:** Der begrenzte Slice benötigt zunächst keine Infrastruktur zum laufenden Nachladen einer großen Welt. Ein vollständig verfügbarer Bereich vereinfacht Objektbezüge, Navigation, Rätselzustände und Restore. Umfang und Ressourcen müssen dabei zum Entwicklungsrechner mit 16 GB RAM passen.

**Konsequenzen:** Die Planung geht zunächst von einer zusammenhängend verfügbaren Spielwelt aus. „Vollständig geladen“ verlangt weder eine einzige Godot-Szene noch gleichzeitig aktive Verarbeitung sämtlicher Objekte. Szenenaufteilung und kontrollierte Aktivierung bleiben Architekturarbeit. Ladezeiten und Spitzenverbrauch werden gemessen; dieser Beschluss ist keine Zusage, dass beliebige Assetmengen in den Speicher passen.

**Mögliche spätere Neubewertung:** Zeigen reale Messungen RAM- oder Ladeprobleme, darf eine einfachere Entlastung oder eine begrenzte Aufteilung in Ladebereiche geprüft und die Strategie begründet überarbeitet werden. Daraus folgt keine automatische Einführung von Open-World-Streaming.

**Bezug:** GDD §§23, 30; Technical Design §§20, 23 und T-08. Die anfängliche Ladestrategie ist entschieden, konkrete Bereichsgrenzen und Leistungsbudgets nicht.

## ADR-004 – Godots 3D-Navigation für die Kreatur

**ID:** ADR-004

**Datum:** 19.09.2026

**Status:** Angenommen als Navigationsbasis für Version 0.1.

**Entscheidung:** Die Kreatur nutzt Godots 3D-Navigationssystem als Basis. Türen und andere bewusst steuerbare Durchgänge beeinflussen ihre Navigierbarkeit kontrolliert. Es gibt keine permanente Neuberechnung des gesamten Levels, keine komplexe Hindernisvermeidung ohne nachgewiesenen Bedarf und keine Teleports oder versteckte Spielerortung als Fehlerkorrektur.

**Begründung:** Die Engine-Navigation bietet einen passenden Ausgangspunkt für die eine Kreatur im gestalteten Slice. Kontrollierte Durchgänge verbinden Wegsuche und tatsächliche Zugänglichkeit. Begrenzte Aktualisierung reduziert unnötige Arbeit; der Verzicht auf versteckte Korrekturen schützt die Nachvollziehbarkeit der Bedrohung.

**Konsequenzen:** Geschlossene Durchgänge dürfen nicht als nutzbare Route behandelt werden. Kollisionsprüfung und Wegsuche müssen abgestimmt sein; physische Blockade allein ersetzt keine kontrollierte Navigierbarkeit. Navigation verarbeitet nur Ziele, die aus gültiger Wahrnehmung oder zulässigem eigenem Verhalten stammen. Die konkrete Aufteilung der Navigationsflächen, Verbindungstechnik, verwendeten Engine-Bausteine und die Reichweiten bleiben offen. Unerreichbare Ziele erhalten kontrollierte Ausgänge statt erzwungener Bewegung durch Hindernisse.

**Mögliche spätere Neubewertung:** Nachgewiesene Probleme mit dynamischen Hindernissen, Durchgängen oder späteren zusätzlichen Kreaturen können gezielte Erweiterungen begründen. Eine solche Änderung muss anhand konkreter Fälle getestet werden; Teleports und Allwissenheit werden dadurch nicht als Reparaturmechanismus freigegeben.

**Bezug:** GDD §17; Technical Design §§12–14 und T-04. Die Navigationsbasis ist entschieden, konkrete Navigations- und Verhaltensparameter bleiben offen.

## ADR-005 – Sichere Speicherzustände und eigenständiger Wiederanlauf

**ID:** ADR-005

**Datum:** 19.09.2026

**Status:** Angenommen als Save-/Restore-Politik für Version 0.1.

**Entscheidung:** Autosaves/Checkpoints und zusätzliche manuelle Speicherpunkte bleiben Pflicht. Für 0.1 wird grundsätzlich nur an dafür vorgesehenen stabilen/sicheren Zuständen gespeichert. Freies Speichern mitten in aktiver Verfolgung oder instabilen Übergängen ist nicht vorgesehen. Manuelle Speicherstände sind eigenständig ladbar und behalten ihren zugehörigen Todes-Wiederanlauf.

**Begründung:** Stabile Speicherzustände begrenzen widersprüchliche Kombinationen aus Spielerposition, Türen, Rätseln und Gegnerverhalten. Ein eigenständig erhaltener Todes-Wiederanlauf verhindert, dass ein älterer manueller Stand durch spätere Autosaves unbrauchbar wird oder nach einer Niederlage zum falschen Fortschritt führt.

**Konsequenzen:** Beide Speicherarten nutzen konsistente vollständige Fortschrittsdaten. Ein manueller Stand darf nicht allein auf eine später überschriebene Autosave-Datei verweisen. Speichern in einem halben Pickup, einer laufenden instabilen Bewegung oder einer widersprüchlichen Tür-/Rätseländerung ist nicht zulässig. „Sicher“ muss für den späteren Wiederanlauf geprüft werden; bloßes Fehlen einer aktuellen Sichtung der Kreatur genügt nicht als Nachweis.

Die konkrete Definition zulässiger Speicherstellen und Suchphasen, Anzahl der Spielstände, Bedienung, Snapshot-Struktur und Gegner-Resetdetails bleiben offen. Ebenso offen bleibt, ob ein manueller Speicherpunkt selbst einen neuen Todes-Checkpoint aktiviert. Der Beschluss garantiert dessen korrekte Zuordnung, entscheidet aber nicht diese zusätzliche Regel. Er bestätigt auch nicht pauschal alle im Technical Design vorgeschlagenen Restore-Details.

**Mögliche spätere Neubewertung:** Freieres Speichern kann für eine spätere Version geprüft werden, wenn ein konkreter Nutzen vorliegt und vollständige Wiederherstellung aktiver Bedrohungs- und Übergangszustände robust beherrscht wird. Beide Pflichtspeicherarten und die Eigenständigkeit manueller Stände werden nicht stillschweigend aufgegeben.

**Bezug:** GDD §§29–30 und O-13; Technical Design §17 sowie T-05/T-13. Der grundsätzliche Speicherrahmen ist entschieden, seine verbleibenden Detailregeln nicht.

## ADR-006 – JSON und `user://` als Save-Ausgangspunkt

**ID:** ADR-006

**Datum:** 19.09.2026

**Status:** Angenommen als bevorzugter Startansatz für Version 0.1; technisch begründet revidierbar.

**Entscheidung:** JSON ist das bevorzugte anfängliche Save-Datenformat. Gespeichert wird unter Godots `user://`.

**Begründung:** Ein lesbares Datenformat unterstützt die Prüfung der kleinen, klar strukturierten Fortschrittsdaten des Slice. Ein benutzerbezogener Speicherort trennt Spielstände vom Installationsordner und den Projektressourcen.

**Konsequenzen:** Zustände werden als ausdrücklich beschriebene Daten mit Version und stabilen Inhaltsbezügen gespeichert. Positionen und andere benötigte Engine-Werte erhalten eine passende Darstellung in einfachen JSON-Datentypen. Formatwahl ersetzt weder Konsistenzprüfung noch Schutz des letzten gültigen Stands. Konkretes Schema, Unterverzeichnisse, Dateinamen, sichtbare Slots und Ersetzungsverfahren sind noch nicht festgelegt.

**Mögliche spätere Neubewertung:** Ergibt die Implementierung einen klaren technischen Grund, darf dieser Startansatz überarbeitet werden. Ein Wechsel benötigt eine dokumentierte Begründung und eine ausdrückliche Behandlung bereits vorhandener Spielstände; eine allgemeine Migrationsplattform ist damit nicht beschlossen.

**Bezug:** GDD §29; Technical Design §§17, 21 und T-05. JSON und `user://` konkretisieren die bisher genannten Kandidaten, ohne offene Speicherbedienung festzulegen.

## ADR-007 – Engine-Basis und erstes Exportziel

**ID:** ADR-007

**Datum:** 19.09.2026

**Status:** Angenommen.

**Entscheidung:** Die projektseitig festgelegte Engine-Basis ist **Godot 4.7.2 Stable**. Programmiert wird mit **GDScript**. **Windows x86-64** ist das erste Export- und Testziel.

**Begründung:** Eine konkrete gemeinsame Engine-Version und ein klar bestimmtes Exportziel schaffen eine reproduzierbare Grundlage für Entwicklung, Tests und spätere Reviews. GDScript entspricht den Projektregeln und dem freigegebenen Technical Design.

**Konsequenzen:** Die spätere Projekt- und Exportkonfiguration richtet sich nach dieser Version und Zielarchitektur; passende Exportvorlagen sind zu verwenden. C#/.NET bleibt für 0.1 außerhalb des Umfangs. Andere Zielplattformen werden nicht automatisch zugesagt. Konkrete Windows-Versionen, Mindesthardware, GPU und Installer-Verfahren bleiben offen. Dieser Beschluss enthält keine Auswahl des Renderers.

**Mögliche spätere Neubewertung:** Ein Engine-Update oder weiteres Exportziel benötigt einen begründeten neuen Beschluss sowie Prüfung von Importen, Darstellung, Verhalten und Spielständen. Die Baseline wird nicht durch ein unbeabsichtigtes Editor-Update ersetzt.

**Bezug:** Projektregeln; GDD §7 und O-02; Technical Design §3 und T-01. Engine-Version und erste Exportarchitektur sind entschieden; die übrigen Plattform- und Hardwarefragen nicht.

## ADR-008 – Rendererentscheidung bleibt offen

**ID:** ADR-008

**Datum:** 19.09.2026

**Status:** Offen hinsichtlich des konkreten Renderers; das Bewertungsverfahren ist gemeinsam festgelegt.

**Entscheidung:** Es wird noch kein Renderer ausgewählt. Forward+, Mobile und Compatibility werden anhand der tatsächlichen GPU und eines frühen Grafiktests bewertet. Keine der drei Optionen gilt durch diesen Eintrag als Standard oder bevorzugte Wahl.

**Begründung:** Die konkrete GPU ist noch nicht verbindlich bekannt. Die Zielrichtung einer realistisch wirkenden, gut lesbaren 3D-Grafik und 16 GB RAM allein begründen keine belastbare Rendererwahl.

**Konsequenzen:** Die spätere Architektur darf rendererabhängige Beleuchtungs- oder Darstellungstechniken nicht ungeprüft zur Voraussetzung machen. Vor der Auswahl sind die tatsächliche Hardware und ein repräsentativer Grafiktest heranzuziehen. Kriterien sind benötigte Bildwirkung, Lesbarkeit, Kompatibilität, Laufzeitverhalten und Ressourcenbedarf. Ein konkreter Renderer, finale Leistungsbudgets oder bestimmte Grafikeffekte werden hier nicht beschlossen.

**Mögliche spätere Neubewertung:** Sobald Hardwaredaten und Grafiktestergebnisse vorliegen, kann dieser offene Punkt durch einen ausdrücklichen Auswahlbeschluss geschlossen werden. Spätere neue Zielhardware oder nachgewiesene Probleme können eine erneute Bewertung begründen.

**Bezug:** GDD §§24–25, 34; Technical Design §23 und T-03. Renderer und vollständiges Grafikprofil bleiben offen.

## Konsistenzprüfung und verbleibende Abgrenzungen

**Prüfdatum:** 19.09.2026

**Ergebnis:** Keine fachlichen Widersprüche zum freigegebenen GDD oder zum Technical Design 0.2 festgestellt. Die Beschlüsse wählen ausdrücklich vorbereitete technische Richtungen beziehungsweise konkretisieren bislang offene Fragen. Sie fügen keine Story-, Kreaturen- oder Rätselinhalte hinzu.

| Beschluss | Abgleich | Verbleibende Abgrenzung |
| --- | --- | --- |
| ADR-001 | GDD lässt die Perspektive für 0.1 offen; das Technical Design empfiehlt die Prüfung von First Person. | Die Hauptperspektive ist nun gewählt, nicht alle Kamera- oder Animationsdetails. |
| ADR-002 | Entspricht der empfohlenen logischen Interaktion. | Kollisionsprüfung bleibt notwendig; konkrete Interaktionsregeln bleiben offen. |
| ADR-003 | Passt zum kleinen gestalteten Slice und dem einfachen Ladeansatz. | Kein konkreter Raumplan, kein einzelner zwingender Node-Tree und keine unbegrenzte Speicherzusage. |
| ADR-004 | Übernimmt die vorgeschlagene Engine-Navigation und wahrt die begrenzte Gegnerwahrnehmung. | Türverhalten, Navigationsaufteilung und Tuning sind noch auszuarbeiten. |
| ADR-005 | Bestätigt beide Pflichtspeicherarten und konkretisiert zulässige Speicherzustände. | Speicherslots, genaue sichere Stellen, manueller Punkt/Todes-Checkpoint und Resetdetails bleiben offen. |
| ADR-006 | Wählt den im Technical Design genannten Startansatz. | Save-Schema und Bedienung werden damit nicht festgelegt. |
| ADR-007 | Konkretisiert Godot 4/GDScript und das Windows-Ziel. | Renderer, konkrete Windows-Versionen und Mindesthardware bleiben offen. |
| ADR-008 | Entspricht der ausdrücklich offenen Grafikprofilentscheidung. | Es liegt keine Rendererfreigabe vor. |

Die früheren Offen-Markierungen in GDD und Technical Design werden in diesem Auftrag nicht geändert. Für die betroffenen Teilfragen sind beim späteren Architekturentwurf zusätzlich die hier dokumentierten neuen Beschlüsse zu berücksichtigen. Insbesondere ist T-03 nicht abgeschlossen, T-04/T-05 sind nur im beschriebenen Grundsatz entschieden, und Health-, Bedienungs- sowie Inhaltsfragen bleiben unberührt.

Die Prüfung ist ein Dokumentabgleich, kein Nachweis einer Installation, eines Grafiktests oder einer bereits funktionierenden Implementierung.
