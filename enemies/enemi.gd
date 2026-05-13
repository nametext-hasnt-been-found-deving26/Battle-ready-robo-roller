extends StaticBody2D
var knockback = false
var Player
@onready var knockback_timer = $knockbackTimer
@export var Maxhealth: int = 2
var health = Maxhealth
const Minhealth = 0
@export var can_die = true
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D



func _physics_process(delta):
	if knockback == true and can_die == true:
		knockback_timer.start()
		$CollisionShape2D.set_disabled(true)
		knockback = false
	if health <= 0 :
		if can_die == true:
			die()

func die():
	queue_free()
func _on_knockback_timer_timeout():
	$CollisionShape2D.set_disabled(false)
	print("does work")


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		if body.imnContact == false or can_die == false and body.jump_ball == true:
			body.currentHP = body.currentHP - 1
			body.recovery_frames = true
			body.knockedback = true
			body.knockback_timer.start()
			print(body.currentHP)
		if body.imnContact == true:
			print("shouldnt hit")
		if body.tackle == true:
			health = health - 2
			body.enemybouncesfx.play()
			body.camera_2d.trigger_shake()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	area_2d.monitorable = true
	area_2d.monitoring = true
	set_physics_process(true)
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	set_physics_process(false)
	area_2d.monitorable = false
	area_2d.monitoring = false
	pass # Replace with function body.
