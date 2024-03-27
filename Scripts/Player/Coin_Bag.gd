extends RayCast3D

@export var Coin : PackedScene

func throw_coin():
	if !is_colliding():
		var coin = Coin.instantiate()
		get_tree().root.add_child(coin)
		coin.global_transform = global_transform
		var direction = global_transform.basis.z.normalized()
		coin.apply_central_impulse(-direction * 10)

func _on_player_use_primary(primaryTool):
	if primaryTool == "Coinbag":
		throw_coin()

func _on_player_use_secondary(secondaryTool):
	if secondaryTool == "Coinbag":
		throw_coin()
