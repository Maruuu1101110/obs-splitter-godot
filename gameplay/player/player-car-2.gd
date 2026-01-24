extends CharacterBody2D

# ! !! READ !!!
# GIN FEED KO NI SA AI, 
# SYA NA NI NAG TIMPLA SANG PARAMS

# ----- Game Mechanics Related -----
var health := 100.0

# ===== CAR STATS (loaded from config) =====
var acceleration_force := 180.0
var brake_force := 600.0
var max_speed := 280.0
var reverse_speed := 140.0
var weight := 1.0

# ===== ENGINE SIMULATION (NEW) =====
var engine_power := 0.0
var engine_response := 2.5  # How fast throttle responds (lower = more realistic)
var traction := 1.0
var current_rpm := 0.0
var max_rpm := 7000.0

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
	car_sprite.texture = load(GameState.player_configuration["body-type"])
	car_sprite.self_modulate = GameState.player_configuration["body-color"]
	
	var tire_texture = load(GameState.player_configuration["tire-type"])
	tire_back_left.sprite_frames = tire_texture
	tire_back_right.sprite_frames = tire_texture
	tire_front_left.sprite_frames = tire_texture
	tire_front_right.sprite_frames = tire_texture

func _apply_car_stats():
	var body_id = GameState.player_configuration.get("body-id", "street-1")
	var body_data = GameState.get_body_data(body_id)
	
	if body_data.is_empty():
		print("Warning: No body data found for '%s', using defaults" % body_id)
		return
	
	max_speed = body_data.get("max_speed", max_speed)
	acceleration_force = body_data.get("acceleration", acceleration_force)
	health = body_data.get("health", health)
	weight = body_data.get("weight", weight)
	
	# Engine response based on weight (heavier = slower response)
	engine_response = body_data.get("engine_response", 3.0 / sqrt(weight))
	
	# Derived stats
	reverse_speed = max_speed * 0.5
	brake_force = acceleration_force * 0.6
	
	print("Body stats loaded: %s (Speed: %s, Accel: %s, HP: %s, Weight: %s)" % [body_id, max_speed, acceleration_force, health, weight])

# Add this variable at the top with other tire stats
var traction_bonus := 0.0

func _apply_tire_stats():
	var tire_id = GameState.player_configuration.get("tire-id", "street_tire")
	var tire_data = GameState.get_tire_data(tire_id)
	
	if tire_data.is_empty():
		print("Warning: No tire data found for '%s', using defaults" % tire_id)
		return
	
	lateral_friction = tire_data.get("grip", lateral_friction)
	drift_lateral_friction = tire_data.get("drift_friction", drift_lateral_friction)
	traction_bonus = tire_data.get("traction_bonus", 0.0) 
	
	var speed_bonus = tire_data.get("max_speed_bonus", 0.0)
	max_speed += speed_bonus
	
	print("Tire stats loaded: %s (Grip: %s, Drift: %s, Speed Bonus: %s, Traction:  %s)" % [tire_id, lateral_friction, drift_lateral_friction, speed_bonus, traction_bonus])

func _calculate_traction(speed):
	if speed < 30.0 and accel_input > 0.8:
		var spin_factor = 1.0 - ((30.0 - speed) / 30.0) * (0.4 - traction_bonus)
		return clamp(spin_factor, 0.5, 1.0)
	return 1.0

func _physics_process(delta):
	read_input()
	apply_drift()
	apply_engine(delta)
	apply_friction(delta)
	apply_steering(delta)
	move_and_slide()

# --------------------------------------------------
# INPUT
# --------------------------------------------------

func read_input():
	accel_input = Input.get_axis("brake", "accelerate")
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
		tire_front_left.rotation_degrees = 75.0
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
# DRIFT
# --------------------------------------------------

func apply_drift():
	var target_friction: float
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
# ENGINE (REALISTIC ACCELERATION)
# --------------------------------------------------

