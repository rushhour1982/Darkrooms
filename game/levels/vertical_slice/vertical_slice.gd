extends Node3D
## Minimaler gemeinsamer Levelvertrag (Architektur §6, §25, §29).
##
## Root-Script jeder von Main geladenen Welt: des späteren Vertical Slice und
## der Systems Sandbox. Main besitzt die Lebensdauer der Welt und ruft
## ausschließlich diesen Vertrag auf:
##   prepare_world()          -> Referenzen und IDs prüfen, Kamera aktivieren, Bereitschaft melden
##   set_gameplay_active()    -> Freigabe/Sperre an die Weltteilnehmer weiterreichen
##
## Ausbaustufe P1-01: Der Player ist ein optionaler Teilnehmer; weitere
## (Creature, Interactables, Puzzles, Trigger) bleiben ausdrücklich optional
## und werden erst mit ihrem jeweiligen Task angebunden. Keine Sonderzweige
## für Testwelten.
##
## P2-02 – stabile IDs (Architektur §24, §27): prepare_world() baut bei
## gesperrtem Gameplay einmal ein lokales ID-Verzeichnis auf, vor Player- und
## Kamerafreigabe und bei jedem Aufbau neu. Identitätsträger sind:
##   - Interactables über ihren Vertrag (persistent_id),
##   - reine Marker3D-Anker über die Metadaten „persistent_id“,
##   - der Player über die feste Akteur-ID <level_id>/player.
## Format: <level_id>/<abschnitt>[/<abschnitt>…], je Abschnitt nur a–z, 0–9
## und _. IDs werden geprüft, nie getrimmt, umbenannt oder neu erzeugt. Jeder
## Fehler (leer, doppelt, Format, Präfix, unerwarteter Träger) wird mit
## Nodepfad gemeldet und sperrt die Freigabe. Traversalmarker tragen keine ID
## (Architektur §24 verlangt sie nicht). Kein globales Verzeichnis, keine
## Suche pro Frame.

## Trenner zwischen Levelpräfix und Objektteil einer ID.
const ID_SEPARATOR: String = "/"

## Metadatenschlüssel reiner Marker3D-Anker; gleicher Name wie der
## Interactable-Vertrag.
const ID_META_KEY: StringName = &"persistent_id"

## Optionale Ankergruppe direkt unter dem Level-Root (Architektur §25); darin
## sind ausschließlich reine Marker3D mit ID erlaubt.
const ANCHORS_NODE_NAME: String = "Anchors"

## Fester Objektteil der Akteur-ID des Players: <level_id>/player.
const PLAYER_ID_NAME: String = "player"

## Name der Welt für die Anzeige in der UI; keine Gameplaywahrheit.
@export var display_name: String = "Welt"

## Dauerhafte Identität dieses Levels und Präfix aller seiner IDs; ein
## Abschnitt aus a–z, 0–9 und _. Pflichtwert, keine Gameplaywahrheit.
@export var level_id: StringName = &""

## Einzige aktive Weltkamera; mit Player dessen Kamera. Pflichtreferenz.
@export var world_camera: Camera3D

## Optionaler Player dieser Welt. Er erhält die Gameplayfreigabe und wird
## beim Aufbau vorbereitet (Konfiguration prüfen, Bewegungshistorie löschen).
@export var player: CharacterBody3D

var _gameplay_active: bool = false

## Lokales ID-Verzeichnis des letzten erfolgreichen Aufbaus (StringName -> Node).
## Bewusst untypisiert: Ein später freigegebener Eintrag darf beim Lesen nicht
## als typisierte Zuweisung scheitern, sondern wird als ungültig erkannt.
var _objects_by_id: Dictionary = {}

## Diagnosen der letzten ID-Prüfung; leer nach erfolgreichem Aufbau.
var _id_errors: PackedStringArray = PackedStringArray()


