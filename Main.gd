extends Node2D

onready var score_label: Label = $HBoxContainer/Score
onready var game_over_menu = $CanvasLayer/GameOverMenu

var score: float = 0


func add_score(s: float) -> void:
	score += s
	score_label.text = str(round(score))


func _on_Organs_all_organs_died():
	_game_over("ALL ORGANS DIED!")


func _on_Organs_heart_died():
	_game_over("THE HEART DIED!")


func _game_over(t: String):
	game_over_menu.score = round(score)
	game_over_menu.game_over_text = t
	get_tree().paused = true
	game_over_menu.visible = true
	get_tree().set_input_as_handled()
	modulate = Color(1, 1, 1, 0.5)
