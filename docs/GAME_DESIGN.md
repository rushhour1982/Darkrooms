# Dark Rooms – Game Design Document

## 1. Dokumentstatus

**Dokumentversion:** 0.1 · **Stand:** 19. September 2026

**Status:** Erste fachliche Ausarbeitung des gemeinsam ausgefüllten Game-Design-Fragebogens.

**Zweck:** Gemeinsame Spielvision für Vater und Sohn sowie fachliche Referenz für Codex, Claude Code und die spätere Umsetzung.

Die Dokumentversion ist nicht mit einer bereits spielbaren Spielversion gleichzusetzen. Der Projektstand besteht bislang aus einer Grundstruktur; die hier beschriebenen Systeme und Inhalte sind noch nicht umgesetzt.

### Verbindlichkeit und Leseregeln

| Kennzeichnung | Bedeutung | Umgang bei späteren Arbeiten |
| --- | --- | --- |
| **FEST BESCHLOSSEN** | Aus dem Auftrag beziehungsweise Fragebogen übernommene Vorgabe. | Fachlich verbindlich. Eine Änderung benötigt einen ausdrücklichen Auftrag. |
| **DESIGNEMPFEHLUNG** | Eigener Vorschlag zur Konkretisierung der Vision. | Diskussionsgrundlage; keine automatisch freigegebene Gameplay-Entscheidung. |
| **NOCH OFFEN** | Entscheidung, Detail oder Auswahl wurde noch nicht getroffen. | Nicht stillschweigend festlegen. Vor davon abhängiger Umsetzung klären. |

Eine Kennzeichnung gilt für den folgenden Absatz, die folgende Liste oder Tabelle bis zur nächsten Kennzeichnung beziehungsweise Unterüberschrift. Empfehlungen werden nicht dadurch verbindlich, dass spätere Abschnitte auf sie verweisen. Konkrete Zahlen in Empfehlungen sind Ausgangspunkte für gemeinsame Erprobung.

**FEST BESCHLOSSEN:** „Gesamtvision“ beschreibt die gewünschte Richtung des Spiels, nicht den Lieferumfang von Version 0.1. Für den Vertical Slice gilt die Abgrenzung in Abschnitt 30. Dieses Dokument beschreibt Spielerlebnis und Spielregeln; technische Architektur, Godot-Szenen und Code sind nicht Gegenstand dieser Ausarbeitung.

## 2. High Concept

**FEST BESCHLOSSEN:** Dark Rooms ist ein storygetriebenes 3D-Horror-Abenteuer mit einem Jungen als fester Hauptfigur. Er erkundet verlassene, zunehmend seltsame Orte, sammelt Gegenstände, löst Rätsel und entkommt bedrohlichen Kreaturen. Das große Ziel ist, zu überleben und ein zentrales Geheimnis aufzudecken.

Atmosphäre, Story und Rätsel bestimmen die Identität. Erkundung ist sehr wichtig. Klassischer Kampf ist trotz des Interesses an Action nicht die primäre Lösung: Beobachten, Ausweichen, Fliehen und cleveres Verhalten stehen zunächst im Vordergrund.

## 3. Elevator Pitch

**DESIGNEMPFEHLUNG – Formulierung der gemeinsamen Vision:**

> Ein Junge erkundet verlassene Gebäude, in denen Geräusche, Räume und Spuren mehr erzählen, als zunächst sichtbar ist. Er findet Werkzeuge, öffnet mit Rätseln neue Wege und kommt einem großen Geheimnis näher. Wenn eine Kreatur auf ihn aufmerksam wird, entscheiden Beobachtung, Orientierung und flüssige Bewegung darüber, ob er entkommt.

Der Pitch führt keine zusätzliche Hintergrundgeschichte ein. Er fasst die festgelegten Schwerpunkte in einer kurzen, gemeinsam besprechbaren Form zusammen.

## 4. Spiel-DNA

**FEST BESCHLOSSEN:** Die drei wichtigsten Elemente sind in dieser Reihenfolge Atmosphäre, Story und Rätsel. Erkundung verbindet sie. Bewegung und Sound sollen sich besonders hochwertig anfühlen.

| Interesse aus dem Fragebogen | Fachliche Bedeutung |
| --- | --- |
| Grusel: etwa 5/5 | Sehr hohe Spannung ist erwünscht; die Zahl ist keine Altersfreigabe. |
| Erkunden: etwa 5/5 | Räume, Hinweise, Gegenstände und versteckte Zugänge sind zentral. |
| Kämpfen: etwa 4/5 | Bedrohung und aktive Auseinandersetzung sind interessant; Flucht bleibt zunächst die wichtigste Antwort. |
| Rätsel: etwa 4/5 | Rätsel sind ein tragender Bestandteil, insbesondere Schalter und Türen. |
| Crafting: etwa 4/5 | Interesse an Gegenstands- und Werkzeugkombinationen, für 0.1 stark begrenzt. |
| Bauen: etwa 1/5 | Kein klassisches Basebuilding und praktisch kein Bausystem. |

**DESIGNEMPFEHLUNG:** Als interne Prüffrage dient: „Macht dieses Feature den Ort unheimlicher, das Geheimnis interessanter, das Rätsel verständlicher oder die Bewegung besser?“ Features ohne klaren Beitrag zu diesen Zielen werden zunächst zurückgestellt.

## 5. Design-Pillars

**DESIGNEMPFEHLUNG:** Die folgenden fünf Leitprinzipien übersetzen die festgelegte Spiel-DNA in überprüfbare Gestaltungsregeln.

| Leitprinzip | Bedeutung für das Erlebnis | Gegenprobe |
| --- | --- | --- |
| Atmosphäre durch Erwartung | Geräusche, räumliche Anordnung und Licht lassen den Spieler vermuten, dass etwas nicht stimmt. | Funktioniert die Spannung auch, bevor eine Kreatur sichtbar wird? |
| Entdecken erzählt Geschichte | Ein neuer Raum oder Gegenstand verändert das Verständnis des Ortes. | Hat Erkundung neben Beute auch einen erzählerischen Wert? |
| Rätsel folgen erkennbaren Regeln | Hinweise und Rückmeldungen erlauben begründete Lösungsversuche. | Kann ein Spieler erklären, warum seine Lösung funktioniert? |
| Bewegung gibt Handlungsspielraum | Leicht erlernbare, verlässliche Bewegung ermöglicht Erkunden und Entkommen. | Scheitert ein Versuch an einer Entscheidung statt an unklarer Steuerung? |
| Bedrohung ist lesbar | Sicht, Geräusche und Verhalten der Kreatur bieten Anhaltspunkte für Gegenmaßnahmen. | Kann der Spieler nach einer Niederlage erkennen, was er anders machen könnte? |

## 6. Zielerlebnis

**FEST BESCHLOSSEN:** Das Hauptgefühl ist starker Grusel. Gewünscht sind neugieriges Erkunden, Story-Entdeckungen, Rätsellösen und intensive Fluchtmomente. Das Bild soll ausreichend erkennbar bleiben; permanente extreme Dunkelheit ist nicht das Ziel.

**DESIGNEMPFEHLUNG:** Der Spannungsverlauf wechselt zwischen Neugier, leiser Beunruhigung, Erkenntnis, akuter Gefahr und kurzer Erleichterung. Ruhigere Abschnitte geben Gelegenheit, Räume zu verstehen und Hinweise aufzunehmen. Dadurch erhält eine Verfolgung Gewicht, ohne dass der gesamte Level dauernd hektisch sein muss.

Nach dem Slice sollte ein Spieler in eigenen Worten sagen können, was er erreichen wollte, wie er ein Rätsel gelöst hat und welche neue Frage die Enthüllung aufwirft.

