extends Node3D
## Minimaler gemeinsamer Levelvertrag (Architektur §6, §25, §29).
##
## Root-Script jeder von Main geladenen Welt: des späteren Vertical Slice und
## der Systems Sandbox. Main besitzt die Lebensdauer der Welt und ruft
## ausschließlich diesen Vertrag auf:
##   prepare_world()          -> Referenzen prüfen, Kamera aktivieren, Bereitschaft melden
##   set_gameplay_active()    -> Freigabe/Sperre an die Weltteilnehmer weiterreichen
##
## Ausbaustufe P1-01: Der Player ist ein optionaler Teilnehmer; weitere
## (Creature, Interactables, Puzzles, Trigger) bleiben ausdrücklich optional
## und werden erst mit ihrem jeweiligen Task angebunden. Keine Sonderzweige
## für Testwelten.

## Name der Welt für die Anzeige in der UI; keine Gameplaywahrheit.
@export var display_name: String = "Welt"

## Einzige aktive Weltkamera; mit Player dessen Kamera. Pflichtreferenz.
@export var world_camera: Camera3D

## Optionaler Player dieser Welt. Er erhält die Gameplayfreigabe und wird
## beim Aufbau vorbereitet (Konfiguration prüfen, Bewegungshistorie löschen).
@export var player: CharacterBody3D

var _gameplay_active: bool = false


## Prüft die benötigten Referenzen, bereitet den Player vor und macht die
## Weltkamera zur aktiven Kamera. Gibt false zurück, wenn die Welt nicht
## freigegeben werden darf; Main baut sie dann kontrolliert wieder ab.
## Gameplay bleibt nach dem Aufruf gesperrt.
func prepare_world() -> bool:
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
		if not player.prepare():
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
