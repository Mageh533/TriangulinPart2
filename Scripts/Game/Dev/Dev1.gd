extends Node3D

@onready var playerCam = $Player/Head
@onready var player = $Player
@onready var monster = $Estrellin

func _on_interactable_object_2_return_camera():
	playerCam.current = true
	player.active = true

func _on_interactable_object_2_freeze_player():
	player.active = false
