extends Control
#@onready var grid: GridContainer = $ScrollContainer
#var index := 0
#@onready var focus_box: Control = $focus_box

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScrollContainer/HBoxContainer/Button.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://stages/test_stage.tscn")


func _on_button_3_pressed() -> void:
	get_tree().quit()
