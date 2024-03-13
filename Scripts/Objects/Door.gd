extends AnimatableBody3D

@onready var barricade = $DoorBarricade

var open : bool = false
var locked : bool = false
var lockable : bool = true

func _ready():
	if !lockable:
		barricade.queue_free()

func _physics_process(delta):
	if open:
		rotation.y = rotate_toward(rotation.y, deg_to_rad(90), delta * 8)
	else:
		rotation.y = rotate_toward(rotation.y, deg_to_rad(0), delta * 8)

func use():
	if !locked:
		open = !open

func _on_door_barricade_is_in_use(inUse):
	locked = inUse
