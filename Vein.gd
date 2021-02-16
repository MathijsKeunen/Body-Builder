extends Line2D
class_name Vein

var start_index: int setget set_start_index, get_start_index
var end_index: int setget set_end_index, get_end_index
var dummy_index: int = -1 setget set_dummy_index, get_dummy_index
var indices: Array setget , get_indices

func _ready():
	default_color = Color(randf(), randf(), randf())
	set_dummy_index(-1)

func set_start_index(i: int) -> void:
	$start/start.text = str(i)

func get_start_index() -> int:
	return int($start/start.text)

func set_end_index(i: int) -> void:
	$end/end.text = str(i)

func get_end_index() -> int:
	return int($end/end.text)

func set_dummy_index(i: int) -> void:
	$dummy/dummy.text = str(i)
	if i >= 0:
		$dummy.visible = true

func get_dummy_index() -> int:
	return int($dummy/dummy.text)

func get_indices() -> Array:
	return [get_start_index(), get_end_index()]

func _process(_delta):
	$start.position = points[0]
	$end.position = points[-1]
	$dummy.position = points[int(points.size() / 2)]
