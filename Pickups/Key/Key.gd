tool
extends Area2D

export(String, "red", "green", "blue") var key_type

func _process(delta):
	if Engine.editor_hint:
		match key_type:
			"red":
				modulate = Color(1,0,0,1)
			"green":
				modulate = Color(0,1,0,1)
			"blue":
				modulate = Color(0,0,1,1)
			_: # THAT'S HOW YOU DEFAULT???
				modulate = Color(1,1,1,1)
	if not Engine.editor_hint:
		if not key_type: # If a key type wasn't chosen, delete it
			queue_free()

func _on_Key_body_entered(body):
	if body == Global.player:
		match key_type:
			"red":
				Global.player.has_red_key = true
				Global.player.display_message("Obtained red key")
				queue_free()
			"green":
				Global.player.has_green_key = true
				Global.player.display_message("Obtained green key")
				queue_free()
			"blue":
				Global.player.has_blue_key = true
				Global.player.display_message("Obtained blue key")
				queue_free()
