class_name VehicleComponent
extends Node


@export var max_speed := 40.0
@export var acceleration_rate := 50.0
@export var deceleration_rate := 40.0
@export var turn_speed := 2.5
@export var lift_speed := 10.0
@export var friction := 1.0
@export var jump_force := 25.0
@export var strafe_speed := 10.5
@export var wall_bounce_force := 25.0
@export var wall_recovery_time := 0.8
@export var speed_damp_multiplier := 0.5
@export var rebound_damping := 1000.0

var parent: CharacterBody3D
var current_speed := 0.0
var velocity: Vector3 = Vector3.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_unstable := false
var unstable_timer := 0.0
var rebound_velocity: Vector3 = Vector3.ZERO
var rebound_force := 0.0
var jump_requested := false


func _ready() -> void:
	parent = get_parent()


func physics_step(delta: float) -> void:
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
	else:
		if jump_requested:
			parent.velocity.y = jump_force
			jump_requested = false
		else:
			parent.velocity.y = 0.0
	
	if is_unstable:
		unstable_timer -= delta
		if unstable_timer <= 0:
			recover_from_wall_collision()
	
	if is_unstable and rebound_force > 0.0:
		var rebound := rebound_velocity * rebound_force * delta
		parent.velocity.x = rebound.x
		parent.velocity.z = rebound.z
		rebound_force = maxf(rebound_force - rebound_damping * delta, 0.0)
	
	for i in parent.get_slide_collision_count():
		var collision = parent.get_slide_collision(i)
		if collision != null and collision.get_normal().y < 0.8:
			_apply_wall_collision(collision.get_normal())
	
	parent.move_and_slide()


func apply_movement(horizontal_velocity: Vector3, jump: bool) -> void:
	if not is_unstable:
		parent.velocity.x = horizontal_velocity.x
		parent.velocity.z = horizontal_velocity.z
	
	if jump and parent.is_on_floor():
		apply_jump()


func apply_jump():
	jump_requested = true


func _apply_wall_collision(normal: Vector3) -> void:
	if not is_unstable:
		var bounced := parent.velocity.bounce(normal).normalized()
		rebound_velocity = bounced
		rebound_force = current_speed * wall_bounce_force
		current_speed *= speed_damp_multiplier
		unstable_timer = wall_recovery_time
		is_unstable = true


func recover_from_wall_collision() -> void:
	is_unstable = false
	rebound_force = 0.0
	rebound_velocity = Vector3.ZERO
