extends Node3D

# Nodes
@onready var map_center_mark = $MapCenter
@onready var estrellin_monster = $Estrellin
@onready var ceiling = $BaseLayout/Ceiling

# Called when the node enters the scene tree for the first time.
func _ready():
	ceiling.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
