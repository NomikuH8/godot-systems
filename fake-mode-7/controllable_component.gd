class_name ControllableComponent
extends Node

@export var can_jump := false
@export var control_damp_multiplier := 0.3
@export var drift_threshold_speed := 20.0
@export var drift_strength := 0.8
@export var drift_decay := 30.0

var vehicle: VehicleComponent
var drift_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	vehicle = get_parent().get_node_or_null("VehicleComponent")


func _physics_process(delta: float) -> void:
	if vehicle == null:
		return
	
	var parent := vehicle.parent
	var forward := -parent.transform.basis.z
	var side := parent.transform.basis.x
	
	if Input.is_action_pressed("accelerate") and not vehicle.is_unstable:
		vehicle.current_speed = minf(vehicle.current_speed + vehicle.acceleration_rate * delta, vehicle.max_speed)
	else:
		vehicle.current_speed = maxf(vehicle.current_speed - vehicle.deceleration_rate * delta, 0.0)
	
	if vehicle.is_unstable:
		vehicle.current_speed = lerpf(vehicle.current_speed, 0.0, vehicle.deceleration_rate * delta)
	
	var strafe_input := Input.get_axis("move_left", "move_right")
	var strafe_velocity := side * (strafe_input * vehicle.strafe_speed)
	
	var steer_input := 0.0
	if Input.is_action_pressed("turn_left"):
		steer_input += 1.0
	if Input.is_action_pressed("turn_right"):
		steer_input -= 1.0
	
	if steer_input != 0.0:
		parent.rotate_y(steer_input * vehicle.turn_speed * delta)
	
	# Drifting
	if abs(steer_input) > 0.0 and vehicle.current_speed > drift_threshold_speed and not vehicle.is_unstable:
		var drift_dir := side * steer_input
		drift_velocity = drift_velocity.lerp(drift_dir * vehicle.current_speed * drift_strength, delta * 3.0)
	else:
		drift_velocity = drift_velocity.lerp(Vector3.ZERO, drift_decay * delta)
	
	var horizontal_velocity := forward * vehicle.current_speed + strafe_velocity + drift_velocity
	var jump := Input.is_action_pressed("go_up") if can_jump else false
	
	vehicle.apply_movement(horizontal_velocity, jump)
	
	if vehicle.is_unstable and Input.is_action_just_pressed("accelerate"):
		vehicle.recover_from_wall_collision()
	
	vehicle.physics_step(delta)
