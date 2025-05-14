extends KinematicBody2D

export var health : int = 20
export var ai_enabled : bool = true
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
onready var sprite = $Sprite
onready var gun = $Gun

func _ready():
	gun.current_weapon = current_weapon

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
	
	velocity = move_and_slide(velocity, Vector2.UP)

func jump():
	if is_on_floor():
		velocity.y = -jump_power

func update_ai():
	if detection_ray.get_collider() == Global.player:
		gun.fire(self)
	jump()

func flip_node(value: bool):
	if value:
		sprite.set_flip_h(true)
		detection_ray.scale.x = -1
		gun.rotation_degrees = 180
		gun.position.x = -13
		print(gun.scale)
	else:
		sprite.set_flip_h(false)
		detection_ray.scale.x = 1
		gun.rotation_degrees = 0
		gun.position.x = 13
		print(gun.scale)

func _on_PlayerDetection_body_entered(body):
	var space_state = get_world_2d().direct_space_state
	
	if body == Global.player and ai_enabled:
		var player_pos = Global.player.global_position
		# draw an invisible line from our position to the player's and get whatever collisions happen on that line, but exclude us, we don't count
		var result = space_state.intersect_ray(global_position, player_pos, [self])
		
		if result:
			if result.collider == Global.player:
				if result.normal.x > 0:
					flip_node(true)
				else:
					flip_node(false)
