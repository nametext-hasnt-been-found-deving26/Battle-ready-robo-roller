extends Control

func _ready():
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func menu_paused():
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()
# Called when the node enters the scene tree for the first time.


func _on_resume_pressed():
	resume()


func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()


func _process(delta):
	menu_paused()


func _on_downwards_dash_mode_pressed() -> void:
	Settings.cycle_dash_mode()
	$PanelContainer/ScrollContainer/Content/downwards_dash_mode.text = "Down Dash: " + Settings.current_dash_mode
