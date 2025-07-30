class_name AnimationComponent
extends Node


@export var from_center: bool = true
@export var time: float = 0.1
@export var transition_type: Tween.TransitionType
@export var hovered_position_offset: Vector2 = Vector2(125.0, 0.0)


var default_position: Vector2
var target: Control


func _ready() -> void:
	target = get_parent()
	
	connect_signals()
	call_deferred("setup")


func connect_signals() -> void:
	target.mouse_entered.connect(on_hover)
	target.mouse_exited.connect(off_hover)


func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_position = target.position


func on_hover() -> void:
	add_tween("position", default_position + hovered_position_offset, time)


func off_hover() -> void:
	add_tween("position", default_position, time)


func add_tween(property: String, value, seconds: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)
