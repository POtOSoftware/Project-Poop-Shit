extends Node2D

export var bullet_speed : int = 750
export var ammo : int = 1000
#export(String, "pistol", "smg", "assault_rifle", "death_lazer") var current_weapon = "pistol"

var current_weapon
var can_fire = true
var damage = 0

var weapons = {
	"pistol" : {
		damage = 10,
		fire_rate = 0.33,
		num_projectiles = 1,
		projectile = preload("res://Assets/Bullet/Bullet.tscn")
	},
	"smg" : {
		damage = 5,
		fire_rate = 0.05,
		num_projectiles = 1,
		projectile = preload("res://Assets/Bullet/Bullet.tscn")
	},
	"assault_rifle" : {
		damage = 20,
		fire_rate = 0.2,
		num_projectiles = 1,
		projectile = preload("res://Assets/Bullet/Bullet.tscn")
	},
	"death_lazer" : {
		damage = 2,
		fire_rate = 0,
		num_projectiles = 5
	}
}

func fire(_exclude: Node2D = null):
	if ammo > 0 and can_fire:
		damage = weapons[current_weapon].damage
		create_bullet(weapons[current_weapon].num_projectiles, _exclude)
		ammo -= 1

func create_bullet(num_projectiles : int = 1, _exclude: Node2D = null):
	for i in num_projectiles:
		var projectile_instance = weapons[current_weapon].projectile.instance()
		projectile_instance.position = self.global_position
		projectile_instance.direction = Vector2.RIGHT.rotated(rotation)
		projectile_instance.gun_damage = weapons[current_weapon].damage
		projectile_instance.set_exclude(_exclude)
		get_tree().get_root().add_child(projectile_instance)
	can_fire = false
	yield(get_tree().create_timer(weapons[current_weapon].fire_rate), "timeout")
	can_fire = true
