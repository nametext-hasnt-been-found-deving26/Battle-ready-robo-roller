# Pellet.gd
extends Area2D

@export var speed := 400.0
@export var lifetime := 2.0  # seconds
var velocity := Vector2.ZERO
var speed_multiplier := 0.0
var dmg = 1

func _ready():
	velocity = Vector2.RIGHT.rotated(rotation) * (speed + speed_multiplier)

func _physics_process(delta):
	print(velocity)
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	if abs(velocity.x) > speed:
		dmg = 2
	else:
		dmg = 1


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.health = body.health - dmg
		queue_free() # Replace with function body.
