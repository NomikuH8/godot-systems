class_name ArtificialIntelligenceComponent
extends Node3D

#@export_category("Other Components")
@export var vehicle: VehicleComponent
@export var track: Path3D
@export var navigation_region: NavigationRegion3D
#
#@export_category("Variables")
#@export var detection_radius: float = 5.0
#@export var avoidance_strength: float = 1.5
#@export var overtaking_offset: float = 2.0
#@export var other_vehicles_group: StringName = "vehicle"
#
#@export_category("Randomization")
#@export var wander_strength: float = 0.2
#@export var wander_change_interval: float = 1.0
#
#@export_category("Raycast Avoidance")
#@export var ray_distance: float = 5.0
#@export var side_clearance: float = 2.0
#@export var forward_offset: float = 1.0
#@export var ray_collision_mask: int = 0xffffffff
#
#@export_category("Avoidance Persistence")
#@export var overtaking_persist_time: float = 0.8
#@export var obstacle_persist_time: float = 0.4
#
#var parent: CharacterBody3D
var steer_input := 0.0
#
#var wander_offset: Vector3 = Vector3.ZERO
#var wander_timer: float = 0.0
#var overtaking_side := 0
#var overtaking_timer := 0.0
#
#
#func _ready() -> void:
	#parent = get_parent()
#
#
#func _physics_process(delta: float) -> void:
	#wander_timer -= delta
	#if wander_timer <= 0.0:
		#wander_timer = wander_change_interval
		#var random_angle = randf_range(-PI, PI)
		#wander_offset = Vector3(cos(random_angle), 0, sin(random_angle)) * wander_strength
	#
	#var base_dir := get_nearest_direction(track.curve, parent.global_transform.origin) + (
		#track.curve.get_closest_point(parent.global_transform.origin) -
		#parent.global_transform.origin
	#).normalized() / 4.0
	#
	#base_dir += wander_offset
	#
	#var avoidance := get_avoidance_vector(delta)
	#var final_dir := (base_dir + avoidance * avoidance_strength).normalized()
	#
	#follow_direction(final_dir)
	#
	#if steer_input != 0.0:
		#parent.rotate_y(steer_input * vehicle.turn_speed * delta)
	#
	#if not vehicle.is_unstable:
		#vehicle.current_speed = minf(vehicle.current_speed + vehicle.acceleration_rate * delta, vehicle.max_speed)
	#else:
		#vehicle.current_speed = maxf(vehicle.current_speed - vehicle.deceleration_rate * delta, 0.0)
	#
	#var forward := -parent.transform.basis.z
	#var horizontal_velocity := forward * vehicle.current_speed
	#
	#vehicle.apply_movement(horizontal_velocity, false)
	#vehicle.physics_step(delta)
#
#
#func get_nearest_direction(curve: Curve3D, point: Vector3) -> Vector3:
	#var offset := curve.get_closest_offset(point)
	#var point_1 := curve.sample_baked(offset, true)
	#var point_2 := curve.sample_baked(offset + 0.5, true)
	#return (point_2 - point_1).normalized()
#
#
#func follow_direction(direction: Vector3):
	#var steering_target = parent.global_transform.origin + direction
	#var fwd = -parent.global_transform.basis.z
	#var target_vector = (steering_target - parent.global_transform.origin)
	#steer_input = fwd.cross(target_vector.normalized()).y
#
#
##func get_avoidance_vector() -> Vector3:
	##var avoidance := Vector3.ZERO
	##var fwd := -parent.global_transform.basis.z
	##for vehicle_node in get_tree().get_nodes_in_group(other_vehicles_group):
		##if vehicle_node == parent:
			##continue
		##var to_other: Vector3 = vehicle_node.global_transform.origin - parent.global_transform.origin
		##var dist := to_other.length()
		##if dist < detection_radius and fwd.dot(to_other.normalized()) > 0.5:
			##var side = signf(fwd.cross(to_other).y)
			##avoidance += (parent.global_transform.basis.x * side * overtaking_offset) / maxf(dist, 0.1)
	##return avoidance
#
#
#func ray_clear(from_pos: Vector3, to_pos: Vector3, exclude: Array = []) -> bool:
	#var space := get_world_3d().direct_space_state
	#var query := PhysicsRayQueryParameters3D.create(from_pos, to_pos, ray_collision_mask, exclude)
	#var result := space.intersect_ray(query)
	#return result.is_empty()
#
#
#func get_avoidance_vector(delta: float) -> Vector3:
	#var avoidance := Vector3.ZERO
	#var fwd := (-parent.global_transform.basis.z).normalized()
	#var right := parent.global_transform.basis.x.normalized()
	#var origin := parent.global_transform.origin + fwd * forward_offset
	#var exclude := [parent]
#
	#var detected_side := 0
	#var is_vehicle := false
	#
	#if vehicle.is_unstable:
		#return Vector3.ZERO
