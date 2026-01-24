extends Control

var selected_level: int = 1

func _ready() -> void:
	pass

func set_level(level: int) -> void:
	selected_level = level

func _on_home_pressed() -> void:
	_quit_to_menu()

func _on_garage_pressed() -> void:
	hide()
	var ui_node = get_node("/root/Main/UI")
	ui_node.show_overlay($/root/Main/UI/Garage)
	print("Pressed Garage Button on Level Preview")
	print("Selected level:", selected_level)
	
	

func _on_next_pressed() -> void:
	_cleanup_gameplay()
	print("Pressed Start Button: LEVEL %d" % selected_level)
	
	var gameplay = get_node("/root/Main/Gameplay")
	if gameplay == null:
		push_error("Gameplay node not found!")
		return

	gameplay.selected_level = selected_level + 1
	gameplay.load_level(selected_level + 1)

	# Hide UI overlays
	var ui_node = get_node("/root/Main/UI")
	ui_node.close_overlay(ui_node.get_node("MainMenu"))
	ui_node.close_overlay(ui_node.get_node("LevelSelection"))
	ui_node.close_overlay(self)

func _quit_to_menu() -> void:
	get_tree().paused = false
	_cleanup_gameplay()
	get_parent().get_parent().hide_hud()
	hide()
	_show_main_menu()

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
						
func _show_main_menu() -> void:
	var main_menu = get_node_or_null("/root/Main/UI/MainMenu")
	var gameplay_hud = get_node_or_null("/root/Main/UI/GameHud")
	
	if main_menu: 
		main_menu.show()
	if gameplay_hud:
		gameplay_hud.hide()
