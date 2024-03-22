extends Node3D

@onready var playerCam = $Player/Head
@onready var player = $Player
@onready var monster = $Estrellin
@onready var triangulin = $Triagulin

func _on_interactable_object_2_return_camera():
	playerCam.current = true
	player.active = true

func _on_interactable_object_2_freeze_player():
	player.active = false


func _on_triangulin_trigger_body_entered(body):
	triangulin.appear()
