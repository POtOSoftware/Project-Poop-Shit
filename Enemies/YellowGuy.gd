extends KinematicBody2D

export var health : int = 20
export var ai_enabled : bool = true
export(String, "pistol", "smg", "assault_rifle", "death_lazer") var current_weapon = "pistol"

var player_detected : bool = false
var is_dead : bool = false

var blood = load("res://Assets/Blood.tscn")

var velocity = Vector2()

onready var collision = $CollisionShape2D
onready var detection_ray = $DetectionRay
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
	velocity.y = GameWorld.GRAVITY
	
	if health <= 0 and is_dead == false:
		die()
	
	if ai_enabled:
		update_ai()
	
	velocity = move_and_slide(velocity)


func update_ai():
	if detection_ray.get_collider() == Global.player:
		gun.fire()
