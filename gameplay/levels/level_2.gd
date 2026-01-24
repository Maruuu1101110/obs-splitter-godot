extends Node2D

var flagpoint_map = {1: "flagpt_1", 2: "flagpt_2", 3: "flagpt_3"}
var lap_passed = []
var player
var police
var lap_count = 0
var biome = "default"
var available_buffs = [
	"res://gameplay/items/defense.tscn",
	"res://gameplay/items/nitro.tscn",
	"res://gameplay/items/repair.tscn",
	"res://gameplay/items/tire_restore.tscn"
]

var has_tire_punctures = false

# SPAWN NODES
@onready var police_spawn = $PoliceSpawnpoint
@onready var tire_puncture_spawn = $TirePunctureSpawn
@onready var bonus_spawn = $BonusSpawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Initialize metadata
	police_spawn.set_meta("occupied", false)
	var combined_array = tire_puncture_spawn.get_children() + bonus_spawn.get_children()
	for child_node in combined_array:
		child_node.set_meta("occupied", false)
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
		for bonus in bonus_spawn.get_children():
			var buff_scn = available_buffs.pick_random()
			spawn_entity(buff_scn, bonus, bonus.name)
	lap_passed.clear()
	
	if lap_count >= 1 && not is_instance_valid(police):
		spawn_entity("res://gameplay/obstacle/police.tscn", police_spawn, "Police Spawned")
		
	if body.name == "PlayerCar":
		if tire_puncture_spawn_flag(body):
			for tire_punc in tire_puncture_spawn.get_children():
				spawn_entity("res://gameplay/obstacle/tire_puncture.tscn", tire_punc, tire_punc.name)
			has_tire_punctures = true
			
	if lap_count == 5:
		_on_level_complete()
		
	#if player != null:
		#print("Player exists")
	
# ------------------------------------------------------------------------------

func tire_puncture_spawn_flag(body) -> bool:
	return lap_count >= 2 && body.is_being_chased == true && not has_tire_punctures
	
# ------------------------------------------------------------------------------
	
func spawn_entity(scene_location: String, spawnpoint: Node2D, debug_message: String = '') -> void:
	if spawnpoint.get_meta("occupied", true):
		return
		
	var level_node = get_node(".")
	var entity_scene = load(scene_location).instantiate()
	entity_scene.position = spawnpoint.position
	entity_scene.rotation = spawnpoint.rotation
	level_node.add_child(entity_scene)
	print(debug_message)
	
	spawnpoint.set_meta("occupied", true)
	entity_scene.set_meta("spawnpoint", spawnpoint)
	
	if scene_location == "res://gameplay/obstacle/police.tscn":
		police = entity_scene
	
# ------------------------------------------------------------------------------
		
func _on_level_complete() -> void:
	pass
