extends Control

# ----- BODY DATA -----
var body_sprites_map = {
	"offroad-1": {
		"tileframe": "res://ui/garage/car_previews/offroad/offroad-model1.png",
		"icon": "res://ui/garage/car_previews/offroad/offroad-model1.png",
		"category": "offroad",
		"name":  "Hill Crawler 69\n(Offroad)",
	},
	"offroad-2": {
		"tileframe": "res://ui/garage/car_previews/offroad/offroad-model2.png",
		"icon":  "res://ui/garage/car_previews/offroad/offroad-model2.png",
		"category": "offroad",
		"name": "Jip M\n(Offroad)",
	},

	# ---- STREET -----
	"street-1": {
		"tileframe": "res://ui/garage/car_previews/street/street-model1.png",
		"icon":  "res://ui/garage/car_previews/street/street-model1.png",
		"category": "street",
		"name": "Atoyot 34\n(Street)",
	},
	"street-2":  {
		"tileframe": "res://ui/garage/car_previews/street/street-model2.png",
		"icon": "res://ui/garage/car_previews/street/street-model2.png",
		"category": "street",
		"name":  "Silvia T12\n(Street)",
	},

	# ---- SPORT ----
	"sport-1":  {
		"tileframe": "res://ui/garage/car_previews/sport/sport-model1.png",
		"icon":  "res://ui/garage/car_previews/sport/sport-model1.png",
		"category": "sport",
		"name": "Sporty 80\n(Sport)",
	},
	"sport-2":  {
		"tileframe": "res://ui/garage/car_previews/sport/sport-model2.png",
		"icon": "res://ui/garage/car_previews/sport/sport-model2.png",
		"category": "sport",
		"name":  "Turan 9000\n(Sport)",
	}
}

# ----- TIRE DATA -----
var tire_sprites_map = {
	"offroad_tire": {
		"tileframe":  "res://ui/garage/car_previews/offroad/offroad-tire-anim.tres",
		"icon":  "res://ui/garage/car_previews/offroad/tires_offroad_0001.png",
		"name":  "Off-Road Tires",
		"description": "Great grip on dirt and rough terrain",
	},
	"street_tire": {
		"tileframe":  "res://ui/garage/car_previews/street/street-tire-anim.tres",
		"icon": "res://ui/garage/car_previews/street/street-tire_0001.png",
		"name": "Street Tires",
		"description": "Balanced performance for city driving",
	},
	"sport_tire":  {
		"tileframe": "res://ui/garage/car_previews/sport/sport-tire-anim.tres",
		"icon": "res://ui/garage/car_previews/sport/sport-tire_0001.png",  
		"name": "Sport Tires",
		"description": "Maximum grip and speed on asphalt",
	},
}

# COLORS BUTTON
var color_set = {
	"blue": {
		"name": "Blue",
		"icon": null,  
		"value": "3399ffff",
		"description": "Classic cool blue",
		"rarity": "common"
	},
	"red": {
		"name": "Red",
		"icon": null,
		"value": "e61a1aff",
		"description": "Fiery red, aggressive",
		"rarity": "rare"
	},
	"green": {
		"name": "Green",
		"icon": null,
		"value": "1acc4dff",
		"description": "Fresh and calm",
		"rarity": "common"
	},
	"yellow": {
		"name": "Yellow",
		"icon": null,
		"value": "ffe61aff",
		"description": "Bright and eye-catching",
		"rarity": "uncommon"
	},
	"purple": {
		"name": "Purple",
		"icon": null,
		"value": "9933ccff",
		"description": "Mysterious and luxurious",
		"rarity": "epic"
	},
	"orange": {
		"name": "Orange",
		"icon": null,
		"value": "ff8000ff",
		"description": "Hot and energetic",
		"rarity": "rare"
	},
	"white": {
		"name": "White",
		"icon": null,
		"value": "ffffffff",
		"description": "Clean and sleek",
		"rarity": "common"
	},
	"black": {
		"name": "Black",
		"icon": null,
		"value": "000000ff",
		"description": "Dark and mysterious",
		"rarity": "common"
	},
}


# ----- EQUIPMENT DATA -----
var equipment_sprites_map = {
	"snow_plow": {
		"tileframe": "res://ui/garage/car_previews/equipment/snow_plow.png",
		"icon": "res://ui/garage/car_previews/equipment/snow_plow.png",
		"damage": 20.0,
		"armor": 30.0,
		"weight": 0.15,
		"speed_penalty": 50.0,
		"name": "Snow Plow",
		"description": "Effective for clearing snowmen and other light debris"
	},
	"front_blade": {
		"tileframe": "res://ui/garage/car_previews/equipment/front_blade.png",
		"icon": "res://ui/garage/car_previews/equipment/front_blade.png",
		"damage": 60.0,
		"armor": 30.0,
		"weight": 0.35,
		"speed_penalty": 80.0,
		"name": "Front Blade",
		"description": "Effective against heavier debris. Can clear tire punctures"
	},
	"mine_claws": {
		"tileframe": "res://ui/garage/car_previews/equipment/mine_flail.png",
		"icon": "res://ui/garage/car_previews/equipment/mine_flail.png",
		"damage": 30.0,
		"armor": 30.0,
		"weight": 0.30,
		"speed_penalty": 65.0,
		"name": "Mine Claws",
		"description": "Higher loot chance"
	},
	"nothing": {
		"tileframe": "res://ui/garage/car_previews/equipment/nothing.png",
		"icon": "res://ui/garage/car_previews/equipment/nothing.png",
		"damage": 0.0,
		"armor": 0.0,
		"weight": 0.0,
		"speed_penalty": 0.0,
		"name": "Nothing",
		"description": "Nothing"
	}
}

