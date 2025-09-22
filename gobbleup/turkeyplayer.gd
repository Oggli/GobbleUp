# turkeyplayer.gd
extends "res://Turkey.gd"

@export var player_id := 1

func _ready():
	print("Player ", player_id, " spawned.")
	add_to_group("player_" + str(player_id))
	add_to_group("players")


func get_movement_direction() -> Vector3:
	var movement_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return Vector3(movement_input.x, 0, movement_input.y).normalized()
