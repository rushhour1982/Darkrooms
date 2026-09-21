extends SceneTree
## R1: echte Bodenstrecke beim Haltungswechsel und weltbezogene Bewegung.
## Godot --headless --path game --script res://tests/p1_movement_regression.gd

var _passed: int = 0
var _failed: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
	print("PASS " if condition else "FAIL ", label)


func _ticks(count: int) -> void:
	for tick in range(count):
		await physics_frame


func _run() -> void:
	var main: Node = load("res://app/main.tscn").instantiate()
	root.add_child(main)
	await main.start_world(main.SANDBOX_SCENE_PATH)
	var world: Node3D = main.get_world()
	var player: CharacterBody3D = world.get_player()
	player.position = Vector3(6.0, 0.0, 8.0)
	await _ticks(10)
	Input.action_press("move_forward")
	await _ticks(11)
	Input.action_release("move_forward")
	await _ticks(30)
	_check(is_zero_approx(player.get_horizontal_speed()), "Player vor Haltungswechsel im Stillstand")
	_check(player.get_step_accumulator() > player.tuning.footstep_distance_crouch,
		"Echte Reststrecke liegt über der Duckschwelle")
	var position_before: Vector3 = player.global_position
	var steps_before: int = player.get_footstep_count()
	Input.action_press("crouch")
	await _ticks(15)
	_check(player.global_position.is_equal_approx(position_before), "Ducken erzeugt keine Bodenstrecke")
	_check(player.get_footstep_count() == steps_before, "Kein Schritt durch Ducken im Stillstand")
	_check(player.get_step_accumulator() < player.tuning.footstep_distance_crouch,
		"Kein überfälliger Schritt wird beim Wiederanlaufen nachgeholt")
	Input.action_press("move_forward")
	await _ticks(20)
	_check(player.get_footstep_count() > steps_before, "Neue Bodenbewegung erzeugt weiter Schritte")
	Input.action_release("move_forward")
	Input.action_release("crouch")
	await main.return_to_menu()

	await main.start_world(main.SANDBOX_SCENE_PATH)
	world = main.get_world()
	player = world.get_player()
	world.rotation.y = PI * 0.5
	player.position = Vector3(6.0, 0.0, 8.0)
	await _ticks(10)
	position_before = player.global_position
	var forward: Vector3 = -player.global_transform.basis.z
	Input.action_press("move_forward")
	await _ticks(30)
	Input.action_release("move_forward")
	var displacement: Vector3 = player.global_position - position_before
	displacement.y = 0.0
	_check(displacement.length() > 1.0, "Player bewegt sich im gedrehten Level")
	_check(displacement.normalized().dot(forward) > 0.999,
		"Vorwärtsbewegung folgt der Weltblickrichtung auch bei gedrehtem Level")
	await main.return_to_menu()
	main.queue_free()
	await process_frame
	# Die Audioausgabe arbeitet unabhängig vom Physiktakt; Freigaben abarbeiten.
	await create_timer(0.2).timeout
	print("R1: %d bestanden, %d fehlgeschlagen" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
