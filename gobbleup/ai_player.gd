extends CharacterBody3D

@export var speed = 8.0 
@export var friction = 0.1
@export var max_size = 100

var size = 0
var target = null

func _ready():
	print("AI Turkey spawned.")
	add_to_group("players") 
	target = get_tree().get_first_node_in_group("player_1")

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if is_instance_valid(target):
		direction = (target.global_position - global_position).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * friction)
		velocity.z = move_toward(velocity.z, 0, speed * friction)
		
		# this is bad plz fix
	if velocity.x>0.0:
		$CollisionShape3D/head.flip_h=0
		$CollisionShape3D/body.flip_h=0
		$CollisionShape3D/legs.flip_h=0
		$CollisionShape3D/wings.flip_h=0
		$CollisionShape3D/tail.flip_h=0
	elif velocity.x<0.0:
		$CollisionShape3D/head.flip_h=1
		$CollisionShape3D/body.flip_h=1
		$CollisionShape3D/legs.flip_h=1
		$CollisionShape3D/wings.flip_h=1
		$CollisionShape3D/tail.flip_h=1

	move_and_slide()
