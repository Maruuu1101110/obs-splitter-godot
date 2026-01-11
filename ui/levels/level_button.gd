extends Button

@export var level_id: int
@export var unlocked := false

@onready var lock_icon = $LockedIcon

func _ready():
	disabled = !unlocked
	if unlocked:
		lock_icon.hide()
	else:
		lock_icon.show()
