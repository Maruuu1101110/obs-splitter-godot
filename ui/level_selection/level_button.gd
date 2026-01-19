extends Button

@export var level_id: int
@export var unlocked := false
@export var selected := false:
	set(value):
		selected = value
		_update_selected()

@onready var lock_icon = $LockedIcon
@onready var selected_icon = $SelectedIcon

func _ready():
	disabled = !unlocked
	lock_icon.visible = !unlocked
	_update_selected()

func _update_selected():
	if selected_icon:
		selected_icon.visible = selected
