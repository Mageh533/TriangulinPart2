extends Node3D

@onready var anim = $AnimationPlayer

func dequip():
	anim.play("Idle")

# Equip anims
func equipFlashlight():
	anim.play("Equip_Flashlight")

func equipCoinbag():
	anim.play("Equip_Coin")

# Use Anims
func useFlashlight():
	anim.play("Use_Flashlight")

func useCoinbag():
	anim.play("Use_Coin")
	await anim.animation_finished
	anim.play("Equip_Coin")
