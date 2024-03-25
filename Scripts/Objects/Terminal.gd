extends Node3D

signal toggleControlToPlayer

@export var sceneToPlay : PackedScene

@onready var viewport = $SubViewport
@onready var game = $SubViewport/Game
@onready var camera = $Camera3D
@onready var UI = $UI
@onready var label = $UI/Label

func _process(_delta):
	if camera.current:
		UI.show()
	else:
		UI.hide()

func _on_exit_button_pressed():
	toggleControlToPlayer.emit()
	for child in game.get_children():
		game.remove_child(child)

func use():
	camera.current = true
	toggleControlToPlayer.emit()
	label.show()

func _unhandled_input(event):
	if camera.current:
		if event.is_action_pressed("start"):
			game.add_child(sceneToPlay.instantiate())
			label.hide()
		# Input has to manually be pushed to the viewport
		if viewport.is_inside_tree():
			viewport.push_input(event)
