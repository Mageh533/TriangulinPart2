extends Node3D

@export var level : int = 0

# doors
@onready var floor5 = $Door2
@onready var floor4 = $Door

func _ready():
	if level == 1:
		floor4.locked = false
		floor4.lockable = false
	else:
		floor5.locked = false
		floor5.lockable = false
