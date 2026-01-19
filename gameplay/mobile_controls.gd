extends Control

@onready var btn_left:  TouchScreenButton = $SteerLeft
@onready var btn_right: TouchScreenButton = $SteerRight
@onready var btn_gas:  TouchScreenButton = $Gas
@onready var btn_brake:  TouchScreenButton = $Brake
@onready var btn_handbrake: TouchScreenButton = $Handbrake

func _ready() -> void:
	# For Button, use pressed/released signals
	btn_left.pressed.connect(func(): Input.action_press("steer_left"))
	btn_left.released. connect(func(): Input.action_release("steer_left"))
	
	btn_right.pressed.connect(func(): Input.action_press("steer_right"))
	btn_right.released.connect(func(): Input.action_release("steer_right"))
	
	btn_gas.pressed.connect(func(): Input.action_press("accelerate"))
	btn_gas.released.connect(func(): Input.action_release("accelerate"))
	
	btn_brake.pressed.connect(func(): Input.action_press("brake"))
	btn_brake.released.connect(func(): Input.action_release("brake"))
	
	if btn_handbrake:
		btn_handbrake.pressed.connect(func(): Input.action_press("handbrake"))
		btn_handbrake.released.connect(func(): Input.action_release("handbrake"))
