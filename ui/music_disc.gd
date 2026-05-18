extends Sprite2D

@export var target_player: AudioStreamPlayer
@export var strength := 0.25
@export var smoothness := 8.0
@export var rotation_speed := 2.0

var base_scale := Vector2.ONE

func _ready():
	base_scale = scale
	#set_process(false)

func _process(delta):

	if MusicPlayer.music_player == null:
		return

	# Get volume from the music bus
	var bus_index = AudioServer.get_bus_index("Music")

	var volume_db = AudioServer.get_bus_peak_volume_left_db(bus_index, 0)

	# Convert dB to linear volume
	var volume = db_to_linear(volume_db)

	# Scale effect
	var target_scale = base_scale * (1.0 + volume * strength)
	#print(volume)

	scale = scale.lerp(target_scale, delta * smoothness)
	rotation_degrees += rotation_speed
