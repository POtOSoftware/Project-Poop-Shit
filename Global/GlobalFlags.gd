extends Node

var cmd_args = Array(OS.get_cmdline_args())
var debug_build = OS.is_debug_build()
var game_paused = false

func set_pause(pause : bool):
	get_tree().paused = pause
	game_paused = pause
	

func _init():
	if cmd_args.has("-debug"):
		debug_build = true
