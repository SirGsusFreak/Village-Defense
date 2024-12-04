extends Node3D

const SPEED  = 100.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@export var damage: int = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0, -SPEED) * delta
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
		


func _on_timer_timeout() -> void:
	queue_free()
