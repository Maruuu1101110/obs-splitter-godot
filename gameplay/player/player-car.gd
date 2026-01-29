extends CharacterBody2D

# !!! READ !!!
# GIN FEED KO NI SA AI, 
# SYA NA NI NAG TIMPLA SANG PARAMS

# ----- Game Mechanics Related -----
var armor := 0.0				# this increases when equipped with weapons
var damage := 0.0				# this increases when equipped with weapons
var bonus_speed := 0.0
var bonus_dmg := 0.0
var bonus_armor := 0.0

# ===== CAR STATS (loaded from config) =====
var acceleration_force := 100.0
var brake_force := 600.0
var max_speed := 280.0
var reverse_speed := 140.0
var weight := 1.0
var car_category: String
var actual_speed

# ===== TIRE STATS (loaded from config) =====
var steering_speed := 2.2
var lateral_friction := 16.0
var rolling_friction := 2.5
var drift_lateral_friction := 2.0
var drift_steering_speed := 4.0

var base_lateral_friction := 16.0
var base_steering_speed := 2.2
var base_rolling_friction := rolling_friction
var base_drift_lateral_friction := drift_lateral_friction
var base_drift_steering_speed := drift_steering_speed


const DRIFT_EASE := 0.15
const RETURN_EASE := 0.01

# PLAYER STATE
var accel_input := 0.0
var steer_input := 0.0
var is_drifting := false
var is_moving_backward := false
var accelerating := false

# ------ GAME MECHANICS ------
var breadcrumb = []
var curr_hp
var max_hp
var damage_cd = 0.5
var damage_timer = 0.0
var is_being_chased = false
var is_punctured = false
var punctured_tire_speed = max_speed * 0.2
var biome = "default"
var equipment = "nothing"
var player_nitro_buffs = []
var player_defense_buffs = []
var immune_to_puncture = false
var police_spawnpoint

# ------ DAMAGE TEXT ------
var floating_text = preload("res://ui/floating_text.tscn")

# ------ BIOME MULTIPLIERS ------
var biome_multipliers = {
	"default": {
		"lateral_friction": 1.0,
		"rolling_friction": 1.0,
		"drift_friction": 1.0,
		"steering_speed": 1.0,
		"drift_steering": 1.0,
		"engine_power": 1.0,
		"target_friction": 1.0
	},
	"ice": {
		"lateral_friction": 0.22,
		"rolling_friction": 0.18,
		"drift_friction": 0.6,
		"steering_speed": 0.55,
		"drift_steering": 0.7,
		"engine_power": 1.0,
		"target_friction": 1.0
	},
	"offroad": {
		"lateral_friction": 1.25,
		"rolling_friction": 2.2,
		"drift_friction": 1.4,
		"steering_speed": 0.85,
		"drift_steering": 0.9,
		"engine_power": 0.85,
		"target_friction": 0.75
	}
}

# ------ BUFF MAPPING ------
var buff_map = {
	"nitro": {
		"path": "res://gameplay/effects/nitro_buff.tres",
		"buff": nitro_buff,
	},
	"defense": {
		"path": "res://gameplay/effects/defense_buff.tres",
		"buff": defense_buff
	}
}

# NODES
@onready var popup_location = $PopupLocation
@onready var buff_container = $BuffContainer
@onready var police_spawner = $PoliceSpawn

# CAR BODY
@onready var car_sprite = $CarAnimation/Body

# AUDIO RELATED
@onready var engine_sound_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# CAR TIRES
@onready var tire_front_left = $CarAnimation/TireLayout/FrontLeft
@onready var tire_front_right = $CarAnimation/TireLayout/FrontRight
@onready var tire_back_left = $CarAnimation/TireLayout/BackLeft
@onready var tire_back_right = $CarAnimation/TireLayout/BackRight

# CAR EQUIPMENT
@onready var equipment_sprite = $CarAnimation/Equipment

# CAR TRACKS
@onready var animated_tracks = $TrailAnimation/AnimatedTrack

func _ready():
	add_to_group('player')
	GameState.player = self
	_load_car_visuals()
	_apply_car_stats()
	_apply_tire_stats()
	fetch_engine_sound()
	engine_sound_player.play()
	engine_sound_player.pitch_scale = 0.5 
	_apply_equipment_stats()
	
	#police_spawnpoint = police_spawner.position
	
	#apply_buff("nitro", 10, 100)
	#apply_buff("defense", 15, 30)
	
	base_lateral_friction = lateral_friction
	base_steering_speed = steering_speed
	base_rolling_friction = rolling_friction
	base_drift_lateral_friction = drift_lateral_friction
	base_drift_steering_speed = drift_steering_speed
	
	equipment = GameState.player_configuration["equipment-id"]


