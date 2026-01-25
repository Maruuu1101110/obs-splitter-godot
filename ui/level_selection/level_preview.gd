extends Control

var selected_level: int = 1

@onready var level_label = $Window/WindowTitle/Label
@onready var preview_image: TextureRect = $PreviewWindow/PreviewImage

func _ready() -> void:
	update_label()
	update_image()

func set_level(level: int) -> void:
	selected_level = level
	update_label()
	update_image()

func update_label() -> void:
	level_label.text = "LEVEL %d" % selected_level

func update_image() -> void:
	var image_path = load("res://ui/level_selection/level_preview_images/level%d-prev.png" % selected_level)
	if image_path == null:
		print("No Image Preview available for this level")
	else:
		preview_image.texture = image_path

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

	gameplay.selected_level = selected_level
	gameplay.load_level(selected_level)

	# Hide UI overlays
	var ui_node = get_node("/root/Main/UI")
	ui_node.close_overlay(ui_node.get_node("MainMenu"))
	ui_node.close_overlay(ui_node.get_node("LevelSelection"))
	ui_node.close_overlay(self)
