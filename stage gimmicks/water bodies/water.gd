extends Area2D

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	
	if not player.can_water_run:
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
