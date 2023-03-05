tool
extends StaticBody2D

export(String, "red", "green", "blue") var door_type

var door_open : bool = false

func _process(delta):
	if Engine.editor_hint:
		match door_type:
			"red":
				modulate = Color(1,0,0,1)
			"green":
				modulate = Color(0,1,0,1)
			"blue":
				modulate = Color(0,0,1,1)
			_: # THAT'S HOW YOU DEFAULT???
				modulate = Color(1,1,1,1)
	if not Engine.editor_hint:
		if not door_type: # If a door type wasn't chosen, delete it
			queue_free()

func _on_Area2D_body_entered(body):
	if body == Global.player and not door_open:
		var tween = Tween.new()
		match door_type:
			"red":
				if Global.player.has_red_key:
					#tween.interpolate_property(self, "position:y", 0, -32, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					position.y -= 32
					door_open = true
				else:
					Global.player.display_message("Need red key")
			"green":
				if Global.player.has_green_key:
					position.y -= 32
					door_open = true
				else:
					Global.player.display_message("Need green key")
			"blue":
				if Global.player.has_blue_key:
					position.y -= 32
					door_open = true
				else:
					Global.player.display_message("Need blue key")
