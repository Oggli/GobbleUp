extends Node3D

@export var player_scene: PackedScene = preload("res://player.tscn")

@export var ai_scene: PackedScene = preload("res://AI_player.tscn") 

@export var spawn_radius: float = 10.0




func _ready():

	var player1 = player_scene.instantiate()
	player1.player_id = 1
	player1.position = Vector3(-5.0, 1.0, 0)	
	add_child(player1)
	

	for i in 10:

		var ai_opponent = ai_scene.instantiate()
		

		var random_x = randf_range(-spawn_radius, spawn_radius)
		var random_z = randf_range(-spawn_radius, spawn_radius)
		

		ai_opponent.position = Vector3(random_x, 1.0, random_z)
		add_child(ai_opponent)
		
		print("Spawned AI #", i + 1, " at ", ai_opponent.position)
