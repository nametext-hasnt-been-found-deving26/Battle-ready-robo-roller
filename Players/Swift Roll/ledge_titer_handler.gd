extends Node2D
@onready var ledge_titer_l: RayCast2D = $ledge_titer_L
@onready var ledge_titer_r: RayCast2D = $ledge_titer_R
var ledge_angle: Vector2

var half_colide: bool = false
var full_colide: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if ledge_titer_l.is_colliding() or ledge_titer_r.is_colliding():
		if ledge_titer_l.is_colliding() and ledge_titer_r.is_colliding():
			full_colide = true
		ledge_angle = lerp(ledge_titer_l.get_collision_normal(), ledge_titer_r.get_collision_normal(), 0.15)
		half_colide = true
	else:
		ledge_angle = Vector2.ZERO
		full_colide = false
		half_colide = false
