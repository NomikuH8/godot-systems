class_name FollowerCameraComponent
extends Node

@export var to_follow: Node3D
@export var follow_offset := Vector3(0.0, 5.0, -10.0)
@export var position_y_lerp_multiplier := 5.0
@export var follow_rotation_y: bool = true
@export var rotation_y_lerp_multiplier := 5.0
@export var rotation_y_offset := 0.0

var parent: Camera3D
var pivot: Node3D

func _ready() -> void:
	parent = get_parent()
	pivot = parent.get_parent()
	pivot.top_level = true


func _physics_process(delta: float) -> void:
	var target_pos := to_follow.global_transform.origin + to_follow.global_transform.basis * Vector3.ZERO
	
	var current_pos := pivot.position
	var new_pos := Vector3(
		target_pos.x,
		lerpf(current_pos.y, target_pos.y, position_y_lerp_multiplier * delta),
		target_pos.z,
	)
	pivot.position = new_pos

	if follow_rotation_y:
		var target_rotation := to_follow.global_rotation.y
		var current_rotation := pivot.global_rotation
		pivot.global_rotation = Vector3(
			current_rotation.x,
			lerp_angle(current_rotation.y, target_rotation, rotation_y_lerp_multiplier * delta),
			current_rotation.z
		)
	
	parent.global_rotation = Vector3(
		parent.global_rotation.x,
		lerp_angle(
			parent.global_rotation.y,
			to_follow.global_rotation.y + deg_to_rad(rotation_y_offset),
			rotation_y_lerp_multiplier * delta
		),
		parent.global_rotation.z
	)
