# Vine.gd
extends Node2D

@onready var handle = $Handle
@onready var line = $Line2D
@onready var end_position: Marker2D = $"Handle/end position"


@export var spring_strength := 200.0
@export var min_speed:= 200
@export var max_stretch := 120.0
@export var origin := position 
@export var swing_axis := Vector2.RIGHT
@export var orbit_damping:= 0.98
@export var steer_strength := 2.0  # radians per second (adjust to taste)

@export_category("visual settings")
@export var rotation_to_spot_speed: float

var grabbed = false
var porigin = origin

var current_pos: Vector2
@onready var handle_origin: Node2D = $"handle origin"


func _ready() -> void:

	print(handle_origin)


func _physics_process(delta):
	handle_spin()
	if not grabbed:

		handle.position.y = move_toward(handle.position.y, handle_origin.position.y , 1)
		handle.position.x = move_toward(handle.position.x, handle_origin.position.x , 1 )

	if grabbed:
		# Project handle onto axis
		handle.global_position = current_pos


	# Draw the vine
	$Node2D.global_position = $Handle/Sprite2D.global_position
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point($Node2D.position )
	



func grab_handle( ):
	grabbed = true

	#handle.position += velocity * 0.1  # displace the handle from center a little

func release_handle():
	grabbed = false
	#handle.position = origin

func get_handle_global_position() -> Vector2:
	return global_position 
	

func get_handle_rotation():
	return handle.rotation_degrees

func get_handle_offset():
	return end_position.position
func apply_spin_input(input_vector: Vector2, delta: float, player_position: Vector2):
	if not grabbed:
		return

	# Rotate the swing axis based on input
	#var rotation_dir := input_vector.x  # right positive, left negative
	#if rotation_dir != 0:
		#swing_axis = swing_axis.rotated(rotation_dir * rotation_speed * delta)
	current_pos = player_position

func handle_spin():
	if handle.position.x != 0 and handle.position.y != 0 and handle.position.length() > 10:
		handle.rotation = atan2(-handle.position.x, handle.position.y)
	if handle.position == handle_origin.position and not grabbed: 
		handle.rotation = 0

		
