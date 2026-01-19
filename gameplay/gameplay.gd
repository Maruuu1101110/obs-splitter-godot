extends Node2D

@export var selected_level: int
@export var levels := {
	1: "res://gameplay/levels/level1.tscn",
	2: "res://gameplay/levels/level2.tscn"
}

@onready var level_container := $LevelContainer
@onready var player_container := $PlayerContainer
@onready var loading_screen := $LoadingScreen
@onready var hud = $GameHud/HUD
@onready var health_label = $GameHud/HUD/RichTextLabel
@onready var mobile_controls = $/root/Main/Gameplay/GameHud/MobileControls

var current_level: Node2D
var player:  Node2D

const PIXELS_PER_METER := 32.0

@export var display_multiplier := 6.5 

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	update_speedometer()

func update_speedometer() -> void:
	if player and is_instance_valid(player):
		var pixel_speed = player.velocity. length()
		var kmh = (pixel_speed / PIXELS_PER_METER) * 3.6 * display_multiplier
		health_label.text = "%d km/h" % int(kmh)

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
	show_hud()
	show_loading(false)
	GameState.is_gameplay = true
	
	if OS.get_name() == "Android":
		mobile_controls.show()



func spawn_player() -> void:
	var gameplay_node = get_node("/root/Main/Gameplay")
	if not gameplay_node.has_node("Player"):
		var player_scene = load("res://gameplay/player/player(car).tscn").instantiate()
		var level_path = "LevelContainer/Level%d/Spawnpoint" % selected_level
		var spawnpoint = gameplay_node.get_node(level_path)
		player_scene.position = spawnpoint.global_position
		player_scene.rotation = spawnpoint.global_rotation
		gameplay_node.add_child(player_scene)
		print("Player Spawned")
		
		player = player_scene

func show_loading(state: bool) -> void:
	if not loading_screen:
		return
	loading_screen. visible = state

@onready var hud_ = $GameHud/HUD
func show_hud() -> void:
	hud_.show()
func hide_hud() -> void:
	hud_.hide()

# --------- IN GAME -------------
@onready var pause_btn = $GameHud/HUD/TouchScreenButton
@onready var pause_overlay = $GameHud/PauseOverlay
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and GameState.is_gameplay:
		pause_overlay. toggle_pause()


func _on_pause_btn_pressed():
	pause_overlay.toggle_pause()
	print("GAME IS PAUSED")
	
# clearing, iwas memory leakage
func cleanup() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null
	if player: 
		player.queue_free()
		player = null
	
	for child in level_container.get_children():
		child.queue_free()
	
	for child in player_container.get_children():
		child.queue_free()
	
	hide_hud()
	GameState.is_gameplay = false
	print("Gameplay session ended")

func restart_current_level() -> void:
	var level_id = selected_level 
	cleanup()
	await get_tree().process_frame
	load_level(level_id)
