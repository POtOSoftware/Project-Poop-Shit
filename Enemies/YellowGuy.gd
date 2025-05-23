extends KinematicBody2D

enum states {IDLE, CHASE, FIRE, DEAD}

export var health : int = 20 setget set_health
export var reaction: float = 0.25
export var aggression: int = 3
export var ai_enabled : bool = true
export var is_flipped: bool = false
export(states) var state = states.IDLE
export(String, "pistol", "smg", "assault_rifle", "death_lazer") var current_weapon = "pistol"

# movement stuffs :3
export(int) var move_speed = 150
export(int) var jump_power = 300

var player_detected : bool = false
var is_dead : bool = false
var can_fire: bool = true

var blood = load("res://Assets/Blood.tscn")

var velocity = Vector2()

onready var collision = $CollisionShape2D
onready var detection_ray = $Flippable/DetectionRay
onready var obstacle_ray = $Flippable/ObstacleRay
onready var flippable = $Flippable
onready var sprite = $Sprite
onready var gun = $Flippable/Gun

# timers
onready var search_timer = $SearchTime

# debug stuff
onready var debug_root = $Debug
onready var debug_state_display = $Debug/DebugState

func _ready():
	set_new_state(state)
	gun.set_weapon(current_weapon)
	#gun.current_weapon = current_weapon
	flip_node(is_flipped)
	set_process(false)
	#move_in_current_direction(5)

func set_health(new_value):
	health = new_value
	if health <= 0 and is_dead == false:
		die()

func die():
	set_new_state(states.DEAD)
	is_dead = true
	can_fire = false
	ai_enabled = false
	collision.disabled = true
	modulate = Color(0,0,0,1)
	
	# stop all timers (there's only one, but for the future nya :3)
	get_tree().call_group("timers", "stop")
	
	#var blood_instance = blood.instance()
	#get_tree().current_scene.add_child(blood_instance)
	#blood_instance.global_position = global_position
	#blood_instance.rotation = global_position.angle_to_point(Global.player.global_position)
	
	set_physics_process(false)
	set_process(false)

func set_new_state(new_state: int) -> void:
	state = new_state
	print(self.name + ": Changing state to " + str(states.keys()[state]))

func raycast_to_player():
	var space_state = get_world_2d().direct_space_state
	
	var player_pos = Global.player.global_position
	var result = space_state.intersect_ray(global_position, player_pos, [self])
	if result:
		if result.collider == Global.player:
			return {"player_detected":true,
					"player_x_normal": result.normal.x}
		else:
			return {"player_detected": false,
					"player_x_normal": 0}
	
	return false

func apply_gravity() -> void:
	velocity.y += GameWorld.GRAVITY * get_physics_process_delta_time()

func _physics_process(delta):
	# not even our sworn enemies can avoid gravity
	apply_gravity()
	
	#if health <= 0 and is_dead == false:
	#	die()
	
	if Global.debug_build:
		debug_root.visible = true
		process_debug()
	else:
		debug_root.visible = false
	
	if ai_enabled:
		update_ai()
	
	#move_left()
	velocity = move_and_slide(velocity, Vector2.UP)

# this process function is here when we need things to run at all times
# should physics process be disabled, we must enable process, these are
# the most most important things to be run each frame
func _process(delta):
	# gravity is ALWAYS present just like the real world
	# never stop applying gravity even if physics_process is stopped
	# well... only enable process if phys_process is disabled
	# we dont need to apply gravity twice!
	apply_gravity()
	velocity = move_and_slide(velocity, Vector2.UP)

