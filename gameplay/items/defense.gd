extends Area2D

@onready var popup = $PopupLocation
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	var bonus_mult = randi_range(30, 71)
	if body.name == "PlayerCar":
		body.apply_buff("defense", 10, bonus_mult)
		popup.popup("Damage +%d!!!\nArmor +%d!!!" % [bonus_mult, (1.5* bonus_mult)], Color("green"))
		queue_free()
		
func _exit_tree() -> void:
	if has_meta("spawnpoint"):
		var spawn = get_meta("spawnpoint")
		if is_instance_valid(spawn):
			spawn.set_meta("occupied", false)
