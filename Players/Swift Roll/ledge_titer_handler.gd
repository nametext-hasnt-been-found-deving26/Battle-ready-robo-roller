extends Node2D
@onready var ledge_titer_l: RayCast2D = $ledge_titer_L
@onready var ledge_titer_r: RayCast2D = $ledge_titer_R


var half_colide: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if ledge_titer_l.is_colliding() or ledge_titer_r.is_colliding():
		half_colide = true
	else:
		half_colide = false
