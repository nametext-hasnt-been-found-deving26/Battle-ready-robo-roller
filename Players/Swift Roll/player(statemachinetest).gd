extends CharacterBody2D

enum MovementMode {
	PAUSED,
	NORMAL,
	UPSIDE_DOWN,
	HIT,
	DASH,
	VINE,
	RAIL_GRINDING,
	WATER,
	TELEPORTING,
	DIRECTION_CHANGE,
	WALL_CLING,WALL_CLIMB,
	WALL_SHOT,
}

var mode = MovementMode.NORMAL

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var Player_collision: CollisionShape2D = $CollisionShape2D

@onready var camera_2d: Camera2D = $Camera2D


@export_category("base settings")
@export var Walking_SPEED = 300.0
@export var Base_Skates_SPEED = 900.0
@export var JUMP_VELOCITY = -500.0
@export var full_snap_length: int = 150
var Player_velocity = Vector2.ZERO

@export var skates_normal_gravity_multiplier: float = 1.0
@export var nonskates_gravity_multipiler: float = 1.60
@export_group("topsy-turby options")
@export var needed_speed_celing_run : int
@export var maintain_ceiling_run_speed : int = 300




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
var dedrag: float

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
@export var shotdown_strength: int = 450

@export_group("shot speeds")
@export var up_shot_speed: Vector2
@export var forward_shot_speed: Vector2
@export var down_shot_speed: Vector2
var wall_cling = false

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
var up_angle : int
var ceiling_angle : int

var angler_dir = 0.0
var store_angler_dir = 0.0
var floor_slope_disable = false
var was_on_slope = false
var rolling = 0
@onready var fallingmomentum_timer = $Timers/fallingmomentumTimer
@onready var walldive_start_downroll_buffer_timer: Timer = $Timers/walldive_start_downroll_buffer_Timer
@onready var ledge_titer_handler: Node2D = $Ledge_titer_handler


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
@export_range(0.0, 1200.0)
var wallrun_assist: float = 525.0
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

var can_jump = true
var jump_buffer = false
var jumping = false
var jumping_off = false
var jump_bounce_multiplier: float

var slope_launched = false
var no_slope_launch: bool
var slope_launch_direction: Vector2
var can_hold_vine = false
var grabbing := false
var grabbed_vine: Node = null
@onready var vine = $"."
var vine_nearby: Node = null
var vine_velocity := Vector2.ZERO

var store_velocity = 0
var vine_swinging = false
var handle_rotation
@onready var grab_vine_position: Marker2D = $grab_vine_position


var boost_mode = 0
var can_boost_mode = false
var store_boost_mode_on_wall_cling = false
#var no_boost_mode = false
var running = false
var store_running_speed: float
var store_boost_mode = 0
var grounded : bool
@export_category("running settings")
@export_range(0.0, 1.0)
var run_buffer_duration: float
var run_buffer_timer: float

@export_category("animation settings")
@export var base_animation_frame_rate: float
var animation_to_play = "idle"

@export_category("trail effects settings")
@export_group("afterimages")
@export_range(0.0, 1.0)
var afterimages_buffer_time_duration: float = 0.1
var afterimages_buffer_timer: float
@export var afterimages : PackedScene
@onready var afterimage = $"."
@export var store_afterimages = 0
var advance_boost_mode = false
var active_afterimages: Array = []
@export var max_afterimages := 12

@export_group("dust_clouds")
@export_range(0.0, 1.0)
var dust_clouds_buffer_time_duration: float = 0.1
var dust_clouds_buffer_timer: float
@export var dust_clouds : PackedScene
@onready var dust_cloud = $"."
@onready var dust_cloud_setter: Node2D = $dust_cloud_setter
var eat_my_dust : bool = false

@export_category("misc visual effects settings")
@export_group("rotation")
@export_subgroup("player rotation")
@export var rotation_accel : float = 2
@export_subgroup("sprite rotation")
@export var rot_sprite_pos: Vector2
@export var rot_sprite_offset: float = -42.0
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
@export var water_input_accel: float = 6
var in_water = false
var water_velocity = 0
var water_accel = 0
var can_water_run = false

@export_category("conveyor settings")
@export var Conveyor_input_offset_duration: float = 10
var conveyor_input_offset : float 
var conveyor_area_dir = Vector2.ZERO
var conveyor_power = 0.0
var conveyor_velocity : Vector2

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
		MovementMode.PAUSED:
			_player_paused()
#region main movement states
		MovementMode.NORMAL:
			apply_main_movement(delta, direction)
			#applying_velocity(delta)

		MovementMode.DIRECTION_CHANGE:
			direction_changing()
			

		MovementMode.UPSIDE_DOWN:
			running_upside_down(direction, delta)

		

		MovementMode.DASH:
			pass

#region wall cling/shot system states

		MovementMode.WALL_CLING:
			_wall_cling(delta, direction)

		MovementMode.WALL_SHOT:
			_wall_shot(delta)

		MovementMode.WALL_CLIMB:
			_wall_climb(delta)

#endregion

#endregion

		MovementMode.HIT:
			apply_knockback(delta)
			

		MovementMode.VINE:
			apply_vine_pull(delta)


		MovementMode.RAIL_GRINDING:
			is_grinding()

		MovementMode.WATER:
			inside_water(delta, direction)

		MovementMode.TELEPORTING:
			chosing_teleport_location(delta)
		#scarf.anchor_offset = Vector2(15, -20
	#applying_velocity(delta, direction)
	if mode != MovementMode.PAUSED:
		_handle_skates_state()

	handle_camara_offset()

	_handle_rotation()

	_handle_squash_and_strech(delta)

	animated_sprite_2d.play(animation_to_play)

	if mode == MovementMode.WALL_SHOT:
		animated_sprite_2d.offset.y = 0.0
		animated_sprite_2d.position = Vector2.ZERO
		sprite_rotation()
	else:
		animated_sprite_2d.offset.y = rot_sprite_offset
		animated_sprite_2d.position = base_position
		animated_sprite_2d.rotation = 0

	if currentHP <= 0:
		die()
	health_bar()
	set_animation()

	if scarf:
		scarf.update_dash_color(can_dash)
		_handle_current_scarf_color()

	if grabbing and grabbed_vine:
	# Let the player influence the swing
		mode = MovementMode.VINE
  # ← apply the stored velocity on release
	if Input.is_action_pressed("jump") and vine_nearby:
		grabbing = true
		grabbed_vine = vine_nearby
		grabbed_vine.grab_handle()

