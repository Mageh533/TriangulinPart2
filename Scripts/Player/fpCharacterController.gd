extends CharacterBody3D

# Signals
signal sendCurrentStamina(currentStamina : float)
signal canInteract(interactable : bool)
signal sendUseMessage(message : String)
signal reload(delta : float, primaryTool : String, secondaryTool : String)
signal reloadSfx
signal updateInventory(inv : Array)
signal toggleInventory
signal usePrimary(primaryTool : String)
signal useSecondary(secondaryTool : String)
signal hitByByllet
signal gameOver

# Nodes
@onready var noiseNode = $Noise/NoiseCollision
@onready var interactRay = $Head/Interact
@onready var playerCam = $Head
@onready var playerCollision = $PlayerCollision
@onready var leftHand = $Head/Hand_Left
@onready var rightHand = $Head/Hand_Right
@onready var UI = $UI
@onready var anim_player = $AnimationPlayer

# Editable constants
@export var SENSITIVITY : float = 0.01
@export var MAX_STAMINA : float = 100.0
@export var STAMINA_DRAIN_RATE : float = 1.0
@export var STAMINA_RECHARGE_RATE : float = 1.0
@export var EQUIPED_RIGHT := "Flashlight"
@export var EQUIPED_LEFT := ""
@export var INVENTORY := ["Flashlight", "Coinbag"]

# Constants
const SPEED : float = 4.5
const SPRINT_SPEED : float = 8
const JUMP_VELOCITY : float = 2.0

# Gameplay variables
var permNoise : float = 0
var tempNoise : float = 0
var noise : float = 0
var currentSpeed : float = 0
var stamina : float = 0

var active : bool = true
var sprinting : bool = false
var crouching : bool = false
var staminaAnims : bool = false
var shot : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready():
	stamina = MAX_STAMINA
	playEquipAnims(EQUIPED_LEFT, leftHand)
	playEquipAnims(EQUIPED_RIGHT, rightHand)
	send_inventory_to_ui()

func _process(delta):
	processNoise(delta)
	emit_signal("sendCurrentStamina", stamina)
	
	# When the player presses the inventory key it will allow them to move again, also applies when interacting with objects
	if Input.is_action_just_pressed("inventory"):
		if active:
			emit_signal("toggleInventory")
			active = false
	elif Input.is_action_just_released("inventory"):
		if !active:
			active = true
			emit_signal("toggleInventory")
	
	if stamina < MAX_STAMINA and !staminaAnims:
		staminaAnims = true
		anim_player.play("UI_stamina_fade_in")
	elif stamina >= MAX_STAMINA and staminaAnims:
		staminaAnims = false
		anim_player.play("UI_stamina_fade_out")
	
	if playerCam.current:
		UI.show()
	else:
		UI.hide()
	
	if active:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if active:
		playerControls(delta)
	else:
		velocity.x = 0
		velocity.z = 0
	
	emit_signal("canInteract", interactRay.is_colliding() and active)
	
	move_and_slide()

# Mouselook
func _input(event):
	if event is InputEventMouseMotion and active:
		rotation.y -= event.relative.x * SENSITIVITY
		
		$Head.rotation.x -= event.relative.y * SENSITIVITY
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func processNoise(delta):
	if tempNoise > 0:
		tempNoise -= delta
		if tempNoise < 0:
			tempNoise = 0
	
	noise = tempNoise + permNoise
	
	noiseNode.shape.radius = noise + 0.001

func playerControls(delta):
	# Sprinting
	if !crouching:
		if Input.is_action_pressed("sprint"):
			sprinting = true
			if stamina > 0:
				currentSpeed = SPRINT_SPEED
				stamina -= delta * STAMINA_DRAIN_RATE
			else:
				currentSpeed = SPEED
		else:
			sprinting = false
			currentSpeed = SPEED
			if stamina < MAX_STAMINA:
				stamina += delta * STAMINA_RECHARGE_RATE
	else:
		if stamina < MAX_STAMINA:
			stamina += delta * STAMINA_RECHARGE_RATE
	
	# Handle objects that are interactable
	if Input.is_action_just_pressed("interact"):
		if interactRay.is_colliding():
			var message
			message = await interactRay.get_collider().use()
			if message is String:
				emit_signal("sendUseMessage", message)
	
	if Input.is_action_just_pressed("primary"):
		emit_signal("usePrimary", EQUIPED_RIGHT)
		playUseAnims(EQUIPED_RIGHT, rightHand)
	
	if Input.is_action_just_pressed("secondary"):
		emit_signal("useSecondary", EQUIPED_LEFT)
		playUseAnims(EQUIPED_LEFT, leftHand)
	
	if Input.is_action_just_pressed("swap"):
		var temp = EQUIPED_LEFT
		EQUIPED_LEFT = EQUIPED_RIGHT
		EQUIPED_RIGHT = temp
		send_inventory_to_ui()
	
	if Input.is_action_pressed("recharge"):
		reload.emit(delta, EQUIPED_RIGHT, EQUIPED_LEFT)
	
	if Input.is_action_just_pressed("recharge"):
		reloadSfx.emit()
	
	if Input.is_action_just_released("recharge"):
		reloadSfx.emit()
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Coruching disables srpint and goes slower
	if Input.is_action_just_pressed("crouch"):
		crouching = true
		playerCollision.shape.height = 1.0
		currentSpeed = SPEED / 2
	elif Input.is_action_just_released("crouch"):
		crouching = false
		currentSpeed = SPEED
		playerCollision.shape.height = 2.0
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
		if sprinting:
			permNoise = 2
		else:
			permNoise = 0.5 if !crouching else 0.1
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
		permNoise = 0

