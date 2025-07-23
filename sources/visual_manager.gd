extends Node2D

@onready var container: Node2D = $Container
@onready var control: Control = $CanvasLayer/Control
@onready var line_edit: LineEdit = $CanvasLayer/Control/MarginContainer/HBoxContainer/LineEdit
@onready var edge_container: Node2D = $EdgeContainer

var resource_node : Resource = preload("res://visual_node.tscn")
var resource_port : Resource = preload("res://visual_port.tscn")
var resource_edge : Resource = preload("res://visual_edge.tscn")

var edges := []
var nodes := []
var connections := {}
var port_edge := {}

var selected_node : VisualNode = null
var selected_port : VisualPort = null
var hover_port : VisualPort = null
var hover_node : VisualNode = null
var hover_edge : VisualEdge = null
var hover_effect_applied := []
var edit_node : VisualNode = null
var edit_port : VisualPort = null
var name_counter : int = -1

var last_click_time := 0.0
const DOUBLE_CLICK_DELAY := 0.3

func _ready():
	#create_test()
	create_node_alt_1(Vector2(-80, 0), "A001")
	create_node_alt_2(Vector2(80, 0), "B002")
	
func create_test():
	var offset = Vector2(1000, 1000)
	var previous = null
	for x in range(20):
		for y in range(20):
			var current = create_node_alt_2(Vector2(x * 100, y * 100) - offset, _get_next_name())
			if previous:
				connect_to(previous.ports[0], current.ports[3])
			previous = current
	
func _draw():
	if selected_port:
		var t = get_global_mouse_position()
		var s = selected_port.global_position
		_draw_bezier_curve(s, t, Color.DEEP_PINK)
	
func _process(_delta):
	#TODO: redraw only when needed
	queue_redraw()

func create_edge(a: VisualPort, b: VisualPort):
	var edge = resource_edge.instantiate()
	edge.port_a = a
	edge.port_b = b
	edge_container.add_child(edge)
	return edge
	
func create_port(node : VisualNode, label : String, label_pos : Enums.TextPosition, pos : Vector2, direction : Enums.VisualPortDirection, multiple_connection : bool = true):
	var port = resource_port.instantiate()
	port.multiple_connection = multiple_connection
	port.direction = direction
	port.text = label
	port.text_pos = label_pos
	port.position = pos
	match direction:
		Enums.VisualPortDirection.INPUT:
			port.color = Color.ORANGE_RED
		Enums.VisualPortDirection.OUTPUT:
			port.color = Color.DODGER_BLUE
		Enums.VisualPortDirection.INPUT_OUTPUT:	
			port.color = Color.WHITE
	node.add_port(port)
	return port
	
func create_node(pos: Vector2, label_text: String):
	if randi_range(0, 10) < 3:
		return create_node_alt_2(pos, label_text)
	else:
		return create_node_alt_1(pos, label_text)
	
func create_node_alt_1(pos: Vector2, label_text: String):
	var size = 32
	var padding = 2
	
	var node = resource_node.instantiate()
	node.position = pos
	node.text = label_text
	
	var port_top = create_port(node, "TOP", Enums.TextPosition.TOP, Vector2(0, -(size + padding)), Enums.VisualPortDirection.INPUT_OUTPUT, true)
	var port_right = create_port(node , "RHT", Enums.TextPosition.RIGHT, Vector2( (size + padding), 0), Enums.VisualPortDirection.INPUT_OUTPUT, true)
	var port_bottom = create_port(node, "BTM", Enums.TextPosition.BOTTOM, Vector2(0, (size + padding)), Enums.VisualPortDirection.INPUT_OUTPUT, true)
	var port_left = create_port(node, "LFT", Enums.TextPosition.LEFT, Vector2( -(size + padding), 0), Enums.VisualPortDirection.INPUT_OUTPUT, true)
	
	nodes.append(node)
	container.add_child(node)
	return node
	
func create_node_alt_2(pos: Vector2, label_text: String):
	var size = 32
	var padding = 2
	
	var node = preload("res://visual_node.tscn").instantiate()
	node.position = pos
	node.text = label_text
	
	var port_right_1 = create_port(node , "R1", Enums.TextPosition.RIGHT, Vector2( (size + padding), -12), Enums.VisualPortDirection.OUTPUT, true)
	var port_right_2 = create_port(node , "R2", Enums.TextPosition.RIGHT, Vector2( (size + padding), 12), Enums.VisualPortDirection.OUTPUT, true)
	var port_left_1 = create_port(node, "L1", Enums.TextPosition.LEFT, Vector2( -(size + padding), -12), Enums.VisualPortDirection.INPUT, false)
	var port_left_2 = create_port(node, "L2", Enums.TextPosition.LEFT, Vector2( -(size + padding), 12), Enums.VisualPortDirection.INPUT, false)
	
	nodes.append(node)
	container.add_child(node)
	return node

