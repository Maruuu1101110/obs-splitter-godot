extends Control

@onready var list = $HBoxContainer

enum SelectionType { BODY, TIRES, COLOR, EQUIPMENT }

var current_type:  SelectionType = SelectionType.BODY
var items:  Dictionary = {}
@onready var garage: Control = get_parent()
@onready var body_stats_label: RichTextLabel = $"../PreviewArea/StatsPanel/BodyStatsLabel"
@onready var tire_stats_label: RichTextLabel = $"../PreviewArea/StatsPanel/TireStatsLabel"

func _ready():
	pass

func _process(delta: float) -> void:
	pass

func build_list():
	# Clear old buttons
	for child in list.get_children():
		child.queue_free()
	
	for item_id in items.keys():
		var item_data = items[item_id]
		print(item_data)
		var btn = Button.new()
		btn.text = item_data.get("name", "")
		btn.icon = load(item_data.icon) if item_data.icon != null else null
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(96, 96)
		btn.expand_icon = true
		
		btn.pressed.connect(_on_item_selected.bind(item_id, item_data))
		
		list.add_child(btn)

func stat_to_bar(value: float, min: float, max: float, bar_max := 10) -> int:
	var normalized = (value - min) / (max - min)
	return int(clamp(normalized * bar_max, 0, bar_max))

func make_bar(value: int, max := 10) -> String:
	return "█".repeat(value) + "░".repeat(max - value)

func _on_item_selected(item_id:  String, item_data: Dictionary):
	match current_type: 
		# FOR BODY
		SelectionType.BODY:
			var body_data = GameState.get_body_data(item_id)
			garage.selected_body_frame = load(item_data.tileframe)
			GameState.player_configuration['body-type'] = item_data['tileframe']
			GameState.player_configuration['body-category'] = item_data['category']
			GameState.player_configuration['body-id'] = item_id
			body_stats_label.text = """[font_size=40]%s[/font_size]

◆ [b]Max Speed[/b]:			|	%s %%
◆ [b]Acceleration[/b]:		|	%s %%
◆ [b]Weight[/b]:					|	%s
◆ [b]Health[/b]:						|	%s
			""" % [
				item_data.name,
				(body_data["max_speed"] / 32.0) * 3.6 * 6.5, # Converter to kmh
				body_data["acceleration"],
				body_data["weight"],
				body_data["health"]
			]
			print("Selected body:  ", item_id)
			
		# FOR TIRES
		SelectionType.TIRES:
			var tire_data = GameState.get_tire_data(item_id)
			garage.selected_tire_frame = load(item_data.tileframe)
			GameState.player_configuration['tire-type'] = item_data['tileframe']
			GameState.player_configuration['tire-id'] = item_id
			tire_stats_label.text = """[font_size=40]%s[/font_size]

◆ [b]Grip[/b]:						|	%s
◆ [b]Drift Control[/b]:	|	%s
◆ [b]Speed Bonus[/b]:	|	%s
			""" % [
				item_data.name,
				make_bar(stat_to_bar(tire_data["grip"], 0, 10)),
				make_bar(stat_to_bar(tire_data["drift_friction"], 0, 10)),
				make_bar(stat_to_bar(tire_data["max_speed_bonus"], -20, 20)),
			]
			print("Selected tires: ", item_id)
			
		# FOR COLORS
		SelectionType.COLOR: 
			garage.selected_body_color = item_data.get("value", null)
			GameState.player_configuration["body-color"] = item_data.get("value")
			print("Selected color: ", item_id) 
			
		# FOR EQUIPMENTS
		SelectionType.EQUIPMENT:
			garage.selected_equipment = load(item_data.tileframe)
			GameState.player_configuration['equipment'] = item_data['tileframe']
			GameState.player_configuration['equipment-id'] = item_id
			print("Selected equipment: ", item_id)

func set_body_items(new_items: Dictionary):
	current_type = SelectionType.BODY
	items = new_items
	build_list()

func set_tire_items(new_items: Dictionary):
	current_type = SelectionType.TIRES
	items = new_items
	build_list()

func set_color_items(new_items: Dictionary):
	current_type = SelectionType.COLOR
	items = new_items
	make_color_button()
	
func set_equipment(new_items: Dictionary):
	current_type = SelectionType.EQUIPMENT
	items = new_items
	build_list()
	
func set_cars(new_items:  Dictionary, type: SelectionType = SelectionType. BODY):
	current_type = type
	items = new_items
	build_list()

# COLORSSSS

func make_color_button():
	# Clear old buttons
	for child in list.get_children():
		child.queue_free()
	
	for item_id in items.keys():
		var item_data = items[item_id]
		print(item_data)
		
		var btn = Button.new()
		btn.text = item_data.get("name", "")

		var style = StyleBoxFlat.new()
		style.bg_color = item_data.get("value", Color.WHITE)
		style.corner_radius_bottom_left = 16
		style.corner_radius_bottom_right = 16
		style.corner_radius_top_left = 16
		style.corner_radius_top_right = 16
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(96, 96)
		btn.expand_icon = true
		
		btn.pressed.connect(_on_item_selected.bind(item_id, item_data))
		
		list.add_child(btn)
