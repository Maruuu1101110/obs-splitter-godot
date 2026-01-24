extends CanvasLayer

var current_screen: Control = null
var screen_stack: Array[Control] = []
@onready var main_sound_track: AudioStreamPlayer = $MainSoundTrack

func _ready():
	screen_stack.clear()
	main_sound_track.process_mode = Node.PROCESS_MODE_ALWAYS
	main_sound_track.play()
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
	if overlay.has_method("on_open"):
		overlay.on_open()

func close_overlay(overlay: Control):
	if overlay.has_method("on_open"):
		overlay.on_open()
	if overlay.has_method("reset_state"):
		overlay.reset_state()
	overlay.hide()

func go_back():
	if screen_stack.is_empty(): 
		return
	current_screen.hide()
	current_screen = screen_stack.pop_back()
	current_screen.show()
