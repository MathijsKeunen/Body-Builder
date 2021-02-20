extends Node2D
class_name Veins

const snap_distance = pow(10, 2)
const cut_segemt_size = 10
const vein_segment_size = 10
const MIN_LENGTH = 10

onready var net_number = get_parent().net_number

var active_vein: Vein
var current_index: int

onready var cut_line := $cut_line

var organ_connections: Dictionary

var vein_scene = preload("res://Vein.tscn")

var astar := AStar2D.new()


func _ready():
	for organ in get_tree().get_nodes_in_group("organ"):
		var point = organ.points[net_number] + organ.global_position
		var p = _add_point(point)
		organ_connections[p] = organ
		organ.set_astar_index(net_number, p)


func cut():
	_cut_veins(cut_line)
	cut_line.clear_points()


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		active_vein = null
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				var result = _get_closest_point(event.position)
				var connection = result[0]
				if connection is Organ:
					var p = connection.get_astar_index(net_number)
					var point = astar.get_point_position(p)
					active_vein = _new_vein(point, p)
					current_index = -1
				else:
					active_vein = connection
					current_index = result[1]
		
		elif event.button_index == BUTTON_RIGHT:
			if event.pressed:
				cut_line.add_point(event.position)
			else:
				cut()
	
	elif event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_RIGHT and not cut_line.points.empty():
			var mouse_position = event.position
			var last_point = cut_line.points[-1]
			var delta = (mouse_position - last_point).normalized() * cut_segemt_size
			var distance = last_point.distance_to(mouse_position)
			for i in range(int(distance / cut_segemt_size) - 1, -1, -1):
				var new_position = mouse_position - i * delta
				cut_line.add_point(new_position, -1)
		
		elif event.button_mask == BUTTON_MASK_LEFT and active_vein:
			# New vein started in the middle of another vein
			if current_index > 0:
				# Split the other vein in two smaller veins
				active_vein = _branch_vein(active_vein, current_index)
				current_index = -1
			else:
				var index = active_vein.get_indices()[current_index]
				if astar.get_point_connections(index).size() > 1:
					# Start new vein at an existing crossing of veins
					active_vein = _new_vein(active_vein.points[current_index], index)
					current_index = -1
			# Check if the active vein should be ended (= connected to an
			# existing vein)
			var mouse_position = event.position
			var result = _get_closest_point(mouse_position)
			var closest_connection = result[0]
			if _endable(closest_connection, result[1], active_vein, current_index):
				# The active vein should be ended
				var i = result[1]
				if closest_connection is Organ:
					_connect_to_organ(active_vein, current_index, closest_connection)
				elif i > 0:
					# Connect to the middle of an existing vein
					_merge_veins(active_vein, current_index, closest_connection, i)
				else:
					var closest_p = closest_connection.get_indices()[i]
					if astar.get_point_connections(closest_p).size() > 1:
						# Connect to an existing crossing of veins
						var new_vein = vein_scene.instance()
						new_vein.default_color = get_parent().color
						new_vein.points = active_vein.points
						new_vein.add_point(closest_connection.points[i], current_index)
						if current_index == 0:
							new_vein.start_index = closest_p
							new_vein.end_index = active_vein.end_index
						elif current_index == -1:
							new_vein.start_index = active_vein.start_index
							new_vein.end_index = closest_p
						for virus in active_vein.get_children():
							if virus is Virus:
								active_vein.remove_child(virus)
								new_vein.add_child(virus)
						_add_vein(new_vein)
						_remove_vein(active_vein)
					else:
						# Connect to the end of an existing vein
						_join_veins(closest_connection, i, active_vein, current_index)
				# Set the active vain to null to stop drawing the vein.
				active_vein = null
			else:
				# The active vein should not be ended.
				# Only add a new point if the distance from the last point is
				# large enough. This way, the amount of points is less dependend
				# on the speed of the mouse
				var last_point = active_vein.points[current_index]
				var delta = (mouse_position - last_point).normalized() * vein_segment_size
				var distance = last_point.distance_to(mouse_position)
				for i in range(int(distance / vein_segment_size) - 1, -1, -1):
					var new_position = mouse_position - i * delta
					active_vein.add_point(new_position, current_index)
				var p = active_vein.get_indices()[current_index]
				astar.set_point_position(p, active_vein.points[current_index])


