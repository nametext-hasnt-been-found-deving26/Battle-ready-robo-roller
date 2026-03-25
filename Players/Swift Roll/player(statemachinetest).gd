extends CharacterBody2D

enum MovementMode {
	NORMAL,
	HIT,
	DASH,
	VINE,
	RAIL_GRINDING,
	WATER,
	TELEPORTING,
}

var mode = MovementMode.NORMAL

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var Player_collision: CollisionShape2D = $CollisionShape2D
@onready var camera_2d: Camera2D = $Camera2D


@export_category("base settings")
@export var Walking_SPEED = 300.0
@export var Base_Skates_SPEED = 900.0
@export var JUMP_VELOCITY = -500.0

@export var skates_normal_gravity_multiplier: float = 1.0
@export var nonskates_gravity_multipiler: float = 1.60

@export_category("brakes settings")
@export_group("ground braking")
@export var ground_brake_accel: float = 50
@export var ground_brake_multiplier: float = 40
@export var ground_brake_over_time_multiplier: float = 1.7
@export_group("air braking")
@export var air_brake_accel: float = 3
@export var air_brake_multiplier: float = 40
@export var air_brake_over_time_multiplier: float = 1.7
@onready var braking_sfx: AudioStreamPlayer = $sfx/braking
var braking: bool = false


@export_category("slope launch settings")
@export var smoothed_angle = 0.0 ## makes slope launch angle more precise


var skating_SPEED = 900.0
@export_category("jumping settings")
@export_group("bounce")
@export var normal_jump_mutiplier: float
@export var no_skates_bounce_jump_mutiplier: float
@export var skates_bounce_jump_mutiplier: float
@export_group("slope jump")
@export_subgroup("counter jump")
@export var counter_velocity_influence_adjust: float = 6.0
@export var counter_angle_influence_adjust: float = 32.0
@export_subgroup("inward jump")
@export var jump_degrade_limit: float = 50
@export var inward_velocity_influence_adjust: float = 30.0
@export var inward_angle_influence_adjust: float = 30.0

@onready var jumpbuffer_timer: Timer = $Timers/jump_timers/jumpbufferTimer
@onready var jump_soundfx: AudioStreamPlayer = $sfx/jump_soundfx
@onready var jump_grunt_1_sfx: AudioStreamPlayer = $sfx/jump_grunt1sfx
@onready var slidejump_timer: Timer = $Timers/jump_timers/slidejumpTimer


@export_category("accelerations")
@export_group("no skates")
@export var walking_accel = 40.0
@export var running_accel = 10.0
@export_group("skates")
@export var ground_forward_past_top_speed_accel = 0.0
@export var air_drag_accel = 2.0
@export var Up_past_mach_accel = 2.0
@export var normal_ground_accel = 5.0
@export var Air_normal_accel = 3.0
@export var up_accel = 6.0
@export var down_accel = 4.0
@export var no_input_accel  = 3.0
var no_input_accel_with_air_drag = no_input_accel + air_drag_accel
@export var tackle_accel = 1.5
var accel: float 

var not_moving_x = true
var not_moving_y = true
var dir = 2
var skates_on = false

@onready var dashDurationTimer = $Timers/dash_timers/DashDurationTimer


var store_x = 0
var store_y = 0

var can_dash = 1
var downdash = false
var dash_modes = ["drag", "stop", "mixed"]
var dash_mode_index := 0  # which of the above is active
var current_dash_mode := "drag"  # default
var downdash_drag = 0
var dashDirection : int
var dodash = false
@onready var dashin: AudioStreamPlayer = $sfx/dashin


@export_category("wall cling/ wall shot")
@export var wall_cling_drag: float = 10
var wall_climb_drag_cancel: bool
var wall_cling = false
var wall_climb= false
var wall_shotLUP = false
var wall_shotLForward = false
var wall_shotLDown = false
var wall_shotRUP = false
var wall_shotRForward = false
var wall_shotRDown = false
@onready var wallshotTimer = $"Timers/wall_cling or shot_timers/wallshotTimer"
var wall_shot_arc = 0

var angle = 0
var other_angle: Vector2
var fixed_other_angle
@onready var wallcling_cooldown = $"Timers/wall_cling or shot_timers/wallclingCooldown"
var angler_dir = 0.0
var store_angler_dir = 0.0
var floor_slope_disable = false
var was_on_slope = false
var rolling = 0
@onready var fallingmomentum_timer = $Timers/fallingmomentumTimer
@onready var walldive_start_downroll_buffer_timer: Timer = $Timers/walldive_start_downroll_buffer_Timer

var can_downroll = true
var downrolling = true
var on_floor_slope = false
var no_downroll = false
var can_uproll = false
var rollin = false
var fixed_angle = 0
var target_angle:float

var jump_ball = false

@onready var jump_ball_collision: Area2D = $jump_ball





@export_category("wall run / dive settings")
var wallrun_dive_gravity_multipier: float = skates_normal_gravity_multiplier
@export var inwall_gravity_limit: float

@export_group("wall run")
@export var wall_run_gravity_multiplier: float
@export var run_direction_gravity_multiplier: float
@export var wallrerun_window: float = 0.15
@export var wallrun_switch_window: float = 0.3
@export var wallrun_assist: float = 11.0
@export var max_help_speed: float = -100
@export_group("wall dive")
@export var wall_dive_gravity_multiplier: float
@export var dive_direction_gravity_multiplier: float
@export var wallredive_window: float = 0.15
@export var walldive_switch_window: float = 0.3



@onready var possiblewallrun_timer = $Timers/on_wall_timers/wall_run_timers/possiblewallrunTimer
var can_wallrun_right = false
var can_wallrun_left = false
@onready var skates_on_off_button = $Camera2D/CanvasLayer/skates_on_off_Button
var can_disable_wallrun = false
var wallrun_switchL = false
var wallrun_switchR = false

var can_walldive_right = false
var can_walldive_left = false
var can_walldive : bool = false
var can_disable_waldive = false
var can_engage_dive: bool
@onready var possibewalldive_timer: Timer = $Timers/on_wall_timers/wall_dive_timers/possibewalldiveTimer
var walldive_starting_location
@onready var wallrunning_wallchecker: RayCast2D = $wallrunning_wallchecker
var on_wall : bool
var walldive_switchL = false
var walldive_switchR = false



var conti_up = false
var conti_down = false
var conti_dash = false
var shotdown = false

var enemy_contact = false
@onready var capsule_shape := ($CollisionShape2D as CollisionShape2D).shape

@onready var cayote_timer = $Timers/jump_timers/cayoteTimer
var can_cayote_jump = false
var dir2 = 0
var can_jump = true
var jump_buffer = false
var jumping = false
var jumping_off = false
var jump_bounce_multiplier: float

var slope_launched = false
var no_slope_launch: bool
var slope_launch_direction: float

var can_hold_vine = false
var grabbing := false
var grabbed_vine: Node = null
@onready var vine = $"."
var vine_nearby: Node = null
var vine_velocity := Vector2.ZERO
var did_vine_swinging = false
var store_velocity = 0
var vine_swinging = false
var handle_rotation

var boost_mode = 0
var can_boost_mode = false
var store_boost_mode_on_wall_cling = false
#var no_boost_mode = false
var running = false
var store_running_speed: float
var store_boost_mode = 0
var grounded : bool
@export_category("running settings")
@export var run_buffer_duration: float
var run_buffer_timer: float

@export_category("animation settings")
@export var base_animation_frame_rate: float
var animation_to_play = "idle"

@export_category("trail effects settings")
@export_group("afterimages")
@export var afterimages_buffer_time_duration: float = 0.1
var afterimages_buffer_timer: float
@export var afterimages : PackedScene
@onready var afterimage = $"."
@export var store_afterimages = 0
var advance_boost_mode = false

@export_group("dust_clouds")
@export var dust_clouds_buffer_time_duration: float = 0.1
var dust_clouds_buffer_timer: float
@export var dust_clouds : PackedScene
@onready var dust_cloud = $"."
@onready var dust_cloud_setter: Node2D = $dust_cloud_setter
var eat_my_dust : bool = false

@export_category("misc visual effects settings")
@export_group("rotation")
@export var rotation_accel : float = 2
@export_group("squash and strech")
@export_subgroup("Xs and Ys")
@export var base_scale = Vector2(0.6, 0.578)
@export var base_position = Vector2(0.0, -5.882)
@export var return_to_form_accel: float
@export_subgroup("on dash")
@export var dash_squash: float = 0.2
@export_subgroup("on jump")
@export var jump_strech: float = 0.4



@export_category("water physics")
@export var water_pull: float
@export var in_water_SPEED: float = 300
@export var water_drag: float = 5
@export var boost_mode_water_drag: float = 10
var in_water = false
var water_velocity = 0
var water_accel = 0
var can_water_run = false

var grindin = false
var store_direction = 0
var grind_speed = 0
var grind_off = false
var rail_land = false
var has_landed = false
var noskates_falling_speed = false

@onready var rail_grind: AudioStreamPlayer = $sfx/rail_grind
@onready var rail_contact: AudioStreamPlayer = $sfx/rail_contact
@onready var pass_through_rails: Timer = $Timers/pass_through_rails


var dash_recharge = false
var star_dash = 0
var can_star_dash = false
var star_dash_effect = false
var star_dashing = false

@onready var star_dash_header: AnimatedSprite2D = $star_dash_header
@onready var star_dash_glow: Sprite2D = $star_dash_glow



@onready var wallkick_lock_r: Node = $wallkick_lockR
@onready var wallkick_lock_l: Node = $wallkick_lockL
@onready var wallkick_timer: Timer = $Timers/jump_timers/wall_kick_timers/wallkickTimer
@onready var wallkicklock_timer: Timer = $Timers/jump_timers/wall_kick_timers/wallkicklockTimer
@onready var wall_kick: AudioStreamPlayer = $sfx/wall_kick

var could_wall_kick = false
var can_wall_kickL = true
var can_wall_kickR = true
var wallkick_velocity = 0.0
var store_wallkick_velocity: bool
var wallkicking = false
var wallkick_dir = 0

var can_dodgeslide = true
var do_dodgeslide = false
var slide_jump = false
var slide_angle_boost = false
var can_slide_jump = false
var contini_dodgeslide = false
@onready var dodgeslide_timer = $Timers/dash_timers/dodgeslide_timers/dodgeslideTimer
@onready var dodgeslidecooldown_timer = $Timers/dash_timers/dodgeslide_timers/dodgeslidecooldownTimer
var dodgeslide_effect = false

@export_category("buster settings")
@onready var proyectile = load("res://Players/Swift Roll/bullet.tscn")
@export var fire_rate := 0.2 # seconds between shots
var fire_timer := 0.0
var chargelevel = 1

@export_category("collision settings")
@export var collision_normal_size = Vector2(7.06 , 36.47)

@onready var muzzle: Marker2D = $Muzzle
@onready var charge_shot_timer: Timer = $Timers/buster_timers/ChargeShotTimer


var currentHP: int = 10
var imnContact = false
var imnMelee = false
var imnProyectile = false
var imnGround = false
var knockedback = false
@onready var knockback_timer = $Timers/invunerability_timers/on_hit/KnockbackTimer
@onready var invincebilityframes_timer: Timer = $Timers/invunerability_timers/on_hit/InvincebilityframesTimer


var from_dir = -1
var tackle = false