#region store_y logic
	if velocity.y > 0 and not is_on_floor():
		if not floor_slope_disable and not ledge_titer_handler.half_colide and fallingmomentum_timer.is_stopped():
			store_y = velocity.y
			#print(store_y)
		elif ledge_titer_handler.half_colide :
			if can_walldive_left or can_walldive_right:
				store_y = velocity.y
			
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
#endregion

#region player size
	if can_walldive_right or can_walldive_left:
		Player_collision.shape.radius = 18.24
	elif fallingmomentum_timer.is_stopped():
		Player_collision.shape.radius = collision_normal_size.x
#endregion

	_get_ceiling_rotation()

	if knockedback:
		print("knocked back")
		mode = MovementMode.HIT
	if recovery_frames == true:
		invincibility_frames()

	if braking == true and not Input.is_action_pressed("jump"):
		if mode == MovementMode.UPSIDE_DOWN: print("ceiling braking 2")
		create_dust_cloud(delta)
		if skates_on == true:
			braking_sfx.play()
	else:
		eat_my_dust = true



func _player_paused():
	pass
	#move_and_slide()
	

func apply_main_movement(delta, direction):
	#if velocity!= Vector2.ZERO:
		#print(velocity.length())
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
	
	

	
	if abs(ceiling_angle) > 1 and abs(ceiling_angle)  < 90  and is_on_ceiling():
		if can_wallrun_left or can_wallrun_right or abs(velocity.x) >= needed_speed_celing_run or velocity.y <= -needed_speed_celing_run:
			mode = MovementMode.UPSIDE_DOWN
			print("topsy")

	if not can_walldive_right and not can_walldive_left:
		if direction > 0 :
			direction = 1
		if direction < 0 :
			direction = -1
	else:
		direction = 0
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
		#if not fallingmomentum_timer.is_stopped():
			#print("something else")
	if store_y > 0 and velocity.y >= 0:
		if angler_dir != 0 and floor_slope_disable or angle > 0.1:
			if skates_on:
				if ledge_titer_handler.half_colide and wallrunning_wallchecker.is_colliding() or angler_dir != 0:
					velocity.y += store_y * angle
				#if fallingmomentum_timer.is_stopped():
					rotation_degrees = (angle * (180 / 3.141592)) * angler_dir   
					#print(rotation)
			else:
				if ledge_titer_handler.half_colide and wallrunning_wallchecker.is_colliding() or angler_dir != 0:
					velocity.y += (store_y * angle) /2
			floor_snap_length = 350
			#print(velocity.y)

	if is_on_floor():
		
		if Input.is_action_pressed("jump") == false:
			can_jump = true
		#if store_y > 0:
			#velocity.y += store_y * angle
			
		if in_water == false and can_wallrun_left == false and can_wallrun_right == false:
			if do_dodgeslide == true :
				velocity.y += 150 * (angle * (180 / 3.141592))/4 
			if skates_on == true and abs(velocity.x) > Base_Skates_SPEED and velocity.x * angler_dir > 0 and angle > 0.01 and can_downroll == false:
				velocity.y = slope_launch_direction.y
				#print("works")
			elif abs(velocity.x) > Walking_SPEED and skates_on == false and angler_dir * velocity.x > 0 and running == true:
				velocity.y = abs(velocity.x) / 2
			elif can_downroll == false and can_walldive_left == false and can_walldive_right == false and direction_change == false:
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

		#if not wallshotTimer.is_stopped():
			#wallshotTimer.stop()


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
		if abs(velocity.x ) > Walking_SPEED + conveyor_power and running == false and grounded == true:
			store_running_speed = abs(velocity.x ) 
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
				dodash = false
				velocity.y = abs(velocity.x) * -1
				can_wallrun_right = true
				
				#print("uprolling")
				possiblewallrun_timer.start()
			elif angler_dir == 1 and velocity.x <= 0 and (angle * (180 / 3.141592)) >= 75 and slope_launched == false and not disable_slope_launch() and can_uproll == false and can_downroll == false:
				#print("uprolling")
				dodash = false
				velocity.y = abs(velocity.x) * -1
				can_wallrun_left = true
				possiblewallrun_timer.start()
				
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
			if skates_on == false and velocity.y > -40 and noskates_falling_speed == false and wall_shotLForward == false and wall_shotRForward == false and conveyor_power == 0:
				velocity.y += (gravity * delta) * nonskates_gravity_multipiler
		#floor_snap_length = 1
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
	if  grindin == false and dodash == false:
		store_velocity = velocity
	# Handle jump.
	if Input.is_action_just_released("jump") and velocity.y < 0 :
		if  not abs(rotation_degrees) == 90 and direction_change == false and not can_wallrun_left and not can_wallrun_right:
			velocity.y = JUMP_VELOCITY / 6
			can_jump = true
			#print(velocity.y)
	
	if jump_buffer == true and skates_on == false and can_jump == true:
		if is_on_floor() and do_dodgeslide == false or can_cayote_jump == true and do_dodgeslide == false:
			dodash = false
			velocity.x += (wallrunning_wallchecker.get_collision_normal() * -((JUMP_VELOCITY - 100) * jump_bounce_multiplier)).x
			velocity.y = (JUMP_VELOCITY - 100) * jump_bounce_multiplier
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
			velocity = slope_launch_direction
			if is_on_floor():
				
				velocity += wallrunning_wallchecker.get_collision_normal() * -JUMP_VELOCITY * jump_bounce_multiplier
			else:
				velocity.y += JUMP_VELOCITY * jump_bounce_multiplier
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



	if skates_on == false and grindin == false and wallkicking == false and knockedback == false:
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
					velocity.x = move_toward(velocity.x, Walking_SPEED * direction, walking_accel )
					store_boost_mode = 0
					if running == false:
						store_running_speed = 0
				if boost_mode != 0 and is_on_floor() :
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
	if skates_on == true and grindin == false and wallkicking == false:
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
						#print("shit")
				if angler_dir != 0 and is_on_floor():
					velocity.x = move_toward(velocity.x + (angle * angler_dir * 25) , 0  , accel)
					#velocity.y += (gravity * delta) * (angle * (180 / 3.141592))

					#print (rolling)
		else:
			tackle = false
			#print (velocity.x)
			#print(angle)
		#main control line for skates mode -------------------------------------------------------------
			velocity.x = move_toward(velocity.x + (angle * angler_dir * 20), skating_SPEED  * direction, accel) if is_on_floor() else move_toward(velocity.x , Base_Skates_SPEED  * direction, accel)
		#manage exeed mach
		if velocity.x * direction >= Base_Skates_SPEED + abs(conveyor_power) and is_on_floor() and abs(velocity.x) > skating_SPEED:
			skating_SPEED = abs(velocity.x) if velocity.x * direction >= Base_Skates_SPEED + abs(conveyor_power) and is_on_floor() and abs(velocity.x) > skating_SPEED else move_toward(skating_SPEED, Base_Skates_SPEED, accel)
		#if abs(skating_SPEED) > Base_Skates_SPEED and is_on_floor(): print(skating_SPEED)
			

		
		#manage exeed mach
		
		#if abs(velocity.x) > Base_Skates_SPEED:
			#print(velocity.x)
		if dodash == true:
			create_dash_effect(delta)
		var downroll_angle: Vector2 
		if is_on_floor() :
			if downroll_angle == Vector2.ZERO:
				downroll_angle  =  ledge_titer_handler.ledge_angle
		else:
			downroll_angle  = Vector2.ZERO
		var tangent : Vector2 = Vector2(-downroll_angle.y, downroll_angle.x).normalized()
		var downrol_multiplier: bool
		#if is_on_floor():
			
		
		
		if can_downroll == true :
			if not is_on_floor() and not floor_slope_disable and angle == 0:
				if wallrunning_wallchecker.is_colliding() or ledge_titer_handler.half_colide:
					downrol_multiplier = true
					#print(tangent.angle())
				else:
					downrol_multiplier = false 
			
			#print("divider " , (downrol_multiplier  ) )
			#if floor_slope_disable:
				#can_walldive_left = false
				#can_walldive_right = false

			if tangent.angle() != 0 and is_on_floor()  and  abs(tangent.angle()) < 180 and ledge_titer_handler.full_colide: 
				#print("slope_down_dive ", downrol_multiplier))

	

				if tackle:
					velocity.x += ((store_y  / 1.2)   * (tangent.angle()* (180.0 / 3.141592)  /90) ) 
				else:
					velocity.x += ((store_y / 1.8)  * (tangent.angle()* (180.0 / 3.141592) /90) ) 
					
				#if not abs(tangent.angle()* (180.0 / 3.141592)) > 88:
				velocity.y += store_y 
				#floor_snap_length = 1000
				
				#print("vel downroll ",velocity, "store y ", store_y)
				
				#print(tangent.angle()* (180.0 / 3.141592))
				#velocity.y += (gravity * delta) * (angle * (180 / 3.141592)) 
				downrolling = false
				#can_downroll = false
				if fallingmomentum_timer.is_stopped():
					fallingmomentum_timer.start()
					#print("engage downroll ", velocity.x)

					
				
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
		if shotdown == true and is_on_floor():
			skating_SPEED = Base_Skates_SPEED
			velocity.x +=  shotdown_strength * dashDirection
			print("shotdown", skating_SPEED)
			shotdown = false
		if knockedback == false:
			store_x = velocity.x
	
	# Let knockback velocity persist, but still allow gravity
		
		#print(from_dir)

		
		 # exit early so no player input overrides knockback
	if abs(velocity.x) > Base_Skates_SPEED and velocity.y < 300 and skates_on == true:
		can_water_run = true
	else:
		can_water_run = false
				
		#(direction)
		#print(accel)




	
	if Input.is_action_pressed("down") and Input.is_action_just_pressed("dash") and can_dodgeslide == true and is_on_floor() and skates_on == false:
		velocity.y += 500 * (angle * (180 / 3.141592))/4 
		dashDirection = 1 if dir == 1 else -1
		can_jump = false
		#print ("yes")
		do_dodgeslide = true
		dodgeslide_timer.start()
		can_dodgeslide = false
		
	elif Input.is_action_just_pressed("dash") and can_dash != 0 :
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
			#velocity.y += 150 * (angle * (180 / 3.141592))/4 
			
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
		dir = dashDirection
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

	if is_on_wall_only() and dodash == true and not downdash : if wallkick_lock_l.is_colliding or wallkick_lock_r.is_colliding :  mode = MovementMode.WALL_CLING; dodash = false

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
			
			#print(velocity.x)
			dir = dashDirection 
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

	




	#if can_wallrun_right == true or can_walldive_right == true:
		
	if wall_cling == true and is_on_wall() and not is_on_floor() or wallkicking == true:
		pass
	else:
		handle_wallkick_lock_dir()
	if not is_on_wall() and not wallkick_lock_l.is_colliding and not wallkick_lock_r.is_colliding:
		wallkick_velocity = abs(velocity.x)
		#print("wallkick_velocity ",wallkick_velocity)

			

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
				if wallkick_lock_l.is_colliding == true:
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
			velocity.x = (wallkick_velocity+300)  * wallkick_dir
			print("wallkick", velocity.x)
			if velocity.y < 0:
				velocity.y += JUMP_VELOCITY/4 - abs(wallkick_velocity)/2
			else:
				velocity.y = JUMP_VELOCITY/4 - abs(wallkick_velocity)/2
			dir *= -1
			wallkicking = false
		else:
			print("walkick_noskates")
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
				#print("yes")
			
			

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
			

			



		#print(switch_speed)
	if direction_change and walldive_start_downroll_buffer_timer.is_stopped():
		walldive_start_downroll_buffer_timer.start()
		can_walldive = false
	if direction_change == true :
		if not possiblewallrun_timer.is_stopped():
			possiblewallrun_timer.stop()
			possiblewallrun_timer.timeout.emit()
			rotation_degrees = 0
		mode = MovementMode.DIRECTION_CHANGE

		
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
	
	#if disable_slope_launch():
		#slope_launched = true
			
		

