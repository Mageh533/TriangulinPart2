extends Control

# Nodes to control
@onready var flashlightLabel = $FlashlightPanel/FlashlightNum
@onready var noiseLabel = $NoisePanel/NoiseNum
@onready var staminaBar = $StaminaPanel/ProgressBar

# Display battery on UI
func _on_flashlight_send_battery(batteryLeft):
	flashlightLabel.text = "Battery: " + str(batteryLeft).pad_decimals(0) + "%"

func _on_player_send_current_noise(currentNoise):
	noiseLabel.text = "Noise: " + str(currentNoise).pad_decimals(2)

func _on_player_send_current_stamina(currentStamina):
	staminaBar.value = currentStamina
