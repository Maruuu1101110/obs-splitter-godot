extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_buff(buff_path: String, duration):
	var buff_sprite = AnimatedSprite2D.new()
	buff_sprite.sprite_frames = load(buff_path)
	add_child(buff_sprite)
	buff_sprite.play()
	get_tree().create_timer(duration).timeout.connect(func():
		if is_instance_valid(buff_sprite):
			buff_sprite.queue_free())
	
