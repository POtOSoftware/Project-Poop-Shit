extends RigidBody2D

var direction = Vector2.RIGHT
var bullet_speed = 500
var gun_damage

func _ready():
	set_as_toplevel(true) # move independent from parent node

func _physics_process(delta):
	global_position += direction * bullet_speed * delta

func _on_Bullet_body_entered(body):
	if not body.is_in_group("bullet"):
		if (body.is_in_group("enemy") or body.is_in_group("player")):
			body.health -= gun_damage
		queue_free()

func _on_DeleteTimer_timeout():
	queue_free()
