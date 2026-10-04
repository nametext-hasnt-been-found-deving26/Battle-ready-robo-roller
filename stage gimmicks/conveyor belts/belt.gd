extends AnimatedSprite2D
var speed: float
@export var speed_to_max: int = 900
var rng := RandomNumberGenerator.new()
var value: int
var entity_offset:= false
#@export var entity_offset_value : float = 0.5
var toggle = false
var process_toggle := false

func _ready() -> void:
	rng.randomize()
	if abs(speed) > speed_to_max:
		animation = "fast"

	else:
		animation = "default"
		
	if speed < 0:
		flip_h = true
		
	else:
		flip_h = false
		
	

func _process(delta: float) -> void:
	if abs(speed) > speed_to_max:
		value = rng.randi_range(-1, 1)
		if not animation == "fast":
			_ready()
		
	
	
	offset.y = int(entity_offset) + value
