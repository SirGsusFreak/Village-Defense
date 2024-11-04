class_name Level
extends Node3D

@export var level_name: String
@export var player: CharacterBody3D
@export var enemies_parent_node: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _get_level_name() -> String:
	return level_name
