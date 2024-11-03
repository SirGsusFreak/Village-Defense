extends CharacterBody3D

class_name Enemy

# Variables to store the player and speed of the enemy
@export var player: Node = null
@export var speed: float = 5

# Variables for enemy attributes
@export var health: int
@export var max_health: int
@export var attack_power: int
@export var defense: int
@export var is_alive: bool = true
@export var experience: int
@export var loot_table: Array = []
@export var rotation_speed: float
@export var attack_range: float

@onready var agent = $NavigationAgent3D
var targ: Vector3


func _ready():
	
	 # Get the player node
	if player == null:
		player = get_node("/root/LevelTestPlayer/Entities/Player")
	
	# Store the player's position in targ
	if player:
		targ = player.global_transform.origin
		updateTargetLocation(targ)

func _physics_process(delta: float):
	
	# Continuously update the target to the player's current position
	if player:
		targ = player.global_transform.origin
		updateTargetLocation(targ)
	
	# Rotate the enemy to face the target
	look_at(targ)
	rotation.x = 0
	rotation.z = 0
	
	# Check if the object is far enough from the target
	if position.distance_to(targ) > 0.5:
		var curLoc = global_transform.origin
		var nextLoc = agent.get_next_path_position()
		
		# Calculate new velocity toward the next location
		var newVel = (nextLoc - curLoc).normalized() * speed
		
		# Update velocity
		velocity = newVel
		# Move the object with the velocity
		move_and_slide()

func updateTargetLocation(target):
	agent.set_target_position(target)
	

func take_damage(amount: int):
	var actual_damage = amount - defense
	if actual_damage < 0:
		actual_damage = 0
	health -= actual_damage
	if health <= 0:
		die()

func die():
	is_alive = false
	drop_loot()  # Call drop_loot when the enemy dies
	queue_free()

func drop_loot():
	if loot_table.size() > 0:
		var random_index = randi() % loot_table.size()  # Get a random index
		var dropped_item = loot_table[random_index]
		print("Dropped item: ", dropped_item)
