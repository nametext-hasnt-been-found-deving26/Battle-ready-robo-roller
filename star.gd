extends Area2D
@onready var recharge_timer = $rechargeTimer
var can_give = true
var has_lost = false
var has_gained = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animation()
func animation():
	if can_give == false:
		has_gained = false
		if has_lost == true:
			$AnimatedSprite2D.play("energy_regain")
		else:
			$AnimatedSprite2D.play("energy_pass")
			if $AnimatedSprite2D.frame >= $AnimatedSprite2D.sprite_frames.get_frame_count($AnimatedSprite2D.animation) - 1 :
				has_lost = true
	else:
		has_lost = false
		if has_gained == true:
			$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("energy_gained")
			if $AnimatedSprite2D.frame >= $AnimatedSprite2D.sprite_frames.get_frame_count($AnimatedSprite2D.animation) - 1 :
				has_gained = true


func _on_body_entered(body):
	if body.is_in_group("player") and can_give == true:
		print("recharge")
		body.dash_recharge = true
		recharge_timer.start()
		can_give = false
		




func _on_recharge_timer_timeout():
	can_give = true
