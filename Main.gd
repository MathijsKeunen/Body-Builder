extends Node2D

onready var score_label: Label = $Score

var score: float = 0


func add_score(s: float) -> void:
	score += s
	score_label.text = str(round(score))
