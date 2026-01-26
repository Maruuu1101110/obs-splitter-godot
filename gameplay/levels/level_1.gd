class_name Level

extends Node2D

# Generalized na sya, basta follow lang ang format sang level:
# - Need sang spawnpoint kag enemyspawnpoint node (optioanal ata ang enemy), follow lang ang concept sang level_1
# - kung mag implement enemy npc, required mag butang sang checkpoints, follow man ang format sang CP# sa level_1, naka manage naman sa script ang automation so biskan mag 100 pa na ka CP
# - Flagpointss... given naman na
# mu manlang na mga critical, ang iban nga addons pwede gid pagustuhan


@export var require_order: bool = true
@export var lap_count: int = 0
@export var laps_to_reward: int = 1
@export var biome: String = "default"
@export var speed_limit: int = 80
@export var police_speed: int = 100

@export var flag_parent_path: NodePath = NodePath("FlagPoints")
@export var enemy_checkpoints_parent_path: NodePath = NodePath("EnemyCheckpoints")
@export var police_spawn_path: NodePath = NodePath("PoliceSpawnpoint")
@export var tire_puncture_spawn_path: NodePath = NodePath("TirePunctureSpawn")
@export var bonus_spawn_path: NodePath = NodePath("BonusSpawn")

# Flagpoints
@export var flag_tokens: Array = []
var flagpoint_map = {1: "flagpt_1", 2: "flagpt_2", 3: "flagpt_3"}

# Spawns (currently for level 2)
@export var available_buffs: Array = [
	"res://gameplay/items/defense.tscn",
	"res://gameplay/items/nitro.tscn",
	"res://gameplay/items/repair.tscn",
	"res://gameplay/items/tire_restore.tscn"
]

# Internal state
var flags: Array = []
var lap_flag: Area2D = null
var current_index: int = 0
var lap_passed: Array = []
#var enemy_checkpoints: Array = []
var enemy: Node2D = null
var enemy_index: int = 0
var police = null
var has_tire_punctures: bool = false
var civilian: Node2D = null
var civilian_index: int = 0
#var biome = "default"

@export var entity_checkpoint_map = {
	"enemy": {
		"checkpoint_array": [],
		"checkpoint_node": "EnemyCheckpoints"
	},
	"civilian": {
		"checkpoint_array": [],
		"checkpoint_node": "CivilianCheckpoints"
	}
}

@onready var police_spawn = $PoliceSpawnpoint
@onready var bonus_spawn = $BonusSpawn
@onready var tire_puncture_spawn = $TirePunctureSpawn

func _ready() -> void:
	#_load_flag_points()
	#_load_enemy_checkpoints()
	_load_npc_checkpoints("enemy")
	_load_npc_checkpoints("civilian")
	_assign_enemy()
	_assign_civilian()
	_init_spawnpoints_meta()

func _process(delta: float) -> void:
	_update_enemy_targeting()
	_update_civilian_targeting()

# ----------------- Initialization helpers -----------------

#func _load_flag_points() -> void:
	#var parent = get_node_or_null(flag_parent_path)
	#if parent:
		#for c in parent.get_children():
			#if c is Area2D:
				#flags.append(c)
				#if c.name.to_lower().find("lap") != -1:
					#lap_flag = c
	#else:
		#parent = get_node_or_null("FlagPoints")
		#if parent:
			#for c in parent.get_children():
				#if c is Area2D:
					#flags.append(c)
					#if c.name.to_lower().find("lap") != -1:
						#lap_flag = c
	#if flag_tokens.is_empty():
		#for f in flags:
			#flag_tokens.append(f.name)
#
	#for i in range(flags.size()):
		#var area = flags[i]
		#if area and not area.is_connected("body_entered", Callable(self, "_on_flag_body_entered")):
			#area.body_entered.connect(_on_flag_body_entered.bind(i, flag_tokens[i]))

	if lap_flag and not lap_flag.is_connected("body_entered", Callable(self, "_on_lap_body_entered")):
		lap_flag.connect("body_entered", Callable(self, "_on_lap_body_entered"))

