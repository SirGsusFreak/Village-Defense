class_name Tower
extends Node3D

@export var health: int = 100
@export var max_health: int = 100

func _on_take_damage(amount: int):
	health -= amount
	print("Tower took damage! Remaining health: ", health)
	
	if health <= 0:
		die()

func die():
	Signalbus.emit_signal("tower_destroyed")
