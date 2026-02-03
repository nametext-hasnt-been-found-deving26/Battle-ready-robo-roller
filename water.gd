extends Area2D

@export var player = get_node_or_null("../parallax/CharacterBody2D")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if player and player.can_water_run == false:
		$StaticBody2D/CollisionShape2D.disabled = true
	else:
		$StaticBody2D/CollisionShape2D.disabled = false
	


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.in_water = true
		print("in water")
		body.velocity.y = body.velocity.y/3
		


func _on_body_exited(body):
	if body.is_in_group("player"):
		body.in_water = false
		body.velocity = body.velocity * 2.25
