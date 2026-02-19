extends Node

var swift_roll: PackedScene = preload("res://Players/Swift Roll/player.tscn")

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
