extends Node

var swift_roll: PackedScene = preload("res://Players/Swift Roll/player.tscn")
var respawn: bool = false
var respawn_point: Vector2
var activated_respawns: Array = []
var activated_checkpoints: Array = []
var current_checkpoint_id

func _ready():
	print("autoload check")
	get_tree().scene_changed.connect(_on_scene_changed)

	# Handle first scene
	_on_scene_changed()

func _on_scene_changed():
	var scene = get_tree().current_scene

	print("Scene changed to:", scene)

	if scene and scene.is_in_group("stage"):
		print("set player")
		scene.player = swift_roll
		if respawn == true:
			print("respawn")
			scene.respawn_point = respawn_point

func activate_respawn(id: String, position: Vector2) -> void:
	if has_checkpoint(id):
		return

	print("Activating checkpoint:", id)

	var stage = get_tree().current_scene
	print("Stage:", stage)


	
	
	if stage and stage.is_in_group("stage"):
		var texture = await stage.capture_checkpoint_preview(position)
		print("Captured texture:", texture)

		activated_checkpoints.append({
			"id": id,
			"position": position,
			"preview": texture
		})
func has_checkpoint(id: String) -> bool:
	for c in activated_checkpoints:
		if c["id"] == id:
			return true
	return false
	
	
func is_respawn_activated(id: String) -> bool:
	return has_checkpoint(id)
