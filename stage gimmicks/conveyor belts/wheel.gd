extends AnimatedSprite2D
var speed: float
@export var speed_to_max: int = 900
var active: bool = true
var frame_count: int
@export var frames_to_skip: int = 4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if speed > 0 :
		flip_h = true
	else:
		flip_h = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not active:
		return
	frame_count += 1
	
	if frame_count % frames_to_skip != 0:
		return
	if not animation == "fast":
		rotate(deg_to_rad(speed/50)* frames_to_skip)
	else:
		speed_scale = speed/ 100
	if abs(speed) > speed_to_max:
		animation = "fast"
