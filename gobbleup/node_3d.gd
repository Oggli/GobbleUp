# Main.gd (this code goes in your node_3d.gd file)
extends Node3D

# --- Scenes to Spawn ---
@export var player_scene: PackedScene
@export var ai_scene: PackedScene
@export var hand_scene: PackedScene

# --- Nodes to Manage ---
@export var press_start_sprite: AnimatedSprite3D
@export var food_spawner: Node
@export var sun_rotator: Node3D

# --- Configuration ---
@export var title_screen_ai_count := 5
@export var gameplay_ai_count := 10
@export var spawn_radius := 2.0

enum GameState { TITLE, PLAYING }
var current_state = GameState.TITLE

func _ready():
	setup_title_screen()

func _input(event: InputEvent):
	if current_state == GameState.TITLE and event.is_pressed():
		start_game()

func setup_title_screen():
	print("Setting up Title Screen...")
	current_state = GameState.TITLE
	
	press_start_sprite.show()
	
	food_spawner.get_node("Timer").stop()
	sun_rotator.hide()
	
	for i in title_screen_ai_count:
		spawn_ai()

func start_game():
	print("Starting Game!")
	current_state = GameState.PLAYING
	
	press_start_sprite.hide()
	
	for entity in get_tree().get_nodes_in_group("players"):
		entity.queue_free()
		
	# Enable game systems and connect to the sun's signal
	food_spawner.get_node("Timer").start()
	sun_rotator.show()
	
	if is_instance_valid(sun_rotator):
		sun_rotator.sunset_reached.connect(_on_sunset_reached)
	else:
		print("ERROR: Sun Rotator is not linked in Main script's inspector!")

	var player_instance = player_scene.instantiate()
	player_instance.position = Vector3(0, 1.0, 0)
	add_child(player_instance)
	
	for i in gameplay_ai_count:
		spawn_ai()

# This function now runs when the sunset signal is received
func _on_sunset_reached():
	var all_turkeys = get_tree().get_nodes_in_group("players")
	if all_turkeys.is_empty(): return

	var fattest_turkey = null
	var max_size = -1

	for turkey in all_turkeys:
		if "size" in turkey and turkey.size > max_size:
			max_size = turkey.size
			fattest_turkey = turkey
	
	if is_instance_valid(fattest_turkey):
		print("Sunset hand is spawning for fattest turkey with size: ", max_size)
		var hand_instance = hand_scene.instantiate()
		add_child(hand_instance)
		hand_instance.start_grab(fattest_turkey)

func spawn_ai():
	if not ai_scene: return
	
	var ai_instance = ai_scene.instantiate()
	var random_x = randf_range(-spawn_radius, spawn_radius)
	var random_z = randf_range(-spawn_radius, spawn_radius)
	ai_instance.position = Vector3(random_x, 1.0, random_z)
	add_child(ai_instance)
