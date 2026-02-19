extends Node
@onready var wallkicklock_l_1: RayCast2D = $wallkicklockL1
@onready var wallkicklock_l_2: RayCast2D = $wallkicklockL2
@onready var wallkicklock_l_3: RayCast2D = $wallkicklockL3
var is_colliding = false
var enabled = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if wallkicklock_l_1.is_colliding() or wallkicklock_l_2.is_colliding() or wallkicklock_l_3.is_colliding():
		is_colliding = true
	else:
		is_colliding = false
	if enabled == true:
		wallkicklock_l_1.enabled = true
		wallkicklock_l_2.enabled = true
		wallkicklock_l_3.enabled = true
	else:
		wallkicklock_l_1.enabled = false
		wallkicklock_l_2.enabled = false
		wallkicklock_l_3.enabled = false
	pass
