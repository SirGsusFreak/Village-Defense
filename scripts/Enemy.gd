class_name Enemy
extends CharacterBody3D

# Variables to store the player, tower, and speed of the enemy
@export var player_path: NodePath = NodePath("../../Player")
@export var tower_path: NodePath = NodePath("../../../NavigationRegion3D/Tower")

@export_category("Monster")
@export var monster_type: String
@export var model: Node3D
# Variables for enemy attributes
@export_group("Enemy Attributes")
@export var max_health: int
@export var attack_power: int
@export var defense: int
@export var attack_cooldown: float
@export var attack_time: float
@export var speed: float = 1.0
@export var experience: int
@export var loot_table: Array = []
@export var attack_range: float

@export_category("Debug Info")
@export var id: int
@export var health: float
@export var is_alive: bool = true
@export var can_attack: bool = true
@export var is_attacking: bool = false
@export var current_target: Node = null
@export var distance_to_targ: float

@onready var agent = $NavigationAgent3D
var targ: Vector3
var player: PlayerCharacter = null
var tower: Tower = null  # Ensure both player and tower are null initially

@onready var floorcast = $FloorCast


func _ready():
	# Initialize player and tower references after spawn
	player = get_node_or_null(player_path)
	tower = get_node_or_null(tower_path)
	if player or tower:
		update_target_location()
	
	health = max_health
	
	# Start a timer to delay initialization slightly if needed
	await get_tree().create_timer(0.1).timeout

func _physics_process(_delta: float):
	if floorcast.is_colliding():
		var collision_point = floorcast.get_collision_point()
		global_transform.origin.y = collision_point.y
	
	if player or tower:
		update_target_location()
	
	if health <= 0:
		die()
	
	# Only look at the target if it's a significant distance away
	if position.distance_to(targ) > 0.1:
		look_at(targ)
		rotation.x = 0
		rotation.z = 0
	
	if current_target:
		distance_to_targ = position.distance_to(targ)
	else: 
		distance_to_targ = 0
	

	if is_attacking:
		velocity = Vector3.ZERO
		return
	
	# If within attack range, attack; otherwise, move towards the target
	if position.distance_to(targ) <= attack_range:
		velocity = Vector3.ZERO
		attack()
	else:
		var cur_loc = global_transform.origin
		var next_loc = agent.get_next_path_position()
		
		if next_loc.distance_to(cur_loc) > 0.1:
			velocity = (next_loc - cur_loc).normalized() * speed
			move_and_slide()
			model.set_is_walking(true)
		else:
			velocity = Vector3.ZERO
			model.set_is_walking(false)

func update_target_location():
	if not agent:
		return
	
	# Determine the closest target (player or tower)
	var player_dist = player.global_transform.origin.distance_to(position) if player else INF
	var tower_dist = tower.global_transform.origin.distance_to(position) if tower else INF
	
	if player_dist < tower_dist:
		current_target = player
		targ = player.global_transform.origin
	else:
		current_target = tower
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
	
	Signalbus.emit_signal("award_xp", experience)
	
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
	if not can_attack or not is_alive or current_target == null:
		return
	
	is_attacking = true
	can_attack = false
	model.animate_attack()
	
	get_tree().create_timer(attack_time * speed / 2).connect("timeout", _deal_damage)
	get_tree().create_timer(attack_cooldown).connect("timeout", _reset_attack)


func _deal_damage():
	if current_target.has_method("_on_take_damage"):
		current_target._on_take_damage(attack_power)
	get_tree().create_timer(attack_time * speed / 2).connect("timeout", _on_attack_timeout)

func _reset_attack():
	can_attack = true

func _on_attack_timeout():
	is_attacking = false
