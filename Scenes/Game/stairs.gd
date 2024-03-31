extends Node3D

@export var level : int = 0

# doors
@onready var floor5 = $Door2
@onready var floor4 = $Door
@onready var floor3 = $Door3

func _ready():
	if level == 1:
		floor4.locked = false
		floor4.lockable = false


func _on_floor_4_unlock_3_rd_floor():
	floor3.locked = false

func _on_floor_5_open_door():
	floor5.open = true

func _on_floor_5_close_door():
	floor5.open = false