func _start_rename():
	if edit_node:
		line_edit.text = edit_node.text
		line_edit.grab_focus()
		line_edit.select_all()
		control.visible = true
	elif edit_port:
		line_edit.text = edit_port.text
		line_edit.grab_focus()
		line_edit.select_all()
		control.visible = true
	else:
		line_edit.text = ""
		control.visible = false

func _cancel_rename():
	edit_node = null
	edit_port = null
	line_edit.text = ""
	control.visible = false
	
func _on_line_edit_text_submitted(new_text: String) -> void:
	if edit_node:
		edit_node.text = new_text
		edit_node = null
	if edit_port:
		edit_port.text = new_text
		edit_port = null
	line_edit.text = ""
	control.visible = false

func _export_graph():
	print("nodes:")
	for n in nodes:
		var nps = n.ports
		print("name = %s" % n.text)
		#for np in nps:
			#print("\tport = %s" % np.text)
	print("edges:")
	for e in edges:
		print("%s.%s = %s.%s" % [e.port_a.parent.text, e.port_a.text, e.port_b.parent.text, e.port_b.text])
		
	var components = Utils.find_connected_components(nodes, edges)
	print("components = %d" % components.size())

func connect_to(vp1 : VisualPort, vp2 : VisualPort):
	if vp1 == vp2:
		return
	if connections.has(vp1) and connections[vp1].has(vp2):
		return
	if connections.has(vp2) and connections[vp2].has(vp1):
		return
	if vp1.direction != Enums.VisualPortDirection.INPUT_OUTPUT and vp2.direction != Enums.VisualPortDirection.INPUT_OUTPUT and vp1.direction == vp2.direction:
		return
	if not vp1.multiple_connection:
		remove_port(vp1)
	if not vp2.multiple_connection:
		remove_port(vp2)
		
	if not connections.has(vp1): connections[vp1] = []
	if not connections.has(vp2): connections[vp2] = []
	if not port_edge.has(vp1): port_edge[vp1] = []
	if not port_edge.has(vp2): port_edge[vp2] = []
	
	var edge = create_edge(vp1, vp2)
	
	connections[vp1].append(vp2)
	connections[vp2].append(vp1)
	port_edge[vp1].append(edge)
	port_edge[vp2].append(edge)
	
	edges.append(edge)

func remove_node(node : VisualNode):
	var to_remove = []
	for p in node.ports:
		if port_edge.has(p):
			for e in port_edge[p]:
				to_remove.append(e)
	for r in to_remove:
		remove_edge(r)
	
	nodes.erase(node)
	node.queue_free()

func remove_port(port : VisualPort):
	if port_edge.has(port):
		var to_remove = []	
		for e in port_edge[port]:
			to_remove.append(e)
		for r in to_remove:
			remove_edge(r)
		
func remove_edge(edge):
	var vp1 = edge.port_a
	var vp2 = edge.port_b
	if connections.has(vp1): connections[vp1].erase(vp2)
	if connections.has(vp2): connections[vp2].erase(vp1)
	if port_edge.has(vp1): port_edge[vp1].erase(edge)
	if port_edge.has(vp2): port_edge[vp2].erase(edge)
	edges.erase(edge)
	edge.queue_free()

func _handle_mouse_hover_edge(mouse_pos : Vector2):
	if hover_edge:
		hover_edge.hover_active = false
		hover_edge = null
		
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = mouse_pos
	query.collision_mask = 1 << 1
	var result = space_state.intersect_point(query)
	for r in result:
		var parent = r.collider.owner
		if is_instance_of(parent, VisualEdge):
			var from = parent.port_a.global_position
			var to = parent.port_b.global_position
			if Utils.is_mouse_near_bezier(mouse_pos, from, to):
				hover_edge = parent
				break
				
	if hover_edge:
		hover_edge.hover_active = true
	
