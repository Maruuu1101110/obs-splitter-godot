extends Control

@onready var grid = $ScrollContainer/GridContainer
@onready var play_button = $SelectButton
@export var total_levels := GameState.total_levels
var LevelButtonScene = preload("LevelButton.tscn")



func _ready():
	play_button.visible = false
	build_grid()
	restore_selection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_open():
	build_grid()
	restore_selection()


func build_grid():
	for child in grid.get_children():
		child.queue_free()

	for i in range(1, GameState.total_levels + 1):
		var btn = LevelButtonScene.instantiate()
		btn.level_id = i
		btn.unlocked = i <= GameState.unlocked_levels
		btn.text = str(i)
		btn.pressed.connect(_on_level_pressed.bind(i))
		grid.add_child(btn)

func restore_selection():
	if GameState.selected_level > 0:
		play_button.visible = true

	for btn in grid.get_children():
		btn.selected = (btn.level_id == GameState.selected_level)


func _on_level_pressed(level_id: int):
	GameState.selected_level = level_id
	play_button.visible = true
	for btn in grid.get_children():
		btn.selected = (btn.level_id == GameState.selected_level)
	print("Load level:", level_id)

func _on_play_pressed():
	print("Playing in level: %d" % GameState.selected_level)
	var level_preview = $LevelPreview
	level_preview.set_level(GameState.selected_level)
	get_parent().show_overlay(level_preview)

func _on_goback_pressed():
	print("Go Back Button Pressed")
	get_parent().close_overlay($/root/Main/UI/LevelSelection)
	
func reset_state():
	GameState.selected_level = 0
	play_button.visible = false
	for btn in grid.get_children():
		btn.selected = false