@onready var enemybouncesfx: AudioStreamPlayer = $sfx/enemybouncesfx


var recovery_frames = false

@onready var scarf = $Scarf2D
var last_velocity = Vector2.ZERO



var direction_change = false
var switch_starting_location
@export var current_tilemap: TileMap
@onready var tilemap: TileMap = current_tilemap
@onready var direction_change_timer: Timer = $Timers/on_wall_timers/direction_change/direction_change_timer
var switch_speed 

@export_category("teleportation")
var teleporting = false
var can_teleport = false
var teleport_location_x: float
var just_teleported: bool = false
@export var teleport_cancel_buffer_duration: float = 0.1
var teleport_cancel_buffer_timer: float = 1

var no_skates_slope_jump = false

func _ready():
	Settings.load_dash_mode()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var direction = Input.get_axis("left", "right") 
	match mode:
		MovementMode.NORMAL:
			apply_main_movement(delta, direction)

		MovementMode.VINE:
			apply_vine_pull(delta)

		MovementMode.RAIL_GRINDING:
			is_grinding()

		MovementMode.WATER:
			on_water(delta, direction)

		MovementMode.TELEPORTING:
			chosing_teleport_location(delta)
		#scarf.anchor_offset = Vector2(15, -20
	handle_camara_offset()
	_handle_rotation()
	_handle_squash_and_strech(delta)
	animated_sprite_2d.play(animation_to_play)
	if currentHP <= 0:
		die()
	health_bar()
	set_animation()
	if velocity.y > 0 and not is_on_floor():
		if not floor_slope_disable:
			store_y = velocity.y
			#print(store_y)
		if not walldive_start_downroll_buffer_timer.is_stopped():
			#print("something")
			can_downroll = false
			downrolling = false
			store_y = 0
		else:
			can_downroll = true
			downrolling = true
			can_walldive = false
	elif velocity.y <= 0 and not is_on_floor():
		store_y = 0
	if can_walldive_right or can_walldive_left:
		Player_collision.shape.radius = 18.24
	elif fallingmomentum_timer.is_stopped():
		Player_collision.shape.radius = collision_normal_size.x


