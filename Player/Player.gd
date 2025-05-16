# Thank you evpevdev for this sweet and sexy platformer controller

extends KinematicBody2D

# Game-specific vars
export var health : int = 100
export var can_move : bool = true
export var is_flipped: bool = false
export(String, "pistol", "smg", "assault_rifle", "death_lazer") var current_weapon = "pistol"

var can_die : bool = true

# The max jump height in pixels (holding jump)
export var max_jump_height = 75 setget set_max_jump_height
# The minimum jump height (tapping jump)
export var min_jump_height = 40 setget set_min_jump_height
# The height of your jump in the air
export var double_jump_height = 100 setget set_double_jump_height
# How long it takes to get to the peak of the jump in seconds
export var jump_duration = 0.3 setget set_jump_duration
# Multiplies the gravity by this while falling
export var falling_gravity_multiplier = 1.5
# Set to 2 for double jump
export var max_jump_amount = 1
export var max_acceleration = 1750
export var friction = 8
export var can_hold_jump : bool = false
# You can still jump this many seconds after falling off a ledge
export var coyote_time : float = 0.1
# Only neccessary when can_hold_jump is off
# Pressing jump this many seconds before hitting the ground will still make you jump
export var jump_buffer : float = 0.1


# not used
var max_speed = 100
var acceleration_time = 10


# These will be calcualted automatically
var default_gravity : float
var jump_velocity : float
var double_jump_velocity : float
# Multiplies the gravity by this when we release jump
var release_gravity_multiplier : float


var jumps_left : int
var holding_jump := false

var vel = Vector2()
var acc = Vector2()

onready var coyote_timer = Timer.new()
onready var jump_buffer_timer = Timer.new()

# node onready vars
onready var sprite = $Sprite
onready var gun = $Flippable/Gun
onready var health_bar = $UILayer/UI/HealthBar
onready var message_label = $UILayer/UI/MessageLabel
onready var message_timer = $MessageTimer
onready var animation = $AnimationPlayer
onready var flippable = $Flippable

# ui onreadeez nuts
onready var ui_root = $UILayer/UI
onready var debug_ui_root = $UILayer/DebugUI
onready var debug_fps_monitor = $UILayer/DebugUI/FPSMonitor

# key variables (not pretty but im too lazy to have a proper key pickup system)
export var has_red_key : bool = false
export var has_green_key : bool = false
export var has_blue_key : bool = false

func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)


func _ready():
	Global.player = self
	Global.player_gun = gun
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	gun.set_weapon(current_weapon)
	#gun.current_weapon = current_weapon
	
	add_child(coyote_timer)
	coyote_timer.wait_time = coyote_time
	coyote_timer.one_shot = true
	
	add_child(jump_buffer_timer)
	jump_buffer_timer.wait_time = jump_buffer
	jump_buffer_timer.one_shot = true

func _exit_tree():
	Global.player = null
	Global.player_gun = null

func die():
	can_die = false
	queue_free()

func flip_node(value: bool):
	if value:
		sprite.set_flip_h(true)
		flippable.scale.x = -1
	else:
		sprite.set_flip_h(false)
		flippable.scale.x = 1

	is_flipped = value

