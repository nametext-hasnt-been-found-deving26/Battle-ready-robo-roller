extends Control

@onready var texture_rect = $TextureRect

func setup(checkpoint):
	if checkpoint.has("preview"):
		texture_rect.texture = checkpoint["preview"]
		print("has view")
	else:
		print("No preview found for checkpoint:", checkpoint["id"])

func set_selected(selected: bool):
	if selected:
		modulate = Color.WHITE
		scale = Vector2.ONE * 1.1
	else:
		modulate = Color(0.7, 0.7, 0.7)
		scale = Vector2.ONE