#func _load_enemy_checkpoints() -> void:
	#var parent = get_node_or_null(enemy_checkpoints_parent_path)
	#if parent:
		#enemy_checkpoints = parent.get_children()
	#else:
		#var fallback = get_node_or_null("EnemyCheckpoints")
		#if fallback:
			#enemy_checkpoints = fallback.get_children()
			
func _load_npc_checkpoints(npc_name: String) -> void:
	print("Loading")
	var checkpoint_node = entity_checkpoint_map[npc_name]["checkpoint_node"]
	var parent = get_node_or_null(NodePath(checkpoint_node))
	if parent:
		entity_checkpoint_map[npc_name]["checkpoint_array"] = parent.get_children()
	else:
		var fallback = get_node_or_null(checkpoint_node)
		if fallback:
			entity_checkpoint_map[npc_name]["checkpoint_array"] = fallback.get_children()			

func _init_spawnpoints_meta() -> void:
	var ps = get_node_or_null(police_spawn_path)
	if ps:
		ps.set_meta("occupied", false)
	var tire_parent = get_node_or_null(tire_puncture_spawn_path)
	var bonus_parent = get_node_or_null(bonus_spawn_path)
	var combined_array = []
	if tire_parent:
		combined_array += tire_parent.get_children()
	if bonus_parent:
		combined_array += bonus_parent.get_children()
	for child_node in combined_array:
		child_node.set_meta("occupied", false)

# ----------------- Enemy routing -----------------

func _assign_enemy() -> void:
	var enemy_checkpoints = entity_checkpoint_map["enemy"]["checkpoint_array"]
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		await get_tree().process_frame
		_assign_enemy()
		return
	enemy = enemies[0]
	if enemy_checkpoints.size() > 0:
		enemy.target = enemy_checkpoints[0]
		enemy_index = 0
		print("ENEMY INITIAL TARGET:", enemy.target.name)
		
func _assign_civilian() -> void:
	var civilian_checkpoints = entity_checkpoint_map["civilian"]["checkpoint_array"]
	var civilians = get_tree().get_nodes_in_group("civilian")
	if civilians.is_empty():
		await  get_tree().process_frame
		_assign_civilian()
		return
	civilian = civilians[0]
	if civilian_checkpoints.size() > 0:
		civilian.target = civilian_checkpoints[0]
		civilian_index = 0
		print("CIVILIAN INITIAL TARGET:", civilian.target.name)

func _update_enemy_targeting() -> void:
	var enemy_checkpoints = entity_checkpoint_map["enemy"]["checkpoint_array"]
	if enemy == null:
		return
	if enemy_checkpoints.size() == 0:
		return
	if enemy.global_position.distance_to(enemy_checkpoints[enemy_index].global_position) < 54:
		enemy_index = (enemy_index + 1) % enemy_checkpoints.size()
		enemy.target = enemy_checkpoints[enemy_index]
		print("ENEMY TARGET:", enemy.target.name)
		
func _update_civilian_targeting() -> void:
	var civilian_checkpoints = entity_checkpoint_map["civilian"]["checkpoint_array"]
	if civilian == null:
		return
	if civilian_checkpoints.size() == 0:
		return
	if civilian.global_position.distance_to(civilian_checkpoints[civilian_index].global_position) < 54:
		civilian_index = (civilian_index + 1) % civilian_checkpoints.size()
		civilian.target = civilian_checkpoints[civilian_index]
		print("CIVILIAN TARGET:", civilian.target.name)

# ----------------- Flag handling -----------------

