extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_home_pressed() -> void:
	GameState.game_over = false
	hide()
	_quit_to_menu()


func _on_restart_pressed() -> void:
	GameState.game_over = false
	hide()
	_restart_level()

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
