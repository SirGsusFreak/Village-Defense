extends CharacterBody3D

# Variables to store the player and speed of the enemy
var player = null
var speed = 5.0

func _ready():
	# Get the player node
	player = get_node("/root/Game/Level/Level/Player")

func _physics_process(delta):
	if player:
		# Calculate the direction to the player
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		# Move the enemy towards the player
		velocity = direction * speed
		move_and_slide()
