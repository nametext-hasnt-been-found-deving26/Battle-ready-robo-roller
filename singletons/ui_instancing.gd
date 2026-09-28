extends Node

var pause_menu := preload("uid://bbxogwa1uudyk")
var FPS_label :=preload("uid://bft5tela22vqs")
var Touch_controls: = preload("uid://d2y7gdugrtp55")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("autoload check")
	get_tree().scene_changed.connect(_on_scene_changed)

	# Handle first scene
	_on_scene_changed()

func _on_scene_changed():
	var scene = get_tree().current_scene

	print("Scene changed to:", scene)
	_instance_FPS_Label()
	if scene and scene.is_in_group("stage"):
		_instance_pause_menu()
		_instance_touch_controls()
		
		

func _instance_pause_menu():
	if not pause_menu:
		print("pause is null")
		return
	var pauser = pause_menu.instantiate()
	get_tree().current_scene.add_child(pauser)
	print("pauser")
		

func _instance_FPS_Label():
	if not FPS_label:
		return
	var FPS = FPS_label.instantiate()
	get_tree().current_scene.add_child(FPS)

func _instance_touch_controls():
	if not Touch_controls:
		return
	var touch = Touch_controls.instantiate()
	get_tree().current_scene.add_child(touch)
