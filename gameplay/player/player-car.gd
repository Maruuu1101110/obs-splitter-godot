extends CharacterBody2D

# !!! READ !!!
# GIN FEED KO NI SA AI, 
# SYA NA NI NAG TIMPLA SANG PARAMS

# ----- Game Mechanics Related -----
var health := 100.0
var armor := 0.0				# this increases when equipped with weapons
var damage := 0.0				# this increases when equipped with weapons

# ===== CAR STATS (loaded from config) =====
var acceleration_force := 1000.0
var brake_force := 600.0
var max_speed := 280.0
var reverse_speed := 140.0
var weight := 1.0

# ===== TIRE STATS (loaded from config) =====
var steering_speed := 2.2
var lateral_friction := 16.0
var rolling_friction := 2.5
var drift_lateral_friction := 2.0
var drift_steering_speed := 4.0

var base_lateral_friction := 16.0
var base_steering_speed := 2.2

const DRIFT_EASE := 0.15
const RETURN_EASE := 0.01

# ------ STATE ------
var accel_input := 0.0
var steer_input := 0.0
var is_drifting := false
var is_moving_backward := false

# ------ GAME MECHANICS ------
var breadcrumb = []
var curr_hp = health
var damage_cd = 0.5
var damage_timer = 0.0
var is_being_chased = false
var is_punctured = false
var punctured_tire_speed = 50.0

# CAR BODY
@onready var car_sprite = $CarAnimation/Body

# CAR TIRES
@onready var tire_front_left = $CarAnimation/TireLayout/FrontLeft
@onready var tire_front_right = $CarAnimation/TireLayout/FrontRight
@onready var tire_back_left = $CarAnimation/TireLayout/BackLeft
@onready var tire_back_right = $CarAnimation/TireLayout/BackRight

# CAR TRACKS
@onready var animated_tracks = $TrailAnimation/AnimatedTrack

func _ready():
	_load_car_visuals()
	_apply_car_stats()
	_apply_tire_stats()
	
	base_lateral_friction = lateral_friction
	base_steering_speed = steering_speed

func _load_car_visuals():
	# Load textures from config
	car_sprite.texture = load(GameState.player_configuration["body-type"])
	
	var tire_texture = load(GameState.player_configuration["tire-type"])
	tire_back_left.sprite_frames = tire_texture
	tire_back_right.sprite_frames = tire_texture
	tire_front_left.sprite_frames = tire_texture
	tire_front_right.sprite_frames = tire_texture

func _apply_car_stats():
	var body_id = GameState.player_configuration. get("body-id", "street-1")
	var body_data = GameState.get_body_data(body_id)
	
	if body_data. is_empty():
		print("Warning: No body data found for '%s', using defaults" % body_id)
		return
	
	max_speed = body_data.get("max_speed", max_speed)
	acceleration_force = body_data.get("acceleration", acceleration_force)
	health = body_data. get("health", health)
	weight = body_data.get("weight", weight)
	
	# Derived stats
	reverse_speed = max_speed * 0.5
	brake_force = acceleration_force * 0.6
	
	print("Body stats loaded: %s (Speed: %s, Accel:  %s, HP: %s)" % [body_id, max_speed, acceleration_force, health])

func _apply_tire_stats():
	var tire_id = GameState. player_configuration.get("tire-id", "street_tire")
	var tire_data = GameState.get_tire_data(tire_id)
	
	if tire_data. is_empty():
		print("Warning:  No tire data found for '%s', using defaults" % tire_id)
		return
	
	lateral_friction = tire_data.get("grip", lateral_friction)
	drift_lateral_friction = tire_data.get("drift_friction", drift_lateral_friction)
	
	# Apply speed bonus from tires
	var speed_bonus = tire_data.get("max_speed_bonus", 0.0)
	max_speed += speed_bonus
	
	print("Tire stats loaded: %s (Grip: %s, Drift: %s, Speed Bonus: %s)" % [tire_id, lateral_friction, drift_lateral_friction, speed_bonus])

func _physics_process(delta):
	damage_timer -= delta
	read_input()
	apply_drift()
	apply_engine(delta)
	apply_friction(delta)
	apply_steering(delta)
	move_and_slide()
	
	if is_punctured:
		puncture_tire(delta)
	else:
		var body_id = GameState.player_configuration. get("body-id", "street-1")
		var body_data = GameState.get_body_data(body_id)
		max_speed = body_data.get("max_speed", max_speed)
	
	if damage_timer > 0:
		return
	detect_collision()

# --------------------------------------------------

func read_input():
	accel_input = Input. get_axis("brake", "accelerate")
	var raw_steer = Input.get_axis("steer_left", "steer_right")
	
	var forward_velocity = velocity.dot(transform.x)
	is_moving_backward = forward_velocity < -5.0
	
	if is_moving_backward: 
		steer_input = -raw_steer
	else:
		steer_input = raw_steer
	
	is_drifting = Input.is_action_pressed("handbrake")
	
	update_animations()

func update_animations():
	if Input.is_action_pressed("steer_left"):
		tire_front_right.rotation_degrees = 75.0
		tire_front_left. rotation_degrees = 75.0
		animated_tracks.animation = "track_left"
	elif Input.is_action_pressed("steer_right"):
		tire_front_left.rotation_degrees = 105.0
		tire_front_right. rotation_degrees = 105.0
		animated_tracks.animation = "track_right"
	else: 
		tire_front_left.rotation_degrees = 90.0
		tire_front_right. rotation_degrees = 90.0
		animated_tracks.animation = "track_def"