#wall runs
	if can_wallrun_right == true:
		can_walldive = false
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
		#print("active")
		can_walldive = false
		jump_ball = false
		rotation_degrees = 90
		#switch_speed = abs(velocity.y)
		if wallrunning_wallchecker.is_colliding() and not is_on_ceiling():
			#if is_on_wall():
				#velocity.x = 10
			#else:
				#velocity.x = move_toward(velocity.x, 0 , walking_accel)
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
			#else:
				#velocity.x = move_toward(velocity.x, 0 , walking_accel)
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
			#if not is_on_floor():
				#velocity.x = -100
			#else:
				#velocity.x = move_toward(velocity.x, 0 , 1)
		if Input.is_action_just_pressed("jump"):
			jumping_off = true
			velocity.x = (JUMP_VELOCITY*-2)
			walldive_switchL = true
			can_disable_waldive = false
			jump_ball = true
			can_walldive_right = false
			camera_2d.offset.y = 0

	if can_walldive_left == true:
		#print("diveleft")
		rotation_degrees = -90
		#f angler_dir == -1:
			#irection_change = true
		if wallrunning_wallchecker.is_colliding():
			if is_on_wall():
				velocity.x = -10
		#	else:
				#velocity.x = move_toward(velocity.x, 0 , walking_accel)
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
			#if not is_on_floor():
				#velocity.x = 100
			#else:
				#velocity.x = move_toward(velocity.x, 0 , 1)
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
	if conveyor_power != 0:
		conveyor_push(delta, direction)
	

	move_and_slide()





	
	if is_on_floor() :
		set_launch_direction()
	


	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		if skates_on == true  and was_on_slope == true and in_water == false and grind_off == false and slope_launched == false and no_slope_launch == false and not disable_slope_launch() and fallingmomentum_timer.is_stopped():
			#if velocity.x > 2000  or velocity.x < -2000 :
			
			velocity = slope_launch_direction
			#if can_downroll:
				#velocity.y /= 2
			#print("slope launch", velocity.y)
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

		#print("dusting")
		

		
	


