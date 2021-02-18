extends Button
class_name TextButton

var small = preload("res://assets/font/dynamicfont_small.tres")
var large = preload("res://assets/font/dynamicfont_large.tres")

func _on_Play_mouse_entered():
	set("custom_fonts/font", large)


func _on_Play_mouse_exited():
	set("custom_fonts/font", small)


func _on_TextButton_button_up():
	set("custom_fonts/font", large)


func _on_TextButton_button_down():
	set("custom_fonts/font", small)