func apply_main_movement(delta, direction):
	if get_tree().paused:
		return
	if can_teleport == true and Input.is_action_pressed("up") and Input.is_action_just_pressed("jump") and is_on_floor():
		teleporting = true
		jump_buffer = false
	if teleporting == true and is_on_floor():
		mode = MovementMode.TELEPORTING
	if teleporting == false:
		just_teleported = false
	if floor_slope_disable == true and not possibewalldive_timer.is_stopped() or angle > 0.1 and not possibewalldive_timer.is_stopped() :
		possibewalldive_timer.stop()
		possibewalldive_timer.timeout.emit()
	
	
	if grabbing and grabbed_vine:
	# Let the player influence the swing
		mode = MovementMode.VINE
	

	if direction > 0 :
		direction = 1
	if direction < 0 :
		direction = -1
	if direction != 0  and grindin == false:
		store_direction = direction 
	if in_water == true:
		mode = MovementMode.WATER
	else:
		water_accel = 0
	var dashSpeedMultiplicator = 2.7
	fire_timer -= delta
	if Input.is_action_just_pressed("jump") :
		if can_jump == true and can_walldive_left == false and can_walldive_right == false and teleporting == false:
			jump_buffer = true
			
			jumpbuffer_timer.start()
	if jump_buffer == true and downdash == true:
		if skates_on == false:
			jump_bounce_multiplier = no_skates_bounce_jump_mutiplier
		else:
			jump_bounce_multiplier = skates_bounce_jump_mutiplier
	else:
		if not is_on_floor() or grounded == true:
			jump_bounce_multiplier = normal_jump_mutiplier

	if angler_dir * velocity.x >= 0 and floor_slope_disable and store_y <= 0  and velocity.y >= 0:
		floor_snap_length = 100
		#print("something")
	if angler_dir * velocity.x < 0 and floor_slope_disable :
		floor_snap_length = 1
		if not fallingmomentum_timer.is_stopped():
			print("something else")
	if store_y > 0 and velocity.y >= 0:
		if angler_dir != 0 and floor_slope_disable or angle > 0.1:
			if skates_on:
				velocity.y += store_y * angle
				if fallingmomentum_timer.is_stopped():
					rotation_degrees = 0
					print("something")
			else:
				velocity.y += (store_y * angle) /2
			floor_snap_length = 250
			#print(velocity.y)

	if is_on_floor():
		
		did_vine_swinging = false
		if Input.is_action_pressed("jump") == false:
			can_jump = true
		#if store_y > 0:
			#velocity.y += store_y * angle
			
		if in_water == false and can_wallrun_left == false and can_wallrun_right == false:
			if skates_on == true and abs(velocity.x) > Base_Skates_SPEED and velocity.x * angler_dir > 0 and angle > 0.01 and can_downroll == false:
				velocity.y = slope_launch_direction
				#print("works")
			elif abs(velocity.x) > Walking_SPEED and skates_on == false and angler_dir * velocity.x > 0 and running == true:
				velocity.y = abs(velocity.x) / 2
			elif can_downroll == false and can_walldive_left == false and can_walldive_right == false:
				#print(0)
				velocity.y = 0
		angle = get_floor_angle()
		if angler_dir != 0:
			was_on_slope = true
		else:
			was_on_slope = false
		if angle != 0:
			fixed_angle = angle * (180 / 3.141592)
			target_angle = fixed_angle
			#print(fixed_angle)
			smoothed_angle = lerp(smoothed_angle, target_angle, 0.15)
		if angler_dir == 0:
			no_slope_launch = false
			can_uproll = false
			
		#print(angle)
		#wallcling/shot stuff --------------------------------------------------------------------------------
		if not wallcling_cooldown.is_stopped():
			wallcling_cooldown.stop()
		if not wallshotTimer.is_stopped():
			wallshotTimer.stop()
		wall_cling = false
		wall_shotLUP = false
		wall_shotLForward = false
		wall_shotLDown = false
		wall_shotRUP = false
		wall_shotRForward = false
		wall_shotRDown = false
		wall_shot_arc = 0
		wall_climb = false
		wall_climb_drag_cancel = false
		#slope launch stuff ------------------------------------------------------------------------------------
		slope_launched = false
		#wallrunning stuff ------------------------------------------------------------------------------------
		if velocity.y > -5 :
			can_wallrun_left = false
			can_wallrun_right = false
			can_disable_wallrun = false
			wallrun_switchL = false
			wallrun_switchR = false
		#walldiving stuff -----------------------------------------------------------------------------------
		if velocity.y >= 0 and is_on_floor_only()  or can_downroll:
			#print("yes")
			can_walldive_left = false
			can_walldive_right = false
			can_disable_waldive = false
			walldive_switchL = false
			walldive_switchR = false
			if not possibewalldive_timer.is_stopped():
				possibewalldive_timer.stop()
		
		if abs(velocity.x) < 400:
			braking = false
		#running stuff -----------------------------------------------------
		if abs(velocity.x) > Walking_SPEED and running == false and grounded == true:
			store_running_speed = abs(velocity.x)
			#print(store_running_speed)
			running = true
		elif abs(store_running_speed) <= Walking_SPEED or grounded == false:
			boost_mode = 0
			running = false
			store_running_speed = 0
			if run_buffer_timer >= 0:
				run_buffer_timer -= delta
			if run_buffer_timer < 0:
				grounded = true
		can_boost_mode = true
		#no_boost_mode = false
		noskates_falling_speed = false
		if can_star_dash == false:
			star_dash_effect = false

		if skates_on == true:
			if angler_dir == -1 and velocity.x >= 0 and (angle * (180 / 3.141592)) >= 75 and slope_launched == false and not disable_slope_launch() and  can_uproll == false and can_downroll == false:
				velocity.y = (( velocity.x ) * -1) 
				can_wallrun_right = true
				dodash = false
				#print("uprolling")
				possiblewallrun_timer.start()
			elif angler_dir == 1 and velocity.x <= 0 and (angle * (180 / 3.141592)) >= 75 and slope_launched == false and not disable_slope_launch() and can_uproll == false and can_downroll == false:
				#print("uprolling")
				velocity.y = ( velocity.x ) 
				can_wallrun_left = true
				possiblewallrun_timer.start()
				dodash = false
				#print("no wall run")
		
		if can_dash == 0:
			can_dash = 1
		if angler_dir != 0 and not Input.is_action_pressed("jump")  and dodash == false :
			if skates_on == false:
				if do_dodgeslide == true or Input.is_action_pressed("down") :
					
					floor_snap_length = 100
					#print("dodgeslide")
				else:
					floor_snap_length = 3
			if skates_on == true and angler_dir * velocity.x >= 0:
				#if Input.is_action_pressed("down") == false:
				floor_snap_length = 100
			else:
				floor_snap_length = 5
				#if Input.is_action_pressed("down") == true and is_on_floor():
					#floor_snap_length = 500 * 10
					#print (floor_snap_length)
					#print("yes")
			#print(angle)
		else:
			floor_snap_length = 1
	if no_skates_slope_jump == true :
			floor_snap_length = 0

			#print(no_skates_slope_jump)
	# for the main 4 directions
	if Input.is_action_pressed("left"):
		dir = -1
	if Input.is_action_pressed("right"):
		dir = 1
	if Input.is_action_pressed("up"):
		dir2 = -1
	if Input.is_action_pressed("down"):
		dir2 = -2
	# for the 4 mid-directions
	if Input.is_action_pressed("left") and Input.is_action_pressed("up"):
		dir2 = 11
	if Input.is_action_pressed("up") and Input.is_action_pressed("right"):
		dir2 = -12
	if Input.is_action_pressed("right") and Input.is_action_pressed("down"):
		dir2 = 22
	if Input.is_action_pressed("down") and Input.is_action_pressed("left"):
		dir2 = -21
	# Add the gravity.
	if not is_on_floor():
		running = false
		grounded = false
		tackle = false
		if not wallrunning_wallchecker.is_colliding() and not abs(rotation_degrees) == 90:
			braking = false
		if run_buffer_timer < 0:
			run_buffer_timer = run_buffer_duration
		#print(velocity.y)
		angle = 0
		if in_water == false:
			velocity.y += (gravity * delta) / wallrun_dive_gravity_multipier if  abs(velocity.y) < inwall_gravity_limit else (gravity * delta)
			if skates_on == false and velocity.y > -40 and noskates_falling_speed == false and wall_shotLForward == false and wall_shotRForward == false:
				velocity.y += (gravity * delta) * nonskates_gravity_multipiler
		floor_snap_length = 1
		#print(can_dash)
		if Input.is_action_just_pressed("jump") and dodash == false and skates_on == true:
			jump_ball = true
			jump_ball_collision.set_monitoring(true)
			jump_ball_collision.set_monitorable(true)
			imnContact = true
			#capsule_shape.height = 16
			#print("yes")

	
	if star_dashing == true:
		jump_ball_collision.set_monitoring(true)
		jump_ball_collision.set_monitorable(true)
		imnContact = true
	if did_vine_swinging == false and in_water == false and grindin == false and dodash == false:
		store_velocity = velocity
	# Handle jump.
	if Input.is_action_just_released("jump") and velocity.y < 0 and did_vine_swinging == false:
		if  not abs(rotation_degrees) == 90 and direction_change == false and not can_wallrun_left and not can_wallrun_right:
			velocity.y = JUMP_VELOCITY / 6
			can_jump = true
			#print(velocity.y)
	
	if jump_buffer == true and skates_on == false and can_jump == true:
		if is_on_floor() and do_dodgeslide == false or can_cayote_jump == true and do_dodgeslide == false:
			dodash = false
			velocity.y = JUMP_VELOCITY - 100 * jump_bounce_multiplier
			if angler_dir * velocity.x < 0:
				velocity.y = JUMP_VELOCITY - 100 * jump_bounce_multiplier - angle
				velocity.x -=  (JUMP_VELOCITY * (angle ) )  * store_angler_dir 
				no_skates_slope_jump = true
				velocity.x  = 0
				#print(no_skates_slope_jump)
			jump_soundfx.play()
			jump_grunt_1_sfx.play()
			can_cayote_jump = false
			can_jump = false
			jump_buffer = false
			if can_dash == 0:
				can_dash = 1
			jumping = true
	elif jump_buffer == true and skates_on == true and can_jump == true:
		if not fallingmomentum_timer.is_stopped():
			fallingmomentum_timer.stop()
			fallingmomentum_timer.timeout.emit()
		if is_on_floor() or can_cayote_jump == true:
			dodash = false
			can_walldive = false
			jump_soundfx.play()
			jump_grunt_1_sfx.play()
			jump_ball = true
			jump_ball_collision.set_monitoring(true)
			jump_ball_collision.set_monitorable(true)
			#print(jump_bounce_multiplier)
			imnContact = true
			if was_on_slope == false or abs(rotation_degrees)  < 1:
				velocity.y = JUMP_VELOCITY *  jump_bounce_multiplier
				
			else:
				if angler_dir * velocity.x < 0:
					var counter_jump_calculation = (JUMP_VELOCITY * (angle * counter_velocity_influence_adjust) * jump_bounce_multiplier)
					velocity.y = (slope_launch_direction / (fixed_angle / counter_angle_influence_adjust) * abs(velocity.x/900)) + (JUMP_VELOCITY * jump_bounce_multiplier) 
					velocity.x -=  counter_jump_calculation  * store_angler_dir 
					if abs(velocity.x) - counter_jump_calculation  < -1000:
						velocity.x = 1000 * store_angler_dir
				elif angler_dir * velocity.x > 0:
					velocity.y = slope_launch_direction + (JUMP_VELOCITY * inward_angle_influence_adjust * jump_bounce_multiplier)
					#print(velocity.y)
					velocity.x -=  (JUMP_VELOCITY * (angle * inward_velocity_influence_adjust)) * angler_dir * jump_bounce_multiplier
					if velocity.y > jump_degrade_limit:
						velocity.y = jump_degrade_limit
			can_cayote_jump = false
			can_jump = false
			jump_buffer = false
			direction_change = false
			if can_dash == 0:
				can_dash = 1
			jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("left") == false and Input.is_action_pressed("right") == false:
		not_moving_x = true
	else:
		not_moving_x = false
	if Input.is_action_pressed("up") == false and Input.is_action_pressed("down") == false:
		dir2 = 0


	if skates_on == false and grabbing == false and grindin == false and wallkicking == false and knockedback == false:
		jump_ball = false
		if boost_mode < 300 and running == false or no_skates_slope_jump == true:
			if no_skates_slope_jump == false:
				boost_mode = 0
			store_boost_mode = 0
			store_running_speed = 0
		if direction or do_dodgeslide == true:
			if abs(velocity.x) > 301 and can_boost_mode == true and no_skates_slope_jump == false or store_boost_mode != 0 and no_skates_slope_jump == false:
				if store_boost_mode != 0:
					boost_mode = store_boost_mode
					can_boost_mode = false
				if abs(velocity.x) > boost_mode or dodash == true:
					boost_mode = abs(velocity.x/ 1.2) 
					#print(boost_mode)
					can_boost_mode = false
							
			if not is_on_floor():
				if not wallrunning_wallchecker.is_colliding():
					grounded = false
					#no_skates_slope_jump = false
					#print(no_skates_slope_jump)
				if no_skates_slope_jump == true:
					
					if wallkick_lock_r.is_colliding == true or wallkick_lock_l.is_colliding == true:
						#print("no skates slope jump")
						store_boost_mode = boost_mode
						#velocity.x = fixed_angle * store_angler_dir * (store_boost_mode / 25)
					else:
						#print("no_slope jump")
						no_skates_slope_jump = false
				elif boost_mode != 0   or abs(store_boost_mode) > Walking_SPEED :
					create_dash_effect(delta)
					running = false
					store_running_speed = 0
				#store_boost_mode = 0
					velocity.x =  move_toward(velocity.x, abs(boost_mode)  *  direction , Walking_SPEED)
				else:
					velocity.x = move_toward(velocity.x, Walking_SPEED * direction, walking_accel)
					#boost_mode -=  0.02
				#print(boost_mode)
				
					
			else:
				if running == true  and abs(store_running_speed) > 300:
					velocity.x = store_running_speed  *  direction
					#print(store_running_speed)
					store_running_speed += log(delta) / log(running_accel) 
				else:
					velocity.x = move_toward(velocity.x, Walking_SPEED * direction, walking_accel)
					store_boost_mode = 0
					if running == false:
						store_running_speed = 0
				if boost_mode != 0 and is_on_floor():
					create_dash_effect(delta)
		else:
			if boost_mode != 0 and not is_on_floor():
				store_boost_mode = abs(velocity.x)
				velocity.x = move_toward(velocity.x, 0, walking_accel)
				create_dash_effect(delta)
			else:
				store_running_speed = 0
				store_boost_mode = move_toward(store_boost_mode, 0, Walking_SPEED)
				velocity.x = move_toward(velocity.x, 0, Walking_SPEED)
			
			running = false
		if knockedback == false:
			store_x = velocity.x
	if skates_on == true and grindin == false and wallkicking == false and knockedback == false or grabbing == true:
		#manage accel
		_handle_accel()
		#print (accel)
		if is_on_floor() and not Input.is_action_pressed("jump"):
			jump_ball = false
		if Input.is_action_just_released("down") and rollin == true or angle == 0 and rollin == true or not is_on_floor() and rollin == true: 
				rollin = false
		if Input.is_action_pressed("down") and is_on_floor():
			accel = 1.5
			tackle = true
			if velocity.x > 0 :
				animated_sprite_2d.flip_h = false
			if velocity.x < 0 :
				animated_sprite_2d.flip_h = true
			imnContact = true
			if slope_launched == false:
				if can_downroll == true  or can_walldive_left or can_walldive_right:
					if angler_dir != 0 and is_on_floor():
						velocity.x +=  ((angle + (store_y/60)) * angler_dir * (180 / 3.141592)/6)
						velocity.y += (gravity * delta) * (angle * (180 / 3.141592)) 
						skating_SPEED = skating_SPEED + (angle * (180 / 3.141592))/2 if velocity.x >= Base_Skates_SPEED or velocity.x <= -Base_Skates_SPEED else Base_Skates_SPEED
				elif can_downroll == false and angler_dir != 0:
					velocity.x = move_toward(velocity.x + (angle * angler_dir * 25) , (skating_SPEED - delta) * direction  , accel)
					#velocity.y += (gravity * delta) * (angle * (180 / 3.141592))
					skating_SPEED = skating_SPEED + (angle * (180 / 3.141592))/4 if velocity.x >= Base_Skates_SPEED or velocity.x <= -Base_Skates_SPEED else Base_Skates_SPEED
					#print (rolling)
		else:
			tackle = false
			#print (velocity.x)
			#print(angle)
		#main control line for skates mode -------------------------------------------------------------
		velocity.x = move_toward(velocity.x + (angle * angler_dir * 15), skating_SPEED  * direction, accel) if is_on_floor() else move_toward(velocity.x , Base_Skates_SPEED  * direction, accel)
		#manage exeed mach
		skating_SPEED = skating_SPEED + (angle * (180 / 3.141592))/4 if abs(velocity.x) >= Base_Skates_SPEED and is_on_floor() else move_toward(skating_SPEED, Base_Skates_SPEED, accel)
		if dodash == true:
			create_dash_effect(delta)
		if can_downroll == true :
			#if floor_slope_disable:
				#can_walldive_left = false
				#can_walldive_right = false
			if angler_dir != 0 and is_on_floor() or not fallingmomentum_timer.is_stopped() or angle > 0.1: 
				velocity.x += ((angle + (store_y/70)) * angler_dir * (180 / 3.141592)/8.0) 
				#velocity.y += (gravity * delta) * (angle * (180 / 3.141592)) 
				downrolling = false
				if fallingmomentum_timer.is_stopped():
					fallingmomentum_timer.start()
					#print("engage downroll ", velocity.x)
				elif (angler_dir * velocity.x) <= (0)  and abs(velocity.x) > abs(velocity.y):
					if angler_dir != 0:
						velocity.x /= fixed_angle/25
					#print("downrolling ",velocity.x)
					fallingmomentum_timer.stop()
					fallingmomentum_timer.timeout.emit()
					
				
		# exceeding mach after effects ---------------------------------------------------------------------------
		if abs(velocity.x) > 2000 or can_wallrun_left == true and abs(velocity.y) > 2000 or can_wallrun_right == true and abs(velocity.y) > 2000 or can_walldive_left == true and abs(velocity.y) > 2000 or can_walldive_right == true and abs(velocity.y) > 2000:
			advance_boost_mode = true
			#print("going too fast")
		if abs(velocity.x) < 2000  and is_on_floor() or can_wallrun_left == true and velocity.y > -2000 or can_wallrun_right == true and velocity.y > -2000 or can_walldive_left == true and abs(velocity.y) < 2000 or can_walldive_right == true and abs(velocity.y) < 2000:        
			#if advance_boost_mode == true:
				#print("exit boost mode")
			advance_boost_mode = false
			
			
		if advance_boost_mode == true:
			create_dash_effect(delta)
		#skiding physics -------------------------------------------------------------------------------------
		if direction * velocity.x < 0 and tackle == false and direction_change == false:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, skating_SPEED  * direction, (ground_brake_accel * ground_brake_multiplier )* delta * ground_brake_over_time_multiplier)
				if abs(velocity.x) > 500:
					braking = true
			else:
				velocity.x = move_toward(velocity.x, skating_SPEED  * direction, (air_brake_accel * air_brake_multiplier )* delta * air_brake_over_time_multiplier)
		else:
			braking = false
				#print("stop midair")
		if shotdown == true:
			skating_SPEED = skating_SPEED + 50
			shotdown = false
		if knockedback == false:
			store_x = velocity.x
	
	if knockedback:
	# Let knockback velocity persist, but still allow gravity
		
		#print(from_dir)
		velocity.y += gravity * delta
		apply_knockback()
		move_and_slide()
		return  # exit early so no player input overrides knockback
	if abs(velocity.x) > Base_Skates_SPEED and velocity.y < 300 and skates_on == true:
		can_water_run = true
	else:
		can_water_run = false
				
		#(direction)
		#print(accel)



	if Input.is_action_pressed("skates_on off"):
		if skates_on == true:
			skates_on_off_button.play("skates_on pressed")
		elif skates_on == false:
			skates_on_off_button.play("skates_off pressed")
	if Input.is_action_just_released("skates_on off"):
		if skates_on == true:
			skates_on = false
			skates_on_off_button.play("skates_off")
		elif skates_on == false:
			skates_on = true
			skates_on_off_button.play("skates_on")
	
	if Input.is_action_pressed("down") and Input.is_action_just_pressed("dash") and can_dodgeslide == true and is_on_floor() and skates_on == false:
		velocity.y += 500 * (angle * (180 / 3.141592))/4 
		dashDirection = 1 if dir == 1 else -1
		can_jump = false
		#print ("yes")
		do_dodgeslide = true
		dodgeslide_timer.start()
		can_dodgeslide = false
		
	elif Input.is_action_just_pressed("dash") and can_dash != 0 and not is_on_wall_only():
		dashin.play()
		dashDirection = 1 if dir == 1 else -1
		#print (dashDirection)
		dodash = true if can_dash != 0 else false
		if Input.is_action_pressed("down") and not is_on_floor():
			change_downdash_mode(delta)
			downdash = true
			if can_dash > 1:
				can_dash = can_dash - 1
		if downdash == false:
			can_dash = can_dash - 1
		if star_dash != 0:
			star_dash = star_dash - 1
		
		dashDurationTimer.start()
		jump_ball = false
		
		
	elif Input.is_action_just_pressed("dash") and can_dash != 0 and is_on_wall_only() and not Input.is_action_pressed("down"):
		jump_ball = false
		dashDirection = 1 if dir == 1 else -1
		#print(dashDirection)
		can_dash = can_dash - 1
		wallcling_cooldown.start()
	
	if contini_dodgeslide == true:
		dodgeslide_timer.set_paused(true)
		do_dodgeslide = true
	else:
		dodgeslide_timer.set_paused(false)
	if do_dodgeslide == true and skates_on == false:
		imnContact = true
		imnMelee = true
		if velocity.x > 0 and angler_dir > 0 or velocity.x < 0 and angler_dir < 0:
			velocity.x = dashDirection * ((Walking_SPEED)+ (angle * (180 / 3.141592))*3) * dashSpeedMultiplicator
			velocity.y += 150 * (angle * (180 / 3.141592))/4 
			
			#print(velocity.x)
			
			#print("that")
			dodgeslide_effect = true
			if Input.is_action_just_pressed("jump") and contini_dodgeslide == false:
				slide_jump = true
				slidejump_timer.start()
				do_dodgeslide = false
				slide_angle_boost = true
		else:
			slide_angle_boost = false
			velocity.x = dashDirection * (Walking_SPEED-50) * dashSpeedMultiplicator
			boost_mode = abs(velocity.x)
			store_running_speed = abs(velocity.x)
			#print("this")
		if Input.is_action_just_pressed("jump") and contini_dodgeslide == false:
			slide_jump = true
			slidejump_timer.start()
			do_dodgeslide = false
		dodgeslide_effect = true
		#print(boost_mode)
		dir = 1 if dashDirection == 1 else -1
	else: 
		velocity.x = store_x 
		if slide_jump == false:
			slide_angle_boost = false


	if slide_jump == true:
		
		velocity.y = JUMP_VELOCITY - 100
		jump_soundfx.play()
		jump_grunt_1_sfx.play()
		can_cayote_jump = false
		can_jump = false
		jump_buffer = false
		if can_dash == 0:
			can_dash = 1
		if slide_angle_boost == true:
			boost_mode = abs(velocity.x) * 1.026
			#print("boost mode", boost_mode)

	if dodash == true and Input.is_action_pressed("dash"):
		can_wallrun_left = false
		can_wallrun_right = false
		can_walldive_left = false
		can_walldive_right = false
		create_dash_effect(delta)
		if downdash == true:
			if can_star_dash == true:
				star_dash_header.set_visible(true)
				velocity.y = ((Walking_SPEED + 50) * dashSpeedMultiplicator) + store_velocity.y
				if velocity.y < 944:
					velocity.y = ( (Walking_SPEED + 50) * dashSpeedMultiplicator)
				Hitstopmanager.hit_stop_short()
				camera_2d.trigger_shake()
				#print(boost_mode)
				#print(velocity.x)
				star_dash_effect = true
				star_dashing = true
			elif can_star_dash == false:
				if abs(velocity.x) > 810:
					star_dash_effect = false
					star_dashing = false
					#velocity.x =(abs(velocity.x)  - 25)* dashDirection
					velocity.y = move_toward(velocity.y, 810, 800)
					#print(velocity.x)
				else:
				#velocity.x = dashDirection * SPEED * dashSpeedMultiplicator
					velocity.y = move_toward(velocity.y, 810 , 500)
			velocity.x = downdash_drag
			dodash = false if is_on_floor_only() and dodash == true else true
			#print(velocity.x)
		else:
			can_boost_mode = true
			if can_star_dash == true:
				star_dash_header.set_visible(true)
				velocity.x = (dashDirection * (Walking_SPEED + 50) * dashSpeedMultiplicator) + store_velocity.x
				if velocity.x > -944 and velocity.x < 944:
					velocity.x = (dashDirection * (Walking_SPEED + 50) * dashSpeedMultiplicator)
				Hitstopmanager.hit_stop_short()
				camera_2d.trigger_shake()
				boost_mode = abs(velocity.x)/1.4
				store_running_speed = abs(velocity.x)/1.4
				#print(boost_mode)
				#print(velocity.x)
				star_dash_effect = true
				star_dashing = true
			elif can_star_dash == false:
				if abs(velocity.x) > 810:
					star_dash_effect = false
					star_dashing = false
					#velocity.x =(abs(velocity.x)  - 25)* dashDirection
					velocity.x = move_toward(velocity.x, 810 * dashDirection, 800)
					#print(velocity.x)
					
				else:
				
				#velocity.x = dashDirection * SPEED * dashSpeedMultiplicator
					velocity.x = move_toward(velocity.x, 810 * dashDirection, 500)
				#boost_mode = abs(velocity.x)
				#can_boost_mode = true
				#can_boost_mode = true
				#print(boost_mode)
				store_running_speed = abs(velocity.x)
			velocity.y = 0
			wall_cling = true if is_on_wall_only() and dodash == true else false
			#print(velocity.x)
			dir = 1 if dashDirection == 1 else -1
	else: 
		downdash = false
		star_dashing = false
		star_dash_header.set_visible(false)
		if do_dodgeslide == false:
			velocity.x = store_x 
		
		
	if star_dash == 0 and dodash == false:
		can_star_dash = false
		star_dash_glow.set_visible(false)
	elif star_dash > 0:
		can_star_dash = true
		star_dash_glow.set_visible(true)

	
	var wall_cling_dir: int

	if wall_cling == true and is_on_wall() and not is_on_floor() or wall_cling == true and wall_climb == true:
		if wallkick_lock_r.is_colliding == true or wallkick_lock_l.is_colliding == true:
			if wallkick_lock_r.is_colliding == true :
				wall_cling_dir = 1
			elif wallkick_lock_l.is_colliding == true:
				wall_cling_dir = -1
		else:
			wall_cling = false
		velocity.x = wall_cling_dir
		
		if wall_climb_drag_cancel == false or velocity.y > 0:
			velocity.y = move_toward(velocity.y, 0, wall_cling_drag)
			wall_climb_drag_cancel = false
		wall_shotLUP = false
		wall_shotLForward = false
		wall_shotLDown = false
		wall_shotRUP = false
		wall_shotRForward = false
		wall_shotRDown = false
		wall_shot_arc = 0
		if abs(wallkick_velocity) > 0:
			wallkick_velocity = abs(wallkick_velocity) - 5
		boost_mode = 0
		if boost_mode != 0:
			store_boost_mode = velocity.x
		dashDirection = wall_cling_dir
		if can_dash < 1:
			can_dash += 1
		dir = dashDirection
		if Input.is_action_just_pressed("dash"):
			if Input.is_action_pressed("up"):
				wall_climb = true
			else:
				wall_cling = false
				wall_climb = false
				dashDirection = wall_cling_dir
				velocity.x = dashDirection * Walking_SPEED 
				velocity.y += gravity * delta
		else:
			wall_climb = false
		if dashDirection == 1:
			if Input.is_action_pressed("jump") and  Input.is_action_pressed("up") or Input.is_action_pressed("jump") and  Input.is_action_pressed("up") and  Input.is_action_pressed("left"):
				wall_shotLUP = true
				wall_cling = false
				#velocity.y = -5000
				dashDirection = -1
				wallshotTimer.start()
				wallcling_cooldown.start()
				#print("LUP")
			elif Input.is_action_pressed("jump") and  Input.is_action_pressed("down") or Input.is_action_pressed("jump") and  Input.is_action_pressed("down") and  Input.is_action_pressed("left"):
				wall_shotLDown = true
				wall_cling = false
				dashDirection = -1
				wallshotTimer.start()
				wallcling_cooldown.start()
				#print("Ldown")
			elif Input.is_action_pressed("jump") and Input.is_action_pressed("left") or Input.is_action_pressed("jump") and not_moving_x == true:
				wall_shotLForward = true
				wall_cling = false
				dashDirection = -1
				wallshotTimer.start()
				wallcling_cooldown.start()
				#print("Lforward")
		elif dashDirection == -1:
			if Input.is_action_pressed("jump") and Input.is_action_pressed("up") or Input.is_action_pressed("jump") and Input.is_action_pressed("up") and Input.is_action_pressed("right"):
				wall_shotRUP = true
				wall_cling = false
				#velocity.y = -5000
				dashDirection = 1
				wallshotTimer.start()
				wallcling_cooldown.start()
				#print("Rup")
			elif Input.is_action_pressed("jump") and Input.is_action_pressed("down") or Input.is_action_pressed("jump") and Input.is_action_pressed("down") and Input.is_action_pressed("right"):
				wall_shotRDown = true
				wall_cling = false
				dashDirection = 1
				wallshotTimer.start()
				wallcling_cooldown.start()
			elif Input.is_action_pressed("jump") and Input.is_action_pressed("right") or Input.is_action_pressed("jump") and not_moving_x == true:
				wall_shotRForward = true
				wall_cling = false
				dashDirection = 1
				wallshotTimer.start()
				wallcling_cooldown.start()
		
	if wall_climb_drag_cancel == true and Input.is_action_just_released("dash"):
		velocity.y /= 6
	if wall_climb == true and wall_climb_drag_cancel == false:
		velocity.y += JUMP_VELOCITY
		wall_climb = false
		wall_climb_drag_cancel = true
	if wall_shotLUP == true:
		store_wallkick_velocity = false
		if abs(wallkick_velocity/2) > 300:
			velocity.x = abs(wallkick_velocity/2) * dashDirection
			velocity.y = JUMP_VELOCITY - abs(wallkick_velocity/6)  - wall_shot_arc
		else:
			velocity.x = dashDirection * Walking_SPEED
			velocity.y = JUMP_VELOCITY - wall_shot_arc
		velocity.y = JUMP_VELOCITY - wall_shot_arc
		wall_shot_arc = wall_shot_arc - 10
		dir = -1
		jump_buffer = false
	if wall_shotLForward == true:
		store_wallkick_velocity = false
		if abs(wallkick_velocity) > 800:
			velocity.x = abs(wallkick_velocity)
		else:
			velocity.x = dashDirection *(skating_SPEED - 100)
		velocity.y = -300 + wall_shot_arc 
		
		wall_shot_arc = wall_shot_arc + delta * 2000
		#print(wall_shot_arc)
		dir = -1
		jump_buffer = false
		
	if wall_shotLDown == true:
		store_wallkick_velocity = false
		if abs(wallkick_velocity) > 1000:
			velocity.x = dashDirection * (skating_SPEED + abs(wallkick_velocity))
		else:
			velocity.x = dashDirection * (skating_SPEED + 5)
		velocity.y += (gravity * delta) * 3
		dir = -1
		shotdown = true
		jump_buffer = false
		#print(velocity.x)
		
	if wall_shotRUP == true:
		store_wallkick_velocity = false
		if abs(wallkick_velocity/1.5) > 300:
			velocity.x = abs(wallkick_velocity/1.5) * dashDirection
			velocity.y = JUMP_VELOCITY - abs(wallkick_velocity/8)  - wall_shot_arc
		else:
			velocity.x = dashDirection * Walking_SPEED
			velocity.y = JUMP_VELOCITY - wall_shot_arc
		wall_shot_arc = wall_shot_arc - 10
		dir = 1
		jump_buffer = false
	if wall_shotRForward == true:
		store_wallkick_velocity = false
		if abs(wallkick_velocity) > 800:
			velocity.x = abs(wallkick_velocity)
		else:
			velocity.x = dashDirection *(skating_SPEED - 100)
		velocity.y = -250 + wall_shot_arc 
		wall_shot_arc = wall_shot_arc + delta * 1500
		dir = 1
		jump_buffer = false
	if wall_shotRDown == true:
		store_wallkick_velocity = false
		if abs(wallkick_velocity) > 1000:
			velocity.x = dashDirection * (100 + abs(wallkick_velocity))
			#print("yeah")
		else:
			velocity.x = dashDirection * (skating_SPEED + 5)
		velocity.y += (gravity * delta) * 10
		dir = 1
		shotdown = true
		jump_buffer = false


	#if can_wallrun_right == true or can_walldive_right == true:
		
	if wall_cling == true and is_on_wall() and not is_on_floor() or wallkicking == true:
		pass
	else:
		handle_wallkick_lock_dir()
	if not wallkick_lock_r.is_colliding == true and wallkick_lock_r.enabled == true or not wallkick_lock_l.is_colliding == true and wallkick_lock_l.enabled == true:
		store_wallkick_velocity = true
	if wallkick_lock_r.is_colliding == true and velocity.x != 0 and store_wallkick_velocity == true or wallkick_lock_l.is_colliding == true and velocity.x != 0 and store_wallkick_velocity == true:
		wallkick_velocity = velocity.x
		store_wallkick_velocity = false
		#print(wallkick_velocity)
	
	if wallkick_lock_r.is_colliding == true and not is_on_floor() and wall_cling == false or wallkick_lock_l.is_colliding == true and not is_on_floor() and wall_cling == false:
		if could_wall_kick == true:
			wallkick_timer.start()
			could_wall_kick = false
		if can_wall_kickL == true and Input.is_action_just_pressed("jump") and can_wallrun_right == false and can_wallrun_right == false or can_wall_kickR == true and Input.is_action_just_pressed("jump") and can_wallrun_right == false and can_wallrun_right == false:
			if wall_shotLUP == false and wall_shotRUP == false and wall_shotLForward == false and wall_shotRForward == false and wall_shotLDown == false and wall_shotRDown == false and wall_cling == false:
				wallkicking = true
					#print("wallkick")
				if skates_on == false:
					wallkicklock_timer.start()
				if wallkick_lock_r.is_colliding == true:
					can_wall_kickR = false
					can_wall_kickL = true
					wallkick_dir = -1
				elif wallkick_lock_l.is_colliding == true:
					can_wall_kickR = true
					can_wall_kickL = false
					wallkick_dir = 1
				wall_kick.play()
				#print(wallkick_velocity)
				if can_dash == 0:
					can_dash = 1
	else:
		could_wall_kick = true
		can_wall_kickL = true
		can_wall_kickR = true
		
		

	if wallkicking == true:
		if skates_on == true:
			velocity.x = wallkick_velocity * -1.2 + (300*wallkick_dir)
			if velocity.y < 0:
				velocity.y += JUMP_VELOCITY/4 - abs(wallkick_velocity)/2
			else:
				velocity.y = JUMP_VELOCITY/4 - abs(wallkick_velocity)/2
			if dir == 1:
				dir = -1
			elif dir == -1:
				dir = 1
			wallkicking = false
		else:
			velocity.x =( abs(wallkick_velocity) + 300)*wallkick_dir
			velocity.y = JUMP_VELOCITY/3 - abs(wallkick_velocity)/2
			boost_mode = abs(velocity.x/ 1.2) + 10 
		
		

		

	if downrolling == true :
		if is_on_floor()  :
			#if floor_slope_disable == false :
			if angle < 0.1:
				fallingmomentum_timer.start()
			#	print("start downroll",store_y)
				downrolling = false
			if not skates_on:
				fallingmomentum_timer.start()
				downrolling = false
				print("yes")
			
			

	if enemy_contact == true:
		
		Hitstopmanager.hit_stop_short()
		camera_2d.trigger_shake()
		enemybouncesfx.play()
		if not jump_ball:
			enemy_contact = false
		if jump_ball == true:
			if can_dash < 1:
				can_dash = 1
			if Input.is_action_pressed("jump"):
				velocity.y = (velocity.y * -1) +  JUMP_VELOCITY if velocity.y > 0 else velocity.y/1.5 + JUMP_VELOCITY  + -175
			else: 
				velocity.y = (velocity.y/1.5 * -1) + JUMP_VELOCITY/2 if velocity.y > 0 else velocity.y/1.5 + JUMP_VELOCITY/2 + -175 
			enemy_contact = false
			#rotate(0.5)
		
	if jump_ball == false and tackle == false and star_dashing == false:
		jump_ball_collision.set_monitoring(false)
		jump_ball_collision.set_monitorable(false)
		if do_dodgeslide == false and star_dashing == false:
			imnContact = false
		#capsule_shape.height = 37
		#elif dir == 1:
			#rotate(-0.5)
	#else:
	if Input.is_action_just_pressed("shoot"):
		shoot()
		fire_timer = fire_rate
	if Input.is_action_pressed("shoot"):
		charge_shot_timer.start()
	if Input.is_action_just_released("shoot") and fire_timer <= 0 and do_dodgeslide == false:
		if chargelevel > 1:
			shoot()
			fire_timer = fire_rate
		charge_shot_timer.stop()
		#rotate(0)
			

			
	if grabbing:
		# Skip movement while holding vine
		if Input.is_action_just_released("jump"):
			grabbing = false
			grabbed_vine.release_handle()
			grabbed_vine = null
			velocity = vine_velocity  # ← apply the stored velocity on release

		
		

		
	if can_walldive and walldive_start_downroll_buffer_timer.is_stopped():
		walldive_start_downroll_buffer_timer.start()

	if can_walldive == true and not is_on_floor() and skates_on == true and can_engage_dive == true:
		walldive_start_downroll_buffer_timer.start()
		#can_downroll = false
		jump_buffer = false
		if angler_dir == 1:
			print("engage walldive")
			can_walldive_right = true
			velocity.y = abs(velocity.x)
			#velocity.x = 0
		if angler_dir == -1:
			print("engage walldive left")
			can_walldive_left = true
			velocity.y = abs(velocity.x)
			#velocity.x = 0
		global_position = walldive_starting_location
		velocity.x = 0
		can_engage_dive = false
		can_walldive = false
		
	if can_disable_waldive == true and not wallrunning_wallchecker.is_colliding():
		if possibewalldive_timer.is_stopped():
			wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
			possibewalldive_timer.wait_time = wallredive_window
			possibewalldive_timer.start()
	elif walldive_switchL == true or walldive_switchR == true:
		jump_buffer = false
		if is_on_wall():
			if walldive_switchR == true:
				can_walldive_right = true
				dir = 1
				walldive_switchR = false
			elif walldive_switchL == true:
				dir = -1
				can_walldive_left = true
				walldive_switchL = false
		if possibewalldive_timer.is_stopped():
			wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
			possibewalldive_timer.wait_time = walldive_switch_window
			possibewalldive_timer.start()
			
	if can_disable_wallrun == true:
		wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
		if possiblewallrun_timer.is_stopped():
			possiblewallrun_timer.wait_time = wallrerun_window
			possiblewallrun_timer.start()
	elif wallrun_switchL == true or wallrun_switchR == true:
		jump_buffer = false
		if is_on_wall():
			if wallrun_switchR == true:
				can_wallrun_right = true
				dir = 1
				wallrun_switchR = false
			elif wallrun_switchL == true:
				dir = -1
				can_wallrun_left = true
				wallrun_switchL = false
		if possiblewallrun_timer.is_stopped():
			possiblewallrun_timer.wait_time = wallrun_switch_window
			possiblewallrun_timer.start()
	
	if disable_slope_launch():
		slope_launched = true
			
	if direction_change == true and switch_speed != 0 :
		if direction_change_timer.is_stopped():
			#global_position = switch_starting_location
			direction_change_timer.start()
		if not possiblewallrun_timer.is_stopped():
			possiblewallrun_timer.stop()
		if angler_dir == 1:
			velocity.x = abs(switch_speed) * -1
			#print(velocity.x)
		elif angler_dir == -1:
			velocity.x = abs(switch_speed)
		global_position = switch_starting_location
		velocity.y = 0
		#direction_change = false
		