func _load_car_visuals():
	car_sprite.texture = load(GameState.player_configuration["body-type"])
	car_sprite.self_modulate = GameState.player_configuration["body-color"]
	
	var tire_texture = load(GameState.player_configuration["tire-type"])
	tire_back_left.sprite_frames = tire_texture
	tire_back_right.sprite_frames = tire_texture
	tire_front_left.sprite_frames = tire_texture
	tire_front_right.sprite_frames = tire_texture
	
	equipment_sprite.texture = load(GameState.player_configuration["equipment"])

func _apply_car_stats():
	var body_id = GameState.player_configuration.get("body-id", "street-1")
	var body_data = GameState.get_body_data(body_id)
	var body_category = GameState.player_configuration.get("body-category")
	
	if body_data. is_empty():
		print("Warning: No body data found for '%s', using defaults" % body_id)
		return
		
	car_category = body_category
	
	max_speed = body_data.get("max_speed", max_speed)
	acceleration_force = body_data.get("acceleration", acceleration_force)
	curr_hp = body_data.get("health", 100)
	max_hp = body_data.get("health",100)
	weight = body_data.get("weight", weight)
	
	reverse_speed = max_speed * 0.5
	actual_speed = max_speed
	brake_force = acceleration_force * 0.6
	
	print("Body stats loaded: %s (Speed: %s, Accel:  %s, HP: %s)" % [body_id, actual_speed, acceleration_force, curr_hp])

func _apply_tire_stats():
	var tire_id = GameState. player_configuration.get("tire-id", "street_tire")
	var tire_data = GameState.get_tire_data(tire_id)
	
	if tire_data. is_empty():
		print("Warning:  No tire data found for '%s', using defaults" % tire_id)
		return
	
	lateral_friction = tire_data.get("grip", lateral_friction)
	drift_lateral_friction = tire_data.get("drift_friction", drift_lateral_friction)
	
	var speed_bonus = tire_data.get("max_speed_bonus", 0.0)
	max_speed += speed_bonus
	actual_speed = max_speed
	
	print("Tire stats loaded: %s (Grip: %s, Drift: %s, Speed Bonus: %s)" % [tire_id, lateral_friction, drift_lateral_friction, speed_bonus])
	
func _apply_equipment_stats():
	var equipment_id = GameState.player_configuration.get("equipment-id", "nothing")
	var equipment_data = GameState.get_equipment_data(equipment_id)
	
	if equipment_data.is_empty():
		print("Warning: No equipment data found for '%s', using defaults" % equipment_id)
		return
		
	damage = equipment_data.get("damage", damage)
	armor = equipment_data.get("armor", armor)
	
	# Apply speed penalty from equipment
	var speed_penalty = equipment_data.get("speed_penalty", 0.0)
	weight += equipment_data.get("weight", weight)
	max_speed -= speed_penalty
	actual_speed = max_speed
	
	print("Equipment stats loaded: %s (Damage: %s, Armor: %s, Weight: %s, Speed Penalty: %s)" % [equipment_id, damage, armor, weight, speed_penalty])
	print(max_speed)
	
	if equipment_id == "front_blade":
		immune_to_puncture = true

func _physics_process(delta):
	damage_timer -= delta
	read_input()
	toggle_camera()
	apply_drift()
	apply_engine(delta)
	apply_friction(delta)
	apply_steering(delta)
	update_engine_sound()
	move_and_slide()
	apply_biome_multipliers(biome_multipliers[biome])
	#print("Actual speed: %d" % actual_speed)
	
	buff_container.global_position = global_position
	buff_container.global_rotation = 0.0
	
	if is_punctured:
		puncture_tire(delta)
		get_parent().effects_add_item("res://assets/Road Racers Adrenaline Assets/Pickables & Obstacles/police_tire_puncture.png")
	else:
		#var body_id = GameState.player_configuration. get("body-id", "street-1")
		#var body_data = GameState.get_body_data(body_id)
		#max_speed = body_data.get("max_speed", max_speed)
		actual_speed = max_speed + bonus_speed
		reverse_speed = actual_speed * 0.5
		get_parent().effects_remove_item("res://assets/Road Racers Adrenaline Assets/Pickables & Obstacles/police_tire_puncture.png")
	
	if damage_timer > 0:
		return
	detect_collision()

# --------------------------------------------------

