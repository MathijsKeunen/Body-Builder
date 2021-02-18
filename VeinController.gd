extends Node2D

const TRANSPARANT = Color(1, 1, 1, 0.3)


func _ready():
	_switch_vein_net()


func _switch_vein_net():
	var first = get_child(1)
	var last = get_child(0)
	move_child(first, 0)
#	first.modulate = TRANSPARANT
#	last.modulate = Color.white
	first.enable(false)
	last.enable(true)
#	first.set_process_unhandled_input(false)
#	last.set_process_unhandled_input(true)


func _unhandled_key_input(event):
	if event.pressed and not event.echo and event.scancode == KEY_SPACE:
		_switch_vein_net()


func are_connected(first: Organ, second: Organ) -> bool:
	for net in get_children():
		if net is VeinNet:
			var i = net.net_number
			var start = first.get_astar_index(i)
			var end = second.get_astar_index(i)
			if not net.are_points_connected(start, end):
				return false
	return true
