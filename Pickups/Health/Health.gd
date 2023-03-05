extends Area2D

export var add_health : int = 10

func _on_Health_body_entered(body):
	if body == Global.player:
		Global.player.health += add_health
		Global.player.display_message("+" + str(add_health) + " HP")
		queue_free()