## 7. Genre und Zielplattform

**FEST BESCHLOSSEN:** 3D-Horror-Abenteuer, storygetrieben, mit Erkundung, Rätseln, Survival-Elementen und flüssiger Bewegung. Die Umsetzung ist für Godot 4 vorgesehen. Version 0.1 wird mit Tastatur und Maus gesteuert; Controller-Unterstützung soll später ergänzt werden.

**DESIGNEMPFEHLUNG:** Für 0.1 zunächst eine Desktop-Plattform als verbindliches Testziel auswählen, damit Steuerung, Optik und Bewegung auf einem bekannten Gerät beurteilt werden können.

**NOCH OFFEN:** Unterstützte Betriebssysteme, Mindesthardware, Veröffentlichungskanäle und spätere weitere Plattformen. Tastatur und Maus legen noch kein konkretes Betriebssystem fest.

## 8. Zielgruppe

**FEST BESCHLOSSEN:** Das Dokument soll für die gemeinsame Arbeit von Vater und Sohn verständlich bleiben. Daraus folgt noch keine festgelegte Alterszielgruppe des fertigen Spiels.

**DESIGNEMPFEHLUNG:** Inhaltlich richtet sich das Spiel zunächst an Menschen, die atmosphärischen Horror, räumliches Erkunden und nachvollziehbare Rätsel mögen und dabei keine umfangreichen Rollenspielsysteme lernen möchten.

**NOCH OFFEN:** Konkrete Alterszielgruppe, inhaltliche Grenzen, Darstellung von Gewalt und Niederlagen sowie gewünschte Zugänglichkeitsoptionen. „Grusel 5/5“ entscheidet weder über explizite Gewaltdarstellung noch über eine Altersfreigabe. Diese Fragen sind vor der konkreten Ausarbeitung bedrohlicher Szenen gemeinsam zu klären.

## 9. Inspirationsquellen und Abgrenzung

**FEST BESCHLOSSEN:** Vorbilder liefern ausschließlich Anregungen für Mechaniken und Gefühle.

| Inspiration | Interessanter Aspekt für Dark Rooms |
| --- | --- |
| Fortnite | Action und flüssige Bewegung |
| Backrooms | Unheimliche Atmosphäre |
| Poppy Playtime | Story und Rätsel |
| Zelda | Erkunden |
| Roblox | Minigames |
| Minecraft | Survival |

Es werden keine Figuren, Namen, Welten, Monster, Designs, Geschichten oder geschützten Inhalte übernommen. Dark Rooms erhält eine eigene Identität, eigene Kreaturen, eine eigene Welt und eine eigene Story. Die Nennung einer Inspiration übernimmt nicht automatisch deren übrige Systeme: Survival bedeutet beispielsweise kein Basebuilding, und Minigames bedeuten noch keinen eigenen Minigame-Modus.

**DESIGNEMPFEHLUNG:** Eigene Entwürfe nach ihrer Funktion begründen: Welches Geräusch warnt vor dieser Kreatur? Was erzählt dieser Raum? Was lernt der Spieler durch dieses Rätsel? Ein Entwurf sollte ohne Verweis auf eine fremde Figur verständlich sein.

## 10. Hauptfigur

**FEST BESCHLOSSEN:** Die Hauptfigur ist ein Junge und bleibt eine feste Figur. Zu Beginn gibt es keine vollständige Charaktererstellung und keinen Begleiter. Fortschritt muss ihn nicht immer stärker machen.

**DESIGNEMPFEHLUNG:** Die Figur erhält eine nachvollziehbare unmittelbare Absicht für den Einstieg, damit das Betreten und weitere Erkunden des Ortes verständlich wird. Diese Motivation kann knapp vermittelt werden und muss nicht sofort ihre ganze Vergangenheit erklären.

**NOCH OFFEN:** Name, Alter, Aussehen, Persönlichkeit, Vorgeschichte, persönliche Motivation und Beziehung zum zentralen Geheimnis. Ebenso offen bleiben die genaue Größe und Bewegungsfähigkeiten der Figur im Verhältnis zur Umgebung.

## 11. Welt und Setting

**FEST BESCHLOSSEN:** Die Welt umfasst verlassene Gebäude und einzelne sorgfältig gestaltete Level statt einer Open World. Ein Wald sowie eine Spielzeugfabrik oder ein vergleichbarer verlassener Industrie-/Spielzeug-Ort sollen vorkommen. Geheime Räume sind ausdrücklich gewünscht. Die Welt darf zunehmend seltsam wirken. Tag/Nacht ist grundsätzlich interessant, aber noch kein beschlossenes dynamisches System.

**DESIGNEMPFEHLUNG:** Der erste Abschnitt verbindet einen kurzen Waldzugang mit einem kompakten Gebäudeteil. Wiedererkennbare räumliche Merkmale helfen bei der Orientierung; gezielte Unstimmigkeiten erzeugen Unsicherheit. Vertraute Abläufe und Gegenstände wirken dadurch zunehmend fragwürdig.

**NOCH OFFEN:** Endgültiger Ortstyp, Epoche, Region, Geschichte des Ortes, Grad des Übernatürlichen und die Regeln möglicher Weltveränderungen. Eine Spielzeugfabrik ist eine zulässige Richtung, aber noch keine ausgearbeitete Welt oder endgültige Festlegung auf diesen Gebäudetyp.

## 12. Atmosphäre und Horror-Philosophie

**FEST BESCHLOSSEN:** Besonders gewünscht sind Geräusche, deren Quelle zunächst unsichtbar bleibt, sowie überraschende Auftritte einer Kreatur. Spannung soll aus Sound, Räumen, Licht, Erwartung und Unsicherheit entstehen. Horror darf nicht ausschließlich aus billigen Jumpscares bestehen. Szenen dürfen nicht bloß so dunkel sein, dass kaum etwas zu erkennen ist.

**DESIGNEMPFEHLUNG:**

- Eine Bedrohung zunächst hörbar oder durch Spuren erfahrbar machen, bevor sie vollständig sichtbar wird.
- Überraschungen mit dem Ort und der Geschichte verbinden, damit sie mehr leisten als einen kurzen Schreck.
- Nach intensiven Ereignissen Zeit für Orientierung und Verarbeitung geben.
- Gefahrenhinweise wahrnehmbar halten, ohne jede Spannung durch eindeutige Warnsymbole aufzulösen.
- Unbekannte Ursachen zulassen, aber verständliche Handlungsoptionen anbieten: beobachten, abwarten, ausweichen oder fliehen.

**NOCH OFFEN:** Häufigkeit und Härte überraschender Auftritte, konkrete Horror-Motive und mögliche Einstellungen zur Intensität. Die genaue Ausgestaltung richtet sich auch nach der noch offenen Zielgruppe.

## 13. Core Gameplay Loop

**FEST BESCHLOSSEN:** Die wiederkehrenden Tätigkeiten sind Erkunden, Ressourcen beziehungsweise Gegenstände sammeln, Klettern/Parkour, Fliehen/Verstecken und Rätsellösen. Verstecken gehört zur Gesamtvision; ein eigenes Verstecksystem ist für 0.1 optional.

**DESIGNEMPFEHLUNG:** Der grundlegende Ablauf lautet:

1. Einen Raum betreten, Orientierung gewinnen und auf Geräusche achten.
2. Hinweise, Gegenstände oder neue Wege entdecken.
3. Ein Hindernis verstehen und durch Interaktion, Rätsellösung oder Bewegung überwinden.
4. Bei Gefahr das eigene Verhalten anpassen und der Kreatur entkommen.
5. Einen neuen Zugang oder eine Story-Erkenntnis gewinnen und von dort weiter erkunden.