var stay_like_that = false
func _handle_rotation():
	if mode == MovementMode.VINE and handle_rotation:
		rotation_degrees = handle_rotation
	elif do_dodgeslide == true:
			if angler_dir != 0:
				if velocity.x * angler_dir < 0:
					if angler_dir == -1:
						rotation_degrees = (90 +(angle * (180 / 3.141592))) * -1
						#print("upwards")
					else:
						rotation_degrees = (90 +(angle * (180 / 3.141592))) 
				else:
					rotation_degrees = (90 -(angle * (180 / 3.141592)))* angler_dir*-1
					#print("downwards")
			else:
				rotation_degrees = -90 * dashDirection 
	elif is_on_floor():
		if skates_on == true or grindin == true and mode == MovementMode.NORMAL:
			rotation_degrees = (angle * (180 / 3.141592)) * angler_dir  
			#print(get_floor_normal())
			if Input.is_action_just_pressed("jump"):
				rotation_degrees = 0
				#print("ball jumpin")
		else:
			
					#print("no angle")
			rotation_degrees = 0
	else:
		if do_dodgeslide == false:
			#if floor_slope_disable == false:
			if mode == MovementMode.UPSIDE_DOWN:
				
				rotation_degrees = ceiling_angle + 180
				#print(rotation_degrees)
			else:
				rotation_degrees = move_toward(rotation_degrees, 0 , 2)
			if dodash == true:
				rotation_degrees = 0


var avg_normal = Vector2.ZERO

var store_vel_for_backwards: Vector2
func _get_ceiling_rotation():
	if not is_on_ceiling():
		store_vel_for_backwards = velocity
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		avg_normal += collision.get_normal()
	# Check if it's a ceiling (normal pointing downward)
		if collision.get_normal().y > 0.7:
			ceiling_angle = normal.angle() * (180 / 3.141592) - 90
			#print("Ceiling angle: ", ceiling_angle )
		elif mode != MovementMode.UPSIDE_DOWN:
			ceiling_angle = 0
			
		if avg_normal != Vector2.ZERO:
			avg_normal = avg_normal.normalized()
			
			var angle = avg_normal.angle()
			#if not is_on_floor():
				#print("Stable angle:", angle)
		
			

func _handle_accel():
	if not_moving_x == true:
		if abs(velocity.x) > Base_Skates_SPEED and not is_on_floor():
			accel = no_input_accel_with_air_drag
		else:
			accel = no_input_accel
	elif is_on_floor():
		if angler_dir == 0:
			if abs(velocity.x) > Base_Skates_SPEED  + conveyor_power  and dashDirection * velocity.x > 0 :
				accel = ground_forward_past_top_speed_accel
				#print("top normal")
			else: 
				accel = normal_ground_accel - abs(velocity.x / 250)
				#print(velocity.x)
		else:
			if angler_dir == dir:
				accel = down_accel
			elif angler_dir != dir:
				if abs(velocity.x) > Base_Skates_SPEED + abs(conveyor_power):
					accel = Up_past_mach_accel
					#print("sonic shit")
				else:
					accel = up_accel
		if tackle == true:
			accel = tackle_accel
	else:
		if velocity.x >= Base_Skates_SPEED and dashDirection  == 1 or velocity.x <= -Base_Skates_SPEED and  dashDirection == -1 :
			accel = air_drag_accel + Air_normal_accel
			#print("mach air drag")
		else:
			accel = Air_normal_accel - abs(velocity.x / 320)
			#print("normal air drag")

func set_launch_direction():
	var pulled_vel = Vector2(velocity.x, 0.0)
	var tangent = Vector2(-wallrunning_wallchecker.get_collision_normal().y, wallrunning_wallchecker.get_collision_normal().x).normalized()
	var full_slope_dir = pulled_vel.rotated(tangent.angle())
	slope_launch_direction = full_slope_dir
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
		
		return
	elif not mode == MovementMode.VINE:
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
	elif mode == MovementMode.WALL_CLING:
		if Input.is_action_pressed("up")  or Input.is_action_pressed("up") and Input.is_action_pressed("right") and animated_sprite_2d.flip_h == false or Input.is_action_pressed("up") and Input.is_action_pressed("left") and animated_sprite_2d.flip_h == true:
			animation_to_play = "wall_cling_up"
			
		elif Input.is_action_pressed("down")  or Input.is_action_pressed("down") and Input.is_action_pressed("right") and animated_sprite_2d.flip_h == false or Input.is_action_pressed("down") and Input.is_action_pressed("left") and animated_sprite_2d.flip_h == true:
			animation_to_play = "wall_cling_down"
		elif Input.is_action_pressed("left") and dashDirection == -1 or dashDirection == 1  and Input.is_action_pressed("right") :
			animation_to_play = "wall_cling_forward"
		else: 
			animation_to_play = "wall_cling_idle"
		return
		#animated_sprite_2d.flip_h = true  if dashDirection == 1 else false
	if mode == MovementMode.WALL_SHOT:
		animation_to_play = "wall_shot"
		return
	if (is_on_floor() and dodash == false and not_moving_x == false and do_dodgeslide == false 
	or can_wallrun_left == true 
	or can_wallrun_right == true 
	or can_walldive_left == true 
	or can_walldive_right == true
	or mode == MovementMode.UPSIDE_DOWN
	):
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
		#print("yeah")
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
		

