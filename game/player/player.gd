extends CharacterBody3D
## Player – First-Person-Motor und Blicksteuerung (Architektur §7, §8, §25).
##
## Dieses Script ist der einzige Schreiber der Spielerposition. Bewegung und
## Kollisionsantwort laufen im Physiktakt über move_and_slide(); der Körper
## dreht horizontal (Yaw), Head vertikal (Pitch), die Kamera bleibt Kind von
## Head. Alle Zahlen kommen aus PlayerTuning; keine Tastencodes, nur Actions.
##
## Ausbaustufe P1-04: WASD, Mausblick, Gravity, Sprung, Bodenkollision,
## Sprint (Halten), Ducken (Halten) mit sicherem Aufstehen, markerbasiertes
## Traversal sowie Testschritte/Landungsimpuls aus zurückgelegter Bodenstrecke
## über eine lokale Audioquelle (E12a-Testton, temporär). Haltung
## (STANDING/CROUCHED) ist eine eigene Achse neben der Fortbewegung (am
## Boden / in der Luft über is_on_floor() / TRAVERSING über _traversal_active);
## keine Zustandsmaschine. Traversal: ein TraversalMarker
## bietet eine erlaubte Passage an, der Player prüft Reichweite, Höhe,
## Richtung und Körperfreiheit entlang des Weges und fährt ihn kollisions-
## geprüft über move_and_collide() – kein Tween, kein Teleport.
## P2-01: Der Interactor (Kind „Interactor“, player_interactor.gd) erkennt
## Interaktionsziele aus der Kamera und fordert Interaktionen an; der Player
## reicht ihm nur die Gameplayfreigabe weiter.
## Licht, Health und echtes Sounddesign folgen mit ihren Tasks.
## Gameplayfreigabe kommt ausschließlich vom Level über set_gameplay_active().

enum Posture { STANDING, CROUCHED }

const ACTION_FORWARD: StringName = &"move_forward"
const ACTION_BACKWARD: StringName = &"move_backward"
const ACTION_LEFT: StringName = &"move_left"
const ACTION_RIGHT: StringName = &"move_right"
const ACTION_JUMP: StringName = &"jump"
const ACTION_SPRINT: StringName = &"sprint"
const ACTION_CROUCH: StringName = &"crouch"

## Frames nach einer Freigabe, in denen Mausbewegung verworfen wird, damit
## ein alter Mausimpuls beim Wiederfangen keinen Kamerasprung auslöst.
const LOOK_SUPPRESS_FRAMES: int = 2

## Vorläufige Bewegungs-/Kamerawerte (E03-Prototyp-Profil und -Nachtrag).
@export var tuning: PlayerTuning

@onready var _body_shape: CollisionShape3D = $BodyShape
@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _footsteps: AudioStreamPlayer3D = $Footsteps
@onready var _interactor: PlayerInteractor = $Interactor

var _gameplay_active: bool = false
## Vertikaler Blickwinkel in Radiant; Laufzustand, nicht Konfiguration.
var _pitch: float = 0.0
var _look_suppress_frames: int = 0
## Haltungsachse; die Kollisionsform folgt ihr sofort, die Kamera weich.
var _posture: Posture = Posture.STANDING
## Aktuelle Kamerahöhe (weicher Übergang zwischen den Augenhöhen).
var _eye_height_current: float = 0.0
## Query-Kapsel für die Aufstehprüfung; nur für Physikabfragen, nie im Baum.
var _stand_query_shape: CapsuleShape3D = CapsuleShape3D.new()
## Aktuell angebotene Passage (vom TraversalMarker beim Betreten gesetzt).
var _offered_marker: Area3D = null
## Laufender Traversalvorgang: Wegpunkte in Weltkoordinaten und Fortschritt.
var _traversal_active: bool = false
var _traversal_path: PackedVector3Array = PackedVector3Array()
var _traversal_index: int = 0
## Schritt-/Landungsdiagnose (P1-04): Schritte entstehen aus tatsächlich
## zurückgelegter Bodenstrecke, nicht aus gedrückten Tasten. Die Audioausgabe
## besitzt keinen Bewegungszustand; sie wird nur ausgelöst.
var _step_accumulator: float = 0.0
var _last_ground_position: Vector3 = Vector3.ZERO
var _was_on_floor: bool = false
var _peak_fall_speed: float = 0.0
var _footstep_count: int = 0
var _landing_count: int = 0
var _last_footstep_context: String = ""
var _last_footstep_db: float = 0.0
var _last_footstep_pitch: float = 1.0
## Aufprallgeschwindigkeit der letzten Landung (auch unterhalb der Schwelle).
var _last_impact_speed: float = 0.0