func toggle_camera():
	var camera = $Camera2D
	if Input.is_action_just_pressed("camera_toggle"):
		camera.ignore_rotation = !camera.ignore_rotation
		
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
		tire_front_right.rotation_degrees = 105.0
		animated_tracks.animation = "track_right"
	else: 
		tire_front_left.rotation_degrees = 90.0
		tire_front_right.rotation_degrees = 90.0
		animated_tracks.animation = "track_def"

func fetch_engine_sound():
	var offroad_engine = preload("res://audio/car_sounds/offroad-engine-61234.mp3")
	var street_engine = preload("res://audio/car_sounds/streetcar-engine-71198.mp3")
	var sport_engine = preload("res://audio/car_sounds/engine-running-byte_6-229112.mp3")
	var selected_sound = offroad_engine
	match car_category:
		"offroad":
			selected_sound = offroad_engine
		"street":
			selected_sound = street_engine
		"sport":
			selected_sound = sport_engine
	
	engine_sound_player.stream = selected_sound
		

func update_engine_sound():
	var base_pitch = 0.5
	var max_pitch = 1.8 
	var speed_factor = velocity.length() / max_speed
	var smoothing = 0.05

	if Input.is_action_pressed("accelerate"):
		if not accelerating:
			accelerating = true
		var target_pitch = lerp(base_pitch, max_pitch, speed_factor)
		engine_sound_player.pitch_scale = lerp(engine_sound_player.pitch_scale, target_pitch, smoothing)
	else:
		engine_sound_player.pitch_scale = lerp(engine_sound_player.pitch_scale, base_pitch, smoothing)
		accelerating = false


# --------------------------------------------------

func apply_drift():
	var target_friction: float
	var target_steer: float
	var ease_amount: float
	var target_friction_mult = biome_multipliers[biome]["target_friction"]
	
	if is_drifting:
		target_friction = drift_lateral_friction * target_friction_mult
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
	var current_speed = velocity.length()
	
	var speed_ratio = clamp(current_speed / actual_speed, 0.0, 1.0)
	var power_factor = pow(1.0 - speed_ratio, 1.5)
	power_factor = clamp(power_factor, 0.0, 1.0)
	
	var weight_modifier = 1.0 / sqrt(weight)
	
	# Engine power multiplier
	var engine_mult = get_engine_multiplier()
	
	if is_drifting:
		if accel_input > 0.0:
			velocity += forward * acceleration_force * engine_mult * power_factor * weight_modifier * 0.6 * accel_input * delta
	elif accel_input > 0.0:
		velocity += forward * acceleration_force * engine_mult * power_factor * weight_modifier * accel_input * delta
	elif accel_input < 0.0:
		var forward_speed = velocity.dot(forward)
		if forward_speed > 10.0:
			velocity += forward * brake_force * accel_input * delta
		else: 
			var reverse_ratio = clamp(current_speed / reverse_speed, 0.0, 1.0)
			var reverse_power = pow(1.0 - reverse_ratio, 1.5)
			velocity += forward * reverse_speed * reverse_power * accel_input * delta
	
	velocity = velocity.limit_length(actual_speed)
	
	update_speed_animations()

func update_speed_animations():
	var speed = velocity.length()
	if speed > 1.0:
		var anim_speed_scale = clamp(speed / actual_speed, 0.3, 2.5)
		
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

func _play_all_sprites_forward(speed_scale:  float):
	tire_back_left.play()
	tire_back_right.play()
	tire_front_left.play()
	tire_front_right.play()
	_set_all_speed_scales(speed_scale)

func _play_all_sprites_backward(speed_scale:  float):
	tire_back_left.play_backwards()
	tire_back_right.play_backwards()
	tire_front_left.play_backwards()
	tire_front_right.play_backwards()
	_set_all_speed_scales(speed_scale)

func _set_all_speed_scales(speed_scale:  float):
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

func apply_friction(delta):
	var forward = transform.x
	var right = transform.y

	var forward_speed = velocity.dot(forward)
	var lateral_speed = velocity.dot(right)

	lateral_speed = lerp(lateral_speed, 0.0, lateral_friction * delta)

	var speed_factor = clamp(velocity.length() / actual_speed, 0.2, 1.0)
	forward_speed = lerp(forward_speed, 0.0, rolling_friction * speed_factor * delta)

	velocity = forward * forward_speed + right * lateral_speed

# --------------------------------------------------

func apply_steering(delta):
	var speed = velocity.length()
	if speed < 5.0:
		return
	var speed_factor = clamp(speed / actual_speed, 0.3, 1.0)
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
# ================== BIOME-BASED STATS ==================

