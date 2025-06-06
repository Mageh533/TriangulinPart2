extends RigidBody3D

@onready var noise = $Noise

var collided := false

func _ready():
	apply_torque_impulse(Vector3(5, 0, 0))

func _physics_process(_delta):
	if !collided:
		if get_contact_count() > 0:
			collided = true
			noise.process_mode = Node.PROCESS_MODE_INHERIT
			await get_tree().create_timer(2).timeout
			queue_free()
