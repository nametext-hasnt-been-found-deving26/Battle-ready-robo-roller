extends Node
@export var current_theme : AudioStream

@onready var stage_gimmicks: Node = $stage_gimmicks
var player: PackedScene
@export var player_position_handler: Marker2D
var respawn_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player_position_handler:
		return
	player_position_handler.spawned = false
	if respawn_point:
		player_position_handler.respawn_point = respawn_point
	#stage_gimmicks.player = player
	set_process(true)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player_position_handler:
		return
	if player_position_handler.spawned == false:
		player_position_handler.set_player(player)
	else:
		set_process(false)
