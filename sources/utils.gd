extends Node

func get_bounding_box(points: PackedVector2Array, min : float = 0.0) -> Rect2:
	if points.is_empty():
		var hm = min / 2.0
		return Rect2(-hm, -hm, min, min)

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
	var rect = Rect2(position, size)
	return rect.grow_individual( max(0, (min - size.x) / 2.0), max(0, (min - size.y) / 2.0), max(0, (min - size.x) / 2.0), max(0, (min - size.y) / 2.0) )
	
func get_bezier_curve(from: Vector2, to: Vector2, steps := 32) -> PackedVector2Array:
	var direction = sign(to.x - from.x)
	var control_offset = abs(to.x - from.x) * 0.5 * direction
	var cp1 = from + Vector2(control_offset, 0)
	var cp2 = to - Vector2(control_offset, 0)

	var points := PackedVector2Array()
	for i in steps + 1:
		var t = i / float(steps)
		var point = from.bezier_interpolate(cp1, cp2, to, t)
		points.append(point)
	
	return points

func is_mouse_near_bezier(mouse_pos: Vector2, from: Vector2, to: Vector2, steps := 32, threshold := 2.0) -> bool:
	var direction = sign(to.x - from.x)
	var control_offset = abs(to.x - from.x) * 0.5 * direction
	var cp1 = from + Vector2(control_offset, 0)
	var cp2 = to - Vector2(control_offset, 0)

	var last_point = from
	for i in range(1, steps + 1):
		var t = i / float(steps)
		var point = from.bezier_interpolate(cp1, cp2, to, t)
		
		var closest = Geometry2D.get_closest_point_to_segment(mouse_pos, last_point, point)
		if mouse_pos.distance_to(closest) <= threshold:
			return true
		
		last_point = point

	return false
	
func is_mouse_near_polyline(mouse_pos: Vector2, points : PackedVector2Array, threshold := 2.0) -> bool:
	if points.is_empty():
		return false
		
	var last_point = points[0]
	for point in points:
		var closest = Geometry2D.get_closest_point_to_segment(mouse_pos, last_point, point)
		if mouse_pos.distance_to(closest) <= threshold:
			return true
		
		last_point = point

	return false

func find_connected_components(nodes: Array, edges: Array) -> Array:
	var visited = {}
	var components = []

	var graph = {}
	for node in nodes:
		graph[node] = []

	for edge in edges:
		var a = edge.port_a.parent
		var b = edge.port_b.parent
		graph[a].append(b)
		graph[b].append(a)

	for node in nodes:
		if not visited.has(node):
			var component = []
			var stack = [node]

			while not stack.is_empty():
				var current = stack.pop_back()
				if visited.has(current):
					continue
				visited[current] = true
				component.append(current)
				for neighbor in graph[current]:
					if not visited.has(neighbor):
						stack.append(neighbor)

			components.append(component)
	return components