## Prüft die benötigten Referenzen, bereitet den Player vor und macht die
## Weltkamera zur aktiven Kamera. Gibt false zurück, wenn die Welt nicht
## freigegeben werden darf; Main baut sie dann kontrolliert wieder ab.
## Gameplay bleibt nach dem Aufruf gesperrt.
func prepare_world() -> bool:
	_objects_by_id = {}
	_id_errors = PackedStringArray()
	if not is_instance_valid(world_camera):
		push_error("%s: world_camera ist nicht gesetzt oder ungültig." % name)
		return false
	if not world_camera.is_inside_tree() or not is_ancestor_of(world_camera):
		push_error("%s: world_camera liegt nicht innerhalb dieser Welt." % name)
		return false
	if player != null:
		if not is_ancestor_of(player) or not player.has_method("prepare"):
			push_error("%s: player liegt nicht in dieser Welt oder erfüllt den Playervertrag nicht." % name)
			return false
	if not _build_id_directory():
		return false
	if player != null and not player.prepare():
		_objects_by_id = {}
		return false
	world_camera.make_current()
	_gameplay_active = false
	return true


## Einziger Freigabeauftrag von Main; wird an die vorhandenen Teilnehmer
## weitergereicht. Spätere Teilnehmer werden hier ergänzt.
func set_gameplay_active(active: bool) -> void:
	_gameplay_active = active
	if is_instance_valid(player):
		player.set_gameplay_active(active)


func is_gameplay_active() -> bool:
	return _gameplay_active


func get_display_name() -> String:
	return display_name


func get_world_camera() -> Camera3D:
	return world_camera


func get_player() -> CharacterBody3D:
	return player


func get_level_id() -> StringName:
	return level_id


## Registrierte Instanz zu id aus dem Verzeichnis dieses Aufbaus, sonst null.
## Liefert nie eine freigegebene oder aus dem Level entfernte Instanz; ohne
## erfolgreichen Aufbau ist das Verzeichnis leer. Kein Durchsuchen des Baums.
func get_object_by_id(id: StringName) -> Node:
	var node: Variant = _objects_by_id.get(id)
	if not is_instance_valid(node) or not is_ancestor_of(node):
		return null
	return node


## Alle im letzten erfolgreichen Aufbau registrierten IDs (Diagnose/Tests).
func get_registered_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	ids.assign(_objects_by_id.keys())
	return ids


## Diagnosen der letzten ID-Prüfung (Kopie); leer nach erfolgreichem Aufbau.
func get_id_errors() -> PackedStringArray:
	return _id_errors.duplicate()


## Leer, wenn segment ein gültiger ID-Abschnitt ist (a–z, 0–9, _), sonst der
## Grund. Prüft nur, korrigiert nichts.
static func get_id_segment_error(segment: String) -> String:
	if segment.is_empty():
		return "leerer Abschnitt"
	for index in segment.length():
		var code: int = segment.unicode_at(index)
		var allowed: bool = (code >= 97 and code <= 122) \
			or (code >= 48 and code <= 57) \
			or code == 95
		if not allowed:
			return "unzulässiges Zeichen U+%04X an Position %d (erlaubt: a–z, 0–9, _)" % [code, index]
	return ""


## Leer, wenn id eine gültige ID dieses Levels ist, sonst der Grund mit
## Fehlerart (leer, Formatverstoß, Präfixfehler). Kein trim, kein to_lower.
static func get_id_format_error(id: String, for_level_id: String) -> String:
	if id.is_empty():
		return "leere ID"
	var segments: PackedStringArray = id.split(ID_SEPARATOR, true)
	for index in segments.size():
		var segment_error: String = get_id_segment_error(segments[index])
		if not segment_error.is_empty():
			return "Formatverstoß in Abschnitt %d: %s" % [index + 1, segment_error]
	if segments.size() < 2 or segments[0] != for_level_id:
		return "Präfixfehler: erwartet '%s%s<name>'" % [for_level_id, ID_SEPARATOR]
	return ""


