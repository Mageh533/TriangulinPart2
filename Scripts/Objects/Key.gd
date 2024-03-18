extends StaticBody3D

signal pickupKey

func use():
	emit_signal("pickupKey")
	queue_free()
	return "Picked up Key labeled (3rd Floor)"
