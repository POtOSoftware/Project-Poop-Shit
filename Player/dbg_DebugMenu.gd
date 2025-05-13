extends Control

onready var camera = $"../../Camera2D"

# Labels
onready var timescale_label = $dbg_Sliders/dbg_TimescaleLabel
onready var cam_zoom_label = $dbg_Sliders/dbg_CameraZoomLabel

func _input(event):
	if event.is_action_pressed("toggle_debug_menu") and Global.debug_build:
		var new_pause_state = not get_tree().paused
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
	match index:
		0:
			Global.player_gun.current_weapon = "pistol"
		1:
			Global.player_gun.current_weapon = "smg"
		2:
			Global.player_gun.current_weapon = "assault_rifle"
		3:
			Global.player_gun.current_weapon = "death_lazer"
		
	print("Changed weapon to " + Global.player_gun.current_weapon)
