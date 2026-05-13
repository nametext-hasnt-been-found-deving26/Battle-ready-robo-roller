extends StaticBody2D
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass








func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.grindin = true
		print("grindin")


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		body.grindin = false
		body.grind_off = true

	
