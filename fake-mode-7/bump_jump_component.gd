extends Node


@export var jump_force: float = 25.0

var parent: Area3D


func _ready() -> void:
	parent = get_parent()
	parent.body_shape_entered.connect(_parent_body_shape_entered)


func _parent_body_shape_entered(
	_body_rid: RID,
	body: Node3D,
	_body_shape_index: int,
	_local_shape_index: int
) -> void:
	var vehicle_component: VehicleComponent
	for child in body.get_children(true):
		if child is VehicleComponent:
			vehicle_component = child
			break
	
	if vehicle_component == null:
		return
	
	vehicle_component.jump_force = jump_force
	vehicle_component.apply_jump()
