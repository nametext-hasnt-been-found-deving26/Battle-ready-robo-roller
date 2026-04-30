extends AnimatedSprite2D
var speed: float
@export var speed_to_max: int = 900
var rng := RandomNumberGenerator.new()
var value: int
var entity_offset: float
@export var entity_offset_value : float = 0.5
var toggle = false
var process_toggle := false
@onready var area_2d: Area2D = $Area2D
var frame_count: int
@export var frames_to_skip: int = 4

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
		offset.y = value
		return
	
	frame_count += 1
	
	if frame_count % frames_to_skip != 0:
		return
	offset.y = entity_offset

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("sink_affectors"):
		return
	entity_offset = entity_offset_value


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("sink_affectors"):
		return
	entity_offset = 0
