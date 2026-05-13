extends Control
@onready var pivot: Control = $pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var panel_container: PanelContainer = $PanelContainer
@export var move_accel: float = 50
var accel: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"PanelContainer/ScrollContainer/button_container/from start".grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(panel_container.global_position)
	accel += delta * move_accel
	if not panel_container.global_position.x == pivot.global_position.x:
		animation_player.play("on appear")
		panel_container.global_position.x = move_toward(panel_container.global_position.x, pivot.global_position.x,accel )
