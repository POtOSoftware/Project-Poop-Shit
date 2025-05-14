extends KinematicBody2D

export var health : int = 20
export var ai_enabled : bool = true
export var is_flipped: bool = false
export(String, "pistol", "smg", "assault_rifle", "death_lazer") var current_weapon = "pistol"

# movement stuffs :3
export(int) var move_speed = 150
export(int) var jump_power = 300

var player_detected : bool = false
var is_dead : bool = false

var blood = load("res://Assets/Blood.tscn")

var velocity = Vector2()

onready var collision = $CollisionShape2D
onready var detection_ray = $DetectionRay
onready var obstacle_ray = $ObstacleRay
onready var sprite = $Sprite
onready var gun = $Gun

func _ready():
	gun.current_weapon = current_weapon
	flip_node(is_flipped)
	move_in_current_direction(5)

func die():
	is_dead = true
	ai_enabled = false
	collision.disabled = true
	modulate = Color(0,0,0,1)
	
	#var blood_instance = blood.instance()
	#get_tree().current_scene.add_child(blood_instance)
	#blood_instance.global_position = global_position
	#blood_instance.rotation = global_position.angle_to_point(Global.player.global_position)
	
	set_process(false)
	set_physics_process(false)

func _physics_process(delta):
	# not even our sworn enemies can avoid gravity
	velocity.y += GameWorld.GRAVITY * delta
	
	if health <= 0 and is_dead == false:
		die()
	
	if ai_enabled:
		update_ai()
	
	#move_left()
	velocity = move_and_slide(velocity, Vector2.UP)

func move_left():
	velocity.x = -move_speed
	flip_node(true)

func move_right():
	velocity.x = move_speed
	flip_node(false)

func move_in_current_direction(duration: float):
	# this some bullshit but i dont care :3c
	if is_flipped:
		while not is_zero_approx(duration):
			move_left()
			duration -= get_physics_process_delta_time()
	else:
		while not is_zero_approx(duration):
			move_right()
			duration -= get_physics_process_delta_time()

func jump():
	if is_on_floor():
		velocity.y = -jump_power

func stop_moving():
	velocity.x = 0

func update_ai():
	if detection_ray.get_collider() == Global.player:
		gun.fire(self)
	# why jump over the player? I WANNA SHOOT THE PLAYER!
	# but if it's a wall, then fuck yeah i wanna JUMP!
	if obstacle_ray.is_colliding():
		# wah wah nested if statement gay and cringe but lookie now im not scared of my own bullets!
		if detection_ray.get_collider() != Global.player && !detection_ray.get_collider().is_in_group("bullet"):
			jump()
			move_in_current_direction(2)

func flip_node(value: bool):
	if value:
		sprite.set_flip_h(true)
		detection_ray.scale.x = -1
		obstacle_ray.scale.x = -1
		gun.rotation_degrees = 180
		gun.position.x = -13
		#print(gun.scale)
	else:
		sprite.set_flip_h(false)
		detection_ray.scale.x = 1
		obstacle_ray.scale.x = 1
		gun.rotation_degrees = 0
		gun.position.x = 13
		#print(gun.scale)
	
	is_flipped = value

func _on_PlayerDetection_body_entered(body):
	var space_state = get_world_2d().direct_space_state
	
	if body == Global.player and ai_enabled:
		var player_pos = Global.player.global_position
		# draw an invisible line from our position to the player's and get whatever collisions happen on that line, but exclude us, we don't count
		var result = space_state.intersect_ray(global_position, player_pos, [self])
		
		if result:
			if result.collider == Global.player:
				if result.normal.x > 0:
					move_left()
				else:
					move_right()

func _on_PlayerDetection_body_exited(body):
	if body == Global.player and ai_enabled:
		stop_moving()
