extends CanvasLayer

var current_screen: Control = null
var screen_stack: Array[Control] = []

func _ready():
	pass

func show_overlay(overlay: Control, duration: float = 0.25, ease: Tween.EaseType = Tween.EASE_OUT, trans: Tween.TransitionType = Tween.TRANS_BACK) -> void:
	overlay.visible = true
	if overlay.size == Vector2.ZERO:
		await get_tree().process_frame
	overlay.pivot_offset = overlay.size * 0.5

	overlay.scale = Vector2(0.8, 0.8)
	if overlay.has_method("on_open"):
		overlay.call("on_open")

	var tween = overlay.create_tween()
	tween.tween_property(overlay, "scale", Vector2.ONE, duration)\
		 .set_ease(ease)\
		 .set_trans(trans)

func close_overlay(overlay: Control, duration: float = 0.15):
	if overlay.has_method("on_close"):
		overlay.call("on_close")
	if overlay.has_method("reset_state"):
		overlay.call("reset_state")
	var tween = overlay.create_tween()
	tween.tween_property(overlay, "scale", Vector2(0.1, 0.1), duration)\
		 .set_ease(Tween.EASE_IN)\
		 .set_trans(Tween.TRANS_BACK)
	
	tween.connect("finished", Callable(overlay, "hide"))
