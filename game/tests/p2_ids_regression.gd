extends SceneTree
## P2-02: stabile IDs und Levelvalidierung, ohne Framework.
## Godot --headless --path game --script res://tests/p2_ids_regression.gd
##
## Prüft die echte Implementierung (vertical_slice.gd, interactable.gd, Main):
## gültige Sandbox, leere/falsche/doppelte IDs, Präfixfehler, unerwartete
## Identitätsträger, Identität nach Rename/Umordnung, get_object_by_id,
## drei Weltwechsel und den Main-Fehlerpfad. Ungültige Welten entstehen nur
## im Speicher bzw. als temporäre Datei unter user://tests/; die versionierte
## Sandbox wird nicht verändert. Alle Fehlermeldungen werden über einen
## Logger erfasst: Erwartete Diagnosen werden ausdrücklich geprüft, jeder
## andere Fehler zählt als Testfehler.

const SANDBOX_PATH: String = "res://tests/systems_sandbox.tscn"
const SWITCH_SCENE_PATH: String = "res://world/switch/switch.tscn"
const LEVEL_SCRIPT_PATH: String = "res://levels/vertical_slice/vertical_slice.gd"
const TEST_DIR: String = "user://tests"
const INVALID_WORLD_PATH: String = "user://tests/p2_02_duplicate_world.tscn"

## Kennzeichen jeder ID-Diagnose des Levels (Level-ID und Phase).
const ID_DIAGNOSTIC_MARK: String = "[level_id '"
const ID_SUMMARY_MARK: String = "ID-Prüfung fehlgeschlagen"

const EXPECTED_SANDBOX_IDS: Array[StringName] = [
	&"sandbox/player",
	&"sandbox/switch_front",
	&"sandbox/switch_back",
	&"sandbox/switch_covered",
	&"sandbox/anchor_start",
	&"sandbox/anchor_interaction_test",
]


## Lokale Exit-Positionen der Traversalmarker in der Sandbox (unverändert aus P1-03).
const TRAVERSAL_EXITS: Dictionary = {
	"VaultMarker": Vector3(0, 0.8, -0.5),
	"HighMarker": Vector3(0, 1.3, -0.5),
	"BlockedMarker": Vector3(0, 0.8, -0.5),
}


## Erfasst Fehler (keine Warnungen) aller Quellen; threadsicher.
class ErrorCapture extends Logger:
	var _mutex: Mutex = Mutex.new()
	var _errors: Array[String] = []

	func _log_error(_function: String, _file: String, _line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtrace: Array[ScriptBacktrace]) -> void:
		if error_type == Logger.ERROR_TYPE_WARNING:
			return
		_mutex.lock()
		_errors.append((code + " " + rationale).strip_edges())
		_mutex.unlock()

	func _log_message(_message: String, _error: bool) -> void:
		pass

	func take() -> Array[String]:
		_mutex.lock()
		var taken: Array[String] = _errors.duplicate()
		_errors.clear()
		_mutex.unlock()
		return taken


var _passed: int = 0
var _failed: int = 0
var _capture: ErrorCapture = ErrorCapture.new()
var _host: Node3D = null


func _initialize() -> void:
	OS.add_logger(_capture)
	_run.call_deferred()


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
	print("PASS " if condition else "FAIL ", label)


## Jeder bis hierher aufgetretene Fehler ist unerwartet.
func _check_no_errors(label: String) -> void:
	var errors: Array[String] = _capture.take()
	for message in errors:
		print("  unerwartet: ", message)
	_check(errors.is_empty(), label + ": keine unerwarteten Fehler")


func _contains_all(messages: Array, parts: Array[String]) -> bool:
	for part in parts:
		var found: bool = false
		for message in messages:
			if String(message).contains(part):
				found = true
				break
		if not found:
			print("  nicht gefunden: ", part)
			return false
	return true


