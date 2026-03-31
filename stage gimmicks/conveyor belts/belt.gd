extends AnimatedSprite2D
var speed: float
@export var speed_to_max: int = 900
var rng := RandomNumberGenerator.new()
var value: int
var entity_offset: float
@export var entity_offset_accel: float = 0.5
var toggle = false
var process_toggle := false
func _ready() -> void:
	rng.randomize()
	

func _process(delta: float) -> void:
	
	if abs(speed) > speed_to_max:
		value = rng.randi_range(-1, 1)
		animation = "fast"
		offset.y = value + entity_offset
		#print(offset.y)
	else:
		animation = "default"
		offset.y = entity_offset
	if speed < 0:
		flip_h = true
	else:
		flip_h = false
