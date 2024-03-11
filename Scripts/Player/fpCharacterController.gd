extends CharacterBody3D

# Signals
signal sendCurrentNoise(currentNoise : float)
signal sendCurrentStamina(currentStamina : float)
signal use_flashlight
signal reload(delta : float)

# Nodes
@onready var noiseNode = $Noise/NoiseCollision
@onready var interactRay = $Head/Interact

# Editable constants
@export var SENSITIVITY : float = 0.01
@export var MAX_STAMINA : float = 100.0
@export var STAMINA_DRAIN_RATE : float = 1.0
@export var STAMINA_RECHARGE_RATE : float = 1.0

# Constants
const SPEED : float = 4.5
const SPRINT_SPEED : float = 8
const JUMP_VELOCITY : float = 2.0
const STEPS_TO_NOISE : float = 0.5

# Gameplay variables
var permNoise : float = 0
var tempNoise : float = 0
var noise : float = 0
var currentSpeed : float = 0
var stamina : float = 0
var steps : float = 0

var active : bool = true
var sprinting : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready():
	stamina = MAX_STAMINA

func _process(delta):
	processNoise(delta)
	emit_signal("sendCurrentStamina", stamina)
	
	# Free the mouse if the player is not active
	if active:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if active:
		playerControls(delta)
	
	# Walking makes noise
	if steps < 0:
		steps = STEPS_TO_NOISE
		if tempNoise < 4:
			tempNoise += 0.5
	
	move_and_slide()

# Mouselook
func _input(event):
	if event is InputEventMouseMotion and active:
		rotation.y -= event.relative.x * SENSITIVITY
		
		$Head.rotation.x -= event.relative.y * SENSITIVITY
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-45), deg_to_rad(90))

func processNoise(delta):
	if tempNoise > 0:
		tempNoise -= delta
		if tempNoise < 0:
			tempNoise = 0
	
	noise = tempNoise + permNoise
	
	noiseNode.shape.radius = noise
	
	emit_signal("sendCurrentNoise", noise)

func playerControls(delta):
	# Sprinting
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
	
	# Handle objects that are interactable
	if Input.is_action_just_pressed("interact"):
		if interactRay.is_colliding():
			interactRay.get_collider().use()
	
	if Input.is_action_just_pressed("flashlight_toggle"):
		emit_signal("use_flashlight")
	
	if Input.is_action_pressed("recharge"):
		emit_signal("reload", delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
		steps -= (delta if !sprinting else delta * 2)
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

# Signal connections
func _on_flashlight_emit_noise(noiseMade):
	# Flashlight recharge shouldnt be louder than 2
	if tempNoise < 2:
		tempNoise += noiseMade
