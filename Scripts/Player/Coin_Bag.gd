extends RayCast3D

@export var Coin : PackedScene
@export var Flare : PackedScene

func throw_coin():
	if !is_colliding():
		var coin = Coin.instantiate()
		get_tree().root.add_child(coin)
		coin.global_transform = global_transform
		var direction = global_transform.basis.z.normalized()
		coin.apply_central_impulse(-direction * 10)

func throw_flare():
	if !is_colliding():
		var flare = Flare.instantiate()
		get_tree().root.add_child(flare)
		flare.global_transform = global_transform
		var direction = global_transform.basis.z.normalized()
		flare.apply_central_impulse(-direction * 10)

func _on_player_use(tool):
	if tool == "Coinbag":
		throw_coin()
	elif tool == "Flare":
		throw_flare()
