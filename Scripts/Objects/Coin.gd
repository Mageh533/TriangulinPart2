extends RigidBody3D

@onready var noise = $Noise

var collided := false

func _process(delta):
	if !collided:
		if get_contact_count() > 0:
			collided = true
			noise.process_mode = Node.PROCESS_MODE_INHERIT
			await get_tree().create_timer(2).timeout
			queue_free()
