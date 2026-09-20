extends CharacterBody3D
## Player – First-Person-Motor und Blicksteuerung (Architektur §7, §8, §25).
##
## Dieses Script ist der einzige Schreiber der Spielerposition. Bewegung und
## Kollisionsantwort laufen im Physiktakt über move_and_slide(); der Körper
## dreht horizontal (Yaw), Head vertikal (Pitch), die Kamera bleibt Kind von
## Head. Alle Zahlen kommen aus PlayerTuning; keine Tastencodes, nur Actions.
##
## Ausbaustufe P1-02: WASD, Mausblick, Gravity, Sprung, Bodenkollision,
## Sprint (Halten) und Ducken (Halten) mit sicherem Aufstehen. Haltung
## (STANDING/CROUCHED) ist eine eigene Achse neben der Fortbewegung
## (am Boden / in der Luft über is_on_floor()); keine Zustandsmaschine.
## Traversal, Interaktion, Licht, Health und Audio folgen mit ihren Tasks.
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
func set_gameplay_active(active: bool) -> void:
	_gameplay_active = active
	if active:
		_look_suppress_frames = LOOK_SUPPRESS_FRAMES


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


func get_camera() -> Camera3D:
	return _camera


func get_pitch_degrees() -> float:
	return rad_to_deg(_pitch)


func get_posture() -> Posture:
	return _posture


func is_crouched() -> bool:
	return _posture == Posture.CROUCHED


func is_sprinting() -> bool:
	return _gameplay_active and _posture == Posture.STANDING and Input.is_action_pressed(ACTION_SPRINT)


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

	_update_posture()
	_update_eye_height(delta)

	# Eingabeabsicht: Vector2 mit Länge ≤ 1 (Diagonalnormalisierung), dann
	# relativ zur horizontalen Blickrichtung (Yaw des Körpers) ausgerichtet.
	var input_dir: Vector2 = Input.get_vector(ACTION_LEFT, ACTION_RIGHT, ACTION_FORWARD, ACTION_BACKWARD)
	var wish_dir: Vector3 = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		wish_dir = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y))
		wish_dir.y = 0.0
		wish_dir = wish_dir.normalized() * minf(input_dir.length(), 1.0)

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

	move_and_slide()


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
