extends Node

@export var max_speed := 50.0
@export var acceleration_rate := 50.0
@export var deceleration_rate := 40.0
@export var turn_speed := 2.5
@export var lift_speed := 10.0
@export var friction := 1.0
@export var jump_force := 30.0
@export var strafe_speed := 10.5
@export var wall_bounce_force := 25.0
@export var wall_recovery_time := 0.8
@export var control_damp_multiplier := 0.3
@export var speed_damp_multiplier := 0.5

var current_speed := 0.0
var velocity: Vector3 = Vector3.ZERO
var parent: CharacterBody3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_unstable := false
var unstable_timer := 0.0
var rebound_velocity: Vector3 = Vector3.ZERO
var rebound_force := 0.0
var rebound_damping := 1000.0

func _ready() -> void:
	parent = get_parent()


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("accelerate") and not is_unstable:
		current_speed = minf(current_speed + acceleration_rate * delta, max_speed)
	else:
		current_speed = maxf(current_speed - deceleration_rate * delta, 0)
	
	if is_unstable:
		current_speed = lerpf(current_speed, 0, deceleration_rate * delta)
	
	var forward := -parent.transform.basis.z
	var side := parent.transform.basis.x
	
	var strafe_input := Input.get_axis("move_left", "move_right")
	var strafe_velocity := side * (strafe_input * strafe_speed)
	
	if not is_unstable:
		var horizontal_velocity := forward * current_speed + strafe_velocity
		
		if not parent.is_on_floor():
			parent.velocity.y -= gravity * delta
		else:
			parent.velocity.y = 0.0
		
		if parent.is_on_floor() and Input.is_action_just_pressed("go_up"):
			parent.velocity.y = jump_force
		
		parent.velocity.x = horizontal_velocity.x
		parent.velocity.z = horizontal_velocity.z
	elif is_unstable and rebound_force > 0:
		var rebound := rebound_velocity * rebound_force * delta
		parent.velocity.x = rebound.x
		parent.velocity.z = rebound.z
		
		rebound_force = maxf(rebound_force - rebound_damping * delta, 0.0)
	
	var steer_input := 0.0
	if Input.is_action_pressed(&"turn_left"):
		steer_input += 1.0
	if Input.is_action_pressed(&"turn_right"):
		steer_input -= 1.0
	
	if steer_input != 0:
		parent.rotate_y(steer_input * turn_speed * delta)
	
	if is_unstable:
		unstable_timer -= delta
		if unstable_timer <= 0:
			_recover_from_wall_collision()
	for i in parent.get_slide_collision_count():
		var collision = parent.get_slide_collision(i)
		if collision != null and collision.get_normal().y < 0.8:
			_apply_wall_collision(collision.get_normal())
	
	parent.move_and_slide()


func _apply_wall_collision(normal: Vector3) -> void:
	if not is_unstable:
		var bounced := parent.velocity.bounce(normal).normalized()
		
		rebound_velocity = bounced
		rebound_force = current_speed * wall_bounce_force
		current_speed *= speed_damp_multiplier
		
		unstable_timer = wall_recovery_time
		is_unstable = true


func _recover_from_wall_collision() -> void:
	is_unstable = false
	rebound_force = 0.0
	rebound_velocity = Vector3.ZERO
