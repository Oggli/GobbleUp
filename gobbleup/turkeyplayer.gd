
extends RigidBody3D

@export var speed := 50.0  
@export var max_size := 100
@export var pickup_heal_amount := 25
@export var player_id := 1

var size := 0


@onready var sprite: Sprite3D = $Sprite3D

func _ready():
	print("Player ", player_id, " spawned with ", size, " size.")
	add_to_group("player_" + str(player_id))
	add_to_group("players")

func _physics_process(delta: float):

	var movement_input := Vector2.ZERO
	if player_id == 1:
		movement_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction = Vector3(movement_input.x, 0, movement_input.y)
	

	linear_velocity += direction * speed * delta
	

	if abs(movement_input.x) > 0.1:
		var should_flip = movement_input.x < 0.0
		for sprite in $Sprite3D.get_children():
			if "flip_h" in sprite:
				sprite.flip_h = should_flip



func grow(amount):
	size = min(size + amount, max_size)
	print("Player ", player_id, " Current size: ", size)
	if size >= max_size:
		print("size is full!")
