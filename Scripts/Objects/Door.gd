extends AnimatableBody3D

@onready var barricade = $DoorBarricade

@export var open : bool = false
@export var locked : bool = false
@export var lockable : bool = true

var initRotY : float

func _ready():
	initRotY = rotation.y
	if !lockable:
		barricade.queue_free()

func _physics_process(delta):
	if open:
		rotation.y = rotate_toward(rotation.y, initRotY + deg_to_rad(90), delta * 8)
	else:
		rotation.y = rotate_toward(rotation.y, initRotY, delta * 8)

func use():
	if !locked:
		open = !open

func _on_door_barricade_is_in_use(inUse):
	locked = inUse
