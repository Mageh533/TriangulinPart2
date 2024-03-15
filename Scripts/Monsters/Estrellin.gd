extends CharacterBody3D

# Nodes
@onready var nav_agent = $NavigationAgent3D
@onready var noise_detection = $NoiseCast
@onready var idle_timer = $idleTimer
var navigationMaps : Array[RID]

@export var seearchTime : float = 30

var target : Vector3
var lastAlertSpot : Vector3

const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5

var curiosity : int = 0

# gameplay variables for chasing the player
var alert : bool = false
var idle : bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	navigationMaps = NavigationServer3D.get_maps()
	target = global_position
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	
	nav_agent.target_position = target

func setTarget(newTarget : Vector3):
	target = newTarget
	idle = false
	
	actor_setup()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if noise_detection.is_colliding():
		setTarget(noise_detection.get_collider(0).global_position)
		alert = true
		idle = false
	
	if nav_agent.is_navigation_finished():
		idle = true
		if alert:
			alert = false
			lastAlertSpot = target
			idle_timer.start()
		return
	
	# Lose curiosity when nothing is happening, if searching for something then lose curiosity slower
	if !alert:
		seearchTime -= delta
		if seearchTime < 0:
			seearchTime = 0
		if curiosity > 0:
			curiosity -= delta
			if curiosity < 0:
				curiosity = 0
	
	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * SPEED
	new_velocity = new_velocity * delta * 50
	
	set_velocity(new_velocity)
	
	look_at(target)
	
	move_and_slide()

func _on_idle_timer_timeout():
	# When searching, it will go to the spot where the sound came from and scout the area
	if !alert and idle:
		idle = false
		var searchSpot := Vector3(lastAlertSpot)
		
		# Go to a new spot thats nearby
		searchSpot.x += randf_range(-15, 15)
		searchSpot.z += randf_range(-15, 15)
		
		setTarget(NavigationServer3D.map_get_closest_point(navigationMaps[0], searchSpot))
		idle_timer.start()
