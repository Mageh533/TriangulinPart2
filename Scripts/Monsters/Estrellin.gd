extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var noise_detection = $NoiseCast

var target : Vector3

const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	target = global_position
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	
	nav_agent.target_position = target

func setTarget(newTarget : Vector3):
	target = newTarget
	
	actor_setup()

func _physics_process(delta):
	if noise_detection.is_colliding():
		setTarget(noise_detection.get_collider(0).global_position)
	
	if nav_agent.is_navigation_finished():
		return
	
	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * SPEED
	new_velocity = new_velocity * delta * 50
	
	set_velocity(new_velocity)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
