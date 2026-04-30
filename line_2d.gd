extends Line2D

@export var base_color  : Color = Color.hex(0x0972ff)
@export_range(0.0, 5.0, 0.05)
var fade_time : float = 0.30
var int_position
var end_position



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ghosting()
	setting_points()

func set_property(pos: Vector2, scl: Vector2) -> void:
	position = pos
	scale = scl
	


	
func setting_points() :
	clear_points()
	add_point(int_position)
	add_point(end_position)

func ghosting() -> void:
	var selected_color : Color = base_color
	self_modulate = selected_color
	var target_colour := Color(selected_color.r, selected_color.g, selected_color.b, 0.0)

	var tw := create_tween()
	tw.tween_property(self, "self_modulate", target_colour, fade_time)
	await tw.finished
	queue_free()
