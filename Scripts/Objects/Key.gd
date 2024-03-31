extends StaticBody3D

signal pickupKey

@export var returnMessage = "Picked up Key labeled (3rd Floor)"

func use():
	emit_signal("pickupKey")
	queue_free()
	return returnMessage
