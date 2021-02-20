extends Label

const start_text = "SCORE: "

var score setget set_score


func set_score(s: int) -> void:
	text = start_text + str(s)
