extends CanvasLayer

var current_screen: Control = null
var screen_stack: Array[Control] = []

func _ready() -> void:
	screen_stack.clear()
	show_screen($MainMenu)

func show_screen(screen: Control):
	if current_screen:
		screen_stack.append(current_screen)
		current_screen.hide()

	current_screen = screen
	current_screen.show()

func go_back():
	if screen_stack.is_empty():
		return

	current_screen = screen_stack.pop_back()
	current_screen.show()
