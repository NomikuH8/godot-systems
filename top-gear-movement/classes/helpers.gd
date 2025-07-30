class_name Helpers
extends Node

static func project(camera_z: float, segment_z: float, screen_height: float) -> float:
	var dz = segment_z - camera_z
	if dz == 0: dz = 0.0001
	return screen_height / dz

static func clamp(value: float, min_val: float, max_val: float) -> float:
	return max(min_val, min(value, max_val))