Die Kreatur muss nicht in jeder Wiederholung auftreten. Eine Rätsellösung kann den nächsten Erkundungsbereich öffnen, während eine Verfolgung bekannte Räume vorübergehend anders nutzbar macht.

## 14. Bewegung und Parkour

**FEST BESCHLOSSEN:** Zur Gesamtvision gehören Laufen, Sprinten, Springen, Ducken, Schwimmen, Greifen/Ziehen, Rutschen, Klettern und Parkour. Die Steuerung soll leicht erlernbar sein; Bewegung soll besonders gut und flüssig wirken.

Für 0.1 sind Laufen, Sprinten, Springen, Ducken und grundlegendes Klettern/Parkour vorgesehen. Die vollständige Bewegungsliste ist nicht der Pflichtumfang des ersten Slice.

**DESIGNEMPFEHLUNG:** Grundlegendes Parkour für 0.1 auf das Überwinden klar erkennbarer niedriger Hindernisse und das Erreichen eindeutig gestalteter Kanten begrenzen. Eine sichere Stelle führt die Bewegung ein; später wird dieselbe Bewegung in einer Flucht gebraucht. Enge Sprünge über tödliche Abgründe sind kein notwendiger Beweis für gute Bewegung.

Sprinten und Ducken sollten verständliche Auswirkungen auf Tempo und eigene Geräusche haben. Das macht Bewegung zu einer Entscheidung zwischen schnellem Vorankommen und vorsichtigem Erkunden.

**NOCH OFFEN:** Bewegungswerte, Sprunghöhe, Klettergrenzen, Ausdauer, Fallfolgen, Luftkontrolle und genaue Lautstärkeunterschiede. Schwimmen, Rutschen und Greifen/Ziehen erhalten später einen konkreten Umfang. Eine wechselbare Perspektive ist denkbar; die Perspektive für 0.1 wird später entschieden.

## 15. Interaktion

**FEST BESCHLOSSEN:** Version 0.1 enthält Interaktionen mit Türen, Schaltern und aufnehmbaren Gegenständen sowie die Nutzung einer Taschenlampe. Ein kleines Inventar gehört dazu.

**DESIGNEMPFEHLUNG:** Ein einheitlicher Interaktionshinweis benennt die mögliche Handlung, zum Beispiel „Öffnen“, „Betätigen“ oder „Aufnehmen“. Eine blockierte Tür zeigt nachvollziehbar, dass sie verriegelt ist oder etwas benötigt. Erfolgreiche Aktionen liefern sichtbare und hörbare Rückmeldung.

Aufgenommene Story-Hinweise sollten in Ruhe gelesen werden können. Wichtige Gegenstände und Schalter sind anhand ihrer Gestaltung erkennbar und nicht nur über winzige Suchpunkte erreichbar.

**NOCH OFFEN:** Interaktionsreichweite, Halten oder Drücken, Verhalten beim Lesen während einer Bedrohung sowie die genaue Bedienung von Werkzeugen und physisch beweglichen Objekten.

## 16. Rätseldesign

**FEST BESCHLOSSEN:** Rätsel sind wichtig; Schalter und Türen bilden einen Schwerpunkt. Version 0.1 enthält zwei unterschiedliche Rätsel. Weitere passende Rätseltypen dürfen entwickelt werden.

**DESIGNEMPFEHLUNG:** Jedes Rätsel besitzt ein erkennbares Ziel, auffindbare Hinweise, nachvollziehbare Regeln und eine eindeutige Rückmeldung. Das erste Rätsel lehrt eine einfache Beziehung. Das zweite verlangt eine andere Denkleistung, statt dieselbe Lösung nur länger zu wiederholen.

| Vorschlag für 0.1 | Handlung und Denkleistung | Hinweise und Rückmeldung |
| --- | --- | --- |
| Rätsel A: Verbindung herstellen | Eine Tür benötigt Versorgung. Der Spieler verfolgt eine erkennbare Verbindung zu einem Schalter und aktiviert ihn. | Räumliche Verbindung, Zustandsanzeige und hörbare Reaktion der Tür erklären Ursache und Wirkung. |
| Rätsel B: Reihenfolge erschließen | Der Spieler entnimmt räumlich verteilten Hinweisen eine kurze Reihenfolge und überträgt sie auf gekennzeichnete Schalter. | Gleiche eindeutige Zeichen verbinden Hinweise und Bedienelemente; ein Fehlversuch setzt nur den Versuch zurück. |

Beide Vorschläge sind eigene, noch nicht freigegebene Rätselinhalte. Rätsel A prüft räumliches Beobachten, Rätsel B das Zusammenführen von Informationen. Weder festgelegte Symbolfolgen noch endgültige Raumdetails werden damit vorgegeben.

Weitere Empfehlungen: Keine Lösung ausschließlich über Farbe oder ein einmaliges Geräusch vermitteln. Fehlversuche dürfen keine notwendigen Gegenstände endgültig verbrauchen. Das zweite Rätsel sollte nach der ersten Verfolgung zunächst wieder Zeit zum Denken bieten.

**NOCH OFFEN:** Endgültige Rätsel, Schwierigkeitsgrad, benötigte Gegenstände, optionale Hilfen und ob spätere Rätsel unter Zeitdruck stattfinden. Rennen und Zeit-Challenges dürfen vorkommen, sind aber kein Pflichtbestandteil beider Rätsel.

## 17. Gegner und Gegner-KI

**FEST BESCHLOSSEN:** Version 0.1 enthält eine Kreatur beziehungsweise einen Gegnertyp. Sie patrouilliert, kann den Spieler sehen, hört Geräusche und reagiert darauf, verfolgt ihn und sucht nach ihm, wenn er entkommt. Kreaturen dürfen sprechen; Sprachausgabe ist zunächst nicht vorgesehen.

**DESIGNEMPFEHLUNG:** Folgende Verhaltensbeschreibung dient als fachliches Modell, nicht als Vorgabe einer technischen KI-Architektur.

| Verhalten | Wahrnehmbares Verhalten im Spiel | Mögliche Antwort des Spielers |
| --- | --- | --- |
| Patrouille | Die Kreatur bewegt sich durch einen begrenzten Bereich und verrät ihre Nähe durch charakteristische Geräusche. | Route beobachten, Abstand halten und einen passenden Moment nutzen. |
| Geräusch untersuchen | Ein auffälliges Geräusch führt sie an dessen vermuteten Ursprung. | Den Ort verlassen oder sich leiser bewegen. |
| Spieler erkennen | Freie Sicht auf den Spieler führt zu einer erkennbaren Reaktion. | Sichtkontakt unterbrechen oder rechtzeitig fliehen. |
| Verfolgen | Die Kreatur folgt dem wahrgenommenen Spieler aktiv. | Wegekenntnis, Sprinten und gelerntes Parkour nutzen. |
| Suchen | Nach Sichtverlust untersucht sie den zuletzt bekannten Bereich. | Distanz schaffen und keine neue Aufmerksamkeit auslösen. |
| Suche beenden | Ohne neue Hinweise kehrt sie zu einem ruhigeren Verhalten zurück. | Vorsichtig weiter erkunden. |

Die Kreatur sollte keine dauerhafte Kenntnis des Spielerstandorts besitzen. Ein Überraschungsauftritt darf inszeniert sein; das anschließende Verhalten soll trotzdem nachvollziehbar bleiben. Eine eigene Silhouette, Bewegung und akustische Wiedererkennbarkeit sind wichtiger als zusätzliche Gegnertypen.

