#extends Node2D
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#var loading_screen
#var level_path
#var load_status
#var level_resource
#
#var current_level = null
#
#func load_level_async(path: String):
	#level_path = path
#
	## Show loading screen
	#loading_screen = load("res://ui/LoadingScreen.tscn").instantiate()
	#get_tree().root.add_child(loading_screen)
#
	## Start async load
	#ResourceLoader.load_threaded_request(level_path)
#
#
#func load_level(level_scene_path):
	## Remove previous level if exists
	#if current_level:
		#current_level.queue_free()
		#current_level = null
#
	## Load new level
	#var level_scene = load(level_scene_path)
	#current_level = level_scene.instantiate()
	#add_child(current_level)
#
	## Optional: move Player on top or instantiate it if not part of the level
	#if not has_node("Player"):
		#var player_scene = load("res://scenes/Player.tscn").instantiate()
		#add_child(player_scene)


extends Node2D

@export var selected_level: int
@export var player_scene = load("res://gameplay/player/player(car).tscn")
@export var levels := {
	1: "res://gameplay/levels/level1.tscn",
	2: "res://gameplay/levels/level2.tscn"
}

@onready var level_container := $LevelContainer
@onready var player_container := $PlayerContainer
@onready var loading_screen := $LoadingScreen   # optional

var current_level: Node2D
var player: Node2D

func load_level(level_id: int) -> void:
	show_loading(true)

	# Clear previous level
	if current_level:
		current_level.queue_free()
		current_level = null

	if player:
		player.queue_free()
		player = null

	await get_tree().process_frame

	# Load level
	var level_path = levels.get(level_id)
	if level_path == null:
		push_error("Invalid level ID: %s" % level_id)
		return

	current_level = load(level_path).instantiate()
	level_container.add_child(current_level)

	await get_tree().process_frame
	
	if true:
		await get_tree().create_timer(3.0).timeout

	spawn_player()
	
	if true:
		await get_tree().create_timer(3.0).timeout

	show_loading(false)

func spawn_player() -> void:
		var gameplay_node = get_node("/root/Main/Gameplay")
		if not gameplay_node.has_node("Player"):
			var player_scene = load("res://gameplay/player/player(car).tscn").instantiate()
			var level_path = "LevelContainer/Level%d/Spawnpoint" % selected_level
			var spawnpoint = gameplay_node.get_node(level_path)
			player_scene.position = spawnpoint.global_position
			player_scene.rotation = spawnpoint.global_rotation
			gameplay_node.add_child(player_scene)
			print("INSIDE LEVEL 1")
			

func show_loading(state: bool) -> void:
	if not loading_screen:
		return
	loading_screen.visible = state
