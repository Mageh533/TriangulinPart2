extends Node2D

signal winGame
signal lostGame

@onready var win_label = $UI/Label

func _ready():
	win_label.hide()

func _on_area_2d_body_entered(_body):
	win_label.show()
	await get_tree().create_timer(2).timeout
	emit_signal("winGame")

func _on_player_death():
	emit_signal("lostGame")
