# FoodSpawner.gd
extends Node3D

@export var food_scene: PackedScene # Drag your Food.tscn file here

# --- Spawning Logic ---
@export var spawn_height := 15.0
# How far from the target the food can spawn, for a little randomness.
@export var spawn_offset_radius := 2.0 

# --- Dynamic Speed Logic ---
@export var initial_wait_time := 3.0   # How long between spawns at the start.
@export var minimum_wait_time := 0.5   # The fastest the spawner can get.
# How much to reduce the wait time after each spawn. 0.98 = 2% faster.
@export var speed_up_factor := 0.98 

@onready var spawn_timer: Timer = $Timer

func _ready():
	# Set the initial spawn rate and connect the timer's signal
	spawn_timer.wait_time = initial_wait_time
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	if not food_scene:
		print("ERROR: Food scene is not set in the FoodSpawner.")
		return
	
	# --- 1. Find a Target ---
	var all_targets = get_tree().get_nodes_in_group("players")
	if all_targets.is_empty():
		return # If there are no players, do nothing.
		
	# Pick a random player or AI from the list
	var random_target = all_targets.pick_random()
	
	# --- 2. Spawn Food Above the Target ---
	var target_position = random_target.global_position
	var new_food = food_scene.instantiate()
	
	# Add a small random offset so it's not perfectly aimed every time
	var offset_x = randf_range(-spawn_offset_radius, spawn_offset_radius)
	var offset_z = randf_range(-spawn_offset_radius, spawn_offset_radius)
	
	# Set the food's position in the sky above the target
	new_food.global_position = Vector3(target_position.x + offset_x, spawn_height, target_position.z + offset_z)
	get_tree().root.add_child(new_food)
	
	# --- 3. Increase the Spawn Rate for Next Time ---
	var new_wait_time = spawn_timer.wait_time * speed_up_factor
	# Use max() to make sure the wait_time never goes below our defined minimum
	spawn_timer.wait_time = max(new_wait_time, minimum_wait_time)
	print("Next food spawn in ", spawn_timer.wait_time, " seconds.")
