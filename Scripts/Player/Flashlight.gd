extends SpotLight3D

signal sendBattery(batteryLeft : float)
signal emitNoise(noiseMade : float)

@export var maxBattery : float = 100.0
@export var rechargeRate : float = 10.0
@export var consumptionRate : float = 1

@export var noise : float = 2

var battery : float

# Called when the node enters the scene tree for the first time.
func _ready():
	battery = maxBattery

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Drain battery, send values to UI
	playerControls(delta)
	# Light feels weaker on lower battery, lets the player know to recharge
	light_energy = battery / 100
	spot_angle = battery / 2
	if battery > 0 and visible:
		battery -= delta * consumptionRate
		if battery < 0:
			battery = 0
	emit_signal("sendBattery", battery)

func playerControls(delta):
	# Turn on flaslight
	if Input.is_action_just_pressed("flashlight_toggle"):
		visible = !visible
	if Input.is_action_pressed("recharge"):
		if battery < maxBattery:
			battery += delta * rechargeRate
		emit_signal("emitNoise", noise * delta)
