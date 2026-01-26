extends Control

var selected_level: int = 1

@onready var level_label = $Window/WindowTitle/Label
@onready var level_name_label: Label = $LevelInfo/LevelName
@onready var level_lap_count_label: Label = $LevelInfo/LevelLapCount
@onready var level_difficulty_label: Label = $LevelInfo/LevelDifficulty
@onready var tips_label: Label = $LevelInfo/Tips

@onready var preview_image: TextureRect = $PreviewWindow/PreviewImage
@onready var start_button: Button = $StartButton
@onready var garage_button: Button = $GarageButton

var level_infos = {
	1: {
		"name": "Rocky Sands",
		"lap_count": 3,
		"difficulty": "Easy",
		"tips": "Eyes on the road."
	},
	2: {
		"name": "Ski Mountain",
		"lap_count": 3,
		"difficulty": "Medium",
		"tips": "Try not to get a frostbite."
	}
}

func _ready() -> void:
	update_label()
	update_image()

func set_level(level: int) -> void:
	selected_level = level
	update_label()
	update_image()

func update_label() -> void:
	print(selected_level)
	if selected_level not in level_infos.keys():
		level_label.text = "LEVEL %d" % selected_level
		level_name_label.text = "Unavailable"
		level_lap_count_label.text = "Unavailable"
		level_difficulty_label.text = "Unavailable"
		tips_label.text = "Unavailable"
		start_button.hide()
		garage_button.hide()
		return
	else:
		var level_info_id = level_infos[selected_level]
		level_label.text = "LEVEL %d" % selected_level
		level_name_label.text = " %s " % level_info_id["name"]
		level_lap_count_label.text = "Lap Count: %d" % level_info_id["lap_count"]
		level_difficulty_label.text = "Difficulty: %s" % level_info_id["difficulty"]
		tips_label.text = "Tips:\n\t %s" % level_info_id["tips"]
		start_button.show()
		garage_button.show()

	

func get_level_preview(level: int):
	var path = "res://ui/level_selection/level_preview_images/level%d-prev.png" % level
	if ResourceLoader.exists(path):
		return load(path)              
	else:
		return preload("res://ui/level_selection/level_preview_images/placeholder.png")

func update_image() -> void:
	var image_path = get_level_preview(selected_level)
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
