extends ScrollContainer

@onready var content: Control = $Content

var offset_step: float = -30.0    # diagonal horizontal shift
var item_height: float = 100.0
var item_width: float = 250.0
var spacing: float = 16.0

var scroll_target: float = 0.0
var scroll_speed: float = 5.0
var smoothness: float = 1.0   # lower = slower and softer
var current_index := 0


func _ready() -> void:
	# Layout buttons diagonally
	layout_diagonal()

	# Enable UI focus and connect focus_entered for each button
	for i in range(content.get_child_count()):
		var btn := content.get_child(i) as Button
		if btn:
			btn.focus_mode = Control.FOCUS_ALL
			btn.connect("focus_entered", Callable(self, "_on_button_focus_entered").bind(i))

	# Focus the first button (if exists)
	if content.get_child_count() > 0:
		var first_btn := content.get_child(0) as Button
		if first_btn:
			first_btn.grab_focus()

func layout_diagonal() -> void:
	var total_height: float = 0.0
	var max_right: float = 0.0

	for i in range(content.get_child_count()):
		var btn := content.get_child(i) as Button
		if btn == null:
			continue

		btn.size = Vector2(item_width, item_height)
		var x: float = float(i) * offset_step
		var y: float = float(i) * (item_height + spacing)
		btn.position = Vector2(x, y)

		total_height = max(total_height, y + item_height)
		max_right = max(max_right, x + item_width)

	# Ensure content has explicit minimum size bigger than viewport so scroll works
	content.custom_minimum_size = Vector2(max_right, total_height)

func _on_button_focus_entered(index: int) -> void:
	var btn := content.get_child(index) as Button
	if btn:
		scroll_target = float(btn.position.y) - float(size.y) / 2.0 + float(btn.size.y) / 2.0
		update_highlight(index)





func _process(delta: float) -> void:
	if not get_tree().paused:        
		return

	
	var current := float(scroll_vertical)    
	var target := float(scroll_target)
	# Exponential smoothing with a soft ease-in/out
	var factor := 1.0 - exp(-smoothness * delta)
	var diff := target - current
	scroll_vertical = current + diff * factor * (1.0 - abs(diff) / 300.0)
	# Snap to target when very close
	if abs(scroll_vertical - scroll_target) < 0.3:        
		scroll_vertical = scroll_target




	# Debugging (uncomment if needed)
	# print("scroll_vertical:", scroll_vertical, "scroll_target:", scroll_target, "t:", t)


func reset_scroll() -> void:    
	scroll_vertical = scroll_target



	# Debugging (uncomment if needed)
	# print("scroll_vertical:", scroll_vertical, "scroll_target:", scroll_target, "t:", t)

func update_highlight(current_index: int) -> void:
	for i in range(content.get_child_count()):
		var btn := content.get_child(i) as Button
		if btn:
			btn.scale = Vector2.ONE if i != current_index else Vector2(1.08, 1.08)

func _unhandled_input(event) -> void:
	if not get_tree().paused:
		return

	# Let built-in focus movement handle up/down (buttons have focus_mode = ALL)
	if event.is_action_pressed("ui_accept"):
		var focused := get_viewport().gui_get_focus_owner() as Button
		if focused:
			focused.emit_signal("pressed")
