extends Area2D
var player
var player_upspeed
var player_downspeed
var can_walldive : bool
@export var disable_switch_H: bool
@export var disable_switch_V: bool
@onready var dive_starter: Marker2D = $dive_starter
@onready var switch_starter: Marker2D = $switch_starter


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("can roll"):

		body.angler_dir = 1
		player = body
		player.no_slope_launch  = true
		player.can_uproll = true
		if player.velocity.y < 0 and disable_switch_H == false and player.can_wallrun_left == true:###
			#if player.direction_change == false:
			player_upspeed = player.velocity.y
			player.switch_starting_location = switch_starter.global_position
			player.switch_speed = player_upspeed
			player.direction_change = true
			player.direction_change_timer.start()
		if disable_switch_V == false:
			player.walldive_starting_location = dive_starter.global_position
			player.can_walldive = true
					
		#if player.direction_change == true:
			
		#if player.can_walldive == true:
			#player.switch_speed = player_downspeed
		


func _on_body_exited(body):
	if body.is_in_group("can roll"):
		body.angler_dir = 0
		player.direction_change = false
		player.can_walldive = false
