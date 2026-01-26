extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_goback_pressed():
	print("Go Back Button Pressed")
	Ui.close_overlay($/root/Main/UI/Settings)
	hide()

func _say_hi_pressed():
	print("HIIII")
