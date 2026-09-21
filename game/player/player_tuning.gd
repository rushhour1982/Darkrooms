class_name PlayerTuning
extends Resource
## Statische Bewegungs-/Kamerakonfiguration des Players (Architektur §23, TDD §21).
##
## Alle Werte sind VORLÄUFIGE TUNINGWERTE aus dem E03-Prototyp-Profil
## (Project Lead, 20.09.2026) und werden nach dem ersten Junior-Playtest
## angepasst. Maße in Metern, Zeiten in Sekunden, Winkel in Grad.
## Die Resource wird während eines Laufs als unveränderlich behandelt;
## Laufzustand (Geschwindigkeit, Blickwinkel) gehört zur Player-Instanz.

@export_group("Körper")
## Gesamthöhe der Kollisionskapsel.
@export_range(1.0, 2.5, 0.01, "suffix:m") var body_height: float = 1.8
## Radius der Kollisionskapsel (vorläufig; nicht im E03-Profil genannt).
@export_range(0.1, 1.0, 0.01, "suffix:m") var body_radius: float = 0.35
## Höhe der Kamera über den Füßen.
@export_range(0.5, 2.5, 0.01, "suffix:m") var eye_height: float = 1.65

@export_group("Ducken")
## Kapselhöhe in geduckter Haltung.
@export_range(0.5, 2.5, 0.01, "suffix:m") var crouch_body_height: float = 1.2
## Kamerahöhe über den Füßen in geduckter Haltung.
@export_range(0.3, 2.5, 0.01, "suffix:m") var crouch_eye_height: float = 1.05
@export_range(0.1, 20.0, 0.1, "suffix:m/s") var crouch_speed: float = 2.5
## Dauer des weichen Kameraübergangs zwischen Stehen und Ducken (vorläufig,
## nicht im E03-Nachtrag beziffert). Die Kollisionsform wechselt sofort.
@export_range(0.0, 1.0, 0.01, "suffix:s") var posture_transition_time: float = 0.15
## Zusätzlicher Freiraum, den die Aufstehprüfung über der stehenden Kapsel
## und unter den Füßen verlangt (vorläufig, nicht im E03-Nachtrag beziffert).
@export_range(0.0, 0.3, 0.01, "suffix:m") var stand_clearance_margin: float = 0.05

@export_group("Bewegung")
@export_range(0.1, 20.0, 0.1, "suffix:m/s") var walk_speed: float = 5.0
@export_range(0.1, 30.0, 0.1, "suffix:m/s") var sprint_speed: float = 8.0
@export_range(0.1, 100.0, 0.1, "suffix:m/s²") var ground_acceleration: float = 20.0
@export_range(0.1, 100.0, 0.1, "suffix:m/s²") var ground_deceleration: float = 24.0
## Anteil der Bodenbeschleunigung, der in der Luft wirkt (reduzierte
## Luftsteuerung; konkreter Faktor vorläufig, nicht im E03-Profil beziffert).
@export_range(0.0, 1.0, 0.05) var air_control: float = 0.3

@export_group("Sprung und Schwerkraft")
@export_range(0.1, 50.0, 0.1, "suffix:m/s²") var gravity: float = 9.8
## Angestrebte Sprunghöhe; die Absprunggeschwindigkeit wird daraus abgeleitet.
@export_range(0.0, 5.0, 0.01, "suffix:m") var jump_height: float = 1.25

@export_group("Traversal")
## Maximale Höhe eines Hindernisses, das über eine erlaubte Passage überwunden wird.
@export_range(0.1, 3.0, 0.01, "suffix:m") var traversal_max_height: float = 0.9
## Maximale horizontale Entfernung zum Eintrittspunkt der Passage.
@export_range(0.1, 5.0, 0.01, "suffix:m") var traversal_detect_range: float = 1.1
## Tempo der kontrollierten Kletterbewegung (vorläufig, nicht im E03-Nachtrag beziffert).
@export_range(0.1, 20.0, 0.1, "suffix:m/s") var traversal_speed: float = 3.0
## Maximaler Winkel zwischen Bewegungsabsicht und Passagerichtung (vorläufig).
@export_range(1.0, 90.0, 1.0, "suffix:°") var traversal_max_angle: float = 45.0
## Abstand, um den der Körper über die Zielhöhe gehoben wird, bevor er
## waagerecht zum Ziel fährt; die Schwerkraft setzt ihn danach ab (vorläufig).
@export_range(0.0, 0.3, 0.01, "suffix:m") var traversal_lift_margin: float = 0.05

