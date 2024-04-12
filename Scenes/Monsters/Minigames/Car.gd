extends Area2D

@export var forward_dir = Vector2.LEFT
@export var speed = 200

@onready var sprite = $AnimatedSprite2D

const spriteNames := ["bike", "car", "truck"]

func _ready():
	randomize()
	sprite.play(spriteNames.pick_random())
	await get_tree().create_timer(7).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_translate(forward_dir * speed * delta)
	sprite.flip_h = true if forward_dir == Vector2.RIGHT else false

func _on_body_entered(body):
	body.kill()
