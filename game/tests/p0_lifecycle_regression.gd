extends SceneTree
## R0-Regressionen ohne Framework; mit Godot --path game --headless
## --script res://tests/p0_lifecycle_regression.gd ausführen.
## Ohne --headless werden zusätzlich die Mausmodi geprüft.

var _passed: int = 0
var _failed: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		push_error("FAIL: " + label)


func _queue_key(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)


func _check_state(main: Node, should_pause: bool, label: String) -> void:
	_check(main.get_phase() == (main.Phase.PAUSED if should_pause else main.Phase.PLAYING), label + ": Phase")
	_check(paused == should_pause, label + ": Enginepause")
	_check(main.get_world().is_gameplay_active() == not should_pause, label + ": Gameplay")
	_check(main.get_node("GameUI/Root/PausePanel").visible == should_pause, label + ": Pausepanel")
	_check(main.get_node("GameUI/Root/HUD").visible == not should_pause, label + ": HUD")
	_check(main.get_node("WorldHost").get_child_count() == 1, label + ": genau eine Welt")
	if DisplayServer.get_name() != "headless":
		_check(Input.mouse_mode == (Input.MOUSE_MODE_VISIBLE if should_pause else Input.MOUSE_MODE_CAPTURED), label + ": Mausmodus")


func _run() -> void:
	var main: Node = load("res://app/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await main.start_world(main.SANDBOX_SCENE_PATH)
	Input.use_accumulated_input = true
	var generation: int = main.get_run_generation()
	main.pause_game()
	_queue_key(KEY_ESCAPE)
	main.resume_game()
	_check_state(main, false, "Gepuffertes Escape beim Fortsetzen")
	_check(main.get_run_generation() == generation, "Fortsetzen ist kein Weltwechsel")

	main.pause_game()
	main.get_node("GameUI/Root/PausePanel/Layout/MenuButton").grab_focus()
	_queue_key(KEY_ENTER)
	main.resume_game()
	_check_state(main, false, "Gepuffertes UI-Accept auf altem Menübutton")

	for focus_returns_early in [false, true]:
		var old_world: Node = main.get_world()
		main.start_world(main.SANDBOX_SCENE_PATH)
		_check(main.get_phase() == main.Phase.PREPARING, "Weltwechsel wartet auf Freigabe")
		root.focus_exited.emit()
		if focus_returns_early:
			root.focus_entered.emit()
		for frame in range(3):
			await process_frame
		_check(not is_instance_valid(old_world), "Alte Welt freigegeben")
		_check_state(main, true, "Fokusverlust während Weltwechsel")
		root.focus_entered.emit()
		await process_frame
		_check_state(main, true, "Fokusrückkehr setzt nicht fort")
		main.resume_game()
		_check_state(main, false, "Bewusstes Fortsetzen nach Weltwechsel")

	await main.return_to_menu()
	_check(main.get_phase() == main.Phase.MENU and not paused, "Saubere Rückkehr ins Menü")
	_check(main.get_world() == null and not main.get_node("GameUI").has_world_bound(), "Keine Weltreferenzen im Menü")
	print("R0: %d bestanden, %d fehlgeschlagen (%s)" % [_passed, _failed, DisplayServer.get_name()])
	quit(1 if _failed else 0)
