extends Node2D

@export var selected_level: int
@export var levels := {
	1: "res://gameplay/levels/level1.tscn",
	2: "res://gameplay/levels/level2.tscn"
}

@onready var level_container := $LevelContainer
@onready var player_container := $PlayerContainer
@onready var speedo_container: Control = $GameHud/HUD/Labels/SpeedoContainer
@onready var loading_screen := $LoadingScreen
@onready var hud = $GameHud/HUD

# LABELS
@onready var speed_label = $GameHud/HUD/Labels/SpeedLabel
@onready var health_label: RichTextLabel = $GameHud/HUD/Labels/HealthLabel
@onready var lap_label: RichTextLabel = $GameHud/HUD/Labels/LapLabel


@onready var mobile_controls = $/root/Main/Gameplay/GameHud/HUD/MobileControls
@onready var loading_progress_bar: ProgressBar = $LoadingScreen/LoadingScreen2/VBoxContainer/ProgressBar

# On level complete overlay
@onready var level_completed_overlay: Control = $GameHud/LevelCompletedOverlay

@onready var timer: Timer = $Timer
@onready var timer_label: RichTextLabel = $GameHud/TimerLabel

var current_level: Node2D
var player:  Node2D
var enemy: Node2D

const PIXELS_PER_METER := 32.0

var _last_time_displayed = -1

@export var display_multiplier := 6.5 

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	_update_timer_label()
	update_health_label()
	update_speedometer()
	level_complete_check()

func _start_countdown():
	print("COUNTDOWN START")
	
	# ENABLE AUDIO TO RUN WHILE COUNTDOWN
	GameState.main_soundtrack.stream = preload("res://audio/main1.mp3")
	GameState.main_soundtrack.volume_db = -7.0
	GameState.main_soundtrack.play()
	GameState.player.engine_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.enemy.engine_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# START TIMER 
	timer_label.show()
	timer.start()

	# PAUSE THE ENTIRE SCREEN WHILE COUNTDOWN
	get_tree().paused = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	current_level.process_mode = Node.PROCESS_MODE_DISABLED
	enemy.process_mode = Node.PROCESS_MODE_DISABLED
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer_label.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.process_mode = Node.PROCESS_MODE_ALWAYS


func _update_timer_label():
	var time_left = int(timer.time_left)
	if time_left != _last_time_displayed: 
		_last_time_displayed = time_left
		print(time_left)
		if time_left == 0:
			timer_label.text = "GO!"
			print("GO")
		else:
			timer_label.text = "[center][wave amp=30 freq=10]%d[/wave][/center]" % time_left


func _on_timer_finished():
	# RESUME ALL AND DECLARE THEM AS PAUSABLE SO THAT THEYLLE STOP WHEN PAUSED
	get_tree().paused = false
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	current_level.process_mode = Node.PROCESS_MODE_PAUSABLE
	enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
	GameState.player.engine_sound_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# HIDE TIMER LABEL
	timer_label.hide()
	
	# SHOW THE INGAME HUD
	show_hud()
	if OS.get_name() == "Android":
		mobile_controls.show()	
	GameState.is_gameplay = true

func update_speedometer() -> void:
	if player and is_instance_valid(player):
		var pixel_speed = player.velocity.length()
		var kmh = (pixel_speed / PIXELS_PER_METER) * 3.6 * display_multiplier
		speed_label.text = "%d km/h" % int(kmh)

func update_health_label():
	if player and is_instance_valid(player):
		var player_health = player.health
		health_label.text = "HEALTH: %s" % str(int(player_health))
	if current_level and is_instance_valid(current_level):
		lap_label.text = "LAP: %s" % str(current_level.lap_count + 1) if current_level.lap_count < 2 else "FINAL"

