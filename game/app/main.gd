extends Node
## Main – Besitzer der Anwendungslebensdauer (Architektur §6, §8, §21, §25).
##
## Main lebt während der gesamten Anwendung, ohne Autoload. Es führt die
## Phasen, erzeugt und gibt genau eine Welt unter WorldHost frei, bindet die
## dauerhafte GameUI und setzt als Einziges SceneTree.paused. Welten erfüllen
## den minimalen Levelvertrag aus levels/vertical_slice/vertical_slice.gd;
## Main kennt keine Weltinterna.
##
## Ausbaustufe P0-03: Phasen MENU, PREPARING, PLAYING und PAUSED mit
## kontrolliertem Aufbau/Abbau, Pause/Fortsetzen über die Action „pause“ und
## Pause bei Fokusverlust (E03a). GAME_OVER, COMPLETED, SaveService,
## Todes-Snapshot und Einstellungen folgen mit ihren jeweiligen Tasks.

enum Phase { MENU, PREPARING, PLAYING, PAUSED }

## Systems Sandbox: neutrale Testwelt, nur im Entwicklungsmodus erreichbar.
const SANDBOX_SCENE_PATH: String = "res://tests/systems_sandbox.tscn"

## Einzige von Main selbst ausgewertete Action (E03a: Escape toggelt Pause).
const PAUSE_ACTION: StringName = &"pause"

## Präfix der Godot-eigenen UI-Actions; sie gehören nicht zum Gameplay-Puffer.
const UI_ACTION_PREFIX: String = "ui_"

## Obergrenze an Frames, die auf die Freigabe einer alten Welt gewartet wird.
const MAX_TEARDOWN_FRAMES: int = 10

@onready var _world_host: Node3D = $WorldHost
@onready var _game_ui: CanvasLayer = $GameUI

var _phase: Phase = Phase.MENU
## Wird genau einmal pro Weltwechsel erhöht; entwertet verspätete Fortsetzungen.
var _run_generation: int = 0
var _world: Node3D = null


func _ready() -> void:
	_game_ui.sandbox_requested.connect(_on_sandbox_requested)
	_game_ui.resume_requested.connect(_on_resume_requested)
	_game_ui.menu_requested.connect(_on_menu_requested)
	_game_ui.quit_requested.connect(_on_quit_requested)
	# E03a: Fokusverlust pausiert aktives Gameplay. Fokusrückkehr wird bewusst
	# nicht verbunden; Fortsetzen erfolgt nur durch eine Nutzeraktion.
	get_window().focus_exited.connect(_on_window_focus_exited)
	_enter_menu()


## Pause-Action nach der UI-Verarbeitung (Architektur §8): Ein von der UI
## behandeltes Ereignis kommt hier nicht mehr an. Außerhalb von PLAYING/PAUSED
## löst die Action nichts aus.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(PAUSE_ACTION):
		return
	match _phase:
		Phase.PLAYING:
			pause_game()
		Phase.PAUSED:
			resume_game()
		_:
			return
	get_viewport().set_input_as_handled()


## Sandboxzugang ist auf Entwicklungsbuilds begrenzt. Die genaue
## Debug-/Release-Grenze wird in P0-04 mit dem Export festgelegt.
func is_sandbox_allowed() -> bool:
	return OS.is_debug_build()


func get_phase() -> Phase:
	return _phase


func get_run_generation() -> int:
	return _run_generation


func get_world() -> Node3D:
	return _world


## Baut die Welt aus scene_path als einzige Welt unter WorldHost auf.
## Ablauf: alte Welt abbauen und Freigabe abwarten, neue Welt inaktiv
## instanziieren, Vertrag und Referenzen prüfen, erst dann UI binden und
## Gameplay freigeben. Bei jedem Fehler bleibt WorldHost leer und Main im Menü.
func start_world(scene_path: String) -> void:
	if _phase == Phase.PREPARING:
		push_warning("Main: Weltwechsel läuft bereits; Anfrage verworfen.")
		return
	var generation: int = _begin_transition()
	_game_ui.show_preparing("Welt wird vorbereitet …")
	await _teardown_world()
	if generation != _run_generation:
		return

	if _world_host.get_child_count() > 0:
		_fail_transition("WorldHost ist nach dem Abbau nicht leer.")
		return

	var packed: PackedScene = ResourceLoader.load(scene_path, "PackedScene") as PackedScene
	if packed == null:
		_fail_transition("Weltszene konnte nicht geladen werden: %s" % scene_path)
		return

	var world: Node = packed.instantiate()
	if not _is_valid_world(world):
		world.free()
		_fail_transition("Weltszene erfüllt den Levelvertrag nicht: %s" % scene_path)
		return

	_world = world
	_world_host.add_child(world)
	if not world.prepare_world():
		await _teardown_world()
		_fail_transition("Welt konnte nicht vorbereitet werden: %s" % scene_path)
		return

	_game_ui.bind_world(world)
	_activate_gameplay()


