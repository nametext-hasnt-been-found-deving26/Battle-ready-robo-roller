extends Area2D

@export var base_power: float = 200.0
@export var side_power_mul: float = 1.5   # Higher = stronger side influence
var push_dir = Vector2.ZERO

func _ready():
	push_dir = transform.x.normalized()

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Save direction so the player can push forward
		body.set("wind_area_dir", push_dir)
		# (Power will be adjusted each frame)
		body.set("wind_power", base_power)

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.set("wind_area_dir", Vector2.ZERO)
		body.set("wind_power", 0.0)

func _physics_process(delta):
	# Modify power dynamically depending on position
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):

			# Convert player position to area-local space
			var local = to_local(body.global_position)

			# Distance left/right relative to push direction
			var side_dist = abs(local.y)

			# Add extra power from side offset
			var added_power = side_dist * side_power_mul

			body.set("wind_power", base_power + added_power)