**NOCH OFFEN:** Name, Gestalt, Ursprung, Persönlichkeit, Sprache, Erkennungsgrenzen, Suchdauer, Tempo und Schadensverhalten. Reaktionen auf die Taschenlampe, verschlossene Türen und bestimmte Parkour-Wege sind noch nicht festgelegt.

## 18. Kampf / Flucht / Survival

**FEST BESCHLOSSEN:** Das relativ hohe Interesse am Kämpfen und der Vorrang von Ausweichen/Flucht sind eine bewusste Designspannung. Später darf es begrenzte Möglichkeiten zur Abwehr oder situativen Auseinandersetzung geben. Version 0.1 konzentriert sich auf Flucht, Ausweichen und Survival; ein umfangreiches Kampfsystem ist nicht notwendig.

Lebenspunkte gehören zum Spiel. Zum Start gibt es kein überladenes Hunger-, Durst- oder Temperatursystem. Eine Niederlage führt zurück zum letzten Checkpoint.

**DESIGNEMPFEHLUNG:** Für den ersten Slice auf ein aktives Angriffssystem verzichten. Bedrohung entsteht durch Nähe, Verfolgung und begrenzten Handlungsspielraum. Ein gewöhnlicher Fehler sollte möglichst eine Chance zum Reagieren lassen; wiederholte Fehlentscheidungen können zur Niederlage führen.

Sollte später Abwehr ergänzt werden, ist eine kurze Gelegenheit zur Flucht ein passenderer erster Ansatz als das routinemäßige Besiegen aller Kreaturen.

**NOCH OFFEN:** Konkrete Schadensquellen, Trefferfolgen, Heilung, Regeneration und mögliche sofort tödliche Situationen. Es sind weder Waffen noch ein bestimmter Gesundheitswert beschlossen.

## 19. Inventar und Gegenstände

**FEST BESCHLOSSEN:** Es gibt ein kleines Inventar, eine Taschenlampe und einen Verbrauchsgegenstand beziehungsweise ein Getränk, das vorübergehend schnelleres Laufen ermöglicht. Weitere passende Gegenstände dürfen entwickelt werden. Sammeln unterstützt Erkunden und Vorankommen.

**DESIGNEMPFEHLUNG:**

| Gegenstandsart | Rolle im Spielerlebnis | Empfehlung für 0.1 |
| --- | --- | --- |
| Taschenlampe | Untersuchen und räumliche Orientierung | Verlässlich ein- und ausschaltbar; zunächst ohne Batterieverbrauch. |
| Tempo-Verbrauchsgegenstand | Vorübergehender Vorteil beim Entkommen | Sichtbar begrenzte Wirkung; eine Flucht bleibt auch ohne ihn lösbar. |
| Rätsel-/Zugangsgegenstand | Konkretes Hindernis überwinden | Nur aufnehmen lassen, wenn er eine verständliche Funktion im Abschnitt hat. |
| Story-Hinweis | Das Geheimnis verständlicher oder interessanter machen | Später erneut lesbar; blockiert keinen für Fortschritt nötigen Inventarplatz. |

Für das Inventar werden zunächst vier bis sechs direkt verständliche Plätze empfohlen. Unverzichtbare Gegenstände sollten keinen dauerhaft blockierten Spielstand verursachen. Inventarverwaltung soll keine umfangreiche Sortieraufgabe werden.

**NOCH OFFEN:** Exakte Platzanzahl, Stapeln, Wegwerfen, automatische Nutzung, Name und Darstellung des Getränks sowie Stärke, Dauer und Anzahl seiner Anwendungen. Auch Batterien und andere begrenzte Ressourcen sind nicht beschlossen.

## 20. Crafting

**FEST BESCHLOSSEN:** Crafting ist grundsätzlich interessant, Bauen dagegen praktisch unwichtig. Crafting wird als mögliches Gegenstands-/Werkzeugsystem verstanden, nicht als Basebuilding. Für 0.1 bleibt es klein und optional; eventuell werden nur einzelne Gegenstände kombiniert.

**DESIGNEMPFEHLUNG:** Falls die Kernversion bereits überzeugt, höchstens eine klar erklärte Kombination zweier Fundstücke prüfen, die ein einzelnes Problem löst. Kein Rezeptbaum und keine wiederholte Materialbeschaffung für denselben Fortschritt. Die beiden Pflichträtsel müssen zunächst auch ohne dieses optionale System konzipierbar sein.

**NOCH OFFEN:** Ob der Slice überhaupt Crafting erhält, welche Kombination sinnvoll wäre und wie sie bedient wird. Es werden noch keine Rezepte oder Materialien festgelegt.

## 21. Storytelling

**FEST BESCHLOSSEN:** Viel Story, mysteriöse Figuren und ein großes Geheimnis sind gewünscht. Das Spielziel verbindet Überleben mit dessen Aufdeckung. Die Erzählung kann über Umgebung, Hinweise, Gegenstände, Texte und Ereignisse erfolgen. Kreaturen dürfen sprechen, zunächst ohne Sprachausgabe. Der Slice endet nach einer ersten größeren Enthüllung mit einem Abschluss beziehungsweise Cliffhanger.

**DESIGNEMPFEHLUNG:** Für 0.1 drei Erzählebenen vorbereiten:

1. Ein unmittelbares Ziel erklärt, was der Junge im Abschnitt erreichen möchte.
2. Auffälligkeiten im Ort wecken eine zentrale Frage.
3. Die Enthüllung beantwortet einen Teil dieser Frage und verändert die Bedeutung zuvor gefundener Spuren.

Als mögliche eigene Richtung kann der Ort Spuren zeigen, als würde sich jemand auf die Ankunft des Jungen vorbereiten, obwohl alles verlassen wirkt. Ob dies auf menschliches Handeln, Täuschung oder etwas Unerklärliches zurückgeht, wäre gemeinsam zu entwickeln. Dieser Ansatz ist ausdrücklich kein festgelegter Plot.

Unverzichtbare Informationen sollten auf dem Hauptweg wahrnehmbar sein; optionale Funde vertiefen das Verständnis. Kurze Texte und räumliche Inszenierung tragen die Geschichte, ohne lange Lesepausen mitten in einer Verfolgung zu verlangen. Falls eine Kreatur spricht, können klar zugeordnete Texteinblendungen diese Äußerungen vermitteln.

**NOCH OFFEN:** Gesamthandlung, zentrales Geheimnis, Figuren, Motive, Grund des Betretens, konkrete Enthüllung, Cliffhanger und ob die erste Kreatur bereits spricht. Keine der genannten Erzählmöglichkeiten ersetzt die gemeinsame Entwicklung der Geschichte.

## 22. Progression

**FEST BESCHLOSSEN:** Kein klassisches XP-/Level-System und kein komplexes Skill-System als Startumfang. Fortschritt entsteht durch Wissen, Werkzeuge, neue Zugänge und neue Spielmechaniken. Belohnungen sind neue Werkzeuge, neue Gebiete und Story-Fortschritt.

**DESIGNEMPFEHLUNG:** Eine wesentliche Aufgabe sollte mindestens eine erkennbare Veränderung auslösen: Eine Tür öffnet sich, ein vertrauter Raum wird anders verstanden oder ein Werkzeug ermöglicht eine neue Handlung. Nicht jede Belohnung muss ein weiterer Gegenstand sein.

**NOCH OFFEN:** Reihenfolge späterer Werkzeuge, dauerhafter Besitz über Levelgrenzen und der Umfang optionaler Sammelziele. Der Slice benötigt noch keinen langfristigen Fortschrittsbaum.

