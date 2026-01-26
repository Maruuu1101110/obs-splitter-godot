extends Control

var selected_level: int = 1

func _ready() -> void:
	pass

func set_level(level: int) -> void:
	selected_level = level

func _on_home_pressed() -> void:
	_quit_to_menu()

func _on_restart_pressed() -> void:
	_restart_level()

func _on_next_pressed() -> void:
	_cleanup_gameplay()
	print("Pressed Start Button: LEVEL %d" % selected_level)
	
	var gameplay = get_node("/root/Main/Gameplay")
	if gameplay == null:
		push_error("Gameplay node not found!")
		return
		
	GameState.unlocked_levels += 1
	GameState.save_game()

	gameplay.selected_level = selected_level + 1
	gameplay.load_level(selected_level + 1)
	hide()

func _quit_to_menu() -> void:
	get_tree().paused = false
	_cleanup_gameplay()
	get_tree().change_scene_to_file("res://main.tscn")

# CLEANUP
func _cleanup_gameplay() -> void:
	var gameplay = get_node_or_null("/root/Main/Gameplay")
	if gameplay: 
		if gameplay.has_method("cleanup"):
			gameplay.cleanup()
		else:
			for child in gameplay.get_children():
				if child.name != "LevelContainer" and child.name != "PlayerContainer":
					child.queue_free()
				else:
					for subchild in child.get_children():
						subchild. queue_free()

func _restart_level() -> void:
	var gameplay = get_node_or_null("/root/Main/Gameplay")
	if gameplay and gameplay.has_method("restart_current_level"):
		gameplay.restart_current_level()
	hide()

func _show_main_menu() -> void:
	var main_menu = get_node_or_null("/root/Main/UI/MainMenu")
	var gameplay_hud = get_node_or_null("/root/Main/UI/GameHud")
	
	if main_menu: 
		main_menu.show()
	if gameplay_hud:
		gameplay_hud.hide()
