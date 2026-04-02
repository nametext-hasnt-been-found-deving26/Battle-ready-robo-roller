extends StaticBody2D

@export var Speed: float = 100
@export var belt_length: float = 400.0

@export var wheel_spacing: float = 64.0
@export var wheel_scene: PackedScene

@onready var wheels_container = $Wheels


@export var segment_width: float = 64.0
@export var belt_scene: PackedScene
@export var segment_corrector: float = 1
@export var belt_corrector: float = 0.5

@onready var belt_container = $BeltSegments
@onready var path_2d: Path2D = $Path2D

var push_dir = Vector2.ZERO
var push_dirL= Vector2.ZERO
var push_dirR= Vector2.ZERO
var push_dirD= Vector2.ZERO

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


@onready var upper_collision: Area2D = $CollisionShape2D/upper_collision
@onready var lefter_collision: Area2D = $CollisionShape2D/lefter_collision
@onready var righter_collision: Area2D = $CollisionShape2D/righter_collision
@onready var downer_collision: Area2D = $CollisionShape2D/downer_collision

var belt_built = false
var frame_count := 0
var process_toggle := false

@export var frames_to_skip: int = 4
var on_screen : bool = false
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
var active_type_state: bool = false


func _ready():
	push_dir = transform.x.normalized()
	push_dirR = -transform.x.orthogonal().normalized()
	push_dirL = transform.x.orthogonal().normalized()
	push_dirD = -transform.x.normalized()
	set_position_collisions()
	update_wheels()
	update_belt()
	
	

func set_position_collisions():
	upper_collision.get_child(0).shape.size.x = collision_shape_2d.shape.size.x
	downer_collision.get_child(0).shape.size.x = collision_shape_2d.shape.size.x
	
	upper_collision.get_child(0).position.y = collision_shape_2d.shape.size.y/ - 2
	downer_collision.get_child(0).position.y = collision_shape_2d.shape.size.y/  2
	righter_collision.get_child(0).position.x = collision_shape_2d.shape.size.x/ 2
	lefter_collision.get_child(0).position.x = collision_shape_2d.shape.size.x/ - 2
	
	
	path_2d.curve.set_point_position(4,Vector2((collision_shape_2d.shape.size.x/ - 2) - 5, 0))
	path_2d.curve.set_point_position(3,Vector2((collision_shape_2d.shape.size.x/ - 2) , collision_shape_2d.shape.size.y/  2))
	path_2d.curve.set_point_position(5,Vector2((collision_shape_2d.shape.size.x/ - 2) , collision_shape_2d.shape.size.y/ - 2))

	path_2d.curve.set_point_position(1,Vector2((collision_shape_2d.shape.size.x/(2 + belt_corrector) ) + 5, 0))
	path_2d.curve.set_point_position(2,Vector2((collision_shape_2d.shape.size.x/(2 + belt_corrector) ) , collision_shape_2d.shape.size.y/  2))
	path_2d.curve.set_point_position(0,Vector2((collision_shape_2d.shape.size.x/ (2 + belt_corrector) ) , collision_shape_2d.shape.size.y/ - 2))
	path_2d.curve.set_point_position(7,Vector2((collision_shape_2d.shape.size.x/ (2 + belt_corrector) ) - 1 , collision_shape_2d.shape.size.y/ - 2))
	
	wheels_container.position.x = (collision_shape_2d.shape.size.x/ - 2) + 9
	
	#visible_on_screen_notifier_2d.rect =Rect2(-10, -10, 20, 20)

	visible_on_screen_notifier_2d.rect = Rect2(collision_shape_2d.shape.size.x/ - 2, collision_shape_2d.shape.size.y/ - 2, collision_shape_2d.shape.size.x, collision_shape_2d.shape.size.y)




func _process(delta):
	var active_wheels = wheels_container.get_children()
	if not on_screen:
		for wheel in active_wheels:
			wheel.set_process(false)
		return
	
	for wheel in active_wheels:

		wheel.set_process(true)
	

	frame_count += 1
	
	if frame_count % frames_to_skip != 0:
		return
	
	move_belt(delta * frames_to_skip)
	for body in upper_collision.get_overlapping_bodies() + lefter_collision.get_overlapping_bodies() + righter_collision.get_overlapping_bodies() + downer_collision.get_overlapping_bodies():#####
		if body.is_in_group("sink_affectors"):
			if abs(Speed) < 900 and active_type_state != true:
				_activate_segments(true)
	

