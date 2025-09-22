# GameManager.gd
extends Node

# Drag your Hand.tscn file here in the editor.
@export var hand_scene: PackedScene 
# --- NEW: We need a reference to the SunRotator node. ---
# Drag your SunRotator node here in the editor.
@export var sun_rotator: Node3D

# The Timer is no longer needed.

func _ready():
	# If the sun rotator is linked, connect to its 'sunset_reached' signal.
	if is_instance_valid(sun_rotator):
		sun_rotator.sunset_reached.connect(_on_sunset_reached)
	else:
		print("ERROR: Sun Rotator is not linked in GameManager's inspector!")

# This function now runs when the signal is received, not when a timer times out.
func _on_sunset_reached():
	# This logic is the same as before.
	var all_turkeys = get_tree().get_nodes_in_group("players")
	if all_turkeys.is_empty():
		return

	var fattest_turkey = null
	var max_size = -1

	for turkey in all_turkeys:
		if "size" in turkey and turkey.size > max_size:
			max_size = turkey.size
			fattest_turkey = turkey
	
	if is_instance_valid(fattest_turkey):
		print("Sunset hand is spawning for fattest turkey with size: ", max_size)
		var hand_instance = hand_scene.instantiate()
		get_tree().root.add_child(hand_instance)
		hand_instance.start_grab(fattest_turkey)
