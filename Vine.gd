# Vine.gd
extends Node2D

@onready var handle = $Handle
@onready var line = $Line2D

@export var spring_strength := 200.0
@export var damping := 10.0
@export var max_stretch := 120.0
@export var origin := position 
@export var swing_axis := Vector2.RIGHT
@export var rotation_speed := 2.0  # radians per second (adjust to taste)



var grabbed = false
var porigin = origin
var velocity := Vector2.ZERO



func _physics_process(delta):
	if grabbed:
		var axis = swing_axis.normalized()

		# Project handle onto axis
		handle.position = axis * handle.position.dot(axis)
		velocity = velocity.project(axis)

		# Spring force along the axis
		var spring_force = -spring_strength * handle.position
		var damping_force = -damping * velocity
		var total_force = spring_force + damping_force

		velocity += total_force * delta
		handle.position += velocity * delta

		# Clamp stretch
		if handle.position.length() > max_stretch:
			handle.position = handle.position.normalized() * max_stretch
			velocity = velocity.slide(handle.position.normalized())

	# Draw the vine
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(handle.position)




func grab_handle(player_velocity: Vector2):
	grabbed = true
	velocity = player_velocity * 0.5
	handle.position += velocity * 0.1  # displace the handle from center a little

func release_handle():
	grabbed = false
	handle.position = origin

func get_handle_global_position() -> Vector2:
	return handle.global_position

func apply_spin_input(input_vector: Vector2, delta: float):
	if not grabbed:
		return

	# Rotate the swing axis based on input
	var rotation_dir := input_vector.x  # right positive, left negative
	if rotation_dir != 0:
		swing_axis = swing_axis.rotated(rotation_dir * rotation_speed * delta)
