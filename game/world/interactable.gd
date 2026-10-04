@tool
class_name Interactable
extends Node3D
## Interactable – kleiner gemeinsamer Interaktionsvertrag (Architektur §9, TDD §8).
##
## Basis für Schalter und spätere Türen, Pickups und Hinweise. Das Objekt
## besitzt seine angebotene Interaktion selbst: Es beschreibt sie ohne
## Zustandsänderung (get_action_info) und führt sie auf Anfrage genau einmal
## aus (request_interaction). Es kennt weder Main, UI noch die Player-Instanz;
## der anfragende Akteur wird nur als Parameter durchgereicht.
##
## Ausbaustufe P2-01: eine primäre Aktion je Ziel, keine Aktionslisten.
## P2-02: persistent_id wird beim Weltaufbau vom Level geprüft und registriert
## (vertical_slice.gd). Ergänzend zeigt der Editor eine Warnung bei fehlender
## ID. @tool dient ausschließlich dieser Warnung; das Script hat keine
## Editor-Laufzeitlogik. Godot vererbt @tool nicht: Abgeleitete Scripts zeigen
## die Warnung erst, wenn sie selbst @tool tragen und ihre eigene Logik
## entsprechend gegen Engine.is_editor_hint() absichern.

## Stabile Weltidentität dieser Instanz (Architektur §24); beim Platzieren
## im Level vergeben, nicht im Prefab.
@export var persistent_id: StringName = &"":
	set(value):
		persistent_id = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Wiedereintrittssperre: Während einer laufenden Aktion wird keine zweite
## angenommen (Architektur §11 „kurzer klarer Änderungsabschnitt“).
var _interaction_running: bool = false


## Aktueller Hinweistext, Verfügbarkeit und interner Ablehnungsgrund; ändert
## keinen Zustand. Der Ablehnungsgrund ist Diagnose, keine Spielermeldung.
func get_action_info() -> Dictionary:
	var reason: String = _get_rejection_reason()
	return {
		"available": reason.is_empty(),
		"text": _get_action_text(),
		"reason": reason,
	}


func is_available() -> bool:
	return _get_rejection_reason().is_empty()


## Erneute lokale Prüfung und genau eine Aktion; true nur bei Ausführung.
func request_interaction(actor: Node3D) -> bool:
	if _interaction_running or not _get_rejection_reason().is_empty():
		return false
	_interaction_running = true
	_perform_interaction(actor)
	_interaction_running = false
	return true


## Editorhinweis (Architektur §24); ersetzt nicht die Prüfung beim Aufbau.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if persistent_id.is_empty():
		warnings.append("persistent_id fehlt: beim Platzieren im Level eine eindeutige ID <level_id>/<name> vergeben (Prefabs bleiben leer).")
	return warnings


## --- Von konkreten Objekten zu überschreiben -------------------------------

## Leerer String = verfügbar; sonst der interne Grund.
func _get_rejection_reason() -> String:
	return ""


## Kurzer Handlungstext; vorläufig generisch (E04), objektspezifisch später.
func _get_action_text() -> String:
	return "Interagieren"


func _perform_interaction(_actor: Node3D) -> void:
	pass
