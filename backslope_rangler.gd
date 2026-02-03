extends Area2D
var player
var player_upspeed
var player_downspeed
var can_walldive : bool
@export var disable_switch_H: bool
@export var disable_switch_V: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("can roll"):
		body.angler_dir = -1
		player = body
		if player.velocity.y < 0 and not Input.is_action_pressed("jump")and disable_switch_H == false:
			if player.direction_change == false:
				player_upspeed = player.velocity.y
			player.direction_change = true
			player.direction_change_timer.start()
			
		if player.velocity.x < 0 and not Input.is_action_pressed("jump") and disable_switch_V == false:
			print("engaging walldive")
			player.velocity.y = abs(player.velocity.x)
			player_downspeed = abs(player.velocity.x)
			player.can_walldive = true
				#print(player.angle
			if player.can_walldive == true:
				player.velocity.y = player_downspeed
					
		if player.direction_change == true:
			player.switch_speed = player_upspeed
		if player.can_walldive == true:
			player.switch_speed = player_downspeed
		


func _on_body_exited(body):
	if body.is_in_group("can roll"):
		body.angler_dir = 0
		player.direction_change = false
		player.can_walldive = false
		
