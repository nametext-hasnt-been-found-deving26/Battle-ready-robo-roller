extends Node
var player = false
@onready var water_bodies: Node = $water_bodies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	water_bodies.player = player
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
