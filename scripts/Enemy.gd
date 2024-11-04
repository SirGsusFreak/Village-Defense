extends CharacterBody3D

class_name Enemy

# Variables to store the player and speed of the enemy
@export var player_path: NodePath = NodePath("../../Player")
@export var speed: float = 5

# Variables for enemy attributes
@export var health: float = 10
@export var max_health: int
@export var attack_power: int
@export var defense: int
@export var is_alive: bool = true
@export var experience: int
@export var loot_table: Array = []
@export var attack_range: float

@onready var agent = $NavigationAgent3D
var targ: Vector3
var player: Node = null  # Ensure the player is null initially

func _ready():
	# Initialize player reference after spawn
	player = get_node_or_null(player_path)
	if player:
		targ = player.global_transform.origin
		update_target_location(targ)
	
	# Start a timer to delay initialization slightly if needed
	await get_tree().create_timer(0.1).timeout
	# This allows enough time for the enemy to initialize its position and navigation

func _physics_process(delta: float):
	if player:
		targ = player.global_transform.origin
		update_target_location(targ)
	
	if health <= 0:
		die()
	
	# Only look at the target if it's a significant distance away
	if position.distance_to(targ) > 0.1:
		look_at(targ)
		rotation.x = 0
		rotation.z = 0
	
	# If within attack range, attack; otherwise, move towards the player
	if position.distance_to(targ) <= attack_range:
		attack()
	else:
		var cur_loc = global_transform.origin  # Declare cur_loc as the current position
		var next_loc = agent.get_next_path_position()
		
		if next_loc.distance_to(cur_loc) > 0.1:
			velocity = (next_loc - cur_loc).normalized() * speed
			move_and_slide()
		else:
			velocity = Vector3.ZERO



func update_target_location(target):
	if agent:
		agent.set_target_position(target)

func take_damage(amount: int):
	health -= amount
	
	if amount > defense:
		var original_speed = speed
		speed = 0 
		await get_tree().create_timer(0.3).timeout  # Wait for 0.3 seconds
		speed = original_speed 
	
	if health <= 0:
		die()

func die():
	is_alive = false
	
	if player and player.has_method("add_experience"):
		player.add_experience(experience)
	
	drop_loot()  # Call drop_loot when the enemy dies
	queue_free()

func drop_loot():
	if loot_table.size() > 0:
		var random_index = randi() % loot_table.size()  # Get a random index
		var dropped_item_scene = loot_table[random_index]
		 # Ensure the item is a valid PackedScene before instancing
		if dropped_item_scene is PackedScene:
			var dropped_item = dropped_item_scene.instantiate()
			get_parent().add_child(dropped_item)  # Add the item to the scene
			dropped_item.global_transform.origin = global_transform.origin

func attack():
	if player.has_method("take_damage"):
		player.take_damage(attack_power)
