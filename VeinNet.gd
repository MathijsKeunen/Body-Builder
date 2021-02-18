extends Node2D
class_name VeinNet

const TRANSPARANT = Color(1, 1, 1, 0.3)

export (int) var net_number
export (Color) var color


func enable(e: bool):
	$Veins.set_process_unhandled_input(e)
	modulate = Color.white if e else TRANSPARANT
	z_index = 2 if e else 0


func are_points_connected(a: int, b: int) -> bool:
	return not $Veins.astar.get_id_path(a, b).empty()