func load_level(level_id:  int) -> void:
	show_loading(true)
	var start_time = Time.get_ticks_msec()
	var minimum_load_time = 1500
	await get_tree().process_frame

	if current_level:
		current_level.queue_free()
		current_level = null

	if player: 
		player.queue_free()
		player = null
	
	if enemy:
		enemy.queue_free()
		enemy = null

	var level_path = levels.get(level_id)
	if level_path == null:
		push_error("Invalid level ID: %s" % level_id)
		show_loading(false)
		return

	var err = ResourceLoader.load_threaded_request(level_path)
	if err != OK: 
		push_error("ERROR starting level load")
		show_loading(false)
		return

	var progress:  Array = []
	while true: 
		var status = ResourceLoader.load_threaded_get_status(level_path, progress)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				loading_progress_bar.value = progress[0] * 100
				await get_tree().process_frame
			ResourceLoader.THREAD_LOAD_LOADED:
				break
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("ERROR loading level")
				show_loading(false)
				return

	var elapsed = Time.get_ticks_msec() - start_time
	if elapsed < minimum_load_time:
		var remaining_time = (minimum_load_time - elapsed) / 1000.0
		var tween = create_tween()
		tween.tween_property(loading_progress_bar, "value", 100, remaining_time)
		await tween.finished

	var level_resource = ResourceLoader.load_threaded_get(level_path)
	current_level = level_resource.instantiate()
	level_container.add_child(current_level)
	
	# Add level if the level is not 1
	if level_id > 1:
		GameState.unlocked_levels += 1
		GameState.save_game()
	
	show_loading(false)
	spawn_player()
	spawn_enemy()
	_start_countdown()
	show_speedometer()


func spawn_player() -> void:
	var gameplay_node = get_node("/root/Main/Gameplay")
	if not gameplay_node.has_node("Player"):
		var player_scene = load("res://gameplay/player/player(car).tscn").instantiate()
		var level_path = "LevelContainer/Level%d/Spawnpoint" % selected_level
		var spawnpoint = gameplay_node.get_node(level_path)
		player_scene.position = spawnpoint.global_position
		player_scene.rotation = spawnpoint.rotation
		gameplay_node.add_child(player_scene)
		print("Player Spawned")
		
		player = player_scene

func spawn_enemy():
	var gameplay_node = get_node("/root/Main/Gameplay")
	if not gameplay_node.has_node("EnemyCar"):
		var enemy_scence = load("res://gameplay/npcs/enemy_car.tscn").instantiate()
		var level_path = "LevelContainer/Level%d/EnemySpawnPoint" % selected_level
		var spawnpoint = gameplay_node.get_node(level_path)
		enemy_scence.position = spawnpoint.global_position
		enemy_scence.rotation = spawnpoint.rotation
		gameplay_node.add_child(enemy_scence)
		enemy = enemy_scence
	
func show_speedometer():
	var speedo_container_node = get_node("/root/Main/Gameplay/GameHud/HUD/Labels/SpeedoContainer")
	if not speedo_container_node.has_node("Speedo"):
		var speedo_scene = load("res://ui/speedo.tscn").instantiate()
		speedo_container_node.add_child(speedo_scene)
		print("SPEEDO IS HEREEE")

func show_loading(state: bool) -> void:
	if not loading_screen:
		return
	loading_screen.visible = state

@onready var hud_ = $GameHud/HUD
func show_hud() -> void:
	hud_.show()
func hide_hud() -> void:
	hud_.hide()

# --------- IN GAME -------------
@onready var pause_overlay = $GameHud/PauseOverlay
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and GameState.is_gameplay:
		pause_overlay.toggle_pause()


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
		
	if enemy:
		enemy.queue_free()
		enemy = null
	
	for child in level_container.get_children():
		child.queue_free()
	
	for child in player_container.get_children():
		child.queue_free()
	
	for child in speedo_container.get_children():
		child.queue_free()
	
	hide_hud()
	mobile_controls.hide()
	GameState.main_soundtrack.stream = preload("res://audio/main2.mp3")
	GameState.main_soundtrack.play()
	GameState.is_gameplay = false
	print("Gameplay session ended")

func restart_current_level() -> void:
	var level_id = selected_level 
	cleanup()
	await get_tree().process_frame
	load_level(level_id)


# gonna be used if we do the same lap concept for every level...
func level_complete_check():
	if current_level == null:
		return
	if is_instance_valid(current_level) && current_level.lap_count >= 3:
		level_completed_overlay.show()
	pass
