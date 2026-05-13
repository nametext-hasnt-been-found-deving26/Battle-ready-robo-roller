extends PanelContainer

var scene_theme: String
var music_folder_on_editor_version = ProjectSettings.globalize_path("res://Music")
var music_folder_on_exe_version = OS.get_executable_path().get_base_dir().path_join("music")
@onready var list_container = $ScrollContainer/VBoxContainer
var allowed_extensions = ["mp3", "ogg", "wav"]
var music_folder

@onready var scroll = $ScrollContainer

var scroll_speed := 200.0

var song_buttons = []
var selected_index = 0

@onready var input_buffer_timer: Timer = $input_buffer_Timer


func _ready():
	var scene = get_tree().current_scene

	if scene == null:
		return

	# Check if the scene has the variable
	if "current_theme" in scene:
		#var theme = ProjectSettings.globalize_path(scene.current_theme.resource_path)
		scene_theme = ProjectSettings.globalize_path(scene.current_theme.resource_path)
		var button = Button.new()
		button.text =  scene_theme.get_file().get_basename()



		button.set_meta("file_path", scene_theme)

		button.pressed.connect(
			_on_song_button_pressed.bind(button)
		)

		list_container.add_child(button)
		song_buttons.append(button)
	else:
		print("no theme")
	if OS.has_feature("editor"):
		music_folder = music_folder_on_editor_version
	else:
		music_folder = music_folder_on_exe_version
	create_playlist_buttons(music_folder)


	

func create_playlist_buttons(path: String):
	var files = DirAccess.get_files_at(path)
	print(files)

	for file_name in files:
		var extension = file_name.get_extension().to_lower()

		# Skip unwanted file types
		if extension not in allowed_extensions:
			continue

		if scene_theme != null:
			if file_name == scene_theme.get_file() :
				continue

		var button = Button.new()
		button.text = file_name.get_basename()

		var full_path = path.path_join(file_name)

		button.set_meta("file_path", full_path)

		button.pressed.connect(
			_on_song_button_pressed.bind(button)
		)

		list_container.add_child(button)
		song_buttons.append(button)

func _on_song_button_pressed(button: Button):
	var file_path = button.get_meta("file_path")

	print("Selected:", file_path)
	MusicPlayer.change_music(file_path)

	# Example:
	# play_song(file_path)


func _unhandled_input(event):
	if event.is_action_pressed("mixtape_scroll_down") and input_buffer_timer.is_stopped():
		move_selection(1)
		input_buffer_timer.start()

	if event.is_action_pressed("mixtape_scroll_up") and input_buffer_timer.is_stopped():
		move_selection(-1)
		input_buffer_timer.start()
	
	if event.is_action_pressed("Mixtape_accept"):
		var focused = get_viewport().gui_get_focus_owner()

		if focused is Button:
			focused.pressed.emit()

func move_selection(direction):
	if song_buttons.is_empty():
		return

	selected_index += direction

	selected_index = clamp(
		selected_index,
		0,
		song_buttons.size() - 1
	)

	var button = song_buttons[selected_index]

	button.grab_focus()

	# Optional: keep focused button visible
	scroll.ensure_control_visible(button)
