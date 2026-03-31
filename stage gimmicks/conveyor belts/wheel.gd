extends AnimatedSprite2D
var speed: float
@export var speed_to_max: int = 900
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if speed > 0 :
		flip_h = true
	else:
		flip_h = false
	if not animation == "fast":
		rotate(deg_to_rad(speed/50))
	else:
		speed_scale = speed/ 100
	if abs(speed) > speed_to_max:
		animation = "fast"
