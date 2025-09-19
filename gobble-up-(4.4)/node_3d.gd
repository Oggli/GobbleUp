extends Node3D

@export var player_scene = preload("res://player.tscn")
@export var ai_script = preload("res://ai_player.gd")

func _ready():

	var player1 = player_scene.instantiate()
	player1.player_id = 1
	player1.position = Vector3(-5.0, 1.0, 0) 
	add_child(player1)
	

	var ai_opponent = player_scene.instantiate()
	ai_opponent.set_script(ai_script)
	ai_opponent.position = Vector3(5.0, 1.0, 0)
	add_child(ai_opponent)
