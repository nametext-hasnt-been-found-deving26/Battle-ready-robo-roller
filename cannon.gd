extends Node2D
@onready var sprite_2d = $Sprite2D

@onready var main = $".."
@onready var proyectile = load("res://bullet.tscn")
var dir = 1
var amount = 0
# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if Input.is_action_just_pressed("left"):
		dir = 2
	elif Input.is_action_just_pressed("right"):
		dir = 1
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if dir == 1:
		rotation_degrees = 0
	else:
		rotation_degrees = 180
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func shoot():
	var instance = proyectile.instantiate()
	instance.dir = 1 if dir == 1 else -1
	instance.zdex = z_index - 1
	get_parent().add_child(instance)
	
