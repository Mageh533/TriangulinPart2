extends Node3D

@onready var triangulin = $Triagulin
@onready var spawnPoint = $TSpawnPoint

func _on_triangulin_trigger_body_entered(_body):
	triangulin.appear(spawnPoint.global_position)
