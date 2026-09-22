extends CanvasLayer
## GameUI – dauerhafte Oberfläche der Anwendung (Architektur §6, §8, §20, §25).
##
## Besitzt ausschließlich Ansicht, Fokus und Mausdarstellung. Main setzt die
## zulässige Ansicht über show_*(); Bedienwünsche gehen als Signale an Main
## zurück. Die UI hält keine Kopie des Spielfortschritts und besitzt keine
## Gameplaywahrheit: Ob pausiert ist, entscheidet allein Main. Die von Main
## gebundene Welt wird nur gelesen und vor jedem Weltabbau über
## unbind_world() wieder losgelassen.
##
## Ausbaustufe P0-03: Hauptmenü, Weltansicht (HUD), Pausepanel und
## Lade-/Fehlermeldung. P2-01: Interaktionshinweis im HUD, gespeist aus dem
## Zielsignal des Player-Interactors; die UI entscheidet nichts darüber.
## Weitere Paneele entstehen erst mit ihrem Task.

## Bedienwunsch: Systems Sandbox starten (nur Entwicklungsfunktion).
signal sandbox_requested
## Bedienwunsch: pausiertes Spiel bewusst fortsetzen.
signal resume_requested
## Bedienwunsch: aktuelle Welt verlassen und ins Hauptmenü zurückkehren.
signal menu_requested
## Bedienwunsch: Anwendung beenden.
signal quit_requested

## Action, deren Belegung im HUD als Pausenhinweis angezeigt wird.
const PAUSE_ACTION: StringName = &"pause"
## Action, deren Belegung dem Interaktionshinweis vorangestellt wird (E04).
const INTERACT_ACTION: StringName = &"interact"

@onready var _main_menu: Control = $Root/MainMenu
@onready var _sandbox_button: Button = $Root/MainMenu/Layout/SandboxButton
@onready var _quit_button: Button = $Root/MainMenu/Layout/QuitButton
@onready var _hud: Control = $Root/HUD
@onready var _world_title: Label = $Root/HUD/Layout/WorldTitle
@onready var _pause_hint: Label = $Root/HUD/Layout/PauseHint
@onready var _interaction_hint: Label = $Root/HUD/Layout/InteractionHint
@onready var _pause_panel: Control = $Root/PausePanel
@onready var _resume_button: Button = $Root/PausePanel/Layout/ResumeButton
@onready var _pause_menu_button: Button = $Root/PausePanel/Layout/MenuButton
@onready var _pause_quit_button: Button = $Root/PausePanel/Layout/QuitButton
@onready var _status_panel: Control = $Root/LoadingAndErrorPanel
@onready var _status_label: Label = $Root/LoadingAndErrorPanel/Frame/StatusLabel

## Nur lesende Referenz auf die aktuell gebundene Welt; null außerhalb PLAYING/PAUSED.
var _world: Node = null
## Zielsignalquelle der gebundenen Welt (Player-Interactor); nur verbunden, nie gelesen.
var _interactor: Node = null


func _ready() -> void:
	_sandbox_button.pressed.connect(func() -> void: sandbox_requested.emit())
	_quit_button.pressed.connect(func() -> void: quit_requested.emit())
	_resume_button.pressed.connect(func() -> void: resume_requested.emit())
	_pause_menu_button.pressed.connect(func() -> void: menu_requested.emit())
	_pause_quit_button.pressed.connect(func() -> void: quit_requested.emit())
	_hide_all_panels()


## Hauptmenü anzeigen: Zeiger frei, sinnvoller Fokus. Der Sandboxzugang ist
## eine Entwicklungsfunktion und wird nur eingeblendet, wenn Main ihn erlaubt.
func show_menu(sandbox_allowed: bool) -> void:
	_hide_all_panels()
	_sandbox_button.visible = sandbox_allowed
	_main_menu.visible = true
	_set_mouse_free(true)
	if sandbox_allowed:
		_sandbox_button.grab_focus()
	else:
		_quit_button.grab_focus()


## Übergangsansicht während PREPARING; Menü, HUD und Pause sind nicht bedienbar.
func show_preparing(message: String) -> void:
	_hide_all_panels()
	_status_label.text = message
	_status_panel.visible = true
	_set_mouse_free(true)


## Fehlermeldung zusammen mit dem Hauptmenü als Rückweg.
func show_error(message: String, sandbox_allowed: bool) -> void:
	show_menu(sandbox_allowed)
	_status_label.text = message
	_status_panel.visible = true


## Ansicht der aktiven Welt (PLAYING): Maus gefangen, kein UI-Fokus, nur HUD.
func show_world_view() -> void:
	_hide_all_panels()
	_pause_hint.text = "%s – Pause" % _action_key_label(PAUSE_ACTION)
	_hud.visible = true
	get_viewport().gui_release_focus()
	_set_mouse_free(false)


## Pausepanel (PAUSED): Zeiger frei, Fokus auf „Fortsetzen“. Die Welt bleibt
## unter dem Panel sichtbar, damit pausierte Welt und aktive UI unterscheidbar sind.
func show_pause() -> void:
	_hide_all_panels()
	_pause_panel.visible = true
	_set_mouse_free(true)
	_resume_button.grab_focus()


## Von Main nach erfolgreichem Weltaufbau aufgerufen. Liest im selben Schritt
## die Anfangsdaten; hier nur den Anzeigenamen.
func bind_world(world: Node) -> void:
	_world = world
	_world_title.text = world.get_display_name() if world.has_method("get_display_name") else world.name
	_show_interaction_hint("")
	var player: Node = world.get_player() if world.has_method("get_player") else null
	if player != null and player.has_method("get_interactor"):
		_interactor = player.get_interactor()
		_interactor.target_changed.connect(_show_interaction_hint)


## Von Main vor jedem Weltabbau aufgerufen: Referenz und weltbezogene Anzeige
## lösen, damit keine alten Weltzugriffe zurückbleiben.
func unbind_world() -> void:
	if is_instance_valid(_interactor):
		_interactor.target_changed.disconnect(_show_interaction_hint)
	_interactor = null
	_world = null
	_world_title.text = ""
	_show_interaction_hint("")
	_hud.visible = false
	_pause_panel.visible = false


func has_world_bound() -> bool:
	return _world != null


## Hinweis nur bei gültigem Ziel (E04): „<Taste> – <Handlung>“, sonst nichts.
func _show_interaction_hint(action_text: String) -> void:
	_interaction_hint.visible = not action_text.is_empty()
	_interaction_hint.text = "" if action_text.is_empty() else "%s – %s" % [_action_key_label(INTERACT_ACTION), action_text]


func _hide_all_panels() -> void:
	_main_menu.visible = false
	_hud.visible = false
	_pause_panel.visible = false
	_status_panel.visible = false


## Mausdarstellung passend zur Ansicht: frei in Menü/Pause/Übergang, gefangen
## in der aktiven Welt. Die Freigabe der Ansicht selbst kommt von Main.
func _set_mouse_free(free: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if free else Input.MOUSE_MODE_CAPTURED


## Lesbare Belegung einer Action aus der tatsächlichen Input Map (TDD §18).
func _action_key_label(action: StringName) -> String:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if events.is_empty():
		return "Nicht belegt"
	var event: InputEvent = events[0]
	if event is InputEventKey and event.physical_keycode != KEY_NONE:
		# Layoutabhängige Beschriftung nur, wenn der Display-Server ein
		# Tastaturlayout kennt (headless: keines); sonst physischer Tastenname.
		if DisplayServer.keyboard_get_layout_count() > 0:
			return OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode))
		return event.as_text_physical_keycode()
	return event.as_text()
