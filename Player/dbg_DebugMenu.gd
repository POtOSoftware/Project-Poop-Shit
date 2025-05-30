extends Control

onready var camera = $"../../Camera2D"

# Labels
onready var timescale_label = $dbg_Sliders/dbg_TimescaleLabel
onready var cam_zoom_label = $dbg_Sliders/dbg_CameraZoomLabel

onready var weapon_select = $dbg_WeaponSelect

func _ready() -> void:
	# wait for every node to be ready so we dont attempt to access a null weapons list
	# and some extra jargon so it checks on scene reloads too
	yield(get_tree().root.get_child(get_tree().root.get_child_count()-1), "ready")
	# grab the list of weapon names from gun.gd
	var gun_list = Global.player_gun.weapons.keys()
	for gun in gun_list:
		# now add all those guns to the weapon selector
		weapon_select.add_item(gun)
	#print(gun_list)

func _input(event):
	if event.is_action_pressed("toggle_debug_menu") and Global.debug_build:
		var new_pause_state = not get_tree().paused
		Global.debug_accident = false
		Global.set_pause(new_pause_state)
		visible = Global.game_paused
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# "reload scene" button pressed
func _on_dbg_ReloadScene_pressed():
	Global.set_pause(false)
	get_tree().reload_current_scene()

func _on_dbg_TimescaleSlider_value_changed(value):
	Engine.set_time_scale(value)
	timescale_label.text = "timescale: " + str(value)

func _on_dbg_CameraZoom_value_changed(value):
	camera.zoom = Vector2(value, value)
	cam_zoom_label.text = "cam zoom: " + str(value)

func _on_dbg_KillAll_pressed():
	get_tree().call_group("enemy", "die")

func _on_dbg_DisableAI_toggled(button_pressed):
	get_tree().set_group("enemy", "ai_enabled", not button_pressed)

func _on_dbg_GodMode_toggled(button_pressed):
	Global.player.can_die = not button_pressed

func _on_dbg_WeaponSelect_item_selected(index):
	#match index:
	#	0:
	#		Global.player_gun.set_weapon("pistol")
	#		#Global.player_gun.current_weapon = "pistol"
	#	1:
	#		Global.player_gun.set_weapon("smg")
	#		#Global.player_gun.current_weapon = "smg"
	#	2:
	#		Global.player_gun.set_weapon("assault_rifle")
	#		#Global.player_gun.current_weapon = "assault_rifle"
	#	3:
	#		Global.player_gun.set_weapon("death_lazer")
	#		#Global.player_gun.current_weapon = "death_lazer"
	
	# wow this was... way simpler
	var new_weapon: String = weapon_select.get_item_text(index)
	
	Global.player_gun.set_weapon(new_weapon)
	
	print("Changed weapon to " + new_weapon)

func _on_GravityEdit_text_entered(new_text):
	print("Changed GRAVITY from " + str(GameWorld.GRAVITY) + " to " + new_text)
	GameWorld.GRAVITY = int(new_text)