func apply_engine(delta):
	var forward = transform.x
	var current_speed = velocity.length()
	
	# ----- GEAR SIMULATION -----
	var gear_ratio = _get_gear_ratio(current_speed)
	
	# ----- POWER CURVE (aggressive falloff at high speeds) -----
	var speed_ratio = clamp(current_speed / max_speed, 0.0, 1.0)
	var power_factor = pow(1.0 - speed_ratio, 2.2)
	
	# ----- WEIGHT AFFECTS ACCELERATION -----
	var weight_modifier = 1.0 / sqrt(weight)
	
	# ----- TRACTION (wheelspin at low speeds) -----
	traction = _calculate_traction(current_speed)
	
	# ----- CALCULATE TARGET POWER -----
	var target_power:  float = 0.0
	
	if accel_input > 0.0:
		target_power = acceleration_force * power_factor * gear_ratio * weight_modifier * traction
		if is_drifting: 
			target_power *= 0.6  # Reduced power while drifting
	
	# ----- THROTTLE RESPONSE DELAY (key for realism!) -----
	if accel_input > 0.0:
		# Accelerating - engine builds power gradually
		engine_power = lerp(engine_power, target_power, engine_response * delta)
		velocity += forward * engine_power * accel_input * delta
		
	elif accel_input < 0.0:
		# Braking or reversing
		var forward_speed = velocity.dot(forward)
		
		if forward_speed > 10.0:
			# Braking (instant response for safety feel)
			velocity += forward * brake_force * accel_input * delta
			engine_power = lerp(engine_power, 0.0, engine_response * 3.0 * delta)
		else:
			# Reverse (also with throttle delay)
			var reverse_ratio = clamp(current_speed / reverse_speed, 0.0, 1.0)
			var reverse_power = pow(1.0 - reverse_ratio, 1.5)
			var target_reverse = reverse_speed * reverse_power * weight_modifier
			engine_power = lerp(engine_power, target_reverse, engine_response * delta)
			velocity += forward * engine_power * accel_input * delta
	else:
		# No input - engine power drops off
		engine_power = lerp(engine_power, 0.0, engine_response * 2.0 * delta)
	
	velocity = velocity.limit_length(max_speed)
	
	# Update RPM for sound/visual feedback (optional use)
	current_rpm = lerp(current_rpm, speed_ratio * max_rpm * gear_ratio, 5.0 * delta)
	
	update_speed_animations()

func _get_gear_ratio(speed: float) -> float:
	# Simulates automatic transmission - each gear has a power band
	# First gear: low speed, high torque multiplier
	# Higher gears: less torque, more top speed
	var shift_points = [0.0, 0.15, 0.30, 0.50, 0.70, 0.85]  # % of max speed
	var gear_powers =  [0.5, 1.0,  0.88, 0.75, 0.60, 0.45]  # power multiplier
	
	var speed_percent = speed / max_speed
	
	for i in range(shift_points.size() - 1):
		if speed_percent < shift_points[i + 1]:
			var t = (speed_percent - shift_points[i]) / (shift_points[i + 1] - shift_points[i])
			return lerp(gear_powers[i], gear_powers[i + 1], t)
	
	return gear_powers[-1]


# --------------------------------------------------
# SPEED ANIMATIONS
# --------------------------------------------------

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
				animated_tracks.show()
				animated_tracks.speed_scale = anim_speed_scale
			else:
				animated_tracks.hide()
				animated_tracks.stop()
	else:
		_stop_all_sprites()

func _play_all_sprites_forward(speed_scale: float):
	tire_back_left.play()
	tire_back_right.play()
	tire_front_left.play()
	tire_front_right.play()
	_set_all_speed_scales(speed_scale)

func _play_all_sprites_backward(speed_scale: float):
	tire_back_left.play_backwards()
	tire_back_right.play_backwards()
	tire_front_left.play_backwards()
	tire_front_right.play_backwards()
	_set_all_speed_scales(speed_scale)

func _set_all_speed_scales(speed_scale: float):
	tire_back_left.speed_scale = speed_scale
	tire_back_right.speed_scale = speed_scale
	tire_front_left.speed_scale = speed_scale
	tire_front_right.speed_scale = speed_scale

func _stop_all_sprites():
	tire_back_left.stop()
	tire_back_right.stop()
	tire_front_left.stop()
	tire_front_right.stop()
	animated_tracks.hide()
	animated_tracks.stop()

# --------------------------------------------------
# FRICTION
# --------------------------------------------------

func apply_friction(delta):
	var forward = transform.x
	var right = transform.y

	var forward_speed = velocity.dot(forward)
	var lateral_speed = velocity.dot(right)

	lateral_speed = lerp(lateral_speed, 0.0, lateral_friction * delta)

	var speed_factor = clamp(velocity.length() / max_speed, 0.2, 1.0)
	forward_speed = lerp(forward_speed, 0.0, rolling_friction * speed_factor * delta)

	velocity = forward * forward_speed + right * lateral_speed

# --------------------------------------------------
# STEERING
# --------------------------------------------------

func apply_steering(delta):
	var speed = velocity.length()
	if speed < 5.0:
		return
	var speed_factor = clamp(speed / max_speed, 0.3, 1.0)
	var steer_modifier = 1.0 - (speed_factor * 0.4)
	var steer_amount = steer_input * steering_speed * steer_modifier
	rotation += steer_amount * delta
