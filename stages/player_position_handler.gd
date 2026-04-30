extends Marker2D
@onready var tile_map: TileMap = $"../TileMap"
var player: PackedScene
var spawned: bool
@onready var stage_gimmicks: Node = $"../stage_gimmicks"
var stage = get_parent()
func set_player(p: PackedScene):
	#print("SET PLAYER CALLED")
	player = p
	spawn_player()

func spawn_player():
	if not player:
		#print("Player is null")
		return
	spawned = true
	var current_player = player.instantiate()
	current_player.current_tilemap = tile_map
	get_parent().add_child(current_player)
	if HandlePlayerInStage.respawn == true:
		current_player.global_position = HandlePlayerInStage.respawn_point
	else:
		current_player.global_position = global_position