func _physics_process(delta: float) -> void:
	if not on_screen:
		return
	for body in upper_collision.get_overlapping_bodies() + lefter_collision.get_overlapping_bodies() + righter_collision.get_overlapping_bodies() + downer_collision.get_overlapping_bodies():#####
		if body.is_in_group("sink_affectors"):

			# Convert player position to area-local space
			var local = to_local(body.global_position)

			# Distance left/right relative to push direction
			var side_dist = abs(local.y)

			# Add extra power from side offset


			body.set("conveyor_power", Speed )


func _on_upper_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		# Save direction so the player can push forward
		body.set("conveyor_area_dir", push_dir)
		# (Power will be adjusted each frame)
		body.set("conveyor_power", Speed)


func _on_upper_collision_body_exited(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		if abs(Speed) < 900 and active_type_state != false:
			_activate_segments(false)
		body.set("conveyor_area_dir", Vector2.ZERO)
		body.set("conveyor_power", 0.0)
		if body.is_in_group("player"):
			body.wall_cling = false


func _on_lefter_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		# Save direction so the player can push forward
		body.set("conveyor_area_dir", push_dirL)
		# (Power will be adjusted each frame)
		body.set("conveyor_power", Speed)


func _on_lefter_collision_body_exited(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		if abs(Speed) < 900 and active_type_state != false:
			_activate_segments(false)
		body.set("conveyor_area_dir", Vector2.ZERO)
		body.set("conveyor_power", 0.0)
		if body.is_in_group("player"):
			body.wall_cling = false


func _on_righter_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		# Save direction so the player can push forward
		body.set("conveyor_area_dir", push_dirR)
		# (Power will be adjusted each frame)
		body.set("conveyor_power", Speed)


func _on_righter_collision_body_exited(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		if abs(Speed) < 900 and active_type_state != false:
			_activate_segments(false)
		body.set("conveyor_area_dir", Vector2.ZERO)
		body.set("conveyor_power", 0.0)
		if body.is_in_group("player"):
			body.wall_cling = false


func _on_downer_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		# Save direction so the player can push forward
		body.set("conveyor_area_dir", push_dirD)
		# (Power will be adjusted each frame)
		body.set("conveyor_power", Speed)


func _on_downer_collision_body_exited(body: Node2D) -> void:
	if body.is_in_group("sink_affectors"):
		if abs(Speed) < 900 and active_type_state != false:
			_activate_segments(false)
		body.set("conveyor_area_dir", Vector2.ZERO)
		body.set("conveyor_power", 0.0)
		if body.is_in_group("player"):
			body.wall_cling = false



func update_wheels():
	for child in wheels_container.get_children():
		child.queue_free()

	var count = int(belt_length / wheel_spacing)

	for i in count:
		var wheel = wheel_scene.instantiate()
		wheel.position.x = i * wheel_spacing
		wheel.speed = Speed
		wheels_container.add_child(wheel)



func update_belt():
	if belt_built:
		return
	
	belt_built = true
	for child in belt_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame 
	
	var curve = path_2d.curve
	var length = curve.get_baked_length()

	var distance = 0.0

	while distance < length * segment_corrector:
		var pos = curve.sample_baked(distance)
		var next_pos = curve.sample_baked(distance + 1.0)
		var angle = (next_pos - pos).angle()

		var segment = belt_scene.instantiate()
		segment.position = pos
		segment.rotation = angle
		segment.speed = Speed
		
		segment.set_meta("distance", distance)

		belt_container.add_child(segment)

		distance += segment_width
		
	#print("Segments:", belt_container.get_child_count())

func move_belt(delta):
	var curve = path_2d.curve
	var length = curve.get_baked_length()

	for segment in belt_container.get_children():
		var dist = segment.get_meta("distance")

		# Move forward
		if abs(Speed) < segment.speed_to_max:
			dist += Speed / 12  * delta 
			
		else:
			dist += (Speed  / 12) / 900 * delta
		dist = fposmod(dist, length)
			#print(dist)

		# Loop back
		if dist > length:
			dist -= length

		# Update position + rotation
		var pos = curve.sample_baked(dist)
		var next_pos = curve.sample_baked(dist + 1.0)
		var angle = (next_pos - pos).angle()

		segment.position = pos
		segment.rotation = angle

		# Save updated distance
		segment.set_meta("distance", dist)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false
	pass # Replace with function body.

func _activate_segments(active:bool):
	for segment in belt_container.get_children():
		segment.area_2d.monitoring = active
		segment.area_2d.monitorable = active
		active_type_state = active
