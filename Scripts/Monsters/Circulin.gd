extends CharacterBody3D

#Export vars
@export var timeToSearch : float = 30
@export var searchRange := [-60, 60]

# Nodes
@onready var nav_agent = $NavigationAgent3D
@onready var noise_detection = $NoiseCast
@onready var sight_detection = $SightCast
@onready var idle_timer = $idleTimer
@onready var anims = $AnimationPlayer
var navigationMaps : Array[RID]

@onready var eh = $Eh
@onready var risa = $Risa
@onready var enfadado = $Enfadado

# Vector targets
var centerOfMap := Vector3(-67.688, 0, -23.18)
var target : Vector3
var lastAlertSpot : Vector3

# Constants
const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5
const MAX_CURIOSITY : float = 10

# gameplay variables for chasing the player
var searchTime : float = 0
var curiosity : float = 0
var alert : bool = false
var idle : bool = true
var hearing : bool = false
var playerFound : bool = false
var soundCooldown : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	navigationMaps = NavigationServer3D.get_maps()
	target = global_position
	anims.play("Idle")
	call_deferred("actor_setup")
	if get_tree().get_nodes_in_group("Center").size() > 0:
		centerOfMap = get_tree().get_first_node_in_group("Center").global_position

func actor_setup():
	await get_tree().physics_frame
	
	nav_agent.target_position = target

func setTarget(newTarget : Vector3):
	target = newTarget
	
	actor_setup()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if noise_detection.is_colliding() or sight_detection.is_colliding():
		hearing = true
		# Check if its a player. All noises should have a type set
		if sight_detection.is_colliding() or (noise_detection.get_collider(0) is Area3D and noise_detection.get_collider(0).TYPE == "Player"):
			playerFound = true
			if !soundCooldown:
				soundCooldown = true
				risa.play()
				anims.stop()
				anims.play("Chase")
		else:
			playerFound = false
			if !soundCooldown:
				soundCooldown = true
				eh.play()
				anims.play("Idle")
	else :
		playerFound = false
		hearing = false
		if soundCooldown:
			await get_tree().create_timer(2).timeout
			soundCooldown = false
	
	# Lose curiosity when nothing is happening, if searching for something then lose curiosity slower
	if !alert:
		searchTime -= delta
		if searchTime < 0:
			searchTime = 0
		
		if hearing:
			curiosity += delta * 4
			if curiosity > 3:
				if noise_detection.get_collision_count() > 0 and noise_detection.get_collider(0) != null:
					setTarget(noise_detection.get_collider(0).global_position)
					alert = true
					idle = false
				elif sight_detection.get_collision_count() > 0 and sight_detection.get_collider(0) != null:
					setTarget(sight_detection.get_collider(0).global_position)
					alert = true
					idle = false
			if curiosity > MAX_CURIOSITY:
				curiosity = MAX_CURIOSITY
		else:
			curiosity -= delta
			if curiosity < 0:
				curiosity = 0
	else:
		if playerFound:
			if sight_detection.is_colliding():
				setTarget(sight_detection.get_collider(0).global_position)
			else:
				setTarget(noise_detection.get_collider(0).global_position)
	
	if nav_agent.is_navigation_finished():
		idle = true
		if alert:
			alert = false
			lastAlertSpot = target
			searchTime = timeToSearch
		return
	
	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	
	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * SPEED
	new_velocity = new_velocity * delta * 50
	
	set_velocity(new_velocity)
	
	if playerFound:
		look_at(target if global_position != target else Vector3.FORWARD)
	else:
		look_at(global_transform.origin + velocity, Vector3.UP)
	
	move_and_slide()

# What to do when there is no noise around
func _on_idle_timer_timeout():
	# When searching, it will go to the spot where the sound came from and scout the area
	if !alert and idle and searchTime > 0:
		idle = false
		var searchSpot := Vector3(lastAlertSpot)
		
		# Go to a new spot thats nearby
		searchSpot.x += randf_range(-10, 10)
		searchSpot.z += randf_range(-10, 10)
		
		setTarget(NavigationServer3D.map_get_closest_point(navigationMaps[0], searchSpot))
	elif !alert and searchTime == 0 and idle:
		idle = false
		var searchSpot := centerOfMap
		# Go to a new spot thats somewhere else
		searchSpot.x += randf_range(searchRange[0], searchRange[1])
		searchSpot.z += randf_range(searchRange[0], searchRange[1])
		
		setTarget(NavigationServer3D.map_get_closest_point(navigationMaps[0], searchSpot))

func _on_kill_area_body_entered(body):
	body.kill("Circulin")
