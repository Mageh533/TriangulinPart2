extends StaticBody3D

signal pickupKey

@onready var picksfx = $Pickup

@export var returnMessage = "Picked up Key labeled (3rd Floor)"

func use():
	pickupKey.emit()
	picksfx.reparent(get_tree().root)
	playSFX()
	queue_free()
	return returnMessage

func playSFX():
	picksfx.play()
	await picksfx.finished
	picksfx.queue_free()
