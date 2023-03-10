extends Node

var cmd_args = Array(OS.get_cmdline_args())
var debug_build = OS.is_debug_build()
var game_paused = false

# https://www.youtube.com/watch?v=SA4vRYYdbrk (I watched this tutorial for a blood particle effect, and I got this bit of code. Super cool!)
var player = null
var player_gun = null

func set_pause(pause : bool):
	get_tree().paused = pause
	game_paused = pause

func _init():
	if cmd_args.has("-debug"):
		debug_build = true
		print("## DEBUG MODE ENABLED ##")

func _input(event):
	if event.is_action_pressed("enable_debug_mode"):
		debug_build = true
		print("## DEBUG MODE ENABLED ##")
