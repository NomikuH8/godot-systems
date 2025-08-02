extends Node3D


const STEER_SPEED =

var _steer_target := 0.0


func _physics_process(delta: float) -> void:
	_steer_target = Input.get_axis(&"turn_right", &"turn_left")
	
