extends Node

@export_group("Spawners")
@export var spawners: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawners = get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _set_active(active: bool):
	for spawner in spawners:
		spawner._set_active(active)
