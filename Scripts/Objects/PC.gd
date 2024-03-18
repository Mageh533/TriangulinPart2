extends StaticBody3D

signal switchPerspective(state : bool)

var usbPickedUp : int = 0
var usbToPickUp : int = 5

@onready var pc_cam = $PCCam
@onready var pc_label = $PCMesh/PCView/PCUI/UsbLabel

func use():
	pc_cam.current = true
	emit_signal("switchPerspective", false)

func _on_button_pressed():
	emit_signal("switchPerspective", true)

func _on_usb_picked_up():
	usbPickedUp += 1
	pc_label.text = str(usbPickedUp) + "/" + str(usbToPickUp)
