extends CharacterBody2D

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
	navigation_agent_2d.velocity_computed.connect(_on_velocity_computed)

	call_deferred("seeker_setup")

	car_sprite.rotation = 0.0


func seeker_setup() -> void:
	await get_tree().physics_frame
	if is_instance_valid(target):
		navigation_agent_2d.target_position = target.global_position


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	navigation_agent_2d.target_position = target.global_position

	if navigation_agent_2d.is_navigation_finished():
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return

	var next_point = navigation_agent_2d.get_next_path_position()
	var to_target = global_position.direction_to(next_point)

	# TURNING / STEERING
	var desired_angle = to_target.angle()
	car_sprite.rotation = lerp_angle(
		car_sprite.rotation,
		desired_angle,
		delta * 4.0
	)

	#  DIRECTION
	var forward = Vector2.RIGHT.rotated(car_sprite.rotation)
	var right = forward.rotated(PI / 2)

	# SPEED CALCULATI
	var alignment = clamp(forward.dot(to_target), 0.4, 1.0)
	var target_speed = max_speed * alignment

	var desired_velocity = forward * target_speed

	# DRIFTING CALCULATIONS
	var turn_amount = abs(angle_difference(car_sprite.rotation, desired_angle)) / PI
	turn_amount = clamp(turn_amount, 0.0, 1.0)

	var drift_dir = sign(right.dot(to_target))
	var target_drift = drift_dir * drift_strength * turn_amount

	current_drift = lerp(current_drift, target_drift, drift_smooth * delta)
	desired_velocity += right * current_drift

	# ACCELERATION
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	update_engine_sound()
	navigation_agent_2d.velocity = velocity


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if safe_velocity.length() > 0.01:
		var desired = safe_velocity.normalized() * max_speed
		velocity = velocity.move_toward(
			desired,
			acceleration * get_physics_process_delta_time()
		)

	move_and_slide()
	
# SOUNDS
	

func update_engine_sound():
	var base_pitch := 0.5
	var max_pitch := 1.8
	var smoothing := 0.08

	var speed := velocity.length()
	var speed_factor = clamp(speed / max_speed, 0.0, 1.0)

	var target_pitch = lerp(base_pitch, max_pitch, speed_factor)

	engine_sound_player.pitch_scale = lerp(
		engine_sound_player.pitch_scale,
		target_pitch,
		smoothing
	)
	
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
