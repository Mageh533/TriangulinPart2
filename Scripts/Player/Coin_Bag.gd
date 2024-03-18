extends RayCast3D

@export var Coin : PackedScene

var equiped := true

func _on_player_use_secondary():
	if equiped:
		if !is_colliding():
			var coin = Coin.instantiate()
			get_tree().root.add_child(coin)
			coin.global_position = global_position
			coin.linear_velocity = target_position
