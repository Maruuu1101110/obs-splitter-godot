extends Control

var is_paused := false

@onready var quit_confirm: Control = $QuitConfirmation

func _ready() -> void:
	hide()
	process_mode = Node. PROCESS_MODE_ALWAYS
	if quit_confirm: 
		quit_confirm.hide()

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	show()

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	hide()
	if quit_confirm:
		quit_confirm.hide()

# ----- BUTTONS -----

func _on_resume_pressed() -> void:
	resume_game() 

func _on_settings_pressed() -> void:
	var ui_node = get_node("/root/Main/UI")
	ui_node.show_overlay($Settings)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	_restart_level()

func _on_quit_pressed() -> void:
	if quit_confirm: 
		quit_confirm.show()
	else:
		_quit_to_menu()

func _on_quit_confirm_pressed() -> void:
	_quit_to_menu()

func _on_quit_cancel_pressed() -> void:
	if quit_confirm: 
		quit_confirm.hide()

# ----- GAMEPLAY MANAGEMENT -----
func _quit_to_menu() -> void:
	var ingame_hud = $GameHud/HUD
	get_tree().paused = false
	_cleanup_gameplay()
	get_parent().get_parent().hide_hud()
	hide()
	_show_main_menu()

func _restart_level() -> void:
	var gameplay = get_node_or_null("/root/Main/Gameplay")
	if gameplay and gameplay.has_method("restart_current_level"):
		gameplay.restart_current_level()
	hide()

func _cleanup_gameplay() -> void:
	var gameplay = get_node_or_null("/root/Main/Gameplay")
	if gameplay: 
		if gameplay.has_method("cleanup"):
			gameplay.cleanup()
		else:
			for child in gameplay.get_children():
				if child. name != "LevelContainer" and child.name != "PlayerContainer":
					child.queue_free()
				else:
					for subchild in child. get_children():
						subchild. queue_free()

func _show_main_menu() -> void:
	var main_menu = get_node_or_null("/root/Main/UI/MainMenu")
	var gameplay_hud = get_node_or_null("/root/Main/UI/GameHud")
	
	if main_menu: 
		main_menu.show()
	if gameplay_hud:
		gameplay_hud.hide()
