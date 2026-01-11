extends CanvasLayer

var current_screen: Control = null
var screen_stack: Array[Control] = []

func _ready():
	screen_stack.clear()
	show_screen($MainMenu)

# Full screen replace
func show_screen(screen: Control):
	if current_screen:
		current_screen.hide()
		screen_stack.append(current_screen)

	current_screen = screen
	current_screen.show()

# Overlay (example: Settings window)
func show_overlay(overlay: Control):
	overlay.show()

func close_overlay(overlay: Control):
	overlay.hide()

func go_back():
	if screen_stack.is_empty(): 
		
		return

	current_screen.hide()
	current_screen = screen_stack.pop_back()
	current_screen.show()