## 23. Levelstruktur

**FEST BESCHLOSSEN:** Das Spiel besteht aus sorgfältig gestalteten Einzelabschnitten statt einer Open World. Erkunden, Sammeln und geheime Räume gehören zur Vision. Rennen beziehungsweise Zeit-Challenges können vorkommen.

**DESIGNEMPFEHLUNG:** Für 0.1 einen kurzen Waldzugang und einen zusammenhängenden Gebäudeteil mit klarer Hauptroute, einer überschaubaren Rückverbindung und einem optionalen Geheimraum planen. Eine Flucht kann teilweise durch zuvor erkundete Räume führen; dadurch zahlt sich Orientierung aus.

Der Geheimraum liefert eine zusätzliche Spur oder einen nützlichen, aber nicht zwingend notwendigen Fund. Die Hauptroute bleibt ohne ihn abschließbar. Der Geheimraum selbst ist eine Empfehlung für 0.1; geheime Räume im Gesamtspiel sind fest gewünscht.

**NOCH OFFEN:** Raumplan, Levelgröße, Übergänge, Anzahl späterer Level, konkrete Geheimzugänge und mögliche gesonderte Minigames oder Zeit-Challenges.

## 24. Grafikrichtung

**FEST BESCHLOSSEN:** Realistisch wirkende 3D-Grafik bleibt die Zielrichtung. Kein Pixel-Art-Stil und keine bewusst verpixelte Optik. Optik gehört neben Stimmung, Bewegung und Sound zu den wichtigsten Qualitätsmerkmalen. Farben und genaue Stimmungspalette sind noch nicht festgelegt.

**DESIGNEMPFEHLUNG:** Realismus zunächst über konsistente Größenverhältnisse, glaubwürdige Oberflächen, stimmige Gebrauchsspuren und zusammenpassende Raumgestaltung vermitteln. Ein kleiner, sorgfältig abgestimmter Abschnitt ist dafür geeigneter als viele unterschiedlich ausgearbeitete Bereiche.

**NOCH OFFEN:** Konkrete Farbpalette, Detailgrad, Aussehen der Hauptfigur und Kreatur sowie die Balance zwischen realistischer Wirkung und leicht erkennbaren Interaktionsobjekten. „Realistisch“ legt noch keine bestimmte Produktionsmethode oder technische Rendering-Lösung fest.

## 25. Beleuchtung

**FEST BESCHLOSSEN:** Licht unterstützt Spannung und Orientierung. Permanente extreme Dunkelheit ist ausgeschlossen. Eine Taschenlampe ist vorgesehen. Tag/Nacht bleibt ein Interesse, kein bereits definierter Ablauf.

**DESIGNEMPFEHLUNG:** Helle, gedämpfte und dunklere Bereiche bewusst abwechseln. Türen, Wege und wichtige Hindernisse bleiben im jeweiligen Spielkontext lesbar. Die Taschenlampe vertieft die Untersuchung und hilft in begrenzten dunklen Bereichen, statt überall die einzige Möglichkeit zu sein, überhaupt etwas zu sehen.

Für 0.1 eine bewusst festgelegte Tageszeit beziehungsweise Lichtstimmung empfehlen; ein dynamischer Tageszeitenwechsel ist für die kurze Spieldauer nicht erforderlich.

**NOCH OFFEN:** Tageszeit, Lichtfarben, Taschenlampenreichweite, Flackereffekte, mögliche Lichtreaktionen der Kreatur und eine spätere Tag/Nacht-Mechanik.

## 26. Audio und Musik

**FEST BESCHLOSSEN:** Atmosphärisches 3D-Audio gehört zu 0.1. Umgebungssound hat hohe Bedeutung. Besonders wichtig sind Kreaturengeräusche, Schritte, Türen, Umgebung sowie mechanische/industrielle Geräusche. Musik ist gruselig und darf sparsam eingesetzt werden. Zunächst keine Sprachausgabe.

**DESIGNEMPFEHLUNG:** Geräusche erfüllen unterscheidbare Aufgaben: Orientierung, erkennbare Reaktion auf eine Handlung, Warnung vor Gefahr oder Aufbau von Atmosphäre. Eigene Schritte vermitteln Untergrund und Bewegungsart. Wiedererkennbare Kreaturengeräusche helfen, ihre Nähe und ihr Verhalten einzuschätzen.

Musik sollte wichtige räumliche Hinweise nicht verdecken. Leise Abschnitte schaffen Kontrast. Ein Geräusch, das den Spieler vor einer konkreten Gefahr warnt, sollte verlässlich genug sein, um daraus Entscheidungen abzuleiten; nicht jedes atmosphärische Knacken muss dagegen eine Kreatur ankündigen.

**NOCH OFFEN:** Musikalische Motive, genaue Klangidentität, Lautstärkebalance und Umfang visueller Alternativen für wichtige akustische Hinweise.

## 27. Benutzeroberfläche

**FEST BESCHLOSSEN:** Die UI ist minimalistisch und soll möglichst wenig ablenken. Version 0.1 enthält ein Startmenü, „Neues Spiel“, ein kleines Inventar, einen Game-Over-Zustand und den Neustart am Checkpoint. Lebenspunkte und relevante Spielzustände müssen für das Erlebnis verständlich vermittelt werden; eine bestimmte Anzeigeform ist noch nicht festgelegt.

**DESIGNEMPFEHLUNG:** Im Spiel nur handlungsrelevante Informationen zeigen: kontextbezogene Interaktion, Hinweise auf Schaden, ausgewählter Gegenstand und verbleibende Wirkung des Tempo-Gegenstands. Lesbare Texte und konsistente Begriffe haben Vorrang vor dekorativen Effekten.

Ein Pausenmenü, eine kurze Speicherbestätigung und „Fortsetzen“ bei vorhandenem Spielstand sind sinnvolle Ergänzungen zum Bedienablauf. Sie sind Empfehlungen und kein stillschweigend erweiterter Pflichtumfang. Game Over sollte den nächsten Schritt eindeutig anbieten.

**NOCH OFFEN:** Konkretes HUD, Inventardarstellung, Textgröße, Zielanzeigen, Einstellungen sowie Untertitelgestaltung. Minimale UI bedeutet nicht, nötige Rückmeldungen ganz wegzulassen.

## 28. Steuerung

**FEST BESCHLOSSEN:** Version 0.1 verwendet Tastatur und Maus; Controller-Unterstützung folgt später. Die Steuerung soll leicht erlernbar sein. Die konkrete Kamera beziehungsweise Perspektive wird für 0.1 später entschieden; ein First-/Third-Person-Wechsel ist optional.

**DESIGNEMPFEHLUNG:** Zunächst eine Perspektive gut ausarbeiten. Als Diskussionsgrundlage eignet sich folgende Belegung:

| Handlung | Vorgeschlagene Eingabe |
| --- | --- |
| Bewegen / Umsehen | WASD / Maus |
| Sprinten / Springen | Umschalt / Leertaste |
| Ducken | Strg |
| Interagieren | E |
| Taschenlampe | F |
| Inventar | Tab |
| Tempo-Gegenstand benutzen | Q |
| Pause | Esc |

Grundlegendes Klettern kann dieselbe Sprung- oder Interaktionstaste nutzen, sofern die Situation eindeutig ist. Eine zweite Kameraperspektive sollte erst erwogen werden, wenn Bewegung, Rätsel und Verfolgung mit der ersten überzeugen.

**NOCH OFFEN:** Endgültige Belegung, Halten/Umschalten beim Sprinten und Ducken, Tastenänderung, Mausempfindlichkeit, Blickfeld und Kamerabewegung. Die Empfehlungen legen keine technische Eingabelösung fest.

