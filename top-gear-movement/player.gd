# Player.gd
extends Node2D

class_name Player

@export var speed := 0.0
@export var acceleration := 500.0
@export var max_speed := 4000.0
@export var deceleration := 1000.0
@export var turn_speed := 3.0

@onready var road_drawer: RoadDrawer = %RoadDrawer


func _process(delta):
	_handle_input(delta)
	road_drawer.update_player_z(delta, speed)


func _handle_input(delta):
	if Input.is_action_pressed("ui_up"):
		speed += acceleration * delta
	elif Input.is_action_pressed("ui_down"):
		speed -= deceleration * delta
	else:
		speed -= deceleration * delta * 0.5

	speed = clamp(speed, 0, max_speed)

	if Input.is_action_pressed("ui_left"):
		road_drawer.player_z -= turn_speed * delta
	elif Input.is_action_pressed("ui_right"):
		road_drawer.player_z += turn_speed * delta
