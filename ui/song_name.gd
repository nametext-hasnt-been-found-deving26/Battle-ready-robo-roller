extends Label

@onready var text_scroller: ScrollContainer = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_song = ProjectSettings.globalize_path(MusicPlayer.music_player.stream.resource_path)
	var song_name = current_song.get_file().get_basename()
	if song_name == "record_scratchin":
		text = "     "
	else:
		text = ("      "   
			+ current_song.get_file().get_basename()
			 + (" ".repeat(int(text_scroller.max_scroll)))      
			)


		 
	pass