## 29. Speichern und Checkpoints

**FEST BESCHLOSSEN:** Autosave / Checkpoints sowie zusätzlich manuelle Speicherpunkte sind vorgesehen; im ursprünglichen Fragebogen wurde „beides“ gewählt. Niederlagen führen zum letzten Checkpoint zurück. Version 0.1 enthält Checkpoints, manuelle Speicherpunkte, Game Over und den Neustart am Checkpoint. Manuelle Speicherpunkte bedeuten nicht automatisch freies Speichern an jeder Position.

**DESIGNEMPFEHLUNG:** Checkpoints und Autosave für 0.1 verbinden: Ein aktivierter Checkpoint sichert einen konsistenten Fortschrittsstand, der auch nach dem Beenden verfügbar bleibt. Nach einer Niederlage oder beim Fortsetzen werden Position, Inventar, Verbrauchsgegenstände, Rätsel- und Türzustände passend zu diesem Stand wiederhergestellt.

Checkpoints sollten nach wichtigen abgeschlossenen Aufgaben und vor anspruchsvollen Gefahrenabschnitten liegen. Der Wiederanlauf beginnt in einer kontrollierten Situation, nicht mitten in einer bereits verlorenen Verfolgung. Wird ein Tempo-Gegenstand erst nach dem Checkpoint verbraucht, stellt der Neustart dessen damaligen Bestand wieder her. So führt ein Fehlversuch nicht dauerhaft in eine unlösbare Lage.

**NOCH OFFEN:** Genaue Speicherorte, automatische Auslöser, gespeicherter Umfang, Rücksetzverhalten optionaler Funde, konkrete Anzahl der Spielstände und Bedienung der manuellen Speicherpunkte. Das genaue Zusammenspiel von Autosave, Checkpoints und manuellen Speicherpunkten ist vor der Umsetzung zu klären; das Vorhandensein beider Speicherarten steht fest.

## 30. Version 0.1 – Vertical Slice

### 30.1 Ziel und Umfang

**FEST BESCHLOSSEN:** Version 0.1 ist ein kleiner, atmosphärischer und präsentabler Vertical Slice: ein zusammenhängender Ausschnitt, der bereits erkennen lässt, warum Dark Rooms Spaß macht. Ziel sind etwa **15–25 Minuten spielbarer Inhalt**, nicht bloß ein Technikprototyp.

**DESIGNEMPFEHLUNG:** Die Dauer an einem ersten vollständigen Durchlauf messen, einschließlich normaler Orientierung, Lesen und Rätsellösen, aber ohne Startmenüzeit, lange Pausen und wiederholte Niederlagen. Ein geübter Wiederholungsdurchlauf darf kürzer sein. Die Zielzeit darf nicht durch unnötige Wege oder Wartezeiten erzwungen werden.

### 30.2 Vorgeschlagener Ablauf

**DESIGNEMPFEHLUNG:** Der folgende Ablauf konkretisiert den ausdrücklich vorgeschlagenen Aufbau aus dem Auftrag. Reihenfolge, Raumgestaltung und Zeitverteilung bleiben ein Vorschlag; die verpflichtenden Systeme und Inhalte stehen separat in 30.3.

| Abschnitt | Inhalt und Zweck | Richtzeit |
| --- | --- | --- |
| Startmenü | „Neues Spiel“ führt verständlich in den Slice. | Nicht Teil der Spielzeit |
| Waldzugang | Einstieg, unmittelbares Ziel, erste Bewegungen und akustische Beunruhigung. | 2–3 Minuten |
| Gebäude erkunden und Rätsel 1 | Orientierung, Taschenlampe, Interaktion, Sammeln und ein einfaches Hindernis. | 4–6 Minuten |
| Spuren und erste Kreaturenbegegnung | Story-Hinweise verdichten sich; aus vermuteter wird erkennbare Gefahr. | 2–4 Minuten |
| Flucht / Verfolgung | Gelerntes Bewegen anwenden; Tempo-Gegenstand kann helfen. | 2–4 Minuten |
| Rätsel 2 und Enthüllung | Ruhe zum Denken, andere Rätselanforderung und erste größere Erkenntnis. | 4–6 Minuten |
| Abschluss / Cliffhanger | Die Erkenntnis öffnet eine neue Frage; das Ende ist klar erkennbar. | Etwa 1 Minute |

Die Richtzeiten ergeben zusammen 15–24 Minuten und lassen innerhalb des Zielrahmens etwas Spielraum. Eine optionale Abzweigung muss bei der späteren Zeitprüfung mitbedacht werden.

### 30.3 Verbindlicher Kernumfang und prüfbares Ergebnis

**FEST BESCHLOSSEN:** Die folgenden Inhalte gehören zum gewünschten Kernumfang von 0.1. Die Ergebnisbeschreibung konkretisiert jeweils die bereits verlangte Funktion, ohne offene Zahlenwerte, Designs oder technische Lösungen festzulegen.

| Bereich | Kernumfang | Woran die Funktion erkennbar ist |
| --- | --- | --- |
| Einstieg | Startmenü, Neues Spiel | Der Spieler kann einen neuen Durchlauf beginnen. |
| Steuerung und Kamera | Spielerbewegung, Kamera, Sprinten, Springen, Ducken, grundlegendes Klettern/Parkour | Die geforderten Bewegungen sind im Abschnitt nutzbar und unterstützen das Vorankommen. |
| Interaktion | Interaktionssystem, Türen, Schalter, Gegenstände aufnehmen | Handlungen verändern nachvollziehbar den Raum oder den Besitz des Spielers. |
| Ausrüstung | Taschenlampe, kleines Inventar, Tempo-Verbrauchsgegenstand | Die Taschenlampe ist nutzbar, Gegenstände werden verwaltet, der Verbrauchsgegenstand erhöht das Lauftempo zeitlich begrenzt. |
| Survival und Wiederanlauf | Lebenspunkte, Checkpoints, Game Over, Neustart am Checkpoint | Niederlage und Rückkehr zum letzten Checkpoint funktionieren im vollständigen Durchlauf. |
| Speichern | Autosave / Checkpoints und zusätzlich manuelle Speicherpunkte | Fortschritt wird automatisch und zusätzlich auf Initiative des Spielers an manuellen Speicherpunkten gesichert; genaue Speicherorte, Anzahl der Spielstände, Bedienung, Auslöser und Umfang sind nach Abschnitt 29 noch zu klären. Freies Speichern an jeder Position ist damit nicht beschlossen. |
| Rätsel | Zwei unterschiedliche Rätsel | Beide lassen sich im Slice lösen und sind nicht bloß identische Wiederholungen. |
| Story | Story-Hinweise, erste größere Enthüllung, Abschluss/Cliffhanger | Hinweise führen zu einem erzählerischen Fortschritt und einem erkennbaren Ende. |
| Gegner | Eine Kreatur / ein Gegnertyp | Patrouille, Sicht- und Geräuscherkennung, Verfolgung sowie Suche nach verlorenem Spieler werden im Spiel wirksam. |
| Präsentation | Atmosphärisches 3D-Audio, minimale UI, kurzer hochwertiger Levelabschnitt | Raum, Sound, Bedienung und Optik bilden einen zusammenhängenden spielbaren Ausschnitt. |

### 30.4 Optionaler Umfang

**FEST BESCHLOSSEN:** Einfaches Verstecken, eine sehr kleine Crafting-/Kombinationsmechanik und First-/Third-Person-Wechsel sind ausschließlich optional für 0.1, wenn sie ohne starke Mehraufwände sinnvoll sind.

