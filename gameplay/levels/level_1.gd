extends Node2D

@export var lap_count: int = 0

var flag_tokens := ["fp1", "fp2", "fp3"]
var current_index := 0

@onready var flags := [
	$FlagPoints/Flag1,
	$FlagPoints/Flag2,
	$FlagPoints/Flag3
]

@onready var enemy_checkpoints = $EnemyCheckpoints.get_children()

@onready var lap_flag: Area2D = $FlagPoints/LapFlag
var enemy_index = 0
var enemy: Node2D = null

func _ready() -> void:
	_assign_enemy()
	
func _process(delta: float) -> void:
	if enemy == null:
		return
	if enemy.global_position.distance_to(
		enemy_checkpoints[enemy_index].global_position
	) < 54:
		enemy_index = (enemy_index + 1) % enemy_checkpoints.size()
		enemy.target = enemy_checkpoints[enemy_index]
		print("ENEMY TARGET:", enemy.target.name)

func _assign_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		await get_tree().process_frame
		_assign_enemy()
		return
	enemy = enemies[0]
	enemy.target = enemy_checkpoints[0]
	print("ENEMY INITIAL TARGET:", flags[0].name)

func _is_player(body: Node2D) -> bool:
	return body.is_in_group("player")

func handle_flag(index: int, token: String, body: Node2D) -> void:
	if not _is_player(body):
		return
	if index != current_index:
		return
	if token != flag_tokens[current_index]:
		return
	current_index += 1
	print("OBTAINED TOKEN", token, current_index, "/", flag_tokens.size())

# PLAYER FLAGPOINTS
func _on_flag_1_body_entered(body: Node2D) -> void:
	handle_flag(0, "fp1", body)

func _on_flag_2_body_entered(body: Node2D) -> void:
	handle_flag(1, "fp2", body)

func _on_flag_3_body_entered(body: Node2D) -> void:
	handle_flag(2, "fp3", body)

func _on_lap_flag_body_entered(body: Node2D) -> void:
	if _is_player(body) and current_index == flag_tokens.size():
		lap_count += 1
		current_index = 0
		print("LAP COMPLETE:", lap_count)