# PREVIEW NODE PATHS
@onready var sprite = $PreviewArea/CarPreview/Body
@onready var tire_fl = $PreviewArea/CarPreview/FrontPair/TireFrontLeft
@onready var tire_fr = $PreviewArea/CarPreview/FrontPair/TireFrontRight
@onready var tire_bl = $PreviewArea/CarPreview/BackPair/TireBackLeft
@onready var tire_br = $PreviewArea/CarPreview/BackPair/TireBackRight

@onready var body_stats_label: RichTextLabel = $PreviewArea/StatsPanel/BodyStatsLabel
@onready var tire_stats_label: RichTextLabel = $PreviewArea/StatsPanel/TireStatsLabel

@onready var equipment = $PreviewArea/CarPreview/Equipment
@onready var selection_area_node = $SelectionArea

# SELECTED DATA ASSETS 
var selected_body_color
var selected_body_frame:  Texture
var selected_tire_frame: SpriteFrames
var selected_body_id
var selected_tire_id
var selected_equipment

func _ready() -> void:
	selected_body_frame = load(GameState.player_configuration['body-type'])
	selected_tire_frame = load(GameState.player_configuration['tire-type'])
	selected_body_id = GameState.player_configuration["body-id"]
	selected_tire_id = GameState.player_configuration["tire-id"]
	selected_body_color = GameState.player_configuration['body-color']
	selected_equipment = load(GameState.player_configuration['equipment'])
	_apply_frames()
	_apply_color()
	_display_body_stats()
	_display_tire_stats()
	_play_all_animations()

func _process(delta:  float) -> void:
	_apply_color()
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
	
	if equipment.texture != selected_equipment:
		equipment.texture = selected_equipment

func _apply_color():
	sprite.self_modulate = Color(selected_body_color)

func _play_all_animations():
	_play_tire_animations()

func _play_tire_animations():
	tire_fl.play()
	tire_fr.play()
	tire_bl.play()
	tire_br. play()

# CAR STATS
func _display_body_stats():
	var body_data = GameState.get_body_data(selected_body_id)
	body_stats_label.text = """[font_size=40]%s[/font_size]

◆ [b]Max Speed[/b]:			|	%s %%
◆ [b]Acceleration[/b]:		|	%s %%
◆ [b]Weight[/b]:					|	%s
◆ [b]Health[/b]:						|	%s
			""" % [
				body_sprites_map[selected_body_id]["name"],
				(body_data["max_speed"] / 32.0) * 3.6 * 6.5, # Converter to kmh
				body_data["acceleration"],
				body_data["weight"],
				body_data["health"]
			]
	print("Body Stats Loaded")
	
@onready var selection_area: Control = $SelectionArea
func _display_tire_stats():
	var tire_data = GameState.get_tire_data(selected_tire_id)
	tire_stats_label.text = """[font_size=40]%s[/font_size]

◆ [b]Grip[/b]:						|	%s
◆ [b]Drift Control[/b]:	|	%s
◆ [b]Speed Bonus[/b]:	|	%s
			""" % [
				tire_sprites_map[selected_tire_id]["name"],
				selection_area.make_bar(selection_area.stat_to_bar(tire_data.get("grip", 0), 0, 10)),
				selection_area.make_bar(selection_area.stat_to_bar(tire_data.get("drift_friction", 0), 0, 10)),
				selection_area.make_bar(selection_area.stat_to_bar(tire_data.get("max_speed_bonus", 0), -20, 20)),
			]
	print("Tire Stats Loaded")

# CALLBACKS FOR BUTTONS
func _on_back_pressed():
	print("Go Back Button Pressed")
	get_parent().close_overlay($/root/Main/UI/Garage)
	
func _on_save_button_pressed() -> void:
	GameState.save_player_config()
	get_parent().close_overlay($/root/Main/UI/Garage)

func _on_body_pressed() -> void:
	selection_area_node.set_body_items(body_sprites_map)

func _on_tires_pressed() -> void:
	selection_area_node.set_tire_items(tire_sprites_map)

func _on_color_pressed() -> void:
	selection_area_node.set_color_items(color_set)

func _on_equipments_pressed() -> void:
	selection_area_node.set_equipment(equipment_sprites_map)