**DESIGNEMPFEHLUNG:** Optionale Systeme erst aufnehmen, wenn der Kern vom Spielstart bis zum Abschluss funktioniert und atmosphärisch trägt. Sichtkontakt durch Raumgeometrie zu unterbrechen kann auch ohne ein eigenes Verstecksystem Teil der Flucht sein; daraus folgt noch keine Mechanik für Schränke oder andere feste Verstecke.

### 30.5 Bewusst ausgeschlossener Pflichtumfang

**FEST BESCHLOSSEN:** Für 0.1 sind Multiplayer, große Open World, umfangreiches Kampfsystem, viele Gegnerarten, umfangreiches Crafting, Basebuilding, XP-/Level-System, Sprachausgabe, dutzende Waffen und komplexes Skill-System nicht notwendig. Ein Teil davon widerspricht auch der bisherigen Gesamtvision; Abschnitt 31 unterscheidet dies ausdrücklich.

**DESIGNEMPFEHLUNG:** Schwimmen, Rutschen, umfangreiches Greifen/Ziehen, dynamisches Tag/Nacht sowie eigenständige Minigames und Zeit-Challenge-Modi zunächst außerhalb des Slice halten. Ihre Erwähnung in der Gesamtvision verpflichtet nicht zu ihrer Umsetzung in 0.1.

## 31. Inhalte, die bewusst später kommen

**FEST BESCHLOSSEN:** „Später“ ist kein Freibrief, alle denkbaren Funktionen zu ergänzen. Der bisherige Umfang lässt sich wie folgt abgrenzen:

| Einordnung | Inhalte | Konsequenz |
| --- | --- | --- |
| Ausdrücklich später vorgesehen | Controller-Unterstützung | Nach Tastatur und Maus ergänzen; Zeitpunkt offen. |
| Gesamtvision, nicht vollständiger 0.1-Kern | Schwimmen, Rutschen, Greifen/Ziehen und weitergehender Parkour | Umfang und sinnvoller Einsatz später konkretisieren. |
| Interessant oder zulässig, nicht zugesagt | Begrenzte Abwehr/Kampf, Tag/Nacht, Zeit-Challenges, Minigames | Erst nach fachlicher Auswahl Teil eines geplanten Umfangs. |
| Optional im Slice, sonst erneut zu prüfen | Einfaches Verstecken, kleine Kombinationen, Perspektivwechsel | Weglassen gefährdet nicht die Vollständigkeit des 0.1-Kerns. |
| Für 0.1 nicht notwendig, auch später nicht zugesagt | Multiplayer, viele Gegnerarten, umfangreicher Kampf, umfangreiches Crafting, Sprachausgabe, viele Waffen, komplexes Skill-System | Keine verdeckte Zusage für spätere Versionen. |
| Nicht Teil der beschlossenen Grundrichtung | Große Open World, klassisches Basebuilding, klassisches XP-/Level-System | Würden eine ausdrückliche Änderung der Spielvision erfordern. |

## 32. Offene Designentscheidungen

**NOCH OFFEN:** Die folgende Liste bündelt Entscheidungen für gemeinsame Gespräche. Sie enthält keine bereits ausgewählten Antworten. „Vor“ bezeichnet die fachliche Abhängigkeit, keinen Entwicklungszeitplan.

| ID | Entscheidung | Wann die Antwort gebraucht wird |
| --- | --- | --- |
| O-01 | Alterszielgruppe, inhaltliche Grenzen, Gewalt- und Niederlagendarstellung | Vor konkreter Horror- und Kreaturenausarbeitung |
| O-02 | Zielbetriebssysteme und Referenzhardware | Vor belastbaren Leistungs- und Präsentationszielen |
| O-03 | Perspektive für 0.1 und gewünschtes Kameragefühl | Vor verbindlicher Ausarbeitung von Bewegung und Räumen |
| O-04 | Name, Alter, Aussehen, Motivation und Vorgeschichte des Jungen | Vor verbindlichen Story- und Figurenentwürfen |
| O-05 | Konkreter Ort, Weltregeln, Epoche und Beziehung zwischen Wald und Gebäude | Vor endgültigem Level- und Storyentwurf |
| O-06 | Zentrales Geheimnis, Figuren, Enthüllung und Cliffhanger | Vor Ausarbeitung der Story-Hinweise |
| O-07 | Kreaturengestalt, Verhalten im Detail, Sprechrolle und Schadenswirkung | Vor endgültiger Gestaltung der ersten Begegnung |
| O-08 | Bewegungstempo, Sprung-/Klettergrenzen, Ausdauer, Fallfolgen und Geräuschregeln | Vor verlässlicher Planung von Wegen und Verfolgung |
| O-09 | Auswahl und genaue Regeln der beiden Rätsel sowie mögliche Hilfen | Vor Festlegung der dazugehörigen Räume und Gegenstände |
| O-10 | Gesundheit, Heilung, Trefferfolgen und tödliche Situationen | Vor Abstimmung von Gefahr und Wiederanlauf |
| O-11 | Inventargröße und -bedienung, benötigte Gegenstände, Taschenlampenressourcen | Vor verbindlichen Sammel- und Zugangsregeln |
| O-12 | Form, Name, Dauer, Stärke und Verfügbarkeit des Tempo-Gegenstands | Vor Abstimmung der Fluchtsequenz |
| O-13 | Genaue Speicherorte, Anzahl der Spielstände, Bedienung manueller Speicherpunkte, Autosave-Auslöser, gespeicherter Umfang, Rücksetzregeln und Zusammenspiel der fest beschlossenen Speicherarten | Vor verbindlicher Ausgestaltung des Speicher- und Niederlagenablaufs |
| O-14 | Verstecken, Kombinationen und Perspektivwechsel tatsächlich in 0.1? | Erst nach Prüfung von Nutzen und Aufwand für den Kern |
| O-15 | Levelplan, Geheimraum im Slice und Übernahme des empfohlenen Ablaufs | Vor verbindlicher Ausarbeitung des Abschnitts |
| O-16 | Tageszeit, Farbpalette, konkrete Licht- und Klanggestaltung | Vor detaillierter Präsentationsgestaltung |
| O-17 | HUD, Textdarstellung, Pausen-/Fortsetzen-Ablauf, Belegung und Zugänglichkeit | Vor verbindlichen Bedienabläufen |
| O-18 | Spätere Kampf-/Abwehrmöglichkeiten, Tag/Nacht und Challenges | Wenn eine spätere Version diese Themen tatsächlich aufgreift |

**DESIGNEMPFEHLUNG:** Entscheidungen zunächst dort treffen, wo sie viele andere Fragen beeinflussen: Zielgruppe, Hauptfigur und Geheimnis, Perspektive, Ort und die beiden Rätsel. Anschließend konkrete Kreaturenregeln, Bewegung, Gegenstände und Wiederanlauf darauf abstimmen. Das ist eine fachliche Gesprächsreihenfolge, keine technische Architektur.

## 33. Risiken für den Spielspaß

**DESIGNEMPFEHLUNG:** Diese Risiken bei Entwürfen und späteren Spieltests beobachten. Die Gegenmaßnahmen sind Vorschläge, keine zusätzliche Pflichtliste neuer Systeme.

