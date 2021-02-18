extends Control


func _on_Quit_pressed():
	get_tree().quit()


func _on_Play_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Main.tscn")


func _on_Back_pressed():
	$CenterContainer.show()
	$CenterContainer2.hide()


func _on_Help_pressed():
	$CenterContainer.hide()
	$CenterContainer2.show()
