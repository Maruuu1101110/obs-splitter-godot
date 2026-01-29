extends Area2D

@onready var popup = $PopupLocation
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerCar":
		body.curr_hp = clamp(body.curr_hp + 30, 0, body.max_hp)
		popup.popup("HP Restored!!!", Color("green"))
		queue_free()

func _exit_tree() -> void:
	if has_meta("spawnpoint"):
		var spawn = get_meta("spawnpoint")
		if is_instance_valid(spawn):
			spawn.set_meta("occupied", false)
