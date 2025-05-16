extends Node

var cmd_args = Array(OS.get_cmdline_args())
var debug_build = OS.is_debug_build()
var game_paused = false

# https://www.youtube.com/watch?v=SA4vRYYdbrk (I watched this tutorial for a blood particle effect, and I got this bit of code. Super cool!)
var player = null
var player_gun = null

var debug_accident: bool = true

func set_pause(pause : bool):
	get_tree().paused = pause
	game_paused = pause

func _init():
	if cmd_args.has("-debug"):
		debug_build = true
		print("## DEBUG MODE ENABLED ##")

func _input(event):
	if Input.is_action_just_pressed("enable_debug_mode"):
		debug_build = !debug_build
		if debug_build:
			player.display_message("Debug mode enabled! Press ~/SELECT for debug menu")
			print("## DEBUG MODE ENABLED ##")
			yield(get_tree().create_timer(5), "timeout")
			debug_accident = false
		if not debug_build:
			if debug_accident:
				player.display_message("Disabled debug mode. Now stop touching your joystick!")
			else:
				player.display_message("Disabled debug mode.")
		print("## DEBUG MODE DISABLED ##")
		
