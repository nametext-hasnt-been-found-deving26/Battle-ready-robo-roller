extends Node2D

@export var detection_range := 20.0
@export var minimum_natural_entrence_speed := -100

var player

@onready var rail_path: Path2D = $"rail path"
@onready var rail_texture: Line2D = $rail_texture


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_texture()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not player:
		_get_player()
		return
	var curve := rail_path.curve
	var player_pos := rail_path.to_local(player.global_position)

	var closest_point := curve.get_closest_point(player_pos)
	var distance := player_pos.distance_to(closest_point)

	if distance <= detection_range:
		if player.mode != player.MovementMode.RAIL_GRINDING:
			if player.velocity.y >= minimum_natural_entrence_speed or Input.is_action_pressed("jump"):
				player.grind_start(rail_path)

			
	pass

func _get_player():
	player = get_tree().get_first_node_in_group("player")

func _build_texture():
	var curve := rail_path.curve
	for point in (curve.point_count):
		rail_texture.add_point(curve.get_point_position(point))
		print(curve.get_point_position(point))
