# sun.gd
extends Node3D

signal sunset_reached

@export var degrees_per_second := 10.0

# --- NEW: A variable to track rotation that won't be wrapped by the engine ---
var total_rotation_tracker := 0.0
var has_triggered_sunset := false

func _process(delta: float):
	# The visual rotation still happens the same way.
	rotate_z(deg_to_rad(degrees_per_second * delta))
	
	# --- MODIFIED: We now update our own tracker ---
	total_rotation_tracker += degrees_per_second * delta
	
	# --- MODIFIED: The check now uses our reliable tracker variable ---
	if total_rotation_tracker >= 180.0 and not has_triggered_sunset:
		print("SUNSET REACHED! Emitting signal.")
		sunset_reached.emit()
		has_triggered_sunset = true
	
	# The reset also uses our tracker.
	if total_rotation_tracker >= 360.0:
		total_rotation_tracker -= 360.0 # Reset for the next cycle
		has_triggered_sunset = false