## Baut das lokale ID-Verzeichnis einmal je Aufbau neu auf. Sammelt alle
## Fehler, meldet sie mit Nodepfad und übernimmt das Verzeichnis nur, wenn
## kein Fehler vorliegt; sonst bleibt es leer und die Freigabe gesperrt.
func _build_id_directory() -> bool:
	var directory: Dictionary = {}
	var errors: Array[String] = []
	var level_error: String = get_id_segment_error(String(level_id))
	if not level_error.is_empty():
		errors.append(_id_diagnostic(self, "level_id '%s' ungültig: %s" % [level_id, level_error]))
	else:
		if player != null:
			var player_id: String = String(level_id) + ID_SEPARATOR + PLAYER_ID_NAME
			_register_id(StringName(player_id), player, directory, errors)
		var anchors: Node = get_node_or_null(ANCHORS_NODE_NAME)
		for node in find_children("*", "", true, false):
			_collect_identity(node, anchors, directory, errors)

	_id_errors = PackedStringArray(errors)
	if not errors.is_empty():
		for message in errors:
			push_error(message)
		push_error(_id_diagnostic(self, "ID-Prüfung fehlgeschlagen (%d Fehler); keine Gameplayfreigabe." % errors.size()))
		return false
	_objects_by_id = directory
	return true


## Ordnet einen Node genau einer Identitätsquelle zu und prüft deren Typ.
func _collect_identity(node: Node, anchors: Node, directory: Dictionary, errors: Array[String]) -> void:
	var has_meta_id: bool = node.has_meta(ID_META_KEY)
	var in_anchors: bool = anchors != null and node.get_parent() == anchors
	if node is Interactable:
		if has_meta_id or in_anchors:
			errors.append(_id_diagnostic(node, "unerwarteter Identitätsträger: Interactable mit Metadaten-ID oder in %s." % ANCHORS_NODE_NAME))
			return
		_register_id(node.persistent_id, node, directory, errors)
	elif has_meta_id or in_anchors:
		if not _is_pure_marker(node):
			errors.append(_id_diagnostic(node, "unerwarteter Identitätsträger (%s); Metadaten-IDs nur an reinen Marker3D." % _describe_type(node)))
			return
		if not has_meta_id:
			errors.append(_id_diagnostic(node, "leere ID: Anker ohne Metadaten '%s'." % ID_META_KEY))
			return
		var value: Variant = node.get_meta(ID_META_KEY)
		if typeof(value) != TYPE_STRING_NAME and typeof(value) != TYPE_STRING:
			errors.append(_id_diagnostic(node, "unerwarteter ID-Typ %s; erwartet StringName." % type_string(typeof(value))))
			return
		_register_id(StringName(value), node, directory, errors)
	elif String(ID_META_KEY) in node:
		errors.append(_id_diagnostic(node, "unerwarteter Identitätsträger (%s) mit Eigenschaft '%s' außerhalb des Interactable-Vertrags." % [_describe_type(node), ID_META_KEY]))


## Prüft Format und Eindeutigkeit; bei Duplikat beide Nodepfade, kein Gewinner.
func _register_id(id: StringName, node: Node, directory: Dictionary, errors: Array[String]) -> void:
	var format_error: String = get_id_format_error(String(id), String(level_id))
	if not format_error.is_empty():
		errors.append(_id_diagnostic(node, "ID '%s': %s." % [id, format_error]))
		return
	if directory.has(id):
		errors.append(_id_diagnostic(node, "doppelte ID '%s': '%s' und '%s'." % [id, get_path_to(directory[id]), get_path_to(node)]))
		return
	directory[id] = node


func _is_pure_marker(node: Node) -> bool:
	return node is Marker3D and node.get_script() == null


func _describe_type(node: Node) -> String:
	var script: Script = node.get_script()
	if script != null and not script.resource_path.is_empty():
		return "%s mit %s" % [node.get_class(), script.resource_path.get_file()]
	return node.get_class()


## Einheitliche Diagnose mit Level-ID, Phase und levelrelativem Nodepfad.
func _id_diagnostic(node: Node, issue: String) -> String:
	return "%s [level_id '%s', Aufbau] '%s': %s" % [name, level_id, get_path_to(node), issue]