func _physics_process(delta):
	if Global.debug_build:
		debug_ui_root.visible = true
		process_debug()
	else:
		debug_ui_root.visible = false
	
	acc.x = 0
	
	# TODO: Only update this when health is changed
	health_bar.value = health
	
	if health <= 0 and can_die:
		die()
	
	if is_on_floor():
		coyote_timer.start()
	if not coyote_timer.is_stopped():
		jumps_left = max_jump_amount
	
	if Input.is_action_pressed("move_left"):
		acc.x = -max_acceleration
		flip_node(true)
		#sprite.set_flip_h(true)
		#gun.scale.x = -1
		#gun.rotation_degrees = 180
		#gun.position.x = -13
	if Input.is_action_pressed("move_right"):
		acc.x = max_acceleration
		flip_node(false)
		#sprite.set_flip_h(false)
		#gun.scale.x = 1
		#gun.rotation_degrees = 0
		#gun.position.x = 13
	
	
	# Check for ground jumps when we can hold jump
	if can_hold_jump:
		if Input.is_action_pressed("jump"):
			# Dont use double jump when holding down
			if is_on_floor():
				jump()
	
	# Check for ground jumps when we cannot hold jump
	if not can_hold_jump:
		if not jump_buffer_timer.is_stopped() and is_on_floor():
			jump()
	
	# Check for jumps in the air
	if Input.is_action_just_pressed("jump"):
		holding_jump = true
		jump_buffer_timer.start()
		
		# Only jump in the air when press the button down, code above already jumps when we are grounded
		if not is_on_floor():
			jump()
		
	
	if Input.is_action_just_released("jump"):
		holding_jump = false
	
	if Input.is_action_pressed("fire"):
		Global.player_gun.fire(self)
	
	
	var gravity = default_gravity
	
	if vel.y > 0: # If we are falling
		gravity *= falling_gravity_multiplier
		
	if not holding_jump and vel.y < 0: # if we released jump and are still rising
		if not jumps_left < max_jump_amount - 1: # Always jump to max height when we are using a double jump
			gravity *= release_gravity_multiplier # multiply the gravity so we have a lower jump
	
	acc.y = -gravity
	vel.x *= 1 / (1 + (delta * friction))
	
	vel += acc * delta
	vel = move_and_slide(vel, Vector2.UP)

func display_message(message : String):
	message_label.text = message # Set message text to string specified in argument
	animation.play("show_message") # I like this kinda text reveal animation
	message_timer.start()
	#yield(get_tree().create_timer(5), "timeout") # Wait 5 seconds before clearing message
	#message_label.text = "" # Clear message

func process_debug():
	debug_fps_monitor.text = "FPS: " + str(Engine.get_frames_per_second())

func calculate_gravity(p_max_jump_height, p_jump_duration):
	# Calculates the desired gravity by looking at our jump height and jump duration
	# Formula is from this video https://www.youtube.com/watch?v=hG9SzQxaCm8
	return (-2 *p_max_jump_height) / pow(p_jump_duration, 2)


func calculate_jump_velocity(p_max_jump_height, p_jump_duration):
	# Calculates the desired jump velocity by lookihg at our jump height and jump duration
	return (2 * p_max_jump_height) / (p_jump_duration)


func calculate_jump_velocity2(p_max_jump_height, p_gravity):
	# Calculates jump velocity from jump height and gravity
	# formula from 
	# https://sciencing.com/acceleration-velocity-distance-7779124.html#:~:text=in%20every%20step.-,Starting%20from%3A,-v%5E2%3Du
	return sqrt(-2 * p_gravity * p_max_jump_height)


func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity):
	# Calculates the gravity when the key is released based on the minimum jump height and jump velocity
	# Formula is from this website https://sciencing.com/acceleration-velocity-distance-7779124.html
	var release_gravity = 0 - pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity


func calculate_friction(time_to_max):
	# Formula from https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3
	# this friction will hit 90% of max speed after the accel time
	return 1 - (2.30259 / time_to_max)


func calculate_speed(p_max_speed, p_friction):
	# Formula from https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3	
	return (p_max_speed / p_friction) - p_max_speed


func jump():
	if jumps_left == max_jump_amount and coyote_timer.is_stopped():
		# Your first jump must be used when on the ground
		# If you fall off the ground and then jump you will be using you second jump
		jumps_left -= 1
		
	if jumps_left > 0:
		if jumps_left < max_jump_amount: # If we are double jumping
			vel.y = -double_jump_velocity
		else:
			vel.y = -jump_velocity
		jumps_left -= 1
	
	
	coyote_timer.stop()


func set_max_jump_height(value):
	max_jump_height = value
	
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)


func set_jump_duration(value):
	jump_duration = value
	
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)


func set_min_jump_height(value):
	min_jump_height = value
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)

func set_double_jump_height(value):
	double_jump_height = value
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)

func add_player_health(add_health):
	health += add_health
	if health > 100:
		health = 100

func _on_MessageTimer_timeout():
	#animation.play_backwards("show_message")
	message_label.text = "" # Clear message
