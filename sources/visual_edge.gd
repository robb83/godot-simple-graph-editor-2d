extends Node2D
class_name VisualEdge

@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var port_a : VisualPort = null
var port_b : VisualPort = null
var hover_active : bool = false : set = _set_hover_active
var points : PackedVector2Array = []

func is_near(point : Vector2, threshold := 2.0):
	return Utils.is_mouse_near_polyline(point, points, threshold)
	
func _draw():
	var s = port_a.global_position
	var t = port_b.global_position
	
	points = Utils.get_bezier_curve(s, t)
	var box = Utils.get_bounding_box(points, 12.0)
	
	area_2d.position = (s + t) / 2.0
	collision_shape_2d.shape.size = box.size
	
	draw_polyline(points, Color.RED if hover_active else Color(0, 1, 1, 1))

func _set_hover_active(value:bool):
	if hover_active != value:
		hover_active = value
		queue_redraw()
