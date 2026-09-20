extends CanvasLayer
## GameUI – dauerhafte Oberfläche der Anwendung (Architektur §6, §20, §25).
##
## Besitzt ausschließlich Ansicht und Fokus. Main setzt die zulässige Ansicht
## über show_*(); Bedienwünsche gehen als Signale an Main zurück. Die UI hält
## keine Kopie des Spielfortschritts; die von Main gebundene Welt wird nur
## gelesen und vor jedem Weltabbau über unbind_world() wieder losgelassen.
##
## Ausbaustufe P0-02: Hauptmenü, Weltansicht (HUD) und Lade-/Fehlermeldung.
## Weitere Paneele entstehen erst mit ihrem jeweiligen Task.

## Bedienwunsch: Systems Sandbox starten (nur Entwicklungsfunktion).
signal sandbox_requested
## Bedienwunsch: aktuelle Welt verlassen und ins Hauptmenü zurückkehren.
signal menu_requested
## Bedienwunsch: Anwendung beenden.
signal quit_requested

@onready var _main_menu: Control = $Root/MainMenu
@onready var _sandbox_button: Button = $Root/MainMenu/Layout/SandboxButton
@onready var _quit_button: Button = $Root/MainMenu/Layout/QuitButton
@onready var _hud: Control = $Root/HUD
@onready var _world_title: Label = $Root/HUD/Layout/WorldTitle
@onready var _menu_button: Button = $Root/HUD/Layout/MenuButton
@onready var _status_panel: Control = $Root/LoadingAndErrorPanel
@onready var _status_label: Label = $Root/LoadingAndErrorPanel/Frame/StatusLabel

## Nur lesende Referenz auf die aktuell gebundene Welt; null außerhalb PLAYING.
var _world: Node = null


func _ready() -> void:
	_sandbox_button.pressed.connect(func() -> void: sandbox_requested.emit())
	_menu_button.pressed.connect(func() -> void: menu_requested.emit())
	_quit_button.pressed.connect(func() -> void: quit_requested.emit())
	_hide_all_panels()


## Hauptmenü anzeigen. Der Sandboxzugang ist eine Entwicklungsfunktion und
## wird nur eingeblendet, wenn Main ihn erlaubt.
func show_menu(sandbox_allowed: bool) -> void:
	_hide_all_panels()
	_sandbox_button.visible = sandbox_allowed
	_main_menu.visible = true
	_quit_button.grab_focus()


## Übergangsansicht während PREPARING; Menü und HUD sind nicht bedienbar.
func show_preparing(message: String) -> void:
	_hide_all_panels()
	_status_label.text = message
	_status_panel.visible = true


## Fehlermeldung zusammen mit dem Hauptmenü als Rückweg.
func show_error(message: String, sandbox_allowed: bool) -> void:
	show_menu(sandbox_allowed)
	_status_label.text = message
	_status_panel.visible = true


## Ansicht der aktiven Welt (PLAYING).
func show_world_view() -> void:
	_hide_all_panels()
	_hud.visible = true
	_menu_button.grab_focus()


## Von Main nach erfolgreichem Weltaufbau aufgerufen. Liest im selben Schritt
## die Anfangsdaten; hier nur den Anzeigenamen.
func bind_world(world: Node) -> void:
	_world = world
	_world_title.text = world.get_display_name() if world.has_method("get_display_name") else world.name


## Von Main vor jedem Weltabbau aufgerufen: Referenz und weltbezogene Anzeige
## lösen, damit keine alten Weltzugriffe zurückbleiben.
func unbind_world() -> void:
	_world = null
	_world_title.text = ""
	_hud.visible = false


func has_world_bound() -> bool:
	return _world != null


func _hide_all_panels() -> void:
	_main_menu.visible = false
	_hud.visible = false
	_status_panel.visible = false
