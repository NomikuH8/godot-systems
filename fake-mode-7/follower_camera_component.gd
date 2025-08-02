extends Node

@export var to_follow: Node3D
@export var follow_offset: Vector3 = Vector3(0, 5, -10)
@export var lerp_weight: float = 5.0
@export var follow_rotation_y: bool = true

var parent: Camera3D

func _ready() -> void:
	parent = get_parent()
	parent.top_level = true


func _process(delta: float) -> void:
	var target_pos := to_follow.global_transform.origin + to_follow.global_transform.basis * follow_offset

	var current_pos := parent.global_position
	var new_pos := Vector3(
		lerpf(current_pos.x, target_pos.x, lerp_weight * delta),
		lerpf(current_pos.y, target_pos.y, (lerp_weight * 0.3) * delta),  # Y mais suave
		lerpf(current_pos.z, target_pos.z, lerp_weight * delta)
	)
	parent.global_position = new_pos

	if follow_rotation_y:
		var target_rotation := to_follow.global_rotation.y
		var current_rotation := parent.global_rotation
		parent.global_rotation = Vector3(
			current_rotation.x,
			lerp_angle(current_rotation.y, target_rotation, lerp_weight * delta),
			current_rotation.z
		)
