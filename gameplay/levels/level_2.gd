extends Node2D

var flagpoint_map = {1: "flagpt_1", 2: "flagpt_2", 3: "flagpt_3"}
var lap_passed = []
var player
var police
var lap_count = 0

var has_tire_punctures = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	#print(get_tree().get_nodes_in_group("obstacle"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# ------------------------------------------------------------------------------

func _on_flagpoint_1_body_entered(body: Node2D) -> void:
	if body.name == 'PlayerCar':
		var pixel_speed = body.velocity.length()
		var kmh = (pixel_speed / 32) * 3.6 * 6.5
		if kmh > 80 && is_instance_valid(police):
			police.in_pursuit = true
			body.is_being_chased = true
			
		if flagpoint_map[1] in lap_passed:
			return
		lap_passed.append(flagpoint_map[1])
		print(lap_passed)

# ------------------------------------------------------------------------------

func _on_flagpoint_2_body_entered(body: Node2D) -> void:
	if flagpoint_map[2] in lap_passed:
		return
	if body.name == 'PlayerCar':
		lap_passed.append(flagpoint_map[2])
		print(lap_passed)

# ------------------------------------------------------------------------------

func _on_flagpoint_3_body_entered(body: Node2D) -> void:
	if flagpoint_map[3] in lap_passed:
		return
	if body.name == 'PlayerCar':
		lap_passed.append(flagpoint_map[3])
		print(lap_passed)

# ------------------------------------------------------------------------------

func _on_lap_body_entered(body: Node2D) -> void:
	if lap_passed == [flagpoint_map[1], flagpoint_map[2], flagpoint_map[3]]:
		lap_count += 1
		print("Lap Count: %d" % lap_count)
	lap_passed.clear()
	
	if lap_count >= 1 && not is_instance_valid(police):
		spawn_entity("res://gameplay/obstacle/police.tscn", "PoliceSpawnpoint", "Police Spawned")
		
	if body.name == "PlayerCar":
		if tire_puncture_spawn_flag(body):
			spawn_entity("res://gameplay/obstacle/tire_puncture.tscn", "TirePunctureSpawn1", "Tire punc 1 Spawned")
			spawn_entity("res://gameplay/obstacle/tire_puncture.tscn", "TirePunctureSpawn2", "Tire punc 2 Spawned")
			spawn_entity("res://gameplay/obstacle/tire_puncture.tscn", "TirePunctureSpawn3", "Tire punc 3 Spawned")
			has_tire_punctures = true
			
	if lap_count == 5:
		_on_level_complete()
	
# ------------------------------------------------------------------------------

func tire_puncture_spawn_flag(body) -> bool:
	return lap_count >= 2 && body.is_being_chased == true && not has_tire_punctures
	
# ------------------------------------------------------------------------------
	
func spawn_entity(scene_location: String, node: String, debug_message: String = '') -> void:
	var level_node = get_node(".")
	var entity_scene = load(scene_location).instantiate()
	var entity_spawnpoint = level_node.get_node(node)
	entity_scene.position = entity_spawnpoint.global_position
	entity_scene.rotation = entity_spawnpoint.global_rotation
	level_node.add_child(entity_scene)
	print(debug_message)
	
	if scene_location == "res://gameplay/obstacle/police.tscn":
		police = entity_scene
	
# ------------------------------------------------------------------------------
		
func _on_level_complete() -> void:
	pass
