extends CanvasLayer
## DebugOverlay – kleine abschaltbare Entwicklungsansicht (Architektur §28).
##
## Liest ausschließlich vorhandene Zustände von Main und Player und zeigt sie
## an; sie ist keine zweite Zustandswahrheit und greift nirgends ein. Main
## instanziiert sie nur im Entwicklungsmodus (Debug-Build); im Release
## existiert sie nicht. Ausbaustufe P1-04: Phase, Freigabe, Fortbewegung,
## Haltung, Geschwindigkeit, Schrittstrecke, letzter Impuls, Landungen.

## Entwicklungs-Hotkey zum Ein-/Ausblenden (F3). Bewusst außerhalb der
## Gameplay-Input-Map, da project.godot in P1-04 nicht dafür freigegeben ist;
## eine Action `debug_overlay` kann in einem späteren Auftrag ergänzt werden.
const TOGGLE_KEY: Key = KEY_F3

@onready var _label: Label = $Panel/Label

var _main: Node = null


func _ready() -> void:
	_label.text = ""


## Von Main nach dem Instanziieren aufgerufen; nur eine lesende Referenz.
func bind_main(main: Node) -> void:
	_main = main


func toggle() -> void:
	visible = not visible


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == TOGGLE_KEY:
		toggle()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not visible or _main == null:
		return
	_label.text = build_text()


## Textaufbau ist getrennt, damit Tests ihn ohne Darstellung prüfen können.
func build_text() -> String:
	var lines: PackedStringArray = []
	var phase_name: String = _main.Phase.keys()[_main.get_phase()] if _main.has_method("get_phase") else "?"
	lines.append("Phase %s  paused=%s" % [phase_name, str(get_tree().paused)])
	var world: Node = _main.get_world() if _main.has_method("get_world") else null
	if world == null:
		lines.append("Welt: keine")
		return "\n".join(lines)
	lines.append("Welt %s  gameplay=%s" % [world.get_display_name(), str(world.is_gameplay_active())])
	var player: Node = world.get_player() if world.has_method("get_player") else null
	if player == null:
		lines.append("Player: keiner")
		return "\n".join(lines)
	lines.append("Fortbewegung %s  Haltung %s" % [player.get_locomotion_name(), player.Posture.keys()[player.get_posture()]])
	lines.append("Tempo %5.2f m/s  vy %5.2f  Sprint %s" % [player.get_horizontal_speed(), player.velocity.y, str(player.is_sprinting())])
	lines.append("Schritt %4.2f / %4.2f m (%s)" % [player.get_step_accumulator(), player.get_footstep_threshold(), player.get_footstep_context()])
	lines.append("Letzter Impuls %s  %+.1f dB  pitch %.3f" % [player.get_last_footstep_context() if player.get_last_footstep_context() != "" else "-", player.get_last_footstep_db(), player.get_last_footstep_pitch()])
	lines.append("Schritte %d  Landungen %d  letzter Aufprall %.2f m/s (Schwelle %.1f)" % [player.get_footstep_count(), player.get_landing_count(), player.get_last_impact_speed(), player.tuning.landing_min_fall_speed])
	if player.has_method("get_offered_marker"):
		var marker: Node = player.get_offered_marker()
		if marker != null:
			var facing: Vector3 = -player.global_transform.basis.z
			var reason: String = player.get_traversal_rejection(marker, facing)
			lines.append("Traversal-Angebot %s: %s" % [marker.name, reason if reason != "" else "startbereit (vorwärts laufen)"])
		else:
			lines.append("Traversal-Angebot -")
	return "\n".join(lines)
