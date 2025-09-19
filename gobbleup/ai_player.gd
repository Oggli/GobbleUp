extends CharacterBody3D

## --- AI Configuration ---
@export var speed := 8.0
@export var friction := 0.1
@export var wander_change_interval := 2.0


var player_target = null
var wander_direction := Vector3.ZERO


@onready var wander_timer := Timer.new()


func _ready():
	print("AI Turkey spawned.")
	add_to_group("players")

	player_target = get_tree().get_first_node_in_group("player_1")

	wander_timer.wait_time = wander_change_interval
	wander_timer.one_shot = false 
	wander_timer.timeout.connect(_on_wander_timer_timeout)
	add_child(wander_timer)
	wander_timer.start()
	_pick_random_direction()


func _physics_process(delta: float):
	var direction := Vector3.ZERO
	

	if is_instance_valid(player_target):
		direction = (player_target.global_position - global_position).normalized()
	else:
		direction = wander_direction


	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity = velocity.lerp(Vector3.ZERO, friction)
		

	if abs(velocity.x) > 0.1: 
		var should_flip = velocity.x < 0.0
		for sprite in $CollisionShape3D.get_children():
			if "flip_h" in sprite: 
				sprite.flip_h = should_flip

	move_and_slide()


func _on_wander_timer_timeout():
	if not is_instance_valid(player_target):
		_pick_random_direction()


func _pick_random_direction():
	var random_x = randf_range(-1.0, 1.0)
	var random_z = randf_range(-1.0, 1.0)
	wander_direction = Vector3(random_x, 0, random_z).normalized()