func _handle_current_lighting(is_dark: bool):
	var player_material = animated_sprite_2d.material as ShaderMaterial
	player_material.set_shader_parameter("in_dark_place", is_dark)

var inner_color
var edge_color
func _handle_current_scarf_color():
	var player_material = animated_sprite_2d.material as ShaderMaterial
	inner_color = scarf.get_current_inner_color()
	edge_color = scarf.get_current_edge_color()
	player_material.set_shader_parameter("replacement_color", edge_color)
	player_material.set_shader_parameter("replacement_color2", inner_color)



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


func direction_changing():
	#move_and_slide()
	can_wallrun_left = false
	can_wallrun_right = false
	rotation_degrees = 0
	global_position = switch_starting_location
	velocity = velocity.rotated(deg_to_rad(90 * angler_dir * -1))
	velocity.y = abs(velocity.x)/-2
		
		
		
	#print(velocity.x)
		#if global_position == switch_starting_location:
	
	direction_change = false
	
	mode = MovementMode.NORMAL
	move_and_slide()
	rotation_degrees = 0

var starter = false
var init_angle_dir: int
var rotated_direction: Vector2
var pre_angle : int
var player_vel : float
var startin_vel : Vector2
#@onready var wall_checker_buffer: Timer = $Timers/on_wall_timers/upside_down_timers/wall_checker_buffer

func running_upside_down(direction, delta):
	#print("rotation", rotation_degrees)
	#if up_angle == 0:
		#print(ceiling_angle)
	_handle_player_upsidedown_velocity(direction,delta)
	if can_wallrun_left or can_wallrun_right:
		#print("calling stop")
		possiblewallrun_timer.stop() 
		possiblewallrun_timer.timeout.emit()
	

	if (not skates_on or not wallrunning_wallchecker.is_colliding() 
	or abs(player_vel) < maintain_ceiling_run_speed 
	or is_on_wall()
	):
		#if  not wallrunning_wallchecker.is_colliding(): print("no cheker ", rotation_degrees )
		#if abs(player_vel) < maintain_ceiling_run_speed: print("too low velocity", player_vel)
		#if is_on_wall(): print("angle", ceiling_angle)
		init_angle_dir = 0
		up_angle = 0
		pre_angle = 0
		starter = false
		if is_on_wall() and abs(ceiling_angle) > 25:
			#print("walled")
			if player_vel < 0:
				can_walldive_left = true
			elif player_vel > 0:
				can_walldive_right = true
		#print("starting vel",startin_vel, velocity)
		#print ("wont")

		mode = MovementMode.NORMAL
		return
	
	if abs( ceiling_angle - up_angle) > 1 :
		#print( "dif " ,abs(up_angle - ceiling_angle ))
		_handle_topsy_turby_angle_change(direction)
	
	velocity =  player_vel * rotated_direction
	
	if not _handle_topsy_turby_angle_change(direction) and is_on_ceiling():
		startin_vel = velocity
	if Input.is_action_just_pressed("jump"):
		velocity += wallrunning_wallchecker.get_collision_normal() * -JUMP_VELOCITY 
		mode = MovementMode.NORMAL
		init_angle_dir = 0
		up_angle = 0
		pre_angle = 0
		could_wall_kick = false

		#print ("wont")
		#print(velocity)
		jump_ball = true
		return
	if conveyor_power != 0:
		conveyor_push(delta, direction)
	move_and_slide()

#region angle changes funcs
func _handle_topsy_turby_angle_change(direction):
	
	if init_angle_dir == 1 and ceiling_angle > up_angle:
		return
	if init_angle_dir == -1 and ceiling_angle < up_angle:
		return
	#print("change")
	#print("Ceiling angle: ", ceiling_angle )
	velocity = velocity.rotated(deg_to_rad(ceiling_angle - up_angle))
	var tangent = Vector2(-wallrunning_wallchecker.get_collision_normal().y, wallrunning_wallchecker.get_collision_normal().x).normalized()
	rotated_direction =  tangent 
	
	_handle_pre_angle()
	up_angle = ceiling_angle
	#print(velocity)
	#print( "up angle " ,up_angle)

func _handle_pre_angle():
	if init_angle_dir != 0:
		return
	if ceiling_angle > 0:
		init_angle_dir = 1
	else:
		init_angle_dir = -1
	return


func _handle_player_upsidedown_velocity(direction,delta):
	if starter == false  and not ceiling_angle == 0:
		#print ("speed length ",store_vel_for_backwards.length(), "angle", abs(ceiling_angle)/ ceiling_angle )
		if store_vel_for_backwards.y < abs(store_vel_for_backwards.x)* -1 or can_wallrun_left or can_wallrun_right:
			player_vel =  store_vel_for_backwards.length() * (abs(ceiling_angle)/ ceiling_angle)
			#print(player_vel, " player vel")
			starter = true
			print("upies")
		elif store_vel_for_backwards.y > abs(store_vel_for_backwards.x)* -1 and ceiling_angle != 0 and store_vel_for_backwards.x != 0 and store_vel_for_backwards.y != 0:
			player_vel =  store_vel_for_backwards.length() * (abs(store_vel_for_backwards.x)/store_vel_for_backwards.x )* -1
			starter = true
			print("sidies")
	if Input.is_action_pressed("down"):
		tackle = true
		imnContact = true
		animated_sprite_2d.flip_h = true if player_vel < 0 else false
	if Input.is_action_just_released("down"):
		tackle = false
		imnContact = false
	if tackle == true and not direction:
		player_vel  = move_toward(player_vel + deg_to_rad(ceiling_angle* -2 )  , skating_SPEED  * direction, tackle_accel)
	else:
		if direction * player_vel < 0 :
			player_vel = move_toward(player_vel, skating_SPEED  * direction, (ground_brake_accel * ground_brake_multiplier )* delta * ground_brake_over_time_multiplier)
			if velocity.length() > 500:
				braking = true
				print("ceiling braking")
		if abs(player_vel) < Base_Skates_SPEED:
			player_vel  = move_toward(player_vel + deg_to_rad(ceiling_angle * -1)  , skating_SPEED  * direction * init_angle_dir, (normal_ground_accel/2)* (2 * direction))
		elif direction * player_vel > 0:
			player_vel  = move_toward(player_vel + deg_to_rad(ceiling_angle * -1)  , skating_SPEED  * direction, ground_forward_past_top_speed_accel)
		#print(deg_to_rad(ceiling_angle * -1))
	
	if abs(player_vel ) > 2000:
		create_dash_effect(delta)
	


		
