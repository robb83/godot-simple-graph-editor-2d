extends Node2D
class_name VisualPort

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@export var color : Color = Color.WHITE : set = _set_color
@export var stroke_hover_color : Color = Color.ORANGE : set = _set_stroke_hover_color
@export var stroke_color : Color = Color.BLACK : set = _set_stroke_color
@export var radius : int = 6 : set = _set_radius
@export var text : String = "" : set = _set_text
@export var text_pos : Enums.TextPosition = Enums.TextPosition.CENTER : set = _set_text_pos
@export var text_color : Color = Color.WHITE : set = _set_text_color
@export var text_padding : int = 3
@export var font : SystemFont
@export var font_size : int = 10
@export var multiple_connection : bool = true
@export var direction : Enums.VisualPortDirection = Enums.VisualPortDirection.INPUT_OUTPUT

var parent : VisualNode = null
var hover_active : bool = false : set = _set_hover_active

func _draw() -> void:
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var hc = stroke_hover_color if hover_active else stroke_color
	
	draw_circle(Vector2(0, 0), radius, color, true)
	draw_circle(Vector2(0, 0), radius, hc, false, 1.0, false)
	
	match text_pos:
		Enums.TextPosition.TOP:
			draw_string(font, Vector2(-text_size.x / 2.0, -(radius + text_padding)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
		Enums.TextPosition.RIGHT:
			draw_string(font, Vector2((radius + text_padding), (text_size.y - radius) / 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
		Enums.TextPosition.BOTTOM:
			draw_string(font, Vector2(-text_size.x / 2.0, (radius + text_padding + text_size.y)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
		Enums.TextPosition.LEFT:
			draw_string(font, Vector2(-(text_size.x + radius + text_padding), (text_size.y - radius) / 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
		Enums.TextPosition.CENTER:
			draw_string(font, Vector2(-text_size.x / 2.0, (text_size.y - radius) / 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

func _set_text(value:String):
	text = value
	queue_redraw()

func _set_radius(value:int):
	radius = value
	collision_shape_2d.shape.radius = radius
	queue_redraw()
	
func _set_text_color(value:String):
	text_color = value
	queue_redraw()

func _set_hover_active(value:bool):
	if hover_active != value:
		hover_active = value
		queue_redraw()

func _set_color(value:Color):
	color = value
	queue_redraw()
	
func _set_stroke_color(value:Color):
	stroke_color = value
	queue_redraw()
	
func _set_stroke_hover_color(value:Color):
	stroke_hover_color = value
	queue_redraw()

func _set_text_pos(value:Enums.TextPosition):
	text_pos = value
	queue_redraw()
