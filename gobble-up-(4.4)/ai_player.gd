extends CharacterBody3D

## --- AI Configuration ---
@export var speed := 8.0
@export var friction := 0.1
@export var wander_change_interval := 2.0 # How often to change direction (in seconds)

## --- AI State ---
var player_target = null
var wander_direction := Vector3.ZERO

# A timer to control the wandering behavior
@onready var wander_timer := Timer.new()


func _ready():
	print("AI Turkey spawned.")
	add_to_group("players")
	
	# Try to find the player at the start
	player_target = get_tree().get_first_node_in_group("player_1")
	
	# Set up and start the timer for wandering
	wander_timer.wait_time = wander_change_interval
	wander_timer.one_shot = false # Make it repeat
	wander_timer.timeout.connect(_on_wander_timer_timeout)
	add_child(wander_timer)
	wander_timer.start()
	
	# Pick an initial random direction so it doesn't stand still
	_pick_random_direction()


func _physics_process(delta: float):
	var direction := Vector3.ZERO
	
	# --- BEHAVIOR SELECTION ---
	# If the player exists (is valid), chase them.
	# Otherwise, execute wander behavior.
	if is_instance_valid(player_target):
		direction = (player_target.global_position - global_position).normalized()
	else:
		# When no player is found, use the wandering direction
		direction = wander_direction

	# --- MOVEMENT ---
	# Apply velocity based on the determined direction
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Slow down smoothly if there's no direction
		velocity = velocity.lerp(Vector3.ZERO, friction)
		
	# --- ANIMATION ---
	# This improved logic flips all sprites based on horizontal velocity
	if abs(velocity.x) > 0.1: # Use a small threshold to prevent flipping when still
		var should_flip = velocity.x < 0.0
		# Assuming all your sprites are children of this node
		for sprite in $CollisionShape3D.get_children():
			if "flip_h" in sprite: # Check if the node can be flipped
				sprite.flip_h = should_flip

	move_and_slide()


## --- Helper Functions ---

# This function is called every time the WanderTimer times out
func _on_wander_timer_timeout():
	# Only pick a new direction if we are in a wandering state (no player)
	if not is_instance_valid(player_target):
		_pick_random_direction()

# Calculates a new random horizontal direction
func _pick_random_direction():
	var random_x = randf_range(-1.0, 1.0)
	var random_z = randf_range(-1.0, 1.0)
	wander_direction = Vector3(random_x, 0, random_z).normalized()