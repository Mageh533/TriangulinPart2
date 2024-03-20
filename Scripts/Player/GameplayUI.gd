extends Control

# Nodes to control
@onready var flashlightLabel = $FlashlightPanel/FlashlightNum
@onready var noiseLabel = $NoisePanel/NoiseNum
@onready var staminaBar = $StaminaPanel/ProgressBar
@onready var interactableLabel = $InteractLabel
@onready var useMsgLabel = $UseMessageLabel
@onready var leftEquiped = $EquipedLeft
@onready var rightEquiped = $EquipedRight
@onready var inventory = $Inventory

func _ready():
	inventory.hide()
	reset_inventories()

# Display battery on UI
func _on_flashlight_send_battery(batteryLeft):
	flashlightLabel.text = "Battery: " + str(batteryLeft).pad_decimals(0) + "%"

func _on_player_send_current_noise(currentNoise):
	noiseLabel.text = "Noise: " + str(currentNoise).pad_decimals(2)

func _on_player_send_current_stamina(currentStamina):
	staminaBar.value = currentStamina

func _on_player_can_interact(interactable):
	interactableLabel.visible = interactable

func _on_player_send_use_message(message):
	useMsgLabel.text = message
	await get_tree().create_timer(2).timeout
	useMsgLabel.text = ""

func reset_inventories():
	# Hide all sprites shown
	for item in leftEquiped.get_children():
		item.hide()
	for item in rightEquiped.get_children():
		item.hide()

func _on_player_update_inventory(inv):
	reset_inventories()
	
	for item in leftEquiped.get_children():
		if item.name == inv["EquipedLeft"]:
			item.show()
	
	for item in rightEquiped.get_children():
		if item.name == inv["EquipedRight"]:
			item.show()

func _on_player_toggle_inventory():
	inventory.visible = !inventory.visible
