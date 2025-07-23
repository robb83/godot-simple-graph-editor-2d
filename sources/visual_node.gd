extends Node2D
class_name VisualNode

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@export var color : Color = Color.WHITE : set = _set_color
@export var stroke_color : Color = Color.BLACK : set = _set_stroke_color
@export var stroke_hover_color : Color = Color.ORANGE : set = _set_stroke_hover_color
@export var size : int = 32 : set = _set_size
@export var text : String = "" : set = _set_text
@export var text_color : Color = Color.BLACK : set = _set_text_color
@export var font : SystemFont
@export var font_size = 10

var ports = []
var hover_active : bool = false : set = _set_hover_active

func add_port( vp:VisualPort ):
	if not ports.has(vp):
		ports.append(vp)
		vp.parent = self
		add_child(vp)

func get_nearest_port(pos:Vector2) -> VisualPort:
	var selected = null
	var distance = INF
	for p in ports:
		var d = (p.global_position - pos).length_squared()
		if distance > d:
			selected = p
			distance = d
	return selected

func _draw() -> void:
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var h = size / 2.0
	var hc = stroke_hover_color if hover_active else stroke_color
	draw_rect(Rect2(-h, -h, size, size), color, true)
	draw_rect(Rect2(-h, -h, size, size), hc, false, 1.0, false)
	draw_string(font, Vector2(-text_size.x / 2.0, text_size.y / 4.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

func _set_stroke_color(value:Color):
	stroke_color = value
	queue_redraw()

func _set_color(value:Color):
	color = value
	queue_redraw()

func _set_stroke_hover_color(value:Color):
	stroke_hover_color = value
	queue_redraw()
	
func _set_text(value:String):
	text = value
	queue_redraw()

func _set_text_color(value:Color):
	text_color = value
	queue_redraw()
	
func _set_size(value:float):
	size = value
	collision_shape_2d.shape.size = Vector2(size, size)
	queue_redraw()

func _set_hover_active(value:bool):
	if hover_active != value:
		hover_active = value
		queue_redraw()
