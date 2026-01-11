extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed():
	# Placeholder for now
	print("Play Button Pressed")
	get_parent().show_overlay($/root/Main/UI/LevelSelection)
	
func _on_settings_pressed():
	get_parent().show_overlay($/root/Main/UI/Settings)
	
func _on_quit_pressed():
	get_tree().quit()
