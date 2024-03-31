extends Node3D

signal terminalCleared
signal unlock3rdFloor

# Nodes
@onready var map_center_mark = $MapCenter
@onready var estrellin_monster = $Estrellin
@onready var triangulin_monster = $Triagulin
@onready var ceiling = $"BaseLayout/4Ceiling"

@onready var UI = $UI

@onready var exit_key = $"Objects/PC Room/Key"
@onready var win_clip = $BaseLayout/Stairs/WinClip

var navigationMaps : Array[RID]

var nextFloorLocked := true
var pcDecryptable := false
var usbPickedUp : int = 0
var usbToPickUp : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	navigationMaps = NavigationServer3D.get_maps()
	exit_key.process_mode = Node.PROCESS_MODE_DISABLED
	ceiling.show()
	UI.hide()
	win_clip.process_mode = Node.PROCESS_MODE_DISABLED

func _on_key_pickup_key():
	unlock3rdFloor.emit()
	win_clip.process_mode = Node.PROCESS_MODE_INHERIT

func _on_spawn_trigger_body_entered(body):
	var playerPos = body.global_position
	playerPos.x += randf_range(-10, 10)
	playerPos.z += randf_range(-10, 10)
	var spawnTarget = NavigationServer3D.map_get_closest_point(navigationMaps[0], playerPos)
	
	triangulin_monster.appear(spawnTarget)

func _on_terminal_terminal_finished():
	usbPickedUp += 1
	if usbPickedUp == usbToPickUp:
		pcDecryptable = true
		exit_key.process_mode = Node.PROCESS_MODE_INHERIT
	terminalCleared.emit()

func _on_win_clip_body_entered(body):
	body.exitLevel()
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_player_game_over():
	for child in get_children():
		if child != UI:
			child.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	UI.show()

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().quit()
