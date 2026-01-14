# This is where all the persistent data should go
extends Node

# --- Runtime game state ---
var total_levels := 30
var unlocked_levels := 1
var selected_level := 0
var coins := 0
var highscore := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_game():
	var path := "user://savegame.json"

	if not FileAccess.file_exists(path):
		print("No save found === starting fresh.")
		save_game()
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file")
		return

	var json := JSON.new()
	var result := json.parse(file.get_as_text())

	if result != OK:
		push_error("Failed to parse save file")
		return

	var data: Dictionary = json.data

	unlocked_levels = data.get("unlocked_levels", 1)
	coins = data.get("coins", 0)
	highscore = data.get("highscore", 0)

	print("Save loaded successfully")


func save_game():
	var data := {
		"unlocked_levels": unlocked_levels,
		"coins": coins,
		"highscore": highscore
	}

	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file == null:
		push_error("!!! Failed to save game !!!")
		return
	file.store_string(JSON.stringify(data))
	print("GAME SAVED!!!")

# Gameplay Functions
func unlock_next_level():
	if selected_level >= unlocked_levels:
		unlocked_levels = selected_level + 1
		save_game()  # auto save when unlocking
