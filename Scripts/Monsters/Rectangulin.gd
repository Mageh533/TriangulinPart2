extends CharacterBody3D

#Export vars
@export var timeToSearch : float = 30
@export var bullet : PackedScene

# Nodes
@onready var nav_agent = $NavigationAgent3D
@onready var noise_detection = $NoiseCast
@onready var sight_detection = $SightCast
@onready var idle_timer = $idleTimer
@onready var glove_left = $glove_left
@onready var glove_right = $glove_right
@onready var face = $rectangulin
var navigationMaps : Array[RID]

# Vector targets
var centerOfMap := Vector3(-67.688, 0, -23.18)
var target : Vector3
var lastAlertSpot : Vector3

# Constants
const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5
const MAX_CURIOSITY : float = 10
const TIME_TO_SHOOT : float = 3

# gameplay variables for chasing the player
var searchTime : float = 0
var timeLeftToShoot : float = 0
var curiosity : float = 0
var alert : bool = false
var idle : bool = true
var playerFound : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	timeLeftToShoot = TIME_TO_SHOOT
	navigationMaps = NavigationServer3D.get_maps()
	target = global_position
	call_deferred("actor_setup")

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
	
	if sight_detection.get_collision_count() > 0 and sight_detection.get_collider(0) != null:
		face.angry()
		look_at(sight_detection.get_collider(0).global_position)
		lastAlertSpot = sight_detection.get_collider(0).global_position
		alert = true
		idle = false
		glove_right.gun()
		glove_left.grab()
		timeLeftToShoot -= delta
		if timeLeftToShoot <= 0:
			shoot()
			timeLeftToShoot = TIME_TO_SHOOT
		return
	else:
		face.normal()
		if nav_agent.is_navigation_finished():
			idle = true
			if alert:
				alert = false
				lastAlertSpot = target
				searchTime = timeToSearch
			return
	
	# Lose curiosity when nothing is happening, if searching for something then lose curiosity slower
	if !alert:
		searchTime -= delta
		if searchTime < 0:
			searchTime = 0
		
		if noise_detection.is_colliding():
			curiosity += delta * 4
			if curiosity > 3:
				if noise_detection.get_collision_count() > 0 and noise_detection.get_collider(0) != null:
					setTarget(noise_detection.get_collider(0).global_position)
					alert = true
					idle = false
			if curiosity > MAX_CURIOSITY:
				curiosity = MAX_CURIOSITY
		else:
			curiosity -= delta
			timeLeftToShoot = TIME_TO_SHOOT
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

func shoot():
	var bulletShot = bullet.instantiate()
	get_tree().root.add_child(bulletShot)
	bulletShot.global_transform = global_transform

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
		searchSpot.x += randf_range(-60, 60)
		searchSpot.z += randf_range(-50, 50)
		
		setTarget(NavigationServer3D.map_get_closest_point(navigationMaps[0], searchSpot))
