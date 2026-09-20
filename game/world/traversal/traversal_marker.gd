extends Area3D
## TraversalMarker – ausdrücklich erlaubte Kletterpassage (Architektur §7, §25, §26).
##
## Der Marker beschreibt nur das geometrische Angebot: Eintrittspunkt am Fuß
## des Hindernisses (Entry) und Zielpunkt oben bzw. dahinter (Exit). Betritt
## ein Körper den Erkennungsbereich, wird ihm die Passage angeboten; verlässt
## er ihn, wird das Angebot zurückgezogen. Ob und wann geklettert wird,
## entscheidet ausschließlich der Player (Reichweite, Höhe, Richtung,
## Freiraum). Der Marker schreibt nie eine Position.

@onready var _entry: Marker3D = $Entry
@onready var _exit: Marker3D = $Exit


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func get_entry_position() -> Vector3:
	return _entry.global_position


func get_exit_position() -> Vector3:
	return _exit.global_position


## Horizontale Passagerichtung vom Eintritt zum Ziel.
func get_direction() -> Vector3:
	var direction: Vector3 = _exit.global_position - _entry.global_position
	direction.y = 0.0
	return direction.normalized()


## Höhe des Ziels über dem Eintrittspunkt.
func get_height() -> float:
	return _exit.global_position.y - _entry.global_position.y


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("offer_traversal"):
		body.offer_traversal(self)


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("revoke_traversal"):
		body.revoke_traversal(self)
