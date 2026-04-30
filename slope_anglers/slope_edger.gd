extends Area2D
var player
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.grind_off = true
		body.grindin = false
