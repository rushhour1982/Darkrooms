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
## persistent_id wird erst in P2-02 vom Level validiert.

## Stabile Weltidentität dieser Instanz (Architektur §24); beim Platzieren
## im Level vergeben, nicht im Prefab.
@export var persistent_id: StringName = &""

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


## --- Von konkreten Objekten zu überschreiben -------------------------------

## Leerer String = verfügbar; sonst der interne Grund.
func _get_rejection_reason() -> String:
	return ""


## Kurzer Handlungstext; vorläufig generisch (E04), objektspezifisch später.
func _get_action_text() -> String:
	return "Interagieren"


func _perform_interaction(_actor: Node3D) -> void:
	pass