@export_group("Schritte und Landung")
## Zurückgelegte horizontale Bodenstrecke pro Schritt je Kontext (E03-Nachtrag Schritte).
@export_range(0.05, 3.0, 0.01, "suffix:m") var footstep_distance_walk: float = 0.7
@export_range(0.05, 3.0, 0.01, "suffix:m") var footstep_distance_sprint: float = 0.9
@export_range(0.05, 3.0, 0.01, "suffix:m") var footstep_distance_crouch: float = 0.5
## Lautstärkeversatz gegenüber der Gehreferenz.
@export_range(-24.0, 24.0, 0.5, "suffix:dB") var footstep_sprint_db: float = 2.0
@export_range(-24.0, 24.0, 0.5, "suffix:dB") var footstep_crouch_db: float = -4.0
## Zufällige Tonhöhenvariation pro Schritt (Anteil, 0,03 = ±3 %).
@export_range(0.0, 0.5, 0.005) var footstep_pitch_variation: float = 0.03
## Fallgeschwindigkeit, ab der eine Landung einen Testimpuls auslöst
## (vorläufig gewählt: ≈ 0,32 m Fallhöhe; kleine Bodenunebenheiten liegen darunter,
## der Abstieg von der 0,5-m-Testplattform darüber).
@export_range(0.1, 30.0, 0.1, "suffix:m/s") var landing_min_fall_speed: float = 2.5
## Landungsimpuls: Lautstärkeversatz und Tonhöhe relativ zum Schritt (vorläufig).
@export_range(-24.0, 24.0, 0.5, "suffix:dB") var landing_db: float = 3.0
@export_range(0.1, 2.0, 0.05) var landing_pitch_scale: float = 0.6

@export_group("Kamera")
@export_range(1.0, 179.0, 0.5, "suffix:°") var fov: float = 75.0
## Blickdrehung pro Mauspixel; bewusst nicht mit der Bildrate skaliert.
@export_range(0.001, 1.0, 0.001, "suffix:°/px") var mouse_sensitivity: float = 0.10
@export_range(-89.0, 0.0, 0.5, "suffix:°") var pitch_min: float = -85.0
@export_range(0.0, 89.0, 0.5, "suffix:°") var pitch_max: float = 85.0


## Absprunggeschwindigkeit für die konfigurierte Sprunghöhe: v = sqrt(2·g·h).
func get_jump_velocity() -> float:
	return sqrt(2.0 * gravity * jump_height)


## Meldet ungültige Wertebereiche beim Aufbau (Architektur §23) und gibt
## false zurück, wenn der Player damit nicht sicher betrieben werden kann.
func validate(context: String) -> bool:
	var problems: PackedStringArray = []
	if body_height <= 2.0 * body_radius:
		problems.append("body_height muss größer als 2 × body_radius sein")
	if eye_height <= 0.0 or eye_height >= body_height:
		problems.append("eye_height muss zwischen 0 und body_height liegen")
	if crouch_body_height <= 2.0 * body_radius or crouch_body_height >= body_height:
		problems.append("crouch_body_height muss zwischen 2 × body_radius und body_height liegen")
	if crouch_eye_height <= 0.0 or crouch_eye_height >= crouch_body_height:
		problems.append("crouch_eye_height muss zwischen 0 und crouch_body_height liegen")
	if walk_speed <= 0.0 or ground_acceleration <= 0.0 or ground_deceleration <= 0.0:
		problems.append("walk_speed, ground_acceleration und ground_deceleration müssen positiv sein")
	if sprint_speed < walk_speed or crouch_speed <= 0.0 or crouch_speed > walk_speed:
		problems.append("es muss gelten: 0 < crouch_speed ≤ walk_speed ≤ sprint_speed")
	if posture_transition_time < 0.0 or stand_clearance_margin < 0.0:
		problems.append("posture_transition_time und stand_clearance_margin dürfen nicht negativ sein")
	if traversal_max_height <= 0.0 or traversal_detect_range <= 0.0 or traversal_speed <= 0.0:
		problems.append("traversal_max_height, traversal_detect_range und traversal_speed müssen positiv sein")
	if traversal_max_angle <= 0.0 or traversal_max_angle > 90.0 or traversal_lift_margin < 0.0:
		problems.append("traversal_max_angle muss in (0, 90] liegen und traversal_lift_margin nicht negativ sein")
	if footstep_distance_walk <= 0.0 or footstep_distance_sprint <= 0.0 or footstep_distance_crouch <= 0.0:
		problems.append("footstep_distance_* müssen positiv sein")
	if footstep_pitch_variation < 0.0 or footstep_pitch_variation >= 1.0:
		problems.append("footstep_pitch_variation muss in [0, 1) liegen")
	if landing_min_fall_speed <= 0.0 or landing_pitch_scale <= 0.0:
		problems.append("landing_min_fall_speed und landing_pitch_scale müssen positiv sein")
	if air_control < 0.0 or air_control > 1.0:
		problems.append("air_control muss zwischen 0 und 1 liegen")
	if gravity <= 0.0 or jump_height < 0.0:
		problems.append("gravity muss positiv und jump_height nicht negativ sein")
	if fov <= 0.0 or fov >= 180.0:
		problems.append("fov muss zwischen 0 und 180 liegen")
	if mouse_sensitivity <= 0.0:
		problems.append("mouse_sensitivity muss positiv sein")
	if pitch_min >= pitch_max or pitch_min < -90.0 or pitch_max > 90.0:
		problems.append("pitch_min/pitch_max müssen geordnet und innerhalb ±90° liegen")
	for problem in problems:
		push_error("%s: PlayerTuning ungültig – %s." % [context, problem])
	return problems.is_empty()