#endregion

#region Wall Cling/Shot funcs

func _wall_climb(delta):
	velocity.y += gravity * delta
	

	
		#print("normal")
	if Input.is_action_just_pressed("jump"):
		mode = MovementMode.WALL_CLING

	if not wallkick_lock_l.is_colliding and  not wallkick_lock_r.is_colliding:
		velocity.x = move_toward(velocity.x, Walking_SPEED * (dashDirection * -1), walking_accel/2)
		
		#print(velocity.x)
		if abs(velocity.x) >= Walking_SPEED:
			print(dir)
			mode = MovementMode.NORMAL
			
			#dir = (abs(velocity.x) / velocity.x)
			
		else: dir = dashDirection * -1
		move_and_slide()
		return

	velocity.x = -dashDirection
	if velocity.y >= 0 :
		mode = MovementMode.WALL_CLING
	
	if Input.is_action_just_released("dash"):
		velocity.y /= 6
	
	
	move_and_slide()

var wall_cling_dir: int
func _wall_cling(delta, direction):
	
	
	velocity.x = 0
	if wallkick_lock_r.is_colliding == true or wallkick_lock_l.is_colliding == true:
		if wallkick_lock_r.is_colliding == true :
			wall_cling_dir = 1
		elif wallkick_lock_l.is_colliding == true:
			wall_cling_dir = -1
		else:
			mode = MovementMode.NORMAL; print("no wallcling")
			print("something")
		#velocity.x = wall_cling_dir
		

	if conveyor_power == 0:
		velocity.y = move_toward(velocity.y, 0, wall_cling_drag)
		if not is_on_wall_only(): mode = MovementMode.NORMAL; print("exit wallcling")
	elif is_on_wall():
		conveyor_push(delta, direction)

		#print("dragging")
	if abs(wallkick_velocity) > 0:
		wallkick_velocity = move_toward(wallkick_velocity, 0,  5)
	boost_mode = 0
	if boost_mode != 0:
		store_boost_mode = velocity.x
	dashDirection = -wall_cling_dir
	
	if can_dash < 1:
		can_dash += 1

	dir = dashDirection
	if Input.is_action_just_pressed("dash"):
		if Input.is_action_pressed("up"):
			velocity.y = JUMP_VELOCITY
			mode = MovementMode.WALL_CLIMB
			return
		else:
			print("exit wall_cling")
			mode = MovementMode.NORMAL
			return

		
	#print(dashDirection)

	if Input.is_action_pressed("jump") and  Input.is_action_pressed("up") or Input.is_action_pressed("jump") and  Input.is_action_pressed("up") and  Input.is_action_pressed("left"):
		print("LUP")
		if wallkick_velocity > up_shot_speed.length():
			_set_wall_shot(up_shot_speed, wallkick_velocity - up_shot_speed.length() )
			print("yesin")
		else:
			_set_wall_shot(up_shot_speed, 0)

				#
	elif Input.is_action_pressed("jump") and  Input.is_action_pressed("down") or Input.is_action_pressed("jump") and  Input.is_action_pressed("down") and  Input.is_action_pressed("left"):
		if wallkick_velocity > down_shot_speed.length():
			_set_wall_shot(down_shot_speed, wallkick_velocity - down_shot_speed.length() )
			print("yesin")
		else:
			_set_wall_shot(down_shot_speed, 0)

				#print("Ldown")
	elif Input.is_action_pressed("jump") :
		if wallkick_velocity > forward_shot_speed.length():
			_set_wall_shot(forward_shot_speed, wallkick_velocity - forward_shot_speed.length() )
		else:
			_set_wall_shot(forward_shot_speed, 0)

				#print("Lforward")


		
	
	move_and_slide()

func _set_wall_shot(setup_speed: Vector2, added_vel: float):

	velocity += setup_speed
	if setup_speed.y < 0:
		velocity += Vector2(added_vel, -added_vel)
	else:
		velocity += Vector2(added_vel, added_vel)
	velocity.x *= dashDirection

	#print(wallshotTimer.time_left)
	#wallcling_cooldown.start()
	jump_buffer = false

	mode = MovementMode.WALL_SHOT

var dont_reactivate: bool
func _wall_shot(delta):
	if wallshotTimer.is_stopped() and not dont_reactivate:
		wallshotTimer.start()
		dont_reactivate = true

	wall_cling = false
	handle_wallkick_lock_dir()
	velocity.y += gravity * delta
	store_x = velocity.x
	if (wallshotTimer.is_stopped() and not wallkick_lock_l.is_colliding and not wallkick_lock_r.is_colliding
	or wallrunning_wallchecker.is_colliding()
	or is_on_wall_only()
	):
		dont_reactivate = false
		wallshotTimer.stop()
		if is_on_wall(): mode = MovementMode.WALL_CLING ; return
		if wallshotTimer.is_stopped(): print("exited ", wallshotTimer.time_left)
		if wallrunning_wallchecker.is_colliding() and velocity.y >= 1000: shotdown = true
		
		mode = MovementMode.NORMAL
		
		#print(velocity)
	move_and_slide()
	

#endregion

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
	if active_afterimages.size() >= max_afterimages:
		var oldest = active_afterimages.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
			#print("too many")
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
		active_afterimages.append(ghost)
		ghost.play(animation_to_play)
		ghost.set_frame(animated_sprite_2d.get_frame()-1)
		ghost.rotation_degrees = rotation_degrees
		afterimages_buffer_timer = afterimages_buffer_time_duration - afterimage_velocity_buffer_multiplier





