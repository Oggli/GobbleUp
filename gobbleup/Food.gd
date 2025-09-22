extends Area3D
@export var fall_speed := 5.0
@export var land_height := 1  # The Y-position of your ground plane
@export var grow_amount := 500    # How much size the player gains

# Sine wave bobbing effect
@export var bob_amplitude := 0.2
@export var bob_frequency := 2.0

# States for our food item
enum State { FALLING, LANDED }
var current_state := State.FALLING
var time := 0.0 # A counter for the sine wave calculation

@onready var sprite: Sprite3D = $Sprite3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
	# Connect the signal for when a player/AI body enters our area
	body_entered.connect(_on_body_entered)
	# Disable collision until the food has landed
	collision_shape.disabled = true

func _physics_process(delta: float):
	# The food's behavior depends on its state
	match current_state:
		State.FALLING:
			# Move the food down
			position.y -= fall_speed * delta
			
			# Check if it has hit the ground
			if position.y <= land_height:
				_land()

		State.LANDED:
			# Create the bobbing effect
			time += delta
			var bob_offset = sin(time * bob_frequency) * bob_amplitude
			# Apply the bob to the sprite, not the root node, to keep the collision stable
			sprite.position.y = bob_offset

func _land():
	# --- DEBUG: Add this print statement ---
	print("--- LAND FUNCTION CALLED! Food is now active. ---")
	
	position.y = land_height
	current_state = State.LANDED
	
	add_to_group("food")
	
	collision_shape.disabled = false

func _on_body_entered(body: Node3D):
	# Check if the thing that touched us is in the "players" group
	if body.is_in_group("players"):
		# Check if it has a "grow" function before calling it
		if body.has_method("grow"):
			print("Player picked up food.")
			body.grow(grow_amount)
		
		# Destroy the food item
		queue_free()
