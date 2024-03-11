extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pauseHotKeys()

func pauseHotKeys():
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = !get_tree().paused
	
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		show()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hide()
