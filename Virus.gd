extends AnimatedSprite


func _on_Virus_animation_finished():
	if randf() < 0.1:
		play("blink")
	else:
		play("default")
