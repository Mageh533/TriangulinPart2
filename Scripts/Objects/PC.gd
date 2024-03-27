extends StaticBody3D

signal toggleControlToPlayer

var usbPickedUp : int = 0
var usbToPickUp : int = 5

@onready var pc_cam = $PCCam
@onready var pc_label = $PCMesh/PCView/PCUI/UsbLabel
@onready var viewport = $PCMesh/PCView
@onready var pc_ui = $UI

func use():
	pc_cam.current = true
	toggleControlToPlayer.emit()

func _process(_delta):
	if pc_cam.current:
		pc_ui.show()
	else:
		pc_ui.hide()

func _on_button_pressed():
	toggleControlToPlayer.emit()

func _on_floor_4_terminal_cleared():
	usbPickedUp += 1
	pc_label.text = str(usbPickedUp) + "/" + str(usbToPickUp)

func _unhandled_input(event):
	if pc_cam.current:
		viewport.push_input(event)

func _on_exit_pressed():
	toggleControlToPlayer.emit()
