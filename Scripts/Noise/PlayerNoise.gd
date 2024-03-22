extends Area3D

@export var TYPE := "Player"
@export var noise_radius : float
@export var one_shot : bool

@onready var noise_particle = $NoiseParticle
@onready var noise_collision = $NoiseCollision

func _ready():
	noise_collision.shape.radius = noise_radius + 0.001
	noise_particle.one_shot = one_shot

func _process(_delta):
	noise_particle.process_material.scale_min = noise_collision.shape.radius
	noise_particle.process_material.scale_max = noise_collision.shape.radius
