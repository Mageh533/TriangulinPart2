extends StaticBody3D

var active : bool = false

signal IsInUse(inUse : bool)

func _physics_process(delta):
	if active:
		rotation.x = rotate_toward(rotation.x, deg_to_rad(-90), delta * 8)
	else:
		rotation.x = rotate_toward(rotation.x, deg_to_rad(0), delta * 8)

func use():
	active = !active
	emit_signal("IsInUse", active)
