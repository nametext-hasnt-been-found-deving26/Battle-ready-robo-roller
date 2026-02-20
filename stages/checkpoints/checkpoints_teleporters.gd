extends Marker2D
@onready var post: Sprite2D = $post
@onready var post_bulb: Sprite2D = $post/post_bulb
@export_category("shader_colors")
@export_group("post")
@export var post_replacement_color1 : Color = Color(0.0, 0.486, 0.0, 1.0)
@export var post_replacement_color2 : Color = Color(0.0, 0.782, 0.0, 1.0)
@export var post_replacement_color3: Color = Color(0.0, 1.0, 0.0, 1.0)
@export_group("bulb")
@export var bulb_replacement_color1: Color = Color(0.286, 0.6, 1.0, 1.0)
@export var bulb_replacement_color2: Color = Color(0.525, 0.714, 0.957, 1.0)
@export var bulb_replacement_color3: Color = Color(0.675, 0.796, 0.949, 1.0)

@export_category("bulb general settings")
@export var non_active_accel: float = 5
var head_towards: float = 186.0
var current_accel: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not activated():
		#if post_bulb.rotation_degrees > 195:
			#head_towards = 164
		#if post_bulb.rotation_degrees < 165:
			#head_towards = 196
			
		post_bulb.rotation_degrees += current_accel
		if post_bulb.rotation_degrees > 195:
			current_accel -= delta * non_active_accel
		elif post_bulb.rotation_degrees < 165:
			current_accel += delta * non_active_accel
		else:
			if abs(current_accel) > 1:
				print("stoped")
				current_accel = move_toward(current_accel, 0, 0.1)
			
			
	if Input.is_action_just_pressed("ui_accept"):
		update_shader_color()



func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	
func activated():
	pass

func update_shader_color():
	var mat_post := post.material as ShaderMaterial
	mat_post.set_shader_parameter("replacement_color", post_replacement_color1)
	mat_post.set_shader_parameter("replacement_color2", post_replacement_color2)
	mat_post.set_shader_parameter("replacement_color3", post_replacement_color3)

	var mat_bulb := post_bulb.material as ShaderMaterial
	mat_bulb.set_shader_parameter("replacement_color", bulb_replacement_color1)
	mat_bulb.set_shader_parameter("replacement_color2", bulb_replacement_color2)
	mat_bulb.set_shader_parameter("replacement_color3", bulb_replacement_color3)
