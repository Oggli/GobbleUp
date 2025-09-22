# Turkey.gd
extends CharacterBody3D

@export var speed := 10.0
@export var push_force := 8.0

# --- NEW: Movement physics variables ---
@export var acceleration := 8.0
@export var friction := 10.0

var size := 0
var knockback := Vector3.ZERO
var knockback_decay := 5.0

@onready var sprite_container: Node3D = $Sprite3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# --- REWRITTEN _physics_process for better movement ---
func _physics_process(delta: float):
	# Get the desired movement direction from child scripts (Player or AI).
	var direction = get_movement_direction()

	# Apply knockback force, which fades over time.
	knockback = knockback.lerp(Vector3.ZERO, knockback_decay * delta)

	# Calculate the final target velocity.
	var target_velocity = direction * speed

	# --- Smooth Acceleration and Friction ---
	# Instead of instantly setting velocity, we smoothly interpolate to the target.
	# This prevents the "wind-up" issue against walls.
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	# If there's no input/direction, apply friction to slow down.
	if direction == Vector3.ZERO:
		velocity = velocity.lerp(Vector3.ZERO, friction * delta)
	
	# Add knockback to the final velocity calculation for this frame.
	velocity += knockback
	
	move_and_slide()

	if get_slide_collision_count() > 0:
		on_wall_collision() # Call the new function after a collision
	# Collision loop for pushing others (this logic is unchanged).
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if not collision:
			continue

		var collider = collision.get_collider()
		if collider and collider.has_method("apply_knockback"):
			var push_direction = -collision.get_normal()
			collider.apply_knockback(push_direction * push_force)

# This function will be overridden by the Player and AI scripts.
func get_movement_direction() -> Vector3:
	return Vector3.ZERO

func on_wall_collision():
	pass # The player doesn't need to do anything special.

# Public function so other turkeys can push this one.
func apply_knockback(force: Vector3):
	knockback += force

# The grow() function is unchanged.
func grow(amount: int):
	size += amount
	print(name, " growing! Current size: ", size)
	var growth_factor = 1.0 + (float(size) / 1000.0)
	var new_scale = Vector3.ONE * growth_factor
	if is_instance_valid(sprite_container):
		sprite_container.scale = new_scale
	if is_instance_valid(collision_shape):
		collision_shape.scale = new_scale
