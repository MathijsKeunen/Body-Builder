extends Control

onready var main = get_node("../..")

const transparant := Color(1, 1, 1, 0.5)

func _unhandled_key_input(event):
	if event.scancode == KEY_ESCAPE and event.pressed:
		_toggle_pause()


func _toggle_pause():
	var paused = not get_tree().paused
	get_tree().paused = paused
	visible = paused
	get_tree().set_input_as_handled()
	main.modulate = transparant if paused else Color.white


func _on_Quit_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://StartMenu.tscn")
	get_tree().paused = false


func _on_Resume_pressed():
	_toggle_pause()
