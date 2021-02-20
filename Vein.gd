extends Line2D
class_name Vein

const virus_scene = preload("res://Virus.tscn")

var start_index: int setget set_start_index, get_start_index
var end_index: int setget set_end_index, get_end_index
var dummy_index: int = -1 setget set_dummy_index, get_dummy_index
var indices: Array setget , get_indices

const spawn_chance: float = 0.001

func _ready():
	set_dummy_index(-1)
#	_spawn_virus()

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
#	if i >= 0:
#		$dummy.visible = true

func get_dummy_index() -> int:
	return int($dummy/dummy.text)

func get_indices() -> Array:
	return [get_start_index(), get_end_index()]

func _process(_delta):
	$start.position = points[0]
	$end.position = points[-1]
# warning-ignore:integer_division
	$dummy.position = points[points.size() / 2]
	if randf() < spawn_chance:
		_spawn_virus()


func _spawn_virus():
	var virus = virus_scene.instance()
	var p = randi() % points.size()
	virus.position = points[p]
	add_virus(virus, p)
	virus.connect("end_reached", get_parent(), "reparent_virus")

func add_virus(virus: Virus, p: int, direction = 0):
	virus.index = p
	if direction != 0:
		virus.direction = direction
	elif p == 0:
		virus.direction = 1
	elif p == -1 or p == points.size() - 1:
		virus.direction = -1
	else:
		virus.direction = 1 - 2 * (randi() % 2)
	if virus.direction == 0:
		print("invalid direction")
	add_child(virus)