#wall runs
	if can_wallrun_right == true:
		jump_ball = false
		rotation_degrees = -90
		#switch_speed = abs(velocity.y)
		#f angler_dir == -1:
			#irection_change = true
		if wallrunning_wallchecker.is_colliding() and not is_on_ceiling():
			if is_on_wall():
				velocity.x = -10
			else:
				velocity.x = move_toward(velocity.x, 0 , walking_accel)
			if not possiblewallrun_timer.is_stopped():
				possiblewallrun_timer.stop()
			can_disable_wallrun = false
			can_disable_waldive = false
			if Input.is_action_pressed("right"):
				wallrun_dive_gravity_multipier =(wall_run_gravity_multiplier + run_direction_gravity_multiplier)  
				velocity.y -= wallrun_assist * clamp(1.0 - abs(velocity.y) / max_help_speed, 0.0, 1.0) * delta
				#print(wallrun_assist * clamp(1.0 - abs(velocity.y) / max_help_speed, 0.0, 1.0) * delta)
			else:
				wallrun_dive_gravity_multipier = wall_run_gravity_multiplier 
			if Input.is_action_pressed("left") or velocity.y >= 0:
				wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
				can_wallrun_right = false
				print("wall right exit")
				camera_2d.offset.y = 0
		else:
			if not is_on_ceiling():
				velocity.x =  100
			can_disable_wallrun = true
		if Input.is_action_just_pressed("jump"):
			jumping_off = true
			velocity.x = -1000
			#print(velocity.x)
			can_disable_wallrun = false
			wallrun_switchL = true
			jump_ball = true
			can_wallrun_right = false
			camera_2d.offset.y = 0


	if can_wallrun_left == true:
		jump_ball = false
		rotation_degrees = 90
		#switch_speed = abs(velocity.y)
		if wallrunning_wallchecker.is_colliding() and not is_on_ceiling():
			if is_on_wall():
				velocity.x = 10
			else:
				velocity.x = move_toward(velocity.x, 0 , walking_accel)
			if not possiblewallrun_timer.is_stopped():
				possiblewallrun_timer.stop()
			can_disable_wallrun = false
			if Input.is_action_pressed("left"):
				wallrun_dive_gravity_multipier =(wall_run_gravity_multiplier + run_direction_gravity_multiplier) 
				velocity.y -= wallrun_assist * clamp(1.0 - abs(velocity.y) / max_help_speed, 0.0, 1.0) * delta
			else:
				wallrun_dive_gravity_multipier = wall_run_gravity_multiplier 
			if Input.is_action_pressed("right") or velocity.y >= 0:
				wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
				print("wall left exit")
				can_wallrun_left = false
				camera_2d.offset.y = 0
		else:
			if not is_on_ceiling():
				velocity.x = -100
			can_disable_wallrun = true
		if Input.is_action_just_pressed("jump"):
			jumping_off = true
			velocity.x = 1000
			wallrun_switchR = true
			can_disable_wallrun = false
			jump_ball = true
			can_wallrun_left = false
			camera_2d.offset.y = 0

	
