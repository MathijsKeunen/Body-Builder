extends Control

var score setget set_score
var game_over_text := "GAME OVER!" setget set_game_over_text


func set_score(s: int) -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/Label.score = s


func set_game_over_text(t: String) -> void:
	$CenterContainer/VBoxContainer/Label.text = t


func _on_Restart_pressed():
	get_tree().paused = false
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Main.tscn")


func _on_Back_pressed():
	get_tree().paused = false
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://StartMenu.tscn")
