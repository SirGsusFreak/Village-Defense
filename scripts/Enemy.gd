extends CharacterBody3D

class_name Enemy

# Variables to store the player, tower, and speed of the enemy
@export var player_path: NodePath = NodePath("../../Player")
@export var tower_path: NodePath = NodePath("../../../NavigationRegion3D/Tower")
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
var player: Node = null
var tower: Node = null  # Ensure both player and tower are null initially

func _ready():
	# Initialize player and tower references after spawn
	player = get_node_or_null(player_path)
	tower = get_node_or_null(tower_path)
	if player or tower:
		update_target_location()
	
	# Start a timer to delay initialization slightly if needed
	await get_tree().create_timer(0.1).timeout

func _physics_process(delta: float):
	if player or tower:
		update_target_location()
	
	if health <= 0:
		die()
	
	# Only look at the target if it's a significant distance away
	if position.distance_to(targ) > 0.1:
		look_at(targ)
		rotation.x = 0
		rotation.z = 0
	
	# If within attack range, attack; otherwise, move towards the target
	if position.distance_to(targ) <= attack_range:
		attack()
	else:
		var cur_loc = global_transform.origin
		var next_loc = agent.get_next_path_position()
		
		if next_loc.distance_to(cur_loc) > 0.1:
			velocity = (next_loc - cur_loc).normalized() * speed
			move_and_slide()
		else:
			velocity = Vector3.ZERO

func update_target_location():
	if not agent:
		return
	
	# Determine the closest target (player or tower)
	var player_dist = player.global_transform.origin.distance_to(position) if player else INF
	var tower_dist = tower.global_transform.origin.distance_to(position) if tower else INF
	
	if player_dist < tower_dist:
		targ = player.global_transform.origin
	else:
		targ = tower.global_transform.origin
	
	agent.set_target_position(targ)

func take_damage(amount: int):
	health -= amount
	
	if amount > defense:
		var original_speed = speed
		speed = 0
		await get_tree().create_timer(0.3).timeout
		speed = original_speed
	
	if health <= 0:
		die()

func die():
	is_alive = false
	
	if player and player.has_method("add_experience"):
		player.add_experience(experience)
	
	drop_loot()
	queue_free()

func drop_loot():
	if loot_table.size() > 0:
		var random_index = randi() % loot_table.size()
		var dropped_item_scene = loot_table[random_index]
		if dropped_item_scene is PackedScene:
			var dropped_item = dropped_item_scene.instantiate()
			get_parent().add_child(dropped_item)
			dropped_item.global_transform.origin = global_transform.origin

func attack():
	if position.distance_to(player.global_transform.origin) <= attack_range and player.has_method("take_damage"):
		player.take_damage(attack_power)
	elif position.distance_to(tower.global_transform.origin) <= attack_range and tower.has_method("take_damage"):
		tower.take_damage(attack_power)