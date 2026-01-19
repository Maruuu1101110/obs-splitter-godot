extends Control

var selected_level: int = 1

@onready var level_label = $Window/WindowTitle/Label

func _ready() -> void:
	update_label()

func set_level(level: int) -> void:
	selected_level = level
	update_label()

func update_label() -> void:
	level_label.text = "LEVEL %d" % selected_level

func _on_back_pressed() -> void:
	var ui_node = get_node("/root/Main/UI")
	ui_node.close_overlay(self)

func _on_garage_pressed() -> void:
	var ui_node = get_node("/root/Main/UI")
	ui_node.show_overlay($/root/Main/UI/Garage)
	print("Pressed Garage Button on Level Preview")
	print("Selected level:", selected_level)
	
	

func _on_start_pressed() -> void:
	print("Pressed Start Button: LEVEL %d" % selected_level)

	var gameplay = get_node("/root/Main/Gameplay")
	if gameplay == null:
		push_error("Gameplay node not found!")
		return

	# Tell Gameplay to handle everything
	gameplay.selected_level = selected_level
	gameplay.load_level(selected_level)

	# Hide UI overlays
	var ui_node = get_node("/root/Main/UI")
	ui_node.close_overlay(ui_node.get_node("MainMenu"))
	ui_node.close_overlay(ui_node.get_node("LevelSelection"))
	ui_node.close_overlay(self)
