extends Camera2D

const ZOOM_STEP := Vector2(0.1, 0.1)
const MIN_ZOOM := Vector2(0.5, 0.5)
const MAX_ZOOM := Vector2(5, 5)

var dragging := false
var last_mouse_position := Vector2.ZERO

func _input(event):
	if Input.is_action_just_pressed("mclick"):
		dragging = true
		last_mouse_position = event.position
		
	if Input.is_action_just_released("mclick"):
		dragging = false
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-ZOOM_STEP, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(ZOOM_STEP, event.position)

	elif event is InputEventMouseMotion and dragging:
		var delta : Vector2 = (event.position - last_mouse_position) / zoom
		global_position -= delta
		last_mouse_position = event.position

# https://github.com/Eranot/schemer/blob/main/scene/screen/main/main_camera.gd
func _zoom(delta: Vector2, mouse_pos: Vector2):
	var new_zoom := (zoom + delta).clamp(MIN_ZOOM, MAX_ZOOM)
	if new_zoom == zoom:
		return
	var mouse_world_before := get_global_mouse_position()
	var direction = (mouse_world_before - self.global_position)
	var new_position = self.global_position + direction - ((direction) / (new_zoom/zoom))
	
	self.zoom = new_zoom
	self.global_position = new_position
