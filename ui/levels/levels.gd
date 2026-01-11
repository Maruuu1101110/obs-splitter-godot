extends Control



@onready var grid = $ScrollContainer/GridContainer
@export var total_levels := 50
@export var unlocked_levels := 10

var LevelButtonScene = preload("LevelButton.tscn")

func _ready():
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
	print("Load level:", level_id)

func _on_goback_pressed():
	print("Go Back Button Pressed")
	get_parent().close_overlay($/root/Main/UI/Levels)
