extends Node3D

var BULLET_SPEED : float = 40

const KILL_TIMER : float = 4
var timer : float = 0

var collided : bool = false

func _physics_process(delta):
	var forward_dir = -global_transform.basis.z.normalized()
	global_translate(forward_dir * BULLET_SPEED * delta)
	
	timer += delta
	if timer >= KILL_TIMER:
		queue_free()

func _on_area_3d_body_entered(body):
	collided = true
	
	body.kill("Rectangulin")
	
	queue_free()
