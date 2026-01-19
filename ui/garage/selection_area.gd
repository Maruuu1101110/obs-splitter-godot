extends Control

@onready var list = $HBoxContainer

enum SelectionType { BODY, TIRES, COLOR }

var current_type:  SelectionType = SelectionType.BODY
var items:  Dictionary = {}
@onready var garage: Control = get_parent()

func _ready():
	pass

func _process(delta: float) -> void:
	pass

func build_list():
	# Clear old buttons
	for child in list.get_children():
		child.queue_free()
	
	# Build new ones
	for item_id in items. keys():
		var item_data = items[item_id]
		
		var btn = Button.new()
		btn.text = item_data.name
		btn.icon = load(item_data.icon)
		btn. icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(96, 96)
		btn.expand_icon = true
		
		btn.pressed.connect(_on_item_selected.bind(item_id, item_data))
		
		list.add_child(btn)

func _on_item_selected(item_id:  String, item_data: Dictionary):
	match current_type: 
		
		# FOR BODY
		SelectionType.BODY:
			garage.selected_body_frame = load(item_data.tileframe)
			GameState.player_configuration['body-type'] = item_data['tileframe']
			GameState.player_configuration['body-id'] = item_id
			print("Selected body:  ", item_id)
			
		# FOR TIRES
		SelectionType.TIRES:
			garage.selected_tire_frame = load(item_data.tileframe)
			GameState.player_configuration['tire-type'] = item_data['tileframe']
			GameState.player_configuration['tire-id'] = item_id
			print("Selected tires: ", item_id)
			
		# FOR COLORS
		SelectionType.COLOR: 
			# SOON
			print("Selected color: ", item_id)

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
	build_list()
	
func set_cars(new_items:  Dictionary, type: SelectionType = SelectionType. BODY):
	current_type = type
	items = new_items
	build_list()
