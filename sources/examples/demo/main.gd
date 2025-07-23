extends Node2D

@onready var visual_manager: VisualManager = $VisualManager

var resource_node : Resource = preload("res://visual_node.tscn")
var resource_port : Resource = preload("res://visual_port.tscn")
var name_counter : int = -1

func _ready():
	#create_test()
	visual_manager.add_node(create_node_alt_1(Vector2(-80, 0), "A001"))
	visual_manager.add_node(create_node_alt_2(Vector2(80, 0), "B002"))

func _get_next_name():
	name_counter = name_counter + 1
	return "N" + str(name_counter).pad_zeros(3)

func create_test():
	var offset = Vector2(1000, 1000)
	var previous = null
	for x in range(20):
		for y in range(20):
			var current = create_node_alt_2(Vector2(x * 100, y * 100) - offset, _get_next_name())
			if previous:
				visual_manager.connect_to(previous.ports[0], current.ports[3])
			previous = current

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
	var node : VisualNode = null
	
	if randi_range(0, 10) < 3:
		node = create_node_alt_2(pos, label_text)
	else:
		node = create_node_alt_1(pos, label_text)
		
	visual_manager.add_node(node)
	return node
	
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
	
	return node

func _on_visual_manager_create_node_on_position(pos: Vector2) -> void:
	create_node(pos, _get_next_name())

func _on_visual_manager_create_node_on_position_and_connect(pos: Vector2, port: VisualPort) -> void:
	var n = create_node(pos, _get_next_name())
	var np = n.get_nearest_port(port.global_position)
	if np:
		visual_manager.connect_to(port, np)
