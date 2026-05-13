extends Camera2D
@export var max_shake: float = 10.0
@export var shake_fade: float = 10.0
var _shake_strength = max_shake
@onready var character_body_2d = $".."
#var desired_offset = character_body_2d.velocity
var min_offset = -200
var max_offset = 200
# Called when the node enters the scene tree for the first time.
func trigger_shake()-> void:
	_shake_strength = max_shake

func _process(delta: float)-> void:
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
		offset = Vector2( offset.x + randf_range(-_shake_strength, _shake_strength), offset.y + randf_range(-_shake_strength, _shake_strength))
	#desired_offset.x = clamp(desired_offset.x, min_offset, max_offset)
	
