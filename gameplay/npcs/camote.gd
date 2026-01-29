extends Area2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var car_sprite: AnimatedSprite2D = $CarSprite
@onready var target: Node2D = null
@onready var engine_sound_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
var accelerating: bool

const MAX_HP := 30
const DAMAGE := 10

var curr_hp = MAX_HP
var is_dead = false
# ------ Death Animation ------
const DEATH_REPEATS = 5
var death_play_count = 0

@onready var popup = $PopupLocation

# DRIVING PARAMS
var max_speed := 80.0
var acceleration := 880.0
var friction := 240.0

# DRIFT PARAMS
var drift_strength := 120.0
var drift_smooth := 6.0  
var current_drift := 0.0 

func _ready() -> void:
	add_to_group("civilian")
	#GameState.civilian = self
	GameState.civilian_list.append(self)
	
	engine_sound_player.volume_db = 2.0
	engine_sound_player.play()
	engine_sound_player.pitch_scale = 0.5 

	navigation_agent_2d.avoidance_enabled = true

	call_deferred("seeker_setup")

	car_sprite.rotation = 0.0


func seeker_setup() -> void:
	await get_tree().physics_frame
	if is_instance_valid(target):
		navigation_agent_2d.target_position = target.global_position


func take_damage(amount: float):
	if is_dead:
		return
		
	curr_hp -= amount
	print(curr_hp)
	if curr_hp <= 0:
		die()
		
	if amount > 0:
		popup.popup(str(amount))

# --------------------------------------------------

func die():
	if is_dead:
		return
	is_dead = true
	
	collision_layer = 0
	collision_mask = 0
	
	car_sprite.play_backwards()
	_on_death_animation_finished()

# --------------------------------------------------

func _on_death_animation_finished():
	death_play_count += 1
	print(death_play_count)
	
	if death_play_count < DEATH_REPEATS:
		await get_tree().create_timer(1).timeout
		car_sprite.play("death")
		_on_death_animation_finished()
	else:
		queue_free()
	
func _exit_tree() -> void:
	if has_meta("spawnpoint"):
		var spawn = get_meta("spawnpoint")
		if is_instance_valid(spawn):
			spawn.set_meta("occupied", false)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerCar":
		body.take_damage(DAMAGE)
