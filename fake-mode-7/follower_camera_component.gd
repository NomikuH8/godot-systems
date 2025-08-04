extends Node

@export var to_follow: Node3D
@export var follow_offset := Vector3(0.0, 5.0, -10.0)
@export var position_y_lerp_multiplier := 5.0
@export var follow_rotation_y: bool = true
@export var rotation_y_lerp_multiplier := 5.0

var parent: Camera3D
var pivot: Node3D

func _ready() -> void:
	parent = get_parent()
	pivot = parent.get_parent()


func _process(delta: float) -> void:
	var target_pos := to_follow.global_transform.origin + to_follow.global_transform.basis * follow_offset
	
	var current_pos := parent.global_position
	var new_pos := Vector3(
		target_pos.x,
		lerpf(current_pos.y, target_pos.y, position_y_lerp_multiplier * delta),
		target_pos.z,
	)
	parent.global_position = new_pos

	if follow_rotation_y:
		var target_rotation := to_follow.global_rotation.y
		var current_rotation := parent.global_rotation
		parent.global_rotation = Vector3(
			current_rotation.x,
			lerp_angle(current_rotation.y, target_rotation, rotation_y_lerp_multiplier * delta),
			current_rotation.z
		)
