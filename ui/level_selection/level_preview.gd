extends Control

var selected_level : int
@onready var level_label = $Window/WindowTitle/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_level(level: int) -> void:
	selected_level = level
	level_label.text = "LEVEL %d" % selected_level

func _on_back_pressed():
	var ui_node = get_node("/root/Main/UI")
	ui_node.close_overlay($/root/Main/UI/LevelSelection/LevelPreview)

func _on_garage_pressed():
	print("Pressed Garage Button on Level Preview")
	print(selected_level)
	
	GameState.unlocked_levels -= 1
	GameState.save_game()
	
	print(GameState.unlocked_levels)

func _on_start_pressed():
	print("Pressed Start Button on Level Preview")
	GameState.unlock_next_level()
	print(GameState.unlocked_levels)
