extends Control

@onready var grid = $ScrollContainer/GridContainer
@onready var play_button = $PlayButton
@export var total_levels := 50
@export var unlocked_levels := 1
@export var selected_level = 1
var LevelButtonScene = preload("LevelButton.tscn")

func _ready():
	play_button.visible = false
	for i in range(1, total_levels + 1):
		var btn = LevelButtonScene.instantiate()
		btn.level_id = i
		btn.unlocked = i <= unlocked_levels
		btn.text = str(i)
		btn.pressed.connect(_on_level_pressed.bind(i))
		grid.add_child(btn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_pressed(level_id: int):
	selected_level = level_id
	play_button.visible = true
	for btn in grid.get_children():
		btn.selected = (btn.level_id == selected_level)
	print("Load level:", level_id)

func _on_play_pressed():
	print("Playing in level: %d" % selected_level)
	unlocked_levels += 1

func _on_goback_pressed():
	print("Go Back Button Pressed")
	get_parent().close_overlay($/root/Main/UI/LevelSelection)
	
func reset_state():
	selected_level = 1
	play_button.visible = false
	for btn in grid.get_children():
		btn.selected = false