var cloud_velocity_size_multiplier: float
func create_dust_cloud(delta):
	if mode == MovementMode.UPSIDE_DOWN:
		cloud_velocity_size_multiplier = (velocity.length()/ 1000)
		#print(cloud_velocity_size_multiplier  )
	elif can_walldive_left == true or can_walldive_right == true:
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
		if mode == MovementMode.UPSIDE_DOWN:print("yesir")
		cloud.set_property(dust_cloud_setter.global_position,  Vector2(abs(cloud_velocity_size_multiplier) - delta  * 2 , abs(cloud_velocity_size_multiplier) - delta * 2 ))
		get_tree().current_scene.add_child(cloud)
		if animated_sprite_2d.flip_h == true:
			cloud.flip_h = false
		else:
			cloud.flip_h = true
		if eat_my_dust == true:
			cloud.play("spike")
			eat_my_dust = false
		else:
			cloud.play("default")
		cloud.rotation_degrees = rotation_degrees
		dust_clouds_buffer_timer = dust_clouds_buffer_time_duration #+ cloud_velocity_timer_multiplier
		#print("working")



var limit_brought_back : Vector2
var floor_bounce_back: bool = false
func apply_vine_pull(delta):
	floor_snap_length = 0
	var input_vector = Vector2(
		 Input.get_action_strength("left") - Input.get_action_strength("right"),
		0
			)
	grabbed_vine.apply_spin_input(input_vector, delta, grab_vine_position.global_position)
	var input_axis = -input_vector.x
	var handle_pos = grabbed_vine.get_handle_global_position()
	handle_rotation = grabbed_vine.get_handle_rotation()
	var steer_strength = grabbed_vine.steer_strength
	var orbit_damping = grabbed_vine.orbit_damping
	var spring_vector = handle_pos - global_position 
	var dir_to_center = spring_vector.normalized()
	var tangent = Vector2(-dir_to_center.y, dir_to_center.x)
	var radial_vel = dir_to_center * velocity.dot(dir_to_center)
	var tangential_vel = tangent * velocity.dot(tangent)
	var min_speed = grabbed_vine.min_speed
	var speed = velocity.length()
	var speed_dif = 1
	
	#Player_collision.position.y = dust_cloud_setter.position.y + grabbed_vine.get_handle_offset().y * 2
	#animated_sprite_2d.position.y = dust_cloud_setter.position.y + 18.235 + grabbed_vine.get_handle_offset().y * 2

	 # tweak this

	
	var original_speed = velocity.length()
	if not input_vector:
		tangential_vel *= orbit_damping
		velocity = radial_vel + tangential_vel
	else:
		var stretch_ratio = spring_vector.length() / grabbed_vine.max_stretch
		var control_strength = clamp(stretch_ratio, 0.2, 1.5)
		velocity += tangent * input_axis * 500 * control_strength * delta
		velocity = velocity.rotated(input_axis * steer_strength * delta)

	if velocity.length() > 0:
		velocity = velocity.normalized() * original_speed
	#var direction = Input.get_axis("left", "right")
	var spring_strength = grabbed_vine.spring_strength
  # tweak this
	
	if vine_swinging == false:
		velocity += (spring_vector * spring_strength * delta) + store_velocity/70
		#velocity -= velocity * damping * delta
	else:
		if spring_vector.length() >= grabbed_vine.max_stretch:
			limit_brought_back = spring_vector.normalized() *  (spring_vector.length() - grabbed_vine.max_stretch )
			#print(abs(spring_vector.x) + abs(spring_vector.y))
		else:
			limit_brought_back = Vector2.ZERO
			#print(speed)
			if speed < min_speed:
				speed_dif = min_speed - speed
				var recovery_strength = 1.0 - (speed / min_speed)  # 0 → 1
				if velocity.y  >= 0:
					velocity.y += gravity * delta * (recovery_strength) + (recovery_strength * speed_dif)
				velocity.x = move_toward(velocity.x, 0, speed_dif)
				#print("speed dif ",speed_dif)
				
				
			else:
				speed_dif = 1
		velocity += ((spring_vector + limit_brought_back ) * spring_strength * delta) + store_velocity/140
		
		
			


	vine_swinging = true
	vine_velocity = velocity  # ← store the current spring velocity
	
	if Input.is_action_just_released("jump"):
		#animated_sprite_2d.position.y = 18.235
		grabbed_vine.release_handle()
		grabbing = false
		grabbed_vine = null
		velocity = vine_velocity * 1.5  # ← apply the stored velocity on release
		vine_swinging = false
		if can_dash < 1:
			can_dash = 1
		mode = MovementMode.NORMAL
	move_and_slide()


var splash = false
var first_splash = false
var bounce = false
func inside_water(delta, direction):
	can_walldive_left = false
	can_walldive_right = false
	can_water_run = false
	wallkick_lock_r.enabled = true
	wallkick_lock_l.enabled = true
	if is_on_floor() :
		if angler_dir == 0:
			velocity.y = JUMP_VELOCITY /2
		first_splash = false
		mode = MovementMode.NORMAL
	if splash == false and in_water:
		print("starting velocity ", velocity.y)
		velocity.x = velocity.x / 1.33
		if velocity.y < 0:
			if not first_splash:
				velocity.y = velocity.y * 0.75
		else:
			if velocity.y <= 300:
				velocity.y = 300
				print("corrective splash")
			else:
				if not first_splash:
					velocity.y = velocity.y * 0.75
			
		print(velocity.y)
		splash = true
		first_splash = true
	else:
		if in_water == true:
			if bounce == false:
				if abs(velocity.x) > in_water_SPEED:
					velocity.x = move_toward(velocity.x, 0, water_drag)
				if wind_power != 0:
					velocity.x =  move_toward(velocity.x, in_water_SPEED * direction, water_input_accel / wind_power)
				else:
					velocity.x =  move_toward(velocity.x, in_water_SPEED * direction, water_input_accel )
			if boost_mode > 0:
				boost_mode = move_toward(boost_mode, 0, boost_mode_water_drag)
			#print(boost_mode)
			#if velocity.y > 0:
				#velocity.y -=  delta  * abs(velocity.y) / water_pull

			velocity.y -= delta * water_pull
			#print(velocity.y)
			velocity.y -= water_accel /2.0
			water_accel = water_accel + 0.05
		else:
			splash = false
			water_accel = 0
			if skates_on == false:
				velocity.x =  move_toward(velocity.x, Walking_SPEED * direction, walking_accel/2)
			else:
				velocity.x =  move_toward(velocity.x, Base_Skates_SPEED * direction, Air_normal_accel)
			velocity.y += gravity * delta
	wind_push(delta)

	if conveyor_power != 0 and not bounce:
		conveyor_push(delta , direction)
		bounce = true
	
	move_and_slide()
	if is_on_wall():
		if wallkick_lock_r.is_colliding == true:
			velocity.x = JUMP_VELOCITY * 1
			bounce = true
			#print(velocity.x)
		elif wallkick_lock_l.is_colliding == true:
			velocity.x = JUMP_VELOCITY  * -1
			bounce = true
			#print(velocity.x)
	if wallkick_lock_r.is_colliding == false and wallkick_lock_l.is_colliding == false:
		bounce = false


