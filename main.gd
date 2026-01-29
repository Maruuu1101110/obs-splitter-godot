extends Node2D

@onready var main_sound_track: AudioStreamPlayer = $UI/MainSoundTrack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.main_soundtrack = main_sound_track
	main_sound_track.process_mode = Node.PROCESS_MODE_ALWAYS
	main_sound_track.play()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
