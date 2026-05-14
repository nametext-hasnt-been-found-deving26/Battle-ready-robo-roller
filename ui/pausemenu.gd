extends Control

@export var current_theme: AudioStream
@onready var mixtape_button_container: VBoxContainer = $mixtape_buttons
@onready var mixtape: PanelContainer = $playlist
@onready var mixtape_downscroll: Button = $mixtape_buttons/mixtape_downscroll
var downscroll_normal =  preload("uid://c7i06xl6g175m")
var downscroll_focus = preload("uid://cp3j7tkixjpd0")
@onready var music_display: PanelContainer = $music_display
@onready var music_disc: Sprite2D = $music_display/music_disc




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

	_set_mixtape_ui()


func _on_downwards_dash_mode_pressed() -> void:
	Settings.cycle_dash_mode()
	$PanelContainer/ScrollContainer/Content/downwards_dash_mode.text = "Down Dash: " + Settings.current_dash_mode

func _set_mixtape_ui():
	mixtape_button_container.position.y = mixtape.position.y - 10
	mixtape_button_container.position.x = (
		mixtape.position.x- (mixtape_button_container.size.x))
	mixtape_button_container.size.y = mixtape.size.y + 10
	music_display.position.x = mixtape.position.x
	music_display.size.x = mixtape.size.x
	music_display.position.y = mixtape.position.y - music_display.size.y
	music_disc.position.y = music_display.size.y/2
	music_disc.position.x = 15
	
	


func _on_mixtape_downscroll_pressed() -> void:
	mixtape.move_selection(1)


func _on_mixtape_upscroll_pressed() -> void:
	mixtape.move_selection(-1)
