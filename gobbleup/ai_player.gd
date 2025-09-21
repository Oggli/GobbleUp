
extends RigidBody3D


@export var speed := 20.0
@export var wander_change_interval := 3.0


enum State { WANDERING, PUSHING_TO_FOOD }

var current_state := State.WANDERING
var wander_direction := Vector3.ZERO
var food_target: Node3D = null
var push_target: RigidBody3D = null

@onready var wander_timer: Timer = $WanderTimer
@onready var food_detector: Area3D = $FoodDetector
@onready var sprite: Sprite3D = $Sprite3D

func _ready():
	print("AI Turkey spawned.")
	add_to_group("players") 
	wander_timer.wait_time = wander_change_interval
	wander_timer.timeout.connect(_on_wander_timer_timeout)
	wander_timer.start()
	_pick_random_direction()
	
	food_detector.body_entered.connect(_on_food_detector_body_entered)
	food_detector.body_exited.connect(_on_food_detector_body_exited)


func _physics_process(delta: float):
	match current_state:
		State.WANDERING:
			linear_velocity += wander_direction * speed * delta

		State.PUSHING_TO_FOOD:
			if is_instance_valid(food_target) and is_instance_valid(push_target):

				var player_pos = push_target.global_position
				var food_pos = food_target.global_position
				var ram_direction = (player_pos - food_pos).normalized()
				var ram_position = player_pos + ram_direction
				

				var direction_to_ram = (ram_position - global_position).normalized()
				linear_velocity += direction_to_ram * speed * delta
			else:

				find_new_targets()



	if abs(linear_velocity.x) > 0.1:
		sprite.flip_h = linear_velocity.x < 0.0



func _on_food_detector_body_entered(body: Node):
	if body.is_in_group("food"):
		print("AI detected food!")
		current_state = State.PUSHING_TO_FOOD
		find_new_targets()

func _on_food_detector_body_exited(body: Node):
	if body == food_target:
		print("AI lost food target.")
		food_target = null
		push_target = null
		current_state = State.WANDERING

func find_new_targets():
	var overlapping_bodies = food_detector.get_overlapping_bodies()
	

	var closest_food: Node3D = null
	var min_dist_sq = INF
	for body in overlapping_bodies:
		if body.is_in_group("food"):
			var dist_sq = global_position.distance_squared_to(body.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest_food = body
	food_target = closest_food


	var closest_player: RigidBody3D = null
	min_dist_sq = INF
	for body in overlapping_bodies:
		if body.is_in_group("players") and body != self:
			var dist_sq = global_position.distance_squared_to(body.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest_player = body
	push_target = closest_player
	

	if not is_instance_valid(food_target) or not is_instance_valid(push_target):
		current_state = State.WANDERING




func _on_wander_timer_timeout():
	_pick_random_direction()

func _pick_random_direction():
	var random_angle = randf_range(0, TAU) 
	wander_direction = Vector3(cos(random_angle), 0, sin(random_angle))
