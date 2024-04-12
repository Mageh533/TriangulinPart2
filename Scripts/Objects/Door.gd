extends AnimatableBody3D

@onready var barricade = $DoorBarricade
@onready var collision = $Collision

@onready var locked_sfx = $LockedSound
@onready var open_sfx = $OpenSound

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
	var message : String = ""
	if !locked:
		open = !open
		message = ""
		open_sfx.play(0.4)
		collision.disabled = true
		await get_tree().create_timer(0.5).timeout
		collision.disabled = false
	else:
		message = "The door is locked"
		locked_sfx.play()
	return message

func _on_door_barricade_is_in_use(inUse):
	locked = inUse
