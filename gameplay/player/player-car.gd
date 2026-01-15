extends CharacterBody2D

## ===== TUNED FOR 32x32 =====
#@export var acceleration_force := 880.0
#@export var brake_force := 420.0
#@export var max_speed := 3400.0
#@export var reverse_speed := 100.0
#
#@export var steering_speed := 50.2          # radians/sec
#@export var lateral_friction := 14.0        # kills sideways sliding
#@export var rolling_friction := 6.0

## ===== DRIFT TUNING =====
#@export var acceleration_force := 500.0
#@export var brake_force := 400.0
#@export var max_speed := 180.0
#@export var reverse_speed := 120.0
#
#@export var steering_speed := 2.5          # Snappy steering to initiate drifts
#@export var lateral_friction := 1.5        # LOW value lets you slide sideways
#@export var rolling_friction := 1.5        # Long coasting distance

# ===== BALANCED ARCADE =====
## Alter ang mga params if needed, mga preset ni sang AI ang default
@export var acceleration_force := 1000.0   # Boosted to fight friction
@export var brake_force := 300.0
@export var max_speed := 240.0             # A realistic cap for 32x32
@export var reverse_speed := 10.0

@export var steering_speed := 3.5          # ~200 degrees/sec (Normal turning)
@export var lateral_friction := 16.0        # Grippy tires
@export var rolling_friction := 3.0        # Lower friction so it coasts a bit 

var accel_input := 0.0
var steer_input := 0.0

@onready var car_sprite = $CarAnimation/AnimatedSprite2D
@onready var animated_tracks = $TrailAnimation/AnimatedTrack

func _physics_process(delta):
	read_input()
	apply_engine(delta)
	apply_friction(delta)
	apply_steering(delta)
	move_and_slide()

# --------------------------------------------------

func read_input():
	accel_input = Input.get_axis("brake", "accelerate")
	if accel_input > 0:
		steer_input = Input.get_axis("steer_left", "steer_right")
	elif accel_input < 0:
		steer_input = Input.get_axis("steer_right", "steer_left")
	
	if Input.is_action_pressed("steer_left"):
		car_sprite.animation = "steering_left"
		animated_tracks.animation = "track_left"
	elif Input.is_action_pressed("steer_right"):
		car_sprite.animation = "steering_right"
		animated_tracks.animation = "track_right"
	else:
		car_sprite.animation = "default"
		animated_tracks.animation = "track_def"
# --------------------------------------------------

func apply_engine(delta):
	var forward = transform.x
	if accel_input > 0.0:
		velocity += forward * acceleration_force * accel_input * delta
	elif accel_input < 0.0:
		velocity += forward * brake_force * accel_input * delta
		
	velocity = velocity.limit_length(max_speed)
	print(velocity)
	# Animation related
	var speed = velocity.length()
	print(speed)
	if speed > 1.0:
		car_sprite.play()
		car_sprite.speed_scale = clamp(speed / max_speed, 0.1, 3.0)
		
		if speed > 50.0 and Input.is_action_pressed("accelerate"):
			animated_tracks.play()
			animated_tracks.show()
			animated_tracks.speed_scale = clamp(speed / max_speed, 0.1, 3.0)
		else:
			animated_tracks.hide()
			animated_tracks.stop()
	else:
		car_sprite.stop()
		


func apply_friction(delta):
	var forward = transform.x
	var right = transform.y

	var forward_speed = velocity.dot(forward)
	var lateral_speed = velocity.dot(right)

	# Kill sideways velocity (KEY FIX)
	lateral_speed = lerp(lateral_speed, 0.0, lateral_friction * delta)

	# Rolling resistance
	forward_speed = lerp(forward_speed, 0.0, rolling_friction * delta)

	velocity = forward * forward_speed + right * lateral_speed

# --------------------------------------------------

func apply_steering(delta):
	var speed_factor = clamp(velocity.length() / max_speed, 0.0, 1.0)
	var steer_amount = steer_input * steering_speed * speed_factor
	rotation += steer_amount * delta
	



#var wheel_base = 16
#var steering_angle = 30
#var engine_power = 220
#var friction = -120
#var drag = -0.18
#var braking = -300
#var max_speed_reverse = 120
#var slip_speed = 140
#var traction_fast = 6
#var traction_slow = 14
#
#var acceleration = Vector2.ZERO
#var steer_direction = 0
#
#func _physics_process(delta):
	#acceleration = Vector2.ZERO
	#get_input()
	#apply_friction(delta)
	#calculate_steering(delta)
	#velocity += acceleration * delta
	#move_and_slide()
	#
#func apply_friction(delta):
	#if acceleration == Vector2.ZERO and velocity.length() < 10:
		#velocity = Vector2.ZERO
	#var friction_force = velocity * friction * delta
	#var drag_force = velocity * velocity.length() * drag * delta
	#acceleration += drag_force + friction_force
	#
#func get_input():
	#var turn = Input.get_axis("steer_left", "steer_right")
	#steer_direction = turn * deg_to_rad(steering_angle)
	#if Input.is_action_pressed("accelerate"):
		#acceleration = transform.x * engine_power
	#if Input.is_action_pressed("brake"):
		#acceleration = transform.x * braking
	#
#func calculate_steering(delta):
	#var rear_wheel = position - transform.x * wheel_base / 2.0
	#var front_wheel = position + transform.x * wheel_base / 2.0
	#rear_wheel += velocity * delta
	#front_wheel += velocity.rotated(steer_direction) * delta
	#var new_heading = rear_wheel.direction_to(front_wheel)
	#var traction = traction_slow
	#if velocity.length() > slip_speed:
		#traction = traction_fast
	#var d = new_heading.dot(velocity.normalized())
	#if d > 0:
		#velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	#if d < 0:
		#velocity = -new_heading * min(velocity.length(), max_speed_reverse)
##	velocity = new_heading * velocity.length()
	#rotation = new_heading.angle()
