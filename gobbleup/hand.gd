

# Hand.gd
extends Node3D

# --- Configuration ---
@export var descend_speed := 8.0
@export var ascend_speed := 10.0
@export var sky_height := 20.0 # The Y-level where the hand disappears

# --- State Machine ---
enum State { IDLE, DESCENDING, GRABBING, ASCENDING }
var current_state = State.IDLE

var target_turkey: Node3D = null

# This is the main function that starts the whole process.
func start_grab(turkey_to_grab: Node3D):
	if turkey_to_grab:
		target_turkey = turkey_to_grab
		# Start above the target turkey
		global_position = target_turkey.global_position + Vector3(0, sky_height, 0)
		current_state = State.DESCENDING
		print("Hand is descending for turkey: ", target_turkey.name)

func _physics_process(delta: float):
	if not is_instance_valid(target_turkey):
		if current_state != State.IDLE:
			print("Hand target became invalid, destroying self.")
			queue_free() # Clean up the hand if its target disappears
		return
	
	match current_state:
		State.DESCENDING:
			# Move towards the turkey's position
			global_position = global_position.move_toward(target_turkey.global_position, descend_speed * delta)
			# When we reach it, grab it
			if global_position.is_equal_approx(target_turkey.global_position):
				current_state = State.GRABBING

		State.GRABBING:
			# Disable the turkey's physics script and make it a child of the hand
			target_turkey.set_physics_process(false)
			target_turkey.reparent(self) # The turkey will now move with the hand
			current_state = State.ASCENDING
			print("Hand has grabbed the turkey!")

		State.ASCENDING:
			# Move straight up into the sky
			global_position.y += ascend_speed * delta
			# When we reach the sky, disappear
			if global_position.y >= sky_height:
				print("Hand has escaped with the turkey.")
				queue_free() # This destroys the hand and the turkey it's carrying
