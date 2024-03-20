extends SpotLight3D

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
	# Light feels weaker on lower battery, lets the player know to recharge
	light_energy = battery / 100
	spot_angle = battery / 2
	if battery > 0 and visible:
		battery -= delta * consumptionRate
		if battery < 0:
			battery = 0

func _on_player_reload(delta):
	if battery < maxBattery:
		battery += delta * rechargeRate
	emit_signal("emitNoise", noise * delta)

func use_flashlight():
	visible = !visible

func _on_player_use_primary(primaryTool):
	if primaryTool == "Flashlight":
		use_flashlight()

func _on_player_use_secondary(secondaryTool):
	if secondaryTool == "Flashlight":
		use_flashlight()