#wall dives
	if can_walldive_right == true:
		rotation_degrees = 90
		#print("diveright")
		#f angler_dir == -1:
			#irection_change = true
		if wallrunning_wallchecker.is_colliding():
			
			if is_on_wall():
				velocity.x = 10
			else:
				velocity.x = move_toward(velocity.x, 0 , walking_accel)
			if Input.is_action_pressed("right"):
				wallrun_dive_gravity_multipier = dive_direction_gravity_multiplier * wall_dive_gravity_multiplier
			elif Input.is_action_pressed("left"):
				velocity.y = move_toward(velocity.y, skating_SPEED  * direction, (ground_brake_accel * ground_brake_multiplier )* delta * ground_brake_over_time_multiplier)
				braking = true
			else:
				wallrun_dive_gravity_multipier = wall_dive_gravity_multiplier
			if velocity.y < 0:
				wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
				can_walldive_right = false
				print("wall right exit")
				camera_2d.offset.y = 0
		else:
			can_disable_waldive = true
			if not is_on_floor():
				velocity.x = -100
			else:
				velocity.x = move_toward(velocity.x, 0 , 1)
		if Input.is_action_just_pressed("jump"):
			jumping_off = true
			velocity.x = (JUMP_VELOCITY*-2)
			walldive_switchL = true
			can_disable_waldive = false
			jump_ball = true
			can_walldive_right = false
			camera_2d.offset.y = 0

	if can_walldive_left == true:
		rotation_degrees = -90
		#f angler_dir == -1:
			#irection_change = true
		if wallrunning_wallchecker.is_colliding():
			if is_on_wall():
				velocity.x = -10
			else:
				velocity.x = move_toward(velocity.x, 0 , walking_accel)
			if Input.is_action_pressed("left"):
				wallrun_dive_gravity_multipier = dive_direction_gravity_multiplier * wall_dive_gravity_multiplier
			elif Input.is_action_pressed("right"):
				velocity.y = move_toward(velocity.y, skating_SPEED  * direction, (ground_brake_accel * ground_brake_multiplier )* delta * ground_brake_over_time_multiplier)
				braking = true
			else:
				wallrun_dive_gravity_multipier = wall_dive_gravity_multiplier
			if velocity.y < 0:
				wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
				can_walldive_left = false
				print("wall right exit")
				camera_2d.offset.y = 0
		else:
			can_disable_waldive = true
			if not is_on_floor():
				velocity.x = 100
			else:
				velocity.x = move_toward(velocity.x, 0 , 1)
		if Input.is_action_just_pressed("jump"):
			jumping_off = true
			velocity.x = (JUMP_VELOCITY*2)
			walldive_switchR = true
			can_disable_waldive = false
			jump_ball = true
			can_walldive_left = false
			camera_2d.offset.y = 0

	
	if dash_recharge == true:
		can_dash = can_dash + 1
		star_dash = star_dash + 1
		dash_recharge = false
			
	if grindin == true:
		is_grinding()
	else:
		grind_speed = 0

		has_landed = false
		rail_grind.stop()
	var was_on_floor = is_on_floor()
	if grind_off == true:
		grindin = false
		#print("grind off")
		velocity.x = velocity.x + grind_speed * dashDirection
		grind_off = false
		if Input.is_action_pressed("jump"):
			velocity.y = velocity.y * 1.35
		else:
			if skates_on == true:
				velocity.y += gravity * delta - ((fixed_angle * 1.5) + (velocity.x/3) ) /3
			if skates_on == false :
				velocity.y += gravity * delta - ((fixed_angle * 1.5) + (velocity.x/2.2) )
	
	wind_push(delta)
	move_and_slide()
	if wall_shotLUP == true or wall_shotRUP == true or wall_shotLForward == true or wall_shotRForward == true or wall_shotLDown == true or wall_shotRDown == true:
		sprite_rotation()
	else:
		animated_sprite_2d.rotation = 0
	if Input.is_action_pressed("jump") and vine_nearby:
		grabbing = true
		grabbed_vine = vine_nearby
		grabbed_vine.grab_handle(velocity)


	
	if angler_dir != 0:
		set_launch_direction()
	
	if recovery_frames == true:
		invincibility_frames()

	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		if skates_on == true  and was_on_slope == true and in_water == false and grind_off == false and slope_launched == false and no_slope_launch == false and not disable_slope_launch() and fallingmomentum_timer.is_stopped():
			#if velocity.x > 2000  or velocity.x < -2000 :
			velocity.y = slope_launch_direction
			print("slope launch", velocity.y)
			slope_launched = true
			#slope_launch_direction = 0
			#print(velocity.y)
		can_cayote_jump = true
		cayote_timer.start()
		
		
	if wallrunning_wallchecker.is_colliding() and abs(rotation_degrees) < 90 or is_on_floor() or not direction_change_timer.is_stopped():
		can_engage_dive = true
		#print("can_waldive")
	elif can_walldive == false :
		can_engage_dive = false
		#print("only uproll")
	if braking == true:
		create_dust_cloud(delta)
		if skates_on == true:
			braking_sfx.play()
	else:
		eat_my_dust = true
		#print("dusting")
		
	if scarf:
		scarf.update_dash_color(can_dash)

