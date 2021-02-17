extends Line2D
class_name Organ

var astar_indices: Dictionary

func _ready():
	print(global_position + points[0])

func get_astar_index(net: int) -> int:
	return astar_indices[net]


func set_astar_index(net: int, i: int) -> void:
	astar_indices[net] = i