func _run() -> void:
	_host = Node3D.new()
	_host.name = "DetachedHost"
	root.add_child(_host)
	await process_frame
	_check_no_errors("Start")

	_test_format_rules()
	await _test_valid_sandbox()
	await _test_invalid_worlds()
	await _test_rename_and_reorder()
	await _test_lookup_lifetime()
	await _test_main_world_changes()

	_host.queue_free()
	await process_frame
	# Die Audioausgabe arbeitet unabhängig vom Physiktakt; Freigaben abarbeiten.
	await create_timer(0.2).timeout
	_check_no_errors("Ende")
	OS.remove_logger(_capture)
	print("P2-02: %d bestanden, %d fehlgeschlagen" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


# --- Reine Prüfregeln ---------------------------------------------------------

func _test_format_rules() -> void:
	var level: GDScript = load(LEVEL_SCRIPT_PATH)
	_check(level.get_id_format_error("sandbox/switch_front", "sandbox").is_empty(), "Format: gültige ID")
	_check(level.get_id_format_error("sandbox/room_1/switch_2", "sandbox").is_empty(), "Format: mehrere Abschnitte gültig")
	_check(level.get_id_format_error("", "sandbox") == "leere ID", "Format: leer")
	_check(level.get_id_format_error("sandbox/Switch", "sandbox").begins_with("Formatverstoß"), "Format: Großbuchstabe")
	_check(level.get_id_format_error("sandbox/switch front", "sandbox").contains("U+0020"), "Format: Leerzeichen")
	_check(level.get_id_format_error(" sandbox/switch", "sandbox").begins_with("Formatverstoß"), "Format: führendes Leerzeichen wird nicht getrimmt")
	_check(level.get_id_format_error("sandbox/switch\t", "sandbox").begins_with("Formatverstoß"), "Format: Tabulator am Ende wird nicht getrimmt")
	_check(level.get_id_format_error("sandbox/schalter_ä", "sandbox").contains("U+00E4"), "Format: Nicht-ASCII")
	_check(level.get_id_format_error("sandbox/switch-1", "sandbox").begins_with("Formatverstoß"), "Format: Bindestrich")
	_check(level.get_id_format_error("sandbox//switch", "sandbox").contains("leerer Abschnitt"), "Format: leerer Abschnitt")
	_check(level.get_id_format_error("sandbox/", "sandbox").contains("leerer Abschnitt"), "Format: abschließender Trenner")
	_check(level.get_id_format_error("sandbox", "sandbox").begins_with("Präfixfehler"), "Präfix: nur Level-ID")
	_check(level.get_id_format_error("other/switch", "sandbox").begins_with("Präfixfehler"), "Präfix: fremdes Level")
	_check(level.get_id_format_error("sandboxx/switch", "sandbox").begins_with("Präfixfehler"), "Präfix: ähnliches Level")
	_check(level.get_id_format_error("switch/sandbox", "sandbox").begins_with("Präfixfehler"), "Präfix: Level-ID nicht vorn")
	_check(level.get_id_segment_error("sandbox").is_empty(), "Level-ID: gültig")
	_check(not level.get_id_segment_error("Sandbox").is_empty(), "Level-ID: Großbuchstabe ungültig")
	_check(not level.get_id_segment_error("").is_empty(), "Level-ID: leer ungültig")
	_check_no_errors("Prüfregeln")


# --- Detachierte Welten (ohne Main) -------------------------------------------

func _new_sandbox() -> Node3D:
	return (load(SANDBOX_PATH) as PackedScene).instantiate()


func _prepare(world: Node3D) -> bool:
	_host.add_child(world)
	return world.prepare_world()


func _dispose(world: Node3D) -> void:
	if world.get_parent() != null:
		world.get_parent().remove_child(world)
	world.free()
	await process_frame


func _test_valid_sandbox() -> void:
	var world: Node3D = _new_sandbox()
	_check(world.get_level_id() == &"sandbox", "Sandbox: exportierte level_id")
	_check(_prepare(world), "Sandbox: gültige IDs geben Aufbau frei")
	_check(world.get_id_errors().is_empty(), "Sandbox: keine Diagnosen")
	var ids: Array[StringName] = world.get_registered_ids()
	_check(ids.size() == EXPECTED_SANDBOX_IDS.size(), "Sandbox: genau %d IDs registriert" % EXPECTED_SANDBOX_IDS.size())
	for id in EXPECTED_SANDBOX_IDS:
		_check(ids.has(id), "Sandbox: %s registriert" % id)
	_check(world.get_object_by_id(&"sandbox/player") == world.get_player(), "Lookup: feste Player-Akteur-ID")
	_check(world.get_object_by_id(&"sandbox/switch_front") == world.get_node("World/Interaction/SwitchFront"), "Lookup: Interactable")
	_check(world.get_object_by_id(&"sandbox/anchor_start") == world.get_node("Anchors/Start"), "Lookup: Marker3D-Anker")
	_check(world.get_object_by_id("sandbox/switch_back") == world.get_node("World/Interaction/SwitchBack"), "Lookup: String-Argument")
	_check(world.get_object_by_id(&"sandbox/unknown") == null, "Lookup: unbekannte ID liefert null")
	_check(world.get_object_by_id(&"") == null, "Lookup: leere ID liefert null")
	_check(not world.is_gameplay_active(), "Sandbox: Gameplay nach Aufbau weiter gesperrt")
	_check_traversal_exits(world)
	await _dispose(world)
	_check_no_errors("Gültige Sandbox")


## Exit-Overrides der instanziierten Traversalmarker (P1-03-Werte). Sie liegen
## als editierbare Kinder in der Sandbox; ohne [editable] verwirft der Editor
## sie beim Speichern und HighMarker fiele auf die Prefab-Höhe 0,8 m zurück.
func _check_traversal_exits(world: Node3D) -> void:
	for marker_name in TRAVERSAL_EXITS:
		var marker: Node = world.get_node("World/" + marker_name)
		var expected: Vector3 = TRAVERSAL_EXITS[marker_name]
		var exit: Node3D = marker.get_node("Exit")
		_check(exit.position.is_equal_approx(expected), "Traversal %s: Exit-Override %s" % [marker_name, expected])
		_check(is_equal_approx(marker.get_height(), expected.y), "Traversal %s: Zielhöhe %.1f m" % [marker_name, expected.y])
		_check(marker.get_exit_position().is_equal_approx(marker.global_position + expected),
			"Traversal %s: Exit-Zielposition" % marker_name)


## Baut eine veränderte Sandbox auf und prüft Ablehnung, leeres Verzeichnis,
## Diagnoseinhalt sowie die tatsächlich gemeldeten Fehler.
func _expect_invalid(label: String, mutate: Callable, expected: Array[String]) -> void:
	var world: Node3D = _new_sandbox()
	mutate.call(world)
	var prepared: bool = _prepare(world)
	var diagnostics: PackedStringArray = world.get_id_errors()
	var logged: Array[String] = _capture.take()
	_check(not prepared, label + ": Aufbau abgelehnt")
	_check(world.get_registered_ids().is_empty(), label + ": kein Verzeichnis")
	_check(world.get_object_by_id(&"sandbox/switch_front") == null, label + ": Lookup liefert null")
	_check(not world.is_gameplay_active(), label + ": Gameplay gesperrt")
	_check(_contains_all(Array(diagnostics), expected), label + ": Diagnose enthält %s" % [expected])
	_check(_contains_all(logged, expected), label + ": Fehler gemeldet")
	_check(_contains_all(logged, [ID_SUMMARY_MARK]), label + ": Zusammenfassung gemeldet")
	_check(logged.size() == diagnostics.size() + 1, label + ": je Diagnose genau ein Fehler plus Zusammenfassung")
	var unexpected: Array[String] = []
	for message in logged:
		if not message.contains(ID_DIAGNOSTIC_MARK):
			unexpected.append(message)
	for message in unexpected:
		print("  unerwartet: ", message)
	_check(unexpected.is_empty(), label + ": keine unerwarteten Fehler")
	await _dispose(world)
	_check_no_errors(label + " (Abbau)")


func _test_invalid_worlds() -> void:
	await _expect_invalid("Leere ID", _mutate_empty_id,
		["'World/Interaction/SwitchCovered'", "leere ID"])
	await _expect_invalid("Großbuchstabe", _mutate_uppercase,
		["'World/Interaction/SwitchFront'", "Formatverstoß", "U+0053"])
	await _expect_invalid("Leerzeichen ohne Trim", _mutate_whitespace,
		["'World/Interaction/SwitchFront'", "' sandbox/switch_front'", "'World/Interaction/SwitchBack'", "'sandbox/switch_back '", "U+0020"])
	await _expect_invalid("Nicht-ASCII", _mutate_non_ascii,
		["'World/Interaction/SwitchCovered'", "U+00E4"])
	await _expect_invalid("Leerer Abschnitt", _mutate_empty_segment,
		["'World/Interaction/SwitchBack'", "leerer Abschnitt"])
	await _expect_invalid("Präfix fremd", _mutate_foreign_prefix,
		["'World/Interaction/SwitchBack'", "Präfixfehler"])
	await _expect_invalid("Präfix fehlt", _mutate_missing_prefix,
		["'Anchors/Start'", "Präfixfehler"])
	await _expect_invalid("Duplikat Interactable", _mutate_duplicate_switch,
		["doppelte ID 'sandbox/switch_front'", "'World/Interaction/SwitchFront' und 'World/Interaction/SwitchDuplicate'"])
	await _expect_invalid("Duplikat Anker/Interactable", _mutate_duplicate_anchor,
		["doppelte ID 'sandbox/switch_back'", "'World/Interaction/SwitchBack' und 'Anchors/InteractionTest'"])
	await _expect_invalid("Duplikat Player-ID", _mutate_duplicate_player,
		["doppelte ID 'sandbox/player'", "'Actors/Player' und 'Anchors/Start'"])
	await _expect_invalid("Dreifach-ID", _mutate_triple,
		["'World/Interaction/SwitchFront' und 'World/Interaction/SwitchBack'", "'World/Interaction/SwitchFront' und 'World/Interaction/SwitchCovered'"])
	await _expect_invalid("Metadaten an Nicht-Marker", _mutate_meta_on_node3d,
		["'World/Probe'", "unerwarteter Identitätsträger (Node3D)"])
	await _expect_invalid("Metadaten an Interactable", _mutate_meta_on_interactable,
		["'World/Interaction/SwitchFront'", "unerwarteter Identitätsträger: Interactable"])
	await _expect_invalid("Fremder Typ in Anchors", _mutate_foreign_anchor_type,
		["'Anchors/Probe'", "unerwarteter Identitätsträger (Node3D)"])
	await _expect_invalid("Interactable in Anchors", _mutate_interactable_in_anchors,
		["'Anchors/ProbeSwitch'", "unerwarteter Identitätsträger: Interactable"])
	await _expect_invalid("Marker3D mit Script", _mutate_scripted_marker,
		["'Anchors/Start'", "unerwarteter Identitätsträger (Marker3D)"])
	await _expect_invalid("Fremde persistent_id-Eigenschaft", _mutate_foreign_property,
		["'World/Probe'", "außerhalb des Interactable-Vertrags"])
	await _expect_invalid("Anker ohne ID", _mutate_anchor_without_id,
		["'Anchors/Probe'", "leere ID: Anker ohne Metadaten"])
	await _expect_invalid("Leere Anker-ID", _mutate_anchor_empty_id,
		["'Anchors/Start'", "leere ID"])
	await _expect_invalid("ID-Typ", _mutate_meta_wrong_type,
		["'Anchors/Start'", "unerwarteter ID-Typ int"])
	await _expect_invalid("level_id leer", _mutate_level_id_empty,
		["level_id '' ungültig"])
	await _expect_invalid("level_id Format", _mutate_level_id_format,
		["level_id 'Sandbox' ungültig", "U+0053"])
	await _expect_invalid("Mehrere Fehler", _mutate_multiple,
		["'World/Interaction/SwitchCovered'", "leere ID", "'Anchors/Start'", "Präfixfehler"])

	# Keine stille Reparatur: Der fehlerhafte Wert bleibt unverändert stehen.
	var world: Node3D = _new_sandbox()
	_mutate_whitespace(world)
	_prepare(world)
	_capture.take()
	_check(world.get_node("World/Interaction/SwitchFront").persistent_id == &" sandbox/switch_front", "Kein Trim: ID unverändert")
	_check(world.get_node("Anchors/Start").get_meta(&"persistent_id") == &"sandbox/anchor_start", "Kein Trim: Anker unverändert")
	await _dispose(world)
	_check_no_errors("Keine stille Reparatur")


func _mutate_empty_id(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchCovered").persistent_id = &""


func _mutate_uppercase(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchFront").persistent_id = &"sandbox/Switch_front"


func _mutate_whitespace(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchFront").persistent_id = &" sandbox/switch_front"
	world.get_node("World/Interaction/SwitchBack").persistent_id = &"sandbox/switch_back "


func _mutate_non_ascii(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchCovered").persistent_id = &"sandbox/schalter_ä"


func _mutate_empty_segment(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchBack").persistent_id = &"sandbox//switch_back"


func _mutate_foreign_prefix(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchBack").persistent_id = &"other/switch_back"


func _mutate_missing_prefix(world: Node3D) -> void:
	world.get_node("Anchors/Start").set_meta(&"persistent_id", &"anchor_start")


func _mutate_duplicate_switch(world: Node3D) -> void:
	var duplicate: Node3D = (load(SWITCH_SCENE_PATH) as PackedScene).instantiate()
	duplicate.name = "SwitchDuplicate"
	duplicate.persistent_id = &"sandbox/switch_front"
	world.get_node("World/Interaction").add_child(duplicate)


func _mutate_duplicate_anchor(world: Node3D) -> void:
	world.get_node("Anchors/InteractionTest").set_meta(&"persistent_id", &"sandbox/switch_back")


func _mutate_duplicate_player(world: Node3D) -> void:
	world.get_node("Anchors/Start").set_meta(&"persistent_id", &"sandbox/player")


func _mutate_triple(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchBack").persistent_id = &"sandbox/switch_front"
	world.get_node("World/Interaction/SwitchCovered").persistent_id = &"sandbox/switch_front"


func _mutate_meta_on_node3d(world: Node3D) -> void:
	var probe: Node3D = Node3D.new()
	probe.name = "Probe"
	probe.set_meta(&"persistent_id", &"sandbox/probe")
	world.get_node("World").add_child(probe)


func _mutate_meta_on_interactable(world: Node3D) -> void:
	world.get_node("World/Interaction/SwitchFront").set_meta(&"persistent_id", &"sandbox/switch_meta")


func _mutate_foreign_anchor_type(world: Node3D) -> void:
	var probe: Node3D = Node3D.new()
	probe.name = "Probe"
	world.get_node("Anchors").add_child(probe)


func _mutate_interactable_in_anchors(world: Node3D) -> void:
	var probe: Node3D = (load(SWITCH_SCENE_PATH) as PackedScene).instantiate()
	probe.name = "ProbeSwitch"
	probe.persistent_id = &"sandbox/probe_switch"
	world.get_node("Anchors").add_child(probe)


func _mutate_scripted_marker(world: Node3D) -> void:
	var script: GDScript = GDScript.new()
	script.source_code = "extends Marker3D\n"
	script.reload()
	world.get_node("Anchors/Start").set_script(script)


func _mutate_foreign_property(world: Node3D) -> void:
	var script: GDScript = GDScript.new()
	script.source_code = "extends Node3D\nvar persistent_id: StringName = &\"sandbox/probe\"\n"
	script.reload()
	var probe: Node3D = Node3D.new()
	probe.name = "Probe"
	probe.set_script(script)
	world.get_node("World").add_child(probe)


func _mutate_anchor_without_id(world: Node3D) -> void:
	var probe: Marker3D = Marker3D.new()
	probe.name = "Probe"
	world.get_node("Anchors").add_child(probe)


func _mutate_anchor_empty_id(world: Node3D) -> void:
	world.get_node("Anchors/Start").set_meta(&"persistent_id", &"")


func _mutate_meta_wrong_type(world: Node3D) -> void:
	world.get_node("Anchors/Start").set_meta(&"persistent_id", 7)


func _mutate_level_id_empty(world: Node3D) -> void:
	world.level_id = &""


func _mutate_level_id_format(world: Node3D) -> void:
	world.level_id = &"Sandbox"


func _mutate_multiple(world: Node3D) -> void:
	_mutate_empty_id(world)
	_mutate_missing_prefix(world)


# --- Identität nach Rename/Umordnung -------------------------------------------

func _test_rename_and_reorder() -> void:
	var reference: Node3D = _new_sandbox()
	_check(_prepare(reference), "Referenzaufbau")
	var reference_ids: Array[StringName] = reference.get_registered_ids()
	await _dispose(reference)

	var world: Node3D = _new_sandbox()
	var switch_front: Node = world.get_node("World/Interaction/SwitchFront")
	var anchor_start: Node = world.get_node("Anchors/Start")
	switch_front.name = "RenamedSwitch"
	switch_front.get_parent().move_child(switch_front, 0)
	anchor_start.name = "RenamedAnchor"
	anchor_start.get_parent().move_child(anchor_start, -1)
	world.move_child(world.get_node("Anchors"), 0)
	_check(_prepare(world), "Rename/Umordnung: Aufbau gültig")
	var ids: Array[StringName] = world.get_registered_ids()
	ids.sort()
	reference_ids.sort()
	_check(ids == reference_ids, "Rename/Umordnung: identische ID-Menge")
	_check(world.get_object_by_id(&"sandbox/switch_front") == switch_front, "Rename/Umordnung: Schalter-ID unverändert")
	_check(world.get_object_by_id(&"sandbox/anchor_start") == anchor_start, "Rename/Umordnung: Anker-ID unverändert")
	_check(switch_front.persistent_id == &"sandbox/switch_front", "Rename/Umordnung: keine Neuvergabe")
	await _dispose(world)
	_check_no_errors("Rename/Umordnung")


# --- Lebensdauer des Verzeichnisses --------------------------------------------

func _test_lookup_lifetime() -> void:
	var world: Node3D = _new_sandbox()
	_check(_prepare(world), "Lebensdauer: Aufbau gültig")

	var switch_back: Node = world.get_node("World/Interaction/SwitchBack")
	switch_back.get_parent().remove_child(switch_back)
	switch_back.free()
	_check(world.get_object_by_id(&"sandbox/switch_back") == null, "Lebensdauer: freigegebener Eintrag liefert null")

	var switch_covered: Node = world.get_node("World/Interaction/SwitchCovered")
	switch_covered.reparent(_host)
	_check(world.get_object_by_id(&"sandbox/switch_covered") == null, "Lebensdauer: aus dem Level entfernter Eintrag liefert null")
	switch_covered.queue_free()

	# Neuaufbau derselben Instanz: Fehler leert das Verzeichnis vollständig.
	var duplicate: Node3D = (load(SWITCH_SCENE_PATH) as PackedScene).instantiate()
	duplicate.name = "SwitchDuplicate"
	duplicate.persistent_id = &"sandbox/switch_front"
	world.get_node("World/Interaction").add_child(duplicate)
	_check(not world.prepare_world(), "Neuaufbau: Duplikat abgelehnt")
	var logged: Array[String] = _capture.take()
	_check(_contains_all(logged, ["doppelte ID 'sandbox/switch_front'", ID_SUMMARY_MARK]), "Neuaufbau: Duplikat gemeldet")
	_check(world.get_registered_ids().is_empty(), "Neuaufbau: kein altes Verzeichnis nach Fehler")
	_check(world.get_object_by_id(&"sandbox/player") == null, "Neuaufbau: keine alte Referenz nach Fehler")

	world.get_node("World/Interaction").remove_child(duplicate)
	duplicate.free()
	_check(world.prepare_world(), "Neuaufbau: nach Korrektur wieder gültig")
	var ids: Array[StringName] = world.get_registered_ids()
	_check(ids.size() == 4 and not ids.has(&"sandbox/switch_back") and not ids.has(&"sandbox/switch_covered"),
		"Neuaufbau: Verzeichnis spiegelt aktuellen Baum")
	await _dispose(world)
	_check_no_errors("Lebensdauer")


# --- Main: Weltwechsel und Fehlerpfad ------------------------------------------

func _test_main_world_changes() -> void:
	var main: Node = load("res://app/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var world_host: Node = main.get_node("WorldHost")

	# Alte Objekte nur über is_instance_valid bzw. ihre Instanz-ID vergleichen.
	var previous_world: Variant = null
	var previous_world_id: int = 0
	var previous_switch: Variant = null
	for change in range(3):
		var label: String = "Weltwechsel %d" % (change + 1)
		await main.start_world(main.SANDBOX_SCENE_PATH)
		var world: Node3D = main.get_world()
		_check(main.get_phase() == main.Phase.PLAYING, label + ": PLAYING")
		_check(world_host.get_child_count() == 1, label + ": genau eine Welt")
		_check(world != null and world.get_instance_id() != previous_world_id, label + ": neue Weltinstanz")
		if previous_world != null:
			_check(not is_instance_valid(previous_world), label + ": alte Welt freigegeben")
			_check(not is_instance_valid(previous_switch), label + ": alter Schalter freigegeben")
		_check(world.get_registered_ids().size() == EXPECTED_SANDBOX_IDS.size(), label + ": Verzeichnis neu, ohne Altlasten")
		var switch_front: Node = world.get_object_by_id(&"sandbox/switch_front")
		_check(switch_front != null and world.is_ancestor_of(switch_front), label + ": Lookup liefert Objekt der aktuellen Welt")
		_check(switch_front == world.get_node("World/Interaction/SwitchFront"), label + ": Lookup liefert richtigen Schalter")
		_check(world.get_object_by_id(&"sandbox/player") == world.get_player(), label + ": Player der aktuellen Welt")
		previous_world = world
		previous_world_id = world.get_instance_id()
		previous_switch = switch_front
	_check_no_errors("Drei Weltwechsel")

	# Ungültige Welt nur als temporäre Testdatei unter user://tests/.
	_check(_write_duplicate_world() == OK, "Fehlerpfad: ungültige Testwelt gespeichert")
	_check_no_errors("Fehlerpfad: Testwelt erzeugen")
	var entered: Array = []
	var on_entered: Callable = func(node: Node) -> void: entered.append(node)
	world_host.child_entered_tree.connect(on_entered)
	await main.start_world(INVALID_WORLD_PATH)
	world_host.child_entered_tree.disconnect(on_entered)
	var logged: Array[String] = _capture.take()
	_check(main.get_phase() == main.Phase.MENU, "Fehlerpfad: Main im Menü")
	_check(not paused, "Fehlerpfad: Engine nicht pausiert")
	_check(main.get_world() == null, "Fehlerpfad: keine Weltreferenz")
	_check(world_host.get_child_count() == 0, "Fehlerpfad: WorldHost leer")
	_check(not main.get_node("GameUI").has_world_bound(), "Fehlerpfad: UI ohne Weltbindung")
	_check(not is_instance_valid(previous_world), "Fehlerpfad: vorherige Welt freigegeben")
	_check(entered.size() == 1, "Fehlerpfad: ungültige Welt wurde genau einmal eingehängt")
	_check(entered.size() == 1 and not is_instance_valid(entered[0]), "Fehlerpfad: ungültige Welt vollständig freigegeben")
	_check(main.get_node("GameUI/Root/LoadingAndErrorPanel").visible, "Fehlerpfad: Fehlermeldung im Menü sichtbar")
	_check(String(main.get_node("GameUI/Root/LoadingAndErrorPanel/Frame/StatusLabel").text).contains("Welt konnte nicht vorbereitet werden"),
		"Fehlerpfad: Fehlermeldung nennt Abbruch")
	_check(_contains_all(logged, [
		"doppelte ID 'sandbox/switch_front'",
		"'World/Interaction/SwitchFront' und 'World/Interaction/SwitchDuplicate'",
		ID_SUMMARY_MARK,
		"Main: Welt konnte nicht vorbereitet werden",
	]), "Fehlerpfad: Diagnose mit beiden Pfaden und Main-Abbruch gemeldet")
	var unexpected: Array[String] = []
	for message in logged:
		if not message.contains(ID_DIAGNOSTIC_MARK) and not message.contains("Main: Welt konnte nicht vorbereitet werden"):
			unexpected.append(message)
	for message in unexpected:
		print("  unerwartet: ", message)
	_check(unexpected.is_empty(), "Fehlerpfad: keine unerwarteten Fehler")

	# Nach dem Fehler startet eine gültige Welt wieder normal.
	await main.start_world(main.SANDBOX_SCENE_PATH)
	_check(main.get_phase() == main.Phase.PLAYING, "Nach Fehler: gültige Welt startet")
	_check(main.get_world().get_registered_ids().size() == EXPECTED_SANDBOX_IDS.size(), "Nach Fehler: vollständiges Verzeichnis")
	await main.return_to_menu()
	_check(main.get_world() == null and world_host.get_child_count() == 0, "Nach Fehler: Rückkehr ins Menü ohne Welt")
	main.queue_free()
	await process_frame
	DirAccess.remove_absolute(INVALID_WORLD_PATH)
	_check_no_errors("Main")


## Speichert eine Sandboxkopie mit doppelter Schalter-ID; Original unverändert.
func _write_duplicate_world() -> Error:
	var world: Node3D = _new_sandbox()
	var duplicate: Node3D = (load(SWITCH_SCENE_PATH) as PackedScene).instantiate()
	duplicate.name = "SwitchDuplicate"
	duplicate.persistent_id = &"sandbox/switch_front"
	world.get_node("World/Interaction").add_child(duplicate)
	duplicate.owner = world
	world.scene_file_path = ""
	var packed: PackedScene = PackedScene.new()
	var result: Error = packed.pack(world)
	world.free()
	if result != OK:
		return result
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	return ResourceSaver.save(packed, INVALID_WORLD_PATH)