func _get_closest_point(point: Vector2, with_endpoints:=true) -> Array:
	"""
	Finds a point in an existing vein that is within the snap_distance from the
	given point. If there is no such point, returns [null, -1].
	Endpoints have priority over other points. If an endpoint is within 
	snap_distance, this point is returned even if another point is closer.
	If no endpoint is within snap_distance, returns the point that is closest to
	the given point (and not the first found).
	If multiple points from different veins are within snap_dinstance of the
	given point, returns a point of the first vein in get_children().
	The return value is a list with the vein and the index of the found point.
	"""
	if with_endpoints:
		for p in organ_connections.keys():
			var connection = astar.get_point_position(p)
			var organ = organ_connections[p]
			if organ.is_alive() and connection.distance_squared_to(point) < snap_distance:
				return [organ, -1]
	for vein in get_children():
		if vein is Vein:
			var points: PoolVector2Array = vein.get_points()
			if with_endpoints:
				# Check endpoints
				if points[0].distance_squared_to(point) < snap_distance:
					return [vein, 0]
				if points[-1].distance_squared_to(point) < snap_distance:
					return [vein, -1]
			
			# Check non-endpoints
			var best_point_index = -1
			var shortest_d: float
			for p in range(points.size()):
				var d = points[p].distance_squared_to(point)
				if d < snap_distance and (d < shortest_d or best_point_index < 0):
					best_point_index = p
					shortest_d = d
			if best_point_index >= 0:
				return [vein, best_point_index]
	# Nothing found
	return [null, -1]


func _endable(old: Line2D, old_index: int, new: Vein, new_index: int) -> bool:
	if not old:
		return false
	if old_index > 0:
		return true
	if old is Vein:
		var old_p = old.get_indices()[old_index]
		var new_p = new.get_indices()[new_index]
		if old_p == new_p:
			return false
	return new.points.size() >= MIN_LENGTH


func _split_vein(vein: Vein, p: int) -> Array:
	"""
	Splits the given vein in two at position p. The two new veins both contain
	the point at index p.
	Returns an array with the two new veins.
	"""
	var vein_start = vein_scene.instance()
	vein_start.default_color = get_parent().color
	for i in range(p + 1):
		vein_start.add_point(vein.points[i], -1)
	var vein_end = vein_scene.instance()
	vein_end.default_color = get_parent().color
	for i in range(p, vein.points.size()):
		vein_end.add_point(vein.points[i], -1)
	return [vein_start, vein_end]


func _join_veins(first: Vein, first_direction: int, second: Vein, second_direction: int) -> void:
	"""
	Joins the two given veins together. The directions indicate which end of the
	points arrays should be joined, 0 means the left side, -1 the right side.
	"""
	var vein = vein_scene.instance()
	vein.default_color = get_parent().color
	vein.points = first.points
	var p: int
	if second_direction == 0:
		p = second.end_index
		for i in range(second.points.size()):
			vein.add_point(second.points[i], first_direction)
	elif second_direction == -1:
		p = second.start_index
		for i in range(second.points.size() - 1, -1, -1):
			vein.add_point(second.points[i], first_direction)
	else:
		print("something went wrong while joining veins!")
	
	if first_direction == 0:
		vein.start_index = p
		vein.end_index = first.end_index
	elif first_direction == -1:
		vein.start_index = first.start_index
		vein.end_index = p
	else:
		print("something went wrong while joining veins!")
	
	for virus in first.get_children():
		if virus is Virus:
			first.remove_child(virus)
			if first_direction == 0:
				virus.index += second.points.size()
			vein.add_child(virus)
	for virus in second.get_children():
		if virus is Virus:
			second.remove_child(virus)
			if second_direction == first_direction:
				virus.direction *= -1
				virus.index -= second.points.size()
			if first_direction == -1:
				virus.index += first.points.size()
			
			vein.add_child(virus)
	_add_vein(vein)
	for v in [first, second]:
		_remove_vein(v)


func _add_point(point: Vector2) -> int:
	var i := astar.get_available_point_id()
	astar.add_point(i, point)
	return i

func _add_vein(vein: Vein) -> void:
	add_child(vein)
	var start = vein.start_index
	var end = vein.end_index
	if start != end:
		if astar.are_points_connected(start, end):
			var dummy = _add_point(vein.points[0])
			vein.dummy_index = dummy
			astar.connect_points(start, dummy)
			astar.connect_points(dummy, end)
		else:
			astar.connect_points(start, end)


func _remove_vein(vein: Vein) -> void:
	remove_child(vein)
	var start = vein.start_index
	var end = vein.end_index
	var dummy = vein.dummy_index
	if start != end:
		if dummy >= 0:
			astar.disconnect_points(start, dummy)
			astar.disconnect_points(dummy, end)
			astar.remove_point(dummy)
		else:
			astar.disconnect_points(start, end)
		for p in [start, end]:
			if astar.get_point_connections(p).size() == 0 and not p in organ_connections.keys():
				astar.remove_point(p)
	vein.queue_free()