var wind_area_dir = Vector2.ZERO
var wind_power = 0.0
func wind_push(delta):
	if wind_area_dir != Vector2.ZERO:
		velocity += wind_area_dir * wind_power * delta
		#print(velocity)

var main_velocity : Vector2
func conveyor_push(delta, direction):
	if conveyor_area_dir != Vector2.ZERO:
		if mode == MovementMode.WATER:
			velocity = conveyor_power * conveyor_area_dir
			print(velocity)
			return 
		#print("yes")
		
		if conveyor_input_offset <= 0:
			if skates_on and abs(conveyor_area_dir.x) > abs(conveyor_area_dir.y):
				if not_moving_x: 
					velocity.x = move_toward(velocity.x + (angle * angler_dir * 15),(conveyor_power * conveyor_area_dir.x ), accel * 100 )
				elif abs(velocity.x) <= Base_Skates_SPEED + abs(conveyor_power):
					velocity = (conveyor_power * conveyor_area_dir ) + velocity
				#print(velocity, conveyor_area_dir)
				
			#if not_moving_x and abs(velocity.x) > conveyor_power:
				#velocity = (conveyor_power * conveyor_area_dir )
			#main_velocity -= (conveyor_power * conveyor_area_dir )
			
			conveyor_input_offset = Conveyor_input_offset_duration
			
		if not skates_on:
			if jump_buffer:
				boost_mode = abs(velocity.x)
			if is_on_floor():
				
				if not grounded and not jump_buffer:
					store_running_speed = 0
					boost_mode = 0
					if not jump_buffer:
						velocity.x /= 1.5
			
			if abs(conveyor_area_dir.x) < abs(conveyor_area_dir.y):
				if wall_cling == false:
					velocity = (conveyor_power * conveyor_area_dir ) / 100 + velocity
				else:
					velocity = (conveyor_power * conveyor_area_dir ) / 25 + velocity
			else:
				velocity = (conveyor_power * conveyor_area_dir ) + velocity
			
				
				
		if skates_on == true and (conveyor_area_dir.x) < abs(conveyor_area_dir.y) :
			if wall_cling == false:
				velocity = (conveyor_power * conveyor_area_dir ) / 100 + velocity
			else:
				velocity = (conveyor_power * conveyor_area_dir ) / 25 + velocity
			
		if conveyor_input_offset >= 0:
			conveyor_input_offset -= delta
			
		#print(conveyor_input_offset)
	if conveyor_power != 0:
		if not is_on_floor() and not is_on_wall() and not is_on_wall():
			conveyor_power = 0



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
	if not mode in [MovementMode.WALL_CLING, MovementMode.WALL_CLIMB] :
		if dir == 1:
			wallkick_lock_r.enabled = true
			wallkick_lock_l.enabled = false
		if dir == -1:
			wallkick_lock_r.enabled = false
			wallkick_lock_l.enabled = true
		#print("wallkick could change")
	if mode == MovementMode.WALL_SHOT:
		if dashDirection == 1:
			wallkick_lock_r.enabled = true
			wallkick_lock_l.enabled = false
		if dashDirection == -1:
			wallkick_lock_r.enabled = false
			wallkick_lock_l.enabled = true
	if do_dodgeslide == true:
		wallkick_lock_r.enabled = true
		wallkick_lock_l.enabled = true
	if wallrun_switchL == true or wallrun_switchR == true or walldive_switchL == true or walldive_switchR == true:
		wallkick_lock_r.enabled = false
		wallkick_lock_l.enabled = false

func _on_wallshot_timer_timeout():
	print("no wall shot")
	wall_cling = false if not is_on_wall() else true
	wall_shotLUP = false
	wall_shotLForward = false
	wall_shotLDown = false
	wall_shotRUP = false
	wall_shotRForward = false
	wall_shotRDown = false
	wall_shot_arc = 0
	#animated_sprite_2d.rotation = 0

	velocity.x = store_x 
	can_dash = 1

func die():
	get_tree().reload_current_scene()

func _handle_skates_state():
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
	
		animated_sprite_2d.rotation = velocity.angle()  + 1.57
		#print(velocity.angle() * (180 / 3.141592))


	
func apply_knockback(delta):
	velocity.y += gravity * delta
	# from_dir should be -1 if hit from right, +1 if hit from left
	if animated_sprite_2d.flip_h:
		velocity.x = 600   # facing left → push right
	else:
		velocity.x = -600
	enemy_contact = false
	invincebilityframes_timer.start()
	velocity.y = -300            # give a little upward knock
	boost_mode = 0
	move_and_slide()
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




	#wall_cling = true






func _on_fallingmomentum_timer_timeout():
	can_downroll = false
	store_y = 0
#	print("no more downrolling")


func _on_possiblewallrun_timer_timeout():
	#print("timeout")
	if not wallrunning_wallchecker.is_colliding() or direction_change or mode == MovementMode.UPSIDE_DOWN:
		wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
		can_wallrun_left = false
		can_wallrun_right = false
		wallrun_switchR = false
		wallrun_switchL = false
		can_disable_wallrun = false
		#if angler_dir == 0:
			#direction_change = false
		#print("no wall run")





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
	mode = MovementMode.NORMAL

func _on_invincebilityframes_timer_timeout() -> void:
	recovery_frames = false



func _on_direction_change_timer_timeout() -> void:
	direction_change = false


func _on_possibewalldive_timer_timeout() -> void:
	if not wallrunning_wallchecker.is_colliding() or floor_slope_disable == true:
		wallrun_dive_gravity_multipier = skates_normal_gravity_multiplier
		#print("no_dive")
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
	pass
	#print("yesir")
