extends Area2D
var player
@export var no_uproll: bool
@export var no_slope_launch: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if not body.is_in_group("can roll"):
		return
	if body.is_in_group("can roll"):
		body.angler_dir = -1
		body.store_angler_dir = -1
		player = body
		player.can_walldive = false
		player.no_slope_launch = no_slope_launch
		player.can_uproll = no_uproll
		player.floor_slope_disable = true
		#print("in slope")



func _on_body_exited(body):
	if not body.is_in_group("can roll"):
		return
	if body.is_in_group("can roll"):
		body.angler_dir = 0
		body.store_angler_dir = -1
		player.can_uproll = false
		player.no_slope_launch = false
		player.floor_slope_disable = false


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	monitorable = true
	monitoring = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	monitorable = false
	monitoring = false
