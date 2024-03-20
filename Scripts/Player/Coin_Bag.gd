extends RayCast3D

@export var Coin : PackedScene

func throw_coin():
	if !is_colliding():
		var coin = Coin.instantiate()
		get_tree().root.add_child(coin)
		coin.linear_velocity = (global_transform.basis.z.normalized())
		coin.global_position = global_position
		var impulsePos := global_position
		impulsePos.y -= 20
		coin.apply_impulse(Vector3(5,5,5), impulsePos)

func _on_player_use_primary(primaryTool):
	if primaryTool == "Coinbag":
		throw_coin()

func _on_player_use_secondary(secondaryTool):
	if secondaryTool == "Coinbag":
		throw_coin()
