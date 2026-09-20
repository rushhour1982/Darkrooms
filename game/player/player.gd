extends CharacterBody3D
## Player – First-Person-Motor und Blicksteuerung (Architektur §7, §8, §25).
##
## Dieses Script ist der einzige Schreiber der Spielerposition. Bewegung und
## Kollisionsantwort laufen im Physiktakt über move_and_slide(); der Körper
## dreht horizontal (Yaw), Head vertikal (Pitch), die Kamera bleibt Kind von
## Head. Alle Zahlen kommen aus PlayerTuning; keine Tastencodes, nur Actions.
##
## Ausbaustufe P1-01: WASD, Mausblick, Gravity, Sprung, Bodenkollision.
## Sprint, Ducken, Traversal, Interaktion, Licht, Health und Audio folgen
## mit ihren Tasks. Gameplayfreigabe kommt ausschließlich vom Level über
## set_gameplay_active(); ohne Freigabe wird weder bewegt noch geblickt.

const ACTION_FORWARD: StringName = &"move_forward"
const ACTION_BACKWARD: StringName = &"move_backward"
const ACTION_LEFT: StringName = &"move_left"
const ACTION_RIGHT: StringName = &"move_right"
const ACTION_JUMP: StringName = &"jump"

## Frames nach einer Freigabe, in denen Mausbewegung verworfen wird, damit
## ein alter Mausimpuls beim Wiederfangen keinen Kamerasprung auslöst.
const LOOK_SUPPRESS_FRAMES: int = 2

## Vorläufige Bewegungs-/Kamerawerte (E03-Prototyp-Profil).
@export var tuning: PlayerTuning

@onready var _body_shape: CollisionShape3D = $BodyShape
@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D

var _gameplay_active: bool = false
## Vertikaler Blickwinkel in Radiant; Laufzustand, nicht Konfiguration.
var _pitch: float = 0.0
var _look_suppress_frames: int = 0


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


## Setzt Geschwindigkeit und Blickhistorie zurück; Yaw bleibt die Spawnausrichtung.
func reset_motion_state() -> void:
	velocity = Vector3.ZERO
	_pitch = 0.0
	_head.rotation = Vector3.ZERO
	_look_suppress_frames = LOOK_SUPPRESS_FRAMES


func get_camera() -> Camera3D:
	return _camera


func get_pitch_degrees() -> float:
	return rad_to_deg(_pitch)


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

	# Eingabeabsicht: Vector2 mit Länge ≤ 1 (Diagonalnormalisierung), dann
	# relativ zur horizontalen Blickrichtung (Yaw des Körpers) ausgerichtet.
	var input_dir: Vector2 = Input.get_vector(ACTION_LEFT, ACTION_RIGHT, ACTION_FORWARD, ACTION_BACKWARD)
	var wish_dir: Vector3 = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		wish_dir = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y))
		wish_dir.y = 0.0
		wish_dir = wish_dir.normalized() * minf(input_dir.length(), 1.0)

	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	var target: Vector3 = wish_dir * tuning.walk_speed
	if is_on_floor():
		var rate: float = tuning.ground_acceleration if wish_dir != Vector3.ZERO else tuning.ground_deceleration
		horizontal = horizontal.move_toward(target, rate * delta)
	elif wish_dir != Vector3.ZERO:
		# Reduzierte Luftsteuerung; ohne Eingabe bleibt der Luftimpuls erhalten.
		horizontal = horizontal.move_toward(target, tuning.ground_acceleration * tuning.air_control * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if is_on_floor():
		if Input.is_action_just_pressed(ACTION_JUMP):
			velocity.y = tuning.get_jump_velocity()
	else:
		velocity.y -= tuning.gravity * delta

	move_and_slide()


## Kapsel und Kamera aus der Konfiguration ableiten. Die Kollisionsform bleibt
## instanzlokal, damit spätere Formänderungen (Ducken) keine geteilte Resource
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
	capsule.height = tuning.body_height
	capsule.radius = tuning.body_radius
	_body_shape.position = Vector3(0.0, tuning.body_height * 0.5, 0.0)
	_head.position = Vector3(0.0, tuning.eye_height, 0.0)
	_camera.fov = tuning.fov