func _ready() -> void:
	_apply_tuning()
	reset_motion_state()


## Vom Level beim Weltaufbau aufgerufen: Konfiguration prüfen und anwenden,
## Bewegungs-/Kamerahistorie zurücksetzen. false sperrt den Weltaufbau.
func prepare() -> bool:
	if tuning == null:
		push_error("%s: Kein PlayerTuning zugewiesen." % name)
		return false
	if not tuning.validate(name):
		return false
	_apply_tuning()
	reset_motion_state()
	return true


## Einziger Freigabeauftrag (vom Level weitergereicht). Sperren unterbricht die
## Verarbeitung, setzt aber keinen Bewegungszustand zurück (Pause friert ein).
## Beim Freigeben wird der eingefrorene Horizontalimpuls verworfen: Nach dem
## Fortsetzen entsteht Bewegung erst wieder aus neuer Eingabe (kein Nachlauf).
## Vertikale Geschwindigkeit (Sprung/Fall), Haltung und ein laufendes
## Traversal bleiben erhalten und werden konsistent fortgesetzt.
func set_gameplay_active(active: bool) -> void:
	_gameplay_active = active
	if active:
		_look_suppress_frames = LOOK_SUPPRESS_FRAMES
		velocity.x = 0.0
		velocity.z = 0.0
		# Nach Freigabe (Start, Fortsetzen) beginnt die Schrittstrecke neu:
		# kein nachgeholter Schritt oder Landungsimpuls aus der Zeit davor.
		_reset_footstep_tracking()
	_interactor.set_gameplay_active(active)


func is_gameplay_active() -> bool:
	return _gameplay_active


## Setzt Geschwindigkeit, Haltung und Blickhistorie zurück; Yaw bleibt die
## Spawnausrichtung. Der Spawn erfolgt stehend.
func reset_motion_state() -> void:
	velocity = Vector3.ZERO
	_pitch = 0.0
	_head.rotation = Vector3.ZERO
	_look_suppress_frames = LOOK_SUPPRESS_FRAMES
	_set_posture(Posture.STANDING)
	_eye_height_current = tuning.eye_height if tuning != null else _head.position.y
	_head.position.y = _eye_height_current
	_clear_traversal()
	_offered_marker = null
	_reset_footstep_tracking()
	_interactor.clear_target()


func get_camera() -> Camera3D:
	return _camera


func get_interactor() -> PlayerInteractor:
	return _interactor


func get_pitch_degrees() -> float:
	return rad_to_deg(_pitch)


func get_posture() -> Posture:
	return _posture


func is_crouched() -> bool:
	return _posture == Posture.CROUCHED


func is_sprinting() -> bool:
	return _gameplay_active and not _traversal_active and _posture == Posture.STANDING and Input.is_action_pressed(ACTION_SPRINT)


## Mausblick: relative Pixel × Empfindlichkeit, unabhängig von der Bildrate.
## Läuft nur bei Gameplayfreigabe (Main fängt dann die Maus); pausierte Nodes
## erhalten keine Eingabe, daher stoppt der Blick in der Pause automatisch.
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseMotion):
		return
	if not _gameplay_active or _look_suppress_frames > 0:
		return
	apply_look(event.relative)


## Wendet ein Blickdelta in Pixeln an (auch für Tests ohne Eingabegeräte).
func apply_look(relative: Vector2) -> void:
	var step: float = deg_to_rad(tuning.mouse_sensitivity)
	rotate_y(-relative.x * step)
	_pitch = clampf(
		_pitch - relative.y * step,
		deg_to_rad(tuning.pitch_min),
		deg_to_rad(tuning.pitch_max)
	)
	_head.rotation.x = _pitch


func _process(_delta: float) -> void:
	if _look_suppress_frames > 0:
		_look_suppress_frames -= 1


