extends AnimatedSprite
class_name Virus

signal end_reached

const move_delay := 1.5
var index: int
var direction: int

var elapsed_time := 0.0

func _ready():
	z_index = 1

func _on_Virus_animation_finished():
	if randf() < 0.1:
		play("blink")
	else:
		play("default")

func _process(delta):
	elapsed_time += delta
	if elapsed_time >= move_delay:
		elapsed_time = 0
		move()


func move():
	var new_index = index + direction
	if new_index < 0 or new_index >= get_parent().points.size():
		emit_signal("end_reached", self)
	else:
		index = new_index
		position = get_parent().points[new_index]
