extends Control

# ----- BODY DATA -----
var body_sprites_map = {
	"offroad-1":  {
		"tileframe": "res://ui/garage/car_previews/offroad/offroad-model1.png",
		"icon": "res://ui/garage/car_previews/offroad/offroad-model1.png",
		"name": "Hill Crawler 69\n(Offroad)",
		"max_speed": 240.0,
		"acceleration": 600.0,
		"weight": 1.2, 
		"health": 150.0,
	},	
	"offroad-2":  {
		"tileframe": "res://ui/garage/car_previews/offroad/offroad-model2.png",
		"icon": "res://ui/garage/car_previews/offroad/offroad-model2.png",
		"name": "Jip M\n(Offroad)",
		"max_speed": 235.0,
		"acceleration": 580.0,
		"weight": 1.5, 
		"health": 160.0,
	},

	# ----  STREET -----
	"street-1": {
		"tileframe": "res://ui/garage/car_previews/street/street-model1.png",
		"icon": "res://ui/garage/car_previews/street/street-model1.png",
		"name": "Atoyot 34\n(Street)",
		"max_speed": 270.0,
		"acceleration": 720.0,
		"weight": 1.0,
		"health": 120.0,
	},
	"street-2": {
		"tileframe": "res://ui/garage/car_previews/street/street-model2.png",
		"icon": "res://ui/garage/car_previews/street/street-model2.png",
		"name": "Silvia T12\n(Street)",
		"max_speed": 285.0,
		"acceleration": 760.0,
		"weight": 0.95,
		"health": 115.0,
	},

	# ---- SPORT ----
	"sport-1": {
		"tileframe": "res://ui/garage/car_previews/sport/sport-model1.png",
		"icon":  "res://ui/garage/car_previews/sport/sport-model1.png",
		"name": "Sporty 80\n(Sport)",
		"max_speed": 320.0,
		"acceleration": 900.0,
		"weight": 0.8,
		"health": 95.0,
	},
	"sport-2": {
		"tileframe": "res://ui/garage/car_previews/sport/sport-model2.png",
		"icon":  "res://ui/garage/car_previews/sport/sport-model2.png",
		"name": "Turan 9000\n(Sport)",
		"max_speed": 340.0,
		"acceleration": 980.0,
		"weight": 0.75,
		"health": 85.0,
	}
}

# ----- TIRE DATA -----
var tire_sprites_map = {
	"offroad_tire": {
		"tileframe": "res://ui/garage/car_previews/offroad/offroad-tire-anim.tres",
		"icon": "res://ui/garage/car_previews/offroad/tires_offroad_0001.png",
		"grip":  12.0,
		"drift_friction": 3.0,
		"max_speed_bonus": -10.0, 
		"name": "Off-Road Tires",
		"description": "Great grip on dirt and rough terrain"
	},
	"street_tire": {
		"tileframe": "res://ui/garage/car_previews/street/street-tire-anim.tres",
		"icon": "res://ui/garage/car_previews/street/street-tire_0001.png",
		"grip":  16.0,
		"drift_friction":  2.0,
		"max_speed_bonus": 0.0,
		"name": "Street Tires",
		"description":  "Balanced performance for city driving"
	},
	"sport_tire": {
		"tileframe": "res://ui/garage/car_previews/sport/sport-tire-anim.tres",
		"icon": "res://ui/garage/car_previews/sport/sport-tire_0001.png",
		"grip":  20.0,
		"drift_friction":  1.5,
		"max_speed_bonus": 15.0,
		"name": "Sport Tires",
		"description": "Maximum grip and speed on asphalt"
	},
}

# PREVIEW NODE PATHS
@onready var sprite = $PreviewArea/CarPreview/Body
@onready var tire_fl = $PreviewArea/CarPreview/FrontPair/TireFrontLeft
@onready var tire_fr = $PreviewArea/CarPreview/FrontPair/TireFrontRight
@onready var tire_bl = $PreviewArea/CarPreview/BackPair/TireBackLeft
@onready var tire_br = $PreviewArea/CarPreview/BackPair/TireBackRight

@onready var selection_area_node = $SelectionArea

# SELECTED DATA ASSETS 
var selected_body_frame:  Texture
var selected_tire_frame: SpriteFrames

func _ready() -> void:
	selected_body_frame = load(GameState.player_configuration['body-type'])
	selected_tire_frame = load(GameState.player_configuration['tire-type'])
	_apply_frames()
	_play_all_animations()

func _process(delta:  float) -> void:
	_apply_frames()

func _apply_frames():
	if sprite.texture != selected_body_frame:
		sprite.texture = selected_body_frame
	
	if tire_fl.sprite_frames != selected_tire_frame:
		tire_fl.sprite_frames = selected_tire_frame
		tire_fr.sprite_frames = selected_tire_frame
		tire_bl.sprite_frames = selected_tire_frame
		tire_br.sprite_frames = selected_tire_frame
		_play_tire_animations()

func _play_all_animations():
	_play_tire_animations()

func _play_tire_animations():
	tire_fl.play()
	tire_fr.play()
	tire_bl.play()
	tire_br. play()

# CALLBACKS FOR BUTTONS
func _on_back_pressed():
	print("Go Back Button Pressed")
	get_parent().close_overlay($/root/Main/UI/Garage)
	
func _on_save_button_pressed() -> void:
	GameState.save_player_config()

func _on_body_pressed() -> void:
	selection_area_node.set_body_items(body_sprites_map)

func _on_tires_pressed() -> void:
	selection_area_node. set_tire_items(tire_sprites_map)

func _on_color_pressed() -> void:
# SOOn
	pass
