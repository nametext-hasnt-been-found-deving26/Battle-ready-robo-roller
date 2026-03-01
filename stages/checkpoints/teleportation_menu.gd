extends Control
@onready var slots_container: HBoxContainer = $CenterContainer/Panel/ScrollContainer/SlotsContainer

@export var checkpoint_slot_scene: PackedScene
var player
var current_index := 0
var slots: Array = []
var Id
var was_teleporting := false
@onready var teletransport_trail_buffer_timer: Timer = $teletransport_trail_buffer_Timer
var base_position
@export var teleport_trail: PackedScene


func _ready() -> void:
	visible = false
func open(p: CharacterBody2D, current_checkpoint_id: String ):
	player = p
	visible = true
	
	build_slots()
	current_index = get_checkpoint_index(current_checkpoint_id)
	update_selection()
	


	

func build_slots():
	slots.clear()

	var container = $CenterContainer/Panel/ScrollContainer/SlotsContainer

	for child in container.get_children():
		child.queue_free()

	var checkpoints = HandlePlayerInStage.activated_checkpoints

	for checkpoint in checkpoints:
		var slot = checkpoint_slot_scene.instantiate()
		container.add_child(slot)   # ADD FIRST
		slot.setup(checkpoint)  # THEN configure
		slots.append(slot)

		print("Checkpoint dictionary:", checkpoint)
		print("Preview value:", checkpoint.get("preview"))

func _process(_delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
	# Detect transition
	if player.teleporting and not was_teleporting:
		open(player, HandlePlayerInStage.current_checkpoint_id)

	if not player.teleporting and was_teleporting:
		close()

	was_teleporting = player.teleporting

	if Input.is_action_just_pressed("ui_right") and  player.teleporting == true:
		current_index = clamp(current_index + 1, 0, slots.size() - 1)
		update_selection()

	if Input.is_action_just_pressed("ui_left") and  player.teleporting == true:
		current_index = clamp(current_index - 1, 0, slots.size() - 1)
		update_selection()

	#if not visible:
		#return



func update_selection():
	for i in range(slots.size()):
		slots[i].set_selected(i == current_index)
		

	teleport_to_selected()

func teleport_to_selected():
	if HandlePlayerInStage.activated_checkpoints.is_empty():
		return
	
	var checkpoint = HandlePlayerInStage.activated_checkpoints[current_index]
	
	if base_position != player.global_position and teletransport_trail_buffer_timer. is_stopped():
		base_position = player.global_position
		teletransport_trail_buffer_timer.start()
	player.global_position = checkpoint.position
	create_trail(base_position, checkpoint.position)
	player.just_teleported = true

func close():
	visible = false

func get_checkpoint_index(id: String) -> int:
	for i in range(HandlePlayerInStage.activated_checkpoints.size()):
		var c = HandlePlayerInStage.activated_checkpoints[i]
		if c["id"] == id:
			return i
	return 0

func create_trail( int_position, end_position):
	var trail = teleport_trail.instantiate()
	trail.int_position = int_position
	trail.end_position = end_position
	get_tree().current_scene.add_child(trail)


func _on_teletransport_trail_buffer_timer_timeout() -> void:
	base_position = player.global_position
