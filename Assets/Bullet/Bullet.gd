extends RigidBody2D

var direction
var bullet_speed = 500
var gun_damage
var exclude: Node2D

func _ready():
	set_as_toplevel(true) # move independent from parent node

func _physics_process(delta):
	global_position += direction * bullet_speed * delta

func set_exclude(node: Node2D = null):
	print("Excluding " + node.name + " from being damaged by " + self.name)
	exclude = node

func _on_Bullet_body_entered(body):
	# make sure the collider isnt itself, or the excluded node
	if not body.is_in_group("bullet") and body != exclude:
		# damage the enemy or the player, we dont discriminate
		if (body.is_in_group("enemy") or body.is_in_group("player")):
			body.health -= gun_damage
		queue_free()

func _on_DeleteTimer_timeout():
	queue_free()
