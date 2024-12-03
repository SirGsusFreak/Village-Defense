class_name Spawner
extends Node3D

@export var enemy_scene: PackedScene  # The enemy scene to instance
@export var spawn_interval: float = 5.0  # Initial spawn interval in seconds
@export var spawn_acceleration: float = 0.9  # Factor to decrease spawn time over time
@export var enemy_parent: NodePath  # Node path to the parent node for enemies
@export var player_path: NodePath  # Path to the player node
@export var tower_path: NodePath  # Path to the tower node
@export var isActive: bool = true

var spawn_count: int = 0
var spawn_timer = 0.0  # Timer to control spawning
var min_spawn_interval = 1.0  # Minimum interval to prevent too fast spawning

func _ready():
	# Ensure we start with a reasonable spawn rate
	spawn_timer = spawn_interval
	set_process(true)

func _process(delta: float):
	spawn_timer -= delta
	if spawn_timer <= 0:
		_spawn_enemy()
		# Reset timer and decrease the interval slightly for the next spawn
		spawn_timer = max(spawn_interval * spawn_acceleration, min_spawn_interval)
		spawn_interval = spawn_timer  # Update spawn_interval to keep decreasing

func _spawn_enemy():
	if enemy_scene and is_inside_tree() and enemy_parent:
		var enemy_instance = enemy_scene.instantiate()
		if enemy_instance:
			# Set the spawn position based on the spawner's position
			enemy_instance.global_transform.origin = global_transform.origin
			
			
			# Get the parent node from the specified NodePath
			var parent_node = get_node(enemy_parent)
			if parent_node:
				parent_node.add_child(enemy_instance)  # Add enemy as a child of the specified node
				enemy_instance.set_id(spawn_count)
				var enemy_str = "Enemy#{id}".format({"id": spawn_count})
				enemy_instance.name = enemy_str
				spawn_count += 1
				# Assign target paths dynamically
				_set_enemy_targets(enemy_instance)


func _set_enemy_targets(enemy_instance):
	# Ensure player and tower paths are valid before assigning
	var player_node = get_node_or_null(player_path)
	var tower_node = get_node_or_null(tower_path)
	
	if player_node and tower_node and enemy_instance.has_method("set_target_paths"):
		enemy_instance.set_target_paths(player_node, tower_node)

func _set_active(active: bool):
	set_process(active)
