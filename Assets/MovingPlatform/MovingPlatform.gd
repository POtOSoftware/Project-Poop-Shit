# https://www.youtube.com/watch?v=mBNa8LcAsns (the only tutorial I found that used tween nodes instead of a damn animation)

extends Node2D

export var wait_between_points : float = 1.0
export var travel_time : float = 1.0
export var repeat : bool = true

onready var kinematic_body = $KinematicBody2D
onready var tween = $Tween
onready var path_follow = $Path2D/PathFollow2D
onready var wait_timer = $WaitTimer

func _ready():
	tween.repeat = self.repeat
	_init_tween()

func _init_tween():
	tween.interpolate_property(path_follow, "unit_offset", 0, 1, travel_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, wait_between_points)
	tween.interpolate_property(path_follow, "unit_offset", 1, 0, travel_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, travel_time + wait_between_points * 2)
	tween.start()
