tool
extends Node2D

export var size : int = 1
export var wait_between_points : float = 0.5
export var travel_time : float = 1.0

onready var kinematic_body = $KinematicBody2D
onready var tween = $Tween
onready var path_follow = $Path2D/PathFollow2D

func _physics_process(delta):
	if Engine.editor_hint:
		kinematic_body.scale.x = size
	#if not Engine.editor_hint:
		#tween.start()
		#tween.interpolate_property(path_follow, "unit_offset", 0, 1, travel_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func _ready():
	tween.start()
	tween.interpolate_property(path_follow, "unit_offset", 0, 1, travel_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
