extends Line2D
class_name Organ

var astar_indices: Dictionary


func get_astar_index(net: int) -> int:
	return astar_indices[net]


func set_astar_index(net: int, i: int) -> void:
	astar_indices[net] = i
