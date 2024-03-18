extends StaticBody3D

signal pickedUp

func use():
	queue_free()
	emit_signal("pickedUp")
