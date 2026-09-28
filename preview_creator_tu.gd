extends Node


@onready var camera_2d: Camera2D = $"../checkpoints_teleporters/Camera2D"


@onready var checkpoints_teleporters = $"../checkpoints_teleporters"


signal camera_disabled

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.

func _process(delta: float) -> void:
	await RenderingServer.frame_post_draw
	
	
	#img.flip_y()
	
	var tex : Texture2D 
	
	tex = set_texture()
	if camera_2d.enabled:
		checkpoints_teleporters.point_image = tex
		if checkpoints_teleporters.point_image:
			camera_2d.enabled = false
		return

	else:
		set_process(false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_texture():
	var vp := get_viewport()
	var img := vp.get_texture().get_image()
	#img.flip_y()
	
	return ImageTexture.create_from_image(img)
