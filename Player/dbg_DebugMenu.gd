extends Control

func _input(event):
	if event.is_action_pressed("toggle_debug_menu") and GlobalFlags.debug_build:
		var new_pause_state = not get_tree().paused
		GlobalFlags.set_pause(new_pause_state)
		visible = GlobalFlags.game_paused

# "reload scene" button pressed
func _on_dbg_ReloadScene_pressed():
	GlobalFlags.set_pause(false)
	get_tree().reload_current_scene()

func _on_dbg_TimescaleSlider_value_changed(value):
	Engine.set_time_scale(value)
	$dbg_Sliders/dbg_TimescaleLabel.text = "timescale: " + str(value)
