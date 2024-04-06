extends Node3D

@onready var anim = $AnimationPlayer
@onready var item_anims = $ItemsAnimPlayer

func dequip():
	anim.play("Idle")
	item_anims.play("Dequip_All")

# Equip anims
func equipFlashlight():
	anim.play("Equip_Flashlight")
	item_anims.play("Flashlight_Equip")

func equipCoinbag():
	anim.play("Equip_Coin")
	item_anims.play("Equip_Coin")

# Use Anims
func useFlashlight():
	anim.play("Use_Flashlight")

func useCoinbag():
	anim.play("Use_Coin")
	item_anims.play("Dequip_All")
	await anim.animation_finished
	item_anims.play("Equip_Coin")
	anim.play("Equip_Coin")
