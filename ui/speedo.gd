extends Control

var player: Node2D
@onready var speed_needle: Sprite2D = $Speed/SpeedNeedle
@onready var rpm_needle: Sprite2D = $Others/RpmNeedle

var needle_speed_deg: float = 0.0
var needle_rpm_deg:   float = 0.0

func _ready() -> void:
	process_mode = 	Node.PROCESS_MODE_PAUSABLE
	speed_needle.rotation_degrees = 0
	rpm_needle.rotation_degrees   = 0
	_try_get_player()

func _process(delta: float) -> void:
	_update_needles(delta)

func _try_get_player() -> void:
	if is_instance_valid(GameState.player):
		player = GameState.player
	else:
		await get_tree().process_frame
		_try_get_player()

func _update_needles(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(speed_needle):
		speed_needle.rotation_degrees = 0
		rpm_needle.rotation_degrees   = 0
		return

	var raw_speed = player.velocity.length()
	var kmh_speed = (raw_speed / 32.0) * 3.6 * 6.5    
	var clamped_kmh = clampf(kmh_speed, 0.0, 190.0)

	var target_speed_deg = lerp(0.0, 180.0, clamped_kmh / 190.0)
	needle_speed_deg = lerp(needle_speed_deg, target_speed_deg, 0.15)
	speed_needle.rotation_degrees = needle_speed_deg
	
	
	var target_rpm = player.accel_input      
	var target_rpm_deg = lerp(0.0, 109.0, target_rpm) 
	needle_rpm_deg = clampf(lerp(needle_rpm_deg, target_rpm_deg, 1 * delta), 0.0, 109.0)
	rpm_needle.rotation_degrees = needle_rpm_deg
