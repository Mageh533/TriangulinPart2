extends Control

# Nodes to control
@onready var staminaBar = $StaminaPanel/ProgressBar
@onready var interactableLabel = $InteractLabel
@onready var useMsgLabel = $UseMessageLabel
@onready var inventory = $Inventory
@onready var fps = $FPS

func _ready():
	inventory.hide()
	reset_inventories()

func _process(delta):
	fps.text = "FPS: " +  str(Engine.get_frames_per_second())

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
	for item in inventory.get_children():
		item.hide()

func _on_player_update_inventory(inv):
	reset_inventories()
	
	for item in inventory.get_children():
		if item.name in inv:
			item.show()

func _on_player_toggle_inventory():
	inventory.visible = !inventory.visible