func _handle_rotation():
	if mode == MovementMode.VINE and handle_rotation:
		rotation_degrees = handle_rotation
	elif is_on_floor():
		if skates_on == true or grindin == true:
			rotation_degrees = (angle * (180 / 3.141592)) * angler_dir   
			if Input.is_action_just_pressed("jump"):
				rotation_degrees = 0
				#print("ball jumpin")
		else:
			if do_dodgeslide == true:
				if angler_dir != 0:
					if abs(velocity.x)/velocity.x != angler_dir:
						rotation_degrees = (90 +(angle * (180 / 3.141592)))* angler_dir
						#print("upwards")
					else:
						rotation_degrees = (90 -(angle * (180 / 3.141592)))* angler_dir*-1
						#print("downwards")
				else:
					rotation_degrees = -90 * dashDirection
					#print("no angle")
			else:
				rotation_degrees = 0
	else:
		if do_dodgeslide == false:
			#if floor_slope_disable == false:
			rotation_degrees = move_toward(rotation_degrees, 0 , 2)
			if dodash == true or direction_change == true:
				rotation_degrees = 0

func _handle_accel():
	if not_moving_x == true:
		if abs(velocity.x) > Base_Skates_SPEED and not is_on_floor():
			accel = no_input_accel_with_air_drag
		else:
			accel = no_input_accel
	elif is_on_floor():
		if angler_dir == 0:
			if abs(velocity.x) > Base_Skates_SPEED and dashDirection * velocity.x > 0 :
				accel = ground_forward_past_top_speed_accel
			else: 
				accel = normal_ground_accel - abs(velocity.x / 250)
				#print(velocity.x)
		else:
			if angler_dir == dir:
				accel = down_accel
			elif angler_dir != dir:
				if velocity.x >= Base_Skates_SPEED and dashDirection  == 1 or velocity.x <= -Base_Skates_SPEED and  dashDirection == -1:
					accel = Up_past_mach_accel
				else:
					accel = up_accel
		if tackle == true:
			accel = tackle_accel
	else:
		if velocity.x >= Base_Skates_SPEED and dashDirection  == 1 or velocity.x <= -Base_Skates_SPEED and  dashDirection == -1 :
			accel = air_drag_accel
			#print(velocity.x)
		else:
			accel = Air_normal_accel - abs(velocity.x / 320)

func set_launch_direction():
	slope_launch_direction = velocity.x * tan(deg_to_rad(smoothed_angle)) * store_angler_dir
	#print(slope_launch_direction)

func _on_Area2D_body_entered(body):
	if body.name == "Vine":
		vine_nearby = body

func set_animation():
	if tackle == false:
		animated_sprite_2d.flip_h = true if dir == -1  else false
	star_dash_header.flip_h = true if animated_sprite_2d.flip_h == true else false
	if jump_ball == true and wall_cling == false:
		animation_to_play = "ball_jump"
	if tackle == true:
		animation_to_play = "rolling"
		(Player_collision.shape as CapsuleShape2D).height = 27.06
		Player_collision.position.y = 4.706
	else:
		(Player_collision.shape as CapsuleShape2D).height = 36.47
		Player_collision.position.y = 0.0
	if do_dodgeslide == true:
		animation_to_play = "dodgeslide"
		return
	elif velocity.y < 0 and can_wallrun_left == false and can_wallrun_right == false and jump_ball == false and not is_on_floor():
		if conti_up == true  :
			animation_to_play = "going_up"
			
		else:
			animation_to_play = "going_up_start"
			if animated_sprite_2d.frame >= animated_sprite_2d.sprite_frames.get_frame_count(animated_sprite_2d.animation) - 1 and animation_to_play == "going_up_start":
				conti_up = true
	elif velocity.y > 0 and can_wallrun_left == false and can_wallrun_right == false  and jump_ball == false and not is_on_floor() and can_walldive_left == false and can_walldive_right == false:
		if conti_down == true :
			animation_to_play = "going_down"
		else:
			#conti_up = false
			conti_dash = false
			animation_to_play = "going_down_start"
			if animated_sprite_2d.frame >= animated_sprite_2d.sprite_frames.get_frame_count(animated_sprite_2d.animation) - 1  and animation_to_play == "going_down_start":
				conti_down = true
	elif dodash == true and wall_cling == false and velocity.y == 0:
		if conti_dash == true and conti_down == false:
			animation_to_play = "dash"
		else:
			animation_to_play = "dash_start"
			if animated_sprite_2d.frame >= animated_sprite_2d.sprite_frames.get_frame_count(animated_sprite_2d.animation) - 1:
				conti_dash = true
	elif wall_cling == true and is_on_wall_only():
		if Input.is_action_pressed("up")  or Input.is_action_pressed("up") and Input.is_action_pressed("right") and animated_sprite_2d.flip_h == false or Input.is_action_pressed("up") and Input.is_action_pressed("left") and animated_sprite_2d.flip_h == true:
			animation_to_play = "wall_cling_up"
		elif Input.is_action_pressed("down")  or Input.is_action_pressed("down") and Input.is_action_pressed("right") and animated_sprite_2d.flip_h == false or Input.is_action_pressed("down") and Input.is_action_pressed("left") and animated_sprite_2d.flip_h == true:
			animation_to_play = "wall_cling_down"
		elif Input.is_action_pressed("right") and dashDirection == -1 or dashDirection == 1  and Input.is_action_pressed("left") :
			animation_to_play = "wall_cling_forward"
		else: 
			animation_to_play = "wall_cling_idle"
		animated_sprite_2d.flip_h = true  if dashDirection == 1 else false
	if wall_shotLUP == true or wall_shotRUP == true or wall_shotLForward == true or wall_shotRForward == true or wall_shotLDown == true or wall_shotRDown == true:
		animation_to_play = "wall_shot"
	if is_on_floor() and dodash == false and not_moving_x == false and do_dodgeslide == false or can_wallrun_left == true or can_wallrun_right == true or can_walldive_left == true or can_walldive_right == true:
		if store_running_speed != 0:
			animation_to_play = "Running"
		else:
			animation_to_play = "walking_no_skates"
		conti_dash = false
		conti_up = false
		conti_down = false
		
	elif is_on_floor_only() and dodash == false and not_moving_x == true and tackle == false:
		conti_dash = false
		conti_up = false
		conti_down = false
		if skates_on == false:
			animation_to_play = "idle"
		else:
			animation_to_play = "idle_skates"

