extends Control


func _unhandled_key_input(event):
	if event.scancode == KEY_SPACE and event.pressed:
		var viewport = get_tree().root.get_viewport()
		var img = viewport.get_texture().get_data()
		img.flip_y()
		img.save_png("splash.png")
