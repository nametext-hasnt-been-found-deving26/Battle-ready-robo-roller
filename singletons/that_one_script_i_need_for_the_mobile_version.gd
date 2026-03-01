extends Node

var player 
var mobile_input 

#func _ready():
	#await get_tree().process_frame

#	player = get_tree().current_scene.get_node("CharacterBody2D")
#	mobile_input = get_tree().current_scene.get_node("touch/touch controls")


func _process(delta: float) -> void:
	if not player:
		return
	await get_tree().process_frame

	player = get_tree().current_scene.get_node("CharacterBody2D")
	mobile_input = get_tree().current_scene.get_node("touch/touch controls")
	if mobile_input.switch_mode.visible:
		player.skates_on_off_button.visible = true
	else:
		player.skates_on_off_button.visible = false
	if player.skates_on == false:
		mobile_input.skates_on = false
	else:
		mobile_input.skates_on = true 
	pass
