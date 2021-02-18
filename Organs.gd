extends Node2D

const points_per_frame = 0.3

signal heart_died
signal all_organs_died

onready var heart = $Heart
onready var controller = get_parent().get_node("VeinController")
onready var parent = get_parent()

var organs: Array


func _ready():
	heart.active = true
	for child in get_children():
		if child is Organ:
			child.connect("died", self, "_on_organ_died")
			if child != heart:
				organs.append(child)


func _process(delta):
	for organ in organs:
		var active = controller.are_connected(organ, heart)
		organ.active = active
		if active:
			parent.add_score(delta)


func _on_organ_died() -> void:
	if not heart.is_alive():
		emit_signal("heart_died")
		print("heart died")
	else:
		var dead := true
		for organ in organs:
			dead = dead and not organ.is_alive()
		if dead:
			emit_signal("all_organs_died")
			print("all organs died")
