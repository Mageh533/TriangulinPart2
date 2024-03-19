extends Node3D

# Nodes
@onready var map_center_mark = $MapCenter
@onready var estrellin_monster = $Estrellin
@onready var ceiling = $BaseLayout/Floor5Ceiling

var nextFloorLocked := true
var pcDecryptable := false
var usbPickedUp : int = 0
var usbToPickUp : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	ceiling.show()

func _on_key_pickup_key():
	nextFloorLocked = false

func _on_usb_picked_up():
	usbPickedUp += 1
	if usbPickedUp == usbToPickUp:
		pcDecryptable = true
