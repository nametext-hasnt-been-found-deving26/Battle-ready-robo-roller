extends Node


@onready var camera_2d: Camera2D = $"../checkpoints_teleporters/Camera2D"
@onready var camera_2d2: Camera2D = $"../checkpoints_teleporters2/Camera2D"
@onready var camera_2d3: Camera2D = $"../checkpoints_teleporters3/Camera2D"
@onready var camera_2d4: Camera2D = $"../checkpoints_teleporters4/Camera2D"
@onready var camera_2d5: Camera2D = $"../checkpoints_teleporters5/Camera2D"
@onready var camera_2d6: Camera2D = $"../checkpoints_teleporters6/Camera2D"
@onready var camera_2d7: Camera2D = $"../checkpoints_teleporters7/Camera2D"

@onready var checkpoints_teleporters = $"../checkpoints_teleporters"
@onready var checkpoints_teleporters_2 = $"../checkpoints_teleporters2"
@onready var checkpoints_teleporters_3 = $"../checkpoints_teleporters3"
@onready var checkpoints_teleporters_4 = $"../checkpoints_teleporters4"
@onready var checkpoints_teleporters_5 = $"../checkpoints_teleporters5"
@onready var checkpoints_teleporters_6 = $"../checkpoints_teleporters6"
@onready var checkpoints_teleporters_7 = $"../checkpoints_teleporters7"

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
	#if not camera_2d.enabled:
	#	camera_disabled.emit()
	
	
	#await camera_disabled
	elif camera_2d2.enabled:
		checkpoints_teleporters_2.point_image = tex
		if checkpoints_teleporters_2.point_image:
			camera_2d2.enabled = false
		return
	#if not camera_2d2.enabled:
	#	camera_disabled.emit()
	
	
	#await camera_disabled

	
	elif camera_2d3.enabled:
		checkpoints_teleporters_3.point_image = tex
		if checkpoints_teleporters_3.point_image:
			camera_2d3.enabled = false
		return

	
	
	#await camera_disabled

	#img.flip_y()
	
	elif camera_2d4.enabled :
		checkpoints_teleporters_4.point_image = tex
		if checkpoints_teleporters_4.point_image:
			camera_2d4.enabled = false
		return
	#if not camera_2d4.enabled:
	#	camera_disabled.emit()
	
	
	#await camera_disabled

	#img.flip_y()
	elif camera_2d5.enabled :
		checkpoints_teleporters_5.point_image = tex
		if checkpoints_teleporters_5.point_image:
			camera_2d5.enabled = false
		return
	#if not camera_2d5.enabled:
	#	camera_disabled.emit()
	
	
	#await camera_disabled
	elif camera_2d6.enabled:
		checkpoints_teleporters_6.point_image = tex
		if checkpoints_teleporters_6.point_image:
			camera_2d6.enabled = false
		return
	#if not camera_2d6.enabled:
	#	camera_disabled.emit()
	
	
	#await camera_disabled
	elif camera_2d7.enabled:
		checkpoints_teleporters_7.point_image = tex
		if checkpoints_teleporters_7.point_image:
			camera_2d7.enabled = false
	else:
		set_process(false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_texture():
	var vp := get_viewport()
	var img := vp.get_texture().get_image()
	#img.flip_y()
	
	return ImageTexture.create_from_image(img)
