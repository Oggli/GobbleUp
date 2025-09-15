
extends CharacterBody3D

@export var speed = 10.0  
@export var friction = 0.1 
@export var max_size = 100
@export var pickup_heal_amount = 25
@export var player_id = 1

var size = 0

func _ready():
	print("Player ", player_id, " spawned with ", size, " size.")
	add_to_group("player_" + str(player_id)) # maybe not needed :/
	add_to_group("players") 

func _physics_process(delta):

	var movement_input = Vector2.ZERO
	if player_id == 1:
		movement_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction = Vector3(movement_input.x, 0, movement_input.y).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * friction)
		velocity.z = move_toward(velocity.z, 0, speed * friction)

	move_and_slide()


# Increases the player's size.
func grow(amount):
	size = min(size + amount, max_size)
	print("Player ", player_id, " Current size: ", size)
	if size >= max_size:
		print("size is full!")
