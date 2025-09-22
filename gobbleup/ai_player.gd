# ai_player.gd
extends "res://Turkey.gd"

# --- AI State Machine ---
enum State { WANDERING, PUSHING_TO_FOOD, AVOIDING_FOOD }
var current_state := State.WANDERING

# --- AI Configuration ---
@export var wander_change_interval := 3.0

# --- AI State Variables ---
var wander_direction := Vector3.ZERO
var food_target: Node3D = null
var push_target: Node3D = null

# --- Node References ---
@onready var wander_timer: Timer = $WanderTimer
@onready var food_detector: Area3D = $FoodDetector


func _ready():
	add_to_group("players")
	
	# Setup Timer
	wander_timer.wait_time = wander_change_interval
	wander_timer.timeout.connect(_on_wander_timer_timeout)
	wander_timer.start()

	# Setup Detector Signals
	food_detector.body_entered.connect(_on_food_detector_body_entered)
	food_detector.area_entered.connect(_on_food_detector_area_entered)
	food_detector.body_exited.connect(_on_food_detector_target_exited)
	food_detector.area_exited.connect(_on_food_detector_target_exited)
	
	change_state(State.WANDERING)


# This function provides the movement direction to the base Turkey.gd script.
func get_movement_direction() -> Vector3:
	match current_state:
		State.WANDERING:
			return wander_direction
			
		State.PUSHING_TO_FOOD:
			if is_instance_valid(food_target) and is_instance_valid(push_target):
				var player_pos = push_target.global_position
				var food_pos = food_target.global_position
				var ram_direction = (player_pos - food_pos).normalized()
				var ram_position = player_pos + ram_direction
				return (ram_position - global_position).normalized()
				
		State.AVOIDING_FOOD:
			if is_instance_valid(food_target):
				return (global_position - food_target.global_position).normalized()
	
	# By default, stand still
	return Vector3.ZERO


# --- AI Logic and State Management ---

func change_state(new_state):
	if new_state == current_state:
		return
		
	current_state = new_state
	match current_state:
		State.WANDERING:
			print(name, " State -> WANDERING")
		State.PUSHING_TO_FOOD:
			print(name, " State -> PUSHING TO FOOD")
		State.AVOIDING_FOOD:
			print(name, " State -> AVOIDING FOOD")


func _make_food_decision():
	find_new_targets()
	
	if is_instance_valid(food_target) and is_instance_valid(push_target):
		change_state(State.PUSHING_TO_FOOD)
	elif is_instance_valid(food_target):
		change_state(State.AVOIDING_FOOD)
	else:
		change_state(State.WANDERING)


func find_new_targets():
	var overlapping_bodies = food_detector.get_overlapping_bodies()
	var overlapping_areas = food_detector.get_overlapping_areas()

	var closest_food: Node3D = null
	var min_dist_sq = INF
	for area in overlapping_areas:
		if area.is_in_group("food"):
			var dist_sq = global_position.distance_squared_to(area.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest_food = area
	food_target = closest_food

	var closest_player: Node3D = null
	min_dist_sq = INF
	for body in overlapping_bodies:
		if body.is_in_group("players") and body != self:
			var dist_sq = global_position.distance_squared_to(body.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest_player = body
	push_target = closest_player

func on_wall_collision():
	# If we hit a wall AND we are in the wandering state...
	if current_state == State.WANDERING:
		# ...immediately pick a new direction to go.
		_pick_random_direction()

# --- Signal Handlers ---

func _on_food_detector_area_entered(area: Area3D):
	if area.is_in_group("food"):
		_make_food_decision()


func _on_food_detector_body_entered(body: Node):
	if body.is_in_group("players"):
		_make_food_decision()


func _on_food_detector_target_exited(target: Node):
	if target == food_target or target == push_target:
		_make_food_decision()


func _on_wander_timer_timeout():
	if current_state == State.WANDERING:
		_pick_random_direction()


func _pick_random_direction():
	var random_angle = randf_range(0, TAU)
	wander_direction = Vector3(cos(random_angle), 0, sin(random_angle))
