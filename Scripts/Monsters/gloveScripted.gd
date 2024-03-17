extends Node3D

@onready var animation_player = $AnimationPlayer


func open():
	animation_player.play("Idle_Open")

func grab():
	animation_player.play("Idle_Grab")

func hold():
	animation_player.play("Idle_Hold")

func gun():
	animation_player.play("Idle_Gun")