func _physics_process(delta: float) -> void:
	if not _gameplay_active:
		return

	if _traversal_active:
		# Kontrollierte Kletterbewegung: keine WASD-Bewegung, kein Sprung, kein
		# Haltungswechsel, keine Schwerkraft; Mausblick bleibt möglich.
		_advance_traversal(delta)
		_update_eye_height(delta)
		_reset_footstep_tracking()
		return

	_update_posture()
	_update_eye_height(delta)

	# Eingabeabsicht: Vector2 mit Länge ≤ 1 (Diagonalnormalisierung), dann
	# relativ zur horizontalen Blickrichtung (Yaw des Körpers) ausgerichtet.
	var input_dir: Vector2 = Input.get_vector(ACTION_LEFT, ACTION_RIGHT, ACTION_FORWARD, ACTION_BACKWARD)
	var wish_dir: Vector3 = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		wish_dir = (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y))
		wish_dir.y = 0.0
		wish_dir = wish_dir.normalized() * minf(input_dir.length(), 1.0)

	if _try_start_traversal(wish_dir):
		_advance_traversal(delta)
		return

	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	var intent_speed: float = _intent_speed()
	if is_on_floor():
		var target: Vector3 = wish_dir * intent_speed
		var rate: float = tuning.ground_acceleration if wish_dir != Vector3.ZERO else tuning.ground_deceleration
		horizontal = horizontal.move_toward(target, rate * delta)
	elif wish_dir != Vector3.ZERO:
		# Reduzierte Luftsteuerung; vorhandener Impuls (z. B. aus dem Sprint)
		# bleibt erhalten: Es wird nur umgelenkt, nie in der Luft abgebremst.
		var air_target: Vector3 = wish_dir * maxf(intent_speed, horizontal.length())
		horizontal = horizontal.move_toward(air_target, tuning.ground_acceleration * tuning.air_control * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if is_on_floor():
		# Kein Sprung aus der Hocke (kein Crouch-Jump); Sprung aus dem Sprint erlaubt.
		if _posture == Posture.STANDING and Input.is_action_just_pressed(ACTION_JUMP):
			velocity.y = tuning.get_jump_velocity()
	else:
		velocity.y -= tuning.gravity * delta

	var fall_speed_before_move: float = maxf(-velocity.y, 0.0)
	move_and_slide()
	_update_movement_audio(fall_speed_before_move)


## --- Traversal (Architektur §7 „Traversal im selben Motor“) -------------------

## Vom TraversalMarker beim Betreten seines Erkennungsbereichs aufgerufen.
func offer_traversal(marker: Area3D) -> void:
	_offered_marker = marker


## Vom TraversalMarker beim Verlassen aufgerufen; ein laufender Vorgang wird
## davon nicht berührt, nur ein künftiger Start.
func revoke_traversal(marker: Area3D) -> void:
	if _offered_marker == marker:
		_offered_marker = null


func get_offered_marker() -> Area3D:
	return _offered_marker


func is_traversing() -> bool:
	return _traversal_active


## Leerer String = Start erlaubt; sonst der Ablehnungsgrund. Prüft Zustand,
## Reichweite, Höhe, Bewegungs-/Blickrichtung und die vollständige
## Körperfreiheit entlang des Weges (Heben, dann waagerecht zum Ziel).
func get_traversal_rejection(marker: Area3D, wish_dir: Vector3) -> String:
	if _traversal_active:
		return "läuft bereits"
	if not is_instance_valid(marker) or not marker.is_inside_tree():
		return "kein Angebot"
	if not is_on_floor():
		return "nicht am Boden"
	if _posture != Posture.STANDING:
		return "geduckt"
	if wish_dir.length_squared() < 0.25:
		return "keine Bewegungsabsicht"
	var direction: Vector3 = marker.get_direction()
	var min_dot: float = cos(deg_to_rad(tuning.traversal_max_angle))
	if wish_dir.normalized().dot(direction) < min_dot:
		return "Bewegung nicht auf die Passage zu"
	var facing: Vector3 = -global_transform.basis.z
	facing.y = 0.0
	if facing.normalized().dot(direction) < min_dot:
		return "Blick nicht auf die Passage"
	# Reichweite „vor dem Spieler“: Abstand entlang der Passagerichtung bis
	# zur Eintrittslinie; der seitliche Spielraum ist durch die Erkennungszone
	# des Markers begrenzt (ein Angebot liegt nur innerhalb der Zone vor).
	var to_entry: Vector3 = marker.get_entry_position() - global_position
	to_entry.y = 0.0
	var forward_distance: float = to_entry.dot(direction)
	if forward_distance > tuning.traversal_detect_range:
		return "zu weit entfernt"
	if forward_distance < -tuning.body_radius:
		return "Eintritt liegt hinter dem Spieler"
	var height: float = marker.get_exit_position().y - global_position.y
	if height <= tuning.traversal_lift_margin:
		return "kein Höhenunterschied"
	if height > tuning.traversal_max_height:
		return "Hindernis zu hoch"
	if _build_traversal_path(marker, height).is_empty():
		return "Weg oder Ziel blockiert"
	return ""


func can_start_traversal(marker: Area3D, wish_dir: Vector3) -> bool:
	return get_traversal_rejection(marker, wish_dir).is_empty()


## Startet den Vorgang, wenn das aktuelle Angebot alle Bedingungen erfüllt.
func _try_start_traversal(wish_dir: Vector3) -> bool:
	if _offered_marker == null or not get_traversal_rejection(_offered_marker, wish_dir).is_empty():
		return false
	var height: float = _offered_marker.get_exit_position().y - global_position.y
	_traversal_path = _build_traversal_path(_offered_marker, height)
	if _traversal_path.is_empty():
		return false
	_traversal_index = 0
	_traversal_active = true
	velocity = Vector3.ZERO
	return true


## Wegpunkte: 1. senkrecht auf Zielhöhe plus Rand heben, 2. waagerecht über
## das Ziel. Beide Abschnitte werden mit der eigenen Kollisionsform per
## test_move() geprüft; bei Kontakt gibt es keinen Weg. Die restliche Höhe
## (Rand) setzt die Schwerkraft nach dem Vorgang ab.
func _build_traversal_path(marker: Area3D, height: float) -> PackedVector3Array:
	var lift: Vector3 = Vector3(0.0, height + tuning.traversal_lift_margin, 0.0)
	var start: Transform3D = global_transform
	if test_move(start, lift):
		return PackedVector3Array()
	var lifted: Transform3D = start.translated(lift)
	var exit_position: Vector3 = marker.get_exit_position()
	var target: Vector3 = Vector3(exit_position.x, lifted.origin.y, exit_position.z)
	if test_move(lifted, target - lifted.origin):
		return PackedVector3Array()
	return PackedVector3Array([lifted.origin, target])


## Fährt den Weg kollisionsgeprüft ab. Ein unerwarteter Kontakt (nachträgliche
## Blockade) stoppt an der letzten freien Lage und beendet den Vorgang
## kontrolliert; die normale Fortbewegung übernimmt im nächsten Physiktakt.
func _advance_traversal(delta: float) -> void:
	var budget: float = tuning.traversal_speed * delta
	while budget > 0.0 and _traversal_index < _traversal_path.size():
		var to_target: Vector3 = _traversal_path[_traversal_index] - global_position
		var distance: float = to_target.length()
		if distance <= 0.0005:
			_traversal_index += 1
			continue
		var step: float = minf(distance, budget)
		var collision: KinematicCollision3D = move_and_collide(to_target / distance * step)
		if collision != null:
			_clear_traversal()
			return
		budget -= step
		if step >= distance - 0.0005:
			_traversal_index += 1
	if _traversal_index >= _traversal_path.size():
		_clear_traversal()


func _clear_traversal() -> void:
	_traversal_active = false
	_traversal_path = PackedVector3Array()
	_traversal_index = 0
	velocity = Vector3.ZERO


## --- Schritte und Landung (P1-04, E03-Nachtrag Schritte, E12a) --------------

## Nach move_and_slide(): Schritte aus tatsächlich zurückgelegter horizontaler
## Bodenstrecke, Landungsimpuls aus der Fallgeschwindigkeit vor dem Aufsetzen.
## Stand, Wandkontakt ohne Strecke, Luft, Traversal und Pause erzeugen nichts;
## nach Fortsetzen wird nichts nachgeholt, weil die Strecke nur pro Tick zählt.
func _update_movement_audio(fall_speed_before_move: float) -> void:
	var on_floor: bool = is_on_floor()
	if on_floor:
		if _was_on_floor:
			var moved: Vector3 = global_position - _last_ground_position
			moved.y = 0.0
			var distance: float = moved.length()
			# Unplausible Strecke pro Tick = Versetzen (Spawn, Test, späteres
			# Restore): keine Schritte daraus ableiten, Verfolgung neu ansetzen.
			if distance > tuning.sprint_speed * get_physics_process_delta_time() * 4.0:
				_reset_footstep_tracking()
				return
			_step_accumulator += distance
			var threshold: float = get_footstep_threshold()
			# Eine kleinere Schwelle nach Haltungs-/Sprintwechsel darf einen
			# alten Streckenrest weder im Stand noch beim Wiederanlaufen nachholen.
			if distance == 0.0 and _step_accumulator >= threshold:
				_step_accumulator = 0.0
			elif _step_accumulator >= threshold:
				# Höchstens ein Schritt pro Tick; Rest bleibt unter der Schwelle.
				_step_accumulator = minf(_step_accumulator - threshold, threshold * 0.5)
				_play_footstep()
		else:
			var impact: float = maxf(_peak_fall_speed, fall_speed_before_move)
			_last_impact_speed = impact
			if impact >= tuning.landing_min_fall_speed:
				_play_landing()
			_step_accumulator = 0.0
		_peak_fall_speed = 0.0
	else:
		_peak_fall_speed = maxf(_peak_fall_speed, fall_speed_before_move)
		_step_accumulator = 0.0
	_was_on_floor = on_floor
	_last_ground_position = global_position


## Schrittstrecke für den aktuellen Kontext (Ducken vor Sprint vor Gehen).
func get_footstep_threshold() -> float:
	match get_footstep_context():
		"crouch":
			return tuning.footstep_distance_crouch
		"sprint":
			return tuning.footstep_distance_sprint
		_:
			return tuning.footstep_distance_walk


func get_footstep_context() -> String:
	if _posture == Posture.CROUCHED:
		return "crouch"
	if is_sprinting():
		return "sprint"
	return "walk"


func _play_footstep() -> void:
	var context: String = get_footstep_context()
	var offset_db: float = 0.0
	match context:
		"sprint":
			offset_db = tuning.footstep_sprint_db
		"crouch":
			offset_db = tuning.footstep_crouch_db
	var variation: float = tuning.footstep_pitch_variation
	_trigger_impulse(context, offset_db, 1.0 + randf_range(-variation, variation))
	_footstep_count += 1


func _play_landing() -> void:
	_trigger_impulse("landing", tuning.landing_db, tuning.landing_pitch_scale)
	_landing_count += 1


## Einzige Stelle, die die lokale Audioquelle anstößt; sie liest nur Werte.
func _trigger_impulse(context: String, volume_db: float, pitch_scale: float) -> void:
	_last_footstep_context = context
	_last_footstep_db = volume_db
	_last_footstep_pitch = pitch_scale
	_footsteps.volume_db = volume_db
	_footsteps.pitch_scale = pitch_scale
	_footsteps.play()


## Strecken-/Fallverfolgung neu ansetzen (Spawn, Traversal): kein alter Rest
## löst danach einen Schritt oder eine Landung aus.
func _reset_footstep_tracking() -> void:
	_step_accumulator = 0.0
	_peak_fall_speed = 0.0
	_was_on_floor = is_on_floor()
	_last_ground_position = global_position


## Diagnosewerte (nur lesend, für Debug-Overlay und Tests).
func get_locomotion_name() -> String:
	if _traversal_active:
		return "TRAVERSING"
	return "GROUNDED" if is_on_floor() else "AIRBORNE"


func get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func get_step_accumulator() -> float:
	return _step_accumulator


func get_footstep_count() -> int:
	return _footstep_count


func get_landing_count() -> int:
	return _landing_count


func get_last_footstep_context() -> String:
	return _last_footstep_context


func get_last_footstep_db() -> float:
	return _last_footstep_db


func get_last_footstep_pitch() -> float:
	return _last_footstep_pitch


func get_last_impact_speed() -> float:
	return _last_impact_speed


## Zieltempo aus Haltung und Sprintabsicht: geduckt gilt das Ducktempo,
## Sprint ist nur stehend möglich.
func _intent_speed() -> float:
	if _posture == Posture.CROUCHED:
		return tuning.crouch_speed
	if Input.is_action_pressed(ACTION_SPRINT):
		return tuning.sprint_speed
	return tuning.walk_speed


## Haltung nur am Boden wechseln: Halten von „crouch“ duckt sofort, Loslassen
## versucht aufzustehen; unter blockierter Decke bleibt der Player geduckt.
func _update_posture() -> void:
	if not is_on_floor():
		return
	var wants_crouch: bool = Input.is_action_pressed(ACTION_CROUCH)
	if wants_crouch and _posture == Posture.STANDING:
		_set_posture(Posture.CROUCHED)
	elif not wants_crouch and _posture == Posture.CROUCHED and can_stand_up():
		_set_posture(Posture.STANDING)


## Prüft mit einer Physikabfrage, ob die stehende Kapsel (plus Freiraum-
## Rand) an der aktuellen Position frei von anderen Körpern ist. Der eigene
## Körper ist ausgeschlossen; die Prüfkapsel beginnt knapp über den Füßen,
## damit der Boden selbst nicht als Blockade zählt.
func can_stand_up() -> bool:
	var margin: float = tuning.stand_clearance_margin
	_stand_query_shape.radius = tuning.body_radius
	_stand_query_shape.height = tuning.body_height
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _stand_query_shape
	query.transform = global_transform.translated_local(Vector3(0.0, tuning.body_height * 0.5 + margin, 0.0))
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var hits: Array[Dictionary] = get_world_3d().direct_space_state.intersect_shape(query, 1)
	return hits.is_empty()


## Haltung setzen. Beim Aufstehen wächst die Kapsel sofort (der Freiraum ist
## geprüft); beim Ducken bleibt sie hoch, bis die Kamera unten ist, damit die
## Kamera nie außerhalb der Kollisionsform liegt (kein Kameradurchtritt).
func _set_posture(posture: Posture) -> void:
	_posture = posture
	if tuning == null:
		return
	if posture == Posture.STANDING:
		_apply_capsule_height(tuning.body_height)
	elif tuning.posture_transition_time <= 0.0:
		_apply_capsule_height(tuning.crouch_body_height)


## Instanzlokale Kapsel auf die gegebene Höhe setzen; die Füße bleiben am Root.
func _apply_capsule_height(height: float) -> void:
	var capsule: CapsuleShape3D = _body_shape.shape as CapsuleShape3D
	if capsule != null:
		capsule.height = height
	_body_shape.position = Vector3(0.0, height * 0.5, 0.0)


func get_capsule_height() -> float:
	var capsule: CapsuleShape3D = _body_shape.shape as CapsuleShape3D
	return capsule.height if capsule != null else 0.0


## Kamerahöhe weich zur Zielaugenhöhe der Haltung führen. Sobald die Kamera
## in der Hocke angekommen ist, wird die Kapsel auf die Duckhöhe verkleinert.
func _update_eye_height(delta: float) -> void:
	var target: float = tuning.crouch_eye_height if _posture == Posture.CROUCHED else tuning.eye_height
	if tuning.posture_transition_time <= 0.0:
		_eye_height_current = target
	else:
		var rate: float = absf(tuning.eye_height - tuning.crouch_eye_height) / tuning.posture_transition_time
		_eye_height_current = move_toward(_eye_height_current, target, rate * delta)
	_head.position.y = _eye_height_current
	if _posture == Posture.CROUCHED and is_equal_approx(_eye_height_current, tuning.crouch_eye_height):
		_apply_capsule_height(tuning.crouch_body_height)


## Kapsel und Kamera aus der Konfiguration ableiten. Die Kollisionsform bleibt
## instanzlokal, damit Formänderungen (Ducken) keine geteilte Resource
## verändern.
func _apply_tuning() -> void:
	if tuning == null:
		return
	var capsule: CapsuleShape3D = _body_shape.shape as CapsuleShape3D
	if capsule == null:
		push_error("%s: BodyShape benötigt eine CapsuleShape3D." % name)
		return
	if not capsule.resource_local_to_scene:
		capsule = capsule.duplicate()
		_body_shape.shape = capsule
	capsule.radius = tuning.body_radius
	_set_posture(_posture)
	_head.position = Vector3(0.0, _head.position.y, 0.0)
	_camera.fov = tuning.fov
