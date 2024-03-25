extends CharacterBody2D

signal death

var tile_size = 32

@onready var sprite = $Sprite2D

var inputs = {"strafe_right": Vector2.RIGHT,
			"strafe_left": Vector2.LEFT,
			"forward": Vector2.UP,
			"backward": Vector2.DOWN}

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	sprite.global_position = global_position

func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move_and_collide(inputs[dir] * tile_size)

func _process(delta):
	# Interpolate
	sprite.global_position.x = move_toward(sprite.global_position.x, global_position.x, delta * 550)
	sprite.global_position.y = move_toward(sprite.global_position.y, global_position.y, delta * 550)
