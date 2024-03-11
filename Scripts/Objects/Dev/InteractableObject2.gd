extends CSGBox3D

signal returnCamera
signal freezePlayer

@onready var newCam = $TakeOver
var active := false

func use():
	if !newCam.current:
		newCam.current = true
		emit_signal("freezePlayer")
		await get_tree().create_timer(0.5).timeout
		active = true

func _process(_delta):
	if Input.is_action_just_released("interact") and active:
		active = false
		emit_signal("returnCamera")
