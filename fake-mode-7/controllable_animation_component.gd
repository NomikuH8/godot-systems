class_name ControllableAnimationComponent
extends Node


@export var controllable_component: ControllableComponent
@export var vehicle_component: VehicleComponent
@export var sprite: Sprite3D
@export var animation_tree: AnimationTree

var playback: AnimationNodeStateMachinePlayback


func _ready() -> void:
	playback = animation_tree["parameters/playback"]


func _physics_process(_delta: float) -> void:
	var idle: bool = vehicle_component.current_speed <= 30.0
	animation_tree["parameters/conditions/idle"] = idle
	
	var going_forward: bool = vehicle_component.current_speed > 30.0
	animation_tree["parameters/conditions/going_forward"] = going_forward
	if controllable_component:
		if controllable_component.steer_input != 0.0:
			if controllable_component.steer_input > 0.2:
				animation_tree["parameters/conditions/turning"] = true
				playback.travel("turn")
				sprite.flip_h = true
			
			if controllable_component.steer_input < -0.2:
				animation_tree["parameters/conditions/turning"] = true
				playback.travel("turn")
				sprite.flip_h = false
		else:
			animation_tree["parameters/conditions/turning"] = false
		
	if idle and not animation_tree["parameters/conditions/turning"]:
		playback.travel("idle")
	if going_forward and not animation_tree["parameters/conditions/turning"]:
		if playback.get_current_node() != "go_forward":
			playback.travel("go_forward")
	
	var strafe_input := Input.get_axis(&"move_left", &"move_right")
	animation_tree["parameters/conditions/diagonal"] = absf(strafe_input) > 0.0
	if strafe_input < 0.0:
		playback.travel("diagonal")
		sprite.flip_h = true
	if strafe_input > 0.0:
		playback.travel("diagonal")
		sprite.flip_h = false