# --------------------------------------------------

func apply_drift():
	var target_friction:  float
	var target_steer: float
	var ease_amount: float
	
	if is_drifting:
		target_friction = drift_lateral_friction
		target_steer = drift_steering_speed
		ease_amount = DRIFT_EASE
	else:
		target_friction = base_lateral_friction
		target_steer = base_steering_speed
		ease_amount = RETURN_EASE
	
	lateral_friction = lerp(lateral_friction, target_friction, ease_amount)
	steering_speed = lerp(steering_speed, target_steer, ease_amount)

# --------------------------------------------------

func apply_engine(delta):
	var forward = transform.x
	var current_speed = velocity. length()
	
	var speed_ratio = clamp(current_speed / max_speed, 0.0, 1.0)
	var power_factor = pow(1.0 - speed_ratio, 1.5)
	power_factor = clamp(power_factor, 0.1, 1.0)
	
	# Weight affects acceleration (heavier = slower accel)
	var weight_modifier = 1.0 / weight
	
	if is_drifting:
		if accel_input > 0.0:
			velocity += forward * acceleration_force * power_factor * weight_modifier * 0.6 * accel_input * delta
	elif accel_input > 0.0:
		velocity += forward * acceleration_force * power_factor * weight_modifier * accel_input * delta
	elif accel_input < 0.0:
		var forward_speed = velocity.dot(forward)
		if forward_speed > 10.0:
			velocity += forward * brake_force * accel_input * delta
		else: 
			var reverse_ratio = clamp(current_speed / reverse_speed, 0.0, 1.0)
			var reverse_power = pow(1.0 - reverse_ratio, 1.5)
			velocity += forward * reverse_speed * reverse_power * accel_input * delta
	
	velocity = velocity.limit_length(max_speed)
	
	update_speed_animations()

func update_speed_animations():
	var speed = velocity.length()
	
	if speed > 1.0:
		var anim_speed_scale = clamp(speed / max_speed, 0.3, 2.5)
		
		if is_moving_backward:
			_play_all_sprites_backward(anim_speed_scale)
			animated_tracks.hide()
			animated_tracks.stop()
		else:
			_play_all_sprites_forward(anim_speed_scale)
			
			if (speed > 130.0 and accel_input > 0) or (is_drifting and speed > 50.0):
				animated_tracks.play()
				animated_tracks. show()
				animated_tracks.speed_scale = anim_speed_scale
			else: 
				animated_tracks.hide()
				animated_tracks.stop()
	else:
		_stop_all_sprites()

func _play_all_sprites_forward(speed_scale:  float):
	tire_back_left. play()
	tire_back_right.play()
	tire_front_left.play()
	tire_front_right.play()
	_set_all_speed_scales(speed_scale)

func _play_all_sprites_backward(speed_scale:  float):
	tire_back_left. play_backwards()
	tire_back_right.play_backwards()
	tire_front_left.play_backwards()
	tire_front_right.play_backwards()
	_set_all_speed_scales(speed_scale)

func _set_all_speed_scales(speed_scale:  float):
	tire_back_left. speed_scale = speed_scale
	tire_back_right. speed_scale = speed_scale
	tire_front_left. speed_scale = speed_scale
	tire_front_right. speed_scale = speed_scale

func _stop_all_sprites():
	tire_back_left. stop()
	tire_back_right. stop()
	tire_front_left. stop()
	tire_front_right. stop()
	animated_tracks.hide()
	animated_tracks.stop()

# --------------------------------------------------

func apply_friction(delta):
	var forward = transform.x
	var right = transform. y

	var forward_speed = velocity. dot(forward)
	var lateral_speed = velocity.dot(right)

	lateral_speed = lerp(lateral_speed, 0.0, lateral_friction * delta)

	var speed_factor = clamp(velocity.length() / max_speed, 0.2, 1.0)
	forward_speed = lerp(forward_speed, 0.0, rolling_friction * speed_factor * delta)

	velocity = forward * forward_speed + right * lateral_speed

# --------------------------------------------------

func apply_steering(delta):
	var speed = velocity.length()
	if speed < 5.0:
		return
	var speed_factor = clamp(speed / max_speed, 0.3, 1.0)
	var steer_modifier = 1.0 - (speed_factor * 0.4)
	var steer_amount = steer_input * steering_speed * steer_modifier
	rotation += steer_amount * delta

# --------------------------------------------------

func _on_timer_timeout() -> void:
	if is_being_chased:
		var dist_from_prev_position = 0
		if not breadcrumb:
			breadcrumb.append(position)
		if breadcrumb:
			dist_from_prev_position = position.distance_to(breadcrumb[-1])
		if dist_from_prev_position > 50:
			breadcrumb.append(position)	
		if len(breadcrumb) > 30:
			breadcrumb.pop_at(0)

# --------------------------------------------------

func detect_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("obstacle"):
			take_damage(collider.DAMAGE)
			deal_damage(collider)
			damage_timer = damage_cd
			break

# --------------------------------------------------

func take_damage(amount: float):
	curr_hp -= max(amount - armor, 0)
	curr_hp = max(curr_hp, 0)
	
	if curr_hp <= 0:
		game_over()
		
	print("Current HP: %d" % curr_hp)

# --------------------------------------------------

func deal_damage(collider: Object):
	collider.take_damage(damage)

# --------------------------------------------------

func puncture_tire(delta):
	if max_speed > punctured_tire_speed:
		max_speed -= 5 * delta
	#print(max_speed)

# --------------------------------------------------

func game_over():
	print("Game Over")
