# This is where all the persistent data should go
extends Node

# REFERENCES
var player: Node2D = null
var enemy: Node2D = null
var civilian: Node2D = null
var main_soundtrack = null

var enemy_list: Array[Node2D] = []
var civilian_list: Array[Node2D] = []

# --- Runtime game state ---
var is_gameplay := false
var total_levels := 50
var unlocked_levels := 1
var selected_level := 0
var game_over := false

# FOR UPDATES
var coins := 0
var highscore := 0

func _ready() -> void:
	load_game()
	load_player_config()

func _process(delta: float) -> void:
	pass

## GAME SAVE ##
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


func unlock_next_level():
	if selected_level >= unlocked_levels:
		unlocked_levels = selected_level + 1
		save_game()


## PLAYER CONFIG ##
# defualt value of player if no saved
var player_configuration = {
	"body-type":  "res://ui/garage/car_previews/sport/sport-model1.png",
	"body-id": "sport-1",
	"body-category": "sport",
	"tire-type":  "res://ui/garage/car_previews/sport/sport-tire-anim. tres",
	"tire-id": "sport_tire",
	"body-color": "ffffffff",
	"equipment": "res://ui/garage/car_previews/equipment/nothing.png",
	"equipment-id": "nothing"
}

var body_stats = {
	"offroad-1": {"max_speed": 260.0, "acceleration": 620.0, "weight": 1.2, "health": 150.0},
	"offroad-2": {"max_speed": 255.0, "acceleration": 600.0, "weight": 1.5, "health": 160.0},
	"street-1":  {"max_speed": 290.0, "acceleration": 740.0, "weight": 1.0, "health": 120.0},
	"street-2": {"max_speed": 305.0, "acceleration": 780.0, "weight": 0.95, "health": 115.0},
	"sport-1": {"max_speed": 340.0, "acceleration": 920.0, "weight": 0.8, "health": 95.0},
	"sport-2": {"max_speed":  360.0, "acceleration":  1000.0, "weight":  0.75, "health":  85.0},
}

var tire_stats = {
	"offroad_tire": {"grip": 12.0, "drift_friction": 3.0, "max_speed_bonus": -10.0},
	"street_tire": {"grip": 16.0, "drift_friction":  2.0, "max_speed_bonus": 0.0},
	"sport_tire":  {"grip": 20.0, "drift_friction": 1.5, "max_speed_bonus": 15.0},
}

var equipment_stats = {
	"snow_plow": {"damage": 20.0, "armor": 30.0, "weight": 0.15, "speed_penalty": 50.0},
	"front_blade": {"damage": 60.0, "armor": 30.0, "weight": 0.35, "speed_penalty": 80.0},
	"mine_claws": {"damage": 30.0, "armor": 30.0, "weight": 0.30, "speed_penalty": 65.0},
	"nothing": {"damage": 0.0, "armor": 0.0, "weight": 0.0, "speed_penalty": 0.0},
}

func get_body_data(body_id: String) -> Dictionary:
	return body_stats.get(body_id, {})

func get_tire_data(tire_id: String) -> Dictionary:
	return tire_stats.get(tire_id, {})
	
func get_equipment_data(equipment_id: String) -> Dictionary:
	return equipment_stats.get(equipment_id, {})

func load_player_config():
	var path := "user://player_config.json"
	
	if not FileAccess.file_exists(path):
		print("No player config found === starting fresh.")
		save_player_config() 
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open player config file")
		return

	var json := JSON.new()
	var result := json.parse(file.get_as_text())

	if result != OK: 
		push_error("Failed to parse player config file")
		return

	var data: Dictionary = json.data
	
	player_configuration["body-type"] = data.get("body-type", player_configuration["body-type"])
	player_configuration["body-id"] = data.get("body-id", player_configuration["body-id"])
	player_configuration["body-category"] = data.get("body-category", player_configuration["body-category"])
	player_configuration["tire-type"] = data.get("tire-type", player_configuration["tire-type"])
	player_configuration["tire-id"] = data.get("tire-id", player_configuration["tire-id"])
	player_configuration["body-color"] = data.get("body-color", player_configuration["body-color"])
	player_configuration["equipment"] = data.get("equipment", player_configuration["equipment"])
	player_configuration["equipment-id"] = data.get("equipment-id", player_configuration["equipment-id"])
	
	print("Player Config loaded: ", player_configuration)


func save_player_config():
	var file := FileAccess.open("user://player_config.json", FileAccess.WRITE)
	if file == null:
		push_error("!!! Failed to save player config !!!")
		return
	file.store_string(JSON.stringify(player_configuration))
	print("Player Config SAVED:  ", player_configuration)
