# enemy.gd
extends CharacterBody3D

class_name Enemy

var health: int
var speed: float

func _init(new_health: int, new_speed: float):
	health = new_health
	speed = new_speed

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free()
