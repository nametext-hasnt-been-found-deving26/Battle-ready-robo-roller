extends Node


@export var base_SPEED = 900.0
@export var JUMP_VELOCITY = -500.0
var speed: float = 900
@export var base_accel = 10
var accel: float
var angle : Vector2
var fixed_angle : int
var pre_angle = 0
var player_vel : float
var rotated_direction: Vector2
var ray_cast_2d: RayCast2D 
var starter : bool
var cayote_jump: bool
var jump_buffer : bool
var jump_buffer_timer: Timer 
var cayote_timer: Timer 
var projected_speed
var entered = false

#var angle_multiplier := 0


@export var angle_multiplier : int = 4



func enter(player, delta, direction):
	if entered:
		physics_update(player, delta, direction)
		return
	jump_buffer_timer = player.jumpbuffer_timer
	cayote_timer = player.cayote_timer
	ray_cast_2d = player.wallrunning_wallchecker
	entered = true
	pass
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func physics_update(player, delta, direction):

	if ray_cast_2d.is_colliding():
		angle =  lerp(ray_cast_2d.get_collision_normal(), player.get_floor_normal(), 0.15)
		#print (player.get_floor_normal())
	#_handle_player_velocity(direction,delta)
	#_handle_angle_change(direction)
	#if ray_cast_2d.is_colliding():
	#if is_on_ceiling() or is_on_floor() or is_on_wall():
		#velocity = velocity.slide(angle)
	var tangent = Vector2(-angle.y, angle.x).normalized()
	#var target_speed = speed * -direction
	#var current_speed = velocity.dot(tangent)
	#current_speed = move_toward(current_speed, target_speed, accel)
	projected_speed = player.velocity.dot(tangent)
	_handle_accel(direction)
	
	projected_speed = move_toward(projected_speed + (tangent.angle()* angle_multiplier), speed * direction, accel)
	speed = base_SPEED if projected_speed * direction < base_SPEED  else projected_speed
	if Input.is_action_just_pressed("jump"):
		jump_buffer = true
		
	if jump_buffer:
		if ray_cast_2d.is_colliding() or cayote_jump:
			player.velocity += ray_cast_2d.get_collision_normal() * -JUMP_VELOCITY
			
			#print("tried ", player.velocity)
			cayote_jump = false
			if not ray_cast_2d.is_colliding():
				jump_buffer = false
	if Input.is_action_just_released("jump") and player.velocity.y < 0  and not player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY / 6
	if not ray_cast_2d.is_colliding():
		player.velocity.y += gravity * delta
		player.velocity.x = move_toward(player.velocity.x  , base_SPEED  * direction, accel)
		player_vel = 0
	elif not jump_buffer :
		#var slope_force = angle.dot(Vector2.DOWN)
		#position += ray_cast_2d.get_collision_normal() * -1
		#velocity += tangent * slope_force * 50
		player.velocity = tangent * projected_speed
		if  player.is_on_floor() or  player.is_on_wall() or player.is_on_ceiling():
			pass
		else:
			player.velocity.y += gravity * delta * 2
		#var slope_force = angle.dot(Vector2.DOWN)
		#print("slope force ", tangent.angle())
		#if abs(tangent.angle()) >= 3.14 :
			#velocity += tangent *( tangent.angle() -  3.14 ) * -5
		#else:
			#velocity += tangent *( tangent.angle()  ) * 5

		#print(player.velocity)
	


	#print(ray_cast_2d.get_collision_normal()  * (180 / 3.141592))
	_handle_rotation(player,tangent)
	
	
	
		
	#move_and_slide()
	if jump_buffer:
		jump_buffer_timer.start()
	if ray_cast_2d.is_colliding():
		cayote_jump = true
	else:
		cayote_timer.start()

func _handle_rotation(player,tangent):
	if ray_cast_2d.is_colliding():
		player.rotation = tangent.angle()
	else:
		player.rotation = move_toward(player.rotation, 0 , 0.2)
		

func _handle_accel(direction):
	if not direction:
		accel = 1.5
		return
	if projected_speed * direction >= base_SPEED :
		accel = 0
		print(projected_speed)
	else:
		accel = base_accel
		
func _handle_angle_change(direction):
	

	#print("change")
	#print("Ceiling angle: ", ceiling_angle )
	#velocity = velocity.rotated(deg_to_rad(ceiling_angle - up_angle))
	var tangent = Vector2(-angle.y, angle.x)
	rotated_direction =  tangent 
	#projected_speed = velocity.dot(tangent)
	
	#print(tangent)
	pre_angle = angle
	#print(velocity)

func _handle_player_velocity(direction,delta):
	if starter == false  and not angle.x == 0:
		#print ("speed length ",velocity.length(), "angle", abs(angle)/ angle )
		#if velocity.y > abs(velocity.x):
			#player_vel =  velocity.length() * (abs(angle)/angle)
			#print(player_vel, " player vel")
			#starter = true
			#print("upies")
		#elif velocity.y < abs(velocity.x) and angle.x != 0 :
			#player_vel =  velocity.length() * (abs(velocity.x)/velocity.x )* -1
			#starter = true
			print("sidies")
	#player_vel  = move_toward(player_vel + angle * -0.2   , speed  * direction, accel)
	


func _on_cayote_timer_timeout() -> void:
	cayote_jump = false


func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false
