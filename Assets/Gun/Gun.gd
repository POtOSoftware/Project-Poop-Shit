extends Node2D

export var bullet_speed : int = 750
export var ammo : int = 1000
#export(String, "pistol", "smg", "assault_rifle", "death_lazer") var current_weapon = "pistol"

var current_weapon
var can_fire = true
var damage = 0
var parent: Node2D

onready var gun_sprite = $GunSprite
onready var fire_point = $FirePoint

var weapons = {
	"pistol" : 
	{
		damage = 10,
		fire_rate = 0.33,
		num_projectiles = 1,
		angle_increment = 0,
		projectile = preload("res://Assets/Bullet/Bullet.tscn"),
		sprite = preload("res://Sprites/guns/pistol.png"),
		fire_pos = Vector2(8, -4)
	},
	"smg" : 
	{
		damage = 5,
		fire_rate = 0.05,
		num_projectiles = 1,
		angle_increment = 0,
		projectile = preload("res://Assets/Bullet/Bullet.tscn"),
		sprite = preload("res://Sprites/guns/smg.png"),
		fire_pos = Vector2(20, -5)
	},
	"assault_rifle" : 
	{
		damage = 20,
		fire_rate = 0.2,
		num_projectiles = 1,
		angle_increment = 0,
		projectile = preload("res://Assets/Bullet/Bullet.tscn"),
		sprite = preload("res://Sprites/guns/assault_rifle.png"),
		fire_pos = Vector2(23, -3)
	},
	"shotgun" : 
	{
		damage = 10,
		fire_rate = 0.5,
		num_projectiles = 3,
		angle_increment = 7,
		projectile = preload("res://Assets/Bullet/Bullet.tscn"),
		sprite = preload("res://icon.png")
		#fire_pos =
	},
	"death_lazer" : 
	{
		damage = 2,
		fire_rate = 0,
		num_projectiles = 5
	}
}

func _ready():
	# so it's not grabbing the parent every time it creates a bullet
	# just do it once here and save it, saves resources! i hope!
	parent = get_parent()

func set_weapon(new_weapon: String) -> void:
	current_weapon = new_weapon
	gun_sprite.texture = weapons[new_weapon].sprite
	
	# check if there's a specified fire point position
	if weapons[new_weapon].has("fire_pos"):
		fire_point.position = weapons[new_weapon].fire_pos
	else:
		# if not, cry about it and set it to (0,0)
		printerr("Fire point position not specified in weapon " + new_weapon + " !!!")
		fire_point.position = Vector2(0,0)

func fire(_exclude: Node2D = null):
	if ammo > 0 and can_fire:
		damage = weapons[current_weapon].damage
		create_bullet(weapons[current_weapon].num_projectiles, _exclude)
		ammo -= 1

func create_bullet(num_projectiles : int = 1, _exclude: Node2D = null):
	fire_point.rotation_degrees = weapons[current_weapon].angle_increment
	print("initial rotation " + str(fire_point.rotation_degrees))
	for i in num_projectiles:
		var projectile_instance = weapons[current_weapon].projectile.instance()
		projectile_instance.position = fire_point.global_position
		projectile_instance.direction = Vector2.RIGHT.rotated(fire_point.rotation) * parent.scale.x # looks weird but it works so nyaaaaaa :p
		projectile_instance.gun_damage = weapons[current_weapon].damage
		projectile_instance.set_exclude(_exclude)
		get_tree().get_root().add_child(projectile_instance)
		fire_point.rotation_degrees -= weapons[current_weapon].angle_increment
		print(fire_point.rotation_degrees)
	can_fire = false
	yield(get_tree().create_timer(weapons[current_weapon].fire_rate), "timeout")
	can_fire = true
