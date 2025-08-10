class_name ControllableComponent
extends Node


@export_category("Other Components")
@export var vehicle: VehicleComponent
#@export var follower_camera: FollowerCameraComponent
@export var steering_particles: GPUParticles3D
@export var can_jump := false
@export var control_damp_multiplier := 0.3
@export var drift_threshold_speed := 20.0
@export var drift_strength := 0.8
@export var drift_decay := 6.0

#const STEERING_ROTATION_MULTIPLIER := 5.0

var steer_input: float
var drift_velocity: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if vehicle == null:
		return
	
	var parent := vehicle.parent
	var side := parent.transform.basis.x
	
	if Input.is_action_pressed("accelerate") and not vehicle.is_unstable:
		vehicle.current_speed = minf(vehicle.current_speed + vehicle.acceleration_rate * delta, vehicle.max_speed)
	else:
		vehicle.current_speed = maxf(vehicle.current_speed - vehicle.deceleration_rate * delta, 0.0)
	
	#if vehicle.is_unstable:
		#vehicle.current_speed = lerpf(vehicle.current_speed, 0.0, vehicle.deceleration_rate * delta)
	
	var strafe_input := Input.get_axis("move_left", "move_right")
	var strafe_velocity := side * (strafe_input * vehicle.strafe_speed)
	
	steer_input = 0.0
	var turn_input_axis := Input.get_axis("turn_right", "turn_left")
	if turn_input_axis >= 0.2:
		steer_input = 1.0
	if turn_input_axis <= -0.2:
		steer_input = -1.0
	
	if steering_particles:
		steering_particles.emitting = (
			absf(steer_input) > 0.2 and
			vehicle.current_speed >= 30.0 and
			parent.is_on_floor()
		)
	
	if steer_input != 0.0:
		# Uncomment if you want the camera to rotate with steering
		#follower_camera.rotation_y_offset = steer_input * _STEERING_ROTATION_MULTIPLIER
		parent.rotate_y(steer_input * vehicle.turn_speed * delta)
	
	# Drifting
	if abs(steer_input) > 0.0 and vehicle.current_speed > drift_threshold_speed and not vehicle.is_unstable:
		var drift_dir := side * steer_input
		drift_velocity = drift_velocity.lerp(drift_dir * vehicle.current_speed * drift_strength, delta * 3.0)
	else:
		var decay_rate := drift_decay
		if vehicle.current_speed < drift_threshold_speed:
			decay_rate *= 0.5
		drift_velocity = drift_velocity.lerp(Vector3.ZERO, decay_rate * delta)
	
	var forward := -parent.transform.basis.z
	var horizontal_velocity := forward * vehicle.current_speed + strafe_velocity + drift_velocity
	var jump := Input.is_action_pressed("go_up") if can_jump else false
	
	vehicle.apply_movement(horizontal_velocity, jump)
	
	if vehicle.is_unstable and Input.is_action_just_pressed("accelerate"):
		vehicle.recover_from_wall_collision()
	
	vehicle.physics_step(delta)
