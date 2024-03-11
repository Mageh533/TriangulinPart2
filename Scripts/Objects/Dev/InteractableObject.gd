extends CSGBox3D

var move : bool = false
var moveTime : float = 0.2

func use():
	move = true

func _physics_process(delta):
	if move:
		position.x += 10 * delta
		moveTime -= delta
		if moveTime < 0:
			move = false
			moveTime = 0.2