func _new_vein(point: Vector2, p: int) -> Vein:
	var new_vein = vein_scene.instance()
	new_vein.default_color = get_parent().color
	new_vein.add_point(point)
	new_vein.start_index = p
	new_vein.end_index = _add_point(point)
	_add_vein(new_vein)
	return new_vein


func _branch_vein(vein: Vein, index: int) -> Vein:
	var point = vein.points[index]
	var p = _add_point(point)
	var new_vein = _new_vein(point, p)
	
	var splitted_veins = _split_vein(vein, index)
	var first = splitted_veins[0]
	var last = splitted_veins[1]
	first.start_index = vein.start_index
	last.end_index = vein.end_index
	first.end_index = p
	last.start_index = p
	for virus in vein.get_children():
		if virus is Virus:
			vein.remove_child(virus)
			if virus.index <= index:
				first.add_child(virus)
			else:
				virus.index -= index
				last.add_child(virus)
	for v in splitted_veins:
		_add_vein(v)
	_remove_vein(vein)
	
	return new_vein


func _merge_veins(new: Vein, direction: int, old: Vein, index: int) -> void:
	var point = old.points[index]
	new.add_point(point, direction)
	var p = new.start_index if direction == 0 else new.end_index
	astar.set_point_position(p, point)
	var splitted_veins = _split_vein(old, index)
	var first = splitted_veins[0]
	var last = splitted_veins[1]
	first.start_index = old.start_index
	last.end_index = old.end_index
	first.end_index = p
	last.start_index = p
	for virus in old.get_children():
		if virus is Virus:
			old.remove_child(virus)
			if virus.index <= index:
				first.add_child(virus)
			else:
				virus.index -= index
				last.add_child(virus)
	for v in splitted_veins:
		_add_vein(v)
	_remove_vein(old)


func _connect_to_organ(vein: Vein, direction: int, organ: Organ) -> void:
	var new = vein_scene.instance()
	new.default_color = get_parent().color
	new.points = vein.points
	var p = organ.get_astar_index(net_number)
	new.add_point(astar.get_point_position(p), direction)
	if direction == 0:
		new.start_index = p
		new.end_index = vein.end_index
	elif direction == -1:
		new.start_index = vein.start_index
		new.end_index = p
	for virus in vein.get_children():
		if virus is Virus:
			vein.remove_child(virus)
			new.add_child(virus)
	_add_vein(new)
	_remove_vein(vein)


func _cut_veins(cut: Line2D) -> void:
	for point in cut.points:
		var result := _get_closest_point(point, false)
		var vein: Vein = result[0]
		if vein:
			_remove_vein(vein)
	for vein in get_children():
		if vein is Vein:
			var p = vein.start_index
			var connected := false
			for o in organ_connections.keys():
				if p == o or astar.get_id_path(p, o).size() > 0:
					connected = true
			if not connected:
				_remove_vein(vein)


func _check_connections():
	for vein in get_children():
		if vein is Vein:
			var start = vein.start_index
			var end = vein.end_index
			var dummy = vein.dummy_index
			if start != end:
				if dummy < 0:
					if not astar.are_points_connected(start, end):
						print(str(start) + " and " + str(end) + " are not connected")
				elif not astar.are_points_connected(start, dummy) and\
					astar.are_points_connected(dummy, end):
						print(str(start) + " and " + str(end) + " are not connected through dummy " + str(dummy))

func _print_connections():
	for p in astar.get_points():
		print(str(p) + " is connected to " + str(astar.get_point_connections(p)))
	print("\n")


func reparent_virus(virus: Virus):
	var parent: Vein = virus.get_parent()
	var i = virus.index
	var p: int
	if i <= 0:
		p = parent.start_index
	elif i >= parent.points.size() - 1:
		p = parent.end_index
	else:
		print("failed to reparent virus")
	
	if p in organ_connections.keys() and organ_connections[p].is_alive():
		organ_connections[p].do_damage()
		parent.remove_child(virus)
	
	else:
# warning-ignore:unassigned_variable
		var connections: Array
		for vein in get_children():
			if vein is Vein:
				if vein.start_index == p or vein.end_index == p and vein != parent:
					connections.append(vein)
		if connections.empty():
			virus.direction = - virus.direction
		else:
			var new: Vein = connections[randi() % connections.size()]
			parent.remove_child(virus)
			var index = 0 if new.start_index == p else new.points.size() - 1

			new.add_virus(virus, index)
		virus.move()
