class_name Level
extends Node3D

@export var level_name: String
@export var enemy_limit: int = 10
@export var is_spawners_active: bool = true

@onready var player: CharacterBody3D = $Entities/Player
@onready var enemies_parent_node: Node = $Entities/Enemies
@onready var spawners_parent_node: Node = $Spawners

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	entity_count()


func _get_level_name() -> String:
	return level_name


func entity_count() -> void:
	if is_spawners_active and enemies_parent_node.get_child_count() >= enemy_limit:
		is_spawners_active = false
		print("Spawners have been paused.")
		spawners_parent_node._set_active(false)
	elif !is_spawners_active and enemies_parent_node.get_child_count() < enemy_limit:
		is_spawners_active = true
		print("Spawners have been unpaused.")
		spawners_parent_node._set_active(true)
