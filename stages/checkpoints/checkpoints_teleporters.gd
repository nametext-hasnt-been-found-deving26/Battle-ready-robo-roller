extends Marker2D
@onready var post: Sprite2D = $post
@onready var post_bulb: Sprite2D = $post/post_bulb
@onready var glow: Sprite2D = $glow

@export var respawn_id: String

@export_group("rings")
@export var ring_buffer_time_duration: float = 0.1
var ring_buffer_timer: float
@export var rings : PackedScene
@onready var ring_spawner: Marker2D = $ring_spawner

@export_category("shader_colors")
@export_group("base colors")
@export_subgroup("post")
@export var post_base_color1 : Color = Color(0.0, 0.486, 0.0, 1.0)
@export var post_base_color2 : Color = Color(0.0, 0.782, 0.0, 1.0)
@export var post_base_color3: Color = Color(0.0, 1.0, 0.0, 1.0)
@export_subgroup("bulb")
@export var bulb_base_color1: Color = Color(0.286, 0.6, 1.0, 1.0)
@export var bulb_base_color2: Color = Color(0.525, 0.714, 0.957, 1.0)
@export var bulb_base_color3: Color = Color(0.675, 0.796, 0.949, 1.0)
@export_group("replacement colors")
@export_subgroup("post")
@export var post_replacement_color1 : Color = Color(0.0, 0.486, 0.0, 1.0)
@export var post_replacement_color2 : Color = Color(0.0, 0.782, 0.0, 1.0)
@export var post_replacement_color3: Color = Color(0.0, 1.0, 0.0, 1.0)
@export_subgroup("bulb")
@export var bulb_replacement_color1: Color = Color(0.286, 0.6, 1.0, 1.0)
@export var bulb_replacement_color2: Color = Color(0.525, 0.714, 0.957, 1.0)
@export var bulb_replacement_color3: Color = Color(0.675, 0.796, 0.949, 1.0)



@export_category("bulb general settings")
@export_group("non active")
@export var non_active_accel: float = 5
@export var non_active_drag: float = 0.06
@export_group("active")
@export var active_drag: float = 0.06
var current_accel: float
var activated = false

var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if HandlePlayerInStage.is_respawn_activated(respawn_id):
		activated = true
	else:
		restart_bulb_color()
		restart_post_color()
		glow.modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if abs(post_bulb.rotation_degrees) >= 360:
		post_bulb.rotation_degrees = 0
	if activated == false:
		if post_bulb.rotation_degrees > 183:
			current_accel -= delta * non_active_accel
		elif post_bulb.rotation_degrees < 177:
			current_accel += delta * non_active_accel
		else:
			if abs(current_accel) > 1:
				#print("stoped")
				current_accel = move_toward(current_accel, 0, non_active_drag)
	else:
		active(delta)
	post_bulb.rotation_degrees += current_accel



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		body.can_teleport = true
		HandlePlayerInStage.current_checkpoint_id = respawn_id
		if activated == false:
			
			if abs(body.velocity.x) >= abs(body.velocity.y):
				current_accel = body.velocity.x/-100
			else:
				current_accel = body.velocity.y/ 100
			activated = true
	
func active(delta):
	update_post_color()
	if abs(current_accel) > 8:
		current_accel = move_toward(current_accel, 0, active_drag)
		#print(post_bulb.rotation_degrees)
	else:
		if abs(post_bulb.rotation_degrees) > 355 or abs(post_bulb.rotation_degrees) < 5:
			if not post_bulb.rotation_degrees == 0:
				HandlePlayerInStage.respawn = true
				HandlePlayerInStage.respawn_point = global_position
				HandlePlayerInStage.activate_respawn(respawn_id, global_position)
				var stage = get_tree().current_scene
				var texture = await stage.capture_checkpoint_preview(global_position)
				#checkpoint_data["preview"] = texture
			current_accel = 0
			post_bulb.rotation_degrees = 0
			update_bulb_color(delta)
			if player and player.can_teleport == true:
				player.teleport_location_x = global_position.x
				HandlePlayerInStage.current_checkpoint_id = respawn_id
			#if player.teleporting == true:




func update_post_color():
	var mat_post := post.material as ShaderMaterial
	mat_post.set_shader_parameter("replacement_color", post_replacement_color1)
	mat_post.set_shader_parameter("replacement_color2", post_replacement_color2)
	mat_post.set_shader_parameter("replacement_color3", post_replacement_color3)

func update_bulb_color(delta):
	var mat_bulb := post_bulb.material as ShaderMaterial
	mat_bulb.set_shader_parameter("replacement_color", bulb_replacement_color1)
	mat_bulb.set_shader_parameter("replacement_color2", bulb_replacement_color2)
	mat_bulb.set_shader_parameter("replacement_color3", bulb_replacement_color3)
	if glow.modulate.a < 1:
		glow.modulate.a += delta
		#print(glow.modulate.a)
	create_rings(delta)

func restart_post_color():
	var mat_post := post.material as ShaderMaterial
	mat_post.set_shader_parameter("replacement_color", post_base_color1)
	mat_post.set_shader_parameter("replacement_color2", post_base_color2)
	mat_post.set_shader_parameter("replacement_color3", post_base_color3)

func restart_bulb_color():
	var mat_bulb := post_bulb.material as ShaderMaterial
	mat_bulb.set_shader_parameter("replacement_color", bulb_base_color1)
	mat_bulb.set_shader_parameter("replacement_color2", bulb_base_color2)
	mat_bulb.set_shader_parameter("replacement_color3", bulb_base_color3)

func create_rings(delta):
	if ring_buffer_timer >= 0:
		ring_buffer_timer -= delta
	var ring = rings.instantiate()
	if ring_buffer_timer < 0:
		ring.set_property(ring_spawner.global_position,  scale)
		get_tree().current_scene.add_child(ring)
		ring_buffer_timer = ring_buffer_time_duration #+ cloud_velocity_timer_multiplier


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.can_teleport = false
	pass # Replace with function body.
