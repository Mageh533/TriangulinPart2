extends Panel

# Nodes
@onready var flashlight = $Flashlight
@onready var coin_bag = $CoinBag

func _on_player_update_inventory(inv):
	resetInv()
	for item in inv:
		if item == "Flashlight":
			flashlight.show()
		elif item == "CoinBag":
			coin_bag.show()

func resetInv():
	coin_bag.hide()
	flashlight.hide()
