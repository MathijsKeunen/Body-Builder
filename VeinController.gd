extends Node2D

signal veins_switched

const TRANSPARANT = Color(1, 1, 1, 0.3)


func _ready():
	_switch_vein_net()


func _switch_vein_net():
	emit_signal("veins_switched")
	var first = get_child(1)
	var last = get_child(0)
	move_child(first, 0)
	first.enable(false)
	last.enable(true)


func _unhandled_key_input(event):
	if event.pressed and not event.echo and event.scancode == KEY_SPACE:
		_switch_vein_net()


func _on_Organ_mouse_entered():
	for net in get_children():
		if net is VeinNet:
			net.get_node("Veins").active_vein = null


func are_connected(first: Organ, second: Organ) -> bool:
	for net in get_children():
		if net is VeinNet:
			var i = net.net_number
			var start = first.get_astar_index(i)
			var end = second.get_astar_index(i)
			if not net.are_points_connected(start, end):
				return false
	return true
