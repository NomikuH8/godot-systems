class_name ArtificialIntelligenceComponent
extends Node3D

@export var vehicle: VehicleComponent
@export var track: Path3D

var parent: CharacterBody3D
var steer_input := 0.0


func _ready() -> void:
	parent = get_parent()


func _physics_process(delta: float) -> void:
	follow_direction(
		get_nearest_direction(track.curve, parent.global_transform.origin) +
		(
			track.curve.get_closest_point(parent.global_transform.origin) -
			parent.global_transform.origin
		).normalized() / 4.0
	)
	
	if steer_input != 0.0:
		parent.rotate_y(steer_input * vehicle.turn_speed * delta)
	
	if not vehicle.is_unstable:
		vehicle.current_speed = minf(vehicle.current_speed + vehicle.acceleration_rate * delta, vehicle.max_speed)
	else:
		vehicle.current_speed = maxf(vehicle.current_speed - vehicle.deceleration_rate * delta, 0.0)
	
	var forward := -parent.transform.basis.z
	var horizontal_velocity := forward * vehicle.current_speed
	
	vehicle.apply_movement(horizontal_velocity, false)
	vehicle.physics_step(delta)


func get_nearest_direction(curve : Curve3D, point : Vector3) -> Vector3:
	var offset := curve.get_closest_offset( point )
	var point_1 := curve.sample_baked( offset, true )
	var point_2 := curve.sample_baked( offset + 0.5, true )
	var direction : Vector3 = ( point_2 - point_1 ).normalized()
	return direction


func follow_direction(direction: Vector3):
	var steering_target = parent.global_transform.origin + direction
	var fwd = -parent.global_transform.basis.z
	var target_vector = (steering_target - parent.global_transform.origin)
	steer_input = fwd.cross(target_vector.normalized()).y
