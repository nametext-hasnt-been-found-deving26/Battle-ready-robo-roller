extends ScrollContainer

@export var scroll_speed := 60.0
var max_scroll: int

func _process(delta):
	scroll_horizontal += scroll_speed * delta

	max_scroll = get_h_scroll_bar().max_value
	print("scroll ", scroll_horizontal, " max_scroll ", max_scroll)
	

	if scroll_horizontal >= max_scroll/1.66:
		scroll_horizontal = 0
		print("reset")
		
