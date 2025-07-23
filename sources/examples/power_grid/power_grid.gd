extends Node2D

@onready var visual_manager: VisualManager = $VisualManager

var resource_node : Resource = preload("res://visual_node.tscn")
var resource_port : Resource = preload("res://visual_port.tscn")
var name_counter : int = -1
var selected_node_type : int = 1

func _ready():
	#create_test()
	visual_manager.add_node(create_node_source(Vector2(-80, 0)))
	visual_manager.add_node(create_node_lamp(Vector2(80, 0)))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("num_1"):
		selected_node_type = 0
	if Input.is_action_just_pressed("num_2"):
		selected_node_type = 1
	if Input.is_action_just_pressed("num_3"):
		selected_node_type = 2

func create_selected_node(pos: Vector2) -> VisualNode:
	match selected_node_type:
		0:
			return create_node_source(pos)
		1:
			return create_node_lamp(pos)
		2:
			return create_node_cross(pos)
	return null
			
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
	
func create_node_source(pos: Vector2):
	var size = 32
	var padding = 2
	
	var node = resource_node.instantiate()
	node.position = pos
	node.text = "GEN"
	
	var port_right = create_port(node , "", Enums.TextPosition.RIGHT, Vector2( (size + padding), 0), Enums.VisualPortDirection.OUTPUT, false)
	
	return node

func create_node_lamp(pos: Vector2):
	var size = 32
	var padding = 2
	
	var node = resource_node.instantiate()
	node.position = pos
	node.text = "LMP"
	
	var port_left = create_port(node, "", Enums.TextPosition.LEFT, Vector2( -(size + padding), 0), Enums.VisualPortDirection.INPUT, false)
	
	return node
	
func create_node_cross(pos: Vector2):
	var size = 32
	var padding = 2
	
	var node = preload("res://visual_node.tscn").instantiate()
	node.position = pos
	node.text = ""
	
	var port_top = create_port(node, "TOP", Enums.TextPosition.TOP, Vector2(0, -(size + padding)), Enums.VisualPortDirection.INPUT_OUTPUT, false)
	var port_right = create_port(node , "RHT", Enums.TextPosition.RIGHT, Vector2( (size + padding), 0), Enums.VisualPortDirection.INPUT_OUTPUT, false)
	var port_bottom = create_port(node, "BTM", Enums.TextPosition.BOTTOM, Vector2(0, (size + padding)), Enums.VisualPortDirection.INPUT_OUTPUT, false)
	var port_left = create_port(node, "LFT", Enums.TextPosition.LEFT, Vector2( -(size + padding), 0), Enums.VisualPortDirection.INPUT_OUTPUT, false)
	
	return node

func _on_visual_manager_create_node_on_position(pos: Vector2) -> void:
	var n = create_selected_node(pos)
	visual_manager.add_node(n)

func _on_visual_manager_create_node_on_position_and_connect(pos: Vector2, port: VisualPort) -> void:
	var n = create_selected_node(pos)
	visual_manager.add_node(n)
	
	var np = n.get_nearest_port(port.global_position)
	if np:
		visual_manager.connect_to(port, np)
