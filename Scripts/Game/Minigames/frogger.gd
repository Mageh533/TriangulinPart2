extends Node2D

signal winGame
signal lostGame

func _on_area_2d_body_entered(_body):
	emit_signal("winGame")

func _on_player_death():
	emit_signal("lostGame")
