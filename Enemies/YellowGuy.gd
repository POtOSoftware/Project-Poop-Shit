extends KinematicBody2D

export var health : int = 20
export var ai_enabled : bool = true

var player_detected : bool = false
var is_dead : bool = false

var blood = load("res://Assets/Blood.tscn")

var velocity = Vector2()

func die():
	is_dead = true
	ai_enabled = false
	
	var blood_instance = blood.instance()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	blood_instance.rotation = global_position.angle_to_point(Global.player.global_position)
	
	set_process(false)
	set_physics_process(false)

func _physics_process(delta):
	if health <= 0 and is_dead == false:
		die()