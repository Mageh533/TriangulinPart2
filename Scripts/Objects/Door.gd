extends AnimatableBody3D

var open : bool = false

func _process(delta):
	if open:
		rotation.y = rotate_toward(rotation.y, deg_to_rad(90), delta * 8)
	else:
		rotation.y = rotate_toward(rotation.y, deg_to_rad(0), delta * 8)

func use():
	open = !open
