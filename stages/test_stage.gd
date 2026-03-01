extends Node
@onready var preview_viewport = $PreviewViewport
@onready var preview_camera = $PreviewViewport/PreviewCamera
@onready var stage_gimmicks: Node = $stage_gimmicks
var player: PackedScene
@onready var player_position_handler: Marker2D = $player_position_handler
var respawn_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	player_position_handler.spawned = false
	if respawn_point:
		player_position_handler.respawn_point = respawn_point
	#stage_gimmicks.player = player
	set_process(true)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_position_handler.spawned == false:
		player_position_handler.set_player(player)
	else:
		set_process(false)

func capture_checkpoint_preview(position: Vector2) -> Texture2D:
	preview_camera.global_position = position
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var image = preview_viewport.get_texture().get_image()
	return ImageTexture.create_from_image(image) 
