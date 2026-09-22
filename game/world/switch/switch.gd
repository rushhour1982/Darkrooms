extends Interactable
## Switch – neutraler Testschalter mit eigenständiger Stellung (Architektur §9, §13).
##
## Ausbaustufe P2-01: ausschließlich Prüfobjekt für den Interaktionsvertrag.
## Die Stellung liegt lokal in dieser Instanz (kein Puzzle, keine Bindung);
## Darstellung = Hebelneigung und Materialwechsel der Basis. Die Materialien
## sind gemeinsame Szenenressourcen und werden nur referenziert, nie verändert.

## Hebelneigung in Grad je Stellung; reine Darstellung, kein Tuning.
const LEVER_ANGLE_OFF: float = 30.0
const LEVER_ANGLE_ON: float = -30.0

@export var material_off: Material
@export var material_on: Material

@onready var _base: MeshInstance3D = $Visuals/Base
@onready var _lever: MeshInstance3D = $Visuals/Lever

var _is_on: bool = false
var _toggle_count: int = 0


func _ready() -> void:
	_apply_visual_state()


func is_on() -> bool:
	return _is_on


func get_toggle_count() -> int:
	return _toggle_count


func get_state_name() -> String:
	return "ON" if _is_on else "OFF"


func _perform_interaction(_actor: Node3D) -> void:
	_is_on = not _is_on
	_toggle_count += 1
	_apply_visual_state()


func _apply_visual_state() -> void:
	_lever.rotation_degrees.x = LEVER_ANGLE_ON if _is_on else LEVER_ANGLE_OFF
	_base.material_override = material_on if _is_on else material_off
