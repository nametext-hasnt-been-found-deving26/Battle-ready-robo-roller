extends StaticBody2D
var player
@onready var for_wallrun_only: CollisionShape2D = $for_wallrun_only

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	if player.can_wallrun_left == true or player.can_wallrun_right == true or player.can_walldive_left == true or player.can_walldive_right == true:  
		for_wallrun_only.disabled = false
	else:
		for_wallrun_only.disabled = true   
	pass