func _handle_mouse_hover_node_port(mouse_pos : Vector2):
	#TODO: consider rewirte Area2D.area_entered / Area2Darea_exited
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = mouse_pos
	var result = space_state.intersect_point(query)
	
	if hover_node: 
		hover_node.hover_active = false
		hover_node = null
	if hover_port: 
		hover_port.hover_active = false
		hover_port = null
	
	var current_hover_node = hover_node
	var current_hover_node_changed = false
	var current_hover_port = hover_port
	var current_hover_port_changed = false
	
	for r in result:
		var parent = r.collider.owner
		if is_instance_of(parent, VisualPort):
			if current_hover_port:
				current_hover_port.hover_active = false
			current_hover_port = parent
			current_hover_port.hover_active = true
			current_hover_port_changed = true
		if is_instance_of(parent, VisualNode):
			if current_hover_node:
				current_hover_node.hover_active = false
			current_hover_node = parent
			current_hover_node.hover_active = true
			current_hover_node_changed = true
	
	if not current_hover_port_changed and current_hover_port:
		current_hover_node.hover_active = false
		current_hover_node = null
	
	if not current_hover_node_changed and current_hover_node:
		current_hover_node.hover_active = false
		current_hover_node = null
		
	hover_port = current_hover_port
	hover_node = current_hover_node

func _create_node_at_mouse(port:VisualPort, mouse_pos : Vector2):
	var n = create_node(mouse_pos, _get_next_name())
	var np = n.get_nearest_port(port.global_position)
	if np:
		connect_to(port, np)
	return n

func _move_selected_node(node: VisualNode, mouse_pos : Vector2):
	if node:
		node.global_position = mouse_pos
		for p in node.ports:
			if port_edge.has(p):
				for e in port_edge[p]:
					e.queue_redraw()
	
func _handle_hover_effect_on_edges():
	for e in hover_effect_applied:
		e.hover_active = false
	hover_effect_applied.clear()
	
	if hover_node:
		for p in hover_node.ports:
			if port_edge.has(p):
				for e in port_edge[p]:
					hover_effect_applied.append(e)
					e.hover_active = true
	elif hover_port:
		if port_edge.has(hover_port):
			for e in port_edge[hover_port]:
				hover_effect_applied.append(e)
				e.hover_active = true
	elif hover_edge:
		pass
	
func _input(event: InputEvent) -> void:
	
	var now = Time.get_ticks_msec() / 1000.0
	var mouse_pos = get_global_mouse_position()
	
	if event is InputEventMouse:
		_handle_mouse_hover_node_port(mouse_pos)
	
	if Input.is_action_just_pressed("cancel"):
		_cancel_rename()
		
	if Input.is_action_just_pressed("export"):
		_export_graph()
	
	if Input.is_action_just_released("lclick"):
		if selected_port != null and hover_port and hover_port != selected_port:
			connect_to(selected_port, hover_port)
		if selected_port != null && hover_port == null:
			_create_node_at_mouse(selected_port, mouse_pos)
		selected_port = null
		selected_node = null
		
	if Input.is_action_just_pressed("lclick"):
		var double_click = now - last_click_time < DOUBLE_CLICK_DELAY
		last_click_time = now
		
		if hover_node:
			if double_click:
				edit_node = hover_node
				edit_port = null
				selected_port = null
				selected_node = null
				_start_rename()
			elif edit_node != null:
				pass
			else:
				selected_node = hover_node
				selected_port = null
				edit_node = null
				edit_port = null
		elif hover_port:
			if double_click:
				edit_port = hover_port
				edit_node = null
				selected_port = null
				selected_node = null
				_start_rename()
			elif edit_port != null:
				pass
			else:
				edit_port = null
				edit_node = null
				selected_node = null
				selected_port = hover_port
		elif hover_edge:
			pass
		elif edit_node:
			pass
		elif edit_port:
			pass
		elif double_click:
			var size = get_viewport().get_visible_rect()
			if size.has_point(mouse_pos):
				create_node(mouse_pos, _get_next_name())
			
	if Input.is_action_just_pressed("rclick") or Input.is_action_just_pressed("delete"):
		if hover_node:
			remove_node(hover_node)
			hover_node = null
		elif hover_port:
			remove_port(hover_port)
			hover_port = null
		elif hover_edge:
			remove_edge(hover_edge)
			hover_edge = null
	
	_move_selected_node(selected_node, mouse_pos)
	_handle_mouse_hover_edge(mouse_pos)
	_handle_hover_effect_on_edges()

func _get_next_name():
	name_counter = name_counter + 1
	return "N" + str(name_counter).pad_zeros(3)

func _draw_bezier_curve(from: Vector2, to: Vector2, color := Color.AQUA, width := 2.0, steps := 32):
	var points = Utils.get_bezier_curve(from, to, steps)
	draw_polyline(points, color, width)