#func _on_flag_body_entered(body: Node, idx: int, token: String) -> void:
	#if not _is_player(body):
		#return
	#if require_order:
		#if idx != current_index:
			#return
		#current_index += 1
		#print("OBTAINED TOKEN", token, current_index, "/", flag_tokens.size())
	#else:
		#if token in lap_passed:
			#return
		#lap_passed.append(token)
		#print("FLAG PASSED:", lap_passed)
#
#func _on_lap_body_entered(body: Node) -> void:
	#if not _is_player(body):
		#return
#
	#if require_order:
		#if current_index == flag_tokens.size():
			#_on_lap_complete()
			#current_index = 0
	#else:
		#if lap_passed.size() == flag_tokens.size():
			#_on_lap_complete()
			#lap_passed.clear()
			
func _on_flagpoint_1_body_entered(body: Node2D) -> void:
	if _is_player(body):
		var pixel_speed = body.velocity.length()
		var kmh = (pixel_speed / 32) * 3.6 * 6.5
		if kmh > speed_limit && is_instance_valid(police):
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
	if body.name == 'PlayerCar' and flagpoint_map[1] in lap_passed:
		lap_passed.append(flagpoint_map[2])
		print(lap_passed)

# ------------------------------------------------------------------------------

func _on_flagpoint_3_body_entered(body: Node2D) -> void:
	if flagpoint_map[3] in lap_passed:
		return
	if body.name == 'PlayerCar' and flagpoint_map[2] in lap_passed:
		lap_passed.append(flagpoint_map[3])
		print(lap_passed)

func _on_lap_body_entered(body: Node2D) -> void:
	if _is_player(body) && lap_passed == [flagpoint_map[1], flagpoint_map[2], flagpoint_map[3]]:
		lap_count += 1
		print("Lap Count: %d" % lap_count)
		if bonus_spawn != null:
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
			
	if lap_count == 3:
		get_parent().get_parent().level_completed_overlay.show()

# ----------------- Utilities -----------------

func _is_player(body: Node) -> bool:
	if body is Node and body.is_in_group("player"):
		return true
	if body is Node and body.name == "PlayerCar":
		return true
	return false

func _on_lap_complete() -> void:
	lap_count += 1
	print("LAP COMPLETE:", lap_count)

	var bonus_parent = get_node_or_null(bonus_spawn_path)
	if not bonus_parent:
		bonus_parent = get_node_or_null("BonusSpawn")
	if bonus_parent:
		for bonus in bonus_parent.get_children():
			var buff_scn = available_buffs.pick_random()
			spawn_entity(buff_scn, bonus, bonus.name)

	if lap_count >= laps_to_reward and not is_instance_valid(police):
		var ps = get_node_or_null(police_spawn_path)
		if not ps:
			ps = get_node_or_null("PoliceSpawnpoint")
		if ps:
			spawn_entity("res://gameplay/obstacle/police.tscn", ps, "Police Spawned")

	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var p = player_nodes[0]
		if tire_puncture_spawn_flag(p):
			var tire_parent = get_node_or_null(tire_puncture_spawn_path)
			if not tire_parent:
				tire_parent = get_node_or_null("TirePunctureSpawn")
			if tire_parent:
				for tire_punc in tire_parent.get_children():
					spawn_entity("res://gameplay/obstacle/tire_puncture.tscn", tire_punc, tire_punc.name)
				has_tire_punctures = true

	if lap_count == 5:
		_on_level_complete()

func tire_puncture_spawn_flag(body: Node) -> bool:
	if not (body is Node):
		return false
	var being_chased = false
	if body.has_method("is_being_chased"):
		being_chased = body.call("is_being_chased")
	if not being_chased and body.has_meta("is_being_chased"):
		being_chased = body.get_meta("is_being_chased")
	if not being_chased and body.has_method("get"):
		if body.get("is_being_chased"):
			being_chased = true

	return lap_count >= 2 and being_chased and not has_tire_punctures

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
		police.speed = police_speed

func _on_level_complete() -> void:
	print("Level complete!")