| Risiko oder Designspannung | Erkennbares Problem | Empfohlene Gegenmaßnahme |
| --- | --- | --- |
| Hohes Kampfinteresse, aber Flucht als Schwerpunkt | Die Figur fühlt sich nur hilflos an oder Erwartungen an Action bleiben unerfüllt. | Aktive Ausweich- und Bewegungsentscheidungen anbieten; Interesse an späterer begrenzter Abwehr getrennt prüfen. |
| Hohes Craftinginteresse, kaum Interesse am Bauen | Materialsuche verdrängt Rätsel und Story. | Wenige bedeutungsvolle Kombinationen statt Sammelschleifen und Bauwirtschaft. |
| Sehr hoher Grusel bei gutem Bewegungsfluss | Zu häufige Unterbrechungen oder Kontrollverlust machen Fluchten ärgerlich. | Bedrohung steigern, ohne verlässliche Eingaben und erkennbare Wege aufzugeben. |
| Dunkelheit statt Atmosphäre | Der Spieler übersieht Türen und hält das Spiel für unfair. | Sichtbare Orientierungspunkte und gezielte dunkle Bereiche prüfen. |
| Ständiger Alarm | Überraschungen verlieren ihre Wirkung; Erkunden wird unmöglich. | Bedrohung und ruhigere Phasen bewusst abwechseln. |
| Unverständliche KI | Die Kreatur scheint alles zu wissen oder verliert den Spieler beliebig. | Sicht-, Geräusch- und Suchreaktionen durch wahrnehmbare Signale erklären. |
| Gleichartige oder unklare Rätsel | Der Spieler probiert wahllos oder erlebt Wiederholung. | Unterschiedliche Denkleistungen und klare Rückmeldungen testen. |
| Verlust kritischer Ressourcen | Ein verbrauchtes Getränk oder voller Rucksack blockiert den Durchlauf. | Pfad ohne Tempo-Bonus lösbar halten und notwendige Gegenstände absichern. |
| Zu viel Inhalt für 15–25 Minuten | Jedes System wird nur kurz gezeigt; Stimmung und Geschichte erhalten keinen Raum. | Den Kern in wenigen Räumen verbinden und optionale Systeme verschieben. |
| Realistische Optik mit zu großer Fläche | Uneinheitliche Gestaltung oder stockende Darstellung zerstört die Wirkung. | Kleinen Abschnitt sorgfältig ausarbeiten und auf gewählter Referenzhardware prüfen. |
| Viel Story bei hohem Tempo | Hinweise werden übersehen oder unter Gefahr weggeklickt. | Informationen auf mehrere kurze, passend platzierte Begegnungen verteilen. |
| Nähe zu Inspirationsquellen | Der Ort oder die Kreatur wirkt wie eine Kopie. | Eigene Funktion, Geschichte, Formensprache und Geräusche gemeinsam begründen. |

## 34. Qualitätsziele

**FEST BESCHLOSSEN:** Besonders hochwertig sollen Optik, Stimmung, Bewegung und Sound wirken. Der Slice muss die Kernfunktionen aus Abschnitt 30 enthalten und ein zusammenhängendes Erlebnis von ungefähr 15–25 Minuten bieten.

**DESIGNEMPFEHLUNG:** Die folgenden Prüfungen machen Qualität im gemeinsamen Spielen besprechbar. Sie ersetzen keine noch offenen Entscheidungen durch vermeintlich fertige Messwerte.

| Ziel | Praktische Prüfung |
| --- | --- |
| Leicht erlernbare Bewegung | Eine neue Testperson bewältigt nach kurzer Einführung einen sicheren Weg und später dieselbe Bewegungsaufgabe unter Druck. |
| Verlässliches Parkour | Klar erkennbare, gleich gestaltete Hindernisse erlauben dieselbe Handlung; Fehlversuche sind erklärbar. |
| Spannung ohne Sichtverlust | Die Testperson beschreibt unheimliche Momente und findet zugleich notwendige Wege und Bedienelemente. |
| Verständliche Rätsel | Beide Rätsel sind ohne Zuruf der Entwickler lösbar; die Testperson kann ihre Schlussfolgerung anschließend erklären. |
| Nachvollziehbare Gefahr | Nach Entdeckung oder Niederlage kann die Testperson mindestens einen plausiblen Auslöser und eine mögliche Gegenmaßnahme benennen. |
| Nutzbarer Raumklang | Relevante Kreaturen- und Umgebungsgeräusche lassen sich im vorgesehenen Hörsetup räumlich einordnen und werden nicht von Musik verdeckt. |
| Wirksame Geschichte | Nach dem Abschluss kann die Testperson die zentrale Erkenntnis und die verbleibende Frage wiedergeben. |
| Begrenzter Frust | Nach einer Niederlage werden nicht wiederholt lange, bereits gelöste Abschnitte erzwungen. |
| Konsistenter Speicherstand | Ein Neustart beziehungsweise Fortsetzen liefert zusammenpassende Position, Gegenstände, Türen und Rätselzustände. |
| Durchgängige Spielbarkeit | Der Slice lässt sich auch nach Fehlversuchen und Verbrauch optionaler Hilfen beenden. |
| Passende Dauer | Ein erster normaler Durchlauf liegt ungefähr im Zielrahmen; Abweichungen werden auf Orientierung, Rätsel oder Wege zurückgeführt. |
| Präsentabler Eindruck | Pflichtwege, Kreatur, Licht, Sound und UI bilden einen stimmigen Abschnitt ohne störende sichtbare Platzhalter. |

**NOCH OFFEN:** Verbindliche Leistungsziele, Referenzgerät, Testgruppe, konkrete Zugänglichkeitsziele und finale Abnahmekriterien. Diese werden nach den vorgelagerten Designentscheidungen festgelegt.

## 35. Definition: „Wann fühlt sich Dark Rooms wie Dark Rooms an?“

**DESIGNEMPFEHLUNG:** Dark Rooms trifft seine angestrebte Identität, wenn ein Durchlauf diese Erfahrungen miteinander verbindet:

- Ich möchte einen Ort erkunden, obwohl seine Geräusche und Spuren mich verunsichern.
- Ich kann sehen, wohin ich gehe, und weiß trotzdem nicht sicher, was mich erwartet.
- Ein Hinweis verändert mein Verständnis und hilft mir, eine eigene Schlussfolgerung zu ziehen.
- Eine gelungene Bewegung oder Rätsellösung öffnet einen Weg, den ich vorher nicht nutzen konnte.
- Die Kreatur wirkt bedrohlich; durch Beobachten, Denken und Bewegen kann ich mein Überleben beeinflussen.
- Eine Enthüllung beantwortet etwas und macht mich zugleich neugierig auf das größere Geheimnis.

Eine überzeugende Grafik allein erfüllt diese Definition ebenso wenig wie eine einzelne gelungene Verfolgung. Die vorgeschlagene Prüffrage lautet: „Ergeben Atmosphäre, Story, Rätsel und Bewegung zusammen ein Erlebnis, dessen Fortsetzung wir sehen möchten?“

## 36. Änderungsverlauf / Dokumenthistorie

| Datum | Dokumentversion | Änderung | Entscheidungsstatus |
| --- | --- | --- | --- |
| 19.09.2026 | 0.1 | Erstfassung des Game Design Documents für Dark Rooms auf Basis des gemeinsamen Fragebogens; Gesamtvision, Slice-Umfang, Designspannungen, Empfehlungen, offene Fragen und Qualitätsziele ausgearbeitet. | Vorgaben als FEST BESCHLOSSEN übernommen; eigene Ergänzungen als DESIGNEMPFEHLUNG und ungeklärte Details als NOCH OFFEN gekennzeichnet. |

**DESIGNEMPFEHLUNG:** Bei künftigen Änderungen kurz festhalten, welche Vorgabe geändert oder welche Empfehlung ausdrücklich angenommen wurde und auf welcher gemeinsamen Entscheidung dies beruht. Bis dahin bleiben die Kennzeichnungen dieser Erstfassung maßgeblich.
