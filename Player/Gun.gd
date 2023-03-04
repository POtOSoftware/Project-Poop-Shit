extends Node2D

export var bullet_speed : int = 750

export var ammo : int = 1000

var bullet = preload("res://Assets/Bullet/Bullet.tscn")

var can_fire = true
var weapon_list = []
var damage = 0

var weapons = {
	"pistol" : {
		damage = 10,
		fire_rate = 0.5,
		num_projectiles = 1
	}
}

var current_weapon = "pistol"

func fire():
	if ammo > 0:
		damage = weapons[current_weapon].damage
		create_bullet(weapons[current_weapon].num_projectiles)
		ammo -= 1

func create_bullet(num_projectiles : int = 1):
	for i in num_projectiles:
		var bullet_instance = bullet.instance()
		bullet_instance.position = self.global_position
		bullet_instance.direction = Vector2.RIGHT.rotated(rotation)
		get_tree().get_root().add_child(bullet_instance)
	can_fire = false
	yield(get_tree().create_timer(weapons[current_weapon].fire_rate), "timeout")
	can_fire = true

func _physics_process(delta):
	if Input.is_action_pressed("fire") and can_fire:
		fire()
		print("FIRE!")