func apply_biome_multipliers(multipliers: Dictionary):
	lateral_friction = base_lateral_friction * multipliers["lateral_friction"]
	rolling_friction = base_rolling_friction * multipliers["rolling_friction"]
	
	drift_lateral_friction = base_drift_lateral_friction * multipliers["drift_friction"]
	
	steering_speed = base_steering_speed * multipliers["steering_speed"]
	drift_steering_speed = base_drift_steering_speed * multipliers["drift_steering"]
	
# --------------------------------------------------
# ================== BUFF OFFROAD CARS IN OFFROAD MAPS ==================
func get_engine_multiplier() -> float:
	var mult = biome_multipliers[biome]["engine_power"]
	
	if biome == "offroad":
		var body_id = GameState.player_configuration.get("body-id", "street-1")
		var tire_id = GameState.player_configuration.get("tire-id", "street_tire")
		
		if body_id in ["offroad-1", "offroad-2"]:
			mult = 2
		if tire_id == "offroad_tire":
			mult *= 1.2
			
	#print(mult)
			
	return mult
	
# --------------------------------------------------

func apply_buff(buff: String, duration, bonus_mult):
	buff_container.play_buff(buff_map[buff]["path"], duration)
	buff_map[buff]["buff"].call(duration, bonus_mult)

# --------------------------------------------------

func nitro_buff(duration, bonus_mult):
	#print("Actual speed before buff: %d" % actual_speed)
	bonus_speed += 2 * bonus_mult
	if is_punctured:
		actual_speed += bonus_speed
	get_tree().create_timer(duration).timeout.connect(clear_nitro_buff.bind(bonus_mult))
	player_nitro_buffs.append("nitro")
	get_parent().effects_add_item("res://assets/Road Racers Adrenaline Assets/Pickables & Obstacles/nitro.png")

# --------------------------------------------------

func defense_buff(duration, bonus_mult):
	bonus_dmg += 1 * bonus_mult
	bonus_armor += 1.5 * bonus_mult
	immune_to_puncture = true
	
	get_tree().create_timer(duration).timeout.connect(clear_defense_buff.bind(bonus_mult))
	player_defense_buffs.append("defense")
	get_parent().effects_add_item("res://assets/Road Racers Adrenaline Assets/Pickables & Obstacles/defense.png")

# --------------------------------------------------

func clear_nitro_buff(bonus_mult):
	player_nitro_buffs.pop_back()
	if is_punctured:
		actual_speed -= bonus_speed
	bonus_speed -= 2 * bonus_mult
	#print("Bonus nitro cleared, actual speed %d" % actual_speed)
	get_parent().effects_remove_item("res://assets/Road Racers Adrenaline Assets/Pickables & Obstacles/nitro.png")

# --------------------------------------------------

func clear_defense_buff(bonus_mult):
	player_defense_buffs.pop_back()
	bonus_dmg -= 1 * bonus_mult
	bonus_armor -= 1.5 * bonus_mult
	if len(player_defense_buffs) <= 0:
		immune_to_puncture = false
	#print("Bonus defense cleared")
	get_parent().effects_remove_item("res://assets/Road Racers Adrenaline Assets/Pickables & Obstacles/defense.png")

# --------------------------------------------------

func detect_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		#if collider.is_in_group("obstacle"):
			#take_damage(collider.DAMAGE)
			#deal_damage(collider)
			#damage_timer = damage_cd
			#break
			
		for group in ["obstacle", "enemy", "civilian"]:
			if collider.is_in_group(group):
				take_damage(collider.DAMAGE)
				deal_damage(collider)
				damage_timer = damage_cd
				break
			
			
		if collider is TileMapLayer:
			take_damage(2)
			damage_timer = damage_cd
			break

# --------------------------------------------------

func take_damage(amount: float):
	var actual_dmg = int(amount - (armor + bonus_armor))
	curr_hp -= max(actual_dmg, 0)
	curr_hp = max(curr_hp, 0)
	
	if curr_hp <= 0:
		game_over()
		
	if actual_dmg > 0:
		popup_location.popup(str(actual_dmg))
		
	print("Current HP: %d" % curr_hp)

# --------------------------------------------------

func deal_damage(collider: Object):
	collider.take_damage(damage + bonus_dmg)

# --------------------------------------------------

func puncture_tire(delta):
	if actual_speed > punctured_tire_speed:
		actual_speed -= 5 * delta
	else:
		actual_speed = punctured_tire_speed
	#print("Max Speed: %d, Actual Speed: %d" % [max_speed, actual_speed])

# --------------------------------------------------

func game_over():
	GameState.game_over = true
