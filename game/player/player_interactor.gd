class_name PlayerInteractor
extends Node
## PlayerInteractor – Zielerkennung, Reichweiten-/Sichtprüfung und
## Interaktionsanfrage des Players (Architektur §9, §25 „Player“; E04).
##
## Ausgangspunkt ist der RayCast3D in der Kameramitte. Der erste Treffer
## entscheidet: Wand oder Boden bedeuten kein Ziel; nur wenn der Treffer zu
## einem Interactable gehört, wird es zum Ziel. Der eigene Player-Körper ist
## als Ausnahme eingetragen. Dieses Script besitzt keine Logik des Zielobjekts
## und keinen Weltzustand; es fordert die Interaktion nur an. Die Freigabe
## kommt vom Player (set_gameplay_active), Eingabe ausschließlich über die
## Action „interact“ (einmal drücken).

## Gemeldet bei jeder Zieländerung; leerer Text = kein gültiges Ziel. Die UI
## stellt daraus den Hinweis dar, entscheidet aber nichts.
signal target_changed(action_text: String)

const ACTION_INTERACT: StringName = &"interact"

## Vorläufiger Tuningwert (E04): maximale Reichweite in Metern von der
## Kameramitte bis zum gültigen Ziel.
@export_range(0.5, 5.0, 0.1, "suffix:m") var interact_range: float = 2.2

@onready var _ray: RayCast3D = $"../Head/Camera3D/InteractionRay"
@onready var _player: CollisionObject3D = get_parent()

var _active: bool = false
var _target: Interactable = null
var _last_action_text: String = ""
## Interner Ablehnungsgrund der letzten Prüfung; nur für Debug-/Diagnosepfad.
var _last_rejection: String = "nicht freigegeben"
var _interaction_count: int = 0


func _ready() -> void:
	_ray.target_position = Vector3(0.0, 0.0, -interact_range)
	_ray.collide_with_areas = true
	_ray.collide_with_bodies = true
	_ray.add_exception(_player)


## Vom Player weitergereicht. Sperren löscht das Ziel sofort, damit weder
## Hinweis noch alte Zielreferenz eine Pause oder einen Weltwechsel überdauern.
func set_gameplay_active(active: bool) -> void:
	_active = active
	if not active:
		clear_target()
		_last_rejection = "nicht freigegeben"


func clear_target() -> void:
	_set_target(null, "kein Ziel")


func get_target() -> Interactable:
	return _target if is_instance_valid(_target) else null


func has_target() -> bool:
	return get_target() != null


func get_action_text() -> String:
	return _last_action_text


func get_last_rejection() -> String:
	return _last_rejection


func get_interaction_count() -> int:
	return _interaction_count


func _physics_process(_delta: float) -> void:
	if not _active:
		return
	_update_target()


func _unhandled_input(event: InputEvent) -> void:
	if not _active or not event.is_action_pressed(ACTION_INTERACT):
		return
	get_viewport().set_input_as_handled()
	_try_interact()


## Erneute Prüfung mit aktuellem Ray (Blick kann sich seit dem letzten
## Physiktakt geändert haben), dann genau eine Anfrage an das Ziel.
func _try_interact() -> void:
	_update_target()
	var target: Interactable = get_target()
	if target == null:
		return
	if target.request_interaction(_player):
		_interaction_count += 1
	_update_target()


## Ray auswerten: erster Treffer, Interactable-Vorfahre innerhalb der Welt.
func _update_target() -> void:
	_ray.force_raycast_update()
	if not _ray.is_colliding():
		_set_target(null, "kein Treffer in Reichweite")
		return
	var collider: Object = _ray.get_collider()
	var interactable: Interactable = _resolve_interactable(collider as Node)
	if interactable == null:
		_set_target(null, "vorderster Treffer ohne Interactable")
		return
	var info: Dictionary = interactable.get_action_info()
	if not info["available"]:
		_set_target(null, "Ziel nicht verfügbar: %s" % info["reason"])
		return
	_set_target(interactable, info["text"])


## Vom getroffenen Kollisionsobjekt aufwärts bis zum Interactable; endet
## spätestens an der Weltgrenze (Vorfahre des Players) oder beim Player selbst.
func _resolve_interactable(node: Node) -> Interactable:
	var current: Node = node
	while current != null:
		if current is Interactable:
			return current
		if current == _player or current.is_ancestor_of(_player):
			return null
		current = current.get_parent()
	return null


## Ziel setzen (Text = Hinweis) oder verwerfen (Text = interner Grund).
func _set_target(target: Interactable, text: String) -> void:
	var action_text: String = text if target != null else ""
	_last_rejection = "" if target != null else text
	if target == _target and action_text == _last_action_text:
		return
	_target = target
	_last_action_text = action_text
	target_changed.emit(action_text)
