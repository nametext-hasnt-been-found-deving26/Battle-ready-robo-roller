extends Node2D

# Geometry & physics feel
@export var segment_count := 8
@export var segment_length := 6.0
@export var slimness := 1.0           # uniform thickness
@export var stiffness := 0.25
@export var flopiness := 0.4
@export var snake_intensity := 0.15   # small sine wobble
@export var snake_speed := 6.0
@export var head_offset := Vector2(0, -8)
@export var tail_length := 8.0
@export var stretch_limit := 1.25     # 1.25× normal = strong resistance
@export var extension_multiplier: float = 1.0
@export var base_segment_length: float = 8.0
var anchor_position: Vector2 = Vector2.ZERO
@onready var neck: Node2D = $"../Neck"
@export var velocity_influence: float = 0.5
const BASE_PHYSICS_FPS := 120.0




# Colors & dash blend
@export var color_inner := Color("#1d2a63")
@export var color_edge := Color("#000e5f")
var _target_inner := color_inner
var _target_edge := color_edge
@export var color_lerp_speed := 8.0

# Internal state
var player: CharacterBody2D
var points: Array[Vector2] = []
var velocities: Array[Vector2] = []
var time := 0.0

func _ready():

	player = owner as CharacterBody2D
	points.resize(segment_count)
	velocities.resize(segment_count)
	for i in range(segment_count):
		points[i] = global_position
		velocities[i] = Vector2.ZERO

func _physics_process(delta):
	var physics_scale = BASE_PHYSICS_FPS * delta


	if player == null:
		return

	time += delta
	# use the player's local space head_offset transformed to global
	points[0] = neck.global_position



	# physics + constraint pass
	for i in range(1, segment_count):
		var dir = points[i] - points[i - 1]
		var dist = dir.length()
		if dist > 0.0:
			dir /= dist
			var target = points[i - 1] + dir * segment_length
			points[i] = points[i].lerp(target, stiffness * physics_scale)

		# floppy downward drift
		points[i].y += flopiness * physics_scale

	# slight sine sway for subtle motion
	for i in range(1, segment_count):
		var offset = Vector2(
			sin(time * snake_speed + float(i) * 0.6) * snake_intensity,
			cos(time * snake_speed + float(i) * 0.7) * snake_intensity * 0.5
		)
		points[i] += offset

	# mild trailing behind player velocity
	if "velocity" in player:
		var vel = player.velocity/2
		for i in range(1, segment_count):
			points[i] += ((vel) * (velocity_influence)/2 * physics_scale)/80

	# extension limiter (resists over-stretching)
	for i in range(1, segment_count):
	
		var diff = points[i] - points[i - 1]
	
		var dist = diff.length()
	
		var max_len = segment_length * stretch_limit

	
		if dist > max_len:
		
			var correction = (dist - max_len) / dist
		
			points[i] -= diff * 0.6 * correction
		
			points[i - 1] += diff * 0.4 * correction


	# color blend toward dash targets
	color_inner = color_inner.lerp(_target_inner, clamp(color_lerp_speed * delta, 0.0, 1.0))
	color_edge  = color_edge.lerp(_target_edge,  clamp(color_lerp_speed * delta, 0.0, 1.0))

	queue_redraw()

func _draw():
	if points.size() < 2:
		return

	# body with uniform thickness
	for i in range(points.size() - 1):
		var a = to_local(points[i])
		var b = to_local(points[i + 1])
		var dir = (b - a).normalized()
		var perp = Vector2(-dir.y, dir.x)
		var width := slimness * 4.0

		var p1 = a + perp * width
		var p2 = a - perp * width
		var p3 = b - perp * width
		var p4 = b + perp * width

		draw_polygon([p1, p2, p3, p4], [color_inner])
		draw_polyline([p1, p2, p3, p4, p1], color_edge, 1.0)

	# --- Tail V with transparent notch ---
	# --- Tail V-end (true cut-out notch, like the sprite) ---
	# --- Tail end shaped like the sprite scarf (true V notch) ---
	# --- Tail end shaped like the sprite scarf (V notch pointing OUTWARD) ---
	# --- Tail end shaped like the sprite scarf (offset outward, true notch) ---
	# inside _draw()
	# in scarf_2d.gd, inside _draw()
# show the computed anchor point (only for debugging)


	if points.size() > 1:
		var tail_dir = (points[-2] - points[-1]).normalized()
		var perp = Vector2(-tail_dir.y, tail_dir.x)

	# Offset the base slightly outward so the V shape isn't buried inside the scarf
		var tail_pos = to_local(points[-1] + tail_dir * (tail_length * -0.8))

		var tail_width = 4.0 * slimness
		var tail_length_full = tail_length * slimness
		var notch_depth = tail_length_full * 0.4
		var notch_width = tail_width * 0.6

	# Rectangle base (connects to scarf body)
		var base_left = tail_pos + perp * tail_width
		var base_right = tail_pos - perp * tail_width

	# Tip sides (front edges forming V)
		var tip_left = tail_pos + tail_dir * tail_length_full + perp * notch_width
		var tip_right = tail_pos + tail_dir * tail_length_full - perp * notch_width
		var notch_point = tail_pos + tail_dir * (tail_length_full + notch_depth)

	# Draw left and right polygons, leaving center V open
		draw_polygon([base_left, tip_left, notch_point], [color_inner])
		draw_polygon([base_right, tip_right, notch_point], [color_inner])

	# Outline edges
		draw_polyline([base_left, tip_left, notch_point, tip_right, base_right], color_edge, 1.0)





# ---- Color control from player ----
func update_dash_color(dash_count: int) -> void:
	match dash_count:
		0:
			_target_inner = Color("#505050")
			_target_edge  = Color("#2a2a2a")
		1:
			_target_inner = Color("#1d2a63")
			_target_edge  = Color("#000e5f")
		2:
			_target_inner = Color("#ffd23f")
			_target_edge  = Color("#ff9b00")
		_:
			var t = clamp(float(dash_count - 2) / 4.0, 0.0, 1.0)
			_target_inner = Color("#ff6b00").lerp(Color("#ff0000"), t)
			_target_edge  = Color("#ff3b00").lerp(Color("#b30000"), t)

func set_dash_color_immediate(dash_count: int) -> void:
	update_dash_color(dash_count)
	color_inner = _target_inner
	color_edge  = _target_edge
	queue_redraw()
