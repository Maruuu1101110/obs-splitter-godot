#extends Control
#
#var selected_level : int
#@onready var level_label = $Window/WindowTitle/Label
#
#var level_scenes = {
	#1: "res://gameplay/levels/level1.tscn",
	#2: "res://gameplay/levels/level2.tscn",
	#3: "res://gameplaylevels/level3.tscn"
#}
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#func set_level(level: int) -> void:
	#selected_level = level
	#level_label.text = "LEVEL %d" % selected_level
#
#func _on_back_pressed():
	#var ui_node = get_node("/root/Main/UI")
	#ui_node.close_overlay($/root/Main/UI/LevelSelection/LevelPreview)
#
#func _on_garage_pressed():
	#print("Pressed Garage Button on Level Preview")
	#print(selected_level)
	#
	#GameState.unlocked_levels -= 1
	#GameState.save_game()
	#
	#print(GameState.unlocked_levels)
#
#func _on_start_pressed():
	#print("Pressed Start Button on Level Preview: LEVEL %d" % selected_level)
	#
	## Get reference to Gameplay node
	#var gameplay_node = get_node("/root/Main/Gameplay")
#
	## Load level scene
	#if selected_level in level_scenes:
		#var level_scene = load(level_scenes[selected_level])
		#var level_instance = level_scene.instantiate()
		#
		## Clear old level if exists
		#for child in gameplay_node.get_children():
			#if child.name.begins_with("Level"):
				#child.queue_free()
		#
		#gameplay_node.add_child(level_instance)
		#
		## Optional: move player if not inside level
		#if not gameplay_node.has_node("Player"):
			#var player_scene = load("res://gameplay/player/player(car).tscn").instantiate()
			#var spawnpoint = gameplay_node.get_node("Level1/Spawnpoint")
			#player_scene.position = spawnpoint.global_position
			#player_scene.rotation = spawnpoint
			#gameplay_node.add_child(player_scene)
			#print("INSIDE LEVEL 1")
			#
		#
		## hide the ui when the map loads (add a loading screen later)
		#var ui_node = get_node("/root/Main/UI")
		#ui_node.close_overlay($/root/Main/UI/MainMenu)
		#ui_node.close_overlay($/root/Main/UI/LevelSelection)
	#else:
		#print("Level not found!")


extends Control

var selected_level: int = 1

@onready var level_label = $Window/WindowTitle/Label

func _ready() -> void:
	update_label()

func set_level(level: int) -> void:
	selected_level = level
	update_label()

func update_label() -> void:
	level_label.text = "LEVEL %d" % selected_level

func _on_back_pressed() -> void:
	var ui_node = get_node("/root/Main/UI")
	ui_node.close_overlay(self)

func _on_garage_pressed() -> void:
	print("Pressed Garage Button on Level Preview")
	print("Selected level:", selected_level)

	GameState.unlocked_levels -= 1
	GameState.save_game()

	print("Unlocked levels:", GameState.unlocked_levels)

func _on_start_pressed() -> void:
	print("Pressed Start Button: LEVEL %d" % selected_level)

	var gameplay = get_node("/root/Main/Gameplay")
	if gameplay == null:
		push_error("Gameplay node not found!")
		return

	# Tell Gameplay to handle everything
	gameplay.selected_level = selected_level
	gameplay.load_level(selected_level)

	# Hide UI overlays
	var ui_node = get_node("/root/Main/UI")
	ui_node.close_overlay(ui_node.get_node("MainMenu"))
	ui_node.close_overlay(ui_node.get_node("LevelSelection"))
