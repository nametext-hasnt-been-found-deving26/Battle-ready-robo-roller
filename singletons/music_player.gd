extends Node

var music_player: AudioStreamPlayer
var record_scrachin = preload("uid://yvy8eohsu2kj")



func _ready():
	

	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"
	get_tree().scene_changed.connect(update_music)
	update_music()


func update_music():
	var scene = get_tree().current_scene

	if scene == null:
		return

	# Check if the scene has the variable
	if "current_theme" in scene:
		var theme = scene.current_theme

		# Don't restart same music
		if  scene.current_theme== theme and music_player.playing:
			print("no theme")
			return


		music_player.stream = theme
		music_player.play()



func change_music(stream: String):

	var current_tune = ProjectSettings.globalize_path(music_player.stream.resource_path)
	if current_tune == stream and music_player.playing:
			#print("no theme")
			return

	music_player.stream = record_scrachin
	music_player.play()
		
	await  music_player.finished
	print("playing: ",stream)
	music_player.stream = load(stream)
	print(ProjectSettings.globalize_path(music_player.stream.resource_path))
	music_player.play()

func _process(delta: float) -> void:
	if music_player.stream == null:
		return
	if not music_player.playing and music_player.stream != record_scrachin:
		music_player.play()
		#print("restart tune")
	else:
		return
