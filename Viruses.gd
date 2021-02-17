extends Node2D

const virus_scene = preload("res://Virus.tscn")

func spawn_virus(p: Vector2):
	var new = virus_scene.instance()
	new.position = p
	add_child(new)

