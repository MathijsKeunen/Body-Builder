extends Line2D
class_name Organ

signal died
signal mouse_entered

var active := false setget activate

var astar_indices: Dictionary

onready var organ := $Organ
onready var healtbar := $HealthBar

func activate(a: bool) -> void:
	if a and not active:
		active = true
		organ.play()
	elif not a:
		active = false
		organ.stop()


func get_astar_index(net: int) -> int:
	return astar_indices[net]


func set_astar_index(net: int, i: int) -> void:
	astar_indices[net] = i


func do_damage() -> void:
	healtbar.value -= healtbar.step
	if healtbar.value == 0:
		activate(false)
		modulate = Color(1, 1, 1, 0.5)
		emit_signal("died")


func is_alive() -> bool:
	return healtbar.value > 0


func _on_Area2D_mouse_entered():
	emit_signal("mouse_entered")
