extends Node
@onready var stage_gimmicks: Node = $stage_gimmicks
@export var player: PackedScene
@onready var player_position_handler: Marker2D = $player_position_handler


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_position_handler.spawned = false
	#stage_gimmicks.player = player
	set_process(true)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_position_handler.spawned == false:
		player_position_handler.set_player(player)
	else:
		set_process(false)