## Pausiert das aktive Gameplay (E03a). Nur Main setzt SceneTree.paused;
## Main und GameUI laufen weiter, WorldHost steht.
func pause_game() -> void:
	if _phase != Phase.PLAYING:
		return
	_set_phase(Phase.PAUSED)
	_world.set_gameplay_active(false)
	_game_ui.show_pause()


## Setzt das pausierte Gameplay nach bewusster Nutzeraktion fort (E03a).
func resume_game() -> void:
	if _phase != Phase.PAUSED:
		return
	_activate_gameplay()


## Verlässt die aktive oder pausierte Welt kontrolliert und kehrt ins Hauptmenü zurück.
func return_to_menu() -> void:
	if _phase != Phase.PLAYING and _phase != Phase.PAUSED:
		push_warning("Main: Rückkehr ins Menü nur aus PLAYING oder PAUSED möglich.")
		return
	_begin_transition()
	await _teardown_world()
	_enter_menu()


func _on_sandbox_requested() -> void:
	if not is_sandbox_allowed():
		push_warning("Main: Systems Sandbox ist in diesem Build nicht erlaubt.")
		return
	start_world(SANDBOX_SCENE_PATH)


func _on_resume_requested() -> void:
	resume_game()


func _on_menu_requested() -> void:
	return_to_menu()


func _on_quit_requested() -> void:
	get_tree().quit()


func _on_window_focus_exited() -> void:
	if _phase == Phase.PLAYING:
		pause_game()


## Phase und Enginepause an genau einer Stelle setzen: pausiert nur in PAUSED.
func _set_phase(phase: Phase) -> void:
	_phase = phase
	get_tree().paused = phase == Phase.PAUSED


## Gemeinsamer Eintritt in PLAYING für Weltstart und Fortsetzen: Aktionspuffer
## verwerfen, Gameplay freigeben, Weltansicht mit gefangener Maus zeigen.
func _activate_gameplay() -> void:
	_set_phase(Phase.PLAYING)
	_discard_action_buffer()
	_world.set_gameplay_active(true)
	_game_ui.show_world_view()


## Gehaltene oder gepufferte Eingaben aus Menü/Pause nicht in die Welt tragen
## (Architektur §8): kein aufgestauter Sprung oder Klick nach dem Wechsel.
func _discard_action_buffer() -> void:
	Input.flush_buffered_events()
	for action in InputMap.get_actions():
		if not String(action).begins_with(UI_ACTION_PREFIX):
			Input.action_release(action)


func _begin_transition() -> int:
	_run_generation += 1
	_set_phase(Phase.PREPARING)
	return _run_generation


func _enter_menu() -> void:
	_set_phase(Phase.MENU)
	_game_ui.show_menu(is_sandbox_allowed())


func _fail_transition(message: String) -> void:
	push_error("Main: " + message)
	_set_phase(Phase.MENU)
	_game_ui.show_error(message, is_sandbox_allowed())


## Gameplay sperren, UI-Referenzen lösen, Welt aus WorldHost entfernen und
## ihre tatsächliche Freigabe abwarten. Erst danach darf eine neue Welt entstehen.
func _teardown_world() -> void:
	var world: Node3D = _world
	_world = null
	_game_ui.unbind_world()
	if world == null:
		return
	world.set_gameplay_active(false)
	_world_host.remove_child(world)
	world.queue_free()
	var waited_frames: int = 0
	while is_instance_valid(world) and waited_frames < MAX_TEARDOWN_FRAMES:
		await get_tree().process_frame
		waited_frames += 1
	if is_instance_valid(world):
		push_error("Main: Alte Welt wurde nach %d Frames nicht freigegeben." % waited_frames)


func _is_valid_world(node: Node) -> bool:
	return node is Node3D \
		and node.has_method("prepare_world") \
		and node.has_method("set_gameplay_active")
