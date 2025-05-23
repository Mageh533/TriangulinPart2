extends CharacterBody3D

const SPEED : float = 30
const FLASHLIGHT_TIME : float = 3

@export var appearChance : float = 0.2
@export var appearCooldown : float = 5
@export var killTimerOverride : float = -1

var navigationMaps : Array[RID]

var timeOut : bool = false
var cooldownActive : bool = false

var flashlight_time_left : float

var target : Vector3

@onready var killtimer = $KillTimer
@onready var nav_agent = $NavigationAgent3D
@onready var flashlight_cast = $FlashlightDetect
@onready var risa = $Risa
@onready var chase = $Chase

# Get all spawnpoints
func _ready():
	navigationMaps = NavigationServer3D.get_maps()
	
	hide()
	
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	
	nav_agent.target_position = target

func setTarget(newTarget : Vector3):
	target = newTarget
	
	actor_setup()

func _process(delta):
	if get_tree().get_nodes_in_group("Players").size() > 0:
		look_at(get_tree().get_first_node_in_group("Players").global_position)
	
	if visible:
		if timeOut:
			if get_tree().get_first_node_in_group("Players") != null:
				setTarget(NavigationServer3D.map_get_closest_point(navigationMaps[0], get_tree().get_first_node_in_group("Players").global_position))
			
			var current_agent_position: Vector3 = global_transform.origin
			var next_path_position: Vector3 = nav_agent.get_next_path_position()
			
			var new_velocity: Vector3 = next_path_position - current_agent_position
			new_velocity = new_velocity.normalized()
			new_velocity = new_velocity * SPEED
			new_velocity = new_velocity * delta * 50
			
			set_velocity(new_velocity)
			
			look_at(target)
			
			move_and_slide()
		else:
			if flashlight_cast.is_colliding():
				flashlight_time_left -= delta
				if flashlight_time_left <= 0:
					dissapear()

func appear(spawnPoint : Vector3):
	if randf_range(0, 1) <= appearChance:
		if !visible:
			show()
			
			flashlight_time_left = FLASHLIGHT_TIME
			
			global_position = spawnPoint
			
			risa.play()
			
			# Override the timer 
			killtimer.start(killTimerOverride)

func dissapear():
	hide()
	
	killtimer.stop()

func _on_kill_timer_timeout():
	timeOut = true
	
	chase.play()

func _on_kill_area_body_entered(body):
	body.kill("Triangulin")
