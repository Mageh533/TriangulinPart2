extends Node3D

# Nodes
@onready var map_center_mark = $MapCenter
@onready var estrellin_monster = $Estrellin
@onready var triangulin_monster = $Triagulin
@onready var ceiling = $BaseLayout/Ceiling

var navigationMaps : Array[RID]

var nextFloorLocked := true
var pcDecryptable := false
var usbPickedUp : int = 0
var usbToPickUp : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	navigationMaps = NavigationServer3D.get_maps()
	ceiling.show()

func _on_key_pickup_key():
	nextFloorLocked = false

func _on_usb_picked_up():
	usbPickedUp += 1
	if usbPickedUp == usbToPickUp:
		pcDecryptable = true

func _on_spawn_trigger_body_entered(body):
	var playerPos = body.global_position
	playerPos.x += randf_range(-10, 10)
	playerPos.z += randf_range(-10, 10)
	var spawnTarget = NavigationServer3D.map_get_closest_point(navigationMaps[0], playerPos)
	
	triangulin_monster.appear(spawnTarget)
