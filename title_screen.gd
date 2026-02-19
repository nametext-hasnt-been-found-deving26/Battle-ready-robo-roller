extends Control
@onready var grid: GridContainer = $ScrollContainer
var index := 0
@onready var focus_box: Control = $focus_box

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func move_focus(direction: Vector2i):
	var cols = grid.columns
	var count = grid.get_child_count()

	var row = index / cols
	var col = index % cols

	col += direction.x
	row += direction.y

	col = clamp(col, 0, cols - 1)
	row = clamp(row, 0, (count - 1) / cols)

	var new_index = row * cols + col
	new_index = clamp(new_index, 0, count - 1)

	index = new_index
	update_focus_position()


func update_focus_position():
	var btn := grid.get_child(index) as Control
	var rect = btn.get_global_rect()

	# Snap center of focus box to the button’s rect
	focus_box.global_position = rect.position
	focus_box.size = rect.size
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_left"):
		move_focus(Vector2i(-1, 0))
	if Input.is_action_just_pressed("ui_right"):
		move_focus(Vector2i(1, 0))
	if Input.is_action_just_pressed("ui_up"):
		move_focus(Vector2i(0, -1))
	if Input.is_action_just_pressed("ui_down"):
		move_focus(Vector2i(0, 1))

	# Confirm button
	if Input.is_action_just_pressed("ui_accept"):
		select_current()
func select_current():
	var btn = grid.get_child(index)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://stages/test_stage.tscn")
