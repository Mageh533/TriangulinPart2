extends Node2D

signal winGame
signal lostGame

@export var cars : PackedScene
@export var logs : PackedScene

@onready var spawns_toLeft = $CarsSpawnsLeft
@onready var spawns_toRight = $CarsSpawnsRight

@onready var spawns_log_toLeft = $LogSpawnsLeft
@onready var spawns_log_toRight = $LogSpawnsRight
@onready var win_label = $UI/Label

func _ready():
	win_label.hide()

func _on_area_2d_body_entered(_body):
	win_label.show()
	await get_tree().create_timer(2).timeout
	emit_signal("winGame")

func _on_player_death():
	emit_signal("lostGame")

func _on_timer_timeout():
	randomize()
	if randi_range(0, 1) == 1:
		var leftSpawns = spawns_toLeft.get_children()
		spawnCars(leftSpawns.pick_random().global_position, Vector2.LEFT)
	else:
		var rightSpawns = spawns_toRight.get_children()
		spawnCars(rightSpawns.pick_random().global_position, Vector2.RIGHT)

func _on_timer_2_timeout():
	randomize()
	if randi_range(0, 1) == 1:
		var leftLogSpawns = spawns_log_toLeft.get_children()
		spawnLogs(leftLogSpawns.pick_random().global_position, Vector2.LEFT)
	else:
		var rightLogSpawns = spawns_log_toRight.get_children()
		spawnLogs(rightLogSpawns.pick_random().global_position, Vector2.RIGHT)

func spawnCars(spawnPos : Vector2, dir : Vector2):
	var car = cars.instantiate()
	car.global_position = spawnPos
	car.forward_dir = dir
	add_child(car)

func spawnLogs(spawnPos : Vector2, dir : Vector2):
	var woodLog = logs.instantiate()
	woodLog.global_position = spawnPos
	woodLog.forward_dir = dir
	add_child(woodLog)
