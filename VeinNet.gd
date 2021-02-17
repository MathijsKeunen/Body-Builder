extends Node2D

const TRANSPARANT = Color(1, 1, 1, 0.3)

export (int) var net_number
export (Color) var color


func enable(e: bool):
	$Veins.set_process_unhandled_input(e)
	modulate = Color.white if e else TRANSPARANT
	z_index = 2 if e else 0