#
	## --- 1. Detecta adversários ---
	#for vehicle_node in get_tree().get_nodes_in_group(other_vehicles_group):
		#if vehicle_node == parent:
			#continue
		#
		#var to_other: Vector3 = vehicle_node.global_transform.origin - parent.global_transform.origin
		#var dist := to_other.length()
		#if dist < detection_radius and fwd.dot(to_other.normalized()) > 0.5:
			#is_vehicle = true
			#detected_side = -1 if signf(fwd.cross(to_other).y) > 0 else 1
			#exclude.append(vehicle_node)
			#break
#
	## --- 2. Detecta obstáculos estáticos ---
	#if detected_side == 0:
		#var front_hit := ray_clear(origin, origin + fwd * ray_distance, exclude)
		#if not front_hit:
			#detected_side = -1 if randf() > 0.5 else 1
#
	## --- 3. Persistência da ultrapassagem/desvio ---
	#if detected_side != 0:
		#if overtaking_side == 0:
			#overtaking_side = detected_side
		#overtaking_timer = overtaking_persist_time if is_vehicle else obstacle_persist_time
	#else:
		#if overtaking_timer > 0:
			#overtaking_timer -= delta
		#else:
			#overtaking_side = 0
#
	## --- 4. Aplica desvio se houver lado ativo e espaço livre ---
	#if overtaking_side != 0:
		#var side_vec := right if overtaking_side > 0 else -right
		#var side_target := origin + side_vec * side_clearance + fwd * ray_distance
		#if ray_clear(origin, side_target, exclude):
			#avoidance += side_vec * overtaking_offset
#
	#return avoidance


@export var waypoints: Array = []
@export var samples = 20

var parent: CharacterBody3D
var current_waypoint_index := 0
var navigation_agent: NavigationAgent3D
var path_node: Path3D
var t := 0.0


func _ready() -> void:
	parent = get_parent()
	waypoints = get_waypoints_from_path(path_node, samples)
	navigation_agent = NavigationAgent3D.new()
	add_child(navigation_agent)
	navigation_agent.target_position = waypoints[current_waypoint_index]

func _physics_process(delta: float) -> void:
	var curve := track.curve
	if curve == null:
		return
	
	if navigation_agent.is_navigation_finished():
		current_waypoint_index += 1
		if current_waypoint_index >= waypoints.size():
			current_waypoint_index = 0  # Loop
		navigation_agent.target_position = waypoints[current_waypoint_index]
	
	var base_dir := get_nearest_direction(track.curve, parent.global_transform.origin) + (
		track.curve.get_closest_point(parent.global_transform.origin) -
		parent.global_transform.origin
	).normalized() / 4.0
	
	var final_dir := base_dir.normalized()
	
	follow_direction(final_dir)
	
	if steer_input != 0.0:
		parent.rotate_y(steer_input * vehicle.turn_speed * delta)

	# Avança ao longo do caminho com base na velocidade e no comprimento da curva
	var path_length := curve.get_baked_length()
	var distance_to_move := vehicle.current_speed * delta
	var distance_covered := t * path_length + distance_to_move

	# Atualiza o parâmetro t (normalizado)
	t = clampf(distance_covered / path_length, 0, 1)

	# Pega a posição na curva para o parâmetro t
	var target_pos := curve.sample_baked(t * path_length)

	# Move o carro em direção ao target_pos
	var direction := (target_pos - global_transform.origin).normalized()
	#var next_point := navigation_agent.get_next_path_position()
	#var horizontal_velocity := direction * vehicle.current_speed
	
	if not vehicle.is_unstable:
		vehicle.current_speed = minf(vehicle.current_speed + vehicle.acceleration_rate * delta, vehicle.max_speed)
	else:
		vehicle.current_speed = maxf(vehicle.current_speed - vehicle.deceleration_rate * delta, 0.0)
	
	var forward := -parent.transform.basis.z
	var horizontal_velocity := forward * vehicle.current_speed
	
	vehicle.apply_movement(horizontal_velocity, false)
	vehicle.physics_step(delta)


func get_nearest_direction(curve: Curve3D, point: Vector3) -> Vector3:
	var offset := curve.get_closest_offset(point)
	var point_1 := curve.sample_baked(offset, true)
	var point_2 := curve.sample_baked(offset + 0.5, true)
	return (point_2 - point_1).normalized()


func follow_direction(direction: Vector3):
	var steering_target = parent.global_transform.origin + direction
	var fwd = -parent.global_transform.basis.z
	var target_vector = (steering_target - parent.global_transform.origin)
	steer_input = fwd.cross(target_vector.normalized()).y


func get_waypoints_from_path(path_node: Path3D, samples: int) -> Array:
	var waypoints = []
	var curve = track.curve
	if curve == null:
		return waypoints

	var path_length = curve.get_baked_length()
	for i in range(samples + 1):
		var distance = (i / samples) * path_length
		var point = curve.sample_baked(distance)
		waypoints.append(point)
	return waypoints
#func get_waypoint_position():
	#return get_node(waypoints[current_waypoint_index]).global_transform.origin