# Signal connections
func _on_flashlight_emit_noise(noiseMade):
	# Flashlight recharge shouldnt be louder than 2
	if tempNoise < 2:
		tempNoise += noiseMade

func playUseAnims(itemName : String, hand):
	match itemName:
		"Flashlight":
			hand.useFlashlight()
		"Coinbag":
			hand.useCoinbag()

func playEquipAnims(itemName : String, hand):
	match itemName:
		"Flashlight":
			hand.equipFlashlight()
		"Coinbag":
			hand.equipCoinbag()
		"":
			hand.dequip()

# Send inventory to ui and update anims
func send_inventory_to_ui():
	emit_signal("updateInventory", INVENTORY)

func exitLevel():
	active = false
	anim_player.play("UI_fade_in")

func kill(killAnim := ""):
	active = false
	rightHand.dequip()
	leftHand.dequip()
	match killAnim:
		_:
			anim_player.play("Death_Generic")
			await anim_player.animation_finished
			gameOver.emit()
			queue_free()

func bulletShot():
	shot = true
	hitByByllet.emit()
	anim_player.play("UI_Hurt_Show")

func heal():
	shot = false
	anim_player.play("UI_Hurt_Hide")

# Equiping items from inventory
func _on_flashlight_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				EQUIPED_RIGHT = "Flashlight"
				if EQUIPED_LEFT == EQUIPED_RIGHT:
					EQUIPED_LEFT = ""
					playEquipAnims(EQUIPED_LEFT, leftHand)
				playEquipAnims(EQUIPED_RIGHT, rightHand)
			MOUSE_BUTTON_RIGHT:
				EQUIPED_LEFT = "Flashlight"
				playEquipAnims("Flashlight", leftHand)
				if EQUIPED_RIGHT == EQUIPED_LEFT:
					EQUIPED_RIGHT = ""
					playEquipAnims(EQUIPED_RIGHT, rightHand)
				playEquipAnims(EQUIPED_LEFT, leftHand)
		send_inventory_to_ui()

func _on_coinbag_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				EQUIPED_RIGHT = "Coinbag"
				if EQUIPED_LEFT == EQUIPED_RIGHT:
					EQUIPED_LEFT = ""
					playEquipAnims(EQUIPED_LEFT, leftHand)
				playEquipAnims(EQUIPED_RIGHT, rightHand)
			MOUSE_BUTTON_RIGHT:
				EQUIPED_LEFT = "Coinbag"
				playEquipAnims("Coinbag", leftHand)
				if EQUIPED_RIGHT == EQUIPED_LEFT:
					EQUIPED_RIGHT = ""
					playEquipAnims(EQUIPED_RIGHT, rightHand)
				playEquipAnims(EQUIPED_LEFT, leftHand)
		send_inventory_to_ui()

func _on_flare_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				EQUIPED_RIGHT = "Flare"
				if EQUIPED_LEFT == EQUIPED_RIGHT:
					EQUIPED_LEFT = ""
					playEquipAnims(EQUIPED_LEFT, leftHand)
				playEquipAnims(EQUIPED_RIGHT, rightHand)
			MOUSE_BUTTON_RIGHT:
				EQUIPED_LEFT = "Flare"
				playEquipAnims("Flare", leftHand)
				if EQUIPED_RIGHT == EQUIPED_LEFT:
					EQUIPED_RIGHT = ""
					playEquipAnims(EQUIPED_RIGHT, rightHand)
				playEquipAnims(EQUIPED_LEFT, leftHand)
		send_inventory_to_ui()

func _on_terminal_toggle_control_to_player():
	active = !active
	if active:
		playerCam.current = true