func _handle_squash_and_strech(delta):
	if not fallingmomentum_timer.is_stopped() and jumping == false:
		#if animated_sprite_2d.position.y = (base_position.y * 20):
		if animated_sprite_2d.scale.y > 0:
			animated_sprite_2d.scale.y -= (store_y/120000) 
		#animated_sprite_2d.position.y += store_y/80000 + (base_scale.y - animated_sprite_2d.scale.y) * 2
		#print(store_y)
		#return
	elif Input.is_action_just_pressed("dash") and wall_cling == false:
		if dodash == true:
			animated_sprite_2d.scale.y -= (dash_squash) 
			#animated_sprite_2d.position.y += dash_squash + (base_scale.y - animated_sprite_2d.scale.y) * 2
		if do_dodgeslide == true:
			animated_sprite_2d.scale.x -= (dash_squash) 
			#animated_sprite_2d.position.x += dash_squash + (base_scale.x - animated_sprite_2d.scale.x) * 2
		#print("dash squash")
	elif jumping == true:
		animated_sprite_2d.scale.y += (jump_strech) 
		#animated_sprite_2d.position.y -= jump_strech + (base_scale.y - animated_sprite_2d.scale.y) * 3
		jumping = false
	elif jumping_off == true:
		#if Input.is_action_just_pressed("jump") :
		animated_sprite_2d.scale.x += (jump_strech) 
		#animated_sprite_2d.position.x -= jump_strech + (base_scale.y - animated_sprite_2d.scale.x) * 2 * dir
		jumping_off = false
		print("yeah")
	else:
		animated_sprite_2d.scale.y = move_toward(animated_sprite_2d.scale.y, base_scale.y, delta * (return_to_form_accel ))
		#animated_sprite_2d.position.y = move_toward(animated_sprite_2d.position.y, base_position.y, delta * (return_to_form_accel * 5))
		animated_sprite_2d.scale.x = move_toward(animated_sprite_2d.scale.x, base_scale.x, delta * (return_to_form_accel ))
		#animated_sprite_2d.position.x = move_toward(animated_sprite_2d.position.x, base_position.x, delta * (return_to_form_accel * 5))
	if not wallrunning_wallchecker.is_colliding() or in_water == true:
		if animated_sprite_2d.scale.x > (base_scale.x /1.2):
			animated_sprite_2d.scale.x -=   abs(velocity.y / 1000) * delta
			if abs(velocity.y) > abs(velocity.x):
				animated_sprite_2d.scale.y +=   abs(velocity.y / 1000) * delta  
		if animated_sprite_2d.scale.y > (base_scale.y /1.2):
			animated_sprite_2d.scale.y -=  abs(velocity.x / 1000)  * delta
			if abs(velocity.y) < abs(velocity.x):
				animated_sprite_2d.scale.x +=   abs(velocity.x / 950) * delta 
		#print("YES")
		

func handle_camara_offset():
	if velocity.x > 100 :
		$Camera2D.offset.x = $Camera2D.offset.x + (1 + (velocity.x / 500)) if $Camera2D.offset.x <= 85 else 90
		#print($Camera2D.offset.x)
	if velocity.x < -100:
		$Camera2D.offset.x = $Camera2D.offset.x - (1 - (velocity.x / 500))  if $Camera2D.offset.x >= -85 else -90
		#print($Camera2D.offset.x)
	if velocity.x > -100 and velocity.x <= 0  or velocity.x < 100 and velocity.x >= 0 :
		if $Camera2D.offset.x >= 2:
			$Camera2D.offset.x = $Camera2D.offset.x - 2  if $Camera2D.offset.x >= 2 else 2
		elif $Camera2D.offset.x <= -2 :
			$Camera2D.offset.x = $Camera2D.offset.x + 2  if $Camera2D.offset.x <= -2 else -2
			
	
	if velocity.y > -850 and velocity.y < 1900 and can_wallrun_right == false and can_wallrun_right == false or is_on_floor_only() and can_wallrun_right == false and can_wallrun_right == false or grabbing == true:
		if $Camera2D.offset.y >= 4:
			$Camera2D.offset.y = $Camera2D.offset.y - 4 if $Camera2D.offset.y >= 4 else 4
		if $Camera2D.offset.y <= -4 :
			$Camera2D.offset.y = $Camera2D.offset.y + 4  if $Camera2D.offset.y <= -4 else -4
	if velocity.y < -900   or can_wallrun_left == true and not is_on_floor() or can_wallrun_right == true  and not is_on_floor() :
		#print("camara up")
		$Camera2D.offset.y = $Camera2D.offset.y - (1 - (velocity.y / 500))  if $Camera2D.offset.y >= -245 else -250
	if velocity.y > 2000 and not is_on_floor() and grabbing == false:
		$Camera2D.offset.y = $Camera2D.offset.y + (1 + (velocity.y/ 250)) if $Camera2D.offset.y <= 295 else 300
		#print("camara down")

func get_player_cell() -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(global_position))

func get_tile_data_at_player() -> TileData:
	var cell := get_player_cell()
	return tilemap.get_cell_tile_data(0, cell)

func disable_slope_launch() -> bool:
	var tile_data := get_tile_data_at_player()
	if tile_data == null:
		return false
	return bool(tile_data.get_custom_data("disable_slope_launch"))

func only_uproll() -> bool:
	var tile_data := get_tile_data_at_player()
	if tile_data == null:
		return false
	return bool(tile_data.get_custom_data("only_uproll"))

func only_slope_launch() -> bool:
	var tile_data := get_tile_data_at_player()
	if tile_data == null:
		return false
	return bool(tile_data.get_custom_data("only_slope_launch"))




func is_grinding():
	var angler_onrails = 0
	var trick = false
	
	if is_on_floor_only():
		if store_direction == 1:
			dir = 2
			animated_sprite_2d.flip_h = false
		elif store_direction == -1:
			dir = 1
			animated_sprite_2d.flip_h = true
		dodash = false
		if has_landed == false:
			rail_land = true
		store_velocity.x = store_velocity.x if store_velocity.x >= 0 else store_velocity.x *-1
		if angler_dir == store_direction:
			angler_onrails = 1
		else:
			angler_onrails = -1
		if Input.is_action_pressed("jump") == false :
			velocity.y = 500
			floor_snap_length = 50
		if skates_on == false:
			grind_speed = grind_speed + 6 + store_velocity.x + ((angle * angler_onrails * 30)/8) if grind_speed <= 840 else grind_speed - 4 + ((angle * angler_onrails * 30)/8)
			velocity.x = grind_speed *  store_direction
		if skates_on == true:
			grind_speed = grind_speed - 2 + store_velocity.x + (angle * angler_onrails * 30) 
			velocity.x = grind_speed *  store_direction
			store_velocity.x = 0
			if Input.is_action_just_pressed("dash"):
				trick = true
			if trick == true :
				grind_speed = grind_speed + 220  + (angle  * 120)
				rail_contact.play()
				trick = false
		if Input.is_action_pressed("down") :
			if skates_on == false:
				grind_speed = grind_speed + 6 + store_velocity.x + ((angle * angler_onrails * 30)/4) if grind_speed <= 800 else grind_speed - 4 + ((angle * angler_onrails * 30)/4)
				velocity.x = grind_speed *  store_direction
			if skates_on == true:
				grind_speed = grind_speed - 2 + store_velocity.x + ((angle * angler_onrails * 30) *2 )
				velocity.x = grind_speed *  store_direction
				store_velocity.x = 0
			if Input.is_action_just_pressed("jump"):
				velocity.y = 100
				#print("pass through")
				Player_collision.disabled = true
				pass_through_rails.start()
	if rail_land == true:
		rail_grind.play()
		rail_contact.play()
		has_landed = true
		rail_land = false


var afterimage_velocity_buffer_multiplier: float
func create_dash_effect(delta):
	if can_wallrun_left == true or can_wallrun_right == true or can_walldive_left == true or can_walldive_right == true:
		afterimage_velocity_buffer_multiplier = (velocity.y / 200000)
	else:
		afterimage_velocity_buffer_multiplier = (velocity.x / 200000)
	if afterimages_buffer_timer >= 0:
		afterimages_buffer_timer -= delta
	var ghost = afterimages.instantiate()
	if do_dodgeslide == true:
		ghost.base = false
		ghost.star = false
		ghost.dodge = true
	elif star_dash_effect == true:
		ghost.base = false
		ghost.star = true
		ghost.dodge = false
	else:
		ghost.base = true
		ghost.star = false
		ghost.dodge = false
	if afterimages_buffer_timer < 0:
		ghost.set_property(position, animated_sprite_2d.scale * 1.7)
		get_tree().current_scene.add_child(ghost)
		if animated_sprite_2d.flip_h == true:
			ghost.flip_h = true
		else:
			ghost.flip_h = false
		ghost.play(animation_to_play)
		ghost.set_frame(animated_sprite_2d.get_frame()-1)
		ghost.rotation_degrees = rotation_degrees
		afterimages_buffer_timer = afterimages_buffer_time_duration - afterimage_velocity_buffer_multiplier

var cloud_velocity_size_multiplier: float
func create_dust_cloud(delta):
	if can_walldive_left == true or can_walldive_right == true:
		cloud_velocity_size_multiplier = (velocity.y / 2000)
	elif not fallingmomentum_timer.is_stopped():
		cloud_velocity_size_multiplier = (store_y / 2000)
	elif eat_my_dust == true:
		cloud_velocity_size_multiplier = (velocity.x / 1000)
		
	else:
		cloud_velocity_size_multiplier = (velocity.x / 2000)
	if dust_clouds_buffer_timer >= 0:
		dust_clouds_buffer_timer -= delta
	var cloud = dust_clouds.instantiate()
	if dust_clouds_buffer_timer < 0:
		cloud.set_property(dust_cloud_setter.global_position,  Vector2(abs(cloud_velocity_size_multiplier) - delta  * 2 , abs(cloud_velocity_size_multiplier) - delta * 2 ))
		get_tree().current_scene.add_child(cloud)
		if animated_sprite_2d.flip_h == true:
			cloud.flip_h = true
		else:
			cloud.flip_h = false
		if eat_my_dust == true:
			cloud.play("spike")
			eat_my_dust = false
		else:
			cloud.play("default")
		cloud.rotation_degrees = rotation_degrees
		dust_clouds_buffer_timer = dust_clouds_buffer_time_duration #+ cloud_velocity_timer_multiplier
		#print("working")

