extends Node3D

@onready var anim = $AnimationPlayer

func dequip():
	anim.play("Idle")

func equipFlashlight():
	anim.play("Idle_Flashlight")

func equipCoinbag():
	anim.play("Idle")
