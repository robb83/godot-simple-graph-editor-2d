extends Node2D
class_name VisualEdge

@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var port_a : VisualPort = null
var port_b : VisualPort = null
var hover_active : bool = false : set = _set_hover_active

func _draw():
	var s = port_a.global_position
	var t = port_b.global_position
	var points = Utils.get_bezier_curve(s, t)
	var box = get_bounding_box(points)
	
	area_2d.position = s + ((t - s) / 2.0)
	collision_shape_2d.shape.size = box.size
	
	draw_polyline(points, Color.RED if hover_active else Color(0, 1, 1, 1))

func get_bounding_box(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()

	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y

	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)

	var position = Vector2(min_x, min_y)
	var size = Vector2(max_x - min_x, max_y - min_y)
	if size.x < 10:
		var grow = (10 - size.x) / 2.0
		size.x += grow
		position.x -= grow

	if size.y < 10:
		var grow = (10 - size.y) / 2.0
		size.y += grow
		position.y -= grow
	return Rect2(position, size)

func _set_hover_active(value:bool):
	if hover_active != value:
		hover_active = value
		queue_redraw()