var limit_brought_back : Vector2
func apply_vine_pull(delta):
	var input_vector = Vector2(
		 Input.get_action_strength("left") - Input.get_action_strength("right"),
		0
			)
	grabbed_vine.apply_spin_input(input_vector, delta, global_position)
	var input_axis = input_vector.x
	var handle_pos = grabbed_vine.get_handle_global_position()
	handle_rotation = grabbed_vine.get_handle_rotation()
	var spring_vector = handle_pos - global_position
	var dir_to_center = spring_vector.normalized()
	var tangent = Vector2(-dir_to_center.y, dir_to_center.x)
	var radial_vel = dir_to_center * velocity.dot(dir_to_center)
	var tangential_vel = tangent * velocity.dot(tangent)
	var orbit_damping = 0.1  # tweak this

	tangential_vel *= orbit_damping
	var original_speed = velocity.length()

	velocity = radial_vel + tangential_vel

	if velocity.length() > 0:
		velocity = velocity.normalized() * original_speed
	#var direction = Input.get_axis("left", "right")
	var spring_strength = grabbed_vine.spring_strength
	var damping = 5
	var steer_strength = 2.5  # tweak this
	
	if vine_swinging == false:
		velocity += (spring_vector * spring_strength * delta) + store_velocity/70
		#velocity -= velocity * damping * delta
	else:
		if spring_vector.length() >= grabbed_vine.max_stretch:
			limit_brought_back = spring_vector.normalized() *  (spring_vector.length() - grabbed_vine.max_stretch )
			print(abs(spring_vector.x) + abs(spring_vector.y))
		else:
			limit_brought_back = Vector2.ZERO
		velocity += ((spring_vector + limit_brought_back) * spring_strength * delta) + store_velocity/140
		velocity += tangent * input_axis * 200 * delta
			
		#velocity.y += velocity.y + (gravity * delta)/20
		#print(vine.global_position)
	did_vine_swinging = true
	vine_swinging = true
	vine_velocity = velocity  # ← store the current spring velocity
	move_and_slide()
	if Input.is_action_just_released("jump"):
		grabbed_vine.release_handle()
		grabbing = false
		grabbed_vine = null
		velocity = vine_velocity * 1.5  # ← apply the stored velocity on release
		vine_swinging = false
		if can_dash < 1:
			can_dash = 1
		mode = MovementMode.NORMAL


var splash = false
func on_water(delta, direction):
	can_walldive_left = false
	can_walldive_right = false
	if is_on_floor() :
		if angler_dir == 0:
			velocity.y = JUMP_VELOCITY /2
		mode = MovementMode.NORMAL
	if splash == false:
		velocity.x = velocity.x * 0.75
		splash = true
	else:
		if in_water == true:
			if abs(velocity.x) > in_water_SPEED:
				velocity.x = move_toward(velocity.x, 0, water_drag)
			velocity.x =  move_toward(velocity.x, in_water_SPEED * direction, walking_accel)
			if boost_mode > 0:
				boost_mode = move_toward(boost_mode, 0, boost_mode_water_drag)
			#print(boost_mode)
			if velocity.y > 0:
				velocity.y -=  delta  * abs(velocity.y) / water_pull

			velocity.y -= delta * water_pull
			print(velocity.y)
			velocity.y -= water_accel /2.0
			water_accel = water_accel + 0.05
		else:
			water_accel = 0
			if skates_on == false:
				velocity.x =  move_toward(velocity.x, Walking_SPEED * direction, walking_accel)
			else:
				velocity.x =  move_toward(velocity.x, Base_Skates_SPEED * direction, Air_normal_accel)
			velocity.y += gravity * delta
	move_and_slide()


var wind_area_dir = Vector2.ZERO
var wind_power = 0.0
func wind_push(delta):
	if wind_area_dir != Vector2.ZERO:
		velocity += wind_area_dir * wind_power * delta
		#print(velocity)

var pellets_on_screen := []

func shoot():
	# Remove any pellets that have been freed
	pellets_on_screen = pellets_on_screen.filter(func(p): return is_instance_valid(p))

	if pellets_on_screen.size() >= 3:
		return # Too many pellets already

	var pellet = proyectile.instantiate()
	pellet.global_position = muzzle.global_position
	if wall_cling == false and not is_on_wall():
		pellet.rotation = rotation
	else:
		if Input.is_action_pressed("up"):
			pellet.rotation = -32
		elif Input.is_action_pressed("down"):
			pellet.rotation = 32
		else:
			pellet.rotation = 0
	if animated_sprite_2d.flip_h:
		pellet.rotation += PI  # Reverse direction by 180°
	if abs(velocity.x) > 750:
		pellet.speed_multiplier = abs(velocity.x) - 450
	else:
		pellet.speed_multiplier = 0
	get_tree().current_scene.add_child(pellet)

	pellets_on_screen.append(pellet)


#func _on_dash_effect_timer_timeout(delta):
	#if boost_mode != 0 :
		#create_dash_effect(delta)


func _on_dash_duration_timer_timeout():
	dodash = false


func handle_wallkick_lock_dir():
	if wall_cling == false:
		if dir == 1:
			wallkick_lock_r.enabled = true
			wallkick_lock_l.enabled = false
		if dir == -1:
			wallkick_lock_r.enabled = false
			wallkick_lock_l.enabled = true
	if do_dodgeslide == true:
		wallkick_lock_r.enabled = true
		wallkick_lock_l.enabled = true
	if wallrun_switchL == true or wallrun_switchR == true or walldive_switchL == true or walldive_switchR == true:
		wallkick_lock_r.enabled = false
		wallkick_lock_l.enabled = false

func _on_wallshot_timer_timeout():
	#print("no wall shot")
	wall_cling = false
	wall_shotLUP = false
	wall_shotLForward = false
	wall_shotLDown = false
	wall_shotRUP = false
	wall_shotRForward = false
	wall_shotRDown = false
	wall_shot_arc = 0
	#animated_sprite_2d.rotation = 0
	wall_cling = true if is_on_wall_only() and Input.is_action_pressed("jump") == false else false
	velocity.x = store_x 
	can_dash = 1

func die():
	get_tree().reload_current_scene()

func health_bar():
	if currentHP == 1:
		$Camera2D/CanvasLayer/healthbar.play("damaged 1")
	if currentHP == 2:
		$Camera2D/CanvasLayer/healthbar.play("damaged 2")
	if currentHP == 3:
		$Camera2D/CanvasLayer/healthbar.play("damaged 3")
	if currentHP == 4:
		$Camera2D/CanvasLayer/healthbar.play("damaged 4")
	if currentHP == 5:
		$Camera2D/CanvasLayer/healthbar.play("damaged 5")
	if currentHP == 6:
		$Camera2D/CanvasLayer/healthbar.play("damaged 6")
	if currentHP == 7:
		$Camera2D/CanvasLayer/healthbar.play("damaged 7")
	if currentHP == 8:
		$Camera2D/CanvasLayer/healthbar.play("damaged 8")
	if currentHP == 9:
		$Camera2D/CanvasLayer/healthbar.play("damaged 9")
	if currentHP == 10:
		$Camera2D/CanvasLayer/healthbar.play("damaged full")
	if currentHP == 0:
		$Camera2D/CanvasLayer/healthbar.play("damaged empty")
#var rec_x:float
#var rec_y:float
func sprite_rotation():
	if velocity.length() > 0:
		animated_sprite_2d.rotation = velocity.angle() + 90 
	#print(animated_sprite_2d.rotation_degrees)


	
func apply_knockback():
	# from_dir should be -1 if hit from right, +1 if hit from left
	if animated_sprite_2d.flip_h:
		velocity.x = 600   # facing left → push right
	else:
		velocity.x = -600
	enemy_contact = false
	invincebilityframes_timer.start()
	velocity.y = -300            # give a little upward knock
	boost_mode = 0
	 # timer will reset the state

func invincibility_frames():
	#print("yes")
	imnContact = true
	imnGround = true
	imnMelee = true
	imnProyectile = true
	


func change_downdash_mode(delta):
	#print(downdash_drag)
	match Settings.current_dash_mode:
		"drag":
			downdash_drag  = move_toward(velocity.x, 0 ,  delta*2 )
		"stop":
			downdash_drag =  0 
		"mixed":
			if skates_on == true:
				downdash_drag  = move_toward(velocity.x, 0, delta*2  )
			else:
				downdash_drag =  0



func _on_wallcling_cooldown_timeout():
	wall_cling = true






func _on_fallingmomentum_timer_timeout():
	can_downroll = false
	store_y = 0
#	print("no more downrolling")


func _on_possiblewallrun_timer_timeout():
	if not wallrunning_wallchecker.is_colliding():
		if velocity.y > -100:
			velocity.y = -100
		wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
		can_wallrun_left = false
		can_wallrun_right = false
		wallrun_switchR = false
		wallrun_switchL = false
		can_disable_wallrun = false
		#if angler_dir == 0:
			#direction_change = false
		print("no wall run")





func _on_jump_ball_body_entered(body):
	if body.is_in_group("enemy"):
		enemy_contact = true
		body.knockback = true
		body.health = body.health - 2
		#print("enemy bounce")





func _on_cayote_timer_timeout():
	can_cayote_jump = false


func _on_jumpbuffer_timer_timeout():
	jump_buffer = false

func _on_detector_area_entered(area):
	if area.get_parent().is_in_group("Vine"):
		vine_nearby = area.get_parent()

func _on_detector_area_exited(area):
	if area.get_parent().is_in_group("Vine"):
		vine_nearby = null

func _on_pass_through_rails_timeout():
	Player_collision.disabled = false

func _on_wallkick_timer_timeout():
	can_wall_kickL = false
	can_wall_kickR = false
	could_wall_kick = false
	#print("no wall kick")

func _on_wallkicklock_timer_timeout():
	wallkicking = false

func _on_dodgeslide_timer_timeout():
	do_dodgeslide = false
	dodgeslidecooldown_timer.start()

func _on_dodgeslidecooldown_timer_timeout():
	can_dodgeslide = true

func _on_slidejump_timer_timeout():
	slide_jump = false

func _on_charge_shot_timer_timeout():
	pass # Replace with function body.

func _on_knockback_timer_timeout():
	if knockedback == true:
		velocity.x = 0
	knockedback = false

func _on_invincebilityframes_timer_timeout() -> void:
	recovery_frames = false



func _on_direction_change_timer_timeout() -> void:
	direction_change = false


func _on_possibewalldive_timer_timeout() -> void:
	if not wallrunning_wallchecker.is_colliding() or floor_slope_disable == true:
		wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
		print("no_dive")
		can_walldive_right = false
		can_walldive_left = false
		can_walldive = false
		can_disable_waldive = false
		walldive_switchR = false
		walldive_switchL = false


func chosing_teleport_location(delta):
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
		teleporting = false
		mode = MovementMode.NORMAL
		#print("fuck me")
	velocity.y = 0
	dir = -1
		


func _on_walldive_start_downroll_buffer_timer_timeout() -> void:
	print("yes")
