extends CanvasLayer
@onready var switch_mode: TouchScreenButton = $AspectRatioContainer/switch_mode
var skates_on: bool
@onready var skates_on_off_button: AnimatedSprite2D = $AspectRatioContainer/switch_mode/skates_on_off_Button
@export var skate_icon_off: AtlasTexture
@export var skate_icon_on: AtlasTexture
@export var skate_icon_pressed_off: AtlasTexture
@export var skate_icon_pressed_on: AtlasTexture
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if skates_on == false:
		switch_mode.texture_normal = skate_icon_off
		switch_mode.texture_pressed = skate_icon_pressed_off
	else:
		switch_mode.texture_normal = skate_icon_on
		switch_mode.texture_pressed = skate_icon_pressed_on
	pass
