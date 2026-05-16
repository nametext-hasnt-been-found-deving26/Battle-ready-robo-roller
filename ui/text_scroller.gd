extends ScrollContainer

@export var scroll_speed := 60.0

var scroll_pos := 0.0

func _process(delta):
	scroll_pos += scroll_speed * delta
	scroll_horizontal = int(scroll_pos)

	var content_width = $HBoxContainer.size.x
	var visible_width = size.x

	var true_max_scroll = content_width - visible_width

	if scroll_pos >= true_max_scroll:
		scroll_pos = 0
