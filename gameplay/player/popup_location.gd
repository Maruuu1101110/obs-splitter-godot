extends Marker2D


func _ready() -> void:
	randomize()

func popup(text: String, color: Color = Color("red")):
	var floating_text = load("res://ui/floating_text.tscn").instantiate()
	floating_text.global_position = global_position
	get_tree().current_scene.add_child(floating_text)
	
	var label = floating_text.get_node("Text")
	label.text = text
	label.add_theme_color_override("font_color", color)
	
	var tween = floating_text.create_tween()
	tween.tween_property(
		floating_text,
		"position",
		floating_text.global_position + _get_direction(),
		0.75
	)
	tween.finished.connect(floating_text.queue_free)
	
func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 16
	