func update_ai():
	# only a human can write code this crappy, no AI here
	match state:
		states.IDLE:
			stop_moving()
			if player_detected:
				# waste of resources to cast a ray multiple times to find out if the player is there and the player's normal
				var _player_raycast = raycast_to_player()
				
				if _player_raycast.player_detected:
					if _player_raycast.player_x_normal > 0:
						flip_node(true)
					else:
						flip_node(false)
					set_new_state(states.CHASE)
		states.CHASE:
			# this is stupid and terrible because this assumes that the player was seen in the direction they were already facing, too bad!
			move_in_current_direction()
			
			# ran into a wall, what do?
			if is_on_wall():
				# this wall isn't too high for me! im gonna jump over it and keep looking!
				if not obstacle_ray.is_colliding():
					# small issue with this is that if the enemy encounters another obstacle before the timer ends,
					# the timer restarts and they keep moving. on the other hand, it might make the ai look smarter?
					# hopefully :3c
					search_timer.start()
					jump()
				# DAMN! that wall is too high! gonna turn around and keep point here I suppose
				else:
					flip_node(!is_flipped)
					set_new_state(states.IDLE)
			# i got the player in my range! FIRE!
			if detection_ray.get_collider() == Global.player:
				set_new_state(states.FIRE)
		states.FIRE:
			var times_fired: int = 0
			
			stop_moving()
			# stopping the physics process from doing anything is the only way to get the intended results
			# this whole thing is probably gonna shit its pants in the long run but hey, it works!
			set_physics_process(false)
			set_process(true)
			
			yield(get_tree().create_timer(reaction), "timeout")
			# im gonna go ahead and fire (for example) 3 times! then go back to chasing
			while times_fired < aggression:
				if not can_fire:
					break
				else:
					gun.fire(self)
					print("Firing!")
					times_fired += 1
					# wait for the fire rate time so that we dont call fire 3 times, but only fire once, but say we did a good job
					yield(get_tree().create_timer(gun.weapons[current_weapon].fire_rate), "timeout")
			
			set_process(false)
			set_physics_process(true)
			if not is_dead:
				set_new_state(states.CHASE)
		states.DEAD:
			can_fire = false
			die()
		_:
			printerr("Enemy " + self.name + " had a state error and had to die!")
			die()

func move_left():
	velocity.x = -move_speed
	flip_node(true)

func move_right():
	velocity.x = move_speed
	flip_node(false)

func move_in_current_direction():
	# this some bullshit but i dont care :3c
	if is_flipped:
		move_left()
	else:
		move_right()

func jump():
	if is_on_floor():
		velocity.y = -jump_power

func stop_moving():
	velocity.x = 0

#func update_ai():
#	if detection_ray.get_collider() == Global.player:
#		gun.fire(self)
#	# why jump over the player? I WANNA SHOOT THE PLAYER!
#	# but if it's a wall, then fuck yeah i wanna JUMP!
#	if obstacle_ray.is_colliding():
#		# wah wah nested if statement gay and cringe but lookie now im not scared of my own bullets!
#		if obstacle_ray.get_collider() != Global.player && !obstacle_ray.get_collider().is_in_group("bullet"):
#			move_in_current_direction()
#			jump()

func flip_node(value: bool):
	if value:
		sprite.set_flip_h(true)
		flippable.scale.x = -1
		#detection_ray.scale.x = -1
		#obstacle_ray.scale.x = -1
		#gun.rotation_degrees = 180
		#gun.position.x = -13
		#print(gun.scale)
	else:
		sprite.set_flip_h(false)
		flippable.scale.x = 1
		#detection_ray.scale.x = 1
		#obstacle_ray.scale.x = 1
		#gun.rotation_degrees = 0
		#gun.position.x = 13
		#print(gun.scale)
	
	# still faces the wrong direction in collision debug view
	# BUT IT WORKS WHO CARES :33333
	# turns out i shouldve cared, cause then sprites would face the wrong direction
	#gun.scale.x = flippable.scale.x
	is_flipped = value

func process_debug():
	debug_state_display.text = states.keys()[state]

func _on_PlayerDetection_body_entered(body):
	if body == Global.player:
		player_detected = true
	
	#print(body)
	#var space_state = get_world_2d().direct_space_state
	
	#if body == Global.player and ai_enabled:
	#	var player_pos = Global.player.global_position
	#	# draw an invisible line from our position to the player's and get whatever collisions happen on that line, but exclude us, we don't count
	#	var result = space_state.intersect_ray(global_position, player_pos, [self])
		
	#	if result:
	#		if result.collider == Global.player:
	#			if result.normal.x > 0:
	#				move_left()
	#			else:
	#				move_right()

func _on_PlayerDetection_body_exited(body):
	if body == Global.player:
		player_detected = false

func _on_SearchTime_timeout():
	set_new_state(states.IDLE)
