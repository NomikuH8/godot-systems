extends Node2D

class_name RoadDrawer

@export var segment_length := 200.0
@export var num_segments := 1000
@export var road_width := 800.0
@export var camera_height := 1000.0
@export var camera_depth := 1.0
@export var player_z := 0.0
@export var draw_distance := 300

var segments = []

func _ready():
	_generate_road()

func _generate_road():
	segments.clear()
	for i in range(num_segments):
		var segment := RoadSegment.new()
		segment.curve = sin(i * 0.1) * 2.0
		#segment.y = sin(i * 0.05) * 50.0
		segment.y = 500.0
		segments.append(segment)

func _draw():
	var base_y = get_viewport_rect().size.y
	var screen_center = get_viewport_rect().size.x / 2
	var pos_z = player_z

	var dx = 0.0

	for n in range(draw_distance):
		var i = roundi(pos_z + n) % num_segments
		var segment = segments[i]

		var p1 = _project_segment(n, dx, segment.y)
		dx += segment.curve

		var i_next = roundi(pos_z + n + 1) % num_segments
		var segment_next = segments[i_next]
		var p2 = _project_segment(n + 1, dx, segment_next.y)

		_draw_segment(p1, p2, screen_center)

func _project_segment(index: int, dx: float, y: float) -> Dictionary:
	var z = index * segment_length
	var scale = camera_depth / z if z != 0 else 1.0
	return {
		"x": dx,
		"y": y,
		"screen_y": get_viewport_rect().size.y / 2 + y * scale,
		"scale": scale,
		"road_width": road_width * scale
	}

func _draw_segment(p1: Dictionary, p2: Dictionary, center: float):
	var road_color = Color(0.1, 0.1, 0.1)
	var grass_color = Color(0.0, 0.6, 0.0)

	var x1 = center + p1["x"] * p1["scale"]
	var x2 = center + p2["x"] * p2["scale"]
	var y1 = p1["screen_y"]
	var y2 = p2["screen_y"]

	var w1 = p1["road_width"]
	var w2 = p2["road_width"]

	# Grass
	draw_rect(Rect2(0, y2, get_viewport_rect().size.x, y1 - y2), grass_color)

	# Road
	draw_polygon(
		[
			Vector2(x1 - w1 / 2, y1),
			Vector2(x1 + w1 / 2, y1),
			Vector2(x2 + w2 / 2, y2),
			Vector2(x2 - w2 / 2, y2),
		],
		[road_color]
	)

func update_player_z(delta: float, speed: float):
	player_z += speed * delta
	if player_z >= num_segments:
		player_z -= num_segments

	queue_redraw()
