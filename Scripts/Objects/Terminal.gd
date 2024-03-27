extends Node3D

signal toggleControlToPlayer
signal terminalFinished

@export var sceneToPlay : PackedScene

@onready var viewport = $SubViewport
@onready var game = $SubViewport/Game
@onready var camera = $Camera3D
@onready var UI = $UI
@onready var label = $UI/Label
@onready var unasable = $SubViewport/Unusable
@onready var flash_timer = $FlashTimer

var connected : bool = false
var active : bool = true

func _ready():
	unasable.hide()

func _process(_delta):
	if camera.current:
		UI.show()
	else:
		UI.hide()
	
	if game.get_child_count() > 0 and !connected:
		connected = true
		game.get_child(0).connect("winGame", gameWon)

func _on_exit_button_pressed():
	toggleControlToPlayer.emit()
	for child in game.get_children():
		game.remove_child(child)

func gameWon():
	print("Game won")
	game.get_child(0).queue_free()
	active = false
	flash_timer.start()
	terminalFinished.emit()

func use():
	camera.current = true
	toggleControlToPlayer.emit()
	if active:
		label.show()

func _unhandled_input(event):
	if camera.current:
		if event.is_action_pressed("start") and game.is_inside_tree() and active:
			game.add_child(sceneToPlay.instantiate())
			label.hide()
		# Input has to manually be pushed to the viewport
		if viewport.is_inside_tree():
			viewport.push_input(event)

func _on_flash_timer_timeout():
	unasable.visible = !unasable.visible
